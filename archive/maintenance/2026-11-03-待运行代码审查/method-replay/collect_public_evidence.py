"""Verify and archive sanitized evidence from an actual external public replay."""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import shutil
import sys

from public_python_replay import sha256, write_json


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--run-dir", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--vault", type=Path, required=True)
    args = parser.parse_args()
    root, output, vault = args.run_dir.resolve(), args.out.resolve(), args.vault.resolve()
    if output.exists():
        raise ValueError("Evidence destination already exists; preserve previous audit bytes")
    summary = json.loads((root / "summary.json").read_text(encoding="utf-8"))
    if summary.get("state") != "passed" or len(summary.get("results", [])) != 6:
        raise ValueError("Expected six actually completed public software branches")
    replacements = {str(root).replace("\\", "/"): "<RUN_ROOT>", str(vault).replace("\\", "/"): "<VAULT>",
                    str(Path(sys.executable)).replace("\\", "/"): "<ML_PYTHON>"}

    def sanitized(value):
        if isinstance(value, str):
            value = value.replace("\\", "/")
            for old, new in replacements.items():
                value = value.replace(old, new)
            return value
        if isinstance(value, dict):
            return {sanitized(key): sanitized(item) for key, item in value.items()}
        if isinstance(value, list):
            return [sanitized(item) for item in value]
        return value

    checks = []
    for branch in summary["results"]:
        directory = Path(branch["audit"]).parent
        audit = json.loads((directory / "audit.json").read_text(encoding="utf-8"))
        comparison = json.loads((directory / "comparison.json").read_text(encoding="utf-8"))
        asset = vault / "知识库/methods" / branch["method"]
        identities = {"same_frozen_input_bytes_as_reference": sha256(directory / "inputs.npz") == summary["input_sha256"]["inputs.npz"],
                      "source_code_tree_unchanged_since_run": all(sha256(asset / member) == digest for member, digest in audit["files"].items()),
                      "copied_closure_identical_to_source": all(sha256(directory / member) == digest for member, digest in audit["runtime_closure_files"].items()),
                      "all_recorded_outputs_match": all(sha256(directory / member) == digest for member, digest in audit["output_sha256"].items()),
                      "comparison_file_matches_run_summary": sha256(directory / "comparison.json") == branch["comparison_sha256"]}
        if branch["implementation"] != "py-roc-render":
            identities["same_fitted_model_bytes_as_reference"] = sha256(directory / "model.joblib") == summary["input_sha256"]["model.joblib"]
        if not all(identities.values()) or not all(comparison["checks"].values()):
            raise AssertionError(f"Post-run identity verification failed: {branch['implementation']}")
        checks.append({"implementation": branch["implementation"], "checks": identities,
                       "raw_external_audit_sha256": sha256(directory / "audit.json"),
                       "raw_external_comparison_sha256": sha256(directory / "comparison.json")})
    output.mkdir(parents=True)
    for branch in summary["results"]:
        directory = Path(branch["audit"]).parent
        destination = output / branch["implementation"]
        destination.mkdir()
        for name in ("audit.json", "comparison.json", "result.json"):
            write_json(destination / name, sanitized(json.loads((directory / name).read_text(encoding="utf-8"))))
        if branch["implementation"] == "py-roc-render":
            for name in ("plot.png", "plot.pdf"):
                shutil.copy2(directory / name, destination / name)
        log = (directory / "stderr.log").read_text(encoding="utf-8")
        if log:
            (destination / "stderr.txt").write_text(sanitized(log), encoding="utf-8")
    for name in ("summary.json", "source-comparison.json"):
        write_json(output / name, sanitized(json.loads((root / name).read_text(encoding="utf-8"))))
    write_json(output / "post-run-identity-checks.json", {"checked_at": datetime.now(timezone.utc).isoformat(),
               "scope": "Additional read-only identity checks after actual six-branch execution; no source/receipt promotion",
               "executed_driver_sha256": sha256(root / "public_python_replay.py"), "branches": checks})
    print(json.dumps({"branches": 6, "state": "passed", "evidence": str(output)}, ensure_ascii=False))


if __name__ == "__main__":
    main()
