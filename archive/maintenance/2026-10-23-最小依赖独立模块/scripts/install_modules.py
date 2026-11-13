"""Install extracted minimal modules, runtime manifests and evidence into the wiki.

Run with the research-wiki venv:
  C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe -X utf8 \
    scripts/install_modules.py
"""
import hashlib
import json
import os
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path

RECORD = Path(__file__).resolve().parents[1]
PILOT = RECORD / "pilot3"
WIKI = Path("E:/research-wiki/知识库")
STAGED = Path("E:/research-wiki/开发/staged/research-wiki")
BUNDLE = WIKI / "methods/scp-local-source/code/SCP-local"
sys.path.insert(0, str(STAGED))

COMMIT = "b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0"
SOURCE = {"package": "SCP-local", "version": "0.5.6", "commit": COMMIT, "license": "GPL (>= 3)"}
R = lambda *items: {"R": list(items)}
OPT = lambda **items: {"R": items}

MODULES = {
    "cell-quality-control": {
        "native": ["cellqc_native.R"],
        "title": "SCP RunCellQC", "functions": ["R/SCP-cellqc.R:RunCellQC", "R/SCP-cellqc.R:RunDoubletCalling", "R/SCP-cellqc.R:db_scDblFinder", "R/SCP-cellqc.R:db_scds", "R/SCP-cellqc.R:db_Scrublet", "R/SCP-cellqc.R:db_DoubletDetection"],
        "required": R("Seurat", "SeuratObject", "Matrix", "rlang"),
        "optional": OPT(scDblFinder="doublet branch when qc_metrics includes doublets",
                        scds="scds doublet branch", reticulate="Scrublet/DoubletDetection Python branches"),
        "python": [], "optional_python": {"scrublet": "Scrublet doublet branch", "doubletdetection": "DoubletDetection doublet branch"},
        "mods": ["check_R/check_Python replaced with fail-only guards", "SeuratObject >= 5 GetAssayData/Assays compatibility shims", "compiled asMatrix helper excluded; its only call is unreachable in upstream as_matrix"],
        "implementations": [("scp-runcellqc", "run_cell_quality_control")],
        "portability": {"scp-runcellqc": "cell-quality-control"},
    },
    "doublet-detection": {
        "native": ["doublet_native.R"],
        "title": "SCP RunDoubletCalling", "functions": ["R/SCP-cellqc.R:RunDoubletCalling", "R/SCP-cellqc.R:db_scDblFinder", "R/SCP-cellqc.R:db_scds", "R/SCP-cellqc.R:db_Scrublet", "R/SCP-cellqc.R:db_DoubletDetection"],
        "required": R("Seurat", "SeuratObject", "Matrix", "rlang"),
        "optional": OPT(scDblFinder="scDblFinder branch", scds="scds branch", reticulate="Scrublet/DoubletDetection branches"),
        "python": [], "optional_python": {"scrublet": "Scrublet branch", "doubletdetection": "DoubletDetection branch"},
        "mods": ["check_R/check_Python replaced with fail-only guards", "SeuratObject >= 5 compatibility shim", "compiled asMatrix helper excluded; unreachable upstream call"],
        "implementations": [("scp-rundoublet", "run_doublet_detection")],
        "portability": {"scp-rundoublet": "doublet-detection"},
    },
    "dimensionality-reduction": {
        "native": ["dimreduction_native.R"],
        "title": "SCP RunDimReduction", "functions": ["R/SCP-workflow.R:RunDimReduction", "R/Seurat-function.R:RunUMAP2", "R/Seurat-function.R:RunNMF", "R/Seurat-function.R:RunGLMPCA", "R/Seurat-function.R:RunMDS", "R/Seurat-function.R:RunDM", "R/Seurat-function.R:RunPHATE", "R/Seurat-function.R:RunPaCMAP", "R/Seurat-function.R:RunTriMap", "R/Seurat-function.R:RunLargeVis", "R/Seurat-function.R:RunFR"],
        "required": R("Seurat", "SeuratObject", "Matrix", "rlang", "data.table", "uwot", "intrinsicDimension"),
        "optional": OPT(NMF="linear_reduction='nmf'", glmpca="linear_reduction='glmpca'", destiny="nonlinear_reduction='dm'", reticulate="phate/pacmap/trimap/largevis branches"),
        "python": [], "optional_python": {},
        "mods": ["check_R/check_Python replaced with fail-only guards", "SeuratObject >= 5 GetAssayData compatibility shim", "compiled asMatrix helper excluded; unreachable upstream call"],
        "implementations": [("scp-dimreduction", "run_dimensionality_reduction")],
        "portability": {"scp-dimreduction": "dimensionality-reduction"},
    },
    "batch-integration": {
        "native": ["integration_native.R"],
        "title": "SCP integration branches", "functions": ["R/SCP-workflow.R:Seurat_integrate", "R/SCP-workflow.R:Harmony_integrate", "R/SCP-workflow.R:RunDimReduction", "R/Seurat-function.R:RunUMAP2", "R/Seurat-function.R:RunHarmony2"],
        "required": R("Seurat", "SeuratObject", "Matrix", "rlang", "data.table", "uwot", "intrinsicDimension", "proxyC", "dplyr", "future", "future.apply"),
        "optional": OPT(harmony="Harmony_integrate branch", Signac="TFIDF/ChromatinAssay branch", reticulate="Leiden clustering branch"),
        "python": [], "optional_python": {"leidenalg": "leiden clustering"},
        "mods": ["check_R/check_Python replaced with fail-only guards", "SeuratObject >= 5 GetAssayData compatibility shim", "compiled asMatrix helper excluded; unreachable upstream call"],
        "implementations": [("scp-seurat", "run_seurat_integration"), ("scp-harmony", "run_batch_integration")],
        "portability": {"scp-seurat": "batch-integration", "scp-harmony": "batch-integration-harmony"},
    },
    "cell-type-annotation": {
        "native": ["annotation_native.R"],
        "title": "SCP RunSingleR", "functions": ["R/SCP-cell_annotation.R:RunSingleR"],
        "required": R("Seurat", "SeuratObject", "Matrix", "rlang", "SingleR", "SingleCellExperiment", "SummarizedExperiment"),
        "optional": OPT(), "python": [], "optional_python": {},
        "mods": ["check_R replaced with a fail-only guard", "SeuratObject >= 5 GetAssayData compatibility shim"],
        "implementations": [("scp-singler", "run_cell_type_annotation")],
        "portability": {"scp-singler": "cell-type-annotation"},
    },
    "differential-expression": {
        "native": ["de_native.R"],
        "title": "SCP RunDEtest", "functions": ["R/SCP-analysis.R:RunDEtest"],
        "required": R("Seurat", "SeuratObject", "Matrix", "BiocParallel", "rlang"),
        "optional": OPT(limma="limma test branches", edgeR="edgeR test branches", DESeq2="DESeq2 test branches"),
        "python": [], "optional_python": {},
        "mods": ["SeuratObject >= 5 Assays/GetAssayData compatibility shims"],
        "implementations": [("scp-detest", "run_differential_expression")],
        "portability": {"scp-detest": "differential-expression"},
    },
    "gene-set-enrichment": {
        "native": ["enrichment_native.R"],
        "title": "SCP RunEnrichment", "functions": ["R/SCP-analysis.R:RunEnrichment", "R/SCP-analysis.R:PrepareDB", "R/SCP-analysis.R:GeneConvert"],
        "required": R("clusterProfiler", "BiocParallel", "rlang"),
        "optional": OPT(**{"org.Hs.eg.db": "built-in human database", "org.Mm.eg.db": "built-in mouse database",
                           "GO.db": "GO database", "msigdbr": "MSigDB database", "gson": "gson database",
                           "AnnotationDbi": "database/ID conversion branch", "biomaRt": "database/ID conversion branch",
                           "R.cache": "database cache", "reshape2": "database branch", "data.table": "database branch"},
                          idconvert="IDtype -> result_IDtype conversion branch"),
        "python": [], "optional_python": {},
        "mods": ["check_R replaced with a fail-only guard", "network/database branches require the corresponding local packages; no installation"],
        "implementations": [("scp-enrichment", "run_gene_set_enrichment")],
        "portability": {"scp-enrichment": "gene-set-enrichment"},
    },
    "gene-set-scoring": {
        "native": ["scoring_native.R"],
        "title": "SCP CellScoring", "functions": ["R/SCP-analysis.R:CellScoring", "R/SCP-analysis.R:AddModuleScore2"],
        "required": R("Seurat", "SeuratObject", "Matrix", "BiocParallel", "rlang", "ggplot2"),
        "optional": OPT(AUCell="method='AUCell'", UCell="method='UCell'", **{"clusterProfiler": "built-in database lookup", "biomaRt": "built-in database lookup", "R.cache": "built-in database cache", "AnnotationDbi": "built-in database lookup", "reshape2": "built-in database lookup"}),
        "python": [], "optional_python": {},
        "mods": ["check_R replaced with a fail-only guard", "SeuratObject >= 5 GetAssayData compatibility shim"],
        "implementations": [("scp-cellscoring", "run_gene_set_scoring")],
        "portability": {"scp-cellscoring": "gene-set-scoring"},
    },
    "trajectory-inference": {
        "native": ["slingshot_native.R", "monocle2_core.R", "monocle2_core_helpers.R",
                   "monocle2.R", "monocle3_core.R", "monocle3.R"],
        "title": "SCP trajectory branches",
        "functions": ["R/SCP-analysis.R:RunSlingshot", "R/SCP-analysis.R:RunMonocle2", "R/SCP-analysis.R:RunMonocle3"],
        "required": R("slingshot", "Seurat", "SeuratObject", "Matrix", "rlang"),
        "optional": OPT(ggplot2="Slingshot plot branch", patchwork="Slingshot plot branch", ggrepel="Slingshot plot branch", ggnewscale="Slingshot plot branch", circlize="Slingshot plot branch", gtable="Slingshot plot branch", plotly="Slingshot plot branch", dplyr="Slingshot plot branch", reshape2="Slingshot plot branch", scales="Slingshot plot branch", BiocParallel="Slingshot plot branch", grid="Slingshot plot branch"),
        "python": [], "optional_python": {},
        "mods": ["SCP::palette_list replaced with the local palette_list loaded from code/data/palette_list.rda",
                 "check_R replaced with a fail-only guard",
                 "SeuratObject >= 5 GetAssayData/Assays compatibility shims",
                 "Monocle2/3: RunMonocle2/3 split into analysis core, Seurat adapter and optional plot; plotting/interactive root selection removed from the core; root/partition must be explicit"],
        "implementations": [
            ("scp-slingshot", "run_trajectory_inference", "analysis.R", R("slingshot", "Seurat", "SeuratObject", "Matrix", "rlang"), ["R/SCP-analysis.R:RunSlingshot"], None),
            ("scp-monocle2-core", "run_monocle2_core", "monocle2_core.R", R("monocle", "DDRTree", "VGAM", "BiocGenerics", "Biobase", "igraph", "Matrix", "rlang"), ["R/SCP-analysis.R:RunMonocle2", "R/SCP-analysis.R:orderCells", "R/SCP-analysis.R:project2MST"], OPT()),
            ("scp-monocle2", "run_trajectory_monocle2", "monocle2.R", R("monocle", "DDRTree", "VGAM", "BiocGenerics", "Biobase", "igraph", "Matrix", "rlang", "Seurat", "SeuratObject"), ["R/SCP-analysis.R:RunMonocle2"], OPT()),
            ("scp-monocle3-core", "run_monocle3_core", "monocle3_core.R", R("monocle3", "SingleCellExperiment", "SummarizedExperiment", "igraph", "Matrix"), ["R/SCP-analysis.R:RunMonocle3"], OPT()),
            ("scp-monocle3", "run_trajectory_monocle3", "monocle3.R", R("monocle3", "SingleCellExperiment", "SummarizedExperiment", "igraph", "Matrix", "Seurat", "SeuratObject"), ["R/SCP-analysis.R:RunMonocle3"], OPT())],
        "portability": {"scp-slingshot": "trajectory-inference", "scp-monocle2-core": "monocle2-core", "scp-monocle2": "monocle2",
                        "scp-monocle3-core": "monocle3-core", "scp-monocle3": "monocle3"},
    },
    "dynamic-feature-analysis": {
        "native": ["dynamic_native.R"],
        "title": "SCP RunDynamicFeatures", "functions": ["R/SCP-analysis.R:RunDynamicFeatures"],
        "required": R("Seurat", "SeuratObject", "Matrix", "BiocParallel", "mgcv", "rlang"),
        "optional": OPT(), "python": [], "optional_python": {},
        "mods": ["check_R replaced with a fail-only guard", "SeuratObject >= 5 GetAssayData compatibility shim"],
        "implementations": [("scp-dynamicfeatures", "run_dynamic_feature_analysis")],
        "portability": {"scp-dynamicfeatures": "dynamic-feature-analysis"},
    },
    "reference-mapping": {
        "native": ["reference_native.R"],
        "title": "SCP RunSeuratMap", "functions": ["R/SCP-projection.R:RunSeuratMap", "R/SCP-projection.R:RunKNNMap", "R/SCP-workflow.R:Standard_SCP"],
        "required": R("Seurat", "SeuratObject", "Matrix", "rlang", "data.table", "uwot", "intrinsicDimension", "dplyr", "proxyC"),
        "optional": OPT(Signac="TFIDF branch", reticulate="Leiden clustering branch"),
        "python": [], "optional_python": {"leidenalg": "leiden clustering"},
        "mods": ["check_R/check_Python replaced with fail-only guards", "SeuratObject >= 5 compatibility shims", "compiled asMatrix helper excluded; unreachable upstream call"],
        "implementations": [("seurat-label-transfer", "run_reference_label_transfer", "transfer.R", R("Seurat", "SeuratObject"), ["R/SCP-projection.R:FindTransferAnchors", "R/SCP-projection.R:TransferData"]),
                            ("scp-runseuratmap", "run_reference_mapping", "analysis.R", None, ["R/SCP-projection.R:RunSeuratMap", "R/SCP-projection.R:RunKNNMap"])],
        "portability": {"seurat-label-transfer": "reference-transfer", "scp-runseuratmap": "reference-mapping"},
    },
    "rna-velocity": {
        "native": ["velocity_native.R"],
        "title": "SCP RunSCVELO", "functions": ["R/SCP-analysis.R:RunSCVELO"],
        "required": R("reticulate", "Seurat", "SeuratObject", "Matrix", "rlang"),
        "optional": OPT(ggplot2="plot branch", patchwork="plot branch", ggrepel="plot branch", ggnewscale="plot branch", circlize="plot branch", gtable="plot branch", plotly="plot branch", dplyr="plot branch", reshape2="plot branch", scales="plot branch", BiocParallel="plot branch", grid="plot branch"),
        "python": ["scanpy", "numpy", "scvelo"], "optional_python": {"magic-impute": "magic imputation"},
        "mods": ["SCP::palette_list replaced with the local palette_list loaded from code/data/palette_list.rda", "check_R/check_Python replaced with fail-only guards"],
        "implementations": [("scp-scvelo", "run_rna_velocity")],
        "portability": {"scp-scvelo": "rna-velocity"},
    },
}

