# 旧页 → 规范家族 → 实现 → 原始来源

本表是本轮跨来源去重的交付物。旧页保留原 id、`source/` 原字节和作者备注，只作为来源/流程/技术资料；分析判断与 `figure_relations` 主记录在规范家族页。参数变化不新建家族；同一算法不同包装是实现差异；不同算法同属一个家族时并列策略，不抹平假设。

## 1. 旧 method 页去向

| 旧页（id） | 分类后 `method_kind` | 规范家族页 | 具体实现 / 分支 | 原始来源 |
|---|---|---|---|---|
| `scp-annotation-projection` | technical | [[methods/cell-type-annotation]] | `scp-singler`（not_run，SingleR 缺失） | `methods/scp-annotation-projection/source/SCP-cell_annotation.R`；SCP `RunSingleR` |
| `scp-annotation-projection` | technical | [[methods/reference-mapping]] | `seurat-label-transfer`（verified）；`scp-runseuratmap`（not_run，UMAP 投影错误） | `methods/scp-annotation-projection/source/SCP-projection.R`；SCP `RunSeuratMap` |
| `scp-cellqc-doublet` | technical | [[methods/cell-quality-control]] | `scp-runcellqc`（verified：UMI/基因数/线粒体阈值） | `methods/scp-cellqc-doublet/source/SCP-cellqc.R`；SCP `RunCellQC` |
| `scp-cellqc-doublet` | technical | [[methods/doublet-detection]] | `scp-rundoublet`（not_run：scDblFinder 缺失） | 同上；SCP `RunDoubletCalling` 的 scDblFinder 分支 |
| `scp-de-enrichment-dynamic` | technical | [[methods/differential-expression]] | `scp-detest`（verified：wilcox） | `methods/scp-de-enrichment-dynamic/source/SCP-analysis.R`；SCP `RunDEtest` |
| `scp-de-enrichment-dynamic` | technical | [[methods/gene-set-enrichment]] | `scp-enrichment`（verified：自定义 TERM2GENE 的 ORA） | 同上；SCP `RunEnrichment` |
| `scp-de-enrichment-dynamic` | technical | [[methods/gene-set-scoring]] | `scp-cellscoring`（verified：Seurat/AddModuleScore） | 同上；SCP `CellScoring` |
| `scp-de-enrichment-dynamic` | technical | [[methods/dynamic-feature-analysis]] | `scp-dynamicfeatures`（verified：Gaussian + 夹具 pseudotime） | 同上；SCP `RunDynamicFeatures` |
| `scp-integration` | technical | [[methods/batch-integration]] | `scp-seurat`（verified）；`scp-harmony`（not_run，harmony 缺失） | `methods/scp-integration/source/SCP-workflow.R`；SCP `Seurat_integrate` / `Harmony_integrate` |
| `scp-local-source` | technical | 全部单细胞家族 | 共享 SCP-local bundle；无独立分析入口 | `methods/scp-local-source/source/`；`methods/scp-local-source/code/SCP-local/` |
| `scp-standard-workflow` | workflow | [[methods/dimensionality-reduction]]；[[methods/cell-clustering]] | `scp-dimreduction`（verified）；`seurat-findclusters`（verified） | `methods/scp-standard-workflow/source/SCP-workflow.R`；SCP `Standard_SCP` |
| `scp-standard-workflow` | workflow | [[methods/cell-quality-control]]；[[methods/doublet-detection]]；[[methods/batch-integration]] | 组合流程引用规范家族，不重复计为分析家族 | 同上；流程步骤 |
| `scp-trajectory-velocity` | technical | [[methods/trajectory-inference]] | `scp-slingshot`（verified） | `methods/scp-trajectory-velocity/source/SCP-analysis.R`；SCP `RunSlingshot` |
| `scp-trajectory-velocity` | technical | [[methods/rna-velocity]] | `scp-scvelo`（not_run：Python 后端缺失） | 同上；SCP `RunSCVELO` |
| `scp-trajectory-velocity` | technical | [[methods/dynamic-feature-analysis]] | `scp-dynamicfeatures`（verified，Gaussian 分支） | 同上；SCP `RunDynamicFeatures` |
| `scp-visualization-interface` | technical | [[methods/scp-visualization-interface]]（技术页） | `scp-table-adapters`（verified：25 PASS） | `methods/scp-visualization-interface/source/SCP-plot.R`；`code/scp_tables.R` |
| `scrna-marker-annotation` | technical | [[methods/cell-type-annotation]] | 青光眼 marker 手工注释来源；未函数化、未验证 | `methods/scrna-marker-annotation/source/annotation.R`；作者 `markers`/`celltype_map` |
| `scrna-marker-annotation` | technical | [[methods/cell-clustering]] | `seurat-findclusters`（verified） | 同上；课题 FindClusters 检查 |
| `scrna-pathway-signature-ensemble` | technical | [[methods/gene-set-scoring]] | 青光眼五种分数相加来源；未函数化、未验证；不是通用标准 | `methods/scrna-pathway-signature-ensemble/source/score_pathway_signatures.R` |
| `scrna-preprocess-doublet-qc-harmony` | workflow | [[methods/cell-quality-control]] | 青光眼 MAD 3× QC 来源；未函数化、未验证 | `methods/scrna-preprocess-doublet-qc-harmony/source/preprocess.R` |
| `scrna-preprocess-doublet-qc-harmony` | workflow | [[methods/doublet-detection]] | 青光眼 DoubletFinder 来源；未函数化、未验证 | 同上；DoubletFinder 7.5% + paramSweep |
| `scrna-preprocess-doublet-qc-harmony` | workflow | [[methods/batch-integration]] | 青光眼 Harmony 来源；未函数化、未验证 | 同上；harmony |
| `scrna-preprocess-doublet-qc-harmony` | workflow | [[methods/dimensionality-reduction]]；[[methods/cell-clustering]] | 组合流程引用规范家族，不重复计为分析家族 | 同上；Seurat PCA/UMAP/FindClusters |
| `shap-explanation` | analysis | [[methods/shap-explanation]] | `shap-explain-model`（verified） | 画廊 `2026-08-17-shap-feature-mechanism/figures/fig01-shap-a-f`；旧脚本 `code/shap_explain.py` |
| `regression-resampling-evaluation` | analysis | [[methods/regression-resampling-evaluation]] | `summarize-predictions`（verified） | 画廊 `2026-10-19-regression-stability/figures/fig03-density-panel`；原帖链接见 frontmatter |

