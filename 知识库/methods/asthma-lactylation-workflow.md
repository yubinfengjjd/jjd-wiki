---
type: method
id: asthma-lactylation-workflow
title: 乳酸化与代谢研究分析流程
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
method_kind: workflow
summary: 保留来源步骤、参数与分组差异的研究流程；共同分析引用现有家族，所有来源分支未重跑。
keywords:
- asthma-lactylation
- 哮喘乳酸化单细胞开篇
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
# 乳酸化与代谢研究分析流程

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

单细胞标准流程→注释→乳酸相关表达签名→hdWGCNA/相关筛选；bulk 签名与一致性分型→模型训练/比较→GMM-LR/MBDs；单细胞多代谢签名→CellChat→Monocle2/动态表达→RCC2 功能探索。 这是来源工作流索引，不代表所有步骤都按编号串行运行或属于一个已验收课题方案。

## 适用

查明某张图之前需要哪个对象、哪一列分组、哪套基因集合与哪个模型输出；挑选真实课题所需的步骤。

## 不适用

本批仅完成来源归档与知识编译；执行状态为 not_run。未安装依赖、未重跑课题分析、未提炼可执行 L2、未新增 ready，原图不作回放证据。 多段脚本依赖全局对象、硬编码目录、重复重定义和来源已保存对象；不得 source 全文件来试探可运行性。

## 输入

bulk：基因×样本表达、探针/基因映射、队列/批次/表型、独立训练与验证单位；单细胞：Seurat 对象及 counts/data、orig.ident/样本、celltype、基因集；轨迹：选定细胞、拟时序根/特征与状态；模型：样本级预测概率/真实结局与切分；通信：表达对象及分组。缺列不猜映射。

## 怎么做

从 [[methods/asthma-lactylation-source-catalog]] 的清单定位原字节；用 [[methods/local-omics-analysis-guide]] 找到规范家族，再核对具体实现而不是继承 ready。依赖图走 [[methods/local-omics-visualization-guide]]；UC 空间内容另见 [[methods/uc-spatial-workflows]]。需要实际使用时才按 Wiki v2 提炼最小闭包，确认输入、统计单位与包清单后验证。

## 来源步骤与选择

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

## 统计单位与科学边界

细胞、metacell、spot 与患者/样本不同，细胞水平分组检验不自动构成患者层证据；拟时序不是实测时间；表达驱动的 CellChat 通信和虚拟敲除不是干预实验。乳酸化/代谢/修饰签名是表达分数，不是蛋白修饰或通量实测。多算法分数直接求和保留为课题特定策略，不命名为通用 consensus 标准。模型筛选、GMM 性能分组、批次校正与最终 ROC 必须保留训练/验证的时间顺序与独立样本边界；本批未核验任何临床效能。

## 代码

原代码来源见 [[methods/asthma-lactylation-source-catalog]]；整理版不是当然的最新版，不同 SHA-256 保留独立版本。只有字节一致的文件合并存储与别名，未归一化行尾或删去注释后宣称同版。

## 输出

流程顺序与依赖对象、方法/图形复用入口以及需要验证的来源分支；不输出课题数据、预测、p 值或成图。

## 知识关联检查

共用 [[methods/gene-set-scoring]]、[[methods/gene-set-enrichment]]、[[methods/differential-expression]]、[[methods/trajectory-inference]] 等已有家族。WGCNA/hdWGCNA、ConsensusClusterPlus、CellChat、虚拟敲除暂存技术选择知识，未批量新建未使用的 L2 家族。

## 使用记录

2026-11-02：来源工作流整理；所有分支 not_run，未代作者确认。

<!-- user:start -->
<!-- user:end -->