PALETTE_MODULES = {"trajectory-inference", "rna-velocity"}


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_json(path: Path, data):
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")


def copy_module(method: str, config: dict):
    target = WIKI / "methods" / method / "code"
    target.mkdir(parents=True, exist_ok=True)
    source = PILOT / method / "code"
    for name in ["analysis.R"] + config["native"]:
        shutil.copy2(source / name, target / name)
    if method == "trajectory-inference":
        for name in ("monocle2.R", "monocle3.R"):
            shutil.copy2(source / name, target / name)
    if method == "reference-mapping":
        shutil.copy2(source / "transfer.R", target / "transfer.R")
    if method in PALETTE_MODULES:
        (target / "data").mkdir(exist_ok=True)
        shutil.copy2(BUNDLE / "data/palette_list.rda", target / "data/palette_list.rda")


def implementation_files(method: str, config: dict, entry: str, native=None, packages=None):
    if entry == "transfer.R":
        return ["code/transfer.R"]
    if entry == "monocle2_core.R":
        return ["code/monocle2_core.R", "code/monocle2_core_helpers.R"]
    if entry == "monocle3_core.R":
        return ["code/monocle3_core.R"]
    if entry == "monocle2.R":
        return ["code/monocle2.R", "code/monocle2_core.R", "code/monocle2_core_helpers.R"]
    if entry == "monocle3.R":
        return ["code/monocle3.R", "code/monocle3_core.R"]
    if entry in ("monocle2_plot.R", "monocle3_plot.R"):
        return [f"code/{entry}"]
    native = native or config["native"]
    if entry == "analysis.R" and method == "trajectory-inference":
        native = ["slingshot_native.R"]
    files = ["code/analysis.R"] + [f"code/{name}" for name in native]
    if method in PALETTE_MODULES:
        files.append("code/data/palette_list.rda")
    return files


