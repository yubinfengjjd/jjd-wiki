---
type: method
id: local-omics-analysis-guide
title: 组学课题方法去重与选择
status: draft
tags:
- single-cell
- transcriptomics
- multi-omics
inputs: []
outputs: []
source:
  kind: written
license: LicenseRef-Project-Unresolved
cite:
- 作者指定本机研究来源 uc-ptm（UC-20种修饰）与 asthma-lactylation（哮喘乳酸化单细胞开篇）；2026-11-02 逐文件 SHA-256
  账本，快照 local-omics-2026-11-02；编译说明不替代上游作者和各软件许可。
favorite: false
method_kind: technical
summary: 把两个课题的共同分析映射到现有家族；区分参数、算法分支、工作流和绘图适配，避免按项目重复建方法。
keywords:
- UC-20种修饰
- 哮喘乳酸化单细胞开篇
- 语义去重
- irGSEA
- RRA
- 五分数求和
- hdWGCNA
- WGCNA
- ConsensusClusterPlus
- CellChat
- Augur
- scTenifoldKnk
- GMM-LR
- MBDs
- PTMD
- Mclust
data_contract:
  input: 来源脚本、静态调用、对象/表结构与来源版本；数据和图片留在课题目录。
  output: 来源去重、规范方法映射、依赖绘图/自定义实现与工作流导航；不提供已验证可执行实现。
---
# 组学课题方法去重与选择

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：LicenseRef-Project-Unresolved
- 引用：作者指定本机研究来源 uc-ptm（UC-20种修饰）与 asthma-lactylation（哮喘乳酸化单细胞开篇）；2026-11-02 逐文件 SHA-256 账本，快照 local-omics-2026-11-02；编译说明不替代上游作者和各软件许可。
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

按研究问题、输入语义、统计单位、估计目标和算法边界整理来源；文件名和包名只作线索。规范 analysis 家族数量保持不变。

## 适用

需要从两个课题找方法、判断同义条目、辨别 irGSEA 打分/整合和五分数求和、选择模型/轨迹/网络分支时。

## 不适用

本批仅完成来源归档与知识编译；执行状态为 not_run。未安装依赖、未重跑课题分析、未提炼可执行 L2、未新增 ready，原图不作回放证据。 静态调用归属是候选，未执行函数分派；同名函数可被局部定义、source 或后加载包遮蔽。

## 输入

来源账本含逐文件相对路径、原语言、SHA-256、角色、调用位置及语法检查。数据语义按上游 Seurat、表达矩阵、样本预测、CellChat、空间对象分别阅读；没有因相近列名新造接口。

## 怎么做

先定位 [[methods/uc-ptm-source-catalog]] / [[methods/asthma-lactylation-source-catalog]]；按下表进入现有家族或保留为本页技术知识。后续课题确需执行时再选择具体版本、参数化、写 runtime 与逐分支真实验证；缺包先列批次清单，不自行安装。

## 来源到规范家族对照

| 分析目的 | 来源/实现 | 规范去向 | 判断 |
|---|---|---|---|
| 质控、整合与降维聚类 | 两目录 Seurat/Harmony 单细胞步骤 | cell-quality-control / batch-integration / dimensionality-reduction / cell-clustering | 保留过滤、assay/slot、批次列和 PC/聚类参数；不是新家族，现有实现验证不授予本来源 |
| marker 与参考注释 | UC 15、哮喘 3 | cell-type-annotation | marker 手工标签与 SingleR 参考预测不同实现；绘图不能替代注释证据 |
| bulk/单细胞差异 | limma、FindMarkers/FindAllMarkers | differential-expression | 模型、比较、样本/细胞单位不同；不把 p 值列相同当统计等价 |
| 基因集/通路签名 | UC SCORE/PTMD/空间、哮喘 lactylation/114/MBDs | gene-set-scoring | AddModuleScore/AUCell/UCell/singscore/ssGSEA 是不同实现；五分数求和为特定后处理 |
| irGSEA 多算法打分 | UC 功能/轨迹、哮喘 RCC2/轨迹 | gene-set-scoring | irGSEA.score 为打分入口；不是因为最后出热图就只记作绘图 |
| irGSEA 组间整合与 RRA | 同上 irGSEA.integrate→irGSEA.heatmap | gene-set-enrichment（候选技术来源） | 按 group/Monocle2_State 组织结果；RRA 与五分数直接求和不同；热图消费整合结果 |
| ORA / ranked GSEA | clusterProfiler/GSVA/GseaVis | gene-set-enrichment / gene-set-scoring | 按真实调用区分过度富集、排名富集与逐样本/细胞分数，不能笼统合并 |
| Monocle2 轨迹 | SCP RunMonocle2 / monocle orderCells | trajectory-inference | 新来源的参数/选细胞版本；不继承已验证的 Slingshot 分支 |
| 动态拟合/显示 | DynamicPlotMonocle2、SCP 动态入口 | dynamic-feature-analysis + scp-viz-model-overlays | 自定义 GAM 会重拟合；依赖原图也要逐选项核对是否触发 RunDynamicFeatures |
| 训练/模型组合与评价 | UC/哮喘 GMM-LR、ROC/CV、stacking/DNN | regression-resampling-evaluation（上游来源） | Mclust 对模型 AUC 分组不是细胞聚类；训练与指标汇总是不同范围 |
| 模型解释 | kernelshap/shapviz/LIME、Python explain | shap-explanation | 解释具体模型与数据；SHAP 来源不继承既有线性模型验证，LIME 不当成 SHAP |
| 共表达网络 | bulk WGCNA 与 hdWGCNA metacells | 本页技术导航；尚无规范家族 | 同为共表达目的但输入/单位/聚合不同；两个来源版本不拆成多个同义算法 |
| 一致性分型 | 两目录 ConsensusClusterPlus | 本页技术导航；尚无规范家族 | bulk/签名矩阵样本亚型不等于单细胞图聚类；参数差别是配置 |
| CellChat 通信 | 单细胞主线与 RCTD spot 分支 | 本页技术导航 + uc-spatial-workflows | 共同通信目标，单细胞/spot 输入假设不同；netVisual 是依赖绘图 |
| Augur / scTenifoldKnk | UC 17 原版 / 整理版 | 本页技术导航；尚无规范家族 | 前者细胞类型状态可分性，后者虚拟敲除；不同目标，不能合并或声称实验验证 |
| 免疫推断 / 代谢物 | UC IOBR；哮喘 metabolism.R | 本页技术导航；尚无规范家族 | 免疫分数、比例、代谢物丰度与 RNA 通路分数分别记录 |
| 空间反卷积/域/邻域 | UC 原目录与整理版空间分支 | uc-spatial-workflows | RCTD、BayesSpace、Moran’s I 与 CellTrek 不互换，旧伪超分辨分支保留历史标识 |

