---
type: method
id: scop-analysis-guide
title: 单细胞与空间分析方法导航
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
- AddModuleScore
- BBKNN_integrate
- CCA_integrate
- CSS_integrate
- CellCycleScoring
- CellScoring
- ComBat_integrate
- Conos_integrate
- Coralysis_integrate
- FindAllMarkers
- FindClusters
- FindExpressedMarkers
- FindMarkers
- FindMultiModalNeighbors
- FindNeighbors
- FindVariableFeatures
- GLUE_integrate
- Harmony5_integrate
- Harmony_integrate
- LIGER_integrate
- MNN_integrate
- MultiMAP_integrate
- NormalizeData
- RPCA_integrate
- RecoverCounts
- RunATACQC
- RunAugur
- RunBANKSY
- RunBayesSpace
- RunCARD
- RunCCA
- RunCCC
- RunCHOIR
- RunCIBERSORT
- RunCNV
- RunCOMMOT
- RunCSIDE
- RunCSSMap
- RunCell2fate
- RunCell2location
- RunCellChat
- RunCellCycle
- RunCellOracle
- RunCellQC
- RunCellRank
- RunCellRankEnrichment
- RunCellRankTrends
- RunCellTypist
- RunCellphoneDB
- RunChromVAR
- RunCisTarget
- RunCoEmbedding
- RunCytoSPACE
- RunCytoTRACE
- RunDEtest
- RunDM
- RunDecontX
- RunDeconvolution
- RunDimsEstimate
- RunDimsReduction
- RunDorothea
- RunDoubletCalling
- RunDoubletDetection
- RunDynamicEnrichment
- RunDynamicFeatures
- RunESTIMATE
- RunEnrichment
- RunFR
- RunFWP
- RunFitDevo
- RunGENIE3
- RunGLMPCA
- RunGNIPLR
- RunGRN
- RunGRNBoost2
- RunGSEA
- RunGSVA
- RunGeneActivity
- RunHarmony2
- RunIREA
- RunIntegration
- RunIntegrationBenchmark
- RunKNNMap
- RunKNNPredict
- RunLIANA
- RunLISI
- RunLabelTransfer
- RunLargeVis
- RunLinkPeaks
- RunMDIC3
- RunMDS
- RunMERINGUE
- RunMetaCell
- RunMetabolism
- RunMilo
- RunMistyR
- RunMonocle2
- RunMonocle3
- RunMotifEnrichment
- RunMultiNichenetr
- RunNMF
- RunNichenetr
- RunPAGA
- RunPCA
- RunPCAMap
- RunPHATE
- RunPaCMAP
- RunPalantir
- RunPermutation
- RunPropeller
- RunProportionTest
- RunRCTD
- RunRareQ
- RunReferenceMapping
- RunSCENIC
- RunSCENICPlus
- RunSCExplorer
- RunSCVELO
- RunSPOTlight
- RunSTdeconvolve
- RunSciBet
- RunScissor
- RunScmap
- RunScrublet
- RunSecAct
- RunSecActCCC
- RunSecActPatternGenes
- RunSecActSignalingPattern
- RunSecActVelocity
- RunSeuratMap
- RunSingleR
- RunSlingshot
- RunSmoothClust
- RunSpaNorm
- RunSpaTalk
- RunSpatialBenchmark
- RunSpatialCellChat
- RunSpatialDM
- RunSpatialEcoTyper
- RunSpatialGradientFeatures
- RunSpatialIntegration
- RunSpatialNeighborhood
- RunSpatialNetwork
- RunSpatialVariableFeatures
- RunSpotQC
- RunSpotSweeper
- RunStandardWorkflow
- RunStatialKontextual
- RunSymphonyMap
- RunTriMap
- RunUMAP
- RunUMAP2
- RunVECTOR
- RunWOT
- RunmcRigor
- RunscCODA
- RunscDblFinder
- RunscFEA
- RunscMalignantFinder
- RunscMalignantRegion
- RunscMalignantStates
- RunscOMM
- RunscPagwas
- RunscTenifoldKnk
- RunscTenifoldNet
- Runscds
- RuntAge
- ScaleData
- Scanorama_integrate
- Seurat_integrate
- TrainCellTypist
- Uncorrected_integrate
- WNN_integrate
- fastMNN5_integrate
- fastMNN_integrate
- integration_scop
- scVI5_integrate
- scVI_integrate
- standard_scop
inputs: []
outputs: []
source:
  kind: written
