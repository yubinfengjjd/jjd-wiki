---
type: template
id: pca-scree-loadings-panel
title: 主成分方差碎石图与特征载荷排序面板
status: draft
layouts: []
sources:
- methods/dimensionality-reduction
panels: []
language: python
primary_method: dimensionality-reduction
style_tier: variant
journal_style: Cancer Discovery
tags:
- transcriptomics
- single-cell
chart_types:
- pca
keywords:
- PCA
- scree-plot
- feature-loadings
- variance-ratio
favorite: false
---
# 主成分方差碎石图与特征载荷排序面板

![[templates/pca-scree-loadings-panel/preview.png]]

<!-- facts:start -->
- 来源：[[methods/dimensionality-reduction|单细胞降维分析]]
- 语言：python
- 标签：transcriptomics、single-cell
- 图型：[[chart-types/pca]]
- 输入接口：未声明 · 未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/dimensionality-reduction|单细胞降维分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：PCA 各主成分解释方差比衰减碎石图与 PC1/PC2 特征绝对载荷排序谱可组合为双联诊断面板。；前提：方差贡献率表与特征载荷表来自同一 PCA 拟合结果。；适配：导出 pca_variance_scree.csv 与 pca_feature_loadings.csv。
    - 关系证据：methods/dimensionality-reduction.md#输出；templates/pca-scree-loadings-panel/spec.json；运行证据：无
<!-- facts:end -->

## 适用

左联绘制各主成分（PC1–PC15）解释方差比衰减碎石折线图（空心方框节点+垂直主成分标签），右联上下并排绘制 PC1 与 PC2 按绝对载荷降序排列的特征散点谱（高亮前两位主导标志物为深红 `#C62828`）。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. S5A 画风。

## 不适用

不适用于展示样本在 PC1–PC2 二维平面的聚类包络散点图（请切换至同槽位默认模板 [[templates/group-hull-pca]]）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/dimensionality-reduction]]，挂入 `(dimensionality-reduction, pca)` 输出槽位（`style_tier: variant`, `journal_style: Cancer Discovery`），与同槽位默认样本包络图 [[templates/group-hull-pca]] 共享主标签 `transcriptomics` 并形成“样本投影 + 载荷诊断”完整 PCA 组合。

## 数据要求

### scree（pca_variance_scree.csv）：各主成分解释方差比表（PC, pc_num, explained_variance_ratio） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| PC | str | 必需 | 主成分名称（如 PC1..PC15） |
| pc_num | int | 必需 | 主成分序号（1, 2, ...） |
| explained_variance_ratio | float | 必需 | 解释方差比例（0-1） |

### loadings（pca_feature_loadings.csv）：各特征在 PC1 与 PC2 上的载荷绝对值表（marker, abs_PC1, abs_PC2） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| marker | str | 必需 | 蛋白标志物或基因名称 |
| abs_PC1 | float | 必需 | PC1 载荷绝对值 |
| abs_PC2 | float | 必需 | PC2 载荷绝对值 |

### 可覆盖的 style

- `top_highlight_n`：`2`
- `max_labeled_features`：`18`
- `dpi`：`300`
- `width_in`：`5.4`
- `height_in`：`3.1`
- `rect`：`[0.1, 0.16, 0.86, 0.76]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
