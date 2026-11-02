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
summary: 依赖原生图、自定义函数与预计算 ROC 分流；复用已有 SCP 闭包，逐分支保留依赖和验证边界。
keywords:
- CellChat
- CellDimPlot
- DotPlotScores
- DynamicHeatmap
- DynamicPlot
- DynamicPlotMonocle2
- FeatureDimPlot
- FeatureStatPlot
- GAM
- GroupHeatmap
- SCP
- SpatialFeaturePlot
- UC-20种修饰
- irGSEA
- irGSEA.heatmap
- irGSEA.integrate
- irGSEA.score
- netVisual_circle
- render_roc_curves
- run_omics_dependency_plot
- 依赖原生绘图
- 哮喘乳酸化单细胞开篇
data_contract:
  input: 原函数显式 arguments/bindings、真实 Seurat/结果对象，或上游预计算曲线与 AUC；文件/输出目录由调用者给定。
  output: 原生计算/绘图值和诊断，或明确阶段的原生工作流；各实现仅以自己的当前收据授予运行证据。
implementations:
- id: py-roc-render
  title: 消费预计算结果的多队列曲线绘图
  language: Python
  entrypoint: code/roc_render.py:render_roc_curves
  dependencies:
  - matplotlib
  verification: verification/py-roc-render-algorithm-20261102b.json
- id: irgsea-heatmap
  title: 依赖原生绘图 irgsea_heatmap
  language: R
  entrypoint: code/dependency_plot.R:run_omics_dependency_plot
  dependencies:
  - irGSEA
  verification: verification/irgsea-heatmap-algorithm-20261102b.json
- id: scp-cell-dim
  title: 依赖原生绘图 scp_cell_dim
  language: R
  entrypoint: code/dependency_plot.R:run_omics_dependency_plot
  dependencies:
  - SCP
  verification: verification/scp-cell-dim-algorithm-20261102b.json
- id: scp-feature-dim
  title: 依赖原生绘图 scp_feature_dim
  language: R
  entrypoint: code/dependency_plot.R:run_omics_dependency_plot
  dependencies:
  - SCP
  verification: verification/scp-feature-dim-algorithm-20261102b.json
- id: scp-feature-stat
  title: 依赖原生绘图 scp_feature_stat
  language: R
  entrypoint: code/dependency_plot.R:run_omics_dependency_plot
  dependencies:
  - SCP
  verification: verification/scp-feature-stat-algorithm-20261102b.json
- id: scp-feature-heatmap
  title: 依赖原生绘图 scp_feature_heatmap
  language: R
  entrypoint: code/dependency_plot.R:run_omics_dependency_plot
  dependencies:
  - SCP
  verification: verification/scp-feature-heatmap-algorithm-20261102b.json
- id: seurat-dim
  title: 依赖原生绘图 seurat_dim
  language: R
  entrypoint: code/dependency_plot.R:run_omics_dependency_plot
  dependencies:
  - Seurat
  verification: verification/seurat-dim-algorithm-20261102b.json
- id: seurat-feature
  title: 依赖原生绘图 seurat_feature
  language: R
  entrypoint: code/dependency_plot.R:run_omics_dependency_plot
  dependencies:
  - Seurat
  verification: verification/seurat-feature-algorithm-20261102b.json
- id: seurat-violin
  title: 依赖原生绘图 seurat_violin
  language: R
  entrypoint: code/dependency_plot.R:run_omics_dependency_plot
  dependencies:
  - Seurat
  verification: verification/seurat-violin-algorithm-20261102b.json
- id: seurat-dot
  title: 依赖原生绘图 seurat_dot
  language: R
  entrypoint: code/dependency_plot.R:run_omics_dependency_plot
  dependencies:
  - Seurat
  verification: verification/seurat-dot-algorithm-20261102b.json
- id: seurat-spatial-dim
  title: 依赖原生绘图 seurat_spatial_dim
  language: R
  entrypoint: code/dependency_plot.R:run_omics_dependency_plot
  dependencies:
  - Seurat
  verification: verification/seurat-spatial-dim-algorithm-20261102b.json
