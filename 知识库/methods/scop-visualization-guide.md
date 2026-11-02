---
type: method
id: scop-visualization-guide
title: 单细胞与空间绘图入口导航
status: ready
favorite: false
method_kind: technical
tags:
- single-cell
- transcriptomics
- multi-omics
keywords:
- scop
- SCOP
- Seurat v5
- 空间组学
- BranchStreamPlot
- CCCHeatmap
- CCCNetworkPlot
- CCCStatPlot
- CNVPlot
- COMMOTPlot
- Cell2locationPlot
- CellCorHeatmap
- CellDensityPlot
- CellDimPlot
- CellDimPlot3D
- CellOraclePlot
- CellRankPlot
- CellScoringPlot
- CellStatPlot
- ClusterTreePlot
- CoverageTrackPlot
- CytoTRACEPlot
- DEtestManhattanPlot
- DEtestPlot
- DEtestRingPlot
- DeconvolutionPlot
- DimsEstimatePlot
- DorotheaPlot
- DynamicHeatmap
- DynamicPlot
- EnrichmentPlot
- EstimateGenePlot
- EstimateScorePlot
- FeatureCorPlot
- FeatureDimPlot
- FeatureDimPlot3D
- FeatureHeatmap
- FeatureStatPlot
- FerrisWheelPlot
- FitDevoPlot
- GSEAPlot
- GSVAPlot
- GeneImmuneCorPlot
- GroupHeatmap
- IREAPlot
- ImmuneAbundancePlot
- IntegrationBenchmarkPlot
- LineagePlot
- MetaCellPlot
- MetabolismPlot
- MistyRPlot
- NMFHeatmap
- PAGAPlot
- PalantirTrajectoryPlot
- PlotscPagwas
- ProjectionPlot
- ProportionTestPlot
- PseudotimeProjectionPlot
- SCENICPlot
- SCENICPlusPlot
- STdeconvolvePlot
- ScissorPlot
- SpaTalkPlot
- SpatialBenchmarkPlot
- SpatialCellChatPlot
- SpatialCellPlot
- SpatialDMPlot
- SpatialDeconvolutionPlot
- SpatialGradientPlot
- SpatialIntegrationPlot
- SpatialNeighborhoodPlot
- SpatialNetworkPlot
- SpatialSpotPlot
- SpatialVariableFeaturePlot
- StatialKontextualPlot
- TACSPlot
- VECTORPlot
- VelocityPlot
- VolcanoPlot
- scFEABalanceBarPlot
- scFEAHeatmap
- scFEAVolcanoPlot
- scTenifoldKnkPlot
- scTenifoldNetPlot
- tAgePlot
inputs: []
outputs: []
source:
  kind: written
license: GPL-3.0-or-later
cite:
- Meng Xu et al. scop 0.9.2. https://github.com/mengxu98/scop/tree/2f44f8c52c247c5a5b42a8a2cb3a7c9800ae24cb
summary: 81 个 scop 原生绘图入口的图形类别、声明输入与上游结果边界；全部本机未运行，不继承 SCP 图样或回放。
data_contract:
  input: 固定 commit 的 scop 源码、Rd、上游数据说明和工作流；本页仅编译知识，未执行分析。
  output: 来源、输入语义、方法/绘图选择与未验证边界；没有本机分析结果或可执行验证授予。
---
# 单细胞与空间绘图入口导航

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：GPL-3.0-or-later
- 引用：Meng Xu et al. scop 0.9.2. https://github.com/mengxu98/scop/tree/2f44f8c52c247c5a5b42a8a2cb3a7c9800ae24cb
- 标签：single-cell、transcriptomics、multi-omics
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 用途

按对象和已有结果选择 scop 绘图函数。81 个公开绘图名逐项定位，形态和参数以固定版本 Rd 为准；入口数量不等于图样或通过形态数量。

## 适用

已有 Seurat/空间对象或已说明的分析结果，需要选入口、核对依赖和源码，准备后续原生对照。

## 不适用