逐文件候选映射见 [family-map.json](/files/wiki/methods/local-omics-analysis-guide/family-map.json)。该表保留全部来源及其去向；subset 等通用调用只提供候选线索，不单凭调用自动认定科学目的。

## 字节与语义去重

291 份代码文件共有 242 个不同 SHA-256，49 份冗余字节引用；相同内容只存一个外部快照对象，原目录与各副本路径都保留。不是删除 49 个原文件，也不意味着 242 个方法。现有 Wiki methods/templates 的 .R/.py/.Rmd 未发现与这批完全相同的字节；这不排除语义重复或外部快照已有相同文件。

跨目录完全相同的两组：UC `16.20种修饰量化/1.R`（含整理副本）与哮喘 `4.乳酸化评分/dotplot.R`；UC 整理版 `18.拟时序分析/code/DynamicPlot.R` 与哮喘 `16.细胞轨迹/DynamicPlot.R`。非同字节的整理/投稿版本均保留，并不自动选其为最新版。全部重复组见 [dedup-map.json](/files/wiki/methods/local-omics-analysis-guide/dedup-map.json)。

## 静态核查与明确缺口

130 个可可靠解码的非历史不同字节 R 文件做 parse/getParseData，只解析不求值：129 个语法可解析，1 个 parse_error（哮喘 `8.百种机器学习/14.MLdata/3个/geoML14.MLdata.R` 第 5 行非法反斜杠转义）。`8.百种机器学习/15.ML/refer2.ML.R` 不能可靠解码，保留原字节、不猜编码修稿。Python 只做 AST 解析；notebook 不执行，含输出不当证据。上述检查不是运行或算法验证。

## 代码

原代码与版权见来源页。未新增 code/ 或 implementation 声明；本页 technical，不进入 analysis 执行推荐。静态解析错误保留在清单；未为通过检查而修源、替换算法或合成数据。

## 输出

已有家族的新增来源知识、候选分支选择和原始来源对照；未建立同义 analysis 页、未新增接口直连或 figure_relations。

## 知识关联检查

关联 [[methods/cell-quality-control]]、[[methods/batch-integration]]、[[methods/dimensionality-reduction]]、[[methods/cell-clustering]]、[[methods/cell-type-annotation]]、[[methods/differential-expression]]、[[methods/gene-set-scoring]]、[[methods/gene-set-enrichment]]、[[methods/trajectory-inference]]、[[methods/dynamic-feature-analysis]]、[[methods/regression-resampling-evaluation]]、[[methods/shap-explanation]]；SCP 图形保留 [[methods/scp-viz-dimplots]]、[[methods/scp-viz-statplots]]、[[methods/scp-viz-heatmaps]]、[[methods/scp-viz-model-overlays]]，详见 [[methods/local-omics-visualization-guide]]。无图关系的原因：本批只有来源知识，无新可执行分析输出或验证模板接口，不凭格式相似建立 direct。

## 使用记录

2026-11-02：方法语义审查与来源合并。现有实现、收据、作者块和 ready 状态不改；本页 draft。

<!-- user:start -->
<!-- user:end -->
