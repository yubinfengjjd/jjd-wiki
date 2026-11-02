"""Write implementation receipts from commands that actually ran.

Passed receipts are added only after the named command exited 0 and the checks
listed below were printed. not_run receipts keep the exact observed error.
"""
from pathlib import Path
import hashlib
import json

ROOT = Path("E:/research-wiki/知识库/methods")
R_CMD = ("D:/R-4.5.0/bin/Rscript.exe --vanilla "
         "E:/research-wiki/维护记录/2026-10-23-方法家族与LLM-Wiki/test_scientific_R.R "
         "E:/research-wiki/知识库 "
         "E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda")
PY_CMD = ("E:/research-wiki-env/bio-python/Scripts/python.exe -X utf8 "
          "E:/research-wiki/维护记录/2026-10-23-方法家族与LLM-Wiki/test_scientific_python.py "
          "E:/research-wiki/知识库/methods")
TABLE_CMD = ("D:/R-4.5.0/bin/Rscript.exe --vanilla "
             "E:/research-wiki/知识库/methods/scp-visualization-interface/code/test_scp_tables.R")

R_ENV = {"language": "R", "R": "4.5.0", "Seurat": "5.6.0", "SeuratObject": "5.4.0",
         "slingshot": "2.16.0", "clusterProfiler": "4.16.0", "DOSE": "4.2.0",
         "mgcv": "1.9.1", "BiocParallel": "1.42.0", "OS": "Windows 11"}
PY_ENV = {"language": "Python", "python": "3.12.14", "numpy": "2.5.4",
          "pandas": "3.0.6", "scikit-learn": "1.9.1", "shap": "0.54.1",
          "OS": "Windows 11"}
R_PORT = ("D:/R-4.5.0/bin/Rscript.exe --vanilla "
          "E:/research-wiki/维护记录/2026-10-23-方法家族与LLM-Wiki/test_portability.R "
          "E:/research-wiki/知识库 "
          "E:/research-wiki-env/sources/scp-2026-10-22/data/pancreas_sub.rda "
          "E:/research-wiki-env/tmp/rw-portability-20261023")
PY_PORT = ("E:/research-wiki-env/bio-python/Scripts/python.exe -X utf8 "
           "E:/research-wiki/维护记录/2026-10-23-方法家族与LLM-Wiki/test_portability_python.py "
           "E:/research-wiki/知识库 E:/research-wiki-env/tmp/rw-portability-python-20261023")
PORTABILITY = {
    "cell-quality-control/scp-runcellqc": "QC runs from copied code and copied bundle",
    "batch-integration/scp-seurat": "Seurat integration runs from copied code and copied bundle",
    "differential-expression/scp-detest": "DE runs from copied code and copied bundle",
    "gene-set-enrichment/scp-enrichment": "ORA runs from copied code and copied bundle",
    "gene-set-scoring/scp-cellscoring": "gene-set scoring runs from copied code and copied bundle",
    "trajectory-inference/scp-slingshot": "Slingshot runs from copied code and copied bundle",
    "reference-mapping/seurat-label-transfer": "reference label transfer runs from copied code",
    "dimensionality-reduction/scp-dimreduction": "PCA/UMAP runs from copied code and copied bundle",
    "cell-clustering/seurat-findclusters": "clustering runs from copied code",
    "dynamic-feature-analysis/scp-dynamicfeatures": "dynamic features run from copied code and copied bundle",
    "scp-visualization-interface/scp-table-adapters": "SCP table adapters run from copied code",
    "shap-explanation/shap-explain-model": "SHAP and regression run from copied code outside the wiki",
    "regression-resampling-evaluation/summarize-predictions": "SHAP and regression run from copied code outside the wiki",
}

