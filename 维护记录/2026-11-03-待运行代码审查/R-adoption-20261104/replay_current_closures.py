"""Re-execute approved public R cases after finalizing runtime evidence pointers."""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def write_json(path, value):
    Path(path).write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--vault", required=True, type=Path)
    parser.add_argument("--dev", required=True, type=Path)
    parser.add_argument("--env-root", required=True, type=Path)
    args = parser.parse_args()
    vault, dev, env_root = (p.resolve() for p in (args.vault, args.dev, args.env_root))
    for repository in (vault, dev):
        if env_root == repository or repository in env_root.parents:
            raise ValueError("Execution environment must be outside both repositories")
    library = env_root / "R-lib-4.5-3.21"
    if list(library.glob("00LOCK*")):
        raise RuntimeError("Shared R library installation lock present")
    sys.path.insert(0, str(dev / "staged/research-wiki"))
    from rwiki.runtime_contract import closure_hash

    support = vault / "维护记录/2026-11-03-待运行代码审查/method-r-execution"
    batch = Path(tempfile.mkdtemp(prefix="r-adoption-20261104-", dir=env_root / "method-runs"))
    shutil.copy2(Path(__file__), batch / Path(__file__).name)
    fixture = env_root / "public-data/pancreas_sub.rda"
    if digest(fixture) != "d95f56fc231378ed14e55fafdebfccb6a6bb464a1a9d988f83e7101d92649744":
        raise ValueError("Pinned public fixture hash differs")
    frozen_query_reference = env_root / "method-runs/original-wrapper-scbxyxye/cell-type-annotation-wrapper/input.rds"
    frozen_doublet_input = env_root / "method-runs/original-wrapper-scbxyxye/doublet-detection-wrapper/input.rds"
    results = []
    for method, branch in (("cell-type-annotation", "scp-singler"), ("doublet-detection", "scp-rundoublet")):
        asset = vault / "知识库/methods" / method
        run = batch / method
        run.mkdir()
        module = run / "module"
        manifest_path = asset / "runtime.json"
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        runtime = next(i for i in manifest["implementations"] if i["id"] == branch)
        source_hashes = {name: digest(asset / name) for name in runtime["files"]}
        manifest_hash = digest(manifest_path)
        for member in runtime["files"]:
            target = module / member
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(asset / member, target)
        shutil.copy2(manifest_path, module / "runtime.json")
        shutil.copy2(fixture, run / fixture.name)
        copied_input = run / "input.rds"
        shutil.copy2(frozen_query_reference if method == "cell-type-annotation" else frozen_doublet_input, copied_input)
        environment = os.environ.copy()
        environment.update(R_LIBS_USER=str(library), R_LIBS_SITE="", TEMP=str(run), TMP=str(run),
                           OMP_NUM_THREADS="1", OPENBLAS_NUM_THREADS="1", SCP_TEST_CELLS="0", SCP_TEST_RENAME="0",
                           RETICULATE_AUTOCONFIGURE="FALSE", RETICULATE_USE_MANAGED_VENV="no",
                           LC_ALL="English_United States.utf8", LANG="English_United States.utf8")
        environment.pop("R_PROFILE_USER", None)
        environment.pop("R_ENVIRON_USER", None)
        rscript = env_root / "R-4.5.0/bin/x64/Rscript.exe"
        if method == "cell-type-annotation":
            driver = run / "singler_alignment_check.R"
            shutil.copy2(support / driver.name, driver)
            commands = [[str(rscript), "--vanilla", str(driver), str(copied_input), str(module), str(run)]]
        else:
            driver = run / "doublet_seed11_corrected.R"
            shutil.copy2(support / driver.name, driver)
            comparison_driver = run / "doublet_direct_check.R"
            shutil.copy2(support / comparison_driver.name, comparison_driver)
            case = {"fixture": str(run / fixture.name), "module_dir": str(module),
                    "result_path": str(run / "result.rds"), "child_path": str(run / "child.json")}
            write_json(run / "case.json", case)
            commands = [[str(rscript), "--vanilla", str(driver), str(run / "case.json")],
                        [str(rscript), "--vanilla", str(comparison_driver), str(copied_input),
                         str(run / "result.rds"), str(run / "comparison.json")]]
        protected = {fixture: digest(fixture), copied_input: digest(copied_input), run / fixture.name: digest(fixture),
                     manifest_path: manifest_hash, module / "runtime.json": manifest_hash}
        protected.update({asset / name: value for name, value in source_hashes.items()})
        protected.update({module / name: value for name, value in source_hashes.items()})
        protected.update({Path(cmd[2]): digest(Path(cmd[2])) for cmd in commands})
        started = datetime.now(timezone.utc).isoformat()
        statuses = []
        for number, command in enumerate(commands):
            with (run / f"{number}-stdout.log").open("wb") as stdout, (run / f"{number}-stderr.log").open("wb") as stderr:
                result = subprocess.run(command, cwd=run, env=environment, stdout=stdout, stderr=stderr,
                                        timeout=300, check=False)
            statuses.append(result.returncode)
            if result.returncode:
                break
        child_name = "result.json" if method == "cell-type-annotation" else "child.json"
        child = json.loads((run / child_name).read_text(encoding="utf-8")) if (run / child_name).is_file() else {}
        comparison = child if method == "cell-type-annotation" else (
            json.loads((run / "comparison.json").read_text(encoding="utf-8")) if (run / "comparison.json").is_file() else {})
        preserved = all(digest(path) == value for path, value in protected.items())
        passed = (len(statuses) == len(commands) and all(code == 0 for code in statuses)
                  and child.get("state") == "executed" and preserved
                  and bool(comparison.get("checks")) and all(comparison["checks"].values()))
        audit = {"method": method, "implementation": branch, "state": "passed" if passed else "not_run",
                 "started_at": started, "executed_at": datetime.now(timezone.utc).isoformat(),
                 "argv": commands, "returncodes": statuses, "closure_hash": closure_hash(asset, runtime),
                 "manifest_sha256": manifest_hash, "files": source_hashes,
                 "input_sha256": {"pancreas_sub.rda": digest(fixture), "input.rds": digest(copied_input)},
                 "source_input_driver_files_unchanged": preserved, "child": child, "comparison": comparison,
                 "outputs": {p.name: digest(p) for p in run.iterdir() if p.is_file() and p.name in
                             {"result.json", "child.json", "result.rds", "direct-SingleR.rds", "comparison.json"}},
                 "driver_sha256": {Path(cmd[2]).name: digest(Path(cmd[2])) for cmd in commands},
                 "scope": "Direct dependency core equality on the approved public case; full unmodified SCP comparison did not pass."}
        write_json(run / "execution-audit.json", audit)
        results.append({"method": method, "state": audit["state"], "audit": str(run / "execution-audit.json")})
        write_json(batch / "summary.json", {"results": results})
        print(json.dumps(results[-1]), flush=True)
        if not passed:
            return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
