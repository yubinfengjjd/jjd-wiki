---
type: template
id: cycif-feature-umap-strip
title: 多标志物连续蛋白强度 UMAP 条带
status: draft
layouts: []
sources:
- methods/cell-type-annotation
panels: []
language: python
primary_method: cell-type-annotation
style_tier: variant
journal_style: Cancer Discovery
tags:
- single-cell
chart_types:
- umap
keywords:
- UMAP
- CyCIF
- protein-intensity
- feature-strip
favorite: false
---
# 多标志物连续蛋白强度 UMAP 条带

![[templates/cycif-feature-umap-strip/preview.png]]

<!-- facts:start -->
- 来源：[[methods/cell-type-annotation|细胞类型注释]]
- 语言：python
- 标签：single-cell
- 图型：[[chart-types/umap]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/cell-type-annotation|细胞类型注释]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：空间蛋白组（CyCIF）或单细胞的多标志物 [0, 1] 归一化强度可按 Cancer Discovery 蓝-灰-红连续色阶条带并排展示。；前提：各标志物列已完成对数转换与 [0, 1] 范围缩放；坐标与强度同源。；适配：导出 cycif_umap_markers.csv（cell_id, umap_1, umap_2 及多标志物归一化强度列）。
    - 关系证据：methods/cell-type-annotation.md#输出；templates/cycif-feature-umap-strip/spec.json；运行证据：无
<!-- facts:end -->

## 适用

将多重空间蛋白组（CyCIF/CODEX/IMC）或单细胞谱系的多个关键标志物归一化荧光强度（`[0, 1]`）按水平条带或网格并排投影在 UMAP 上，采用《Cancer Discovery》标志性的冷蓝-浅灰-深红（`#3B75AF -> #EAEAEA -> #B2182B`）连续发散色阶与右侧共享 `Intensity` 色标条。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 2B / 1D 画风。

## 不适用

不适用于离散细胞类型注释着色（请用 [[templates/tri-panel-stage-umap]] 或 [[templates/scrna-celltype-umap]]）；输入特征值须已完成对数转换与 `[0, 1]` 归一化。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/cell-type-annotation]]，挂入 `(cell-type-annotation, umap)` 输出槽位（`style_tier: variant`, `journal_style: Cancer Discovery`），与同槽位 `Cai2026-npjPO` 特征网格 [[templates/feature-umap-contrast-grid]] 及标准特征网格 [[templates/scrna-feature-umap-grid]] 并列提供不同顶刊配色方案。

## 数据要求

### cells（cycif_umap_markers.csv）：单细胞 UMAP 坐标与多列归一化蛋白/基因强度宽表（cell_id, umap_1, umap_2 及多个标志物列） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell_id | str | 必需 | 细胞唯一标识 |
| umap_1 | float | 必需 | UMAP 横坐标 |
| umap_2 | float | 必需 | UMAP 纵坐标 |
| SOX10 | float | 可选 | SOX10 归一化强度 |
| CD11C | float | 可选 | CD11C 归一化强度 |
| FOXP3 | float | 可选 | FOXP3 归一化强度 |
| CD8A | float | 可选 | CD8A 归一化强度 |
| PDL1 | float | 可选 | PDL1 归一化强度 |
| PD1 | float | 可选 | PD1 归一化强度 |

### 可覆盖的 style

- `header_title`：`"Marker intensities across all specimens"`
- `point_size`：`2.4`
- `alpha`：`0.84`
- `dpi`：`300`
- `width_in`：`7.6`
- `height_in`：`2.2`
- `rect`：`[0.03, 0.08, 0.92, 0.72]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
