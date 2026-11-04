"""Compare pinned installed SCP originals and isolated wrappers without patching either."""
import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from run_batch import ENV_ROOT, MAPPING, OUTPUT, SUPPORT, VAULT, digest, write_json

sys.path.insert(0, str(SUPPORT))
from replay import assess, closure_hashes, safe_member, verify_inputs_unchanged


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8")) if path.is_file() else {}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-identity", type=Path, required=True)
    args = parser.parse_args()
    identity = read_json(args.source_identity)
    if identity.get("passed") is not True:
        raise ValueError("Function source identity did not pass")
    library = ENV_ROOT / "R-lib-4.5-3.21"
    if list(library.glob("00LOCK*")):
        raise RuntimeError("Shared dependency installation is still active")
    batch = Path(tempfile.mkdtemp(prefix="original-wrapper-", dir=ENV_ROOT / "method-runs"))
    evidence_root = OUTPUT / batch.name
    evidence_root.mkdir()
    write_json(evidence_root / "source-identity.json", identity)
    shutil.copy2(args.source_identity, batch / "source-identity.json")
    mapping = read_json(MAPPING)
    fixture = ENV_ROOT / "public-data/pancreas_sub.rda"
    pinned = "d95f56fc231378ed14e55fafdebfccb6a6bb464a1a9d988f83e7101d92649744"
    if digest(fixture) != pinned:
        raise ValueError("Fixture identity mismatch")
    summary = {"source_identity_passed": True, "source_identity_sha256": digest(args.source_identity),
               "algorithm_verification_state": "not_run", "formal_receipts_modified": False, "cases": []}
    for method, implementation in (("doublet-detection", "scp-rundoublet"), ("cell-type-annotation", "scp-singler")):
        row = next(row for row in mapping["implementations"]
                   if (row["method"], row["implementation"]) == (method, implementation))
        asset = VAULT / "知识库/methods" / method
        runtime_path = asset / "runtime.json"
        manifest = next(branch for branch in read_json(runtime_path)["implementations"] if branch["id"] == implementation)
        if manifest != row["runtime"]:
            raise ValueError("Runtime differs from reviewed mapping")
        hashes = closure_hashes(asset, manifest)
        case = {"method": method, "implementation": implementation, "runs": [],
                "comparison_state": "not_run", "algorithm_verification_state": "not_run"}
        for mode in ("original", "wrapper"):
            print(f"START {method}/{mode}", flush=True)
            run = batch / f"{method}-{mode}"
            run.mkdir()
            originals = {safe_member(asset, member): checksum for member, checksum in hashes.items()}
            originals.update({fixture: pinned, runtime_path: digest(runtime_path)})
            copied_fixture = run / fixture.name
            shutil.copy2(fixture, copied_fixture)
            originals[copied_fixture] = pinned
            config = {"method": method, "mode": mode, "fixture": str(copied_fixture),
                      "result_path": str(run / "result.rds"), "keys_path": str(run / "key-arrays.rds"),
                      "input_path": str(run / "input.rds"), "child_path": str(run / "child.json")}
            if mode == "wrapper":
                module = run / "module"
                for member, checksum in hashes.items():
                    target = module / member
                    target.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(safe_member(asset, member), target)
                    originals[target] = checksum
                shutil.copy2(runtime_path, module / "runtime.json")
                originals[module / "runtime.json"] = originals[runtime_path]
                config["module_dir"] = str(module)
            driver = run / "comparison_case.R"
            shutil.copy2(OUTPUT / driver.name, driver)
            originals[driver] = digest(OUTPUT / driver.name)
            config_path = run / "case.json"
            config_path.write_text(json.dumps(config, ensure_ascii=False, indent=2), encoding="utf-8")
            argv = [str(ENV_ROOT / "R-4.5.0/bin/x64/Rscript.exe"), "--vanilla", str(driver), str(config_path)]
            environment = os.environ.copy()
            environment.update(R_LIBS_USER=str(library), R_LIBS_SITE="", TEMP=str(run), TMP=str(run),
                               RETICULATE_AUTOCONFIGURE="FALSE", RETICULATE_USE_MANAGED_VENV="no",
                               OMP_NUM_THREADS="1", OPENBLAS_NUM_THREADS="1", SCP_TEST_CELLS="0", SCP_TEST_RENAME="0",
                               LC_ALL="English_United States.utf8", LANG="English_United States.utf8")
            environment.pop("R_PROFILE_USER", None)
            environment.pop("R_ENVIRON_USER", None)
            started = datetime.now(timezone.utc).isoformat()
            with (run / "stdout.log").open("wb") as stdout, (run / "stderr.log").open("wb") as stderr:
                try:
                    process = subprocess.run(argv, cwd=run, env=environment, stdout=stdout, stderr=stderr,
                                             timeout=300, check=False)
                    returncode, error = process.returncode, None
                except subprocess.TimeoutExpired:
                    returncode, error = -1, "Child exceeded 300 seconds"
            child = read_json(run / "child.json")
            audit = {"kind": "original-wrapper-case-execution", "method": method, "implementation": implementation,
                     "mode": mode, **assess(returncode, child, verify_inputs_unchanged(originals)),
                     "returncode": returncode, "error": error or child.get("error"), "argv": argv,
                     "started_at": started, "executed_at": datetime.now(timezone.utc).isoformat(),
                     "source_sha256": hashes, "manifest_sha256": originals[runtime_path], "fixture_sha256": pinned,
                     "driver_sha256": originals[driver], "child": child,
                     "outputs": {path.name: digest(path) for path in run.iterdir() if path.is_file()
                                 and path.name in {"result.rds", "key-arrays.rds", "input.rds", "child.json", "stdout.log", "stderr.log"}}}
            (run / "execution-audit.json").write_text(json.dumps(audit, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            evidence = {"execution_audit": audit, "log_tails": {name: "\n".join((run / name).read_text(encoding="utf-8", errors="replace").splitlines()[-80:])
                                                                  for name in ("stdout.log", "stderr.log")}}
            write_json(evidence_root / f"{method}-{mode}.json", evidence)
            case["runs"].append({"mode": mode, "execution_state": audit["execution_state"], "error": audit["error"],
                                 "input_serialized_sha256": child.get("input_serialized_sha256"), "external_run_directory": str(run)})
            write_json(evidence_root / "summary.json", {**summary, "in_progress": case})
            print(f"DONE {method}/{mode} {audit['execution_state']} error={audit['error']}", flush=True)
        case["same_input_serialized_sha256"] = (case["runs"][0]["input_serialized_sha256"] is not None and
                                                case["runs"][0]["input_serialized_sha256"] == case["runs"][1]["input_serialized_sha256"])
        if all(item["execution_state"] == "executed" for item in case["runs"]) and case["same_input_serialized_sha256"]:
            compare_argv = [str(ENV_ROOT / "R-4.5.0/bin/x64/Rscript.exe"), "--vanilla", str(OUTPUT / "compare_key_arrays.R"),
                            str(batch / f"{method}-original/key-arrays.rds"), str(batch / f"{method}-wrapper/key-arrays.rds"),
                            str(batch / f"{method}-comparison.json")]
            comparison = subprocess.run(compare_argv, cwd=batch, env=environment, capture_output=True, text=True, encoding="utf-8", timeout=60)
            detail = read_json(batch / f"{method}-comparison.json")
            case["comparison_state"] = "matched" if detail.get("matched") is True and comparison.returncode == 0 else "different"
            case["comparison"] = detail
        else:
            case["comparison_reason"] = "Both original and wrapper must complete on the same input before comparing actual output arrays."
        summary["cases"].append(case)
        write_json(evidence_root / "summary.json", summary)
    print(f"EVIDENCE {evidence_root}", flush=True)


if __name__ == "__main__":
    main()
