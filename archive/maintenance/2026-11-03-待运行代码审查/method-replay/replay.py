"""Replay an allowlisted, historical public-data case in an external directory.

Execution evidence is intentionally separate from algorithm verification. A zero
exit code cannot establish original/wrapper equivalence or scientific validity.
No packages are installed, no Wiki asset is written, and no shell is invoked.
"""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path, PurePosixPath
import shutil
import subprocess
import tempfile

from discover import PANCREAS_SHA256, PORTABLE_CASES, sha256, tokens


def safe_member(asset: Path, member: str) -> Path:
    parts = PurePosixPath(member)
    if "\\" in member or parts.is_absolute() or any(part in {".", ".."} or part.startswith(".") for part in parts.parts):
        raise ValueError(f"Unsafe runtime member: {member!r}")
    target = asset / member
    if not target.is_file() or target.is_symlink() or asset.resolve() not in target.resolve().parents:
        raise ValueError(f"Runtime member missing or escapes asset: {member!r}")
    # Reject symlinked ancestors even if they resolve back inside the asset.
    if any(parent.is_symlink() for parent in target.parents if parent != asset.parent):
        raise ValueError(f"Symlinked runtime member: {member!r}")
    return target


def closure_hashes(asset: Path, manifest: dict) -> dict[str, str]:
    files = manifest.get("files", [])
    if not files or len(files) != len(set(files)) or manifest.get("entry") not in files:
        raise ValueError("Runtime files must be unique and include the entry")
    return {member: sha256(safe_member(asset, member)) for member in files}


def verify_inputs_unchanged(paths: dict[Path, str]) -> bool:
    return all(path.is_file() and sha256(path) == before for path, before in paths.items())


def assess(returncode: int, child: dict, unchanged: bool) -> dict:
    checks = child.get("checks", {})
    # jsonlite serializes an empty R list as []; failed calls still need a receipt.
    if not isinstance(checks, dict):
        checks = {}
    complete = (returncode == 0 and child.get("state") == "executed"
                and checks.get("actual_invocation") is True
                and checks.get("input_object_unchanged") is True
                and checks.get("output_assertions") is True
                and unchanged)
    return {"execution_state": "executed" if complete else "not_run",
            "algorithm_verification_state": "not_run",
            "algorithm_verification_reason": "No new independent original-versus-wrapper comparison has been performed by this replay.",
            "checks": {**checks, "source_and_input_files_unchanged": unchanged}}


