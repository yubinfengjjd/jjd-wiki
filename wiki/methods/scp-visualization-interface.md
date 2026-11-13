---
type: method
id: scp-visualization-interface
title: SCP 绘图函数与图接口映射
status: ready
tags:
- 单细胞分析
- 其他数据图
keywords:
- SCP
- Seurat
- CellDimPlot
- FeatureDimPlot
- CellStatPlot
- FeatureStatPlot
- GroupHeatmap
- FeatureHeatmap
- CellCorHeatmap
- CellDensityPlot
- EnrichmentPlot
- GSEAPlot
- DynamicPlot
- DynamicHeatmap
- LineagePlot
- PAGAPlot
- VelocityPlot
- VolcanoPlot
- UMAP
- dotplot
- heatmap
- violin
- sankey
inputs: []
outputs: []
source:
  kind: repo
  url: https://github.com/zhanghao-njmu/scp
  commit: b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0
license: GPL-3
cite: []
favorite: false
method_kind: technical
summary: SCP 绘图函数到 Wiki 图表接口的映射与适配资料；不是分析方法。
data_contract:
  input: SCP/Seurat 分析对象或已导出的表。
  output: render-* 接口 CSV；适配层不重算分析或绘图统计。
implementations:
- id: scp-table-adapters
  title: SCP/Seurat 表到 Wiki 接口适配层
  language: R
  entrypoint: code/scp_tables.R:scp_umap_groups
  dependencies: []
  verification: verification/scp-table-adapters.json
---
# SCP 绘图函数与图接口映射

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：无
- 标签：单细胞分析、其他数据图
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/scp-visualization-interface/code/scp_tables.R](/files/wiki/methods/scp-visualization-interface/code/scp_tables.R) · [methods/scp-visualization-interface/code/test_scp_tables.R](/files/wiki/methods/scp-visualization-interface/code/test_scp_tables.R)

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

> **资料类型：技术/来源资料，不是默认分析家族。**
> 当前分析问题见：[[methods/cell-quality-control|单细胞质量控制]]、[[methods/doublet-detection|双细胞检测]]、[[methods/batch-integration|单细胞批次整合]]、[[methods/differential-expression|差异表达分析]]、[[methods/gene-set-enrichment|基因集富集分析]]、[[methods/gene-set-scoring|基因集与通路签名打分]]、[[methods/trajectory-inference|拟时序与轨迹推断]]、[[methods/rna-velocity|RNA 速度分析]]、[[methods/cell-type-annotation|细胞类型注释]]、[[methods/reference-mapping|参考图谱映射]]、[[methods/dimensionality-reduction|单细胞降维分析]]、[[methods/cell-clustering|单细胞聚类分析]]、[[methods/dynamic-feature-analysis|拟时序动态特征分析]]。原代码与作者备注保留；本页不再作为分析推荐卡片。

## 用途

把 SCP 的绘图函数本地化后，按“函数 → 所需数据 → Wiki 现有图接口/模板”的关系整理，回答两个问题：

1. 某个 SCP 图（UMAP、feature UMAP、比例、点图、小提琴/箱线、热图、富集、GSEA、轨迹、速度等）需要什么形状的数据？
2. 现有 Wiki 模板能复用哪些画法，SCP 的 Seurat 对象输出怎样改造成模板读的 CSV？

本页是来源与接口映射资料，不另建分析家族。已有图优先复制各模板 runtime.json 声明的最小闭包；整库加载器只作为历史来源/原版对照，不能冒充最小依赖入口。v2 下开源库走来源/配方路径，画廊复刻走 ingest-figure；已有原生对象绘图闭包见 [[methods/scp-source-catalog|全库索引]] 与四个 draft 绘图技术页，用到时再做新的 L2。

## 原始实现与家族范围

来源是 SCP v0.5.6 的 `R/SCP-plot.R`（745 KB，绘图函数与内部 helper）。主要函数：

