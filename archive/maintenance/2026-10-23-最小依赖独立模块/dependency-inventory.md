# 逐实现 / 逐模板依赖清单

日期：2026-10-23。机器可读版：`dependency-inventory.json`。

## 方法实现

### cell-quality-control
| 实现 | 运行模式 | 必要包 | 可选包 | 复制文件 | 资源 | 独立迁移 | 算法 | 证据 |
|---|---|---|---|---|---|---|---|---|
| scp-runcellqc | standalone | R: Seurat, SeuratObject, Matrix, rlang | R: scDblFinder, scds, reticulate; Python: scrublet, doubletdetection | code/analysis.R; code/cellqc_native.R | — | verified | passed | `verification/scp-runcellqc-portability.json`; `verification/scp-runcellqc-standalone.json` |

### doublet-detection
| 实现 | 运行模式 | 必要包 | 可选包 | 复制文件 | 资源 | 独立迁移 | 算法 | 证据 |
|---|---|---|---|---|---|---|---|---|
| scp-rundoublet | standalone | R: Seurat, SeuratObject, Matrix, rlang | R: scDblFinder, scds, reticulate; Python: scrublet, doubletdetection | code/analysis.R; code/doublet_native.R | — | not_run | not_run | `verification/scp-rundoublet-portability.json`; `verification/scp-rundoublet-standalone.json` |

### dimensionality-reduction
| 实现 | 运行模式 | 必要包 | 可选包 | 复制文件 | 资源 | 独立迁移 | 算法 | 证据 |
|---|---|---|---|---|---|---|---|---|
| scp-dimreduction | standalone | R: Seurat, SeuratObject, Matrix, rlang, data.table, uwot, intrinsicDimension | R: NMF, glmpca, destiny, reticulate | code/analysis.R; code/dimreduction_native.R | — | verified | passed | `verification/scp-dimreduction-portability.json`; `verification/scp-dimreduction-standalone.json` |

### batch-integration
| 实现 | 运行模式 | 必要包 | 可选包 | 复制文件 | 资源 | 独立迁移 | 算法 | 证据 |
|---|---|---|---|---|---|---|---|---|
| scp-seurat | standalone | R: Seurat, SeuratObject, Matrix, rlang, data.table, uwot, intrinsicDimension, proxyC, dplyr, future, future.apply | R: harmony, Signac, reticulate; Python: leidenalg | code/analysis.R; code/integration_native.R | — | verified | passed | `verification/scp-seurat-portability.json`; `verification/scp-seurat-standalone.json` |
| scp-harmony | standalone | R: Seurat, SeuratObject, Matrix, rlang, data.table, uwot, intrinsicDimension, proxyC, dplyr, future, future.apply | R: harmony, Signac, reticulate; Python: leidenalg | code/analysis.R; code/integration_native.R | — | not_run | not_run | `verification/scp-harmony-portability.json`; `verification/scp-harmony-standalone.json` |

### cell-type-annotation
| 实现 | 运行模式 | 必要包 | 可选包 | 复制文件 | 资源 | 独立迁移 | 算法 | 证据 |
|---|---|---|---|---|---|---|---|---|
| scp-singler | standalone | R: Seurat, SeuratObject, Matrix, rlang, SingleR, SingleCellExperiment, SummarizedExperiment | R:  | code/analysis.R; code/annotation_native.R | — | not_run | not_run | `verification/scp-singler-portability.json`; `verification/scp-singler-standalone.json` |

### differential-expression
| 实现 | 运行模式 | 必要包 | 可选包 | 复制文件 | 资源 | 独立迁移 | 算法 | 证据 |
|---|---|---|---|---|---|---|---|---|
| scp-detest | standalone | R: Seurat, SeuratObject, Matrix, BiocParallel, rlang | R: limma, edgeR, DESeq2 | code/analysis.R; code/de_native.R | — | verified | passed | `verification/scp-detest-portability.json`; `verification/scp-detest-standalone.json` |

