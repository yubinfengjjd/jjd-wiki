---
type: template
id: 2026-10-22-scp-example__fig09-bar--bar
title: 分组计数柱图
status: ready
layouts:
- 2026-10-22-scp-example__fig09-bar
panels:
- A
language: r
tags:
- 单细胞分析
chart_types:
- bar
favorite: false
---
# 分组计数柱图

![[templates/2026-10-22-scp-example__fig09-bar--bar/preview.png]]

<!-- facts:start -->
- 来源版式：[[layouts/2026-10-22-scp-example__fig09-bar|分组计数柱图]]
- 面板（来源版式）：A
- 语言：r
- 标签：单细胞分析
- 图型：[[chart-types/bar]]
- 输入接口：[[interfaces/render-cell-metadata|细胞级分组元数据表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

读取 `render-cell-metadata` 的逐细胞分类表（每个细胞一行，`group` 与 `stat` 两个标签），在模板内按原 `StatPlot()` 的 `xtabs` 步骤计数，再复现 `plot_type = "bar"` 分支：`geom_col(width = 0.8, colour = "black", alpha = ...)`、stack/dodge 定位、柱内计数或百分比标签、`scale_fill_manual`、`theme_scp`。示例为 `pancreas_sub` 的 CellType × Phase，`stat_type = "count"`、默认 stack、`label = TRUE`、8×6 in @150 dpi。

绘图核心来自 SCP v0.5.6（commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`，GPL >= 3）`StatPlot()` 的 bar 分支。组数 `n_group`、类别数 `n_stat` 与最长标签从数据读取，不写死示例的 5 组 × 3 类；`position`、`stat_type`、`label`、`flip` 由 style 显式给出。固定示例输出与画廊 source 逐字节一致（SHA256 `d9375658…`）；PNG 与 SVG 一致，PDF 仅尾部压缩流有差异（页面内容相同）。

## 不适用

- 只画 bar 单 panel；不能把 pie/rose/trend/area/dot 等其他 `CellStatPlot` 图型混进同一模板。
- 只展示计数或组内比例，不替代统计检验；柱高不是效应量，误差棒/显著性需另配。
- 输入必须逐细胞一行，`cell` 唯一；`group`/`stat` 的 NA 不是真实类别，当前 levels 检查在计数前拒绝 NA（`NA_stat` 不能保留 NA 水平）。
- `group`/`stat` 的顺序由 `group_levels`/`stat_levels` 显式给出；显式 levels 漏掉任一观察值会报错。示例 CSV 的出现顺序与因子顺序不同，必须保留 style 中的 levels，否则轴序/图例会变。
- 组数/类别数多或标签长时按 `sizing` 增宽/增高；设置 `max_width_in`/`max_height_in` 后超限会停止并报所需尺寸，不缩小字体、不隐藏类别。
- 示例数据 `pancreas_sub` 不是病例/对照队列，不能据此作生物学结论。
- 参考 panel（Example-2 第 2 格）与记录的 source 同为上游默认 stack；第 1 格是 dodge 变体，数据与配色相同但几何不同。模板通过 `position = "dodge"` 也支持后者，并已与上游逐字节对照。

## 知识关联检查

日期 2026-10-22；查过 methods（`scp-standard-workflow`、`scp-annotation-projection`、`scp-cellqc-doublet`、`scp-de-enrichment-dynamic`、`scp-visualization-interface`）与 templates（fig03 pie、fig04 rose、fig05 trend、fig06 area、fig07 dot、本模板）。

- 候选方法：[[methods/scp-standard-workflow]] 与 [[methods/scp-annotation-projection]] 产出 celltype/cluster；[[methods/scp-cellqc-doublet]] 可提供 QC Pass/Fail；[[methods/scp-de-enrichment-dynamic]] 的 DE 结果可提供分组。它们需要在课题内把元数据整理成 `render-cell-metadata` 表（cell, group, stat），模板不重算分析。
- 一方法多图：同一份细胞级元数据可驱动 bar/pie/rose/trend/area/dot 六种结构编码；bar 用共同零基线比较绝对量，pie/rose 用角度/半径编码比例，trend/area 用堆叠段沿有序轴展示构成，dot 用面积编码比例；它们不互相替代。
- 一图多方法：任何产生「每个细胞一个 group 与一个 stat」标签的方法都可驱动本模板，不限于 SCP。
- 来源 layout：[[layouts/2026-10-22-scp-example__fig09-bar|分组计数柱图来源]]；模板从 A panel 拆出。
- 关系状态：已登记到 [[methods/scp-visualization-interface]] 的 `adaptable` 关系；模板读取 `render-cell-metadata`，验证状态 example。
- 验证范围：固定 8×6@150 与画廊 source 逐字节一致；stack/dodge/count/percent/label/flip 六个变体与上游逐字节一致；adaptive 2×2 与 12×5、35 字符标签通过；`max_width_in`/`max_height_in` 正确拒绝；输入不变、异目录复制通过；PNG/SVG 一致，PDF 尾部压缩流不同。未验证 Seurat 元数据→CSV→模板的课题流水线，也不证明统计有效。

## 运行方式

本模板是独立模块：复制 `code/`（含 `data/palette_list.rda`）与 `spec.json` 到课题，用课题自己的 R 环境运行 `code/render.R`；不需要完整 `SCP-local`。必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verify/runtime-portability.json`。本轮已把模板复制到异目录、在新进程、不提供来源库路径运行，PNG 与既有回放逐像素一致（MAD=0）；PDF 因生成时间戳不同、部分 SVG 因设备标识不同而未按字节比较。

## 数据要求

### metadata（render-cell-metadata.csv）：每个细胞一行的 group/stat 元数据；模板按原 StatPlot 的 xtabs 计数步骤聚合成 group x stat 表 [[interfaces/render-cell-metadata|细胞级分组元数据表]]

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell | str | 可选 | 细胞标识；同一图内唯一 |
| group | str | 必需 | 分组或条件；每个细胞一个值；x 轴 |
| stat | str | 必需 | 被统计的类别；每个细胞一个值；堆叠/扇区系列 |

### 可覆盖的 style

- `plot_type`：`"bar"`
- `stat_type`：`"count"`
- `position`：`"stack"`
- `group_col`：`"group"`
- `stat_col`：`"stat"`
- `group_levels`：`["Ductal", "Ngn3 low EP", "Ngn3 high EP", "Pre-endocrine", "Endocrine"]`
- `stat_levels`：`["G1", "S", "G2M"]`
- `palette`：`"Paired"`
- `palcolor`：`null`
- `alpha`：`1`
- `bg_col`：`null`
- `bg_palette`：`"Paired"`
- `bg_palcolor`：`null`
- `bg_alpha`：`0.2`
- `flip`：`false`
- `label`：`true`
- `label_size`：`3.5`
- `label_fg`：`"black"`
- `label_bg`：`"white"`
- `label_bg_r`：`0.1`
- `legend_title`：`"Phase:"`
- `legend_position`：`"right"`
- `legend_direction`：`"vertical"`
- `xlab`：`"CellType"`
- `ylab`：`"Count"`
- `NA_stat`：`true`
- `seed`：`11`
- `dpi`：`150`
- `width_in`：`8`
- `height_in`：`6`
- `sizing`：`{"mode": "adaptive", "base_in": 5.0, "per_group_in": 0.7, "per_stat_in": 0.25, "base_height_in": 4.6, "min_width_in": 6.0, "min_height_in": 3.5, "base_label_chars": 14, "per_label_char_in": 0.1, "aspect": 0.75, "max_width_in": null, "max_height_in": null}`

## 使用记录

2026-10-22 从 layout `2026-10-22-scp-example__fig09-bar` 的 A panel 拆出；原生调用 `CellStatPlot(pancreas_sub, stat.by = "Phase", group.by = "CellType", stat_type = "count", plot_type = "bar", label = TRUE)`。表半 `scp_stat_table()` 的 15 行计数表与上游 `p0$data` 在列、因子水平、行序和数值上一致（仅多 5 个 provenance 属性）；绘图半保留 bar 分支。固定 8×6@150 与画廊 source 逐字节一致，`verify-template` exit 0；方法关系登记在 [[methods/scp-visualization-interface]]。

<!-- user:start -->
<!-- user:end -->
