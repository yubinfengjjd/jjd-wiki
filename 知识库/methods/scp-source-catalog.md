---
type: method
id: scp-source-catalog
title: 单细胞全库来源与入口索引
status: draft
favorite: false
method_kind: technical
tags:
- single-cell
- transcriptomics
keywords:
- SCP
- 全库
- 入库
- 来源
- 原生绘图
- '%>%'
- '%||%'
- AnnotateFeatures
- BBKNN_integrate
- CC_GenePrefetch
- CSS_integrate
- CellCorHeatmap
- CellDensityPlot
- CellDimPlot
- CellDimPlot3D
- CellScoring
- CellStatPlot
- ComBat_integrate
- Conos_integrate
- CreateDataFile
- CreateMetaFile
- DefaultReduction
- DynamicHeatmap
- DynamicPlot
- EnrichmentPlot
- Env_requirements
- FeatureCorPlot
- FeatureDimPlot
- FeatureDimPlot3D
- FeatureHeatmap
- FeatureStatPlot
- FetchH5
- FindExpressedMarkers
- GSEAPlot
- GeneConvert
- GraphPlot
- GroupHeatmap
- Harmony_integrate
- Integration_SCP
- LIGER_integrate
- LineagePlot
- ListDB
- MNN_integrate
- PAGAPlot
- PrepareDB
- PrepareEnv
- PrepareSCExplorer
- ProjectionPlot
- RecoverCounts
- RenameClusters
- RenameFeatures
- RunCSSMap
- RunCellQC
- RunDEtest
- RunDM
- RunDimReduction
- RunDoubletCalling
- RunDynamicEnrichment
- RunDynamicFeatures
- RunEnrichment
- RunFR
- RunGLMPCA
- RunGSEA
- RunHarmony2
- RunKNNMap
- RunKNNPredict
- RunLargeVis
- RunMDS
- RunMonocle2
- RunMonocle3
- RunNMF
- RunPAGA
- RunPCAMap
- RunPHATE
- RunPaCMAP
- RunPalantir
- RunSCExplorer
- RunSCVELO
- RunScmap
- RunSeuratMap
- RunSingleR
- RunSlingshot
- RunSymphonyMap
- RunTriMap
- RunUMAP2
- RunWOT
- Scanorama_integrate
- Seurat_integrate
- SrtAppend
- SrtReorder
- Standard_SCP
- StatPlot
- Uncorrected_integrate
- VelocityPlot
- VolcanoPlot
- adata_to_srt
- adjcolors
- arrow
- as_matrix
- blendcolors
- capitalize
- check_DataType
- check_Python
- check_R
- check_srtList
- check_srtMerge
- compute_velocity_on_grid
- db_DoubletDetection
- db_Scrublet
- db_scDblFinder
- db_scds
- download
- drop_data
- exist_Python_pkgs
- fastMNN_integrate
- find_conda
- geom_alluvial
- geom_alluvial_label
- geom_alluvial_text
- geom_sankey
- geom_sankey_bump
- geom_sankey_label
- geom_sankey_text
- get_vars
- gpar
- installed_Python_pkgs
- invoke
- isOutlier
- iterchunks
- make_long
- palette_scp
- panel_fix
- panel_fix_overall
- scVI_integrate
- segementsDf
- show_palettes
- slim_data
- srt_to_adata
- theme_alluvial
- theme_blank
- theme_sankey
- theme_sankey_bump
- theme_scp
- tochunks
- try_get
- unit
- unnest
inputs: []
outputs: []
source:
  kind: written
license: GPL-3.0-or-later
cite:
- SCP 0.5.6, Hao Zhang, https://github.com/zhanghao-njmu/SCP/tree/b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0
summary: 142 个导出及 238 个源码定义的逐项来源核对；链接规范家族与 22 个 draft 原生绘图入口，区分归档、运行和确认。
data_contract:
  input: 固定 commit 的 NAMESPACE、R AST、Rd、依赖声明及本机当前方法清单；只读审计。
  output: 逐导出来源、文档、规范页、候选模块、helper 消费者和验证范围索引；不产生科学结果。