### gene-set-enrichment
| 实现 | 运行模式 | 必要包 | 可选包 | 复制文件 | 资源 | 独立迁移 | 算法 | 证据 |
|---|---|---|---|---|---|---|---|---|
| scp-enrichment | standalone | R: clusterProfiler, BiocParallel, rlang | R: org.Hs.eg.db, org.Mm.eg.db, GO.db, msigdbr, gson, AnnotationDbi, biomaRt, R.cache, reshape2, data.table, idconvert | code/analysis.R; code/enrichment_native.R | — | verified | passed | `verification/scp-enrichment-portability.json`; `verification/scp-enrichment-standalone.json` |

### gene-set-scoring
| 实现 | 运行模式 | 必要包 | 可选包 | 复制文件 | 资源 | 独立迁移 | 算法 | 证据 |
|---|---|---|---|---|---|---|---|---|
| scp-cellscoring | standalone | R: Seurat, SeuratObject, Matrix, BiocParallel, rlang, ggplot2 | R: AUCell, UCell, clusterProfiler, biomaRt, R.cache, AnnotationDbi, reshape2 | code/analysis.R; code/scoring_native.R | — | verified | passed | `verification/scp-cellscoring-portability.json`; `verification/scp-cellscoring-standalone.json` |

### trajectory-inference
| 实现 | 运行模式 | 必要包 | 可选包 | 复制文件 | 资源 | 独立迁移 | 算法 | 证据 |
|---|---|---|---|---|---|---|---|---|
| scp-slingshot | standalone | R: slingshot, Seurat, SeuratObject, Matrix, rlang | R: ggplot2, patchwork, ggrepel, ggnewscale, circlize, gtable, plotly, dplyr, reshape2, scales, BiocParallel, grid | code/analysis.R; code/slingshot_native.R; code/data/palette_list.rda | code/data/palette_list.rda | verified | passed | `verification/scp-slingshot-portability.json`; `verification/scp-slingshot-standalone.json` |
| scp-monocle2 | standalone | R: monocle, DDRTree, VGAM, BiocGenerics, Biobase, igraph, Matrix, rlang, Seurat, SeuratObject | R:  | code/monocle2.R; code/monocle2_core.R; code/monocle2_core_helpers.R | — | not_run | not_run | `verification/scp-monocle2-portability.json`; `verification/scp-monocle2-standalone.json` |
| scp-monocle3 | standalone | R: monocle3, SingleCellExperiment, SummarizedExperiment, igraph, Matrix, Seurat, SeuratObject | R:  | code/monocle3.R; code/monocle3_core.R | — | not_run | not_run | `verification/scp-monocle3-portability.json`; `verification/scp-monocle3-standalone.json` |
| scp-monocle2-core | standalone | R: monocle, DDRTree, VGAM, BiocGenerics, Biobase, igraph, Matrix, rlang | R:  | code/monocle2_core.R; code/monocle2_core_helpers.R | — | not_run | not_run | `verification/scp-monocle2-core-portability.json`; `verification/scp-monocle2-core-standalone.json` |
| scp-monocle3-core | standalone | R: monocle3, SingleCellExperiment, SummarizedExperiment, igraph, Matrix | R:  | code/monocle3_core.R | — | not_run | not_run | `verification/scp-monocle3-core-portability.json`; `verification/scp-monocle3-core-standalone.json` |

### dynamic-feature-analysis
| 实现 | 运行模式 | 必要包 | 可选包 | 复制文件 | 资源 | 独立迁移 | 算法 | 证据 |
|---|---|---|---|---|---|---|---|---|
| scp-dynamicfeatures | standalone | R: Seurat, SeuratObject, Matrix, BiocParallel, mgcv, rlang | R:  | code/analysis.R; code/dynamic_native.R | — | verified | passed | `verification/scp-dynamicfeatures-portability.json`; `verification/scp-dynamicfeatures-standalone.json` |

