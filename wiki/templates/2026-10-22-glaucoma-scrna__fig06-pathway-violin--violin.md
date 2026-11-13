---
type: template
id: 2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin
title: 分组小提琴图（含统计标注）
status: ready
layouts:
- 2026-10-22-glaucoma-scrna__fig06-pathway-violin
panels:
- A
language: r
tags:
- 单细胞分析
- 实验统计
chart_types:
- violin
favorite: false
keywords:
- GSE251716
- pathway
---
# 分组小提琴图（含统计标注）

![[templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/preview.png]]

<!-- facts:start -->
- 来源：[[layouts/2026-10-22-glaucoma-scrna__fig06-pathway-violin|分组小提琴与统计标注（GSE251716）]]
- 面板（来源版式）：A
- 语言：r
- 标签：单细胞分析、实验统计
- 图型：[[chart-types/violin]]
- 输入接口：[[interfaces/render-grouped-values|分组细胞级数值表]] · [[interfaces/render-group-summaries|预计算分组分布摘要表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/cell-quality-control|单细胞质量控制]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：QC 指标按样本或细胞类型分组的分布可用分组小提琴展示；模板不重算阈值。；前提：每个值有明确的采样单位（细胞或样本）；细胞级分布不能当样本级推断。；p/mean/SD 若展示，必须由分析阶段预计算并说明来源。；适配：导出 render-grouped-values.csv 和可选的 render-group-summaries.csv。
    - 关系证据：methods/cell-quality-control.md#输出；methods/scp-cellqc-doublet.md#知识关联检查；methods/scp-cellqc-doublet.md#输出；templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/spec.json；templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/verify/verify.json；运行证据：无
  - [[methods/dynamic-feature-analysis|拟时序动态特征分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：动态特征或 pseudotime 按 cluster/lineage 分组的分布可用分组小提琴展示；模板不做轨迹或检验。；前提：同一 pseudotime/lineage 定义；celltype/group 标签一致。；p/mean/SD 若展示，由分析阶段预计算；细胞级 p 不能当样本级推断。；适配：导出 render-grouped-values.csv（group=cluster/lineage, value=特征值/pseudotime）。
    - 关系证据：methods/dynamic-feature-analysis.md#输出；methods/scp-trajectory-velocity.md#知识关联检查；methods/scp-trajectory-velocity.md#输出；templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/spec.json；templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/verify/verify.json；运行证据：无
  - [[methods/gene-set-scoring|基因集与通路签名打分]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：通路签名分数按细胞类型/组展示分布，可复用小提琴模板；模板不重算分数或检验。；前提：同一 pathway 定义和单位；celltype/group 标签一致。；p/mean/SD 由分析阶段预计算并说明来源；细胞水平 p 仅作描述，不能当样本级推断。；适配：导出 render-grouped-values.csv 和可选的 render-group-summaries.csv；细胞级 p 只作描述。
    - 关系证据：methods/gene-set-scoring.md#输出；methods/scrna-pathway-signature-ensemble.md#知识关联检查；methods/scrna-pathway-signature-ensemble.md#输出；layouts/2026-10-22-glaucoma-scrna__fig06-pathway-violin.md#适用；templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/spec.json；templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/verify/verify.json；运行证据：无
  - [[methods/trajectory-inference|拟时序与轨迹推断]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：pseudotime 按 cluster/lineage 分组的分布可用分组小提琴展示；模板不做轨迹或检验。；前提：同一 pseudotime/lineage 定义；celltype/group 标签一致。；p/mean/SD 若展示，由分析阶段预计算；细胞级 p 不能当样本级推断。；适配：导出 render-grouped-values.csv（celltype/group, value=pseudotime）。
    - 关系证据：methods/trajectory-inference.md#输出；methods/scp-trajectory-velocity.md#知识关联检查；methods/scp-trajectory-velocity.md#输出；templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/spec.json；templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/verify/verify.json；运行证据：无
<!-- facts:end -->

## 适用

分组分布展示：输入细胞级 `celltype, group, value` 长表 + 预计算 `celltype, group, mean, sd, p_label, p_y, mean_sd_label, mean_y` 摘要。画小提琴 + 箱线 + 抖动、双色分组、每个细胞类型的 p 标签和 Mean/SD 标签。组数/类别数由 `style.group_levels`/`celltype_levels` 控制（示例 2 组×9 类）；换数据必须覆盖或置空，否则新类别会被丢弃。

## 不适用

没有预计算摘要或需要模板自行跑检验；细胞不独立/每组只有 1 个样本时不能做组间推断；不能把 p 标签当因果或样本级显著性。模板只画预计算值，不计算 p 值、均值或 SD；p 值来源必须在图注/方法页说明。

## 知识关联检查

2026-10-22 查过 [[methods/scrna-pathway-signature-ensemble|M3 通路打分与组间比较]] 和小提琴图型页。M3 可产出 `render-grouped-values` 与 `render-group-summaries`；M4 的 Wilcoxon 已并入 M3，不单独成方法页（按 2026-10-22 规则）。示例为合成数据，p 标签为描述性；方法侧关系已登记为 adaptable；模板只读接口表，不重算分析。

## 数据要求

### values（render-grouped-values.csv）：细胞级或样本级分组数值 [[interfaces/render-grouped-values|分组细胞级数值表]]

| 列 | 类型 | 含义 |
|---|---|---|
| celltype | str | 细胞类型或类别；x 轴 |
| group | str | 比较组；用于小提琴/箱线/散点分组 |
| value | float | 细胞级或样本级数值；采样单位由课题说明 |

### summaries（render-group-summaries.csv）：预计算 mean/SD/p 标签和标注位置；模板不重算检验 [[interfaces/render-group-summaries|预计算分组分布摘要表]]

| 列 | 类型 | 含义 |
|---|---|---|
| celltype | str | 细胞类型或类别；与值表一一对应 |
| group | str | 比较组；与值表一一对应 |
| mean | float | 上游给定的组内均值 |
| sd | float | 上游给定的组内标准差 |
| p_label | str | 上游给定的 p 值标签；模板不重算检验 |
| p_y | float | p 标签的 y 位置，由上游给定 |
| mean_sd_label | str | 上游给定的 Mean/SD 文本标签 |
| mean_y | float | Mean/SD 标签的 y 位置，由上游给定 |

### 可覆盖的 style

- `font_family`：`"sans"`
- `dpi`：`192`
- `width_in`：`12`
- `height_in`：`6.5`
- `sizing`：`mode` 为 `adaptive`（换数据）或 `fixed`（固定示例回放）；base/per-item/min/max 参数见 `spec.json`。
- `celltype_levels`：`["Muller_Glia", "Rod_Photoreceptor", "Bipolar", "Cone_Photoreceptor", "RGC_like", "RPE", "Vascular_Pericyte", "Amacrine", "Amacrine_Horizontal_like"]`
- `group_levels`：`["Control", "Glaucoma"]`
- `color_scheme`：`["#FF7F0E", "#1F77B4"]`
- `title`：`"Complement Pathway Score Comparison"`
- `ylab`：`"Pathway Score"`
- `dodge_width`：`0.8`
- `violin_width`：`0.7`
- `box_width`：`0.18`
- `jitter_width`：`0.18`

## 使用记录

2026-10-22 建模板；R 4.3.1 回放通过；preview 已生成；p 标签统计局限已记录。
2026-10-22 作者确认模板可用；补 adaptive sizing，固定示例用 `example/style.json` 的 fixed 模式；jitter 固定 seed，使回放可重复；`check-entry --record` 已更新。

<!-- user:start -->
<!-- user:end -->
