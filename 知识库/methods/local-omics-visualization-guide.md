---
type: method
id: local-omics-visualization-guide
title: 课题绘图依赖与自定义改造
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
summary: 将 irGSEA、SCP、Seurat、CellChat 等直接出图区分为依赖调用，并单列带汇总或 GAM 重拟合的本地改造。
keywords:
- UC-20种修饰
- 哮喘乳酸化单细胞开篇
- irGSEA
- irGSEA.score
- irGSEA.integrate
- irGSEA.heatmap
- SCP
- DynamicPlotMonocle2
- DynamicPlot
- DotPlotScores
- CellDimPlot
- FeatureDimPlot
- GroupHeatmap
- DynamicHeatmap
- FeatureStatPlot
- CellChat
- netVisual_circle
- SpatialFeaturePlot
- 依赖原生绘图
- GAM
data_contract:
  input: 来源脚本、静态调用、对象/表结构与来源版本；数据和图片留在课题目录。
  output: 来源去重、规范方法映射、依赖绘图/自定义实现与工作流导航；不提供已验证可执行实现。
---
# 课题绘图依赖与自定义改造

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

辨别图形来自依赖原生函数、项目调用配置、函数改造，还是绘图中包含的新计算；避免按两个课题或多份 PDF 重复收模板。

## 适用

定位来源图的函数入口、对象输入、调用行号和上游计算，选择已有 SCP 图入口或确定后续需验证的自定义候选。

## 不适用

本批仅完成来源归档与知识编译；执行状态为 not_run。未安装依赖、未重跑课题分析、未提炼可执行 L2、未新增 ready，原图不作回放证据。 本页不是已验收的图模板画廊；未将课题 PDF/PNG 复制成 Wiki preview，也没有把原生图与本地改造混作同一实现。

## 输入

源码静态调用 + 真实对象语义。限定 package::function 可直接识别命名空间；未限定名称只记候选归属，library/source/全局函数覆盖需运行环境验证。输入普通长表、Seurat、CellChat、GSEA result、拟时序对象与空间切片不互换。

## 怎么做

对照下表与 [call-sites.json](/files/wiki/methods/local-omics-visualization-guide/call-sites.json)，其每条保存源路径、SHA-256、函数和行号、角色及对象边界。相同内容的路径保留别名，不当不同图法；history 不进入默认复用。已有方法 find→show；确定实际课题再 use 对应已验证闭包。

## 绘图来源判定

| 调用或图层 | 分类 | 上游结果与复用判断 |
|---|---|---|
| irGSEA.score → irGSEA.integrate → irGSEA.heatmap | 打分 → 组间整合/RRA → 依赖原生热图 | 热图消费 result.dge，不能仅导出普通矩阵就宣称接口等价；不提取成“本项目新热图算法”。 |
| SCP CellDimPlot / FeatureDimPlot | 依赖原生绘图 | Seurat 降维、分组与 feature/metadata；复用 scp-viz-dimplots，不重复造 UMAP 模板。 |
| SCP FeatureStatPlot / CellStatPlot | 依赖原生统计展示 | 与 scp-viz-statplots 关联；按选项检查汇总/检验，不把整次调用都标纯绘图。 |
| SCP GroupHeatmap / FeatureHeatmap / DynamicHeatmap | 依赖原生表达/动态热图 | 复用 scp-viz-heatmaps；组聚合、拟时序与 fitted 分支保留对象要求。 |
| SCP DynamicPlot | 依赖原生动态绘图，可触发拟合 | 既有 scp-viz-model-overlays；和本地 DynamicPlotMonocle2 不是同一实现，不继承相互验证。 |
| 本地 DynamicPlotMonocle2 | 自定义分析+绘图改造 | 函数内 mgcv::gam、predict 与区间计算，失败 fallback 到 geom_smooth；不是只替换配色的 SCP 包装。 |
| 本地 DotPlotScores | 自定义汇总+绘图，跨项目完全同字节 | 提取 metadata，组均值/log1p/scale；pct.exp 在全体细胞上算而非逐组，长度回填与数值域待实际验证；不等价于 Seurat DotPlot。 |
| Seurat DimPlot/FeaturePlot/VlnPlot/DotPlot/SpatialFeaturePlot | 依赖原生图 | 列、assay、slot、降维与坐标是调用配置；不按项目和输出文件各建模板。 |
| CellChat netVisual_* / netAnalysis_* | 依赖原生通信展示 | 消费 CellChat 对象/网络；signaling role 与 pattern 等上游结果明确记录，不能将网络显著性重算藏在样式层。 |
| WGCNA/hdWGCNA、GseaVis/enrichplot、pheatmap/ComplexHeatmap | 依赖绘图/项目组合 | 常规依赖调用先链接对象输入；依赖标题和成图外形不构成新画法。 |
| ggplot2、空间 plot_helpers、注释热图 helper、Python ROC | 项目自定义构图/适配候选 | 表结构、排序、检验和 helper 闭包逐实现审查；新布局不等于新分析方法。 |
| 整理版空间 9.21–9.25 | RCTD+CellChat 后处理/分层展示 | 与 legacy CellTrek 分支分开；绘图中若计算差值/聚合/统计，仍标相应计算边界。 |

本批静态调用实见 FeatureStatPlot、FeatureHeatmap 等；上表中的 CellStatPlot、GroupHeatmap、DynamicHeatmap 和原生 DynamicPlot 是既有库的相近入口对照，未在本批可解析调用中发现直接调用，不计作本批已收录实现。完整调用和来源角色以 call-sites.json 为准，计数包含字节别名及明确标记的历史来源，不是独立图样数。

## 关键位置

irGSEA：UC `17.基因功能探究/1.R` 的 468/477/482 行分别 score/integrate/heatmap，494/502/506 行为另一签名配置；哮喘 `16.细胞轨迹/1.R` 的 374/396/404 行是按 Monocle2_State 组织的同类链。自定义 `16.细胞轨迹/DynamicPlot.R` 从第 10 行定义 DynamicPlotMonocle2，156 行 GAM 拟合、159 行预测，162–163 行区间；UC 整理版是相同字节副本。DotPlotScores 跨项目同字节，不能因文件名不同多收。

## 上游计算与展示边界

irGSEA.integrate 的统计/秩整合不能记作热图换皮；五算法 rowSums 组合与 RRA 整合不等价。DynamicPlotMonocle2 的 GAM 形式、失败 fallback 和区间推断都属于实现边界。DotPlotScores 的全局阈值比例、组均值和 log1p 不应在未来函数化时悄悄修正：这会改变汇总或统计含义，需先与作者确认。SCP 旧验证仅覆盖记录的包版本/入口/参数形态，不覆盖本项目或自定义函数。

## 代码

原脚本留来源原字节；本页无新绘图核心/闭包，也未先为未来需求提炼 L2。技术导航页不维护主 figure_relations，不反向宣称接口直连。

## 输出

依赖原生绘图导航、项目改造候选与计算边界；不生成新图或预览。所有新增来源调用均 not_run。

## 知识关联检查

依赖原生入口回到 [[methods/scp-viz-dimplots]]、[[methods/scp-viz-heatmaps]]、[[methods/scp-viz-statplots]]、[[methods/scp-viz-model-overlays]]；上游算法见 [[methods/local-omics-analysis-guide]] 与 [[methods/uc-spatial-workflows]]。图型相同不证明对象/统计一致；没有新增模板或冒用 FigureYa/SCP 回放。

## 使用记录

2026-11-02：按作者要求完成依赖输出与本地改造分流；字节去重保留来源别名，不改作者图和脚本。

<!-- user:start -->
<!-- user:end -->
