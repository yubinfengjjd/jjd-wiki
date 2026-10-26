---
type: template
id: 2026-10-22-scp-example__fig10-sankey--sankey
title: 分组流向桑基图
status: ready
layouts:
- 2026-10-22-scp-example__fig10-sankey
panels:
- A
language: r
tags:
- 单细胞分析
chart_types:
- sankey
favorite: false
---
# 分组流向桑基图

![[templates/2026-10-22-scp-example__fig10-sankey--sankey/preview.png]]

<!-- facts:start -->
- 来源版式：[[layouts/2026-10-22-scp-example__fig10-sankey|分组流向桑基图]]
- 面板（来源版式）：A
- 语言：r
- 标签：单细胞分析
- 图型：[[chart-types/sankey]]
- 输入接口：[[interfaces/render-cell-linkage|细胞级多维流向长表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

读取 `render-cell-linkage` 的细胞级长表（每个细胞每个维度一行），按 `dimension_order` 与 `dimension_levels` 透视为 `cell × dimension` 宽表，至少两个维度，再复现 `StatPlot()` 的 sankey 分支：`make_long()`、`geom_sankey(color = "black", flow.alpha = alpha)`、`scale_fill_manual`、`scale_x_discrete(expand = c(0, 0.2))`、`theme_void`，以及每个维度单独的图例（`get_legend` + `add_grob`）和 `patchwork` 组合。桑基流量是满足类别组合的细胞行数，不做加权或比例。

示例为 `pancreas_sub` 的 CellType → Phase（1000 个细胞、2000 行长表），8×6 in @150 dpi；固定输出与画廊 source 逐字节一致（SHA256 `7b16c620…`）。维度数 ≥2、每个维度的类别数和顺序从数据/`dimension_levels` 读取，不写死 5×3。

## 不适用

- 只画默认单 split 的 sankey 单 panel；`split.by` 多面板组合循环未实现。
- 上游 sankey 忽略 `group.by`，并强制 `stat_type = "count"`；不能画比例。`flip`、`label`、`title`、`subtitle` 在该分支无效。
- 维度标签必须是互斥分类；一个细胞可属于多个集合的情况应使用 venn/upset，不是 sankey。
- 长表必须每个细胞每个维度恰好一行；`category` 不允许 NA；缺失/重复会改变流量。超过 100 个水平的上游交互确认分支未实现。
- 流量是计数，不是概率、转移率或因果；维度顺序不能自动读成时间顺序。
- 图例顺序按当前上游因子水平，可能与 Example-2 panel 12 的字母序不同；这是已记录的视觉差异。
- 类别/标签过多时按 `sizing` 增宽/增高；`max_width_in`/`max_height_in` 超限报错，不缩字体。
- 原生组合依赖 patchwork 1.3.1 / gtable 0.3.6 / ggplot2 3.5.2；PNG 逐字节一致只在该环境与固定设备下成立。
- 示例数据 `pancreas_sub` 不是病例/对照队列，不能据此作生物学结论。

## 知识关联检查

日期 2026-10-22；查过 methods（`scp-standard-workflow`、`scp-annotation-projection`、`scp-cellqc-doublet`、`scp-de-enrichment-dynamic`、`scp-visualization-interface`）与 templates（fig04 stacked-bar-flow、fig11 chord、本模板）。

- 候选方法：[[methods/scp-standard-workflow]] / [[methods/scp-annotation-projection]] 产出 celltype/cluster；[[methods/scp-de-enrichment-dynamic]] 可提供状态/分组；它们需要在课题内把每个细胞的维度标签导出成 `render-cell-linkage` 长表（cell, dimension, category, dimension_order），模板不重算分析。
- 一方法多图：同一张 `CellType × Phase` 计数表可由 sankey 与 [[templates/2026-10-22-scp-example__fig11-chord--chord|和弦图]] 表达；sankey 线性排列、追踪单条路径更直接，chord 环形紧凑、看整体交叉更方便；两者不互相替代。
- 一图多方法：任何产生两个以上互斥分类维度的细胞级标签的方法都可驱动本模板，不限于 SCP。
- 来源 layout：[[layouts/2026-10-22-scp-example__fig10-sankey|分组流向桑基图来源]]；模板从 A panel 拆出。
- 关系状态：已登记到 [[methods/scp-visualization-interface]] 的 `adaptable` 关系；模板读取 `render-cell-linkage`，验证状态 example。
- 验证范围：表半与上游 `make_long()`/`dat_use` 一致；固定 8×6@150 与画廊 source 逐字节一致；adaptive 维度/节点/长标签与非法输入已测。未验证 `split.by` 多面板、NA 类别、>100 水平、真实 Seurat 元数据→CSV→模板流水线，也不证明科学有效。

## 运行方式

本模板是独立模块：复制 `code/`（含 `data/palette_list.rda`）与 `spec.json` 到课题，用课题自己的 R 环境运行 `code/render.R`；不需要完整 `SCP-local`。必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verify/runtime-portability.json`。本轮已把模板复制到异目录、在新进程、不提供来源库路径运行，PNG 与既有回放逐像素一致（MAD=0）；PDF 因生成时间戳不同、部分 SVG 因设备标识不同而未按字节比较。

## 数据要求

### linkage（render-cell-linkage.csv）：每个细胞 × 每个维度一行的长表（cell, dimension, category, dimension_order）；模板按 dimension_order 与显式类别顺序透视为 cell × dimension 宽表，再执行上游 make_long()/geom_sankey() 的计数与绘图。桑基流量是细胞行数，不是权重，也不计算组内比例。 [[interfaces/render-cell-linkage|细胞级多维流向长表]]

| 列 | 类型 | 含义 |
|---|---|---|
| cell | str | 细胞标识；同一维度内唯一；每个细胞每个维度一行 |
| dimension | str | 维度/注释名；如 CellType、Phase；显式顺序沿流向排列 |
| category | str | 该维度下的类别；每个细胞每个维度一个值 |
| dimension_order | int | 维度顺序；从 1 起；决定桑基/和弦的左右次序 |

### 可覆盖的 style

- `cell_col`：`"cell"`
- `dimension_col`：`"dimension"`
- `category_col`：`"category"`
- `dimension_order_col`：`"dimension_order"`
- `dimension_levels`：`{"CellType": ["Ductal", "Ngn3 low EP", "Ngn3 high EP", "Pre-endocrine", "Endocrine"], "Phase": ["G1", "S", "G2M"]}`
- `plot_type`：`"sankey"`
- `stat_type`：`"count"`
- `palette`：`"Paired"`
- `palcolor`：`null`
- `alpha`：`1`
- `label`：`false`
- `legend_position`：`"right"`
- `legend_direction`：`"vertical"`
- `seed`：`11`
- `dpi`：`150`
- `width_in`：`8`
- `height_in`：`6`
- `sizing`：`{"mode": "adaptive", "base_in": 5.0, "per_dimension_in": 0.6, "per_node_in": 0.08, "base_height_in": 4.2, "per_node_height_in": 0.25, "min_width_in": 6.0, "min_height_in": 4.0, "base_label_chars": 14, "per_label_char_in": 0.08, "max_width_in": null, "max_height_in": null}`

## 使用记录

2026-10-22 从 layout `2026-10-22-scp-example__fig10-sankey` 的 A panel 拆出；原生调用 `CellStatPlot(pancreas_sub, stat.by = c("CellType", "Phase"), plot_type = "sankey")`。表半保留上游因子预处理、`dat_use`、`make_long()` 与图例水平；绘图半保留 `geom_sankey()`、配色、两个维度的图例和 `patchwork` 组合。为适配当前依赖做了三处记录在 `PATCHES.md` 的兼容：图例 gtable 转换、`wrap_plots(list(gtable))`、跳过 zeroGrob 取第一个非空 guide-box；几何不变，两个图例均保留。固定 8×6@150 与画廊 source 逐字节一致（SHA256 `7b16c620…`），`verify-template` exit 0；方法关系登记在 [[methods/scp-visualization-interface]]。

<!-- user:start -->
<!-- user:end -->