### reference-mapping
| 实现 | 运行模式 | 必要包 | 可选包 | 复制文件 | 资源 | 独立迁移 | 算法 | 证据 |
|---|---|---|---|---|---|---|---|---|
| seurat-label-transfer | standalone | R: Seurat, SeuratObject | R: Signac, reticulate; Python: leidenalg | code/transfer.R | — | verified | passed | `verification/seurat-label-transfer-portability.json`; `verification/seurat-label-transfer-standalone.json` |
| scp-runseuratmap | standalone | R: Seurat, SeuratObject, Matrix, rlang, data.table, uwot, intrinsicDimension, dplyr, proxyC | R: Signac, reticulate; Python: leidenalg | code/analysis.R; code/reference_native.R | — | not_run | not_run | `verification/scp-runseuratmap-portability.json`; `verification/scp-runseuratmap-standalone.json` |

### rna-velocity
| 实现 | 运行模式 | 必要包 | 可选包 | 复制文件 | 资源 | 独立迁移 | 算法 | 证据 |
|---|---|---|---|---|---|---|---|---|
| scp-scvelo | standalone | R: reticulate, Seurat, SeuratObject, Matrix, rlang; Python: scanpy, numpy, scvelo | R: ggplot2, patchwork, ggrepel, ggnewscale, circlize, gtable, plotly, dplyr, reshape2, scales, BiocParallel, grid; Python: magic-impute | code/analysis.R; code/velocity_native.R; code/data/palette_list.rda | code/data/palette_list.rda | not_run | not_run | `verification/scp-scvelo-portability.json`; `verification/scp-scvelo-standalone.json` |

## 模板

