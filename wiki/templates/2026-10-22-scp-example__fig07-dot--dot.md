---
type: template
id: 2026-10-22-scp-example__fig07-dot--dot
title: 分组构成点图
status: ready
layouts:
- 2026-10-22-scp-example__fig07-dot
panels:
- A
language: r
tags:
- 单细胞分析
keywords:
- SCP
- pancreas_sub
- dot
- composition
chart_types:
- dot
favorite: false
---
# 分组构成点图

![[templates/2026-10-22-scp-example__fig07-dot--dot/preview.png]]

<!-- facts:start -->
- 来源：[[layouts/2026-10-22-scp-example__fig07-dot|组成点阵图（SCP 示例）]]
- 面板（来源版式）：A
- 语言：r
- 标签：单细胞分析
- 图型：[[chart-types/dot]]
- 输入接口：[[interfaces/render-cell-metadata|细胞级分组元数据表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

一个 `group × stat` 的细胞级元数据表，每个细胞一行，带 `group` 与 `stat` 标签。group × stat 网格，点面积表示组内比例。

绘图核心来自 SCP v0.5.6（commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`，GPL >= 3）`StatPlot()` 的 `plot_type = "dot"` 分支。`scp_stat_table()` 保留原计数/比例逻辑；`plot_scp_stat()` 消费聚合表并保留原 ggplot 构造、`theme_scp`、`palette_scp`、标签/图例规则。`theme_scp`、`palette_scp` 和 `palette_list.rda` 已复制到 `code/`，不依赖已安装的 SCP 包、Wiki 路径或课题工作目录。组数 `n_group` 与类别数 `n_stat` 从数据识别，不写死示例规模。

固定示例（`example/style.json`）为 8×6 in、150 dpi，显示来源标签 `CellType` 与 `Phase:`；该输出与画廊 source 逐字节一致。

## 不适用

- 只画 `dot` 单 panel；不能把其他 CellStatPlot 图型混进同一模板。
- 不能替代分类组成的统计检验；图只展示计数或组内比例。
- 输入是每个细胞一行的元数据，`group`/`stat` 不允许 NA 作为真实类别（当前 levels 检查在计数前拒绝 NA，`NA_stat` 不能保留 NA 水平（以代码为准））。
- 组数/类别数很多或标签很长时会拥挤；`sizing` 按组数、类别数和最长标签增宽/增高，设置 `max_width_in`/`max_height_in` 后超限会停止并报所需尺寸，不缩小字体、不隐藏类别。
- 示例数据 `pancreas_sub` 不是病例/对照队列，不能据此作生物学结论。
- 固定 8×6 的 `area`/`rose` 可能再现上游 panel 边界对端点标签的裁切；这是原函数行为，模板不擅自改 x 轴几何。

## 知识关联检查

日期 2026-10-22；查过 methods（`scp-standard-workflow`、`scp-annotation-projection`、`scp-cellqc-doublet`、`scp-de-enrichment-dynamic`、`scp-visualization-interface`）与 templates（fig04 stacked-bar-flow、fig02 ring）。

- 候选方法：[[methods/scp-standard-workflow]] / [[methods/scp-annotation-projection]] 产出 celltype/cluster；[[methods/scp-cellqc-doublet]] 可用 QC Pass/Fail 作为 stat。它们需要在课题内把元数据整理成 `render-cell-metadata` 表（cell, group, stat），模板不重算分析。
- 一方法多图：同一份细胞级元数据可驱动 pie/rose/trend/area/dot 五种结构编码；它们不互相替代。
- 一图多方法：任何产生 `group × stat` 细胞级标签的方法都可驱动本模板，不限于 SCP。
- 来源 layout：[[layouts/2026-10-22-scp-example__fig07-dot|点图 来源]]；模板从 A panel 拆出。
- 关系状态：已登记到 [[methods/scp-visualization-interface]] 的 `adaptable` 关系；模板读取 `render-cell-metadata`，验证状态为 example。
- 验证范围：固定 8×6@150 输出与画廊 source 逐字节一致（SHA256 `ddabf0eed555227b0a7d25848ebc3a5aa68676f570f9d2e5b6d737044e112117`；`verify-template` exit 0）；CLI 测试五模板合计 82 PASS / 0 FAIL，覆盖 adaptive 1×1/5×3/10×6、45 字符长标签、列映射+逆序、另一 stat_type/position/label、非法输入、输入不变、异目录复制。未验证 Seurat 元数据→CSV→模板的课题流水线，也不证明统计有效。

## 运行方式

本模板是独立模块：复制 `code/`（含 `data/palette_list.rda`）与 `spec.json` 到课题，用课题自己的 R 环境运行 `code/render.R`；不需要完整 `SCP-local`。必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verify/runtime-portability.json`。本轮已把模板复制到异目录、在新进程、不提供来源库路径运行，PNG 与既有回放逐像素一致（MAD=0）；PDF 因生成时间戳不同、部分 SVG 因设备标识不同而未按字节比较。

## 数据要求

### metadata（render-cell-metadata.csv）：每个细胞一行的 group/stat 元数据；模板按原 StatPlot 的计数步骤聚合 [[interfaces/render-cell-metadata|细胞级分组元数据表]]

| 列 | 类型 | 含义 |
|---|---|---|
| cell | str | 细胞标识；同一图内唯一 |
| group | str | 分组或条件；每个细胞一个值；x 轴 |
| stat | str | 被统计的类别；每个细胞一个值；堆叠/扇区系列 |

### 可覆盖的 style

- `group_col`：`"group"`
- `stat_col`：`"stat"`
- `group_levels`：`null`
- `celltype_levels`：`null`
- `palette`：`"Paired"`
- `palcolor`：`null`
- `alpha`：`1`
- `bg_col`：`null`
- `bg_palette`：`"Paired"`
- `bg_palcolor`：`null`
- `bg_alpha`：`0.2`
- `flip`：`false`
- `label_size`：`3.5`
- `label_fg`：`"black"`
- `label_bg`：`"white"`
- `label_bg_r`：`0.1`
- `legend_title`：`"Phase:"`
- `merge_polar_endpoints`：`false`
- `legend_position`：`"right"`
- `legend_direction`：`"vertical"`
- `seed`：`11`
- `dpi`：`150`
- `width_in`：`8`
- `height_in`：`6`
- `plot_type`：`"dot"`
- `stat_type`：`"percent"`
- `position`：`"stack"`
- `label`：`false`
- `xlab`：`"CellType"`
- `ylab`：`"Percentage"`
- `sizing`：`{"mode": "adaptive", "base_in": 5.0, "per_group_in": 0.6, "per_stat_in": 0.9, "base_height_in": 3.0, "min_width_in": 6.0, "min_height_in": 6.0, "base_label_chars": 14, "per_label_char_in": 0.1, "aspect": 0.75, "max_width_in": null, "max_height_in": null}`

## 使用记录

<!-- user:start -->
<!-- user:end -->
