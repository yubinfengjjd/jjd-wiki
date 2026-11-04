"""Check the missing-loadings guard against one frozen, actual public input."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

from run_batch import ENV_ROOT, OUTPUT, VAULT, digest, write_json


def main():
    previous = ENV_ROOT / "method-runs/public-r-20261104-ig3shgyk/reference-mapping-scp-runseuratmap-2jzh7jkz"
    recorded_input = previous / "result-input.rds"
    fixture = ENV_ROOT / "public-data/pancreas_sub.rda"
    asset = VAULT / "知识库/methods/reference-mapping"
    originals = {path: digest(path) for path in (fixture, recorded_input, asset / "code/analysis.R",
                                                 asset / "code/reference_native.R", asset / "runtime.json")}
    batch = Path(tempfile.mkdtemp(prefix="reference-guard-identity-", dir=ENV_ROOT / "method-runs"))
    evidence_root = OUTPUT / batch.name
    evidence_root.mkdir()
    records = []
    for phase in ("red", "green"):
        run = batch / phase
        module = run / "module/code"
        module.mkdir(parents=True)
        source = previous / "module/code" if phase == "red" else asset / "code"
        for name in ("analysis.R", "reference_native.R"):
            shutil.copy2(source / name, module / name)
        for source_file, name in ((fixture, fixture.name), (recorded_input, "recorded-input.rds"),
                                  (OUTPUT / "reference_loadings_guard_test.R", "driver.R")):
            shutil.copy2(source_file, run / name)
        copy_hashes = {path: digest(path) for path in run.rglob("*") if path.is_file()}
        argv = [str(ENV_ROOT / "R-4.5.0/bin/x64/Rscript.exe"), "--vanilla", str(run / "driver.R"),
                str(run / fixture.name), str(module.parent), str(run), str(run / "recorded-input.rds")]
        environment = os.environ.copy()
        environment.update(R_LIBS_USER=str(ENV_ROOT / "R-lib-4.5-3.21"), R_LIBS_SITE="", TEMP=str(run), TMP=str(run),
                           LC_ALL="English_United States.utf8", LANG="English_United States.utf8",
                           OMP_NUM_THREADS="1", OPENBLAS_NUM_THREADS="1")
        with (run / "stdout.log").open("wb") as stdout, (run / "stderr.log").open("wb") as stderr:
            process = subprocess.run(argv, cwd=run, env=environment, stdout=stdout, stderr=stderr, timeout=300)
        report = json.loads((run / "guard-test.json").read_text(encoding="utf-8"))
        unchanged = all(digest(path) == value for path, value in {**originals, **copy_hashes}.items())
        if not unchanged:
            raise ValueError("Original or copied input/source changed")
        record = {"phase": phase, "child_returncode": process.returncode, "argv": argv, "report": report,
                  "original_and_copy_files_unchanged": unchanged,
                  "source_sha256": {name: digest(module / name) for name in ("analysis.R", "reference_native.R")},
                  "fixture_sha256": originals[fixture], "recorded_input_file_sha256": originals[recorded_input],
                  "driver_sha256": digest(run / "driver.R"), "log_tails": {name: "\n".join((run / name).read_text(encoding="utf-8", errors="replace").splitlines()[-50:])
                                                                             for name in ("stdout.log", "stderr.log")}}
        write_json(evidence_root / f"{phase}.json", record)
        records.append(record)
    before, after = records
    checks = {"red_failed_for_original_error": before["child_returncode"] == 1 and
               before["report"]["actual_error"] == "Argument 'dim.' must be an integer vector of length two",
              "green_passed_with_precise_missing_loadings_error": after["child_returncode"] == 0 and after["report"]["passed"] is True,
              "same_serialized_input": before["report"]["input_serialized_sha256"] == after["report"]["input_serialized_sha256"],
              "input_object_unchanged_in_both": all(item["report"]["input_object_unchanged"] for item in records),
              "native_source_unchanged": before["source_sha256"]["reference_native.R"] == after["source_sha256"]["reference_native.R"]}
    summary = {"kind": "reference-input-guard-regression", "passed": all(checks.values()), "checks": checks,
               "execution_state": "not_run", "algorithm_verification_state": "not_run", "refit_performed": False,
               "root_cause": "Pinned public PCA contains cell embeddings but a 0x0 feature-loadings matrix. Seurat pcaproject selects no features and rowMeans2 receives numeric(0).",
               "formal_wrapper_sha256": originals[asset / "code/analysis.R"],
               "formal_runtime_sha256": originals[asset / "runtime.json"],
               "scope": "Precise input validation only. No new reference representation, PCA fit or scientific parameter was chosen."}
    write_json(evidence_root / "summary.json", summary)
    print(json.dumps({"passed": summary["passed"], "checks": checks, "evidence": str(evidence_root)}, ensure_ascii=False))
    if not summary["passed"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