- 降维图：`CellDimPlot()`、`FeatureDimPlot()`、`CellDimPlot3D()`、`FeatureDimPlot3D()`。
- 统计图：`CellStatPlot()`、`FeatureStatPlot()`、`StatPlot()`、`CellDensityPlot()`。
- 热图：`GroupHeatmap()`、`FeatureHeatmap()`、`CellCorHeatmap()`。
- 富集/GSEA：`EnrichmentPlot()`、`GSEAPlot()`、`VolcanoPlot()`。
- 轨迹/速度：`LineagePlot()`、`PAGAPlot()`、`ProjectionPlot()`、`VelocityPlot()`、`DynamicPlot()`、`DynamicHeatmap()`、`GraphPlot()`。
- 主题/调色板/布局 helper：`theme_scp()`、`palette_scp()`、`panel_fix()`、`slim_data()`、`drop_data()` 等（多数不单独建页）。

返回对象：多数返回 ggplot/patchwork；`GroupHeatmap()`、`FeatureHeatmap()`、`DynamicHeatmap()`、`CellCorHeatmap()` 返回含 `$plot` 的 list；`GroupHeatmap()` 还返回矩阵/元数据/富集结果。以函数文档和运行结果为准。

代码已本地化到 `code/SCP-local/R/SCP-plot.R`，配套 `ggsankey.R`、`Seurat-function.R`、`utils.R`；补丁见 [[methods/scp-local-source|SCP 源码本地化]]。

## 适用

- 已有 Seurat 对象、降维、分组/表达数据；需要 SCP 的成图风格（UMAP 包络/标签/箭头、统计图多形态、热图注释、富集网络等）。
- 需要把 SCP 图的数据整理成 Wiki 模板能读的 CSV，复用现有单 panel 样式。
- 需要了解哪些 SCP 图型当前没有 Wiki 模板，避免把“函数存在”误当成“模板已就绪”。
- 需要在课题内直接调用 SCP 绘图函数，而不是安装 SCP 包。

## 不适用

- 不能把 SCP 绘图函数直接当成 Wiki 模板：模板入口是 `spec.json` + `code/render.*` + CSV 接口；SCP 函数读 Seurat 对象，二者契约不同。
- v2 的图模板可来自开源配方或画廊复刻；ready 仍表示作者确认。S1–S3有16个SCP示例模板，另加作者已确认的点阵分支共17个；历史收据只证明各自示例，不覆盖整个函数。全库入库仍在继续，未覆盖分支单列。
- 不能把“画法相似”当成“语义直连”：CellDensityPlot 与密度散点不是同一图。GroupHeatmap 的 ht1 已有 fig08；新增 [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]] 为已确认的原生结构分支，不拿普通气泡图替代。
- 不能保证全家族视觉等价：本批独立重跑GroupHeatmap add_dot的单矩阵、reticle及双矩阵；其余模板仍按各自已有证据解释，未在本批全量重跑。add_violin、split、annotation等未实现，S4+其余绘图入口仍有缺口。
- 不能把 SCP 的默认配色/主题当期刊规范；模板样式以 spec 为准。
- 不能在没有数据的情况下用 SCP 函数“估读”出一张图；缺数据要说明。

## 输入

- Seurat 对象：降维（`reduction`）、分组列（`group.by`）、表达矩阵/assay/slot、可选 lineage/velocity 结果。
- `CellDimPlot()`：`group.by`、`reduction`、`dims`、`split.by`、`label`、`add_mark`/`mark_type`、`stat.by`/`stat_type`、`lineages`、`paga`、`velocity`、`graph` 等。
- `FeatureDimPlot()`：`features`、`reduction`、`slot`/`assay`、`compare_features`、`calculate_coexp`、`bg_cutoff`、`lower/upper_quantile` 等。
- `CellStatPlot()`：`stat.by`、`group.by`、`split.by`、`plot_type`（bar/rose/ring/pie/trend/area/dot/sankey/chord/venn/upset）、`stat_type`（percent/count）、`position`。
- `FeatureStatPlot()`：`stat.by`（feature）、`group.by`、`plot_type`（violin/box/bar/dot/col）、`fill.by`、`add_box`/`add_point`/`add_stat`、`comparisons` 等。
- `GroupHeatmap()`/`FeatureHeatmap()`：`features`、`group.by`/`split.by`、`slot`、`exp_method`（zscore/raw/fc/log2fc/log1p）、`feature_split`、`cell_annotation`、`anno_terms` 等。
- `EnrichmentPlot()`/`GSEAPlot()`：`srt` + 已存在的 `srt@tools` 富集/GSEA 结果，或 `res`；`plot_type`、`group_use`、`id_use`、`topTerm` 等。
- `DynamicPlot()`/`DynamicHeatmap()`：`lineages`、`features`、`slot`；lineage 列必须已存在。
- `LineagePlot()`/`PAGAPlot()`/`ProjectionPlot()`/`VelocityPlot()`：对应轨迹/投影/速度结果已存在。
- 一行代表一个细胞；表达值/得分/比例的单位必须说明；颜色/分组顺序显式给出。