def run(args):
    vault, dev = args.vault.resolve(), args.dev.resolve()
    run_root = args.run_root.resolve()
    # Never write execution products into either repository, including this record.
    for repository in (vault, dev):
        if run_root == repository or repository in run_root.parents:
            raise ValueError("--run-root must be outside both repositories")
    if not run_root.is_dir():
        raise ValueError("--run-root must be an existing external directory")
    if not args.environment_restored:
        raise ValueError("Use --environment-restored only after dependency installation has completed")
    fixture = args.fixture.resolve()
    if not fixture.is_file() or sha256(fixture) != PANCREAS_SHA256:
        raise ValueError("Fixture must match the pinned public pancreas_sub.rda SHA256")
    document = json.loads(args.mapping.read_text(encoding="utf-8"))
    row = next((row for row in document["implementations"] if row["method"] == args.method and row["implementation"] == args.implementation), None)
    if not row or not row.get("driver"):
        raise ValueError("No reviewed public-data driver is available for this branch; inspect replay-map.json blockers")
    asset = vault / "知识库/methods" / args.method
    runtime_path = asset / "runtime.json"
    runtime = json.loads(runtime_path.read_text(encoding="utf-8"))
    manifest = next(branch for branch in runtime["implementations"] if branch["id"] == args.implementation)
    if manifest != row["runtime"]:
        raise ValueError("Runtime changed since discovery; regenerate and review the mapping")
    if manifest.get("runtime_mode") != "standalone" or manifest.get("language") != "R":
        raise ValueError("Only declared standalone R closures are supported by this driver")
    if f"{manifest.get('entry')}:{manifest.get('entry_function')}" != row["entrypoint"]:
        raise ValueError("Runtime entry and frontmatter entrypoint do not agree")
    driver = row["driver"]
    if driver["kind"] == "historical_portable":
        if PORTABLE_CASES.get((args.method, args.implementation)) != driver["case"]:
            raise ValueError("Historical portable case is not allowlisted")
    elif driver["kind"] == "recorded_plot":
        if tokens(driver["case"].get("args", {})) != {"@pancreas_sub"}:
            raise ValueError("Plot driver accepts only the pinned public pancreas token; no eval or synthetic objects")
        current_receipt = json.loads((asset / row["current_verification_pointer"]).read_text(encoding="utf-8"))
        if current_receipt.get("case") != driver["case"]:
            raise ValueError("Plot parameters no longer match the current recorded case")
    elif driver["kind"] == "recorded_velocity":
        if (args.method, args.implementation) != ("rna-velocity", "scp-scvelo"):
            raise ValueError("Recorded velocity driver belongs only to scp-scvelo")
        if not args.reticulate_python or not args.reticulate_python.is_file():
            raise ValueError("RNA velocity requires --reticulate-python pointing to the prepared compatible interpreter")
    else:
        raise ValueError("Unknown driver kind")
    sources = closure_hashes(asset, manifest)
    originals = {safe_member(asset, member): checksum for member, checksum in sources.items()}
    originals[fixture] = sha256(fixture)
    originals[runtime_path] = sha256(runtime_path)
    run_dir = Path(tempfile.mkdtemp(prefix=f"{args.method}-{args.implementation}-", dir=run_root))
    module_dir = run_dir / "module"
    for member in sources:
        destination = module_dir / member
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(safe_member(asset, member), destination)
        if sha256(destination) != sources[member]:
            raise RuntimeError(f"Copied file changed: {member}")
        originals[destination] = sources[member]
    copied_fixture = run_dir / fixture.name
    shutil.copy2(fixture, copied_fixture)
    originals[copied_fixture] = originals[fixture]
    copied_runtime = module_dir / "runtime.json"
    shutil.copy2(runtime_path, copied_runtime)
    originals[copied_runtime] = originals[runtime_path]
    support_dir = Path(__file__).resolve().parent
    copied_driver = run_dir / "driver.R"
    shutil.copy2(support_dir / "driver.R", copied_driver)
    if driver["kind"] == "historical_portable":
        historical = vault / "维护记录/2026-10-23-最小依赖独立模块/scripts/portable_run.R"
        if sha256(historical) != driver["source_sha256"]:
            raise ValueError("Historical portable driver changed since discovery")
        shutil.copy2(historical, run_dir / "historical_portable_run.R")
        originals[historical] = sha256(historical)
    configuration = {"method": args.method, "implementation": args.implementation,
                     "module_dir": str(module_dir), "entry": manifest["entry"],
                     "entry_function": manifest.get("entry_function"), "driver": driver,
                     "fixture": str(copied_fixture), "required_packages": manifest.get("required_packages", {}),
                     "result_path": str(run_dir / "result.rds"), "child_path": str(run_dir / "child.json")}
    config_file = run_dir / "case.json"
    config_file.write_text(json.dumps(configuration, ensure_ascii=False, indent=2), encoding="utf-8")
    argv = [str(args.rscript.resolve()), "--vanilla", str(copied_driver), str(config_file)]
    invocation_argv = argv
    if driver["kind"] == "historical_portable":
        invocation_argv = [str(args.rscript.resolve()), "--vanilla", str(run_dir / "historical_portable_run.R"),
                           driver["case"], str(module_dir / "code"), str(copied_fixture), str(run_dir / "result.rds")]
    environment = os.environ.copy()
    environment.update(R_LIBS_USER=str(args.r_libs.resolve()), R_LIBS_SITE="", TEMP=str(run_dir), TMP=str(run_dir),
                       RETICULATE_AUTOCONFIGURE="FALSE", RETICULATE_USE_MANAGED_VENV="no",
                       SCP_TEST_CELLS="0", SCP_TEST_RENAME="0", OMP_NUM_THREADS="1", OPENBLAS_NUM_THREADS="1")
    if os.name == "nt":
        environment.update(LC_ALL="English_United States.utf8", LANG="English_United States.utf8")
    if args.reticulate_python:
        environment["RETICULATE_PYTHON"] = str(args.reticulate_python.resolve())
    environment["MPLBACKEND"] = "Agg"
    environment.pop("R_PROFILE_USER", None)
    environment.pop("R_ENVIRON_USER", None)
    started = datetime.now(timezone.utc).isoformat()
    # Keep complete machine-local logs external; only sanitized evidence belongs in Git.
    with (run_dir / "stdout.log").open("wb") as stdout, (run_dir / "stderr.log").open("wb") as stderr:
        try:
            process = subprocess.run(invocation_argv, cwd=run_dir, env=environment, stdout=stdout, stderr=stderr, timeout=args.timeout, check=False)
            returncode, error = process.returncode, None
            if returncode == 0 and invocation_argv != argv:
                process = subprocess.run(argv, cwd=run_dir, env=environment, stdout=stdout, stderr=stderr, timeout=args.timeout, check=False)
                returncode = process.returncode
        except subprocess.TimeoutExpired:
            returncode, error = -1, "Child process exceeded the configured timeout"
    child = json.loads((run_dir / "child.json").read_text(encoding="utf-8")) if (run_dir / "child.json").is_file() else {}
    assessment = assess(returncode, child, verify_inputs_unchanged(originals))
    evidence = {"schema_version": 1, "kind": "method-execution-audit", "method": args.method,
                "implementation": args.implementation, **assessment, "returncode": returncode,
                "error": error or child.get("error"), "started_at": started,
                "executed_at": datetime.now(timezone.utc).isoformat(),
                "argv": invocation_argv, "validation_argv": argv, "case": driver, "source_sha256": sources,
                "manifest_sha256": originals[runtime_path], "fixture_sha256": PANCREAS_SHA256,
                "copied_driver_sha256": sha256(copied_driver), "environment": child.get("environment", {}),
                "backend_closure_limit": row["blockers"] if driver["kind"] == "recorded_velocity" else [],
                "outputs": {str(path.relative_to(run_dir)): sha256(path) for path in run_dir.rglob("*") if path.is_file() and path not in {config_file, copied_fixture, copied_runtime, copied_driver, run_dir / "historical_portable_run.R"} and module_dir not in path.parents},
                "scope": ("Actual public RNA velocity case through copied R files; current installed SCP Python backend is an undeclared external dependency, so no standalone portability or algorithm equivalence claim."
                          if driver["kind"] == "recorded_velocity" else
                          "Actual historical public-data case in copied runtime closure; no new algorithm equivalence or scientific validity claim.")}
    receipt = run_dir / "execution-audit.json"
    receipt.write_text(json.dumps(evidence, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"execution_state": evidence["execution_state"], "algorithm_verification_state": "not_run", "receipt": str(receipt)}, ensure_ascii=False))
    return 0 if evidence["execution_state"] == "executed" else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--vault", type=Path, required=True)
    parser.add_argument("--dev", type=Path, required=True)
    parser.add_argument("--mapping", type=Path, default=Path(__file__).with_name("replay-map.json"))
    parser.add_argument("--method", required=True)
    parser.add_argument("--implementation", required=True)
    parser.add_argument("--fixture", type=Path, required=True)
    parser.add_argument("--run-root", type=Path, required=True)
    parser.add_argument("--rscript", type=Path, required=True)
    parser.add_argument("--r-libs", type=Path, required=True)
    parser.add_argument("--reticulate-python", type=Path)
    parser.add_argument("--timeout", type=int, default=1800)
    parser.add_argument("--environment-restored", action="store_true")
    args = parser.parse_args()
    for path in (args.rscript, args.r_libs):
        if not path.exists():
            parser.error(f"Required runtime path missing: {path}")
    return run(args)


if __name__ == "__main__":
    raise SystemExit(main())
