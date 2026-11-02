---
type: method
id: scop-workflows
title: 单细胞与空间组学工作流
status: ready
favorite: false
method_kind: workflow
tags:
- single-cell
- transcriptomics
- multi-omics
keywords:
- scop
- SCOP
- Seurat v5
- 空间组学
- AverageExpression
- CellCorHeatmap
- CellDimPlot
- DefaultReduction
- FeatureDimPlot
- ProjectionPlot
- RunKNNMap
- RunKNNPredict
- RunStandardWorkflow
- CellDimPlot
- CellRankPlot
- FeatureDimPlot
- PalantirTrajectoryPlot
- PrepareEnv
- RunCellRank
- RunCellRankEnrichment
- RunCellRankTrends
- RunPalantir
- RunStandardWorkflow
- DEtestPlot
- EnrichmentPlot
- FeatureHeatmap
- GSEAPlot
- GetAssayData5
- RunDEtest
- RunEnrichment
- RunGSEA
- RunStandardWorkflow
- IntegrationBenchmarkPlot
- RunHarmony2
- RunIntegration
- RunIntegrationBenchmark
- CellDimPlot
- FeatureDimPlot
- RunHarmony2
- RunIntegration
- RunStandardWorkflow
- CellDimPlot
- DEtestPlot
- DynamicHeatmap
- EnrichmentPlot
- FeatureDimPlot
- GroupHeatmap
- PrepareSCExplorer
- RunCellQC
- RunDEtest
- RunDynamicFeatures
- RunEnrichment
- RunGRNBoost2
- RunMonocle3
- RunSCENIC
- RunSCVELO
- RunSlingshot
- RunStandardWorkflow
- SCENICPlot
- VelocityPlot
- CellDimPlot
- FeatureDimPlot
- GetAssayData5
- GroupHeatmap
- RunCellQC
- RunStandardWorkflow
- RunIntegrationBenchmark
- RunSpatialBenchmark
- SpatialBenchmarkPlot
- GetAssayData5
- NormalizeData
- SpatialCoordinates
- SpatialSpotPlot
- giotto_to_srt
- spe_to_srt
- srt_to_giotto
- srt_to_spe
- RunRCTD
- RunSPOTlight
- RunSpatialIntegration
- RunStandardWorkflow
- SpatialCellPlot
- SpatialCoordinates
- SpatialDeconvolutionPlot
- SpatialSpotPlot
- SpatialVariableFeaturePlot
- Cell2locationPlot
- GetAssayData5
- NormalizeData
- ReadSpatialData
- RunBayesSpace
- RunCell2location
- RunRCTD
- RunSPOTlight
- RunSpatialIntegration
- RunStandardWorkflow
- SpatialCellPlot
- SpatialCoordinates
- SpatialDeconvolutionPlot
- SpatialIntegrationPlot
- SpatialSpotPlot
- CellDimPlot
- DynamicHeatmap
- DynamicPlot
- FeatureDimPlot
- PAGAPlot
- RunDynamicFeatures
- RunMonocle3
- RunPAGA
- RunSCVELO
- RunSlingshot
- RunStandardWorkflow
- VelocityPlot
inputs: []
outputs: []
source:
  kind: written
license: GPL-3.0-or-later
cite:
- Meng Xu et al. scop 0.9.2. https://github.com/mengxu98/scop/tree/2f44f8c52c247c5a5b42a8a2cb3a7c9800ae24cb
summary: 12 份固定版本上游 Rmd 流程的输入、执行边界和方法链；未 Knit，未作为 L1 配方运行。
data_contract:
  input: 固定 commit 的 scop 源码、Rd、上游数据说明和工作流；本页仅编译知识，未执行分析。
  output: 来源、输入语义、方法/绘图选择与未验证边界；没有本机分析结果或可执行验证授予。
---
# 单细胞与空间组学工作流

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

为单细胞、整合、注释、轨迹、差异富集、空间平台和框架转换选择起点，明确整流程与单步方法的区别。

