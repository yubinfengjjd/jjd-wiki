---
type: method
id: uc-ptm-workflow
title: 修饰分型与模型分析流程
status: ready
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
method_kind: workflow
summary: 保留来源步骤、参数与分组差异的研究流程；共同分析引用现有家族，所有来源分支未重跑。
keywords:
- uc-ptm
- UC-20种修饰
- 流程
- GMM-LR
- WGCNA
- hdWGCNA
- ConsensusClusterPlus
- CellChat
- irGSEA
- Monocle2
data_contract:
  input: 来源脚本、静态调用、对象/表结构与来源版本；数据和图片留在课题目录。
  output: 来源去重、规范方法映射、依赖绘图/自定义实现与工作流导航；不提供已验证可执行实现。
---
# 修饰分型与模型分析流程

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

bulk 预处理→修饰签名/一致性分型→差异/WGCNA/交集→模型比较及 GMM-LR/stacking→PTMD/表达/免疫/富集；单细胞 QC/整合/聚类→注释→签名打分→功能/轨迹/CellChat；空间分支独立记录。 这是来源工作流索引，不代表所有步骤都按编号串行运行或属于一个已验收课题方案。

## 适用

查明某张图之前需要哪个对象、哪一列分组、哪套基因集合与哪个模型输出；挑选真实课题所需的步骤。

## 不适用

来源归档阶段只编译知识，整份来源脚本执行状态仍为 not_run。未安装依赖、未重跑课题分析、未提炼可执行 L2、未新增 ready，原图不作回放证据。 多段脚本依赖全局对象、硬编码目录、重复重定义和来源已保存对象；不得 source 全文件来试探可运行性。

## 输入

bulk：基因×样本表达、探针/基因映射、队列/批次/表型、独立训练与验证单位；单细胞：Seurat 对象及 counts/data、orig.ident/样本、celltype、基因集；轨迹：选定细胞、拟时序根/特征与状态；模型：样本级预测概率/真实结局与切分；通信：表达对象及分组。缺列不猜映射。

## 怎么做

从 [[methods/uc-ptm-source-catalog]] 的清单定位原字节；用 [[methods/local-omics-analysis-guide]] 找到规范家族，再核对具体实现而不是继承 ready。依赖图走 [[methods/local-omics-visualization-guide]]；UC 空间内容另见 [[methods/uc-spatial-workflows]]。需要实际使用时才按 Wiki v2 提炼最小闭包，确认输入、统计单位与包清单后验证。

## 来源步骤与选择

| 来源模块 | 内容与链路 | 入库判断 |
|---|---|---|
| 1.数据预处理 | GEO 表达、探针注释、批次与表型整理 | bulk 的基因×样本；批次校正和训练/验证切分边界需逐队列核对 |
| 2.20种修饰一致性聚类 | 基因集打分→ConsensusClusterPlus→亚型对照 | 研究对象分型；不与单细胞 FindClusters 合并 |
| 3.bulk-DEGs | limma 差异、火山图与热图 | 差异模型/对比属于上游统计，图形是下游表示 |
| 4.WGCNA | bulk 共表达模块与性状关联 | 不是 hdWGCNA 的 metacell 分支；模块含义与样本单位分开 |
| 5.交集韦恩图 | 基因集合交集及 VennDiagram 调用 | 集合展示，不能单独算分析方法 |
| 6.GMM-LR | 模型 AUC 的 Mclust 分组与 LR 组合、CV 变体、SHAP/LIME | GMM 聚类模型表现而非细胞；主版和 CV 版保持不同来源 |
| 7.20种修饰模型比较 | 不同签名模型和 ROC 比较 | 比较数据、选模和外部验证边界待逐实现核对 |
| 8.深度学习dnn / 整理版 8.stacking | DNN 目录与 Python stacking 打包版 | 不得将 stacking 与 DNN 合成同一实现；src 多为导入适配 |
| 9.PTMD评分 | 签名与 ssGSEA 分数、相关性展示 | PTMD 项目术语保留；不是蛋白修饰实测量 |
| 10.nomo | rms/regplot 列线图及 rmda 决策曲线 | 模型评价/展示资料，不能将历史图当新数据验证 |
| 11.表达差异图与基因ROC | 表达分布、基因 ROC；整理版另有 Python 多队列绘图 | R 和 Python 是实现/展示变体，不新增同义家族 |
| 12.免疫浸润 | IOBR/GSVA 等调用、相关与分组图 | 推断分数/比例取决于具体算法；不能笼统叫实测免疫细胞数 |
| 13.GSEA与GSVA | GSEA、GSVA/ssGSEA 与 GseaVis/enrichplot | ranked GSEA、ORA 与打分须区分 |
| 14.单细胞转录组基本流程 | Seurat→Harmony→降维/邻居/聚类 | 复用现有 QC/整合/降维/聚类家族；整理版含改动，保留差异 |
| 15.单细胞注释 | marker/SingleR、SCP/Seurat/SCpubr/Nebulosa 展示 | 注释与绘图分层；整理版新增热图 helper 不等于新算法 |
| 16.20种修饰量化 | 五种签名分数求和、DotPlotScores | 共用 gene-set-scoring；跨方法尺度、覆盖与缺失需审查 |
| 17.基因功能探究 | Augur、差异、irGSEA；整理版另有 scTenifoldKnk | 预测可分性、集合富集与虚拟敲除不同目标；均未运行 |
| 18.拟时序分析 | SCP RunMonocle2、Mfuzz、irGSEA、动态显示 | Monocle2 不继承库中 Slingshot 验证；整理版含自定义 GAM 图 |
| 19.细胞通讯 | CellChat 及其 netVisual/netAnalysis 图 | 表达驱动的候选通信；整理版与原版参数/后处理分开 |
| 20.空间转录组 / 整理版 20.sptial | 空间主流程、RCTD、BayesSpace、邻域、通信与样本层展示 | 详见空间分支页；原目录、整理主线、legacy 和 RCTD 后处理分开 |

