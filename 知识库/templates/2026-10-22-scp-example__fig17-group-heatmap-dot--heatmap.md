---
type: template
id: 2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap
title: 分组表达点阵热图
status: ready
layouts:
- 2026-10-22-scp-example__fig17-group-heatmap-dot
panels:
- A
language: r
tags:
- 单细胞分析
chart_types:
- heatmap
favorite: false
---
# 分组表达点阵热图

![[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap/preview.png]]

<!-- facts:start -->
- 来源版式：[[layouts/2026-10-22-scp-example__fig17-group-heatmap-dot|分组表达点阵热图]]
- 面板（来源版式）：A
- 语言：r
- 标签：单细胞分析
- 图型：[[chart-types/heatmap]]
- 输入接口：[[interfaces/render-group-heatmap|分组热图长表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

按特征×分组展示聚合表达及阈值阳性细胞比例；可将多个分组变量的矩阵并排，保留共同行顺序。来自SCP 0.5.6 GroupHeatmap(add_dot=TRUE)原生几何，背景白；点颜色是变换表达，点直径是0–1比例，顶部色条仅标识分组。支持reticle。

## 不适用

不从聚合均值推算逐细胞比例，不重算聚合、标准化或统计检验。输入不是Seurat对象。add_violin、flip、split、复杂注释未包含；R共享会话会附加依赖包，建议新进程调用。不将示例回放扩大为所有课题科学有效。

## 知识关联检查

2026-10-25核对[[layouts/2026-10-22-scp-example__fig17-group-heatmap-dot]]、既有ht1模板、[[interfaces/render-group-heatmap]]、[[chart-types/heatmap]]和[[methods/scp-visualization-interface]]。点大小额外编码比例，故与ht1保留不同结构入口；同样使用已有长表接口。技术页只作来源映射，不建新分析家族。细胞注释、差异表达和轨迹输出不会自动含本图逐细胞阈值比例，因此未建立direct关系。

## 数据要求

### heatmap（render-group-heatmap.csv）：一个 matrix × feature × group 的长表；模板按 matrix 重建多个热图矩阵，percent 驱动点大小 [[interfaces/render-group-heatmap|分组热图长表]]

| 列 | 类型 | 含义 |
|---|---|---|
| matrix | str | 分组变量/矩阵名，如 CellType；同一 feature 可出现在多个矩阵 |
| feature | str | 基因或元数据特征标识；行键是 matrix×feature×group，同一 feature 在同一矩阵内按每个 group 出现一次，也可出现在多个矩阵 |
| group | str | 列分组/细胞类型；同一 group 在同一矩阵内按每个 feature 出现一次 |
| value | float | 聚合后的表达值，已按 exp_method 变换（如 zscore） |
| percent | float | 该组中逐细胞表达值（经原调用声明的 lib_normalize 后、聚合/zscore 前）> exp_cutoff 的细胞比例，0–1；不是对聚合 value 列取阈值 |
| matrix_order | int | 矩阵显示顺序，正整数从 1 起，可不连续 |
| group_order | int | 同一矩阵内列顺序，正整数从 1 起，可不连续 |
| feature_order | int | 行顺序，正整数从 1 起，可不连续；同一 feature 在各矩阵保持一致 |

### 可覆盖的 style

- `add_dot`：`true`
- `dot_size_mm`：`8`
- `add_reticle`：`false`
- `reticle_color`：`"grey"`
- `exp_method`：`"zscore"`
- `exp_legend_title`：`"zscore(normalized counts)"`
- `heatmap_palette`：`"RdBu"`
- `heatmap_palcolor`：`null`
- `group_palette`：`"Paired"`
- `group_palcolor`：`null`
- `nlabel`：`20`
- `features_label`：`null`
- `label_size`：`10`
- `label_color`：`"black"`
- `dpi`：`150`
- `width_in`：`8`
- `height_in`：`6`
- `seed`：`11`
- `sizing`：`{"mode": "adaptive", "base_width_in": 3, "per_x_in": 0.35, "base_height_in": 2, "per_y_in": 0.25, "min_width_in": 6, "min_height_in": 5, "base_label_chars": 8, "per_label_char_in": 0.08, "aspect": null, "max_width_in": null, "max_height_in": null}`

## 使用记录

2026-10-25作者明确确认后按正常流程组装；代码与已独立核验候选同源。三张PNG、两张SVG匹配独立重跑原函数；1m/2m PDF栅格一致。异目录清单复制、新进程、换合法规模/标签/数字身份、输入不变及异常拒绝均留证。当前正式verify另记录本次真实运行，未验证分支不继承。runtime.json声明只复制本图所需文件和资源，绘图不加载SCP或Seurat。

<!-- user:start -->
<!-- user:end -->