没有任何 scop 本机回放图或通过用例。旧 SCP 的 69 张回放和 19 个已验证绘图入口不能标作 scop 证据；3D/交互、CPP 后端、Assay5 与空间图像坐标都需实际验证。

## 输入

本页列必需形参只是签名声明，不替代完整语义。对象缺降维、tools 结果、图像、细胞边界、样本或参考时，先补真实上游；不能用占位矩阵替代。

## 怎么做

`rwiki show scop-visualization-guide` → 在下表选函数 → 查其固定 Rd/源码 → 读 [[methods/scop-analysis-guide]] 的上游方法 → 获准补齐依赖后实际调用。本页没有 code/，当前不支持 rwiki use/render 直接出图。

## 绘图入口总表

### 表达、分布与分组

Seurat 表达/降维、元数据或所选分支的矩阵；部分入口会触发上游计算，不能一概视为纯展示。

| 函数 | 必需形参（声明） | 原始定义 / Rd |
|---|---|---|
| `CellDimPlot` | `object`、`group.by` | `R/CellDimPlot.R:485`；`man/CellDimPlot.Rd` |
| `CellDimPlot3D` | `object`、`group.by` | `R/CellDimPlot.R:1996`；`man/CellDimPlot3D.Rd` |
| `FeatureDimPlot` | `object`、`features` | `R/FeatureDimPlot.R:353`；`man/FeatureDimPlot.Rd` |
| `FeatureDimPlot3D` | `object`、`features` | `R/FeatureDimPlot.R:1917`；`man/FeatureDimPlot3D.Rd` |
| `CellDensityPlot` | `object`、`features` | `R/CellDensityPlot.R:54`；`man/CellDensityPlot.Rd` |
| `FeatureStatPlot` | `object`、`stat.by` | `R/FeatureStatPlot.R:329`；`man/FeatureStatPlot.Rd` |
| `CellStatPlot` | `object`、`stat.by` | `R/CellStatPlot.R:292`；`man/CellStatPlot.Rd` |
| `FeatureCorPlot` | `object`、`features` | `R/FeatureCorPlot.R:62`；`man/FeatureCorPlot.Rd` |
| `GroupHeatmap` | `object` | `R/GroupHeatmap.R:263`；`man/GroupHeatmap.Rd` |
| `FeatureHeatmap` | `object` | `R/FeatureHeatmap.R:119`；`man/FeatureHeatmap.Rd` |
| `CellCorHeatmap` | `srt_query` | `R/CellCorHeatmap.R:230`；`man/CellCorHeatmap.Rd` |
| `ClusterTreePlot` | `object` | `R/ClusterTreePlot.R:68`；`man/ClusterTreePlot.Rd` |
| `MetaCellPlot` | `object` | `R/MetaCellPlot.R:68`；`man/MetaCellPlot.Rd` |
| `NMFHeatmap` | `object` | `R/NMFHeatmap.R:74`；`man/NMFHeatmap.Rd` |
| `DimsEstimatePlot` | `object` | `R/DimsEstimate.R:518`；`man/DimsEstimatePlot.Rd` |

### 差异、富集与打分

对应 DE、富集、GSEA、签名、免疫或代谢结果；不同结果表与分数不能互换。