## 统计单位与科学边界

细胞、metacell、spot 与患者/样本不同，细胞水平分组检验不自动构成患者层证据；拟时序不是实测时间；表达驱动的 CellChat 通信和虚拟敲除不是干预实验。乳酸化/代谢/修饰签名是表达分数，不是蛋白修饰或通量实测。多算法分数直接求和保留为课题特定策略，不命名为通用 consensus 标准。模型筛选、GMM 性能分组、批次校正与最终 ROC 必须保留训练/验证的时间顺序与独立样本边界；本批未核验任何临床效能。

## 代码

原代码来源见 [[methods/uc-ptm-source-catalog]]；整理版不是当然的最新版，不同 SHA-256 保留独立版本。只有字节一致的文件合并存储与别名，未归一化行尾或删去注释后宣称同版。

## 输出

流程顺序与依赖对象、方法/图形复用入口以及需要验证的来源分支；不输出课题数据、预测、p 值或成图。

## 知识关联检查

共用 [[methods/gene-set-scoring]]、[[methods/gene-set-enrichment]]、[[methods/differential-expression]]、[[methods/trajectory-inference]] 等已有家族。WGCNA/hdWGCNA、ConsensusClusterPlus、CellChat、虚拟敲除暂存技术选择知识，未批量新建未使用的 L2 家族。

## 使用记录

2026-11-02：来源工作流整理；所有分支 not_run，未代作者确认。

## 代码复用层增量（2026-11-02）

已有函数的独立加载、显式 arguments/bindings、去重代码、源码哈希和逐文件去向集中在 [[methods/local-omics-analysis-guide]]；依赖原生绘图和消费预计算结果的 ROC 绘图在 [[methods/local-omics-visualization-guide]]。请 use 对应代码页，不对本来源/流程页承诺 run/render。532 处函数定义中 448 处可选取，84 处有安装、清理、路径/工作树或连带闭包缺口而隔离。两个代码页的 40 个实现分支中，19 个具有限定用例的当前运行与异目录证据（含 1 个纯环境工具），21 个保留 not_run；另有 4 个既有 SCP 闭包完成课题集成/独立回放，不重复建实现；整份源码、整个课题流程与科学有效性不随之提升。此前“无 code/、未提炼”的说明描述来源归档阶段，本次代码资产集中在上述两页，未复制数据与原图进 Wiki。

## 资料确认记录（2026-11-02）

作者在对话中明确授权 agent 代处理当前“待你确认”队列。本轮核对笔记用途、输入边界、知识关联和现有收据后，经正式批量确认入口记录资料审阅。ready 仅表示本技术/流程资料已确认；不会把未运行、缺依赖、未覆盖参数或其他版本变成已验证，也不代表整个课题或科学有效性验收。正文此前带日期的 draft/来源归档说明为当时历史记录，当前资料状态以前置信息和本次验收记录为准。

<!-- user:start -->
<!-- user:end -->