license: GPL-3.0-or-later
cite:
- Meng Xu et al. scop 0.9.2. https://github.com/mengxu98/scop/tree/2f44f8c52c247c5a5b42a8a2cb3a7c9800ae24cb
summary: 将 scop 候选实现映射到既有 13 个规范家族，并整理通信、调控、空间、ATAC、反卷积等新增领域；2026-11-12 执行矩阵 analysis-entry
  99 pass / 45 not_run、backend 5 pass / 16 not_run。
data_contract:
  input: 固定 commit 的 scop 源码、Rd、上游数据说明和工作流；本页仅编译知识，未执行分析。
  output: 来源、输入语义、方法/绘图选择与未验证边界；没有本机分析结果或可执行验证授予。
---
# 单细胞与空间分析方法导航

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

按研究问题和观测单位选择 scop 候选入口，复用已有规范家族，区分分析、组合流程、对象转换和资源准备。

## 适用

确定新课题可能需要的分析，以及每个候选的对象、单位、上游结果、外部资源和方法边界；优先已有当前验证分支。

## 不适用

这不是新增已验证分析家族或即用实现清单。未审查的 CPP/R/Python 后端、默认参数和上游示例不作为课题科学方案自动执行；不能继承 SCP 数值或独立性收据。

## 输入

按入口区分 Seurat 的细胞×特征、SummarizedExperiment 的样本/伪批量、ATAC peak/cCRE、空间 spot/bin/cell。样本、条件、供体、坐标和基因组信息必须来自真实数据。

## 怎么做

先读下表的规范家族和限制，再查固定版本的 `man/<函数>.Rd` 与对应 R 源文件。明确目的/单位后才在课题环境选分支；默认不运行资源下载、自动安装或改变统计逻辑。

## 已有家族的候选来源

| 已有规范家族 | scop 候选入口 | 关键边界 |
|---|---|---|
| [[methods/cell-quality-control|质量控制]] | `RunCellQC`、`RunATACQC`、`RunSpotQC`、`RunSpotSweeper` | RNA 细胞、ATAC 细胞与空间 spot 的 QC 指标和阈值分开；不能沿用旧 RNA 阈值覆盖其他平台。 |
| [[methods/doublet-detection|双细胞检测]] | `RunDoubletDetection`、`RunDoubletCalling`、`RunscDblFinder`、`RunScrublet`、`Runscds` | 按所选后端核对真实 counts、样本批次和预期双细胞率；不是同一后端的不同名称。 |
| [[methods/batch-integration|批次与多模态整合]] | `RunIntegration`、`Seurat_integrate`、`Harmony_integrate`、`WNN_integrate`、`GLUE_integrate` | 单模态批次校正与 RNA/ATAC 多模态整合的输入、目标不同；每个后端另验。 |
| [[methods/dimensionality-reduction|降维与图布局]] | `RunDimsReduction`、`RunPCA`、`RunUMAP`、`RunLargeVis`、`RunFR` | RunFR 是图布局；低维图相邻不等于生物学相近或完成批次校正。 |
| [[methods/cell-clustering|细胞聚类]] | `FindNeighbors`、`FindClusters`、`RunCHOIR` | 聚类标签不是细胞类型；图构建、分辨率与显著性聚类路径分别核对。 |
| [[methods/differential-expression|差异与伪批量分析]] | `RunDEtest`、`FindMarkers`、`FindAllMarkers` | scop 的 Seurat 和 SummarizedExperiment 方法、细胞级检验和样本级伪批量检验要分开；sample_col/condition_col/design/contrast 不能靠猜测补齐。 |
| [[methods/gene-set-enrichment|富集与调控集分析]] | `RunEnrichment`、`RunGSEA`、`RunDynamicEnrichment` | ORA、GSEA 和动态富集不是同一估计目标；基因背景、排序、物种与 ID 类型需显式确定。 |
| [[methods/gene-set-scoring|基因集与通路打分]] | `CellScoring`、`RunGSVA`、`RunMetabolism` | 各打分方法的量纲和假设不同，不能将分数相加或直接作相同尺度比较。 |
| [[methods/cell-type-annotation|自动注释与分类]] | `RunSingleR`、`RunCellTypist`、`RunScmap`、`RunKNNPredict`、`RunSciBet` | 核对参考物种、基因 ID、标签与查询/参考独立性；相似度不是校准概率。 |
| [[methods/reference-mapping|参考映射与投影]] | `RunReferenceMapping`、`RunLabelTransfer`、`RunSeuratMap`、`RunKNNMap`、`RunPCAMap` | 投影位置、标签转移与批次整合分别解释；同一细胞同时出现在查询和参考中不是独立验证。 |
| [[methods/trajectory-inference|轨迹、命运与真实时间输运]] | `RunSlingshot`、`RunMonocle2`、`RunMonocle3`、`RunPAGA`、`RunPalantir`、`RunCellRank`、`RunWOT` | 拟时序、命运概率、RNA 速度和 WOT 的真实时间输运分别记录；不按 README 章节标题将它们视为同一种算法。 |
| [[methods/rna-velocity|RNA 动力学]] | `RunSCVELO`、`RunCell2fate` | 需要相应 spliced/unspliced 或动力学输入；命运概率不等于速度向量。Python 后端另验。 |
| [[methods/dynamic-feature-analysis|沿轨迹的动态特征]] | `RunDynamicFeatures`、`RunDynamicEnrichment` | 拟时序必须来自已说明的上游；模型 family、counts/归一化层和趋势不确定性分别核对。 |