def build():
    now = datetime.now(timezone.utc).isoformat()
    for method, config in MODULES.items():
        copy_module(method, config)
        asset = WIKI / "methods" / method
        implementations = []
        for item in config["implementations"]:
            iid, function = item[0], item[1]
            entry = item[2] if len(item) > 2 else "analysis.R"
            required = item[3] if len(item) > 3 and item[3] is not None else config["required"]
            functions = item[4] if len(item) > 4 else config["functions"]
            optional = item[5] if len(item) > 5 and item[5] is not None else config["optional"]
            files = implementation_files(method, config, entry)
            resources = []
            for name in files:
                if name.startswith("code/data/"):
                    resources.append({"path": name, "sha256": sha(asset / name),
                                      "role": "SCP palette data used by optional plot helpers"})
            optional_packages = dict(optional)
            if config["optional_python"]:
                optional_packages["Python"] = config["optional_python"]
            required_packages = dict(required)
            if config["python"]:
                required_packages["Python"] = config["python"]
            implementations.append({
                "id": iid, "entry": f"code/{entry}", "entry_function": function,
                "language": "R", "runtime_mode": "standalone",
                "files": files, "resources": resources,
                "required_packages": required_packages,
                "optional_packages": optional_packages,
                "source": {**SOURCE, "functions": functions, "modifications": config["mods"]},
                "evidence": {"portability": f"verification/{iid}-portability.json"},
            })
        manifest = {"schema_version": 1, "kind": "method", "id": method,
                    "implementations": implementations}
        write_json(asset / "runtime.json", manifest)
        # Portability receipts, driven by the actual run summary.
        for iid, _function in [(i[0], i[1]) for i in config["implementations"]]:
            files = next(i["files"] for i in implementations if i["id"] == iid)
            key = config["portability"][iid]
            summary = portable_summary(key)
            log_state = summary.get("state", "not_run") if summary else "not_run"
            log_error = (summary.get("error") if summary else None) or "portability summary missing; see maintenance record"
            input_unchanged = bool(summary.get("input_unchanged")) if summary else False
            executed_codes = (summary or {}).get("code_sha256") or {}
            code_mismatch = [name for name in files
                             if executed_codes.get(name[5:] if name.startswith("code/") else name)
                             != sha(asset / name)]
            if log_state == "passed" and (not executed_codes or code_mismatch):
                log_state = "not_run"
                log_error = ("executed code hash missing or differs from current code; rerun required: "
                             + ", ".join(code_mismatch or files))
            closure = closure_hash(asset, manifest, iid)
            output_path = Path(summary["out_file"]) if summary and summary.get("out_file") else None
            input_path = Path(summary["input_file"]) if summary and summary.get("input_file") else None
            checks = [
                "Module code copied to an isolated directory without the SCP-local bundle",
                "New R process, source() only from the copied closure",
                "No SCP-local path passed; package installation disabled",
            ]
            if input_unchanged:
                checks.append("Input object unchanged (serialization before/after)")
            if log_state == "passed":
                checks.append("Actual call returned a result")
            receipt = {
                "schema_version": 1, "kind": "method", "implementation": iid,
                "state": log_state,
                "scope": ("Isolated copy of the declared closure; new R process; "
                          "no SCP-local path; required packages only" if log_state == "passed"
                          else log_error),
                "closure_hash": closure,
                "files": {name: sha(asset / name) for name in files},
                "copied_files": files,
                "executed_files": {name: executed_codes.get(name[5:] if name.startswith("code/") else name)
                                   for name in files},
                "command": (summary or {}).get("command", ""),
                "case": (summary or {}).get("case"),
                "isolated_code_dir": (summary or {}).get("code_dir"),
                "fixture": (summary or {}).get("fixture"),
                "input_sha256": sha(input_path) if input_path and input_path.is_file() else None,
                "output_sha256": sha(output_path) if output_path and output_path.is_file() else None,
                "environment": {
                    "R": (summary or {}).get("R_version", "4.5.0"),
                    "platform": (summary or {}).get("platform"),
                    "BPPARAM": "BiocParallel::SerialParam()", "future": "sequential",
                },
                "checks": checks,
                "executed_at": (summary or {}).get("executed_at", now),
            }
            if log_state != "passed":
                receipt["not_run_reason"] = log_error
            write_json(asset / "verification" / f"{iid}-portability.json", receipt)
        # Algorithm receipts: state comes only from the actual comparison artifact.
        for iid in [item[0] for item in config["implementations"]]:
            key = config["portability"][iid]
            summary = portable_summary(key)
            comparison = comparison_summary(key)
            files = {p.relative_to(asset).as_posix(): sha(p) for p in (asset / "code").rglob("*") if p.is_file()}
            executed = (summary or {}).get("code_sha256") or {}
            declared = next(
                (item["files"] for item in manifest["implementations"] if item["id"] == iid), files)
            codes_ok = bool(executed) and all(
                executed.get(name[5:] if name.startswith("code/") else name) == sha(asset / name)
                for name in declared)
            passed = (summary and summary.get("state") == "passed" and codes_ok
                      and comparison and comparison.get("state") == "passed")
            if passed:
                state = "passed"
                checks = [f"{name}: {'PASS' if value else 'FAIL'}"
                          for name, value in (comparison.get("checks") or {}).items()]
                scope = (f"Actual isolated run and comparison for {iid}; "
                         f"case={json.dumps(summary.get('case'), ensure_ascii=False)}")
            else:
                state = "not_run"
                reason = ((summary or {}).get("error")
                          or ("executed code hash missing or differs from current code; rerun required"
                              if summary and summary.get("state") == "passed" and not codes_ok else None)
                          or ("comparison artifact missing or failed"
                              if summary and summary.get("state") == "passed" else None)
                          or "portability run missing")
                checks = [f"Observed: {reason}"]
                scope = reason
            receipt = {"schema_version": 1, "implementation": iid, "state": state,
                       "scope": scope, "command": (summary or {}).get("command", ""),
                       "case": (summary or {}).get("case"),
                       "checks": checks,
                       "environment": {"R": (summary or {}).get("R_version", "4.5.0"),
                                       "platform": (summary or {}).get("platform"),
                                       "BPPARAM": "BiocParallel::SerialParam()", "future": "sequential"},
                       "files": files,
                       "executed_files": {name: executed.get(name[5:] if name.startswith("code/") else name)
                                          for name in declared}}
            if state == "not_run":
                receipt["not_run_reason"] = scope
            write_json(asset / "verification" / f"{iid}-standalone.json", receipt)


