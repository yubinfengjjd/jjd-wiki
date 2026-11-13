---
type: method
id: uc-ptm-source-catalog
title: 修饰研究脚本来源索引
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
method_kind: technical
summary: 132 份研究代码、90 个不同字节版本的来源及去重索引；只编译知识，未运行。
keywords:
- uc-ptm
- UC-20种修饰
- 原字节
- 来源索引
- 去重
- SCP
- irGSEA
- CellChat
data_contract:
  input: 来源脚本、静态调用、对象/表结构与来源版本；数据和图片留在课题目录。
  output: 来源去重、规范方法映射、依赖绘图/自定义实现与工作流导航；不提供已验证可执行实现。
---
# 修饰研究脚本来源索引

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

查找作者指定目录中的研究代码、整理副本、历史分支及方法/绘图归属。来源键为 `uc-ptm`；原目录由本机外部快照的 `source-roots.local.json` 解析。

## 适用

定位原脚本与版本、核对对象输入和参数、选择后续要验证的具体分支。

## 不适用

来源归档阶段只编译知识，整份来源脚本执行状态仍为 not_run。未安装依赖、未重跑课题分析、未提炼可执行 L2、未新增 ready，原图不作回放证据。 文件哈希一致只说明字节一致；文件名、目录名、既有 PDF 和脚本里的 PASS 字样不证明科学正确或可迁移。

## 输入

研究代码扩展名 .R/.Rmd/.py/.ipynb/.sh；排除 node_modules、Skill、skills-main、隐藏缓存与 paper-harness。文章、投稿正文、表格数据、对象文件和图片不复制入 Wiki。notebook 只登记原文件哈希，不将输出识别为代码。

## 怎么做

先看 [[methods/uc-ptm-workflow]]；分析去重见 [[methods/local-omics-analysis-guide]]；绘图见 [[methods/local-omics-visualization-guide]]。来源文件逐项记录在 [inventory.json](/files/wiki/methods/uc-ptm-source-catalog/inventory.json)，含相对路径、SHA-256、角色、原语言、编码、canonical 字节别名和静态调用。

## 来源盘点

共 132 份文件、90 个不同 SHA-256；角色数量：active=41、organized-copy=82、historical=9。角色是目录上下文判断，active 仅指非归档目录候选，不表示作者选定科学终版。

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

## 原始层与许可

可解码与未解码的非历史脚本均按原字节保存在 `<sources_root>/local-omics-2026-11-02/objects/<sha256>.<ext>`，同字节共享一份对象。历史导入包与 notebook 原件留在作者项目；清单明确哪些条目只有原目录来源，未声称全目录快照。快照不含项目数据或成图。项目总许可未明确；SCP/irGSEA/CellChat/数据库、基因集和第三方代码各自权利不因作者持有文件而转移。本批不提交原代码、不推送、不把未知许可宣称为开源许可。

## 代码

本页 source.kind=written 仅指 agent 编译说明，原脚本仍归相应作者/上游。没有 code/、运行清单或声明实现，不能对本页调用 use/run/render 来承诺执行。适配器目前仅支持 FigureYa Rmd，未将普通 R/Python 文件伪装成 L0/L1。

## 输出

可检索来源与导航、逐文件来源账本、字节去重与语义归属；没有新运行收据、图像回放或科学结果。

## 知识关联检查

[[methods/local-omics-analysis-guide]] 统一映射既有家族；依赖原生图与自定义图见 [[methods/local-omics-visualization-guide]]。具体代码变化和参数差异保留在来源，不能继承已有 SCP 或 FigureYa 的运行/作者确认状态。

## 使用记录

2026-11-02：作者指定两个本机目录按 Wiki 规则入库，并要求去重及区分依赖直接出图；本页 draft，待作者审阅知识内容。

## 代码复用层增量（2026-11-02）

已有函数的独立加载、显式 arguments/bindings、去重代码、源码哈希和逐文件去向集中在 [[methods/local-omics-analysis-guide]]；依赖原生绘图和消费预计算结果的 ROC 绘图在 [[methods/local-omics-visualization-guide]]。请 use 对应代码页，不对本来源/流程页承诺 run/render。532 处函数定义中 448 处可选取，84 处有安装、清理、路径/工作树或连带闭包缺口而隔离。两个代码页的 40 个实现分支中，19 个具有限定用例的当前运行与异目录证据（含 1 个纯环境工具），21 个保留 not_run；另有 4 个既有 SCP 闭包完成课题集成/独立回放，不重复建实现；整份源码、整个课题流程与科学有效性不随之提升。此前“无 code/、未提炼”的说明描述来源归档阶段，本次代码资产集中在上述两页，未复制数据与原图进 Wiki。

## 资料确认记录（2026-11-02）

作者在对话中明确授权 agent 代处理当前“待你确认”队列。本轮核对笔记用途、输入边界、知识关联和现有收据后，经正式批量确认入口记录资料审阅。ready 仅表示本技术/流程资料已确认；不会把未运行、缺依赖、未覆盖参数或其他版本变成已验证，也不代表整个课题或科学有效性验收。正文此前带日期的 draft/来源归档说明为当时历史记录，当前资料状态以前置信息和本次验收记录为准。

<!-- user:start -->
<!-- user:end -->