## 新增领域的选择知识

### 调控网络与扰动

入口：`RunSCENIC`、`RunSCENICPlus`、`RunGRN`、`RunGENIE3`、`RunGRNBoost2`、`RunCisTarget`、`RunDorothea`、`RunCellOracle`、`RunscTenifoldNet`、`RunscTenifoldKnk`。

输入：表达矩阵、候选调控因子；SCENIC 需匹配物种/基因组的 ranking/motif 资源，SCENIC+ 另需多模态输入。

输出与选择：网络边、regulon 活性或计算扰动响应。相关/推断网络不自动构成因果证据；外部数据库及下载单列。

### 细胞通信

入口：`RunCCC`、`RunCellChat`、`RunCellphoneDB`、`RunLIANA`、`RunNichenetr`、`RunMultiNichenetr`、`RunSpatialCellChat`、`RunSpatialDM`、`RunCOMMOT`。

输入：细胞分组、表达及相应配体受体/靶基因资源；部分方法还需对照设计或空间坐标。

输出与选择：方法专属与统一通信结果。LIANA 的默认方法集含 CellPhoneDB scorer，不能把两者当作完全独立证据；空间约束另核对。

### 细胞组成与差异丰度

入口：`RunProportionTest`、`RunMilo`、`RunPropeller`、`RunscCODA`、`RunPermutation`。

输入：细胞类型/分组、条件及真实 sample.by；配对/重复设计按具体后端确定。

输出与选择：比例或差异丰度统计。随机拆分细胞不会产生生物学重复；默认不启用 allow_pseudo_samples。

### bulk / 伪批量反卷积

入口：`RunDeconvolution`、`RunCIBERSORT`。

输入：bulk-like SummarizedExperiment 和与之匹配的参考细胞/供体信息。

输出与选择：样本级细胞组成结果。scop 的 cpp 与原包 r 后端须分别验证；不等同于空间 spot 反卷积。

### 空间域、特征与平台流程

入口：`ReadSpatialData`、`RunStandardWorkflow`、`RunBANKSY`、`RunBayesSpace`、`RunSpatialVariableFeatures`、`RunSpatialGradientFeatures`、`RunSpatialIntegration`、`RunSpaNorm`。

输入：空间 Seurat、图像、表达层、坐标及采集单位；区分 Visium spot、Visium HD bin、Xenium cell。

输出与选择：空间 QC、域、变量特征、梯度或整合结果。原始采集坐标和显示缩放分开，spot 标签不能直接当细胞类型。