def portable_summary(key: str):
    summary = RECORD / "portability" / key / "result.json"
    if not summary.is_file():
        return None
    try:
        return json.loads(summary.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None


def comparison_summary(key: str):
    path = RECORD / "portability" / key / "comparison.json"
    if not path.is_file():
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return None


def closure_hash(asset: Path, manifest: dict, iid: str) -> str:
    implementation = next(item for item in manifest["implementations"] if item["id"] == iid)
    digest = hashlib.sha256((asset / "runtime.json").read_bytes())
    for name in sorted(implementation["files"]):
        digest.update(name.encode("utf-8"))
        digest.update(b"\0")
        digest.update((asset / name).read_bytes())
    return digest.hexdigest()


TEMPLATE_PACKAGES = {
    "fig01": ["ggplot2", "ggrepel", "scales", "rlang", "jsonlite"],
    "fig02": ["ggplot2", "ggrepel", "rlang", "scales", "jsonlite"],
    "fig03": ["dplyr", "ggplot2", "ggrepel", "rlang", "scales", "jsonlite"],
    "fig04": ["dplyr", "ggplot2", "ggrepel", "rlang", "scales", "jsonlite"],
    "fig05": ["dplyr", "ggplot2", "ggrepel", "rlang", "scales", "jsonlite"],
    "fig06": ["dplyr", "ggplot2", "ggrepel", "rlang", "scales", "jsonlite"],
    "fig07": ["dplyr", "ggplot2", "ggrepel", "rlang", "scales", "jsonlite"],
    "fig08": ["ComplexHeatmap", "circlize", "grid", "gtable", "patchwork", "ggplot2", "jsonlite"],
    "fig09": ["dplyr", "ggplot2", "ggrepel", "rlang", "scales", "jsonlite"],
    "fig10": ["dplyr", "ggplot2", "gtable", "patchwork", "purrr", "stringr", "tidyr", "grid", "jsonlite"],
    "fig11": ["circlize", "graphics", "grid", "jsonlite"],
    "fig12": ["dplyr", "ggplot2", "ggrepel", "rlang", "ggVennDiagram", "sf", "jsonlite"],
    "fig13": ["dplyr", "ggplot2", "ggrepel", "rlang", "ggupset", "jsonlite"],
    "fig14": ["ComplexHeatmap", "circlize", "grid", "gtable", "patchwork", "ggplot2", "jsonlite"],
    "fig15": ["ComplexHeatmap", "circlize", "dplyr", "ggplot2", "grid", "gtable", "patchwork", "rlang", "scales", "Seurat", "jsonlite"],
    "fig16": ["dplyr", "ggplot2", "patchwork", "rlang", "ggridges", "SeuratObject", "methods", "jsonlite"],
}


def template_key(name: str) -> str:
    return name.split("__")[1].split("-")[0]


def install_templates():
    evidence = json.loads((RECORD / "portability" / "templates-evidence.json").read_text(encoding="utf-8"))
    now = datetime.now(timezone.utc).isoformat()
    for name, item in evidence.items():
        asset = WIKI / "templates" / name
        code = asset / "code"
        files = sorted(p.relative_to(asset).as_posix() for p in code.rglob("*") if p.is_file())
        packages = TEMPLATE_PACKAGES[template_key(name)]
        manifest = {
            "schema_version": 1, "kind": "template", "id": name,
            "entry": "code/render.R", "language": "r", "runtime_mode": "standalone",
            "files": files,
            "resources": [{"path": "code/data/palette_list.rda",
                           "sha256": sha(code / "data/palette_list.rda"),
                           "role": "SCP palette data used by the native helpers"}],
            "required_packages": {"R": packages},
            "optional_packages": {"R": {"svglite": "vector SVG device when installed; otherwise grDevices::svg fallback"}},
            "source": {**SOURCE, "functions": ["R/SCP-plot.R native panel core"],
                       "modifications": ["SCP::palette_list replaced with the local palette_list loaded from code/data/palette_list.rda",
                                          "only the selected native panel core and its helpers are copied"]},
            "evidence": {"portability": "verify/runtime-portability.json"},
        }
        write_json(asset / "runtime.json", manifest)
        digest = hashlib.sha256((asset / "runtime.json").read_bytes())
        for filename in files:
            digest.update(filename.encode("utf-8"))
            digest.update(b"\0")
            digest.update((asset / filename).read_bytes())
        closure = digest.hexdigest()
        state = item["state"]
        reason = None
        executed_codes = item.get("code_sha256") or {}
        mismatched = [filename for filename in files if executed_codes.get(filename) != sha(asset / filename)]
        if state == "passed" and (not executed_codes or mismatched):
            state = "not_run"
            reason = "executed template code hash missing or differs from current code; rerun required: " + ", ".join(mismatched or files)
        receipt = {
            "schema_version": 1, "kind": "template", "implementation": name,
            "state": state,
            "scope": ("Isolated copy of the template (spec, code, example); new R process; no SCP-local path; "
                      "render.R invoked from an unrelated working directory"),
            "closure_hash": closure,
            "files": {filename: sha(asset / filename) for filename in files},
            "copied_files": files,
            "command": item.get("command", ""),
            "isolated_dir": item.get("isolated_dir"),
            "code_dir": item.get("code_dir"),
            "example_dir": item.get("example_dir"),
            "out_dir": item.get("out_dir"),
            "environment": {"R": "4.5.0", "Rscript": "D:/R-4.5.0/bin/Rscript.exe",
                            "working_directory": item.get("working_directory")},
            "checks": [
                "Template copied to an isolated directory without the SCP-local bundle",
                "New R process; render.R resolved spec.json and code locally",
                "No SCP-local path passed; package installation disabled",
                "PNG compared pixel-wise with the existing verify/figure.png",
            ],
            "outputs": item["outputs"],
            "previous_outputs": item.get("previous_outputs", {}),
            "same_as_previous": item.get("same_as_previous", {}),
            "started_at": item.get("started_at"),
            "executed_at": item.get("executed_at", now),
        }
        if state == "passed":
            receipt["checks"].append("PNG pixel-identical to the existing verify output (MAD=0)")
        else:
            receipt["not_run_reason"] = reason or "\n".join(item.get("error_tail") or [])
        write_json(asset / "verify" / "runtime-portability.json", receipt)


if __name__ == "__main__":
    build()
    install_templates()
    print("installed modules:", len(MODULES), "templates:", len(TEMPLATE_PACKAGES))
