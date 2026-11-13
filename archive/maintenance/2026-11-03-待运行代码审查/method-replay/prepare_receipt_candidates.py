"""Prepare review-only contract-shaped receipts from completed actual evidence."""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import subprocess
import sys

from public_python_replay import sha256, write_json


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--vault", type=Path, required=True)
    parser.add_argument("--dev", type=Path, required=True)
    parser.add_argument("--evidence", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    if args.out.exists():
        raise ValueError("Candidate directory exists; retain previously prepared bytes")
    sys.path.insert(0, str(args.dev / "staged/research-wiki"))
    from rwiki.runtime_contract import closure_hash
    summary = json.loads((args.evidence / "summary.json").read_text(encoding="utf-8"))
    args.out.mkdir(parents=True)
    prepared = []
    for row in summary["results"]:
        branch = row["implementation"]
        audit = json.loads((args.evidence / branch / "audit.json").read_text(encoding="utf-8"))
        comparison = json.loads((args.evidence / branch / "comparison.json").read_text(encoding="utf-8"))
        if audit["state"] != "passed" or not all(comparison["checks"].values()):
            raise AssertionError("Cannot prepare passed candidates without actual passed branch evidence")
        asset = args.vault / "知识库/methods" / row["method"]
        if sha256(asset / "runtime.json") != audit["runtime_manifest_sha256"]:
            raise AssertionError("Runtime changed since actual execution")
        if not all(sha256(asset / member) == digest for member, digest in audit["files"].items()):
            raise AssertionError("Current algorithm code differs from executed bytes")
        manifest = json.loads((asset / "runtime.json").read_text(encoding="utf-8"))
        runtime = next(item for item in manifest["implementations"] if item["id"] == branch)
        checks = [name for name, passed in comparison["checks"].items() if passed]
        checks.extend(["Original reference process and copied-closure production process both exited zero",
                       "Frozen real public input/model bytes agree with the reference phase",
                       "Current source code tree still matches actual execution hashes",
                       "No original-source directory supplied to the isolated production function"])
        stem = branch + "-public-breast-cancer-20261103"
        comparison_name = stem + "-comparison.json"
        scope = audit["scope"] + " Positive class is benign (1); fixed held-out threshold 0.5. Youden is exercised on training probabilities only."
        common = {"schema_version": 1, "kind": "method", "implementation": branch, "state": "passed", "scope": scope,
                  "command": subprocess.list2cmdline(audit["command"]), "argv": audit["command"],
                  "checks": checks, "environment": audit["environment"], "files": audit["files"],
                  "case": audit["case"], "case_id": audit["case_id"], "input_sha256": audit["input_sha256"],
                  "output_sha256": audit["output_sha256"], "executed_at": audit["executed_at"],
                  "comparison": "verification/" + comparison_name,
                  "promotion": "Review-only candidate; not installed in Wiki and not checked through its official page pointer",
                  "path_redaction": "ML_PYTHON and RUN_ROOT are explicit machine-local placeholders; exact original argv retained in external actual audit.json",
                  "review_prepared_at": datetime.now(timezone.utc).isoformat()}
        write_json(args.out / (stem + "-algorithm.json"), common)
        portability = {**common, "scope": "New-process copied declared closure with actual real public inputs and unchanged input/model/code bytes. " + scope,
                       "closure_hash": closure_hash(asset, runtime), "copied_files": list(runtime["files"])}
        write_json(args.out / (stem + "-portability.json"), portability)
        write_json(args.out / comparison_name, comparison)
        prepared.append({"method": row["method"], "implementation": branch,
                         "algorithm": stem + "-algorithm.json", "portability": stem + "-portability.json",
                         "comparison": comparison_name, "closure_hash": portability["closure_hash"],
                         "full_code_files_bound": len(audit["files"]), "closure_files_executed": len(runtime["files"])})
    write_json(args.out / "index.json", {"scope": "Six actual public software cases; primary review required before formal adoption",
               "contract_adjustments": ["Audit kind changed to accepted method kind", "Command serialized as a nonempty Windows argv string", "Check mapping rendered as nonempty string assertions", "Official runtime_contract.closure_hash applied to unchanged current manifest/closure", "All current code files bound, executed closure listed separately"],
               "official_pointer_validation": "not_run; no formal Wiki file was written", "candidates": prepared})
    print(json.dumps({"candidates": len(prepared), "official_pointer_validation": "not_run"}))


if __name__ == "__main__":
    main()