| 模板 | 运行模式 | 必要包 | 可选包 | 复制文件 | 资源 | 独立迁移 | 证据 |
|---|---|---|---|---|---|---|---|
| 2026-10-22-scp-example__fig01-volcano--volcano | standalone | R: ggplot2, ggrepel, scales, rlang, jsonlite | R: svglite | code/core.R; code/data/palette_list.rda; code/panel.R; code/render.R; code/scp_helpers.R; code/scp_volcano_native.R | code/data/palette_list.rda | verified | `verify/runtime-portability.json` |
| 2026-10-22-scp-example__fig02-ring--ring | standalone | R: ggplot2, ggrepel, rlang, scales, jsonlite | R: svglite | code/core.R; code/data/palette_list.rda; code/panel.R; code/render.R; code/scp_helpers.R; code/scp_ring_native.R | code/data/palette_list.rda | verified | `verify/runtime-portability.json` |
| 2026-10-22-scp-example__fig03-pie--pie | standalone | R: dplyr, ggplot2, ggrepel, rlang, scales, jsonlite | R: svglite | code/core.R; code/data/palette_list.rda; code/panel.R; code/render.R; code/scp_helpers.R; code/scp_stat_native.R | code/data/palette_list.rda | verified | `verify/runtime-portability.json` |
| 2026-10-22-scp-example__fig04-rose--rose | standalone | R: dplyr, ggplot2, ggrepel, rlang, scales, jsonlite | R: svglite | code/core.R; code/data/palette_list.rda; code/panel.R; code/render.R; code/scp_helpers.R; code/scp_stat_native.R | code/data/palette_list.rda | verified | `verify/runtime-portability.json` |
| 2026-10-22-scp-example__fig05-trend--trend | standalone | R: dplyr, ggplot2, ggrepel, rlang, scales, jsonlite | R: svglite | code/core.R; code/data/palette_list.rda; code/panel.R; code/render.R; code/scp_helpers.R; code/scp_stat_native.R | code/data/palette_list.rda | verified | `verify/runtime-portability.json` |
| 2026-10-22-scp-example__fig06-area--area | standalone | R: dplyr, ggplot2, ggrepel, rlang, scales, jsonlite | R: svglite | code/core.R; code/data/palette_list.rda; code/panel.R; code/render.R; code/scp_helpers.R; code/scp_stat_native.R | code/data/palette_list.rda | verified | `verify/runtime-portability.json` |
| 2026-10-22-scp-example__fig07-dot--dot | standalone | R: dplyr, ggplot2, ggrepel, rlang, scales, jsonlite | R: svglite | code/core.R; code/data/palette_list.rda; code/panel.R; code/render.R; code/scp_helpers.R; code/scp_stat_native.R | code/data/palette_list.rda | verified | `verify/runtime-portability.json` |
| 2026-10-22-scp-example__fig08-group-heatmap--heatmap | standalone | R: ComplexHeatmap, circlize, grid, gtable, patchwork, ggplot2, jsonlite | R: svglite | code/core.R; code/data/palette_list.rda; code/panel.R; code/render.R; code/scp_group_heatmap_native.R; code/scp_helpers.R; code/sizing.R | code/data/palette_list.rda | verified | `verify/runtime-portability.json` |
| 2026-10-22-scp-example__fig09-bar--bar | standalone | R: dplyr, ggplot2, ggrepel, rlang, scales, jsonlite | R: svglite | code/core.R; code/data/palette_list.rda; code/panel.R; code/render.R; code/scp_bar_native.R; code/scp_helpers.R | code/data/palette_list.rda | verified | `verify/runtime-portability.json` |
| 2026-10-22-scp-example__fig10-sankey--sankey | standalone | R: dplyr, ggplot2, gtable, patchwork, purrr, stringr, tidyr, grid, jsonlite | R: svglite | code/core.R; code/data/palette_list.rda; code/panel.R; code/render.R; code/scp_helpers.R; code/scp_sankey_native.R | code/data/palette_list.rda | verified | `verify/runtime-portability.json` |
| 2026-10-22-scp-example__fig11-chord--chord | standalone | R: circlize, graphics, grid, jsonlite | R: svglite | code/core.R; code/data/palette_list.rda; code/panel.R; code/render.R; code/scp_chord_native.R; code/scp_helpers.R | code/data/palette_list.rda | verified | `verify/runtime-portability.json` |
| 2026-10-22-scp-example__fig12-venn--venn | standalone | R: dplyr, ggplot2, ggrepel, rlang, ggVennDiagram, sf, jsonlite | R: svglite | code/core.R; code/data/palette_list.rda; code/panel.R; code/render.R; code/scp_helpers.R; code/scp_venn_native.R | code/data/palette_list.rda | verified | `verify/runtime-portability.json` |
| 2026-10-22-scp-example__fig13-upset--upset | standalone | R: dplyr, ggplot2, ggrepel, rlang, ggupset, jsonlite | R: svglite | code/core.R; code/data/palette_list.rda; code/panel.R; code/render.R; code/scp_helpers.R; code/scp_upset_native.R | code/data/palette_list.rda | verified | `verify/runtime-portability.json` |
| 2026-10-22-scp-example__fig14-feature-heatmap--heatmap | standalone | R: ComplexHeatmap, circlize, grid, gtable, patchwork, ggplot2, jsonlite | R: svglite | code/core.R; code/data/palette_list.rda; code/panel.R; code/render.R; code/scp_feature_heatmap_native.R; code/scp_helpers.R; code/sizing.R | code/data/palette_list.rda | verified | `verify/runtime-portability.json` |
| 2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap | standalone | R: ComplexHeatmap, circlize, dplyr, ggplot2, grid, gtable, patchwork, rlang, scales, Seurat, jsonlite | R: svglite | code/core.R; code/data/palette_list.rda; code/panel.R; code/render.R; code/scp_cell-cor-heatmap_native.R; code/scp_helpers.R; code/sizing.R | code/data/palette_list.rda | verified | `verify/runtime-portability.json` |
| 2026-10-22-scp-example__fig16-cell-density--ridge | standalone | R: dplyr, ggplot2, patchwork, rlang, ggridges, SeuratObject, methods, jsonlite | R: svglite | code/core.R; code/data/palette_list.rda; code/panel.R; code/render.R; code/scp_cell-density_native.R; code/scp_helpers.R | code/data/palette_list.rda | verified | `verify/runtime-portability.json` |

