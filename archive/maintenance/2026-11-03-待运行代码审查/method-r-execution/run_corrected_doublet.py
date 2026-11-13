"""Run the approved scDblFinder argument correction in a new isolated directory."""
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from run_batch import DEV, ENV_ROOT, MAPPING, OUTPUT, SUPPORT, VAULT, digest, write_json

sys.path.insert(0, str(SUPPORT))
from replay import assess, closure_hashes, safe_member, verify_inputs_unchanged


def main():
    library = ENV_ROOT / "R-lib-4.5-3.21"
    if list(library.glob("00LOCK*")):
        raise RuntimeError("Dependency installation lock present; wait for restoration")
    method, implementation = "doublet-detection", "scp-rundoublet"
    asset = VAULT / "知识库/methods" / method
    runtime_path = asset / "runtime.json"
    manifest = next(branch for branch in json.loads(runtime_path.read_text(encoding="utf-8"))["implementations"]
                    if branch["id"] == implementation)
    row = next(row for row in json.loads(MAPPING.read_text(encoding="utf-8"))["implementations"]
               if (row["method"], row["implementation"]) == (method, implementation))
    if manifest != row["runtime"]:
        raise ValueError("Current reviewed runtime differs from mapping")
    fixture = ENV_ROOT / "public-data/pancreas_sub.rda"
    fixture_hash = "d95f56fc231378ed14e55fafdebfccb6a6bb464a1a9d988f83e7101d92649744"
    if digest(fixture) != fixture_hash:
        raise ValueError("Pinned public fixture does not match")
    sources = closure_hashes(asset, manifest)
    originals = {safe_member(asset, member): checksum for member, checksum in sources.items()}
    originals.update({fixture: fixture_hash, runtime_path: digest(runtime_path)})
    run = Path(tempfile.mkdtemp(prefix="doublet-seed11-corrected-", dir=ENV_ROOT / "method-runs"))
    module = run / "module"
    for member, checksum in sources.items():
        destination = module / member
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(safe_member(asset, member), destination)
        originals[destination] = checksum
    copied_fixture = run / fixture.name
    shutil.copy2(fixture, copied_fixture)
    originals[copied_fixture] = fixture_hash
    copied_runtime = module / "runtime.json"
    shutil.copy2(runtime_path, copied_runtime)
    originals[copied_runtime] = originals[runtime_path]
    source_driver = OUTPUT / "doublet_seed11_corrected.R"
    copied_driver = run / source_driver.name
    originals[source_driver] = digest(source_driver)
    shutil.copy2(source_driver, copied_driver)
    originals[copied_driver] = originals[source_driver]
    case = {"case_id": "public-pancreas80-scdblfinder-seed11-no-seed-argument",
            "module_dir": str(module), "fixture": str(copied_fixture),
            "result_path": str(run / "result.rds"), "child_path": str(run / "child.json"),
            "correction": "Remove unsupported forwarded seed argument; set.seed(11) still precedes the call.",
            "cells": 80, "seed_before_call": 11,
            "forwarded_parameters": {"assay": "RNA", "db_method": "scDblFinder", "db_rate": 0.01}}
    config = run / "case.json"
    config.write_text(json.dumps(case, ensure_ascii=False, indent=2), encoding="utf-8")
    argv = [str(ENV_ROOT / "R-4.5.0/bin/x64/Rscript.exe"), "--vanilla", str(copied_driver), str(config)]
    environment = os.environ.copy()
    environment.update(R_LIBS_USER=str(library), R_LIBS_SITE="", TEMP=str(run), TMP=str(run),
                       RETICULATE_AUTOCONFIGURE="FALSE", RETICULATE_USE_MANAGED_VENV="no",
                       SCP_TEST_CELLS="0", SCP_TEST_RENAME="0", OMP_NUM_THREADS="1", OPENBLAS_NUM_THREADS="1",
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
            returncode, error = -1, "Child process exceeded 300 seconds"
    child_path = run / "child.json"
    child = json.loads(child_path.read_text(encoding="utf-8")) if child_path.is_file() else {}
    audit = {"schema_version": 1, "kind": "method-execution-audit", "method": method,
             "implementation": implementation, **assess(returncode, child, verify_inputs_unchanged(originals)),
             "case": case, "returncode": returncode, "error": error or child.get("error"),
             "started_at": started, "executed_at": datetime.now(timezone.utc).isoformat(), "argv": argv,
             "source_sha256": sources, "manifest_sha256": originals[runtime_path], "fixture_sha256": fixture_hash,
             "driver_sha256": originals[source_driver], "environment": child.get("environment", {}),
             "result_details": {key: child.get(key) for key in ("classification_counts", "score_range", "parameters")},
             "scope": "Actual corrected public pancreas invocation; random seed remains 11. No original-source comparison or algorithm-verification claim.",
             "outputs": {path.name: digest(path) for path in run.iterdir()
                         if path.is_file() and path.name in {"result.rds", "child.json", "stdout.log", "stderr.log"}}}
    (run / "execution-audit.json").write_text(json.dumps(audit, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    evidence = {"execution_audit": audit, "log_tails": {}}
    for name in ("stdout.log", "stderr.log"):
        evidence["log_tails"][name] = "\n".join((run / name).read_text(encoding="utf-8", errors="replace").splitlines()[-60:])
    evidence_root = OUTPUT / run.name
    evidence_root.mkdir()
    write_json(evidence_root / "execution-audit.json", evidence)
    print(json.dumps({"execution_state": audit["execution_state"], "error": audit["error"],
                      "receipt": str(evidence_root / "execution-audit.json")}, ensure_ascii=False))
    return 0 if audit["execution_state"] == "executed" else 1


if __name__ == "__main__":
    raise SystemExit(main())