## 怎么做

1. 先判断要画的图属于哪一类：降维图、统计图、热图、富集/GSEA、轨迹/速度。每类先读对应函数的参数和返回类型。
2. 已有 CSV 数据优先复用相应表驱动模板；已有 Seurat/原生结果对象可按绘图技术页直接选闭包。是否转表取决于输入与图意，不能仅因接口列名相似就转换。
3. 如果现有模板不能表达（例如 lineage 曲线、velocity 箭头、PAGA 网络、enrichmap、wordcloud、动态热图、3D），如实标记“无模板”，不要强行套用相似模板。bar/rose/chord/venn/upset 与 ring 已有单 panel 原生模板；它们各自只覆盖一个 `plot_type`，不能互相替代。
4. 原生对象绘图优先读 [[methods/scp-viz-dimplots]]、[[methods/scp-viz-statplots]]、[[methods/scp-viz-heatmaps]]、[[methods/scp-viz-model-overlays]] 的清单，复制所选闭包。旧整库 `load_scp_local.R` 仅供历史兼容/原版对照；确认依赖包（ggplot2、ComplexHeatmap、circlize、ggrepel、ggforce、ggnewscale、patchwork、plotly 等）已安装。
5. 表适配：
   - `scp_umap_groups()`：坐标 + 元数据 → `render-umap-groups`。
   - `scp_umap_feature_long()`：坐标 + 表达（宽/长）+ 元数据 → `render-umap-feature-long`。
   - `scp_dotplot_long()`：平均表达 + 阳性比例长表 → `render-dotplot-long`；`pct_scale` 必须显式给 `percent` 或 `fraction`。
   - `scp_grouped_values()`：元数据 + 一个数值列 → `render-grouped-values`。
   - `scp_cell_proportions()`：元数据 → `render-cell-proportions`；每组比例归一化到 1。
   - `scp_cell_metadata()`：元数据 → `render-cell-metadata`（cell, group, stat）；供 pie/rose/trend/area/dot 原生模板使用。
   - `scp_write_interface()`：按接口名写 `<interface>.csv`，供 `wiki.py render` 读取。
6. 必要诊断：颜色是否足够区分、标签是否被裁切、图例/色标是否完整、panel 尺寸是否适合类别数、离散组是否循环有限色板；模板的 `verify-template` 已有回放，但换数据仍要检查。
7. 现有模板的 `--style` 用 `utils::modifyList()` 合并，固定 `group_levels` 这类无名数组不会被替换。换新分组时，可在 style 里传 `{"group_levels": null}` 让模板从数据推导（失去显式顺序控制），或在课题副本修改 `spec.json` 显式给出顺序；不要静默沿用旧分组。
8. 记录：函数名、参数、数据来源、接口表路径、模板 id；不要把 SCP 图的默认样式当模板样式。

## 代码

- 原始字节：`source/SCP-plot.R`（只读归档，未修改）。
- 本地化副本：`code/SCP-local/R/SCP-plot.R`；sankey helper 在 `ggsankey.R`。加载方式：
  ```r
  source("path/to/SCP-local/load_scp_local.R")
  p <- SCP_local$CellDimPlot(srt, group.by = "celltype", reduction = "UMAP",
                             label = TRUE, add_mark = TRUE, mark_type = "hull")
  p <- SCP_local$FeatureDimPlot(srt, features = c("G1", "G2"), reduction = "UMAP")
  p <- SCP_local$FeatureStatPlot(srt, stat.by = "G1", group.by = "celltype",
                                 plot_type = "violin", add_box = TRUE)
  ```
  这只是调用模式，不是已跑通的本机示例。