BRANCHES = [
    # method, id, entrypoint, state, scope, checks, command, env, error (not_run)
    ("cell-quality-control", "scp-runcellqc", "code/analysis.R:run_cell_quality_control",
     "passed",
     "实际调用 SCP RunCellQC 于 pancreas_sub 的 80 个细胞；比较封装与上游 CellQC、检查输入未变。",
     ["QC returns a Seurat result", "QC keeps all requested cells and does not mutate the input",
      "QC writes count, feature and CellQC fields", "QC wrapper matches the preserved upstream call"],
     R_CMD, R_ENV, None),
    ("doublet-detection", "scp-rundoublet", "code/analysis.R:run_doublet_detection",
     "not_run",
     "SCP RunDoubletCalling 的 scDblFinder 分支；本机 R 库无 scDblFinder。",
     ["Observed: Missing R dependency: scDblFinder; automatic installation is disabled"],
     R_CMD, R_ENV, "Missing R dependency: scDblFinder; automatic installation is disabled"),
    ("batch-integration", "scp-seurat", "code/analysis.R:run_seurat_integration",
     "passed",
     "实际调用 SCP Seurat_integrate：pancreas_sub 120 细胞拆成两个显式批次，300 HVF、20 PC、k.weight=30；比较封装与上游 UMAP。",
     ["Seurat integration returns a Seurat result", "Seurat integration keeps cells and writes an integrated UMAP",
      "Seurat integration writes a cluster field", "Seurat integration wrapper matches the preserved upstream call"],
     R_CMD, R_ENV, None),
    ("batch-integration", "scp-harmony", "code/analysis.R:run_batch_integration",
     "not_run",
     "SCP Harmony_integrate 分支；本机 R 库无 harmony。",
     ["Observed: Missing R dependency: harmony; automatic installation is disabled"],
     R_CMD, R_ENV, "Missing R dependency: harmony; automatic installation is disabled"),
    ("differential-expression", "scp-detest", "code/analysis.R:run_differential_expression",
     "passed",
     "实际调用 SCP RunDEtest：pancreas_sub 全数据，Ductal vs Endocrine，wilcox；比较封装与上游 AllMarkers 表。",
     ["DE returns the upstream Seurat result", "DE stores a gene-level table with effect size and adjusted p values",
      "DE wrapper matches the preserved upstream call"],
     R_CMD, R_ENV, None),
    ("gene-set-enrichment", "scp-enrichment", "code/analysis.R:run_gene_set_enrichment",
     "passed",
     "实际调用 SCP RunEnrichment 的 ORA 分支，显式 TERM2GENE/TERM2NAME（两个合成基因集），与上游结果表比较。",
     ["ORA returns an enrichment result table", "ORA wrapper matches the preserved upstream call"],
     R_CMD, R_ENV, None),
    ("gene-set-scoring", "scp-cellscoring", "code/analysis.R:run_gene_set_scoring",
     "passed",
     "实际调用 SCP CellScoring 的 Seurat/AddModuleScore 分支，显式 name='X' 避开上游空 name 的列名缺陷；与上游分数比较。",
     ["gene-set scoring writes one score column per named set",
      "gene-set scoring wrapper matches the preserved upstream call"],
     R_CMD, R_ENV, None),
    ("trajectory-inference", "scp-slingshot", "code/analysis.R:run_trajectory_inference",
     "passed",
     "实际调用 SCP RunSlingshot：pancreas_sub 80 细胞，CellType 分组，UMAP 1:2；比较 pseudotime 与 BranchID。",
     ["Slingshot returns lineage pseudotime and branch labels",
      "Slingshot wrapper matches the preserved upstream call"],
     R_CMD, R_ENV, None),
    ("rna-velocity", "scp-scvelo", "code/analysis.R:run_rna_velocity",
     "not_run",
     "SCP RunSCVELO 分支需要 reticulate 与 scvelo；本机未设置 RETICULATE_PYTHON，且未安装 scvelo/scanpy。",
     ["Observed: Set RETICULATE_PYTHON to an existing project interpreter; installation disabled"],
     R_CMD, R_ENV,
     "Set RETICULATE_PYTHON to an existing project interpreter; installation disabled"),
    ("cell-type-annotation", "scp-singler", "code/analysis.R:run_cell_type_annotation",
     "not_run",
     "SCP RunSingleR 分支；本机 R 库无 SingleR。",
     ["Observed: Missing R dependency: SingleR; automatic installation is disabled"],
     R_CMD, R_ENV, "Missing R dependency: SingleR; automatic installation is disabled"),
    ("reference-mapping", "seurat-label-transfer", "code/transfer.R:run_reference_label_transfer",
     "passed",
     "从 SCP RunSeuratMap 提取 FindTransferAnchors + TransferData 标签转移分支；pancreas_sub 300 参考/700 查询，检查每细胞预测、顺序与 anchor 数。不包含 UMAP 投影。",
     ["reference label transfer returns one prediction per query cell",
      "reference label transfer preserves query order and reports anchor count"],
     R_CMD, R_ENV, None),
    ("reference-mapping", "scp-runseuratmap", "code/analysis.R:run_reference_mapping",
     "not_run",
     "SCP RunSeuratMap 的 UMAP 投影分支在 Seurat 5.6 下失败；标签转移另由 seurat-label-transfer 分支验证。",
     ["Observed: Argument 'dim.' must be an integer vector of length two"],
     R_CMD, R_ENV, "Argument 'dim.' must be an integer vector of length two"),
    ("dimensionality-reduction", "scp-dimreduction", "code/analysis.R:run_dimensionality_reduction",
     "passed",
     "实际调用 SCP RunDimReduction：pancreas_sub 200 细胞，100 HVF、20 PC、UMAP；比较封装与上游 UMAP。",
     ["dimension reduction writes PCA and UMAP", "UMAP has one row per cell",
      "dimension-reduction wrapper matches the preserved upstream call"],
     R_CMD, R_ENV, None),
    ("cell-clustering", "seurat-findclusters", "code/clustering.R:run_seurat_clustering",
     "passed",
     "显式复用 SCP Standard_SCP 中的 FindNeighbors/FindClusters 聚类分支；与相同 Seurat 调用逐标签比较，不含预处理/降维。",
     ["clustering returns one cluster label per cell", "clustering preserves cell order",
      "clustering matches the same explicit Seurat FindNeighbors/FindClusters calls"],
     R_CMD, R_ENV, None),
    ("dynamic-feature-analysis", "scp-dynamicfeatures", "code/analysis.R:run_dynamic_feature_analysis",
     "passed",
     "实际调用 SCP RunDynamicFeatures：pancreas_sub 80 细胞，显式 fixture pseudotime，Gcg/Krt19；比较 GAM 表。pseudotime 为软件夹具，不代表真实轨迹。",
     ["dynamic features return a per-gene GAM table",
      "dynamic-feature wrapper matches the preserved upstream call"],
     R_CMD, R_ENV, None),
    ("shap-explanation", "shap-explain-model", "code/explain_model.py:explain_model",
     "passed",
     "解析线性模型 SHAP 精确解；检查 summary/samples 表、百分比、输入与模型未变、特征顺序保护。",
     ["SHAP analytical linear solution; tables; no input/model mutation; feature order guard"],
     PY_CMD, PY_ENV, None),
    ("regression-resampling-evaluation", "summarize-predictions", "code/summarize_predictions.py:summarize",
     "passed",
     "手算折外指标、常数预测 r 未定义、不修改输入、完整 coverage 拒绝。不包含训练或重采样。",
     ["regression hand-derived metrics; constant prediction r; no mutation; heldout coverage"],
     PY_CMD, PY_ENV, None),
    ("scp-visualization-interface", "scp-table-adapters", "code/scp_tables.R:scp_umap_groups",
     "passed",
     "SCP/Seurat 导出表到 Wiki 绘图接口的适配层；20 个合成表检查。未验证 SCP 绘图函数视觉等价。",
     ["25 PASS, 0 FAIL in test_scp_tables.R: columns, order, conversions, guards, CSV round trip"],
     TABLE_CMD, R_ENV, None),
]


