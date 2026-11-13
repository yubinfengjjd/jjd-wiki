---
type: template
id: 2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow
title: 细胞比例堆叠流带图
status: ready
layouts:
- 2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow
panels:
- A
language: r
tags:
- 单细胞分析
chart_types:
- stacked-bar-flow
favorite: false
keywords:
- GSE251716
- proportion
---
# 细胞比例堆叠流带图

![[templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/preview.png]]

<!-- facts:start -->
- 来源：[[layouts/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow|细胞比例堆叠与流带（GSE251716）]]
- 面板（来源版式）：A
- 语言：r
- 标签：单细胞分析
- 图型：[[chart-types/stacked-bar-flow]]
- 输入接口：[[interfaces/render-cell-proportions|细胞类型比例表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/batch-integration|单细胞批次整合]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：按 batch/样本统计细胞类型比例，可检查整合前后组成是否被过度改变；模板不做统计检验。；前提：每个 group 的比例归一化到 1；group 为 batch/样本，celltype 为注释类型。；比例是描述性；组间差异不能由该图直接推断。；适配：导出 render-cell-proportions.csv（group, celltype, proportion）；比例只作描述。
    - 关系证据：methods/batch-integration.md#输出；methods/scp-integration.md#知识关联检查；methods/scp-integration.md#输出；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/spec.json；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/verify/verify.json；运行证据：无
  - [[methods/cell-clustering|单细胞聚类分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：按样本/条件统计 cluster 比例，检查组成；模板不做聚类或检验。；前提：每个 group 的比例归一化到 1；group/celltype 完整，无缺组。；流带仅作视觉插值，不是统计估计或细胞轨迹。；适配：导出 render-cell-proportions.csv（group=样本, celltype=cluster, proportion）。
    - 关系证据：methods/cell-clustering.md#输出；methods/scrna-marker-annotation.md#知识关联检查；methods/scrna-marker-annotation.md#输出；layouts/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow.md#适用；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/spec.json；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/verify/verify.json；运行证据：无
  - [[methods/cell-quality-control|单细胞质量控制]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：按样本/条件统计 QC Pass/Fail 比例，可复用比例堆叠与流带模板；模板不做统计检验。；前提：每个 group 的 celltype 比例归一化到 1；group 为样本或条件，celltype 为 CellQC。；组间比较只作描述，不能当样本级推断。；适配：导出 render-cell-proportions.csv（group, celltype, proportion）；比例只作描述。
    - 关系证据：methods/cell-quality-control.md#输出；methods/scp-cellqc-doublet.md#知识关联检查；methods/scp-cellqc-doublet.md#输出；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/spec.json；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/verify/verify.json；运行证据：无
  - [[methods/cell-type-annotation|细胞类型注释]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：按样本/条件统计预测类型比例，检查注释组成；模板不做统计检验。；前提：每个 group 的比例归一化到 1；group 为样本/条件，celltype 为预测标签。；比例是描述性；组间差异不能由该图直接推断。；适配：导出 render-cell-proportions.csv（group, celltype, proportion）。
    - 关系证据：methods/cell-type-annotation.md#输出；methods/scp-annotation-projection.md#知识关联检查；methods/scp-annotation-projection.md#输出；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/spec.json；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/verify/verify.json；运行证据：无
  - [[methods/doublet-detection|双细胞检测]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：按样本统计双细胞比例可复用比例图；模板不做双细胞检测或统计检验。；前提：每个 group 的 celltype 比例归一化到 1；group 为样本或条件，celltype 为 CellQC。；组间比较只作描述，不能当样本级推断。；适配：导出 render-cell-proportions.csv（group=样本, celltype=doublet class, proportion）。
    - 关系证据：methods/doublet-detection.md#输出；methods/scp-cellqc-doublet.md#知识关联检查；methods/scp-cellqc-doublet.md#输出；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/spec.json；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/verify/verify.json；运行证据：无
  - [[methods/reference-mapping|参考图谱映射]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：按样本统计预测标签比例，检查映射组成；模板不做映射或检验。；前提：每个 group 的比例归一化到 1；group 为样本/条件，celltype 为预测标签。；比例是描述性；组间差异不能由该图直接推断。；适配：导出 render-cell-proportions.csv（group=样本, celltype=predicted label, proportion）。
    - 关系证据：methods/reference-mapping.md#输出；methods/scp-annotation-projection.md#知识关联检查；methods/scp-annotation-projection.md#输出；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/spec.json；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/verify/verify.json；运行证据：无
<!-- facts:end -->

## 适用

两组或多组的细胞类型比例展示：输入 `group, celltype, proportion`，每组比例可归一化到 1。画堆叠柱 + 相邻组流带、右侧逆序图例、y 轴 0–1。组数/细胞类型数由 `style.x_levels`/`stack_levels` 控制（示例 2×9）；换数据必须覆盖或置空。

## 不适用

比例未按组归一化或存在缺组；需要组间统计检验；组数过多导致流带不可读；不能把流带当细胞轨迹、统计估计或因果变化。流带只是相邻柱的视觉插值。

## 知识关联检查

2026-10-22 查过 [[methods/scrna-marker-annotation|M2 注释]] 和比例图图型页。M2 可导出 `cell-proportions.csv`；本模板只画比例，不做检验。示例为合成数据；方法侧关系已登记为 adaptable；模板只读接口表，不重算分析。

## 数据要求

### proportions（render-cell-proportions.csv）：每组细胞类型比例；每组应归一化到 1 [[interfaces/render-cell-proportions|细胞类型比例表]]

| 列 | 类型 | 含义 |
|---|---|---|
| group | str | 样本或条件分组；x 轴 |
| celltype | str | 细胞类型；堆叠/流带类别 |
| proportion | float | 该组内该细胞类型的比例；每组应归一化到 1 |

### 可覆盖的 style

- `font_family`：`"sans"`
- `dpi`：`192`
- `width_in`：`5.5`
- `height_in`：`4.5`
- `sizing`：`mode` 为 `adaptive`（换数据）或 `fixed`（固定示例回放）；base/per-item/min/max 参数见 `spec.json`。
- `x_levels`：`["Control", "Glaucoma"]`
- `stack_levels`：`["Muller_Glia", "Rod_Photoreceptor", "Bipolar", "Cone_Photoreceptor", "RGC_like", "RPE", "Vascular_Pericyte", "Amacrine", "Amacrine_Horizontal_like"]`
- `legend_levels`：`["Amacrine_Horizontal_like", "Amacrine", "Vascular_Pericyte", "RPE", "RGC_like", "Cone_Photoreceptor", "Bipolar", "Rod_Photoreceptor", "Muller_Glia"]`
- `palette`：`["#E64B35", "#4DBBD5", "#00A087", "#3C5488", "#F39B7F", "#8491B4", "#91D1C2", "#DC0000", "#7E6148"]`
- `normalize`：`true`
- `bar_width`：`0.36`
- `flow_alpha`：`0.22`
- `bar_alpha`：`0.92`
- `flow_n`：`120`
- `y_lab`：`"Cell proportion"`
- `legend_title`：`"Cell type"`

## 使用记录

2026-10-22 建模板；R 4.3.1 回放通过；preview 已生成。
2026-10-22 作者确认模板可用；补 adaptive sizing，固定示例用 `example/style.json` 的 fixed 模式；`check-entry --record` 已更新。

<!-- user:start -->
<!-- user:end -->
