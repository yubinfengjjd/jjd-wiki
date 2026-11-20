---
type: template
id: tri-panel-stage-umap
title: 三联分群分期患者 UMAP
status: ready
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
- cell-type
- progression-stage
- Cancer Discovery
favorite: false
---
# 三联分群分期患者 UMAP

![[templates/tri-panel-stage-umap/preview.png]]

<!-- facts:start -->
- 来源：[[methods/cell-type-annotation|细胞类型注释]]
- 语言：python
- 标签：single-cell
- 图型：[[chart-types/umap]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/cell-type-annotation|细胞类型注释]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：注释后的单细胞/空间蛋白组细胞类型标签可与进展分期、患者 ID 合并导出为 Cancer Discovery 风格三联 UMAP 变体；模板不执行注释。；前提：umap_1/umap_2 与 cell_type、stage、patient_id 来自同一质控后对象；cell_id 唯一。；适配：导出 umap_tripanel_cells.csv（cell_id, umap_1, umap_2, cell_type, stage, patient_id）。
    - 关系证据：methods/cell-type-annotation.md#输出；templates/tri-panel-stage-umap/spec.json；运行证据：无
  - [[methods/dimensionality-reduction|单细胞降维分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：降维生成的 UMAP 坐标可联合细胞类型、进展分期与患者编号按 Cancer Discovery 风格三联并排展示；模板不重算 UMAP。；前提：坐标与三列离散注释来自同一降维对象；cell_id 唯一且坐标无 NA。；适配：导出 umap_tripanel_cells.csv（cell_id, umap_1, umap_2, cell_type, stage, patient_id）。
    - 关系证据：methods/dimensionality-reduction.md#输出；templates/tri-panel-stage-umap/spec.json；运行证据：无
<!-- facts:end -->

## 适用

同一单细胞降维坐标（`umap_1, umap_2`）按**细胞类型（`cell_type`）、疾病演进分期（`stage`）与患者/供体编号（`patient_id`）**三联并排着色展示，用于直观核查细胞分群边界是否与疾病分期一致且不被单个患者批次效应主导。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 2A 风格。

## 不适用

不适用于单一维度的基础细胞类型展示（请改用默认模板 [[templates/scrna-celltype-umap]]），也不适用于连续基因/蛋白表达强度分布（请用 [[templates/scrna-feature-umap-grid]]）；示例数据来自 HTA-MELATLAS-1 S3 5 例患者分层抽样 QC 后 1,987 个真实 Panel 2 单细胞，不能代替百万级全切片样本量。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/cell-type-annotation]]，与 [[methods/dimensionality-reduction]] 共同适配；采用 `style_tier: variant` 与现有默认/普通 UMAP 模板区分，无槽位冲突。

## 数据要求

### cells（umap_tripanel_cells.csv）：单细胞 UMAP 坐标与三列离散注释表（细胞类型、进展分期、患者编号） （模板内联表结构）

| 列 | 类型 | 含义 |
|---|---|---|
| cell_id | str | 细胞唯一标识 |
| umap_1 | float | UMAP 横坐标 |
| umap_2 | float | UMAP 纵坐标 |
| cell_type | str | 第一面板细胞类型注释 |
| stage | str | 第二面板进展分期/分组 |
| patient_id | str | 第三面板患者/样本编号 |

### 可覆盖的 style

- `panel1_col`：`"cell_type"`
- `panel2_col`：`"stage"`
- `panel3_col`：`"patient_id"`
- `panel_titles`：`["UMAP by cell type", "UMAP by stage", "UMAP by patient"]`
- `point_size`：`4.5`
- `alpha`：`0.78`
- `dpi`：`300`
- `width_in`：`8.8`
- `height_in`：`2.75`
- `rect`：`[0.04, 0.1, 0.8, 0.78]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
