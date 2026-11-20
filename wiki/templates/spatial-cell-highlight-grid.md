---
type: template
id: spatial-cell-highlight-grid
title: 空间单细胞坐标表型高亮散点分面网格
status: draft
layouts: []
sources:
- methods/spatial-transcriptomics-microenvironment
panels: []
language: python
primary_method: spatial-transcriptomics-microenvironment
style_tier: variant
journal_style: Cancer Discovery
tags:
- single-cell
- transcriptomics
chart_types:
- spatial-map
keywords:
- spatial-scatter
- CyCIF
- TCC
- RCN
favorite: false
---
# 空间单细胞坐标表型高亮散点分面网格

![[templates/spatial-cell-highlight-grid/preview.png]]

<!-- facts:start -->
- 来源：[[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]
- 语言：python
- 标签：single-cell、transcriptomics
- 图型：[[chart-types/spatial-map]]
- 输入接口：未声明 · 未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：单细胞空间物理坐标（X_um, Y_um）上各空间滞后簇（TCC1-10）或邻域的二值高亮空间落点可绘制为多面板网格。；前提：高亮表与背景视野表须共享同一物理微米坐标系与 fov_id。；适配：导出 spatial_cluster_highlights.csv 与 spatial_fov_background.csv。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/spatial-cell-highlight-grid/spec.json；运行证据：无
<!-- facts:end -->

## 适用

在组织切片物理坐标（`X_um, Y_um`）上以浅灰散点（`#D8D8D8`）渲染全切片细胞基底，分面高亮特定肿瘤细胞簇（TCC1–10）或空间邻域（RCN1–10）的空间落点（深青蓝 `#194B5F`），并在右侧附带免疫互作/非互作黄色分组竖条与水平分隔虚线。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 5D / S3D / 1E 画风。

## 不适用

不适用于需要构建 Voronoi 多边形细胞边界镶嵌的图景（请用 [[templates/voronoi-neighborhood-mosaic]]）或空间核密度等高线图（请用 [[templates/spatial-expression-contour]]）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/spatial-transcriptomics-microenvironment]]，挂入 `(spatial-transcriptomics-microenvironment, spatial-map)` 输出槽位（`style_tier: variant`, `journal_style: Cancer Discovery`），与同槽位默认 Visium 特征网格 [[templates/spatial-feature-grid]] 及 Voronoi 邻域镶嵌图 [[templates/voronoi-neighborhood-mosaic]] 共享主标签 `single-cell`。

## 数据要求

### highlights（spatial_cluster_highlights.csv）：目标空间聚簇/表型细胞物理坐标表（cell_uid, X_um, Y_um, fov_id, Stage, TCC） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell_uid | str | 必需 | 细胞唯一标识 |
| X_um | float | 必需 | 空间横坐标（μm） |
| Y_um | float | 必需 | 空间纵坐标（μm） |
| fov_id | str | 必需 | 所属视野编号 |
| Stage | str | 可选 | 所属演进分期 |
| TCC | str | 必需 | 高亮聚簇标签（如 TCC1..TCC10） |

### background（spatial_fov_background.csv）：各视野全部背景细胞物理坐标表（cell_uid, X_um, Y_um, fov_id, Stage） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell_uid | str | 必需 | 细胞唯一标识 |
| X_um | float | 必需 | 空间横坐标（μm） |
| Y_um | float | 必需 | 空间纵坐标（μm） |
| fov_id | str | 必需 | 所属视野编号 |
| Stage | str | 可选 | 所属演进分期 |

### 可覆盖的 style

- `title`：`"Mapping of TCCs to physical location"`
- `bg_color`：`"#D8D8D8"`
- `fg_color`：`"#194B5F"`
- `bg_size`：`3.0`
- `fg_size`：`11.0`
- `dpi`：`300`
- `width_in`：`4.2`
- `height_in`：`6.4`
- `rect`：`[0.06, 0.05, 0.88, 0.86]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