| 函数 | 必需形参（声明） | 原始定义 / Rd |
|---|---|---|
| `VolcanoPlot` | 由分支/结果参数决定 | `R/DEtestPlot.R:1550`；`man/VolcanoPlot.Rd` |
| `DEtestPlot` | 由分支/结果参数决定 | `R/DEtestPlot.R:189`；`man/DEtestPlot.Rd` |
| `DEtestManhattanPlot` | 由分支/结果参数决定 | `R/DEtestPlot.R:1011`；`man/DEtestManhattanPlot.Rd` |
| `DEtestRingPlot` | 由分支/结果参数决定 | `R/DEtestPlot.R:1280`；`man/DEtestRingPlot.Rd` |
| `EnrichmentPlot` | 由分支/结果参数决定 | `R/EnrichmentPlot.R:373`；`man/EnrichmentPlot.Rd` |
| `GSEAPlot` | 由分支/结果参数决定 | `R/GSEAPlot.R:58`；`man/GSEAPlot.Rd` |
| `CellScoringPlot` | `object` | `R/CellScoringPlot.R:111`；`man/CellScoringPlot.Rd` |
| `GSVAPlot` | 由分支/结果参数决定 | `R/GSVAPlot.R:97`；`man/GSVAPlot.Rd` |
| `GeneImmuneCorPlot` | `features` | `R/GeneImmuneCorPlot.R:35`；`man/GeneImmuneCorPlot.Rd` |
| `EstimateScorePlot` | 由分支/结果参数决定 | `R/EstimatePlot.R:29`；`man/EstimateScorePlot.Rd` |
| `EstimateGenePlot` | `features` | `R/EstimatePlot.R:242`；`man/EstimateGenePlot.Rd` |
| `MetabolismPlot` | 由分支/结果参数决定 | `R/MetabolismPlot.R:127`；`man/MetabolismPlot.Rd` |
| `scFEAHeatmap` | `object` | `R/RunscFEA.R:389`；`man/scFEAHeatmap.Rd` |
| `scFEABalanceBarPlot` | `object`、`group.by` | `R/RunscFEA.R:1083`；`man/scFEABalanceBarPlot.Rd` |
| `scFEAVolcanoPlot` | `object`、`group.by` | `R/RunscFEA.R:731`；`man/scFEAVolcanoPlot.Rd` |

### 轨迹、动态、命运与参考映射

对应轨迹、拟时序、动力学、命运概率或参考投影；必须说明具体上游和结果存储位置。

| 函数 | 必需形参（声明） | 原始定义 / Rd |
|---|---|---|
| `LineagePlot` | `object`、`lineages` | `R/LineagePlot.R:45`；`man/LineagePlot.Rd` |
| `PAGAPlot` | `object` | `R/PAGAPlot.R:95`；`man/PAGAPlot.Rd` |
| `VelocityPlot` | `object`、`reduction` | `R/VelocityPlot.R:116`；`man/VelocityPlot.Rd` |
| `DynamicPlot` | `object`、`lineages`、`features` | `R/DynamicPlot.R:101`；`man/DynamicPlot.Rd` |
| `DynamicHeatmap` | `object`、`lineages` | `R/DynamicHeatmap.R:219`；`man/DynamicHeatmap.Rd` |
| `PalantirTrajectoryPlot` | `object` | `R/PalantirTrajectoryPlot.R:73`；`man/PalantirTrajectoryPlot.Rd` |
| `CellRankPlot` | `object` | `R/CellRankPlot.R:50`；`man/CellRankPlot.Rd` |
| `BranchStreamPlot` | `object`、`group.by` | `R/BranchStreamPlot.R:79`；`man/BranchStreamPlot.Rd` |
| `PseudotimeProjectionPlot` | `object`、`reduction`、`time_key` | `R/PseudotimeProjectionPlot.R:83`；`man/PseudotimeProjectionPlot.Rd` |
| `CytoTRACEPlot` | `object` | `R/CytoTRACEPlot.R:45`；`man/CytoTRACEPlot.Rd` |
| `FitDevoPlot` | `object` | `R/RunFitDevo.R:130`；`man/FitDevoPlot.Rd` |
| `VECTORPlot` | `object` | `R/RunVECTOR.R:155`；`man/VECTORPlot.Rd` |
| `ProjectionPlot` | `srt_query`、`srt_ref` | `R/ProjectionPlot.R:54`；`man/ProjectionPlot.Rd` |

### 调控网络与扰动

regulon、网络、TF 活性或计算扰动输出；图像存在不证明调控因果。