## 上游函数与兼容改动

### cell-quality-control / scp-runcellqc
- 旧入口：`code/analysis.R` 的 `load_scp_engine(bundle)` 整库加载；旧实现保留在 `before/` 与 Git 历史。
- 新入口：`code/analysis.R:run_cell_quality_control`
- 上游函数：R/SCP-cellqc.R:RunCellQC；R/SCP-cellqc.R:RunDoubletCalling；R/SCP-cellqc.R:db_scDblFinder；R/SCP-cellqc.R:db_scds；R/SCP-cellqc.R:db_Scrublet；R/SCP-cellqc.R:db_DoubletDetection
- 兼容改动：check_R/check_Python replaced with fail-only guards；SeuratObject >= 5 GetAssayData/Assays compatibility shims；compiled asMatrix helper excluded; its only call is unreachable in upstream as_matrix

### doublet-detection / scp-rundoublet
- 旧入口：`code/analysis.R` 的 `load_scp_engine(bundle)` 整库加载；旧实现保留在 `before/` 与 Git 历史。
- 新入口：`code/analysis.R:run_doublet_detection`
- 上游函数：R/SCP-cellqc.R:RunDoubletCalling；R/SCP-cellqc.R:db_scDblFinder；R/SCP-cellqc.R:db_scds；R/SCP-cellqc.R:db_Scrublet；R/SCP-cellqc.R:db_DoubletDetection
- 兼容改动：check_R/check_Python replaced with fail-only guards；SeuratObject >= 5 compatibility shim；compiled asMatrix helper excluded; unreachable upstream call

### dimensionality-reduction / scp-dimreduction
- 旧入口：`code/analysis.R` 的 `load_scp_engine(bundle)` 整库加载；旧实现保留在 `before/` 与 Git 历史。
- 新入口：`code/analysis.R:run_dimensionality_reduction`
- 上游函数：R/SCP-workflow.R:RunDimReduction；R/Seurat-function.R:RunUMAP2；R/Seurat-function.R:RunNMF；R/Seurat-function.R:RunGLMPCA；R/Seurat-function.R:RunMDS；R/Seurat-function.R:RunDM；R/Seurat-function.R:RunPHATE；R/Seurat-function.R:RunPaCMAP；R/Seurat-function.R:RunTriMap；R/Seurat-function.R:RunLargeVis；R/Seurat-function.R:RunFR
- 兼容改动：check_R/check_Python replaced with fail-only guards；SeuratObject >= 5 GetAssayData compatibility shim；compiled asMatrix helper excluded; unreachable upstream call

### batch-integration / scp-seurat
- 旧入口：`code/analysis.R` 的 `load_scp_engine(bundle)` 整库加载；旧实现保留在 `before/` 与 Git 历史。
- 新入口：`code/analysis.R:run_seurat_integration`
- 上游函数：R/SCP-workflow.R:Seurat_integrate；R/SCP-workflow.R:Harmony_integrate；R/SCP-workflow.R:RunDimReduction；R/Seurat-function.R:RunUMAP2；R/Seurat-function.R:RunHarmony2
- 兼容改动：check_R/check_Python replaced with fail-only guards；SeuratObject >= 5 GetAssayData compatibility shim；compiled asMatrix helper excluded; unreachable upstream call

### batch-integration / scp-harmony
- 旧入口：`code/analysis.R` 的 `load_scp_engine(bundle)` 整库加载；旧实现保留在 `before/` 与 Git 历史。
- 新入口：`code/analysis.R:run_batch_integration`
- 上游函数：R/SCP-workflow.R:Seurat_integrate；R/SCP-workflow.R:Harmony_integrate；R/SCP-workflow.R:RunDimReduction；R/Seurat-function.R:RunUMAP2；R/Seurat-function.R:RunHarmony2
- 兼容改动：check_R/check_Python replaced with fail-only guards；SeuratObject >= 5 GetAssayData compatibility shim；compiled asMatrix helper excluded; unreachable upstream call

