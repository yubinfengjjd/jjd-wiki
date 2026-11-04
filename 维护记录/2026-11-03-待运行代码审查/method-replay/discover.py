"""Build a read-only replay inventory; historical success is never a new pass."""
from __future__ import annotations

import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import sys

PANCREAS_SHA256 = "d95f56fc231378ed14e55fafdebfccb6a6bb464a1a9d988f83e7101d92649744"
PORTABLE_CASES = {
    ("cell-quality-control", "scp-runcellqc"): "cell-quality-control",
    ("doublet-detection", "scp-rundoublet"): "doublet-detection",
    ("dimensionality-reduction", "scp-dimreduction"): "dimensionality-reduction",
    ("cell-type-annotation", "scp-singler"): "cell-type-annotation",
    ("differential-expression", "scp-detest"): "differential-expression",
    ("gene-set-scoring", "scp-cellscoring"): "gene-set-scoring",
    ("trajectory-inference", "scp-slingshot"): "trajectory-inference",
    ("reference-mapping", "seurat-label-transfer"): "reference-transfer",
    ("reference-mapping", "scp-runseuratmap"): "reference-mapping",
}
AUTHOR_DEFERRED = {"scp-monocle2", "scp-monocle3", "scp-monocle2-core", "scp-monocle3-core"}
SYNTHETIC = {
    "scp-seurat": "Historical case assigns artificial A/B batch labels; need observed batch metadata and an approved case.",
    "scp-harmony": "Historical case assigns artificial A/B batch labels; need observed batch metadata and an approved case.",
    "scp-dynamicfeatures": "Historical fixture_time is PCA rank, not a measured time or inferred trajectory; need a genuine lineage result and an approved case.",
    "scp-enrichment": "Historical T1/T2 TERM2GENE and TERM2NAME are hand-built; need a lawful gene-set collection, biological universe and approved case.",
    "scp-monocle2-core": "Historical counts are seq_len(20); need observed counts and an explicit biological root_state.",
    "scp-monocle3-core": "Historical counts and embedding are seq_len matrices; need observed counts/embedding and explicit roots/partition policy.",
    "scp-monocle2": "Historical root_state='1' lacks biological justification; root selection requires confirmation.",
    "scp-monocle3": "Historical root is the first cell by position; root/partition selection requires confirmation.",
    "scp-statplot": "Current historical case uses meta_synth; synthetic plotting contract only, not real biological validation.",
    "shap-explain-model": "Historical test fits an analytic four-row artificial linear dataset; numerical contract only. Need a real model, background and evaluation data.",
    "summarize-predictions": "Historical test uses four hand-written outcomes/predictions; numerical contract only. Need real held-out prediction rows and split design.",
    "scp-table-adapters": "Historical dependency-free table tests use artificial cells/expression; schema contract only, not real biological evidence.",
}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def load_json(path: Path, default=None):
    return json.loads(path.read_text(encoding="utf-8-sig")) if path.is_file() else default


def tokens(value):
    if isinstance(value, str):
        return {value} if value.startswith("@") else set()
    if isinstance(value, dict):
        return set().union(*(tokens(item) for item in value.values()), set())
    if isinstance(value, list):
        return set().union(*(tokens(item) for item in value), set())
    return set()


def public_path(path: str) -> str:
    """Keep exact environment-relative prerequisites without private project roots."""
    path = path.replace("\\", "/")
    path = re.sub(r"[A-Za-z]:/research-wiki-env", "$OLD_ENV", path, flags=re.I)
    path = re.sub(r"[A-Za-z]:/research-wiki(?=/)", "$OLD_VAULT", path, flags=re.I)
    path = re.sub(r"[A-Za-z]:/R-4\.5\.0", "$OLD_R", path, flags=re.I)
    path = re.sub(r"[A-Za-z]:/anaconda/python\.exe", "$OLD_PYTHON", path, flags=re.I)
    path = re.sub(r"[A-Za-z]:/(?!R-)[^\s\"']*?/wiki-use", "$PRIVATE_PROJECT/wiki-use", path)
    return path


def clean(value):
    if isinstance(value, str):
        return public_path(value)
    if isinstance(value, dict):
        return {public_path(str(key)): clean(item) for key, item in value.items()}
    if isinstance(value, list):
        return [clean(item) for item in value]
    return value


def input_hashes(value):
    """Extract file identities recorded in nested historical comparison documents."""
    found = {}
    if isinstance(value, dict):
        for key, item in value.items():
            if re.match(r"^[A-Za-z]:[\\/]", key) and isinstance(item, str) and re.fullmatch(r"[0-9a-f]{64}", item):
                found[Path(key.replace("\\", "/")).name] = item
            if isinstance(item, dict) and "path" in item and "sha256" in item:
                found[Path(str(item["path"]).replace("\\", "/")).name] = item["sha256"]
            found.update(input_hashes(item))
    elif isinstance(value, list):
        for item in value:
            found.update(input_hashes(item))
    return found