| 函数 | 必需形参（声明） | 原始定义 / Rd |
|---|---|---|
| `SCENICPlot` | `object`、`group.by` | `R/SCENICPlot.R:131`；`man/SCENICPlot.Rd` |
| `SCENICPlusPlot` | `object`、`group.by` | `R/SCENICPlusPlot.R:40`；`man/SCENICPlusPlot.Rd` |
| `CellOraclePlot` | `object` | `R/CellOraclePlot.R:27`；`man/CellOraclePlot.Rd` |
| `DorotheaPlot` | `object`、`group.by` | `R/DorotheaPlot.R:161`；`man/DorotheaPlot.Rd` |
| `scTenifoldNetPlot` | `object` | `R/scTenifoldKnkPlot.R:286`；`man/scTenifoldNetPlot.Rd` |
| `scTenifoldKnkPlot` | `object` | `R/scTenifoldKnkPlot.R:85`；`man/scTenifoldKnkPlot.Rd` |

### 细胞通信

方法专属/统一通信结果；网络边、显著性和空间约束按所选方法解释。

| 函数 | 必需形参（声明） | 原始定义 / Rd |
|---|---|---|
| `CCCNetworkPlot` | `object` | `R/CCCNetworkPlot.R:186`；`man/CCCNetworkPlot.Rd` |
| `CCCHeatmap` | `object` | `R/CCCHeatmap.R:182`；`man/CCCHeatmap.Rd` |
| `CCCStatPlot` | `object` | `R/CCCStatPlot.R:197`；`man/CCCStatPlot.Rd` |
| `COMMOTPlot` | `object` | `R/RunCOMMOT.R:467`；`man/COMMOTPlot.Rd` |
| `SpatialCellChatPlot` | `object` | `R/RunSpatialCellChat.R:1361`；`man/SpatialCellChatPlot.Rd` |
| `SpatialDMPlot` | `object` | `R/RunSpatialDM.R:434`；`man/SpatialDMPlot.Rd` |
| `SpaTalkPlot` | `object` | `R/RunSpaTalk.R:540`；`man/SpaTalkPlot.Rd` |

### 空间位置、图与邻域

空间对象/分割边界/坐标与对应结果。SpatialSpotPlot 和 SpatialCellPlot 分别面向 spot 与细胞边界。

| 函数 | 必需形参（声明） | 原始定义 / Rd |
|---|---|---|
| `SpatialSpotPlot` | 由分支/结果参数决定 | `R/SpatialSpotPlot.R:61`；`man/SpatialSpotPlot.Rd` |
| `SpatialCellPlot` | 由分支/结果参数决定 | `R/SpatialCellPlot.R:44`；`man/SpatialCellPlot.Rd` |
| `SpatialIntegrationPlot` | `object` | `R/RunSpatialIntegration.R:197`；`man/SpatialIntegrationPlot.Rd` |
| `SpatialVariableFeaturePlot` | 由分支/结果参数决定 | `R/RunSpatialVariableFeatures.R:680`；`man/SpatialVariableFeaturePlot.Rd` |
| `SpatialGradientPlot` | `object` | `R/RunSpatialGradientFeatures.R:307`；`man/SpatialGradientPlot.Rd` |
| `SpatialNeighborhoodPlot` | `object` | `R/RunSpatialNeighborhood.R:277`；`man/SpatialNeighborhoodPlot.Rd` |
| `SpatialNetworkPlot` | 由分支/结果参数决定 | `R/RunSpatialNetwork.R:399`；`man/SpatialNetworkPlot.Rd` |
| `SpatialBenchmarkPlot` | 由分支/结果参数决定 | `R/SpatialBenchmarkPlot.R:74`；`man/SpatialBenchmarkPlot.Rd` |
| `StatialKontextualPlot` | 由分支/结果参数决定 | `R/RunStatialKontextual.R:330`；`man/StatialKontextualPlot.Rd` |
| `MistyRPlot` | 由分支/结果参数决定 | `R/RunMistyR.R:363`；`man/MistyRPlot.Rd` |

### 反卷积与组成

样本或 spot 的组成/丰度和相应检验；观测单位与结果量纲必须保留。

