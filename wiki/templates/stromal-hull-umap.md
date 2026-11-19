---
type: template
id: stromal-hull-umap
title: 基质亚群功能包络UMAP
status: draft
layouts: []
sources:
- methods/cell-type-annotation
panels: []
language: r
primary_method: cell-type-annotation
style_tier: variant
journal_style: Cai2026-npjPO
tags:
- single-cell
chart_types:
- umap
keywords:
- stromal-subcluster
- convex-hull
- UMAP
favorite: false
---
# 基质亚群功能包络UMAP

<!-- facts:start -->
- 来源：[[methods/cell-type-annotation|细胞类型注释]]
- 语言：r
- 标签：single-cell
- 图型：[[chart-types/umap]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

绘制高密度精细细胞亚群 UMAP 流形，按功能群（`functional_group`）自动生成光滑红色虚线包络轮廓（`#D63A2F`）与白边描边功能群标签，在亚群质心标注白色描边数字编号，左下角附 L 形坐标短箭头，并在图底排布分组多列彩点图例。对应 Cai 等主图 1D 风格。

## 不适用

不适用于不含高阶亚群/功能群分层的常规大群 UMAP（请改用默认模板 [[templates/scrna-celltype-umap]]），也不适用于展示连续基因表达网格（请用 [[templates/scrna-feature-umap-grid]]）；包络线仅作视觉分区导引，不能作为群间统计学边界检验依据。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/cell-type-annotation]]，作为 `variant` 高密度精细亚群画风模板（来源风格 `Cai2026-npjPO`），与默认基础细胞类型图 [[templates/scrna-celltype-umap]]、marker 特征网格 [[templates/scrna-feature-umap-grid]] 并列切换；区别于基础 UMAP 模板，本模板提供数字编号质心、周期样条光滑红虚线功能包络及底部多列分层彩点图例。

## 数据要求

### cells（stromal_umap_cells.csv）：细胞亚群降维坐标与高阶功能群表（cell_id、umap_1、umap_2、subcluster，可选 functional_group） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell_id | str | 必需 | 细胞唯一标识 |
| umap_1 | float | 必需 | UMAP 横坐标 |
| umap_2 | float | 必需 | UMAP 纵坐标 |
| subcluster | str | 必需 | 细胞精细亚群标签（自动按顺序编号） |
| functional_group | str | 可选 | 可选高阶功能群标签（绘制红色虚线包络轮廓） |

### 可覆盖的 style

- `hull_color`：`"#D63A2F"`
- `hull_linewidth`：`0.48`
- `dot_size`：`0.85`
- `legend_cols`：`3`
- `show_hulls`：`true`
- `show_centroids`：`true`
- `dpi`：`300`
- `width_in`：`6.6`
- `height_in`：`7.6`

## 使用记录

<!-- user:start -->
<!-- user:end -->