- 表适配代码：`code/scp_tables.R`；测试：`code/test_scp_tables.R`（25 PASS / 0 FAIL）。适配层只依赖 base R，不依赖 Seurat/SCP。
- 详细验证记录：`verification.md`（命令、覆盖范围、未覆盖项）。
- 依赖：ggplot2、ComplexHeatmap、circlize、ggrepel、ggforce、ggnewscale、patchwork、plotly、scales、grid、gtable、png、ggsankey（内置）；个别函数用 ggpubr/ggwordcloud/ggupset/ggVennDiagram 等 Suggests。完整清单见 [[methods/scp-local-source|SCP 源码本地化]]。
- 验证状态：2026-10-22 记录本地绘图函数已定义并可加载；`CellStatPlot` 的 ring/bar/pie/rose/trend/area/dot/sankey/chord/venn/upset 分支、`VolcanoPlot`、`GroupHeatmap` ht1、`FeatureHeatmap`、`CellCorHeatmap` 与 `CellDensityPlot` 已在隔离库用 `pancreas_sub` 实际运行，并由原生 core + 表/绘图拆分模板复现（固定示例同哈希）；sankey/venn/cell-cor 的依赖兼容补丁记录在对应画廊 `PATCHES.md`。2026-10-23 表适配层 25 PASS / 0 FAIL；其余绘图函数未逐一运行，视觉/数值等价仍未验证。
- 本地化未改变绘图算法；只去掉 `SCP::palette_list`/`SCP::words_excluded` 的包限定。

## 输出

本页不产生新的模板或分析结果；它产出两类东西：

### 1. 可复用的表适配（已测试）

- `render-umap-groups.csv`：`cell_id, umap_1, umap_2, group` → fig01。
- `render-umap-feature-long.csv`：`cell_id, umap_1, umap_2, group, feature, value` → fig02。
- `render-dotplot-long.csv`：`group, feature, avg_expression, pct_expressed, target_group` → fig03。
- `render-cell-proportions.csv`：`group, celltype, proportion` → fig04（堆叠+流带）与 ring 模板（同心环）；两者读取同一接口；fig04 默认在组内再归一化（normalize=true），ring 不归一化、只校验每组和为 1。
- `render-cell-metadata.csv`：`cell, group, stat` → bar/pie/rose/trend/area/dot 原生模板（fig03–fig07、fig09）；每个细胞一行，模板内部执行原 StatPlot 的计数步骤。
- `render-cell-linkage.csv`：`cell, dimension, category, dimension_order` → sankey/chord 原生模板（fig10、fig11）；每个细胞每个维度一行，模板按显式维度/类别顺序重建二维计数表。
- `render-cell-membership.csv`：`cell, set, member` → venn/upset 原生模板（fig12、fig13）；每个细胞每个集合一行，`member` 只取 0/1，模板透视为宽逻辑矩阵后计算交集。
- `render-feature-heatmap.csv`：`matrix, feature, cell, group, value, matrix_order, feature_order, cell_order, group_order` → FeatureHeatmap 模板（fig14）；cell-level 表达矩阵，value 已变换。
- `render-correlation-heatmap.csv`：`row, column, similarity, row_group, column_group, row_order, column_order` → CellCorHeatmap 模板（fig15）；相似度已由上游算好。
- `render-cell-feature-values.csv`：`cell, feature, value, group, feature_order, group_order` → CellDensityPlot 模板（fig16）；cell-level 连续值，模板计算密度。
- `render-grouped-values.csv`：`celltype, group, value` → fig06。
- `render-category-points.csv` + `render-box-summaries.csv`：箱线模板（回归 fig04）。
- 每个接口的实际读取入口见对应模板 `spec.json` 的 `tables` 字段；模板不会隐式重算分析。

### 2. SCP 图型 → 现有模板与缺口