def classify(method, implementation, receipt, runtime):
    key = (method, implementation)
    if receipt.get("case_id") == "breast-cancer-public-software-case" and receipt.get("promotion") == "adopted":
        return "adopted_public_software_case", [], None
    if key in PORTABLE_CASES:
        return "public_replay_candidate", [], {"kind": "historical_portable", "case": PORTABLE_CASES[key]}
    if implementation in AUTHOR_DEFERRED:
        return "author_deferred", ["Author explicitly deferred Monocle until a biological root group is specified; do not choose state 1, the first cell, or fabricate a root. " + SYNTHETIC[implementation]], None
    if implementation in SYNTHETIC:
        return "scientific_input_or_choice_required", [SYNTHETIC[implementation]], None
    if implementation == "scp-scvelo":
        return "public_input_backend_required", ["Public pancreas has real RNA/spliced/unspliced assays. The current extracted function still imports SCP_analysis from system.file('python', package='SCP'); the Python backend is absent from runtime.files. Audit/declare the pinned backend closure or record the exact undeclared-backend failure; do not report missing biological input."], {
            "kind": "recorded_velocity", "case": {"cells": 80, "seed": 11, "parameters": {"assay_X": "RNA", "assay_layers": ["spliced", "unspliced"], "group_by": "CellType", "linear_reduction": "PCA"}},
            "required_packages": {"R": ["jsonlite", "future"], "Python": ["scanpy", "numpy", "scvelo"]}}
    if implementation == "scp-velocityplot":
        return "derived_input_required", ["Public pancreas has real RNA/spliced/unspliced assays, but this plot requires a genuine computed velocity result. Run the upstream velocity case first; do not fabricate velocity fields."], None
    if method.startswith("scp-viz-"):
        case = receipt.get("case", {}) or {}
        refs = tokens(case.get("args", {}))
        if case.get("args") and refs == {"@pancreas_sub"}:
            return "public_replay_candidate", [], {"kind": "recorded_plot", "case": case}
        if refs:
            return "derived_input_required", ["Need original derived public artifact and its generator: " + ", ".join(sorted(refs))], None
        return "recorded_case_required", ["No current verification pointer/case; an installed namespace or an existing function is insufficient."], None
    if method.startswith("local-omics-"):
        if implementation == "native-library":
            return "catalog_only", ["448 registered source occurrences are a catalog; each function needs explicit bindings, input semantics and a real case."], None
        reason = receipt.get("not_run_reason") or (receipt.get("scope") if receipt.get("state") == "not_run" else None)
        blockers = [reason] if reason else []
        if receipt.get("command"):
            blockers.append("Historical validation driver/config lives in missing external 20261102 cache; restore the exact driver, parameters and lawfully available input before replay.")
        if implementation.startswith("py-"):
            blockers.append("Historical input/probability/model data belong to a private project and are absent; public replacements require an explicit equivalent case.")
        if implementation in {"native-score-dot", "native-dynamic-seurat5", "seurat-dim", "seurat-feature", "seurat-violin", "seurat-dot", "seurat-spatial-dim", "seurat-spatial-feature"}:
            blockers.append("Historical monocle.Rdata / processed_samples_final.RData are private and absent; do not fabricate scores, trajectories, images or spatial coordinates.")
        return "historical_artifact_or_case_required", blockers or ["No recorded real case/explicit scientific arguments."], None
    return "recorded_case_required", ["Historical multi-family test requires extraction into a single isolated driver with original parameters and comparison assertions."], None


