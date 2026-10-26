---
type: template
id: 2026-10-22-scp-example__fig13-upset--upset
title: 多集合交集 UpSet 图
status: ready
layouts:
- 2026-10-22-scp-example__fig13-upset
panels:
- A
language: r
tags:
- 单细胞分析
chart_types:
- upset
favorite: false
---
# 多集合交集 UpSet 图

![[templates/2026-10-22-scp-example__fig13-upset--upset/preview.png]]

<!-- facts:start -->
- 来源版式：[[layouts/2026-10-22-scp-example__fig13-upset|多集合交集 UpSet 图]]
- 面板（来源版式）：A
- 语言：r
- 标签：单细胞分析
- 图型：[[chart-types/upset]]
- 输入接口：[[interfaces/render-cell-membership|细胞级集合成员表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

读取 `render-cell-membership` 的细胞级长表（每个细胞每个集合一行，`member` 只取 0/1），透视为 `cell × set` 逻辑矩阵，按原 `StatPlot()` 的 upset 分支构造每个细胞的交集集合，再复现 `ggupset::scale_x_upset(sets = 集合名, n_intersections = 20)`、`geom_bar(fill = after_stat(count))`、`geom_text_repel`、`scale_fill_gradientn(material-indigo)`、`theme_scp(aspect.ratio = 0.6)` 与 `theme_combmatrix`。

示例为 `pancreas_sub` 的四个集合（Ductal、Endocrine、G1S、G2M），共 1000 个细胞；交集 512、411、77，8×6 in @150 dpi；固定输出与画廊 source 逐字节一致（SHA256 `b2f0322d…`）。集合名与集合数从数据读取，不写死四个集合；`n_intersections = 20` 是上游默认，可用 style 覆盖。

## 不适用

- 只画 upset 单 panel；不能把 venn/chord/sankey 混进同一模板。
- 条形高度是交集大小，不是单个集合大小；集合大小需另标或另图，不能按条形高度反推集合规模。
- 所有集合必须来自同一细胞全集；缺失 `cell × set` 行会让集合变小，重复行会成倍计数；`member` 只接受 0/1，NA 会被拒绝。
- 超过 `n_intersections` 的交集会被截断，必须在图注说明；空交集不显示。
- 交集大小不是富集显著性；不能据此宣称生物学重要性或因果。
- 集合数很多或标签很长时按 `sizing` 增大画布；`aspect.ratio = 0.6`、组合矩阵字号与间距是上游常数，不随画布缩放。
- 示例数据 `pancreas_sub` 不是病例/对照队列，不能据此作生物学结论。

## 知识关联检查

日期 2026-10-22；查过 methods（`scp-standard-workflow`、`scp-annotation-projection`、`scp-cellqc-doublet`、`scp-de-enrichment-dynamic`、`scp-visualization-interface`）与 templates（fig12 venn、本模板）。

- 候选方法：[[methods/scp-standard-workflow]] / [[methods/scp-annotation-projection]] 产出 celltype；[[methods/scp-cellqc-doublet]] 可定义 QC 通过集合；[[methods/scp-de-enrichment-dynamic]] 可定义差异基因/程序阳性集合。它们需要在课题内先定义每个集合的成员关系并导出 `render-cell-membership` 长表（cell, set, member），模板不重算阈值或富集。
- 一方法多图：同一份成员表可由 [[templates/2026-10-22-scp-example__fig12-venn--venn|维恩图]] 或本模板表达；venn 在 2–4 个集合时更直观，upset 在集合多、交集多时按大小排序并可扩展到 20 个交集；两者不互相替代。
- 一图多方法：任何产生「同一细胞全集的多个 0/1 集合」的方法都可驱动本模板，不限于 SCP。
- 来源 layout：[[layouts/2026-10-22-scp-example__fig13-upset|UpSet 图来源]]；模板从 A panel 拆出。
- 关系状态：已登记到 [[methods/scp-visualization-interface]] 的 `adaptable` 关系；模板读取 `render-cell-membership`，验证状态 example。
- 验证范围：表半交集计数与上游 `p$data` 一致；固定 8×6@150 与画廊 source 逐字节一致；adaptive 2–8 个集合、2–16 个交集通过；超过 20 个交集的截断分支未测。未验证真实 Seurat 元数据→CSV→模板流水线，也不证明科学有效。

## 运行方式

本模板是独立模块：复制 `code/`（含 `data/palette_list.rda`）与 `spec.json` 到课题，用课题自己的 R 环境运行 `code/render.R`；不需要完整 `SCP-local`。必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verify/runtime-portability.json`。本轮已把模板复制到异目录、在新进程、不提供来源库路径运行，PNG 与既有回放逐像素一致（MAD=0）；PDF 因生成时间戳不同、部分 SVG 因设备标识不同而未按字节比较。

## 数据要求

### membership（render-cell-membership.csv）：每个细胞 × 每个集合一行的 0/1 成员表，不聚合细胞；模板按原 StatPlot 的 upset 分支重建每个细胞的 intersection 列表并计数，集合顺序由 style.set_levels 显式给出 [[interfaces/render-cell-membership|细胞级集合成员表]]

| 列 | 类型 | 含义 |
|---|---|---|
| cell | str | 细胞标识；同一集合内唯一；每个细胞每个集合一行 |
| set | str | 集合名；如 Ductal、G1S；顺序显式给出 |
| member | int | 是否属于该集合；只接受 0 或 1 |

### 可覆盖的 style

- `cell_col`：`"cell"`
- `set_col`：`"set"`
- `member_col`：`"member"`
- `set_levels`：`null`
- `stat_level`：`"TRUE"`
- `label_size`：`3.5`
- `label_fg`：`"black"`
- `label_bg`：`"white"`
- `label_bg_r`：`0.1`
- `alpha`：`1`
- `legend`：`false`
- `title`：`null`
- `subtitle`：`null`
- `xlab`：`""`
- `fill_palette`：`"material-indigo"`
- `seed`：`11`
- `width_in`：`8`
- `height_in`：`6`
- `dpi`：`150`
- `sizing`：`{"mode": "adaptive", "base_in": 5.2, "per_intersection_in": 0.75, "per_set_in": 0.05, "base_label_chars": 6, "per_label_char_in": 0.12, "base_height_in": 3.6, "per_set_height_in": 0.6, "min_width_in": 5.0, "min_height_in": 4.0, "max_width_in": null, "max_height_in": null}`

## 使用记录

2026-10-22 从 layout `2026-10-22-scp-example__fig13-upset` 的 A panel 拆出；原生调用 `CellStatPlot(pancreas_sub, stat.by = c("Ductal", "Endocrine", "G1S", "G2M"), plot_type = "upset", stat_level = "TRUE")`。表半 `scp_upset_table()` 与上游交集对象一致；绘图半保留 ggupset 构造。固定 8×6@150 与画廊 source 逐字节一致，`verify-template` exit 0；方法关系登记在 [[methods/scp-visualization-interface]]。

<!-- user:start -->
<!-- user:end -->
