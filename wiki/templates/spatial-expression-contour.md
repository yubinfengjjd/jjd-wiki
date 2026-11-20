---
type: template
id: spatial-expression-contour
title: 空间蛋白表达等高线地形图
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
- spatial-contour
- CyCIF
- protein-expression
- topography
- Cancer Discovery
favorite: false
---
# 空间蛋白表达等高线地形图

![[templates/spatial-expression-contour/preview.png]]

<!-- facts:start -->
- 来源：[[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]
- 语言：python
- 标签：single-cell、transcriptomics
- 图型：[[chart-types/spatial-map]]
- 输入接口：未声明 · 未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

基于组织切片物理空间坐标（`X_um, Y_um`）绘制蛋白或基因表达的二维平滑等高线填充地形图（蓝-米黄-珊瑚红渐变 + 白色等值轮廓线 + 单细胞散点叠加 + 彩色面板边框），直观揭示肿瘤微环境中的连续空间表达梯度与亚区界限。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 5B 与 Fig. S5B 同质归并画风。

## 不适用

不适用于离散邻域多边形镶嵌（请用同槽位变体 [[templates/voronoi-neighborhood-mosaic]]）、H&E 配准反卷积对照（请用 [[templates/spatial-he-deconv-panel]]）或 Visium Spot 规则网格散点（请用同槽位默认模板 [[templates/spatial-feature-grid]]）；输入网格点须覆盖同一物理视野坐标。示例数据直接切片自 `pmc9167783` 实测 `fig5b_s5b_spatial_contours_proxy.csv`（`MEL09_FOV_IM` 1,600 网格点）与 `fov_cells_with_rcn.csv`（576 个连续 FOV 细胞）。

## 知识关联检查

2026-11-21：将 Nirmal 2022 中视觉同质的 Fig. 5B 与 Fig. S5B 归并提炼为 1 套代表性模板，主归属方法 [[methods/spatial-transcriptomics-microenvironment]]，挂入输出槽位 `(spatial-transcriptomics-microenvironment, spatial-map)`。因该槽位已存在默认模板 [[templates/spatial-feature-grid]]，本模板设为 `style_tier: variant`（`journal_style: Cancer Discovery`），并与同槽位模板对齐受控英文标签 `[single-cell, transcriptomics]`。

## 数据要求

### contours（spatial_contours.csv）：空间二维物理网格表达密度表 （模板内联表结构）

| 列 | 类型 | 含义 |
|---|---|---|
| fov_id | str | 视场标识 |
| X_um | float | 物理横坐标 (um) |
| Y_um | float | 物理纵坐标 (um) |

### cells（spatial_cells.csv）：可选单细胞物理坐标叠层表 （模板内联表结构）

| 列 | 类型 | 含义 |
|---|---|---|
| X_um | float | 细胞物理横坐标 (um) |
| Y_um | float | 细胞物理纵坐标 (um) |

## 使用记录

<!-- user:start -->
<!-- user:end -->
