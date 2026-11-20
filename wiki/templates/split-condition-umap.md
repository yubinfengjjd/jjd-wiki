---
type: template
id: split-condition-umap
title: 双条件并排分面亚群 UMAP
status: ready
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
- condition-split
- stromal-subcluster
- Normal-vs-Tumor
favorite: false
---
# 双条件并排分面亚群 UMAP

![[templates/split-condition-umap/preview.png]]

<!-- facts:start -->
- 来源：[[methods/cell-type-annotation|细胞类型注释]]
- 语言：r
- 标签：single-cell
- 图型：[[chart-types/umap]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/cell-type-annotation|细胞类型注释]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：注释后的精细细胞亚群可按组织/实验条件（如 Normal vs Tumor）并排分面展示（灰色全集背景 + 当前条件高亮彩点）；模板不执行注释。；前提：umap_1/umap_2、subcluster 与 condition 来自同一整合注释对象；cell_id 唯一。；适配：导出 split_condition_umap_cells.csv（cell_id, umap_1, umap_2, subcluster, condition）。
    - 关系证据：methods/cell-type-annotation.md#输出；templates/split-condition-umap/spec.json；运行证据：无
<!-- facts:end -->

## 适用

将同一单细胞降维流形按组织/实验条件（如 Adjacent normal tissue vs Tumor）并排拆分为多子图：每个子图以浅灰全集流形（`#DCDCDC`）为背景衬底，仅高亮当前条件下的细胞亚群彩点，并在左下角绘制 L 形坐标短箭头，底部排布多列圆点亚群图例。对应 Cai et al. (*npj Precision Oncology*, 2026) Fig. 2A / 4A / 5A 画风。

## 不适用

不适用于单一整体细胞类型展示（请用默认模板 [[templates/scrna-celltype-umap]]）或含红色功能包络的整体图谱（请用 [[templates/stromal-hull-umap]]）；各条件细胞数差异悬殊时仅反映采样分布，不等同于统计学丰度显著性检验（请配合 [[templates/roe-cox-heatmap]] 或 [[templates/tissue-ratio-prop-combo]]）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/cell-type-annotation]]，挂入 `(cell-type-annotation, umap)` 输出槽位（`style_tier: variant`, `journal_style: Cai2026-npjPO`），与同槽位默认模板 [[templates/scrna-celltype-umap]]、包络变体 [[templates/stromal-hull-umap]] 及三联分期变体 [[templates/tri-panel-stage-umap]] 共享受控主标签 `single-cell` 并支持一键切换。

## 数据要求

### cells（split_condition_umap_cells.csv）：单细胞 UMAP 坐标、精细亚群与条件分组表（cell_id, umap_1, umap_2, subcluster, condition） （模板内联表结构）

| 列 | 类型 | 含义 |
|---|---|---|
| cell_id | str | 细胞唯一标识 |
| umap_1 | float | UMAP 横坐标 |
| umap_2 | float | UMAP 纵坐标 |
| subcluster | str | 细胞亚群名称 |
| condition | str | 并排分面条件标签（如 Adjacent normal tissue / Tumor） |

### 可覆盖的 style

- `bg_color`：`"#DCDCDC"`
- `dot_size`：`0.65`
- `legend_cols`：`2`
- `dpi`：`300`
- `width_in`：`6.2`
- `height_in`：`4.8`

## 使用记录

<!-- user:start -->
<!-- user:end -->
