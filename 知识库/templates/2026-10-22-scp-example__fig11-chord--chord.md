---
type: template
id: 2026-10-22-scp-example__fig11-chord--chord
title: 分组流向和弦图
status: ready
layouts:
- 2026-10-22-scp-example__fig11-chord
panels:
- A
language: r
tags:
- 单细胞分析
chart_types:
- chord
favorite: false
---
# 分组流向和弦图

![[templates/2026-10-22-scp-example__fig11-chord--chord/preview.png]]

<!-- facts:start -->
- 来源版式：[[layouts/2026-10-22-scp-example__fig11-chord|分组流向和弦图]]
- 面板（来源版式）：A
- 语言：r
- 标签：单细胞分析
- 图型：[[chart-types/chord]]
- 输入接口：[[interfaces/render-cell-linkage|细胞级多维流向长表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

读取 `render-cell-linkage` 的细胞级长表（每个细胞每个维度一行），按 `dimension_order` 取两个维度，透视为 `cell × dimension` 宽表，再用原 `StatPlot()` 的 `table(useNA = "ifany")` 重建二维计数矩阵。绘图核心保留 SCP v0.5.6（commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`，GPL >= 3）chord 分支的 `circlize::chordDiagram()` 参数：`grid.col`、`transparency = 0.2`、`link.lwd = 1`、`link.lty = 1`、`link.border = 1`，并在同一设备上记录/重放 `recordedplot`。

示例为 `pancreas_sub` 的 CellType × Phase，8×6 in @150 dpi，计数矩阵 5×3；固定输出与画廊 source 逐字节一致（SHA256 `6674db75…`）。类别数、维度名和顺序从数据读取；两个维度的类别名会合并为同一组圆周扇区，模板不自动改名。

## 不适用

- 只画 chord 单 panel；`split.by` 多面板 / `combine = FALSE` 未实现。
- 必须恰好两个维度；第三个维度不画。上游 chord 忽略 `group.by`，并强制 `stat_type = "count"`，不能画比例。
- 弦宽是原始计数，不是概率或效应量；同一类别名在两个维度中会合并，若两维度的「NA」是真实类别也会合并，需上游先区分。
- long 表必须每个细胞每个维度恰好一行；`category` 不允许 NA；缺失/重复会改变矩阵。
- 上游 chord 不使用 ggplot 图例；`label`、`alpha` 等 style 键保留但不应改变绘图几何。
- 扇区/标签过多时按 `sizing` 增大画布；设置 `max_width_in`/`max_height_in` 后超限报错，不缩字体。
- 示例数据 `pancreas_sub` 不是病例/对照队列，不能据此作生物学结论。
- 原生 `recordedplot` 与设备相关；PNG 逐字节一致依赖 R 4.5.0 + cairo 设备参数，PDF/SVG 不承诺跨设备逐字节。

## 知识关联检查

日期 2026-10-22；查过 methods（`scp-standard-workflow`、`scp-annotation-projection`、`scp-cellqc-doublet`、`scp-de-enrichment-dynamic`、`scp-visualization-interface`）与 templates（fig02 ring、fig04 stacked-bar-flow、fig10 sankey、本模板）。

- 候选方法：[[methods/scp-standard-workflow]] / [[methods/scp-annotation-projection]] 产出 celltype/cluster；[[methods/scp-de-enrichment-dynamic]] 可提供分组/状态；它们需要在课题内把每个细胞的维度标签导出成 `render-cell-linkage` 长表（cell, dimension, category, dimension_order），模板不重算分析。
- 一方法多图：同一张 `cell × CellType × Phase` 计数表可由 chord 与 [[templates/2026-10-22-scp-example__fig10-sankey--sankey|桑基图]] 表达；chord 环形紧凑、看整体交叉，sankey 线性更易追踪单条路径；两者不互相替代。
- 一图多方法：任何产生两个互斥分类维度的细胞级标签的方法都可驱动本模板，不限于 SCP。
- 来源 layout：[[layouts/2026-10-22-scp-example__fig11-chord|分组流向和弦图来源]]；模板从 A panel 拆出。
- 关系状态：已登记到 [[methods/scp-visualization-interface]] 的 `adaptable` 关系；模板读取 `render-cell-linkage`，验证状态 example。
- 验证范围：表半 `scp_chord_table()` 与上游 `table()` 矩阵 identical；固定 8×6@150 与画廊 source 逐字节一致；adaptive 与设备边界已测。未验证 `split.by` 多面板、第三个维度、真实 Seurat 元数据→CSV→模板流水线，也不证明科学有效。

## 运行方式

本模板是独立模块：复制 `code/`（含 `data/palette_list.rda`）与 `spec.json` 到课题，用课题自己的 R 环境运行 `code/render.R`；不需要完整 `SCP-local`。必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verify/runtime-portability.json`。本轮已把模板复制到异目录、在新进程、不提供来源库路径运行，PNG 与既有回放逐像素一致（MAD=0）；PDF 因生成时间戳不同、部分 SVG 因设备标识不同而未按字节比较。

## 数据要求

### linkage（render-cell-linkage.csv）：每个细胞每个维度一行的长表；dimension_order 决定两个维度的次序，category_levels 给出显式类别顺序；模板按原 StatPlot 的 table(useNA='ifany') 重建二维计数矩阵，不聚合输入。 [[interfaces/render-cell-linkage|细胞级多维流向长表]]

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
- `dimension_order`：`null`
- `category_levels`：`null`
- `palette`：`"Paired"`
- `palcolor`：`null`
- `NA_color`：`"grey"`
- `alpha`：`1`
- `label`：`false`
- `legend`：`false`
- `transparency`：`0.2`
- `link_lwd`：`1`
- `link_lty`：`1`
- `link_border`：`1`
- `width_in`：`8`
- `height_in`：`6`
- `dpi`：`150`
- `seed`：`11`
- `sizing`：`{"mode": "adaptive", "base_in": 5.0, "per_sector_in": 0.35, "base_label_chars": 12, "per_label_char_in": 0.12, "min_width_in": 6.0, "min_height_in": 5.0, "aspect": 0.75, "max_width_in": null, "max_height_in": null}`

## 使用记录

2026-10-22 从 layout `2026-10-22-scp-example__fig11-chord` 的 A panel 拆出；原生调用 `CellStatPlot(pancreas_sub, stat.by = c("CellType", "Phase"), plot_type = "chord")`。表半 `scp_chord_table()` 与上游 `table(...)` 矩阵 identical；绘图半保留 `circlize::chordDiagram()` 与 `recordPlot()`，source 与 replica 用同一 PNG/PDF/SVG 设备重放。固定 8×6@150 与画廊 source 逐字节一致（SHA256 `6674db75…`），`verify-template` exit 0；方法关系登记在 [[methods/scp-visualization-interface]]。

<!-- user:start -->
<!-- user:end -->