---
# 单细胞全库来源与入口索引

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：GPL-3.0-or-later
- 引用：SCP 0.5.6, Hao Zhang, https://github.com/zhanghao-njmu/SCP/tree/b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0
- 标签：single-cell、transcriptomics
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 用途

接续 SCP 0.5.6 全库入库：固定 commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`，核对快照全部受 Git 管理的文件，再独立解析 NAMESPACE、238 个 R 顶层定义和 142 份 Rd。142 个导出各占一条主记录，22 个原生绘图入口各有对象输入与对应技术页。

这是一份 technical 来源索引。当前 rwiki 来源适配器只支持 FigureYa Rmd，SCP 是 R 包；没有冒用 FigureYa 适配器、伪造 L0 项或把 R 文件当作 Rmd 配方。已有拆分代码按已完成成果保留，不再批量开发新 L2。

## 适用

按函数名查源码/文档、按研究问题找到已有规范分析家族、按上游结果选择原生绘图入口；或检查 helper/环境函数被哪些模块消费。先读对应家族和当前分支收据，再复制到课题。

## 不适用

来源覆盖不等于全库可运行，算法通过不等于独立性通过，draft 不等于作者确认。10 月隔离区的 79 个模块与 286 个分支盘点只作候选线索，不能把旧候选状态、文件存在或 source-only 成功算作当前正式验证。环境/安装器与 reexport 不作为科研分析方法。

## 输入

原始层为 `<sources_root>/scp-2026-10-22`，继续保持只读。每个入口的源文件、定义行号、Rd 和 SHA-256 见本页资产 `inventory.json`；该 JSON 不含源码函数体、课题数据或密钥。历史 Windows 检出有 174 个文件仅 CRLF/LF 与 Git blob 不同：分别记录实际文件与 Git blob 的哈希，不将二者冒称原字节相同，不改原始层换行。其余文件逐字节一致，未发现其他内容差异。输入/统计单位按对应规范家族或绘图技术页分别核对。

## 怎么做

1. 已知函数名时用 `rwiki find <函数名> --kind method`；按研究场景找模板时用 `rwiki find <分析目的>` → `rwiki show <规范家族/绘图技术页>`。原生绘图页按入口、参数形态和收据判断；CSV 数据走既有模板。
已知函数名加 `--kind method` 可避免默认图型/领域扩展把相近的已验证表格模板排在原生入口之前。

2. 规范家族已有可用实现时优先复用其清单；`inventory.json` 中 candidate 字段只说明旧隔离成果去向，不能直接当作已入库实现。
3. 原生绘图可 `rwiki use <绘图技术页 id> --project <课题目录>`；在副本中选对应 runtime.json 分支并调用。对象缺 assay/降维/上游结果时先解决输入契约，不补造结果。
4. 首次使用某分析分支才做必要提炼/验证；缺包按批次列清单交作者，变更统计逻辑先确认。使用记录仍须作者确认后写。

### 原生绘图入口

| 入口 | 技术页 | 当前算法收据范围 | 状态 |
|---|---|---|---|
| `CellCorHeatmap` | [[methods/scp-viz-heatmaps]] | 无通过范围 | not_run / draft |
| `CellDensityPlot` | [[methods/scp-viz-dimplots]] | f_x_order_rank | verified / draft |
| `CellDimPlot` | [[methods/scp-viz-dimplots]] | mark_circle | verified / draft |
| `CellDimPlot3D` | [[methods/scp-viz-dimplots]] | cell_3d | verified / draft |
| `CellStatPlot` | [[methods/scp-viz-statplots]] | f_plot_type_upset | verified / draft |
| `DynamicHeatmap` | [[methods/scp-viz-heatmaps]] | f_exp_method_raw | verified / draft |
| `DynamicPlot` | [[methods/scp-viz-model-overlays]] | native_curve | verified / draft |
| `EnrichmentPlot` | [[methods/scp-viz-model-overlays]] | positive_native_material | verified / draft |
| `FeatureCorPlot` | [[methods/scp-viz-statplots]] | two_markers | verified / draft |
| `FeatureDimPlot` | [[methods/scp-viz-dimplots]] | keep_all | verified / draft |
| `FeatureDimPlot3D` | [[methods/scp-viz-dimplots]] | feature_3d | verified / draft |
| `FeatureHeatmap` | [[methods/scp-viz-heatmaps]] | default | verified / draft |
| `FeatureStatPlot` | [[methods/scp-viz-statplots]] | f_add_stat_mean | verified / draft |
| `GSEAPlot` | [[methods/scp-viz-model-overlays]] | positive_native_material | verified / draft |
| `GraphPlot` | [[methods/scp-viz-model-overlays]] | real_curved | verified / draft |
| `GroupHeatmap` | [[methods/scp-viz-heatmaps]] | annotation | verified / draft |
| `LineagePlot` | [[methods/scp-viz-model-overlays]] | positive_native_material | verified / draft |
| `PAGAPlot` | [[methods/scp-viz-model-overlays]] | 无通过范围 | not_run / draft |
| `ProjectionPlot` | [[methods/scp-viz-model-overlays]] | self_projection | verified / draft |
| `StatPlot` | [[methods/scp-viz-statplots]] | f_position_dodge | verified / draft |
| `VelocityPlot` | [[methods/scp-viz-model-overlays]] | velocity_umap | not_run / draft |
| `VolcanoPlot` | [[methods/scp-viz-statplots]] | positive_native_material | verified / draft |

### 分析入口

| 导出 | 原始定义/文档 | 规范页或去向 |
|---|---|---|
| `CellScoring` | `R/SCP-analysis.R:731` | [[methods/gene-set-scoring]] |
| `FindExpressedMarkers` | `R/SCP-analysis.R:1229` | [[methods/differential-expression]] |
| `RecoverCounts` | `R/SCP-workflow.R:420` | 候选 `count-recovery`；尚未合入 |
| `RunCSSMap` | `R/SCP-projection.R:471` | [[methods/reference-mapping]] |
| `RunCellQC` | `R/SCP-cellqc.R:314` | [[methods/cell-quality-control]] |
| `RunDEtest` | `R/SCP-analysis.R:1671` | [[methods/differential-expression]] |
| `RunDimReduction` | `R/SCP-workflow.R:781` | [[methods/dimensionality-reduction]] |
| `RunDoubletCalling` | `R/SCP-cellqc.R:180` | [[methods/doublet-detection]] |
| `RunDynamicEnrichment` | `R/SCP-analysis.R:5218` | [[methods/dynamic-feature-analysis]] |
| `RunDynamicFeatures` | `R/SCP-analysis.R:4948` | [[methods/dynamic-feature-analysis]] |
| `RunEnrichment` | `R/SCP-analysis.R:3766` | [[methods/gene-set-enrichment]] |
| `RunGSEA` | `R/SCP-analysis.R:4030` | [[methods/gene-set-enrichment]] |
| `RunHarmony2` | `R/Seurat-function.R:1787` | [[methods/batch-integration]] |
| `RunKNNMap` | `R/SCP-projection.R:43` | [[methods/reference-mapping]] |
| `RunKNNPredict` | `R/SCP-cell_annotation.R:98` | [[methods/cell-type-annotation]] |
| `RunMonocle2` | `R/SCP-analysis.R:4410` | [[methods/trajectory-inference]] |
| `RunMonocle3` | `R/SCP-analysis.R:4745` | [[methods/trajectory-inference]] |
| `RunPAGA` | `R/SCP-analysis.R:5785` | [[methods/trajectory-inference]] |
| `RunPCAMap` | `R/SCP-projection.R:281` | [[methods/reference-mapping]] |
| `RunPalantir` | `R/SCP-analysis.R:6001` | [[methods/trajectory-inference]] |
| `RunSCVELO` | `R/SCP-analysis.R:5895` | [[methods/rna-velocity]] |
| `RunScmap` | `R/SCP-cell_annotation.R:527` | [[methods/cell-type-annotation]] |
| `RunSeuratMap` | `R/SCP-projection.R:382` | [[methods/reference-mapping]] |
| `RunSingleR` | `R/SCP-cell_annotation.R:655` | [[methods/cell-type-annotation]] |
| `RunSlingshot` | `R/SCP-analysis.R:4307` | [[methods/trajectory-inference]] |
| `RunSymphonyMap` | `R/SCP-projection.R:565` | [[methods/reference-mapping]] |
| `RunWOT` | `R/SCP-analysis.R:6086` | [[methods/trajectory-inference]] |

### 具名算法后端

| 导出 | 原始定义/文档 | 规范页或去向 |
|---|---|---|
| `BBKNN_integrate` | `R/SCP-workflow.R:2541` | [[methods/batch-integration]] |
| `CSS_integrate` | `R/SCP-workflow.R:2765` | [[methods/batch-integration]] |
| `ComBat_integrate` | `R/SCP-workflow.R:3395` | [[methods/batch-integration]] |
| `Conos_integrate` | `R/SCP-workflow.R:3183` | [[methods/batch-integration]] |
| `Harmony_integrate` | `R/SCP-workflow.R:2140` | [[methods/batch-integration]] |
| `LIGER_integrate` | `R/SCP-workflow.R:2971` | [[methods/batch-integration]] |
| `MNN_integrate` | `R/SCP-workflow.R:1762` | [[methods/batch-integration]] |
| `RunDM` | `R/Seurat-function.R:458` | [[methods/dimensionality-reduction]] |
| `RunFR` | `R/Seurat-function.R:1678` | [[methods/dimensionality-reduction]] |
| `RunGLMPCA` | `R/Seurat-function.R:323` | [[methods/dimensionality-reduction]] |
| `RunLargeVis` | `R/Seurat-function.R:1550` | [[methods/dimensionality-reduction]] |
| `RunMDS` | `R/Seurat-function.R:187` | [[methods/dimensionality-reduction]] |
| `RunNMF` | `R/Seurat-function.R:27` | [[methods/dimensionality-reduction]] |
| `RunPHATE` | `R/Seurat-function.R:1280` | [[methods/dimensionality-reduction]] |
| `RunPaCMAP` | `R/Seurat-function.R:1151` | [[methods/dimensionality-reduction]] |
| `RunTriMap` | `R/Seurat-function.R:1431` | [[methods/dimensionality-reduction]] |
| `RunUMAP2` | `R/Seurat-function.R:579` | [[methods/dimensionality-reduction]] |
| `Scanorama_integrate` | `R/SCP-workflow.R:2348` | [[methods/batch-integration]] |
| `Seurat_integrate` | `R/SCP-workflow.R:1276` | [[methods/batch-integration]] |
| `Uncorrected_integrate` | `R/SCP-workflow.R:1092` | [[methods/batch-integration]] |
| `compute_velocity_on_grid` | `R/SCP-plot.R:6963` | [[methods/scp-viz-model-overlays]] |
| `db_DoubletDetection` | `R/SCP-cellqc.R:132` | [[methods/doublet-detection]] |
| `db_Scrublet` | `R/SCP-cellqc.R:89` | [[methods/doublet-detection]] |
| `db_scDblFinder` | `R/SCP-cellqc.R:17` | [[methods/doublet-detection]] |
| `db_scds` | `R/SCP-cellqc.R:50` | [[methods/doublet-detection]] |
| `fastMNN_integrate` | `R/SCP-workflow.R:1968` | [[methods/batch-integration]] |
| `isOutlier` | `R/SCP-cellqc.R:238` | [[methods/cell-quality-control]] |
| `scVI_integrate` | `R/SCP-workflow.R:1573` | [[methods/batch-integration]] |

### 原生绘图

| 导出 | 原始定义/文档 | 规范页或去向 |
|---|---|---|
| `CellCorHeatmap` | `R/SCP-plot.R:10113` | [[methods/scp-viz-heatmaps]] |
| `CellDensityPlot` | `R/SCP-plot.R:5679` | [[methods/scp-viz-dimplots]] |
| `CellDimPlot` | `R/SCP-plot.R:1328` | [[methods/scp-viz-dimplots]] |
| `CellDimPlot3D` | `R/SCP-plot.R:2843` | [[methods/scp-viz-dimplots]] |
| `CellStatPlot` | `R/SCP-plot.R:4463` | [[methods/scp-viz-statplots]] |
| `DynamicHeatmap` | `R/SCP-plot.R:11020` | [[methods/scp-viz-heatmaps]] |
| `DynamicPlot` | `R/SCP-plot.R:12102` | [[methods/scp-viz-model-overlays]] |
| `EnrichmentPlot` | `R/SCP-plot.R:12727` | [[methods/scp-viz-model-overlays]] |
| `FeatureCorPlot` | `R/SCP-plot.R:5232` | [[methods/scp-viz-statplots]] |
| `FeatureDimPlot` | `R/SCP-plot.R:2042` | [[methods/scp-viz-dimplots]] |
| `FeatureDimPlot3D` | `R/SCP-plot.R:3066` | [[methods/scp-viz-dimplots]] |
| `FeatureHeatmap` | `R/SCP-plot.R:9114` | [[methods/scp-viz-heatmaps]] |
| `FeatureStatPlot` | `R/SCP-plot.R:3524` | [[methods/scp-viz-statplots]] |
| `GSEAPlot` | `R/SCP-plot.R:13563` | [[methods/scp-viz-model-overlays]] |
| `GraphPlot` | `R/SCP-plot.R:6287` | [[methods/scp-viz-model-overlays]] |
| `GroupHeatmap` | `R/SCP-plot.R:7911` | [[methods/scp-viz-heatmaps]] |
| `LineagePlot` | `R/SCP-plot.R:5918` | [[methods/scp-viz-model-overlays]] |
| `PAGAPlot` | `R/SCP-plot.R:6121` | [[methods/scp-viz-model-overlays]] |
| `ProjectionPlot` | `R/SCP-plot.R:12511` | [[methods/scp-viz-model-overlays]] |
| `StatPlot` | `R/SCP-plot.R:4564` | [[methods/scp-viz-statplots]] |
| `VelocityPlot` | `R/SCP-plot.R:6745` | [[methods/scp-viz-model-overlays]] |
| `VolcanoPlot` | `R/SCP-plot.R:7088` | [[methods/scp-viz-statplots]] |

### 组合流程

| 导出 | 原始定义/文档 | 规范页或去向 |
|---|---|---|
| `Integration_SCP` | `R/SCP-workflow.R:3907` | [[methods/scp-integration]] |
| `Standard_SCP` | `R/SCP-workflow.R:3663` | [[methods/scp-standard-workflow]] |

### helper / 资源辅助

| 导出 | 原始定义/文档 | 规范页或去向 |
|---|---|---|
| `AnnotateFeatures` | `R/SCP-feature_annotation.R:33` | not referenced by any of the 79 extracted module closures; kept as source only (特征 IDtype 注释: symbol/ensembl_id/entrez_id 互转加列) |
| `CC_GenePrefetch` | `R/SCP-analysis.R:472` | not referenced by any of the 79 extracted module closures; kept as source only (细胞周期基因跨物种同源抓取缓存; 需 biomaRt 网络 → not_run(网络)) |
| `DefaultReduction` | `R/SCP-workflow.R:1034` | 随闭包消费：celldimplot, celldimplot3d, featuredimplot, featuredimplot3d 等 |
| `GeneConvert` | `R/SCP-analysis.R:70` | 随闭包消费：cellscoring, dynamicheatmap, featureheatmap, groupheatmap 等 |
| `ListDB` | `R/SCP-analysis.R:2123` | 随闭包消费：cellscoring, dynamicheatmap, featureheatmap, groupheatmap 等 |
| `PrepareDB` | `R/SCP-analysis.R:2243` | 随闭包消费：cellscoring, dynamicheatmap, featureheatmap, groupheatmap 等 |
| `RenameClusters` | `R/SCP-workflow.R:560` | not referenced by any of the 79 extracted module closures; kept as source only (重命名聚类标签 (nameslist/keep_levels)) |
| `RenameFeatures` | `R/SCP-workflow.R:500` | not referenced by any of the 79 extracted module closures; kept as source only (重命名特征 (行列名安全处理)) |
| `SrtAppend` | `R/SCP-workflow.R:692` | 随闭包消费：bbknn-integrate, combat-integrate, conos-integrate, css-integrate 等 |
| `SrtReorder` | `R/SCP-workflow.R:623` | 随闭包消费：bbknn-integrate, combat-integrate, conos-integrate, css-integrate 等 |
| `adata_to_srt` | `R/SCP-analysis.R:5521` | 随闭包消费：runpaga, runpalantir, runscvelo, runwot |
| `adjcolors` | `R/SCP-plot.R:1000` | 随闭包消费：featuredimplot, groupheatmap, runmonocle2, runmonocle3 |
| `as_matrix` | `R/utils.R:831` | 随闭包消费：cellcorheatmap, celldensityplot, celldimplot, cellscoring 等 |
| `blendcolors` | `R/SCP-plot.R:1026` | 随闭包消费：cellcorheatmap, celldimplot, cellstatplot, dynamicheatmap 等 |
| `capitalize` | `R/utils.R:852` | 随闭包消费：cellcorheatmap, celldimplot, cellscoring, cellstatplot 等 |
| `check_DataType` | `R/SCP-workflow.R:14` | 随闭包消费：bbknn-integrate, cellcorheatmap, cellscoring, combat-integrate 等 |
| `check_srtList` | `R/SCP-workflow.R:75` | 随闭包消费：bbknn-integrate, combat-integrate, conos-integrate, css-integrate 等 |
| `check_srtMerge` | `R/SCP-workflow.R:334` | 随闭包消费：bbknn-integrate, combat-integrate, conos-integrate, css-integrate 等 |
| `download` | `R/utils.R:685` | not referenced by any of the 79 extracted module closures; kept as source only (带重试的文件下载 (内部用)) |
| `drop_data` | `R/SCP-plot.R:833` | not referenced by any of the 79 extracted module closures; kept as source only (丢弃 ggplot 内部数据) |
| `geom_alluvial` | `R/ggsankey.R:860` | 随闭包消费：cellcorheatmap, celldimplot, cellstatplot, groupheatmap 等 |
| `geom_alluvial_label` | `R/ggsankey.R:932` | 随闭包消费：cellcorheatmap, celldimplot, cellstatplot, groupheatmap 等 |
| `geom_alluvial_text` | `R/ggsankey.R:907` | 随闭包消费：cellcorheatmap, celldimplot, cellstatplot, groupheatmap 等 |
| `geom_sankey` | `R/ggsankey.R:691` | 随闭包消费：cellcorheatmap, celldimplot, cellstatplot, groupheatmap 等 |
| `geom_sankey_bump` | `R/ggsankey.R:976` | 随闭包消费：cellcorheatmap, celldimplot, cellstatplot, groupheatmap 等 |
| `geom_sankey_label` | `R/ggsankey.R:768` | 随闭包消费：cellcorheatmap, celldimplot, cellstatplot, groupheatmap 等 |
| `geom_sankey_text` | `R/ggsankey.R:805` | 随闭包消费：cellcorheatmap, celldimplot, cellstatplot, groupheatmap 等 |
| `get_vars` | `R/SCP-plot.R:963` | not referenced by any of the 79 extracted module closures; kept as source only (从 ggplot 对象提取变量名) |
| `invoke` | `R/utils.R:767` | 随闭包消费：bbknn-integrate, combat-integrate, conos-integrate, css-integrate 等 |
| `iterchunks` | `R/utils.R:932` | not referenced by any of the 79 extracted module closures; kept as source only (迭代分块) |
| `make_long` | `R/ggsankey.R:70` | 随闭包消费：cellcorheatmap, celldimplot, cellstatplot, groupheatmap 等 |
| `palette_scp` | `R/SCP-plot.R:168` | 随闭包消费：cellcorheatmap, celldensityplot, celldimplot, celldimplot3d 等 |
| `panel_fix` | `R/SCP-plot.R:453` | not referenced by any of the 79 extracted module closures; kept as source only (patchwork panel 尺寸固定) |
| `panel_fix_overall` | `R/SCP-plot.R:588` | 随闭包消费：cellcorheatmap, dynamicheatmap, featureheatmap, groupheatmap 等 |
| `segementsDf` | `R/SCP-plot.R:6666` | 随闭包消费：celldimplot, graphplot, pagaplot, runmonocle2 等 |
| `show_palettes` | `R/SCP-plot.R:298` | 随闭包消费：cellcorheatmap, celldensityplot, celldimplot, celldimplot3d 等 |
| `slim_data` | `R/SCP-plot.R:918` | not referenced by any of the 79 extracted module closures; kept as source only (ggplot 数据瘦身 (大点集抽稀)) |
| `srt_to_adata` | `R/SCP-analysis.R:5351` | 随闭包消费：integration-scp, runpaga, runpalantir, runscvelo 等 |
| `theme_alluvial` | `R/ggsankey.R:155` | 随闭包消费：cellcorheatmap, celldimplot, cellstatplot, groupheatmap 等 |
| `theme_blank` | `R/SCP-plot.R:84` | not referenced by any of the 79 extracted module closures; kept as source only (空白主题 (轨迹/网络图底)) |
| `theme_sankey` | `R/ggsankey.R:124` | 随闭包消费：cellcorheatmap, celldimplot, cellstatplot, groupheatmap 等 |
| `theme_sankey_bump` | `R/ggsankey.R:184` | 随闭包消费：cellcorheatmap, celldimplot, cellstatplot, groupheatmap 等 |
| `theme_scp` | `R/SCP-plot.R:16` | 随闭包消费：cellcorheatmap, celldensityplot, celldimplot, celldimplot3d 等 |
| `tochunks` | `R/utils.R:892` | not referenced by any of the 79 extracted module closures; kept as source only (数据分块) |
| `try_get` | `R/utils.R:647` | 随闭包消费：cellscoring, dynamicheatmap, featureheatmap, groupheatmap 等 |
| `unnest` | `R/utils.R:800` | 随闭包消费：cellscoring, dynamicheatmap, enrichmentplot, featureheatmap 等 |

### 环境与安装辅助

| 导出 | 原始定义/文档 | 规范页或去向 |
|---|---|---|
| `CreateDataFile` | `R/SCP-app.R:20` | 候选 `scp-environment-installers`；尚未合入 |
| `CreateMetaFile` | `R/SCP-app.R:104` | 候选 `scp-environment-installers`；尚未合入 |
| `Env_requirements` | `R/utils.R:144` | 候选 `scp-environment-installers`；尚未合入 |
| `FetchH5` | `R/SCP-app.R:345` | 候选 `scp-environment-installers`；尚未合入 |
| `PrepareEnv` | `R/utils.R:13` | 候选 `scp-environment-installers`；尚未合入 |
| `PrepareSCExplorer` | `R/SCP-app.R:250` | 候选 `scp-environment-installers`；尚未合入 |
| `RunSCExplorer` | `R/SCP-app.R:581` | 候选 `scp-environment-installers`；尚未合入 |
| `check_Python` | `R/utils.R:510` | 候选 `scp-environment-installers`；尚未合入 |
| `check_R` | `R/utils.R:558` | 候选 `scp-environment-installers`；尚未合入 |
| `exist_Python_pkgs` | `R/utils.R:291` | 候选 `scp-environment-installers`；尚未合入 |
| `find_conda` | `R/utils.R:367` | 候选 `scp-environment-installers`；尚未合入 |
| `installed_Python_pkgs` | `R/utils.R:271` | 候选 `scp-environment-installers`；尚未合入 |

### 上游重导出

| 导出 | 原始定义/文档 | 规范页或去向 |
|---|---|---|
| `%>%` | `R/reexports.R` | reexport: dplyr::`%>%` (reexports.R) — upstream re-export, not an SCP implementation |
| `%||%` | `R/reexports.R` | reexport: rlang::`%||%` (reexports.R) — upstream re-export, not an SCP implementation |
| `arrow` | `R/reexports.R` | reexport: grid::arrow (reexports.R) — upstream re-export, not an SCP implementation |
| `gpar` | `R/reexports.R` | reexport: grid::gpar (reexports.R) — upstream re-export, not an SCP implementation |
| `unit` | `R/reexports.R` | reexport: grid::unit (reexports.R) — upstream re-export, not an SCP implementation |

## 代码

整库历史加载器见 [[methods/scp-local-source|源码本地化资料]]；优先使用规范家族的 standalone 清单。原始包、既有拆分闭包和 GPL 派生代码仅存本机。新检出不自动携带这些 ignored 文件：本机恢复须从同 commit 的来源及对应提炼产物核对哈希，不能用最新上游替换后沿用旧收据。

## 输出

本批输出：142 条唯一导出记录、238 个 R 定义核对、22 个绘图契约、4 个 draft 技术页，以及 153 条绘图参数形态的显式证据对应。状态以当前文件计算；不以这些计数宣称全库验收完成。

## 知识关联检查

规范家族沿用质量控制、双细胞检测、批次整合、降维、聚类、差异、富集、签名打分、注释、参考映射、轨迹、速度和动态特征。RunFR 是 Fruchterman–Reingold 图布局；RunLargeVis 使用 R uwot::lvish；PAGA/Palantir/WOT 候选归 trajectory-inference，WOT 需要真实时间字段。GeneConvert/PrepareDB 是函数，不作为包数据。

绘图到 CSV 的关系见 [[methods/scp-visualization-interface]]；同名函数的一个通过用例不授予其余形态状态。还需继续处理原生失败、缺上游结果、逐形态默认参数用例和真实课题适用性。

## 后续方法批次的依赖缺口

当前 Wiki 专用 R 库的包存在性盘点：17 个候选模块有缺项，共 16 个不同的必需 R 包。这不是加载或算法验证，不推断 Python 后端环境，也不把已安装包当作已经跑通。没有执行安装。

| 候选模块 | 缺少的必需 R 包 |
|---|---|
| `css-integrate` | `qlcMatrix`, `simspec` |
| `conos-integrate` | `conos` |
| `harmony-integrate` | `harmony` |
| `liger-integrate` | `rliger` |
| `mnn-integrate` | `batchelor` |
| `runcssmap` | `simspec` |
| `rundm` | `destiny` |
| `runharmony2` | `harmony` |
| `runmonocle2` | `DDRTree`, `monocle` |
| `runmonocle3` | `monocle3` |
| `runnmf` | `RcppML` |
| `runscmap` | `scmap` |
| `runsingler` | `SingleR` |
| `runsymphonymap` | `symphony` |
| `db-scdblfinder` | `scDblFinder` |
| `db-scds` | `scds` |
| `fastmnn-integrate` | `batchelor` |

完整清单见 `dependency-gaps.json`；安装仍需依知识库规则先获作者按批次批准。原生绘图的未验证分支还可能缺上游结果，不能全部归因于缺包。

## 使用记录

2026-11-01：按 v2 接续来源和既有绘图闭包入库；保留旧 id、作者块、状态与原始层，未执行装包或代签核。

<!-- user:start -->
<!-- user:end -->