### cell-type-annotation / scp-singler
- 旧入口：`code/analysis.R` 的 `load_scp_engine(bundle)` 整库加载；旧实现保留在 `before/` 与 Git 历史。
- 新入口：`code/analysis.R:run_cell_type_annotation`
- 上游函数：R/SCP-cell_annotation.R:RunSingleR
- 兼容改动：check_R replaced with a fail-only guard；SeuratObject >= 5 GetAssayData compatibility shim

### differential-expression / scp-detest
- 旧入口：`code/analysis.R` 的 `load_scp_engine(bundle)` 整库加载；旧实现保留在 `before/` 与 Git 历史。
- 新入口：`code/analysis.R:run_differential_expression`
- 上游函数：R/SCP-analysis.R:RunDEtest
- 兼容改动：SeuratObject >= 5 Assays/GetAssayData compatibility shims

### gene-set-enrichment / scp-enrichment
- 旧入口：`code/analysis.R` 的 `load_scp_engine(bundle)` 整库加载；旧实现保留在 `before/` 与 Git 历史。
- 新入口：`code/analysis.R:run_gene_set_enrichment`
- 上游函数：R/SCP-analysis.R:RunEnrichment；R/SCP-analysis.R:PrepareDB；R/SCP-analysis.R:GeneConvert
- 兼容改动：check_R replaced with a fail-only guard；network/database branches require the corresponding local packages; no installation

### gene-set-scoring / scp-cellscoring
- 旧入口：`code/analysis.R` 的 `load_scp_engine(bundle)` 整库加载；旧实现保留在 `before/` 与 Git 历史。
- 新入口：`code/analysis.R:run_gene_set_scoring`
- 上游函数：R/SCP-analysis.R:CellScoring；R/SCP-analysis.R:AddModuleScore2
- 兼容改动：check_R replaced with a fail-only guard；SeuratObject >= 5 GetAssayData compatibility shim

### trajectory-inference / scp-slingshot
- 旧入口：`code/analysis.R` 的 `load_scp_engine(bundle)` 整库加载；旧实现保留在 `before/` 与 Git 历史。
- 新入口：`code/analysis.R:run_trajectory_inference`
- 上游函数：R/SCP-analysis.R:RunSlingshot
- 兼容改动：SCP::palette_list replaced with the local palette_list loaded from code/data/palette_list.rda；check_R replaced with a fail-only guard；SeuratObject >= 5 GetAssayData/Assays compatibility shims；Monocle2/3: RunMonocle2/3 split into analysis core, Seurat adapter and optional plot; plotting/interactive root selection removed from the core; root/partition must be explicit

### trajectory-inference / scp-monocle2
- 旧入口：原 `RunMonocle2`/`RunMonocle3` 只在完整 SCP bundle 中调用；本轮从固定源码拆分为 core / Seurat adapter / plot 分支。
- 新入口：`code/monocle2.R:run_trajectory_monocle2`
- 上游函数：R/SCP-analysis.R:RunMonocle2
- 兼容改动：SCP::palette_list replaced with the local palette_list loaded from code/data/palette_list.rda；check_R replaced with a fail-only guard；SeuratObject >= 5 GetAssayData/Assays compatibility shims；Monocle2/3: RunMonocle2/3 split into analysis core, Seurat adapter and optional plot; plotting/interactive root selection removed from the core; root/partition must be explicit

### trajectory-inference / scp-monocle3
- 旧入口：原 `RunMonocle2`/`RunMonocle3` 只在完整 SCP bundle 中调用；本轮从固定源码拆分为 core / Seurat adapter / plot 分支。
- 新入口：`code/monocle3.R:run_trajectory_monocle3`
- 上游函数：R/SCP-analysis.R:RunMonocle3
- 兼容改动：SCP::palette_list replaced with the local palette_list loaded from code/data/palette_list.rda；check_R replaced with a fail-only guard；SeuratObject >= 5 GetAssayData/Assays compatibility shims；Monocle2/3: RunMonocle2/3 split into analysis core, Seurat adapter and optional plot; plotting/interactive root selection removed from the core; root/partition must be explicit