- id: seurat-spatial-feature
  title: 依赖原生绘图 seurat_spatial_feature
  language: R
  entrypoint: code/dependency_plot.R:run_omics_dependency_plot
  dependencies:
  - Seurat
  verification: verification/seurat-spatial-feature-algorithm-20261102b.json
- id: cellchat-circle
  title: 依赖原生绘图 cellchat_circle
  language: R
  entrypoint: code/dependency_plot.R:run_omics_dependency_plot
  dependencies:
  - CellChat
  verification: verification/cellchat-circle-algorithm-20261102b.json
- id: cellchat-bubble
  title: 依赖原生绘图 cellchat_bubble
  language: R
  entrypoint: code/dependency_plot.R:run_omics_dependency_plot
  dependencies:
  - CellChat
  verification: verification/cellchat-bubble-algorithm-20261102b.json
- id: cellchat-aggregate
  title: 依赖原生绘图 cellchat_aggregate
  language: R
  entrypoint: code/dependency_plot.R:run_omics_dependency_plot
  dependencies:
  - CellChat
  verification: verification/cellchat-aggregate-algorithm-20261102b.json
- id: cellchat-heatmap
  title: 依赖原生绘图 cellchat_heatmap
  language: R
  entrypoint: code/dependency_plot.R:run_omics_dependency_plot
  dependencies:
  - CellChat
  verification: verification/cellchat-heatmap-algorithm-20261102b.json
- id: cellchat-role-heatmap
  title: 依赖原生绘图 cellchat_role_heatmap
  language: R
  entrypoint: code/dependency_plot.R:run_omics_dependency_plot
  dependencies:
  - CellChat
  verification: verification/cellchat-role-heatmap-algorithm-20261102b.json
- id: cellchat-role-scatter
  title: 依赖原生绘图 cellchat_role_scatter
  language: R
  entrypoint: code/dependency_plot.R:run_omics_dependency_plot
  dependencies:
  - CellChat
  verification: verification/cellchat-role-scatter-algorithm-20261102b.json
code_roles:
- visualization
theory_methods:
- gene-set-scoring
- gene-set-enrichment
- trajectory-inference
- dynamic-feature-analysis
- regression-resampling-evaluation
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
- 代码模板：[methods/local-omics-visualization-guide/code/dependency_plot.R](/files/wiki/methods/local-omics-visualization-guide/code/dependency_plot.R) · [methods/local-omics-visualization-guide/code/roc_render.py](/files/wiki/methods/local-omics-visualization-guide/code/roc_render.py)

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 用途

辨别图形来自依赖原生函数、项目调用配置、函数改造，还是绘图中包含的新计算；避免按两个课题或多份 PDF 重复收模板。

## 适用

定位来源图的函数入口、对象输入、调用行号和上游计算，选择已有 SCP 图入口或确定后续需验证的自定义候选。

## 不适用

代码存在、成功 use、source 或 --help 均不授予科学或完整流程验证。只有各实现当前收据覆盖的用例有运行证据；其余为 not_run，页面保持 draft。禁止将少数用例通过扩展为整库、整个函数所有参数或真实课题有效性已验证。

## 输入

源码静态调用 + 真实对象语义。限定 package::function 可直接识别命名空间；未限定名称只记候选归属，library/source/全局函数覆盖需运行环境验证。输入普通长表、Seurat、CellChat、GSEA result、拟时序对象与空间切片不互换。

## 怎么做

`rwiki use local-omics-visualization-guide --project <已存在课题目录>`。依赖原生图调用 `code/dependency_plot.R:run_omics_dependency_plot(branch, arguments)`，输入必须是原函数需要的 Seurat、CellChat 或 irGSEA 整合对象；参数直接转交。SCP 缺包时优先检查既有 scp-viz-* 的已提炼闭包，不能把那些收据授予本页原生包适配器。

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

R 依赖原生图：

```r
mod <- new.env(parent = baseenv())
source(file.path(copy_dir, "code", "dependency_plot.R"), local = mod)
p <- mod$run_omics_dependency_plot(
  branch = "irgsea_heatmap",
  arguments = list(object = actual_integrated_result, method = "RRA")
)
```