def build(vault: Path, dev: Path, public_data: Path):
    sys.path.insert(0, str(dev / "staged/research-wiki"))
    from rwiki.pages import read_page
    rows, pages = [], []
    public_evidence = load_json(Path(__file__).with_name("public-python-evidence") / "summary.json", {})
    public_cases = {row["implementation"]: row for row in public_evidence.get("results", []) if row.get("state") == "passed"}
    method_root = vault / "知识库/methods"
    for page in sorted(method_root.glob("*.md")):
        meta, _ = read_page(page)
        asset = page.with_suffix("")
        manifest = load_json(asset / "runtime.json", {})
        branches = {row["id"]: row for row in manifest.get("implementations", [])}
        implementations = meta.get("implementations", [])
        pages.append({"method": page.stem, "kind": meta.get("method_kind"), "declared_implementations": len(implementations),
                      "has_runtime": bool(manifest), "execution_scope": "declared implementations only" if implementations else "source/workflow catalog; no declared executable implementation",
                      "unlisted_runtime_implementations": sorted(set(branches) - {row["id"] for row in implementations})})
        for impl in implementations:
            name = impl["id"]
            pointer = impl.get("verification")
            receipt = load_json(asset / pointer, {}) if pointer else {}
            runtime = branches.get(name)
            category, blockers, driver = classify(page.stem, name, receipt, runtime)
            if driver and driver["kind"] == "historical_portable":
                historical_driver = vault / "维护记录/2026-10-23-最小依赖独立模块/scripts/portable_run.R"
                driver["source_sha256"] = sha256(historical_driver)
                driver["required_packages"] = {"R": ["jsonlite", "digest", "BiocParallel", "future"]}
            elif driver and driver["kind"] == "recorded_plot":
                driver["required_packages"] = {"R": ["jsonlite"]}
            history = []
            for receipt_path in sorted((asset / "verification").glob("*.json")):
                historical = load_json(receipt_path, {})
                if historical.get("implementation") != name or not historical.get("case"):
                    continue
                case = historical["case"]
                history.append({"receipt": str(receipt_path.relative_to(vault)).replace("\\", "/"),
                                "state": historical.get("state"), "case": case,
                                "input_tokens": sorted(tokens(case)), "public_input_tokens_only": bool(tokens(case)) and tokens(case) <= {"@pancreas_sub"}})
            comparison = load_json(asset / receipt.get("comparison", "__absent__"), {})
            identities = input_hashes(receipt) | input_hashes(comparison)
            for filename, checksum in identities.items():
                if filename != "pancreas_sub.rda":
                    blockers.append("Recorded input artifact absent from the public-data fixture: " + filename + " (sha256 " + checksum + ")")
            files = runtime.get("files", []) if runtime else []
            absent = [filename for filename in files if not (asset / filename).is_file()]
            if absent:
                blockers.append("Missing runtime closure files: " + ", ".join(absent))
                driver = None
            if not runtime:
                blockers.append("No runtime.json branch; independent closure not declared.")
                driver = None
            rows.append({"method": page.stem, "implementation": name, "language": impl.get("language"),
                         "entrypoint": impl.get("entrypoint"), "historical_state": receipt.get("state", "missing"),
                         "current_execution_state": "not_run", "current_verification_pointer": pointer,
                         "historical_command": public_path(receipt.get("command", "")),
                         "historical_case": receipt.get("case"), "recorded_input_identities": identities,
                         "runtime": runtime, "missing_closure_files": absent, "category": category,
                         "blockers": blockers, "driver": driver, "historical_cases": history})
            rows[-1]["historical_case_replay_state"] = "not_run"
            if name in public_cases:
                rows[-1]["current_execution_state"] = "executed_public_case"
                rows[-1]["additional_public_case"] = {"case_id": public_evidence["case_id"], "state": "passed",
                    "scope": "Separate approved public software case; historical private case was not rerun and no formal Wiki pointer promoted",
                    "audit": "public-python-evidence/" + name + "/audit.json",
                    "comparison": "public-python-evidence/" + name + "/comparison.json"}
    fixture = public_data / "pancreas_sub.rda"
    fixture_info = {"name": fixture.name, "exists": fixture.is_file(), "expected_sha256": PANCREAS_SHA256,
                    "source": "https://raw.githubusercontent.com/zhanghao-njmu/SCP/b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0/data/pancreas_sub.rda"}
    if fixture.is_file():
        fixture_info.update(sha256=sha256(fixture), size_bytes=fixture.stat().st_size)
        fixture_info["matches_historical_identity"] = fixture_info["sha256"] == PANCREAS_SHA256
    return {"schema_version": 1, "generated_at": datetime.now(timezone.utc).isoformat(),
            "scope": "Read-only discovery; no method executed and no historical receipt promoted.",
            "summary": {"pages": len(pages), "implementations": len(rows),
                        "historical_states": dict(Counter(row["historical_state"] for row in rows)),
                        "categories": dict(Counter(row["category"] for row in rows)),
                        "additional_public_software_case_passes": len(public_cases),
                        "parameterized_public_candidates": sum(row["driver"] is not None for row in rows)},
            "public_fixture": fixture_info, "pages": pages, "implementations": rows}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--vault", type=Path, required=True)
    parser.add_argument("--dev", type=Path, required=True)
    parser.add_argument("--public-data", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    result = build(args.vault.resolve(), args.dev.resolve(), args.public_data.resolve())
    args.out.write_text(json.dumps(clean(result), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result["summary"], ensure_ascii=False))


if __name__ == "__main__":
    main()
