---
type: template
id: diffusion-trajectory-overlay
title: 降维轨迹与功能模块叠图
status: ready
layouts: []
sources:
- methods/trajectory-inference
panels: []
language: r
primary_method: trajectory-inference
style_tier: default
journal_style: Cai2026-npjPO
tags:
- single-cell
chart_types:
- scatter
keywords:
- DiffusionMap
- Slingshot
- pseudotime
- trajectory
favorite: false
---
# 降维轨迹与功能模块叠图

![[templates/diffusion-trajectory-overlay/preview.png]]

<!-- facts:start -->
- 来源：[[methods/trajectory-inference|拟时序与轨迹推断]]
- 语言：r
- 标签：single-cell
- 图型：[[chart-types/scatter]]
- 输入接口：未声明 · 未声明 · 未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/trajectory-inference|拟时序与轨迹推断]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：Diffusion Map 或 Slingshot 降维流形、有向分化轨迹箭头与多模块主导活性叠色可作为 default 主推轨迹图；模板不推断拟时序。；前提：坐标（dim1, dim2）、cluster 与 pseudotime 来自同一细胞轨迹对象；有向边须有起点依据。；适配：导出 diffusion_trajectory_cells.csv、可选 diffusion_module_scores.csv 与 trajectory_edges.csv。
    - 关系证据：methods/trajectory-inference.md#输出；templates/diffusion-trajectory-overlay/spec.json；运行证据：无
<!-- facts:end -->

## 适用

在 Diffusion Map 或 UMAP 降维流形上叠加有向谱系轨迹箭头、白色描边亚群质心编号、左下 L 形坐标短箭头及多模块主导活性色标（或 DPT/Slingshot 拟时序梯度与亚群离散着色），底部并排紧凑色带条。对应 Cai 等主图 2F–I、4F–H、5F–H 风格。

## 不适用

不适用于原始未归一化的高维计数矩阵，也不能代替拟时序统计推断本身；所绘箭头和模块主导色仅为流形上的视觉引导与活性归纳，不能解释为因果分化时间。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/trajectory-inference]]，作为该方法的 `default` 主推轨迹流形模板（来源风格 `Cai2026-npjPO`），与分支基因平滑曲线网格 [[templates/pseudotime-branch-curves]] 形成“二维流形轨迹空间分布 vs 沿拟时序基因表达曲线”的可切换组合；区别于静态细胞类型 UMAP（如 [[templates/scrna-celltype-umap]]），本模板支持有向分化弧线与多模块主导连续叠色。

## 数据要求

### cells（diffusion_trajectory_cells.csv）：降维轨迹细胞坐标、亚群标签与可选拟时序值（cell_id、dim1、dim2、cluster、可选 pseudotime） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell_id | str | 必需 | 细胞唯一标识 |
| dim1 | float | 必需 | 降维坐标第一轴（如 DC_1 或 UMAP_1） |
| dim2 | float | 必需 | 降维坐标第二轴（如 DC_2 或 UMAP_2） |
| cluster | str | 必需 | 细胞亚群或谱系状态名称 |
| pseudotime | float | 可选 | 可选 DPT 或 Slingshot 拟时序值 |

### scores（diffusion_module_scores.csv）（可选表）：可选多模块功能得分长表（cell_id、module、score），用于主导模块着色叠图 （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell_id | str | 必需 | 细胞标识（匹配 cells.cell_id） |
| module | str | 必需 | 功能模块名称（如 mCAF、ifnCAF、iCAF、lpCAF） |
| score | float | 必需 | 模块基因集得分 |

### edges（trajectory_edges.csv）（可选表）：可选有向拟时序分支连接边（from_cluster、to_cluster） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| from_cluster | str | 必需 | 起点亚群名称 |
| to_cluster | str | 必需 | 终点亚群名称 |

### 可覆盖的 style

- `color_mode`：`"module_overlay"`
- `x_label`：`"DC_1"`
- `y_label`：`"DC_2"`
- `dot_size`：`0.95`
- `show_centroids`：`true`
- `show_trajectory`：`true`
- `module_colors`：`["#BF3347", "#328D40", "#397BB9", "#825097", "#E68A00", "#1B9E77"]`
- `pseudotime_palette`：`["#2B5C8F", "#66C2A5", "#FFFFBF", "#FDAE61", "#D53E4F"]`
- `dpi`：`300`
- `width_in`：`6.4`
- `height_in`：`5.8`

## 使用记录

<!-- user:start -->
<!-- user:end -->