def code_files(asset: Path) -> dict[str, str]:
    return {
        path.relative_to(asset).as_posix(): hashlib.sha256(path.read_bytes()).hexdigest()
        for path in sorted((asset / "code").rglob("*"))
        if path.is_file() and "__pycache__" not in path.parts
        and path.suffix.lower() not in (".pyc", ".pyo")
    }


def main():
    for method, iid, entry, state, scope, checks, command, env, error in BRANCHES:
        asset = ROOT / method
        files = code_files(asset)
        entry_file = entry.partition(":")[0]
        if entry_file not in files:
            raise SystemExit(f"{method}: entrypoint {entry_file} not in code files")
        data = {
            "schema_version": 1,
            "implementation": iid,
            "state": state,
            "scope": scope,
            "command": command,
            "checks": checks,
            "environment": env,
            "files": files,
        }
        if error:
            data["observed_error"] = error
        portability = PORTABILITY.get(f"{method}/{iid}")
        if state == "passed" and portability:
            data["checks"].append("Portability: " + portability)
            data["portability"] = {
                "command": PY_PORT if method in ("shap-explanation", "regression-resampling-evaluation") else R_PORT,
                "scope": "复制 code/ 与 SCP-local 到 E:/research-wiki-env/tmp 下的异目录，用绝对 bundle/数据路径重跑代表调用；不使用知识库工作目录。",
                "checks": [portability],
            }
        target = asset / "verification" / f"{iid}.json"
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"{method}/{iid}: {state}, {len(files)} file(s)")


if __name__ == "__main__":
    main()