## 2. 规范家族的实现与来源

| 规范家族 | 声明分支 | 当前状态 | 原始来源 |
|---|---|---|---|
| `cell-quality-control` | `scp-runcellqc` | verified（80 细胞；UMI/基因数/线粒体） | SCP `RunCellQC`；青光眼 `preprocess.R` MAD 来源 |
| `doublet-detection` | `scp-rundoublet` | not_run（scDblFinder 缺失） | SCP `RunDoubletCalling`；青光眼 DoubletFinder 来源 |
| `batch-integration` | `scp-seurat` / `scp-harmony` | verified / not_run（harmony 缺失） | SCP `Seurat_integrate` / `Harmony_integrate`；青光眼 harmony 来源 |
| `differential-expression` | `scp-detest` | verified（Ductal vs Endocrine） | SCP `RunDEtest` |
| `gene-set-enrichment` | `scp-enrichment` | verified（自定义 TERM2GENE ORA） | SCP `RunEnrichment` |
| `gene-set-scoring` | `scp-cellscoring` | verified（Seurat/AddModuleScore） | SCP `CellScoring`；青光眼五分数来源 |
| `trajectory-inference` | `scp-slingshot` | verified（80 细胞） | SCP `RunSlingshot` |
| `rna-velocity` | `scp-scvelo` | not_run（Python 后端缺失） | SCP `RunSCVELO` |
| `cell-type-annotation` | `scp-singler` | not_run（SingleR 缺失） | SCP `RunSingleR`；青光眼 marker 手工注释来源 |
| `reference-mapping` | `seurat-label-transfer` / `scp-runseuratmap` | verified / not_run（UMAP 投影错误） | SCP `RunSeuratMap` 分支；Seurat anchors |
| `dimensionality-reduction` | `scp-dimreduction` | verified（PCA/UMAP） | SCP `RunDimReduction`；青光眼 preprocess 来源 |
| `cell-clustering` | `seurat-findclusters` | verified（PCA 1:20） | SCP `Standard_SCP` 的 FindNeighbors/FindClusters |
| `dynamic-feature-analysis` | `scp-dynamicfeatures` | verified（Gaussian + 夹具 pseudotime） | SCP `RunDynamicFeatures` |
| `shap-explanation` | `shap-explain-model` | verified（解析线性模型） | 原帖/画廊；旧 `shap_explain.py` |
| `regression-resampling-evaluation` | `summarize-predictions` | verified（合成指标表） | 原帖/画廊 |

## 3. 同家族多来源的处理规则

| 情形 | 处理 | 例子 |
|---|---|---|
| 同一算法、不同包装/课题脚本 | 同一家族下增加 implementation 或来源说明；不新建家族 | SCP Harmony 与青光眼 Harmony；SCP `RunSingleR` 与 Seurat 标签转移要分开（算法不同） |
| 同一分析目的、不同算法 | 同一家族并列策略，比较输入、假设、输出，不标成可互换 | scDblFinder vs DoubletFinder；SingleR vs marker 手工注释 |
| 多个步骤串联 | 记为 `workflow` 资料，步骤引用规范家族 | `scp-standard-workflow`、`scrna-preprocess-doublet-qc-harmony` |
| 源码/绘图适配 | `technical` 资料，不作为分析家族 | `scp-local-source`、`scp-visualization-interface` |
| 参数变化 | 配置差异，不新建家族/方法 | 双细胞预期率、QC 阈值、resolution、dims |
| 新分析目的 | 才提议新家族；先查库并说明与现有家族的边界 | 需作者确认；本轮未新增同义分析页 |

自动 `lint` 只检查声明结构、标题重复、实现/收据结构；跨来源语义同义性由 agent 按本表和入库八步人工审查，不能宣称自动解决。
