---
type: template
id: voronoi-neighborhood-mosaic
title: Voronoi 细胞空间邻域镶嵌图
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
chart_types:
- spatial-map
keywords:
- Voronoi
- spatial-neighborhood
- RCN
- CyCIF
- Cancer Discovery
favorite: false
---
# Voronoi 细胞空间邻域镶嵌图

![[templates/voronoi-neighborhood-mosaic/preview.png]]

<!-- facts:start -->
- 来源：[[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]
- 语言：python
- 标签：single-cell
- 图型：[[chart-types/spatial-map]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：连续物理视野（FOV）单细胞坐标与 RCN/TCC 邻域标签可切换为 variant 高密 Voronoi 多边形空间镶嵌与局部放大图；模板不做空间聚类。；前提：输入必须为未下采样打碎连续拓扑的物理 FOV（x, y），否则 Voronoi 面积失真。；适配：导出 spatial_cells_voronoi.csv（cell_id, x, y, neighborhood, 可选 fov_id/stage）。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/voronoi-neighborhood-mosaic/spec.json；运行证据：无
<!-- facts:end -->

## 适用

基于单细胞物理坐标（`x, y`）动态计算有限 Voronoi 多边形镶嵌（`scipy.spatial.Voronoi` + `shapely` 视场边界裁剪），按 `neighborhood`（如 `RCN1–10` 或 `TCC1–10`）着色渲染整幅物理视场并高亮两个局部高密放大框（红/蓝框）。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 3A / Fig. 5E 风格。

## 不适用

严禁用于经过随机下采样打碎连续物理拓扑的细胞子集（打碎后 Voronoi 多边形面积失真）；常规 Visium 规则点阵切片连续特征网格请使用默认模板 [[templates/spatial-feature-grid]]。示例数据取自 `fov_cells_with_rcn.csv`（4 个完整连续未抽样矩形物理 FOV 共 1,418 个真实细胞，默认展示 `MEL09_FOV_IM` 576 细胞）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/spatial-transcriptomics-microenvironment]]；因该 `(spatial-transcriptomics-microenvironment, spatial-map)` 槽位已由 [[templates/spatial-feature-grid]] 占用 `default`，本模板严格设为 `style_tier: variant`。

## 数据要求

### cells（spatial_cells_voronoi.csv）：单细胞连续物理坐标与空间邻域类别表 （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell_id | str | 必需 | 细胞唯一标识 |
| x | float | 必需 | 物理横坐标 (um) |
| y | float | 必需 | 物理纵坐标 (um) |
| neighborhood | str | 必需 | 空间邻域或群落类别标签 |
| fov_id | str | 可选 | 连续视野切片标识 |

### 可覆盖的 style

- `fov_id`：`"MEL09_FOV_IM"`
- `flip_y`：`true`
- `overview_lw`：`0.14`
- `zoom_lw`：`0.35`
- `dpi`：`300`
- `width_in`：`5.4`
- `height_in`：`6.2`

## 使用记录

<!-- user:start -->
<!-- user:end -->
