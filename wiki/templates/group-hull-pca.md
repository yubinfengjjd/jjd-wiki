---
type: template
id: group-hull-pca
title: 微区域样本半透明凸包包络 PCA 图
status: ready
layouts: []
sources:
- methods/dimensionality-reduction
panels: []
language: python
primary_method: dimensionality-reduction
style_tier: default
journal_style: Cancer Discovery
tags:
- transcriptomics
- single-cell
chart_types:
- pca
keywords:
- PCA
- convex-hull
- PickSeq
- GeoMx
favorite: false
---
# 微区域样本半透明凸包包络 PCA 图

![[templates/group-hull-pca/preview.png]]

<!-- facts:start -->
- 来源：[[methods/dimensionality-reduction|单细胞降维分析]]
- 语言：python
- 标签：transcriptomics、single-cell
- 图型：[[chart-types/pca]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/dimensionality-reduction|单细胞降维分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：空间微区域（PickSeq/GeoMx）或样本级主成分坐标（PC1, PC2）可绘制为带 Chaikin 光滑半透明虚线凸包包络与内嵌组名的 PCA 散点图。；前提：PC1/PC2 坐标及解释方差比由上游 PCA 给定；每组至少 3 个样本以拟合凸包。；适配：导出 pca_sample_coords.csv（sample_id, site, PC1, PC2, pc1_var_pct, pc2_var_pct）。
    - 关系证据：methods/dimensionality-reduction.md#输出；templates/group-hull-pca/spec.json；运行证据：无
<!-- facts:end -->

## 适用

展示空间微区域转录组（PickSeq / GeoMx）或样本级主成分分析（PC1 vs PC2）散点分布，按解剖/病理超类自动拟合Chaikin光滑处理的半透明虚线凸包包络（Convex Hull），并在各亚组质心直接内嵌同色加粗组名标签。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 6A 画风。

## 不适用

不适用于考察主成分方差贡献率衰减与 Top 特征载荷排序的诊断图（请切换至同槽位变体模板 [[templates/pca-scree-loadings-panel]]）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/dimensionality-reduction]]，挂入 `(dimensionality-reduction, pca)` 输出槽位（标为 `style_tier: default`, `journal_style: Cancer Discovery`），与同槽位诊断变体 [[templates/pca-scree-loadings-panel]] 共享主标签 `transcriptomics`。

## 数据要求

### pca（pca_sample_coords.csv）：样本/微区域主成分坐标与分组表（sample_id, site, PC1, PC2, pc1_var_pct, pc2_var_pct） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| sample_id | str | 必需 | 样本或微区域唯一标识 |
| site | str | 必需 | 组织学分期或微区域分组标签（如 MIS, IR, bTIL, IB, IM, EM） |
| PC1 | float | 必需 | 第一主成分得分 |
| PC2 | float | 必需 | 第二主成分得分 |
| pc1_var_pct | float | 可选 | PC1 解释方差百分比 |
| pc2_var_pct | float | 可选 | PC2 解释方差百分比 |

### 可覆盖的 style

- `point_size`：`24.0`
- `hull_alpha`：`0.42`
- `dpi`：`300`
- `width_in`：`3.6`
- `height_in`：`3.4`
- `rect`：`[0.16, 0.14, 0.78, 0.74]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
