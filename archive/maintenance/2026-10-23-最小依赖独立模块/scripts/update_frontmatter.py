"""Point method frontmatter at the new standalone receipts and dependencies."""
import json
import sys
from pathlib import Path

STAGED = Path("E:/research-wiki/开发/staged/research-wiki")
WIKI = Path("E:/research-wiki/知识库")
sys.path.insert(0, str(STAGED))

from rwiki.pages import read_page, write_page  # noqa: E402

PACKAGES = {
    "cell-quality-control": ["Seurat", "SeuratObject", "Matrix", "rlang"],
    "doublet-detection": ["Seurat", "SeuratObject", "Matrix", "rlang"],
    "dimensionality-reduction": ["Seurat", "SeuratObject", "Matrix", "rlang", "data.table", "uwot", "intrinsicDimension"],
    "batch-integration": ["Seurat", "SeuratObject", "Matrix", "rlang", "data.table", "uwot", "intrinsicDimension", "proxyC", "dplyr", "future", "future.apply"],
    "cell-type-annotation": ["Seurat", "SeuratObject", "Matrix", "rlang", "SingleR", "SingleCellExperiment", "SummarizedExperiment"],
    "differential-expression": ["Seurat", "SeuratObject", "Matrix", "BiocParallel", "rlang"],
    "gene-set-enrichment": ["clusterProfiler", "BiocParallel", "rlang"],
    "gene-set-scoring": ["Seurat", "SeuratObject", "Matrix", "BiocParallel", "rlang", "ggplot2"],
    "trajectory-inference": ["slingshot", "Seurat", "SeuratObject", "Matrix", "rlang"],
    "dynamic-feature-analysis": ["Seurat", "SeuratObject", "Matrix", "BiocParallel", "mgcv", "rlang"],
    "reference-mapping": ["Seurat", "SeuratObject", "Matrix", "rlang", "data.table", "uwot", "intrinsicDimension", "dplyr", "proxyC"],
    "rna-velocity": ["reticulate", "Seurat", "SeuratObject", "Matrix", "rlang", "scanpy", "numpy", "scvelo"],
}

EXTRA = {
    "trajectory-inference": [
        {"id": "scp-monocle2-core", "title": "Monocle2 分析核心（counts + 元数据）",
         "language": "R", "entrypoint": "code/monocle2_core.R:run_monocle2_core",
         "dependencies": ["monocle", "DDRTree", "VGAM", "BiocGenerics", "Biobase", "igraph", "Matrix", "rlang"],
         "verification": "verification/scp-monocle2-core-standalone.json"},
        {"id": "scp-monocle2", "title": "Monocle2 Seurat 适配分支",
         "language": "R", "entrypoint": "code/monocle2.R:run_trajectory_monocle2",
         "dependencies": ["monocle", "DDRTree", "VGAM", "BiocGenerics", "Biobase", "igraph", "Matrix", "rlang", "Seurat", "SeuratObject"],
         "verification": "verification/scp-monocle2-standalone.json"},
        # Pure plotting helpers are not analysis implementations and are not
        # registered here. They stay in the maintenance snapshot only.
        {"id": "scp-monocle3-core", "title": "Monocle3 分析核心（counts + 元数据）",
         "language": "R", "entrypoint": "code/monocle3_core.R:run_monocle3_core",
         "dependencies": ["monocle3", "SingleCellExperiment", "SummarizedExperiment", "igraph", "Matrix"],
         "verification": "verification/scp-monocle3-core-standalone.json"},
        {"id": "scp-monocle3", "title": "Monocle3 Seurat 适配分支",
         "language": "R", "entrypoint": "code/monocle3.R:run_trajectory_monocle3",
         "dependencies": ["monocle3", "SingleCellExperiment", "SummarizedExperiment", "igraph", "Matrix", "Seurat", "SeuratObject"],
         "verification": "verification/scp-monocle3-standalone.json"},
    ],
}


def main():
    changed = 0
    for method, packages in PACKAGES.items():
        page = WIKI / "methods" / f"{method}.md"
        meta, body = read_page(page)
        items = [item for item in (meta.get("implementations") or [])
                 if not (isinstance(item, dict) and str(item.get("id", "")).endswith("-plot"))]
        for item in items:
            if not isinstance(item, dict):
                continue
            iid = item.get("id")
            if not iid:
                continue
            receipt = page.with_suffix("") / "verification" / f"{iid}-standalone.json"
            if receipt.is_file():
                item["verification"] = f"verification/{iid}-standalone.json"
            if str(iid).startswith("scp-monocle"):
                item["dependencies"] = next(
                    entry["dependencies"] for entry in EXTRA["trajectory-inference"] if entry["id"] == iid)
            elif iid == "seurat-label-transfer":
                item["dependencies"] = ["Seurat", "SeuratObject"]
            else:
                item["dependencies"] = packages
        existing = {item.get("id") for item in items if isinstance(item, dict)}
        for extra in EXTRA.get(method, []):
            if extra["id"] not in existing:
                items.append(extra)
            else:
                for item in items:
                    if isinstance(item, dict) and item.get("id") == extra["id"]:
                        item["title"] = extra["title"]
                        item["entrypoint"] = extra["entrypoint"]
                        item["verification"] = extra["verification"]
        meta["implementations"] = items
        write_page(page, meta, body)
        changed += 1
    print("updated", changed)


if __name__ == "__main__":
    main()
