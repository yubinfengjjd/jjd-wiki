---
type: template
id: 2026-10-22-scp-example__fig12-venn--venn
title: 多集合交集维恩图
status: ready
layouts:
- 2026-10-22-scp-example__fig12-venn
panels:
- A
language: r
tags:
- 单细胞分析
chart_types:
- venn
favorite: false
---
# 多集合交集维恩图

![[templates/2026-10-22-scp-example__fig12-venn--venn/preview.png]]

<!-- facts:start -->
- 来源：[[layouts/2026-10-22-scp-example__fig12-venn|多集合交集维恩图]]
- 面板（来源版式）：A
- 语言：r
- 标签：单细胞分析
- 图型：[[chart-types/venn]]
- 输入接口：[[interfaces/render-cell-membership|细胞级集合成员表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

读取 `render-cell-membership` 的细胞级长表（每个细胞每个集合一行，`member` 只取 0/1），按 `cell × set` 透视为宽逻辑矩阵，再复现 `StatPlot()` 的 venn 分支：`ggVennDiagram::Venn()` / `process_data()`、区域与集合边的 `geom_sf`、集合标签与区域计数的 `geom_text_repel`、`scale_fill_identity` / `scale_color_identity` 和无坐标轴主题。区域标签固定为「计数 + 一位小数百分比」，与上游一致。

示例为 `pancreas_sub` 的四个集合（Ductal、Endocrine、G1S、G2M），集合大小 488/512/923/77，非空交集 512/411/77；8×6 in @150 dpi；固定输出与画廊 source 逐字节一致（SHA256 `a5bf1995…`）。集合数 2–7，集合名与顺序从 `style.set_levels` 或输入首现顺序读取，不写死四个集合。

## 不适用

- 只画 venn 单 panel；`split.by` 多面板未实现；不能把 upset/chord/sankey 混进同一模板。
- 集合数限制 2–7；5 个以上集合通常不可读，应改用 [[templates/2026-10-22-scp-example__fig13-upset--upset|UpSet 图]]。
- 维恩图的圆/椭圆面积不与集合大小成比例，不能按面积读大小；必须看标注计数。
- 交集计数不能相加当全集：重叠区域的细胞被多个集合重复计数，百分比分母是各区域计数之和（上游行为），不是背景全集。
- 所有集合必须来自同一细胞全集；缺失 `cell × set` 行会让集合变小，重复行会成倍计数；`member` 只接受 0/1，NA 被拒绝。
- 集合定义（阈值、细胞过滤、注释版本）必须在课题内固定并记录；模板不重算阈值，也不做富集显著性检验。
- 原生绘图代码依赖 ggVennDiagram 的 `process_data()` 几何；本模板兼容 ggVennDiagram >= 1.5 的几何结构（区域/边/标签坐标重建），未与 1.2.x 逐字节交叉验证。
- 示例数据 `pancreas_sub` 不是病例/对照队列，不能据此作生物学结论。

## 知识关联检查

日期 2026-10-22；查过 methods（`scp-standard-workflow`、`scp-annotation-projection`、`scp-cellqc-doublet`、`scp-de-enrichment-dynamic`、`scp-visualization-interface`）与 templates（fig13 upset、本模板）。

- 候选方法：[[methods/scp-standard-workflow]] / [[methods/scp-annotation-projection]] 产出 celltype；[[methods/scp-cellqc-doublet]] 可定义 QC 通过集合；[[methods/scp-de-enrichment-dynamic]] 可定义差异基因/程序阳性集合。它们需要在课题内先定义每个集合的成员关系并导出 `render-cell-membership` 长表（cell, set, member），模板不重算阈值或富集。
- 一方法多图：同一份成员表可由 venn 或 [[templates/2026-10-22-scp-example__fig13-upset--upset|UpSet 图]] 表达；venn 在 2–4 个集合时更直观，upset 在集合多、交集多时按大小排序并可扩展到 20 个交集；两者不互相替代。
- 一图多方法：任何产生「同一细胞全集的多个 0/1 集合」的方法都可驱动本模板，不限于 SCP。
- 来源 layout：[[layouts/2026-10-22-scp-example__fig12-venn|多集合交集维恩图来源]]；模板从 A panel 拆出。
- 关系状态：已登记到 [[methods/scp-visualization-interface]] 的 `adaptable` 关系；模板读取 `render-cell-membership`，验证状态 example。
- 验证范围：表半区域/集合表与上游一致；固定 8×6@150 与画廊 source 逐字节一致；adaptive 集合数/长标签与非法输入已测。未与 ggVennDiagram 1.2.x 逐字节交叉验证；未验证真实 Seurat 元数据→CSV→模板流水线，也不证明科学有效。

## 运行方式

本模板是独立模块：复制 `code/`（含 `data/palette_list.rda`）与 `spec.json` 到课题，用课题自己的 R 环境运行 `code/render.R`；不需要完整 `SCP-local`。必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verify/runtime-portability.json`。本轮已把模板复制到异目录、在新进程、不提供来源库路径运行，PNG 与既有回放逐像素一致（MAD=0）；PDF 因生成时间戳不同、部分 SVG 因设备标识不同而未按字节比较。

## 数据要求

### membership（render-cell-membership.csv）：每个细胞每个集合一行的长表（cell, set, member）；member 只取 0/1，模板按 cell × set 透视为宽逻辑矩阵后重建原 StatPlot venn 分支。 [[interfaces/render-cell-membership|细胞级集合成员表]]

| 列 | 类型 | 含义 |
|---|---|---|
| cell | str | 细胞标识；同一集合内唯一；每个细胞每个集合一行 |
| set | str | 集合名；如 Ductal、G1S；顺序显式给出 |
| member | int | 是否属于该集合；只接受 0 或 1 |

### 可覆盖的 style

- `cell_col`：`"cell"`
- `set_cols`：`null`
- `set_levels`：`null`
- `set_level`：`"TRUE"`
- `palette`：`"Paired"`
- `palcolor`：`null`
- `alpha`：`1`
- `label`：`true`
- `label_size`：`3.5`
- `label_fg`：`"black"`
- `label_bg`：`"white"`
- `label_bg_r`：`0.1`
- `title`：`null`
- `subtitle`：`null`
- `legend_position`：`"none"`
- `legend_direction`：`"vertical"`
- `seed`：`11`
- `dpi`：`150`
- `width_in`：`8`
- `height_in`：`6`
- `sizing`：`{"mode": "adaptive", "base_in": 6.0, "per_set_in": 0.35, "base_label_chars": 8, "per_label_char_in": 0.08, "min_width_in": 5.0, "min_height_in": 4.5, "aspect": 0.75, "max_width_in": null, "max_height_in": null}`

## 使用记录

2026-10-22 从 layout `2026-10-22-scp-example__fig12-venn` 的 A panel 拆出；原生调用 `CellStatPlot(pancreas_sub, stat.by = c("Ductal", "Endocrine", "G1S", "G2M"), plot_type = "venn", stat_level = "TRUE")`，四个集合由 CellType/Phase 派生（Ductal = 三种 ductal 类型，Endocrine = pre-endocrine + endocrine，G1S = G1 + S，G2M = G2M）。表半与上游区域/集合表一致；绘图半保留 ggVennDiagram 构造，并对 ggVennDiagram >= 1.5 的 `venn_setedge()` 缺 `name` 与几何结构做兼容。固定 8×6@150 与画廊 source 逐字节一致，`verify-template` exit 0；方法关系登记在 [[methods/scp-visualization-interface]]。

<!-- user:start -->
<!-- user:end -->
