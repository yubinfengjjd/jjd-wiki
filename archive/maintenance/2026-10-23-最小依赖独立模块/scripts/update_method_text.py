"""Update method prose: minimal call closure, deprecated bundle, runtime manifest."""
import sys
from pathlib import Path

STAGED = Path("E:/research-wiki/开发/staged/research-wiki")
WIKI = Path("E:/research-wiki/知识库")
sys.path.insert(0, str(STAGED))
from rwiki.pages import read_page, write_page  # noqa: E402

NOTE = ("本目录是所选分支的最小调用闭包：复制 `code/`（以及 `runtime.json` 列出的资源）即可在课题环境运行，"
        "不再需要完整 `SCP-local`。`bundle` 参数仅为兼容旧调用而接受，函数不会读取；必要/可选依赖、复制清单和"
        "独立性证据见 `runtime.json` 与 `verification/*-portability.json`。\n")

REPLACEMENTS = {
    "cell-quality-control": [
        ("入口 `methods/cell-quality-control/code/analysis.R:run_cell_quality_control(srt, bundle, parameters)`。"
         "`bundle` 指向复制到课题的完整 `SCP-local` 目录，函数按固定哈希校验后 source，不写死知识库路径；"
         "依赖 Seurat、SeuratObject。参数与 SCP `RunCellQC` 同名，统计逻辑未改。",
         "入口 `methods/cell-quality-control/code/analysis.R:run_cell_quality_control(srt, bundle = NULL, parameters)`。"
         "参数与 SCP `RunCellQC` 同名，统计逻辑未改；双细胞辅助函数只在 `qc_metrics` 包含 doublets 时检查其包。"),
    ],
    "doublet-detection": [
        ("`methods/doublet-detection/code/analysis.R:run_doublet_detection(srt, bundle, parameters)`",
         "`methods/doublet-detection/code/analysis.R:run_doublet_detection(srt, bundle = NULL, parameters)`"),
    ],
    "dimensionality-reduction": [
        ("`methods/dimensionality-reduction/code/analysis.R:run_dimensionality_reduction(srt, bundle, parameters)`",
         "`methods/dimensionality-reduction/code/analysis.R:run_dimensionality_reduction(srt, bundle = NULL, parameters)`"),
        ("封装与上游 UMAP 一致。", "PCA 与 UMAP 嵌入与保留的完整 bundle 参考一致（异目录复制、新进程、仅必需包）。"),
    ],
    "batch-integration": [
        ("`methods/batch-integration/code/analysis.R:run_seurat_integration(srt, batch, bundle, parameters)`",
         "`methods/batch-integration/code/analysis.R:run_seurat_integration(srt, batch, bundle = NULL, parameters)`"),
        ("`run_batch_integration(srt, bundle, parameters)`",
         "`run_batch_integration(srt, bundle = NULL, parameters)`"),
    ],
    "cell-type-annotation": [
        ("`methods/cell-type-annotation/code/analysis.R:run_cell_type_annotation(srt_query, srt_ref, bundle, parameters)`",
         "`methods/cell-type-annotation/code/analysis.R:run_cell_type_annotation(srt_query, srt_ref, bundle = NULL, parameters)`"),
    ],
    "differential-expression": [
        ("`methods/differential-expression/code/analysis.R:run_differential_expression(srt, bundle, parameters)`",
         "`methods/differential-expression/code/analysis.R:run_differential_expression(srt, bundle = NULL, parameters)`"),
        ("封装与上游 `AllMarkers_wilcox` 表一致。", "`AllMarkers_wilcox` 表与保留的完整 bundle 参考一致（异目录复制、新进程、`BiocParallel::SerialParam()`）。"),
    ],
    "gene-set-enrichment": [
        ("`methods/gene-set-enrichment/code/analysis.R:run_gene_set_enrichment(gene_ids, bundle, parameters)`",
         "`methods/gene-set-enrichment/code/analysis.R:run_gene_set_enrichment(gene_ids, bundle = NULL, parameters)`"),
        ("封装结果表与上游一致。", "结果表与保留的完整 bundle 参考一致（异目录复制、新进程、无网络）。"),
    ],
    "gene-set-scoring": [
        ("`methods/gene-set-scoring/code/analysis.R:run_gene_set_scoring(srt, bundle, parameters)`",
         "`methods/gene-set-scoring/code/analysis.R:run_gene_set_scoring(srt, bundle = NULL, parameters)`"),
        ("封装分数与上游一致；", "分数与保留的完整 bundle 参考一致（异目录复制、新进程、`BiocParallel::SerialParam()`）；"),
    ],
    "trajectory-inference": [
        ("`methods/trajectory-inference/code/analysis.R:run_trajectory_inference(srt, bundle, parameters)`",
         "`methods/trajectory-inference/code/analysis.R:run_trajectory_inference(srt, bundle = NULL, parameters)`"),
        ("Monocle2/Monocle3/PAGA 等分支未运行。",
         "Monocle2/Monocle3 已从固定版本 SCP 原函数 `RunMonocle2`/`RunMonocle3` 提取到 "
         "`code/monocle2.R`/`code/monocle3.R`（入口 `run_trajectory_monocle2`/`run_trajectory_monocle3`），"
         "未新写算法；本机缺 `monocle`/`monocle3`，独立复制后的新进程在包检查处准确 `not_run`。"
         "PAGA 等未入库分支仍未运行。"),
    ],
    "dynamic-feature-analysis": [
        ("`methods/dynamic-feature-analysis/code/analysis.R:run_dynamic_feature_analysis(srt, bundle, parameters)`",
         "`methods/dynamic-feature-analysis/code/analysis.R:run_dynamic_feature_analysis(srt, bundle = NULL, parameters)`"),
        ("封装与上游 `DynamicFeatures` 表一致。", "`DynamicFeatures` 表与保留的完整 bundle 参考一致（异目录复制、新进程、`BiocParallel::SerialParam()`）。"),
    ],
    "reference-mapping": [
        ("`methods/reference-mapping/code/analysis.R:run_reference_mapping(...)`",
         "`methods/reference-mapping/code/analysis.R:run_reference_mapping(srt_query, srt_ref, bundle = NULL, parameters)`"),
        ("`methods/reference-mapping/code/transfer.R:run_reference_label_transfer(query, reference, ref_group_col, ...)`",
         "`methods/reference-mapping/code/transfer.R:run_reference_label_transfer(query, reference, ref_group_col, ...)`"),
    ],
    "rna-velocity": [
        ("`methods/rna-velocity/code/analysis.R:run_rna_velocity(srt, bundle, parameters)`",
         "`methods/rna-velocity/code/analysis.R:run_rna_velocity(srt, bundle = NULL, parameters)`"),
    ],
}


def main():
    changed = 0
    for method, pairs in REPLACEMENTS.items():
        page = WIKI / "methods" / f"{method}.md"
        meta, body = read_page(page)
        for old, new in pairs:
            if old not in body:
                print("MISS", method, old[:60])
                continue
            body = body.replace(old, new)
        marker = "## 代码\n\n"
        if NOTE not in body:
            body = body.replace(marker, marker + NOTE + "\n", 1)
        write_page(page, meta, body)
        changed += 1
    print("updated", changed)


if __name__ == "__main__":
    main()
