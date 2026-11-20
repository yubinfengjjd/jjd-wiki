---
type: template
id: rcn-horizontal-bar-pie
title: 邻域水平堆叠与功能饼图
status: ready
layouts: []
sources:
- methods/cell-proportion-composition
panels: []
language: python
primary_method: cell-proportion-composition
style_tier: variant
journal_style: Cancer Discovery
tags:
- single-cell
chart_types:
- stacked-bar-flow
keywords:
- RCN
- stacked-bar
- pie-chart
- cell-proportion
- Cancer Discovery
favorite: false
---
# 邻域水平堆叠与功能饼图

![[templates/rcn-horizontal-bar-pie/preview.png]]

<!-- facts:start -->
- 来源：[[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]
- 语言：python
- 标签：single-cell
- 图型：[[chart-types/stacked-bar-flow]]
- 输入接口：未声明 · 未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-21 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：邻域或聚类簇的细粒度细胞表型比例可导出为 variant 水平堆叠条形图（高亮靶细胞边框）+ 底部虚线框分组功能饼图；模板不重算邻域聚类或统计检验。；前提：每个邻域/分组的细胞表型比例与汇总功能大类比例按相同细胞集汇总归一化，且不混同描述性构成与样本级显著性推断。；适配：导出 rcn_phenotype_composition.csv 与 rcn_functional_pies.csv（按 RCN 键对齐）。
    - 关系证据：methods/cell-proportion-composition.md#输出；templates/rcn-horizontal-bar-pie/spec.json；templates/rcn-horizontal-bar-pie/verify/verify.json；运行证据：无
<!-- facts:end -->

## 适用

展示空间邻域（RCN1–10）或细胞聚类簇的细粒度细胞组成水平堆叠条形图（支持用红框高亮关键靶细胞类型如 `PD1+ CTL`），并在底部按功能大类（如 Epidermis、Myeloid enriched、Immune suppressive、T enriched、Melanocytic）以虚线分组框配对汇总饼图。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 2E 画风。

## 不适用

不适用于仅有两三组且需跨组连线流带的常规比例对比（请改用同槽位默认模板 [[templates/cell-prop-flow-bar]]），也不适用于双组织区室分层对比（请改用 [[templates/compartment-dual-track-bars]]）；本模板仅展示预汇总组成比例，不执行样本级统计检验。示例数据直接取自 `pmc9167783` 连续 FOV 实测 `fig2d_rcn_phenotype_composition.csv` 与 `fig2e_rcn_simplified_pie.csv`。

## 知识关联检查

2026-11-21：新建衍生风格模板主归属方法 [[methods/cell-proportion-composition]]，挂入输出槽位 `(cell-proportion-composition, stacked-bar-flow)`。因该槽位已存在标准默认模板 [[templates/cell-prop-flow-bar]]（`style_tier: default`），本模板置为 `style_tier: variant`（`journal_style: Cancer Discovery`），并与默认模板对齐受控英文标签 `[single-cell]`；与 [[templates/compartment-dual-track-bars]] 共同组成同槽位 3 画风切换。

## 数据要求

### bars（rcn_phenotype_composition.csv）：各空间邻域/分组的细胞类型构成比例矩阵（首列为邻域ID，其余列为各细胞表型比例） （模板内联表结构）

| 列 | 类型 | 含义 |
|---|---|---|
| RCN | str | 空间邻域或聚类分组编号 |

### pies（rcn_functional_pies.csv）：各空间邻域的汇总功能大类构成表（用于底部虚线框分组饼图） （模板内联表结构）

| 列 | 类型 | 含义 |
|---|---|---|
| RCN | str | 与 bars 表对齐的空间邻域编号 |

### 可覆盖的 style

- `id_col`：`"RCN"`
- `highlight_col`：`"PD1+ CTL"`
- `highlight_fill`：`"#E2E2E2"`
- `highlight_edge`：`"#C82829"`
- `bar_title`：`"RCN cell types"`
- `rcn_order`：`["RCN1", "RCN2", "RCN3", "RCN4", "RCN5", "RCN6", "RCN7", "RCN8", "RCN9", "RCN10"]`
- `pie_box_groups`：`[{"title": "Epidermis", "items": ["RCN1"]}, {"title": "Myeloid enriched", "items": ["RCN2", "RCN3", "RCN4"]}, {"title": "Immune suppressive", "items": ["RCN5", "RCN8"]}, {"title": "T enriched", "items": ["RCN6", "RCN7"]}, {"title": "Melanocytic", "items": ["RCN9", "RCN10"]}]`
- `dpi`：`300`
- `width_in`：`4.4`
- `height_in`：`6.4`
- `rect`：`[0.13, 0.04, 0.83, 0.91]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