| SCP 函数/图型 | 现有模板 | 状态 |
|---|---|---|
| `CellDimPlot` 分组 UMAP | fig01（`render-umap-groups`） | 可适配 |
| `FeatureDimPlot` 特征 UMAP | fig02（`render-umap-feature-long`） | 可适配 |
| `CellStatPlot` 堆叠比例 | fig04（`render-cell-proportions`） | 可适配 |
| `FeatureStatPlot` violin | fig06（`render-grouped-values` + summaries） | 可适配 |
| `FeatureStatPlot` box | 回归 fig04（`render-category-points` + summaries） | 可适配 |
| `FeatureStatPlot(dot)` | fig03（`render-dotplot-long`） | 仅接口适配线索，不能保证SCP原生几何/主题等价 |
| `GroupHeatmap(add_dot)` | [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；`render-group-heatmap` | 原生正式模板，作者已确认；点颜色为变换表达，点直径为逐细胞阈值比例，不从均值反推 |
| `CellDimPlot` lineage 曲线/箭头 | 无 | 需新模板或直接用 SCP 图 |
| `CellStatPlot` ring | fig02-ring（`render-cell-proportions`） | 原生模板已就绪；固定示例同哈希 |
| `CellStatPlot` pie/rose/trend/area/dot/bar | fig03–fig07、fig09 原生模板（`render-cell-metadata`） | 原生模板已就绪；固定示例逐字节一致 |
| `CellStatPlot` sankey/chord | fig10、fig11 原生模板（`render-cell-linkage`） | 原生模板已就绪；固定示例逐字节一致 |
| `CellStatPlot` venn/upset | fig12、fig13 原生模板（`render-cell-membership`） | 原生模板已就绪；固定示例逐字节一致 |
| `GroupHeatmap` | fig08及fig17（`render-group-heatmap`） | ht1、add_dot已就绪；add_violin/split/annotation未实现 |
| `FeatureHeatmap` | fig14（`render-feature-heatmap`） | 默认单 panel 已就绪；split/add_dot/add_violin/feature_split/annotation 未实现 |
| `CellCorHeatmap` | fig15（`render-correlation-heatmap`） | query-query 折叠默认路径已就绪；参考集/细胞级/nlabel 未验证 |
| `CellDensityPlot` | fig16（`render-cell-feature-values`） | 默认 ridge 已就绪；flip/reverse/x_order 非默认未验证 |
| `EnrichmentPlot`/`GSEAPlot` 各形态 | 无 | 需复刻/模板 |
| `VolcanoPlot` | fig01-volcano（`render-de-results`） | 原生模板已就绪；关系登记在 [[methods/scp-de-enrichment-dynamic]] |
| `DynamicPlot`/`DynamicHeatmap` | 无 | 需复刻/模板 |
| `LineagePlot`/`PAGAPlot`/`ProjectionPlot`/`VelocityPlot`/`GraphPlot` | 无 | 需复刻/模板 |
| `CellDimPlot3D`/`FeatureDimPlot3D` | 无 | 需复刻/模板 |

## 知识关联检查

2026-10-23 分类为技术/来源资料：旧 id、`source/` 原字节和作者备注保留，但不再作为默认分析家族推荐。语义配图关系已迁往 [[methods/cell-quality-control|单细胞质量控制]]、[[methods/doublet-detection|双细胞检测]]、[[methods/batch-integration|单细胞批次整合]]、[[methods/differential-expression|差异表达分析]]、[[methods/gene-set-enrichment|基因集富集分析]]、[[methods/gene-set-scoring|基因集与通路签名打分]]、[[methods/trajectory-inference|拟时序与轨迹推断]]、[[methods/rna-velocity|RNA 速度分析]]、[[methods/cell-type-annotation|细胞类型注释]]、[[methods/reference-mapping|参考图谱映射]]、[[methods/dimensionality-reduction|单细胞降维分析]]、[[methods/cell-clustering|单细胞聚类分析]]、[[methods/dynamic-feature-analysis|拟时序动态特征分析]]；本页只保留来源与实现证据链接，不再维护 `figure_relations` 主记录。原页面正文中的模板/证据链接仍可用于溯源；结构相似不等于科学直连。

## 使用记录

2026-10-25续整理：核对原生GroupHeatmap点阵分支与既有ht1的结构差异，复用既有render-group-heatmap接口而不新建分析方法。新来源仅作图样参考；未将其关联为细胞注释、差异表达或轨迹分析的direct结果，原因是这些方法的实际输出与逐细胞阈值比例生成仍需课题侧语义核对。点阵绘图闭包独立于SCP/Seurat；prepare原版对照仍依赖历史源码环境，不宣称该准备层已独立。来源、候选和代码通过新layout的画廊指针查阅。

2026-10-22 建页；归档 `SCP-plot.R` 原字节，本地化副本进入共享源码包；新增 `code/scp_tables.R` 与 `code/test_scp_tables.R`，合成测试 0 failure；按作者代签授权标为 ready；验收记录见 `acceptance.json`。

<!-- user:start -->
<!-- user:end -->
