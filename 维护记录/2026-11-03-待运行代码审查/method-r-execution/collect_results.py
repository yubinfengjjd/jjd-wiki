"""Collect existing replay outputs, including an early orchestration failure."""
import argparse
import json
from pathlib import Path

from run_batch import ENV_ROOT, MAPPING, OUTPUT, VAULT, digest, sanitize, write_json


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8")) if path.is_file() else {}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("batch", type=Path)
    args = parser.parse_args()
    batch_root = args.batch.resolve()
    if batch_root.parent != (ENV_ROOT / "method-runs").resolve():
        raise ValueError("Expected a direct child of the dedicated method-runs directory")
    evidence_root = OUTPUT / batch_root.name
    summary = read_json(evidence_root / "summary.json")
    if len(summary["results"]) != 20:
        raise ValueError("Collect only after all twenty first-pass calls have completed")
    mapping = read_json(MAPPING)
    rows = {(row["method"], row["implementation"]): row for row in mapping["implementations"]}
    results = []
    for index, original in enumerate(summary["results"], 1):
        item = dict(original)
        key = (item["method"], item["implementation"])
        matches = [path for path in batch_root.glob(f"{key[0]}-{key[1]}-*") if path.is_dir()]
        if len(matches) != 1:
            raise ValueError(f"Expected one isolated directory for {key}, found {len(matches)}")
        run = matches[0]
        row = rows[key]
        audit = read_json(run / "execution-audit.json")
        child = read_json(run / "child.json")
        historical = read_json(run / "result.json")
        source_hashes = {}
        source_preserved = {}
        asset = VAULT / "知识库/methods" / key[0]
        for member in row["runtime"]["files"]:
            source_hashes[member] = digest(run / "module" / member)
            source_preserved[member] = digest(asset / member) == source_hashes[member]
        checks = {"source_closure_matches_isolated_copy": all(source_preserved.values()),
                  "runtime_manifest_matches_isolated_copy": digest(asset / "runtime.json") == digest(run / "module/runtime.json"),
                  "recorded_runtime_matches_current_mapping": next(branch for branch in
                      read_json(run / "module/runtime.json")["implementations"] if branch["id"] == key[1]) == row["runtime"],
                  "fixture_matches_pinned_sha256": digest(run / "pancreas_sub.rda") == mapping["public_fixture"]["sha256"]
                  if "public_fixture" in mapping else digest(run / "pancreas_sub.rda") == "d95f56fc231378ed14e55fafdebfccb6a6bb464a1a9d988f83e7101d92649744"}
        if not all(checks.values()):
            raise ValueError(f"Preservation check failed for {key}: {checks}")
        item["collection_checks"] = checks
        if not audit:
            item["orchestration_error"] = item.get("error")
            item["error"] = historical.get("error") or child.get("error") or item.get("error")
            item["execution_state"] = "not_run"
            recovered = {"kind": "failed-method-execution-evidence", "method": key[0], "implementation": key[1],
                         "execution_state": "not_run", "algorithm_verification_state": "not_run",
                         "error": item["error"], "orchestration_error": item["orchestration_error"],
                         "source_sha256": source_hashes, "preservation_checks": checks,
                         "child": child, "historical_result": historical, "log_tails": {},
                         "scope": "Collected from existing child and result sidecars after the original replay orchestrator failed; no method was retried."}
            for name in ("stdout.log", "stderr.log"):
                recovered["log_tails"][name] = "\n".join((run / name).read_text(encoding="utf-8", errors="replace").splitlines()[-60:])
            write_json(evidence_root / f"{index:02d}-{key[1]}-recovered.json", recovered)
        elif audit["execution_state"] != item["execution_state"]:
            raise ValueError(f"Execution status mismatch for {key}")
        if audit:
            if audit["source_sha256"] != source_hashes:
                raise ValueError(f"Original audit source hashes differ for {key}")
            for member, expected_hash in audit["outputs"].items():
                if digest(run / member) != expected_hash:
                    raise ValueError(f"Output changed after original audit for {key}: {member}")
        item["algorithm_verification_state"] = "not_run"
        item["external_run_directory"] = str(run)
        results.append(item)
    summary["results"] = results
    summary["mapping_sha256_at_collection"] = digest(MAPPING)
    summary["mapping_changed_during_batch"] = summary["mapping_sha256_at_collection"] != summary["mapping_sha256"]
    summary["counts"] = {"completed": 20, "executed": sum(item["execution_state"] == "executed" for item in results),
                         "not_run": sum(item["execution_state"] != "executed" for item in results),
                         "algorithm_verified": 0}
    summary["evidence_scope"] = "Actual reviewed public-data execution only; no independent original-versus-wrapper comparison. Plot visual review remains pending."
    write_json(evidence_root / "collected-summary.json", summary)
    lines = ["# Public pancreas R execution audit, 2026-11-04", "",
             f"Completed: 20; executed: {summary['counts']['executed']}; not_run: {summary['counts']['not_run']}; algorithm verified: 0.", "",
             "Each case used the recorded parameters, an isolated runtime closure, the pinned public pancreas fixture, and a fresh R process. No packages were installed during this batch. Original source, runtime and fixture copies match after execution. Original receipts and Wiki pages were not modified.", "",
             "These are execution audits only. No independent original-source comparison was performed. Plot visual review remains pending. Existing reference-map cases reuse subsets of the same public fixture and do not establish external generalization.", "",
             "| Method | Implementation | Execution | Seconds | Error |", "|---|---|---|---:|---|"]
    for item in results:
        error = str(item.get("error") or "").replace("|", "/").replace("\n", " ")
        lines.append(f"| {item['method']} | {item['implementation']} | {item['execution_state']} | {item['duration_seconds']} | {sanitize(error)} |")
    lines.extend(["", "Full sanitized receipts, package versions and log tails are in the numbered JSON files. Raw logs, results and exact process arguments remain in the external batch directory recorded in collected-summary.json.", "",
                  "The first SingleR failure exposed the replay orchestrator's assumption that R `checks` is always a JSON object. R emitted an empty array on failure. Its original failure evidence is preserved and separately recovered from child/result sidecars; it was not rerun in this batch.", ""])
    (evidence_root / "README.md").write_text("\n".join(lines), encoding="utf-8")
    print(json.dumps(summary["counts"]))


if __name__ == "__main__":
    main()
