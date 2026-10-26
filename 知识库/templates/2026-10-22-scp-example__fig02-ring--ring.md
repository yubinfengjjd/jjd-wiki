---
type: template
id: 2026-10-22-scp-example__fig02-ring--ring
title: 分组构成同心环图
status: ready
layouts:
- 2026-10-22-scp-example__fig02-ring
panels:
- A
language: r
tags:
- 单细胞分析
keywords:
- SCP
- pancreas_sub
- ring
- composition
chart_types:
- ring
favorite: false
---
# 分组构成同心环图

![[templates/2026-10-22-scp-example__fig02-ring--ring/preview.png]]

<!-- facts:start -->
- 来源版式：[[layouts/2026-10-22-scp-example__fig02-ring|环形组成图（SCP 示例）]]
- 面板（来源版式）：A
- 语言：r
- 标签：单细胞分析
- 图型：[[chart-types/ring]]
- 输入接口：[[interfaces/render-cell-proportions|细胞类型比例表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

一个 group × celltype 比例表，画成同心环组成图：按 `group` 分环、按 `celltype` 分扇区，扇区角度为组内比例。适合细胞类型、细胞周期、样本组成等分类组成的展示；环数/扇区数从数据读取，不写死 5 组或 3 类。

绘图核心来自 SCP v0.5.6（commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`，GPL >= 3）`StatPlot()` 的 ring 分支。`scp_ring_table()` 保留原计数逻辑；`plot_scp_ring()` 消费表并保留原 `geom_col` + `coord_polar(theta = "y")`、`geom_text_repel`、`theme_scp`、`palette_scp` 与图例/标签规则。`theme_scp`、`palette_scp` 和 `palette_list.rda` 已复制到 `code/`，不依赖已安装的 SCP 包、Wiki 路径或课题工作目录。

默认样式使用接口列名 `group/celltype/proportion`，行顺序即默认类别顺序；也可用 `group_levels`/`celltype_levels` 显式指定。示例 `example/style.json` 固定 8×6 in、150 dpi，并显示来源标签（`CellType`、`Phase:`）；该固定模式 PNG 与画廊复刻逐字节一致。

## 不适用

- 只画 ring 单 panel；不能把 pie/rose/bar 等其他图型混进同一模板。
- 不能替代比例差异的统计检验；环图只展示组内组成。
- 输入必须是已归一化比例，每个 group 的 `proportion` 之和须为 1；缺失的 group × celltype 组合会按 0 补齐，但显式 `group_levels`/`celltype_levels` 不能漏掉数据中已有的组或类别（会报错，避免静默丢组）。
- 类别很多或标签很长时会拥挤；`sizing` 按组数、类别数和最长标签增宽/增高，设置 `max_width_in`/`max_height_in` 后超限会停止并报所需尺寸，不缩小字体、不隐藏类别。
- 原生 `label = TRUE` 会对所有扇区加标签（`geom_text_repel`）；极小的相邻扇区仍可能重叠，模板不按比例阈值省略标签。
- 环的顺序只是分类顺序，不代表时间或轨迹；颜色只区分类别，不是定量刻度。
- 示例数据 `pancreas_sub` 不是病例/对照队列，不能据此作生物学结论。

## 知识关联检查

日期 2026-10-22；查过 methods（`scp-standard-workflow`、`scp-annotation-projection`、`scp-cellqc-doublet`、`scp-visualization-interface`）与 templates（fig04 stacked-bar-flow；本模板为 ring）。

- 候选方法：[[methods/scp-standard-workflow]] / [[methods/scp-annotation-projection]] 产出 celltype/cluster；[[methods/scp-cellqc-doublet]] 可用 QC Pass/Fail 作为类别。它们都需在课题内把元数据按 group 统计成 `render-cell-proportions` 表；ring 不归一化、只校验每组和为 1，fig04 默认在组内再归一化（normalize=true）。
- 一方法多图：同一 proportions 表也可进 fig04（堆叠比例 + 流带）；ring 是不同结构编码，不替代 fig04。
- 一图多方法：任何产生 group × celltype 比例表的方法都可驱动本模板，不限于 SCP。
- 来源 layout：[[layouts/2026-10-22-scp-example__fig02-ring|单 panel Ring composition]]；模板从 A panel 拆出。
- 关系状态：[[methods/scp-visualization-interface]] 已登记 `adaptable` 关系（读取 `render-cell-proportions`，验证状态 example）；当前不标 direct。
- 验证范围：核心函数契约 30 PASS / 0 FAIL（4×3、7×5、零组合、反序、count、列映射、短配色、非法输入、输入不变）。模板 CLI 验收 30 PASS / 0 FAIL（固定 8×6@150 与画廊 replica 同 SHA256 `85b3c9b7…`；adaptive 1/5/10 组、1/6 类别、43 字符长标签、零组合、反序、列映射、两色 palette 插值、非法输入、异目录复制、无 Wiki/SCP 依赖）。`verify-template` exit 0；preview SHA256 `85b3c9b7…`。相对来源 PNG 的像素平均绝对差 `1.17e-05`、RMS `0.0036`，差异只在中心极小 bbox（原生 cell 级与表级路径的极坐标端点合并）。不证明统计有效。

## 运行方式

本模板是独立模块：复制 `code/`（含 `data/palette_list.rda`）与 `spec.json` 到课题，用课题自己的 R 环境运行 `code/render.R`；不需要完整 `SCP-local`。必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verify/runtime-portability.json`。本轮已把模板复制到异目录、在新进程、不提供来源库路径运行，PNG 与既有回放逐像素一致（MAD=0）；PDF 因生成时间戳不同、部分 SVG 因设备标识不同而未按字节比较。

## 数据要求

### proportions（render-cell-proportions.csv）：每个 group 内 celltype 的比例；每组 proportion 之和必须为 1 [[interfaces/render-cell-proportions|细胞类型比例表]]

| 列 | 类型 | 含义 |
|---|---|---|
| group | str | 样本或条件分组 |
| celltype | str | 细胞类型；环内堆叠类别 |
| proportion | float | 该组内该细胞类型的比例；每组和为 1 |

### 可覆盖的 style（`spec.json` 的 `style`）

- `group_col`：`"group"`；`celltype_col`：`"celltype"`；`proportion_col`：`"proportion"`
- `group_levels` / `celltype_levels`：`null`，即按输入行顺序；显式传入时用于固定顺序
- `stat_type`：`"percent"`；`palette`：`"Paired"`；`palcolor`：`null`
- `alpha`：`1`；`flip`：`false`；`label`：`true`；`label_size`：`3.5`
- `label_fg` / `label_bg`：`"black"` / `"white"`；`label_bg_r`：`0.1`
- `position`：`"stack"`；`xlab` / `ylab` / `legend_title`：`null`（分别回落到 group 列名、`Percentage`、`<celltype 列名>:`）
- `legend_position` / `legend_direction`：`"right"` / `"vertical"`
- `merge_polar_endpoints`：`true`；`seed`：`11`；`dpi`：`150`；`width_in`：`8`；`height_in`：`6`
- `sizing`：`{"mode":"adaptive","base_in":5.0,"per_group_in":0.6,"per_celltype_in":0.12,"min_size_in":6.0,"min_height_in":6.0,"base_label_chars":14,"per_label_char_in":0.1,"aspect":0.75,"max_width_in":null,"max_height_in":null}`

### 入口

`Rscript code/render.R --data <目录> --out <目录> [--style <json>]`。读取 `<data>/render-cell-proportions.csv`，写出 `figure.png`、`figure.pdf`、`figure.svg` 和 `sizing.json`；`sizing.json` 记录实际宽高、dpi、组/类别数、标签长度和 SVG 设备。

## 使用记录

2026-10-22 从 layout `2026-10-22-scp-example__fig02-ring` 的 A panel 拆出。当前实现：`code/scp_ring_native.R`（原生 core）+ `code/scp_helpers.R`（本地 `theme_scp`/`palette_scp`）+ `code/data/palette_list.rda` + `code/core.R` + `code/panel.R` + `code/render.R`。旧的自定义 `plot_ring()` 版本保存在工作区 `archive/template-custom-core/fig02-ring-708071c/`（Wiki git commit `708071c`），不参与当前模板。`verify-template`、核心契约和 58 项 CLI 验收见上。

<!-- user:start -->
<!-- user:end -->
