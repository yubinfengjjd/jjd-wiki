---
type: template
id: feature-umap-contrast-grid
title: 高对比度连续特征 UMAP 网格
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
- UMAP
- feature-grid
- module-score
- marker-expression
favorite: false
---
# 高对比度连续特征 UMAP 网格

![[templates/feature-umap-contrast-grid/preview.png]]

<!-- facts:start -->
- 来源：[[methods/cell-type-annotation|细胞类型注释]]
- 语言：r
- 标签：single-cell
- 图型：[[chart-types/umap]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/cell-type-annotation|细胞类型注释]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：谱系标志基因表达量或功能模块评分可在单细胞 UMAP 上按高对比度置顶色阶与 Min/Max 色标渲染为多面板网格；模板不执行打分。；前提：坐标与连续特征列来自同一单细胞对象；特征列已完成对数标准化或模块打分。；适配：导出 feature_umap_scores.csv（cell_id, umap_1, umap_2 及多列连续特征/模块得分）。
    - 关系证据：methods/cell-type-annotation.md#输出；templates/feature-umap-contrast-grid/spec.json；运行证据：无
<!-- facts:end -->

## 适用

将多个功能模块评分（如 lpCAF/mCAF/tCAF/ifnCAF）或谱系标志基因表达量投射在单细胞 UMAP 流形上，按高表达置顶排序渲染为高对比度连续色阶（光谱蓝-黄-深红 `Spectral` 或浅灰-胭脂红 `#E8E8E8 -> #D53E4F`）多面板网格，每子图右侧附带独立 `Min`/`Max` 垂直色标条。对应 Cai et al. (*npj Precision Oncology*, 2026) Fig. 1C / 2B / 4B / 5B / S2C / S4C 画风。

## 不适用

不适用于离散细胞类型分群展示（请用 [[templates/scrna-celltype-umap]] 或 [[templates/stromal-hull-umap]]）；模板仅对连续特征作 `[0, 1]` 分位数缩放与视觉映射，不执行上游模块打分或差异表达检验。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/cell-type-annotation]]，同时与 [[methods/gene-set-scoring]] 语义关联；挂入 `(cell-type-annotation, umap)` 输出槽位（`style_tier: variant`, `journal_style: Cai2026-npjPO`），区别于常规单色透明特征图 [[templates/scrna-feature-umap-grid]]，本模板提供高对比度置顶渲染与 `Min`/`Max` 端点色标。

## 数据要求

### cells（feature_umap_scores.csv）：单细胞 UMAP 坐标与多列连续特征/模块评分宽表（cell_id, umap_1, umap_2 及 2-9 个连续特征列） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell_id | str | 必需 | 细胞唯一标识 |
| umap_1 | float | 必需 | UMAP 横坐标 |
| umap_2 | float | 必需 | UMAP 纵坐标 |
| lpCAF | float | 可选 | 示例特征 1（可替换为任意基因或模块名） |
| mCAF | float | 可选 | 示例特征 2 |
| tCAF | float | 可选 | 示例特征 3 |
| ifnCAF | float | 可选 | 示例特征 4 |

### 可覆盖的 style

- `palette_mode`：`"module_spectral"`
- `ncol`：`2`
- `dot_size`：`0.62`
- `gamma`：`1.6`
- `dpi`：`300`
- `width_in`：`5.6`
- `height_in`：`4.8`

## 使用记录

<!-- user:start -->
<!-- user:end -->