## 适用

开始规划对象流转和处理步骤；比较单细胞/空间、观测/推断、数据检查/分析结果的边界。

## 不适用

不是本机运行报告或已验证配方。vignette 内已展示的输出、eval=TRUE、上游 CI 不代表本机执行；不要按文档存在推断每个可选后端已跑通。

## 输入

上游提供 pancreas、panc8、multiome、Visium、bulk/参考等 8 个数据文件，均在固定快照中归档。本次未 load 或分析这些数据。换到作者数据时样本单位、物种、基因组、条件和图像标识另核对。

## 怎么做

先 [[methods/scop-source-catalog]] 查依赖和固定版本，再选择下表一个流程。源码 Rmd 不能直接交给当前 FigureYa 配方适配器；本批没有 promote、rwiki run 或 Knit。实际执行前先获批补齐依赖、核对每个分支的资源和安装/联网副作用。

## 流程目录

| 上游流程 | 关键声明入口 | 固定来源 |
|---|---|---|
| 细胞注释与参考映射 | `AverageExpression`、`CellCorHeatmap`、`CellDimPlot`、`DefaultReduction`、`FeatureDimPlot`、`ProjectionPlot`、`RunKNNMap`、`RunKNNPredict` 等 | [`cell-annotation-workflow.Rmd`](https://github.com/mengxu98/scop/blob/2f44f8c52c247c5a5b42a8a2cb3a7c9800ae24cb/vignettes/cell-annotation-workflow.Rmd) |
| CellRank / Palantir 命运分析 | `CellDimPlot`、`CellRankPlot`、`FeatureDimPlot`、`PalantirTrajectoryPlot`、`PrepareEnv`、`RunCellRank`、`RunCellRankEnrichment`、`RunCellRankTrends` 等 | [`cellrank-palantir-fate-workflow.Rmd`](https://github.com/mengxu98/scop/blob/2f44f8c52c247c5a5b42a8a2cb3a7c9800ae24cb/vignettes/cellrank-palantir-fate-workflow.Rmd) |
| 差异与富集 | `DEtestPlot`、`EnrichmentPlot`、`FeatureHeatmap`、`GSEAPlot`、`GetAssayData5`、`RunDEtest`、`RunEnrichment`、`RunGSEA` 等 | [`differential-enrichment-workflow.Rmd`](https://github.com/mengxu98/scop/blob/2f44f8c52c247c5a5b42a8a2cb3a7c9800ae24cb/vignettes/differential-enrichment-workflow.Rmd) |
| 整合评价 | `IntegrationBenchmarkPlot`、`RunHarmony2`、`RunIntegration`、`RunIntegrationBenchmark` | [`integration-benchmark-workflow.Rmd`](https://github.com/mengxu98/scop/blob/2f44f8c52c247c5a5b42a8a2cb3a7c9800ae24cb/vignettes/integration-benchmark-workflow.Rmd) |
| 多样本整合 | `CellDimPlot`、`FeatureDimPlot`、`RunHarmony2`、`RunIntegration`、`RunStandardWorkflow` | [`integration-workflow.Rmd`](https://github.com/mengxu98/scop/blob/2f44f8c52c247c5a5b42a8a2cb3a7c9800ae24cb/vignettes/integration-workflow.Rmd) |
| 胰腺内分泌发育复现 | `CellDimPlot`、`DEtestPlot`、`DynamicHeatmap`、`EnrichmentPlot`、`FeatureDimPlot`、`GroupHeatmap`、`PrepareSCExplorer`、`RunCellQC` 等 | [`reproduce-pancreatic-endocrinogenesis.Rmd`](https://github.com/mengxu98/scop/blob/2f44f8c52c247c5a5b42a8a2cb3a7c9800ae24cb/vignettes/reproduce-pancreatic-endocrinogenesis.Rmd) |
| 单细胞主流程 | `CellDimPlot`、`FeatureDimPlot`、`GetAssayData5`、`GroupHeatmap`、`RunCellQC`、`RunStandardWorkflow` | [`single-cell-main-workflow.Rmd`](https://github.com/mengxu98/scop/blob/2f44f8c52c247c5a5b42a8a2cb3a7c9800ae24cb/vignettes/single-cell-main-workflow.Rmd) |
| 空间分析评价 | `RunIntegrationBenchmark`、`RunSpatialBenchmark`、`SpatialBenchmarkPlot` | [`spatial-benchmark-workflow.Rmd`](https://github.com/mengxu98/scop/blob/2f44f8c52c247c5a5b42a8a2cb3a7c9800ae24cb/vignettes/spatial-benchmark-workflow.Rmd) |
| 空间框架转换 | `GetAssayData5`、`NormalizeData`、`SpatialCoordinates`、`SpatialSpotPlot`、`giotto_to_srt`、`spe_to_srt`、`srt_to_giotto`、`srt_to_spe` | [`spatial-framework-bridges.Rmd`](https://github.com/mengxu98/scop/blob/2f44f8c52c247c5a5b42a8a2cb3a7c9800ae24cb/vignettes/spatial-framework-bridges.Rmd) |
| 空间主流程 | `RunRCTD`、`RunSPOTlight`、`RunSpatialIntegration`、`RunStandardWorkflow`、`SpatialCellPlot`、`SpatialCoordinates`、`SpatialDeconvolutionPlot`、`SpatialSpotPlot` 等 | [`spatial-main-workflow.Rmd`](https://github.com/mengxu98/scop/blob/2f44f8c52c247c5a5b42a8a2cb3a7c9800ae24cb/vignettes/spatial-main-workflow.Rmd) |
| 空间平台与输入 | `Cell2locationPlot`、`GetAssayData5`、`NormalizeData`、`ReadSpatialData`、`RunBayesSpace`、`RunCell2location`、`RunRCTD`、`RunSPOTlight` 等 | [`spatial-platform-workflows.Rmd`](https://github.com/mengxu98/scop/blob/2f44f8c52c247c5a5b42a8a2cb3a7c9800ae24cb/vignettes/spatial-platform-workflows.Rmd) |
| 轨迹与动态特征 | `CellDimPlot`、`DynamicHeatmap`、`DynamicPlot`、`FeatureDimPlot`、`PAGAPlot`、`RunDynamicFeatures`、`RunMonocle3`、`RunPAGA` 等 | [`trajectory-dynamic-workflow.Rmd`](https://github.com/mengxu98/scop/blob/2f44f8c52c247c5a5b42a8a2cb3a7c9800ae24cb/vignettes/trajectory-dynamic-workflow.Rmd) |

## 代码

vignettes/ 原字节及每份 SHA-256 留在来源快照；workflows.json 的 declared_calls 是静态声明的函数引用，不是已执行调用链。先确认实际入口和作者输入后再提炼，不批量新建 L2。

## 输出

本次只生成流程导航。后续运行必须分别记录对象/表、参数、输入输出哈希、环境、实际比较与失败原因；不将源示例的科学结果搬作作者结论。

## 知识关联检查

单步选择见 [[methods/scop-analysis-guide]]；结果出图见 [[methods/scop-visualization-guide]]。原 SCP 工作流与新 scop 工作流并存，API/默认参数和层语义不相互继承。

## 使用记录

2026-11-01：归档和编译 12 份上游流程，本机全部 not_run。

## 资料确认记录（2026-11-02）

作者在对话中明确授权 agent 代处理当前“待你确认”队列。本轮核对笔记用途、输入边界、知识关联和现有收据后，经正式批量确认入口记录资料审阅。ready 仅表示本技术/流程资料已确认；不会把未运行、缺依赖、未覆盖参数或其他版本变成已验证，也不代表整个课题或科学有效性验收。正文此前带日期的 draft/来源归档说明为当时历史记录，当前资料状态以前置信息和本次验收记录为准。

<!-- user:start -->
<!-- user:end -->
