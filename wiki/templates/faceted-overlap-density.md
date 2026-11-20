---
type: template
id: faceted-overlap-density
title: 多基因分面双组半透明重叠核密度图
status: draft
layouts: []
sources:
- methods/gene-set-scoring
panels: []
language: python
primary_method: gene-set-scoring
style_tier: default
journal_style: Cancer Discovery
tags:
- transcriptomics
- single-cell
chart_types:
- density
keywords:
- KDE
- density-plot
- overlapping-density
- PMEL
favorite: false
---
# 多基因分面双组半透明重叠核密度图

![[templates/faceted-overlap-density/preview.png]]

<!-- facts:start -->
- 来源：[[methods/gene-set-scoring|基因集与通路签名打分]]
- 语言：python
- 标签：transcriptomics、single-cell
- 图型：[[chart-types/density]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/gene-set-scoring|基因集与通路签名打分]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：特征基因或基因集签名在两组样本（如 MIS vs EM/IM）间的分布差异可绘制为分面半透明重叠高斯核密度图与顶部红色显著性星号横线。；前提：每组样本量 >= 3 且方差非零以支持高斯 KDE 拟合。；适配：导出 gene_group_density_long.csv（gene, sample_id, group, log2_expr）。
    - 关系证据：methods/gene-set-scoring.md#输出；templates/faceted-overlap-density/spec.json；运行证据：无
<!-- facts:end -->

## 适用

按多个特征基因或签名（如 PMEL、CD63）水平并排分面，展示两个疾病分组（如 MIS 青绿 `#689892` vs EM and IM 米黄 `#EBE3B5`）的对数表达高斯核密度估计（KDE）半透明填充重叠分布，并在两峰值之间绘制红色显著性星号横线（`#C62828`）。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 6K 画风。

## 不适用

不适用于三个以上分组的多层山脊垂直堆叠展示（请改用 [[templates/scp-expr-ridge]]）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/gene-set-scoring]]，同时适配 [[methods/differential-expression]]；挂入 `(gene-set-scoring, density)` 输出槽位（该槽位首个模板，标为 `style_tier: default`, `journal_style: Cancer Discovery`）。

## 数据要求

### expr（gene_group_density_long.csv）：多基因两组比较对数表达长表（gene, sample_id, group, log2_expr） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| gene | str | 必需 | 基因或签名名称（分面标题） |
| sample_id | str | 必需 | 样本唯一标识 |
| group | str | 必需 | 比较分组（如 MIS vs EM_and_IM） |
| log2_expr | float | 必需 | 对数归一化表达值 |

### 可覆盖的 style

- `bw_method`：`0.45`
- `fill_alpha`：`0.76`
- `xlabel`：`"Log$_2$ expression"`
- `dpi`：`300`
- `width_in`：`4.6`
- `height_in`：`3.0`
- `rect`：`[0.14, 0.18, 0.82, 0.68]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
