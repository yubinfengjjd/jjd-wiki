---
type: method
id: asthma-lactylation-source-catalog
title: 乳酸化研究脚本来源索引
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
summary: 159 份研究代码、154 个不同字节版本的来源及去重索引；只编译知识，未运行。
keywords:
- asthma-lactylation
- 哮喘乳酸化单细胞开篇
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
# 乳酸化研究脚本来源索引

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

查找作者指定目录中的研究代码、整理副本、历史分支及方法/绘图归属。来源键为 `asthma-lactylation`；原目录由本机外部快照的 `source-roots.local.json` 解析。

## 适用

定位原脚本与版本、核对对象输入和参数、选择后续要验证的具体分支。

## 不适用

本批仅完成来源归档与知识编译；执行状态为 not_run。未安装依赖、未重跑课题分析、未提炼可执行 L2、未新增 ready，原图不作回放证据。 文件哈希一致只说明字节一致；文件名、目录名、既有 PDF 和脚本里的 PASS 字样不证明科学正确或可迁移。

## 输入

研究代码扩展名 .R/.Rmd/.py/.ipynb/.sh；排除 node_modules、Skill、skills-main、隐藏缓存与 paper-harness。文章、投稿正文、表格数据、对象文件和图片不复制入 Wiki。notebook 只登记原文件哈希，不将输出识别为代码。

## 怎么做

先看 [[methods/asthma-lactylation-workflow]]；分析去重见 [[methods/local-omics-analysis-guide]]；绘图见 [[methods/local-omics-visualization-guide]]。来源文件逐项记录在 [inventory.json](/files/wiki/methods/asthma-lactylation-source-catalog/inventory.json)，含相对路径、SHA-256、角色、原语言、编码、canonical 字节别名和静态调用。

## 来源盘点

共 159 份文件、154 个不同 SHA-256；角色数量：active=33、historical=91、organized-copy=34、auxiliary=1。角色是目录上下文判断，active 仅指非归档目录候选，不表示作者选定科学终版。

| 来源模块 | 内容与链路 | 入库判断 |
|---|---|---|
| 1.单细胞转录组数据下载 | 下载材料入口 | 未发现本批支持的研究代码扩展名；不凭目录名认定完整下载实现 |
| 2.单细胞标准流程 | Seurat/Harmony/聚类 | 引用已有规范家族；对象 oc 等隐式上下文不视作独立闭包 |
| 3.单细胞注释 | marker 注释与表达展示 | 与 UC 的注释问题同家族，保留细胞标签和 marker 差别 |
| 4.乳酸化评分 | 四组基因集合、五种分数求和、DotPlotScores | 是转录表达签名；不代表乳酸化蛋白的直接测定 |
| 5.hdWGCNA | metacell 参数扫描、网络模块、ModuleExprScore(UCell) | metacell 不是独立患者；bulk WGCNA 不直接互换 |
| 6.一致性聚类 | ConsensusClusterPlus 样本亚型 | 与 UC 同类流程、不同签名/队列，不新建同义算法 |
| 6.2.Degs与cor | 差异与相关筛选 | 与差异家族关联；筛选与后续模型切分边界须复核 |
| 7.转录组数据下载 | GEO/bulk 整理与批次处理 | 与单细胞输入的计数/单位区别保留 |
| 8.百种机器学习 | MLdata、refer.ML、模型训练、ROC 与混淆矩阵 | 同字节 refer.ML 合并来源；refer2 编码未可靠解码，不修原版 |
| 9.GMM与LR | 模型性能 GMM 分组→LR；模型比对 | 与 UC 同类模型组合流程；不新建细胞聚类方法 |
| 10.MBDs评分 | MBDs/LMBDs 的 ssGSEA 与关联展示 | 名称和配置依来源保留，不当作通用通路/终点定义 |
| 11.深度学习 / 11.ROC | DNN notebook 与预处理；独立 ROC 脚本 | notebook 含输出仅做文件哈希登记，未执行、不复制数据输出 |
| 12.箱式图 | 表达值与组间展示 | 统计检验参数属于分析层；不为箱图新建家族 |
| 13.114种代谢通路的量化 | 多签名五分数及后处理 | 与乳酸化/UC 打分同家族；114 是来源模块名，未据名称验收完整覆盖 |
| 14.细胞通讯 | CellChat；按 Retinoic_Acid_Metabolism 高低划组 | 分组语义属于该来源；不统一改名为乳酸化高低 |
| 16.细胞轨迹 | RunMonocle2、irGSEA、DynamicPlotMonocle2 | 有原始全局对象与子群选择；GAM 自定义实现和依赖原生入口分开 |
| 17.RCC2基因功能探究 | 差异/GSEA、irGSEA 与基因关联 | 保留两个脚本和投稿改写版，不合并参数与组名 |
| 代谢组学 | metabolism.R 与代谢物分析来源 | 行单位是样本/代谢物，与表达签名分数分开 |
| 投稿整理目录 / 废弃 | manuscript-order 方法副本；历史稿与引入外部项目 | 前者保留非同字节改写版；废弃仅历史来源，不进入默认执行推荐 |

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

<!-- user:start -->
<!-- user:end -->