### 空间邻域与图

入口：`RunSpatialNetwork`、`RunSpatialNeighborhood`、`RunStatialKontextual`、`RunMistyR`、`RunMERINGUE`。

输入：坐标、标签、样本/受试者信息及所需半径或 k；跨切片边界显式隔离。

输出与选择：邻接图、邻域汇总或差异邻域统计。observed 描述与 spicyR 等推断分开；半径依赖真实坐标单位。

### 空间反卷积

入口：`RunRCTD`、`RunSPOTlight`、`RunCARD`、`RunCell2location`、`RunSTdeconvolve`、`RunCSIDE`、`RunCytoSPACE`。

输入：空间 counts 与相容的单细胞参考，或所选无参考模型的输入；部分后端需 Python/模型资源。

输出与选择：spot 丰度/细胞定位等结果；比例、丰度与单细胞表达不能混用，参考依赖和不确定性需审查。

### ATAC 与多组学

入口：`ReadATACData`、`ReadMultiomeData`、`RunATACQC`、`RunGeneActivity`、`RunChromVAR`、`RunLinkPeaks`、`RunMotifEnrichment`、`RunCoEmbedding`。

输入：fragment、peak/cCRE、基因组版本、基因注释及对应多模态细胞标识。

输出与选择：可及性 QC、基因活性、motif/peak-gene 或联合表示；gene activity 不直接等同实测 RNA 表达。

### CNV、表型与状态

入口：`RunCNV`、`RunScissor`、`RunFWP`、`RunRareQ`、`RunCytoTRACE`、`RunFitDevo`、`RunIREA`、`RunSecAct`、`RuntAge`、`RunscPagwas`。

输入：各自要求的表达/参考、表型、bulk 或 GWAS 等输入；不能仅凭一个 Seurat 对象推定全可用。

输出与选择：CNV、关联细胞、潜能/状态等不同输出。区分表达推断 CNV 与实测 DNA CNV，潜能分数与真实谱系证据分开。

### 代谢活性与通量

入口：`RunMetabolism`、`RunscFEA`。

输入：表达层及相应基因集/代谢网络和物种资源；scFEA 另需 Python 训练环境。

输出与选择：通路活性分数与模型估计通量不是同一量；inst/python/scfea/LICENSE 另附学术非商业限制。


## 代码

逐函数位置与参数在 [[methods/scop-source-catalog]] 的 inventory.json。R/CPP/Python 是不同实现边界；backend="cpp" 的包装、后处理或加速范围按各函数文档核实，不把一种后端等同于原包数值通过。

## 输出

本页输出是候选选择、输入和单位边界，未生成任何统计结果、基因集、网络或新科学结论。

## 知识关联检查

旧 SCP 的已验证分支继续在原规范家族中使用；scop 仅以候选来源互链，不添加 implementations 或覆盖旧代码。绘图结果消费链见 [[methods/scop-visualization-guide]]；12 个上游流程见 [[methods/scop-workflows]]。

## 使用记录

2026-11-01：来源级语义整理，全部 scop 候选未在本机执行。

2026-11-12：scop 装入 Wiki R 库后完成逐导出执行矩阵。按类：analysis-entry 144 个中 99 pass / 45 not_run；analysis-backend 21 个中 5 pass / 16 not_run（多为缺可选后端）；visualization 81 个中 69 pass / 12 not_run。逐条判定见 [[methods/scop-source-catalog]] 的 execution-matrix.json；pass 仅为示例可调用性，不构成规范家族实现或科学验证。

## 资料确认记录（2026-11-02）

作者在对话中明确授权 agent 代处理当前“待你确认”队列。本轮核对笔记用途、输入边界、知识关联和现有收据后，经正式批量确认入口记录资料审阅。ready 仅表示本技术/流程资料已确认；不会把未运行、缺依赖、未覆盖参数或其他版本变成已验证，也不代表整个课题或科学有效性验收。正文此前带日期的 draft/来源归档说明为当时历史记录，当前资料状态以前置信息和本次验收记录为准。

<!-- user:start -->
<!-- user:end -->