Python `code/roc_render.py:render_roc_curves(curves, aucs, cohort_colors, title)` 消费上游给定的 FPR/TPR 和 AUC，返回 figure/axes，不拟合模型、不推断标签、不选择 ROC 方向、不自动保存。保留原 style_axes/draw_auc_strip 和构图行为；原脚本 main 的自动标签/方向推断没有混入绘图层。

自定义 DynamicPlotMonocle2、DotPlotScores 等函数通过 [[methods/local-omics-analysis-guide]] 的精确原生函数入口复用；它们包含拟合或汇总，不归为纯依赖图，更不重新收成同义模板。

## 输出

返回原函数值及必要诊断，或依赖原生绘图结果；Python ROC 返回 figure/axes。实际数据与成图由调用者留在课题目录。本页为 technical，不新增同义 analysis 家族或 L2 单 panel 模板。

## 知识关联检查

依赖原生入口回到 [[methods/scp-viz-dimplots]]、[[methods/scp-viz-heatmaps]]、[[methods/scp-viz-statplots]]、[[methods/scp-viz-model-overlays]]；上游算法见 [[methods/local-omics-analysis-guide]] 与 [[methods/uc-spatial-workflows]]。图型相同不证明对象/统计一致；没有新增模板或冒用 FigureYa/SCP 回放。

## 使用记录

2026-11-02：按作者要求完成依赖输出与本地改造分流；字节去重保留来源别名，不改作者图和脚本。

## 代码复用层验证（2026-11-02）

本页 18 个分支中，7 个有当前收据和异目录新进程回放：py-roc-render、seurat-dim、seurat-feature、seurat-violin、seurat-dot、seurat-spatial-dim、seurat-spatial-feature。前 4 个单细胞图使用原 711 细胞对象及其 umap、Monocle2_State、RCC2/BIRC3；2 个空间图使用 UC 原保存切片对象（2378 spots、slice_ 图像、Structure、UBE2L6）。逐分支与直接 Seurat 原生调用比较 ggplot 图层数据（1e-12）、输入不变、调用环境恢复和独立回放哈希一致。参数与对象来源明确，未重新做聚类或注释。

ROC 用例保留原真实预计算 FPR/TPR/AUC，原版对照的曲线数据、RGBA 像素一致，独立副本 PNG 哈希一致。原 inset_axes/tight_layout 提示保留；已目视检查所选用例，不等于任意版式或投稿质量验收。

其余 11 个包路由保持 not_run：irGSEA 1、SCP 4、CellChat 6，均缺相应包本体。此前阻塞 Seurat 的退出崩溃经实际架构子进程环境桥接解决，见 [[methods/local-omics-analysis-guide]]；没有安装包。完整契约见 runtime.json，逐分支收据见 verification/，没有新增模板、layout 或 figure_relations 直连。

## 本次复用整理记录

作者明确要求继续代码复用层整理。补入可复制函数/适配器、闭包清单、逐文件去向和受限真实数据用例证据；没有安装包、修改原统计逻辑、合成科研数据或改变作者状态。`rwiki use` 已在独立目录实际执行，成功复制不授予全部依赖齐备或全部分支可运行。

## 复用既有 SCP 闭包的课题集成

通过 find → show → use 复用 [[methods/scp-viz-dimplots]]、[[methods/scp-viz-statplots]]、[[methods/scp-viz-heatmaps]] 中的 CellDimPlot、FeatureDimPlot、FeatureStatPlot、FeatureHeatmap；未再建同名模板或复制一套 SCP 实现进本页。4 个既有闭包均在原 711 细胞对象上运行并完成仅复制各 runtime 声明文件后的新进程确定性回放。Heatmap 选择 raw data、不做库大小归一化，返回表达矩阵还与原 RNA data 对应行列核对；统计图未执行组间检验。

这是既有闭包对当前项目对象的集成证据，不是 SCP 包本体的新版等价验证，不授予本页 4 个缺包路由 passed。FeatureHeatmap 会留下部分绘图 options（具体键见 scp-project-integration-20261102b.json），因此保持独立 R 子进程使用，不承诺在用户交互会话中无副作用。原 SCP 文件、旧收据与状态均未改。源码保留的手工 scale 无匹配 level 提示如实留在运行日志；所选成图已检查，未据此修改统计或绘图原算法。

<!-- user:start -->
<!-- user:end -->