| 函数 | 必需形参（声明） | 原始定义 / Rd |
|---|---|---|
| `DeconvolutionPlot` | 由分支/结果参数决定 | `R/DeconvolutionPlot.R:62`；`man/DeconvolutionPlot.Rd` |
| `SpatialDeconvolutionPlot` | `object` | `R/SpatialDeconvolutionPlot.R:59`；`man/SpatialDeconvolutionPlot.Rd` |
| `Cell2locationPlot` | `object` | `R/RunCell2location.R:409`；`man/Cell2locationPlot.Rd` |
| `STdeconvolvePlot` | `object` | `R/RunSTdeconvolve.R:228`；`man/STdeconvolvePlot.Rd` |
| `ImmuneAbundancePlot` | 由分支/结果参数决定 | `R/ImmuneAbundancePlot.R:49`；`man/ImmuneAbundancePlot.Rd` |
| `ProportionTestPlot` | `object` | `R/ProportionTestPlot.R:95`；`man/ProportionTestPlot.Rd` |

### 其他特征与评估

相应 CNV、表型、状态、整合评价或 ATAC coverage 等结果；以各入口 Rd 为准。

| 函数 | 必需形参（声明） | 原始定义 / Rd |
|---|---|---|
| `CNVPlot` | `object` | `R/CNVPlot.R:44`；`man/CNVPlot.Rd` |
| `ScissorPlot` | `object` | `R/ScissorPlot.R:118`；`man/ScissorPlot.Rd` |
| `PlotscPagwas` | `object` | `R/RunscPagwas.R:180`；`man/PlotscPagwas.Rd` |
| `IREAPlot` | `object` | `R/IREAPlot.R:26`；`man/IREAPlot.Rd` |
| `TACSPlot` | `object`、`feature1`、`feature2` | `R/TACSPlot.R:89`；`man/TACSPlot.Rd` |
| `tAgePlot` | `object` | `R/tAgePlot.R:46`；`man/tAgePlot.Rd` |
| `FerrisWheelPlot` | 由分支/结果参数决定 | `R/FerrisWheelPlot.R:91`；`man/FerrisWheelPlot.Rd` |
| `IntegrationBenchmarkPlot` | `object` | `R/IntegrationBenchmarkPlot.R:48`；`man/IntegrationBenchmarkPlot.Rd` |
| `CoverageTrackPlot` | `object`、`region` | `R/CoverageTrackPlot.R:32`；`man/CoverageTrackPlot.Rd` |


## 声明调用示例

以下是声明调用形态，当前没有执行，不能当作运行收据：

```r
# 前提：scop 与目标依赖已经获批安装；srt 是已检查的 Seurat 对象
scop::CellDimPlot(srt, group.by = "CellType", reduction = "已有降维名称")

# 空间输入分别核对 spot / cell、图像与原始坐标
scop::SpatialSpotPlot(spatial, group.by = "已有分组列", image = "已有图像名")
scop::SpatialCellPlot(spatial, group.by = "已有细胞分组列")
```

不要 source 单个 R 文件就承诺独立可用：scop 依赖 thisplot、thisutils、包命名空间和部分注册 C++，本批没有拆最小闭包。

## 代码

来源与哈希在 [[methods/scop-source-catalog]]；本页资产 entries.json 是函数与形参索引，不是执行清单或验证收据。旧 SCP 的 StatPlot、GraphPlot 不在 scop 的公开导出中，不直接改前缀迁移。

## 输出

本次只有入口说明与源码/文档定位，没有新图。上游引用或图片仅作来源参考，不作为本机回放，也不复制为新模板。

## 知识关联检查

按研究问题与输入去重；已有 CSV 模板仍按原接口使用，不宣称与 scop 样式/计算等价。scFEA 图形消费的通量结果及附带后端许可另见来源页。

## 使用记录

2026-11-01：81 个公开绘图入口来源整理；全部 not_run。

## 资料确认记录（2026-11-02）

作者在对话中明确授权 agent 代处理当前“待你确认”队列。本轮核对笔记用途、输入边界、知识关联和现有收据后，经正式批量确认入口记录资料审阅。ready 仅表示本技术/流程资料已确认；不会把未运行、缺依赖、未覆盖参数或其他版本变成已验证，也不代表整个课题或科学有效性验收。正文此前带日期的 draft/来源归档说明为当时历史记录，当前资料状态以前置信息和本次验收记录为准。

<!-- user:start -->
<!-- user:end -->