### trajectory-inference / scp-monocle2-core
- 旧入口：原 `RunMonocle2`/`RunMonocle3` 只在完整 SCP bundle 中调用；本轮从固定源码拆分为 core / Seurat adapter / plot 分支。
- 新入口：`code/monocle2_core.R:run_monocle2_core`
- 上游函数：R/SCP-analysis.R:RunMonocle2；R/SCP-analysis.R:orderCells；R/SCP-analysis.R:project2MST
- 兼容改动：SCP::palette_list replaced with the local palette_list loaded from code/data/palette_list.rda；check_R replaced with a fail-only guard；SeuratObject >= 5 GetAssayData/Assays compatibility shims；Monocle2/3: RunMonocle2/3 split into analysis core, Seurat adapter and optional plot; plotting/interactive root selection removed from the core; root/partition must be explicit

### trajectory-inference / scp-monocle3-core
- 旧入口：原 `RunMonocle2`/`RunMonocle3` 只在完整 SCP bundle 中调用；本轮从固定源码拆分为 core / Seurat adapter / plot 分支。
- 新入口：`code/monocle3_core.R:run_monocle3_core`
- 上游函数：R/SCP-analysis.R:RunMonocle3
- 兼容改动：SCP::palette_list replaced with the local palette_list loaded from code/data/palette_list.rda；check_R replaced with a fail-only guard；SeuratObject >= 5 GetAssayData/Assays compatibility shims；Monocle2/3: RunMonocle2/3 split into analysis core, Seurat adapter and optional plot; plotting/interactive root selection removed from the core; root/partition must be explicit

### dynamic-feature-analysis / scp-dynamicfeatures
- 旧入口：`code/analysis.R` 的 `load_scp_engine(bundle)` 整库加载；旧实现保留在 `before/` 与 Git 历史。
- 新入口：`code/analysis.R:run_dynamic_feature_analysis`
- 上游函数：R/SCP-analysis.R:RunDynamicFeatures
- 兼容改动：check_R replaced with a fail-only guard；SeuratObject >= 5 GetAssayData compatibility shim

### reference-mapping / seurat-label-transfer
- 旧入口：`code/transfer.R` 本来就是显式 Seurat 调用，不含整库加载器；本轮补独立迁移证据。
- 新入口：`code/transfer.R:run_reference_label_transfer`
- 上游函数：R/SCP-projection.R:FindTransferAnchors；R/SCP-projection.R:TransferData
- 兼容改动：check_R/check_Python replaced with fail-only guards；SeuratObject >= 5 compatibility shims；compiled asMatrix helper excluded; unreachable upstream call

### reference-mapping / scp-runseuratmap
- 旧入口：`code/analysis.R` 的 `load_scp_engine(bundle)` 整库加载；旧实现保留在 `before/` 与 Git 历史。
- 新入口：`code/analysis.R:run_reference_mapping`
- 上游函数：R/SCP-projection.R:RunSeuratMap；R/SCP-projection.R:RunKNNMap
- 兼容改动：check_R/check_Python replaced with fail-only guards；SeuratObject >= 5 compatibility shims；compiled asMatrix helper excluded; unreachable upstream call

### rna-velocity / scp-scvelo
- 旧入口：`code/analysis.R` 的 `load_scp_engine(bundle)` 整库加载；旧实现保留在 `before/` 与 Git 历史。
- 新入口：`code/analysis.R:run_rna_velocity`
- 上游函数：R/SCP-analysis.R:RunSCVELO
- 兼容改动：SCP::palette_list replaced with the local palette_list loaded from code/data/palette_list.rda；check_R/check_Python replaced with fail-only guards

