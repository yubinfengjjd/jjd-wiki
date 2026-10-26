---
type: template
id: 2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap
title: marker 特征 UMAP 小多图
status: ready
layouts:
- 2026-10-22-glaucoma-scrna__fig02-marker-feature-umap
panels:
- A
language: r
tags:
- 单细胞分析
chart_types:
- umap
favorite: false
keywords:
- GSE251716
- marker
---
# marker 特征 UMAP 小多图

![[templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/preview.png]]

<!-- facts:start -->
- 来源版式：[[layouts/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap|marker 特征 UMAP 小多图（GSE251716）]]
- 面板（来源版式）：A
- 语言：r
- 标签：单细胞分析
- 图型：[[chart-types/umap]]
- 输入接口：[[interfaces/render-umap-feature-long|UMAP 坐标与特征长表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/cell-type-annotation|细胞类型注释]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：用 marker 表达检查预测标签是否落在对应群，可复用特征 UMAP 网格；模板不做注释或检验。；前提：marker 表达长表与 UMAP 坐标同源；cell_id 一致。；每个 feature 至少有一个正表达细胞；目标类型在 group 中存在。；适配：导出 render-umap-feature-long.csv（cell_id, umap_1, umap_2, group, feature, value）。
    - 关系证据：methods/cell-type-annotation.md#输出；methods/scp-annotation-projection.md#知识关联检查；methods/scp-annotation-projection.md#输出；templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/verify/verify.json；运行证据：无
  - [[methods/dimensionality-reduction|单细胞降维分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：降维嵌入可与 marker 表达长表拼成特征 UMAP 网格；模板不重做降维或表达。；前提：UMAP 坐标与表达来自同一 Seurat 对象；cell_id 一致。；目标细胞类型映射由注释步骤给出；每个 feature 至少有一个正表达细胞。；适配：导出 render-umap-feature-long.csv（cell_id, umap_1, umap_2, group, feature, value）。
    - 关系证据：methods/dimensionality-reduction.md#输出；methods/scp-standard-workflow.md#知识关联检查；methods/scp-standard-workflow.md#输出；templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/verify/verify.json；运行证据：无
  - [[methods/dynamic-feature-analysis|拟时序动态特征分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：动态特征值可作为 feature 长表画在 UMAP 上；模板只画值，不拟合 GAM。；前提：值与 UMAP 坐标来自同一细胞集合；cell_id 一致。；value 的含义/单位明确；无 NA。；适配：导出 render-umap-feature-long.csv（feature=基因/特征, value=表达或拟合值）。
    - 关系证据：methods/dynamic-feature-analysis.md#输出；methods/scp-de-enrichment-dynamic.md#知识关联检查；methods/scp-de-enrichment-dynamic.md#输出；templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/verify/verify.json；运行证据：无
  - [[methods/trajectory-inference|拟时序与轨迹推断]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：pseudotime 可作为 feature 长表画在 UMAP 上；模板不拟合轨迹。；前提：值与 UMAP 坐标来自同一细胞集合；cell_id 一致。；value 的含义/单位明确；无 NA。；适配：导出 render-umap-feature-long.csv（feature=pseudotime, value=Lineage1）。
    - 关系证据：methods/trajectory-inference.md#输出；methods/scp-trajectory-velocity.md#知识关联检查；methods/scp-trajectory-velocity.md#输出；templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap/verify/verify.json；运行证据：无
<!-- facts:end -->

## 适用

多个 marker 在同一 UMAP 上的小多图：输入 `cell_id, umap_1, umap_2, group, feature, value` 长表；每个小图保留灰底、表达渐变、目标群虚线轮廓、独立 colorbar 和短箭头。基因数/网格列数由 style 识别，示例 9 个基因不是限制。

## 不适用

没有坐标或表达长表；基因全为零；基因/组数过多导致网格不可读；不能把特征图当差异表达或统计检验。不同基因的 colorbar 各自裁剪 q05/q98，不能比较绝对表达量。

## 知识关联检查

2026-10-22 查过 [[methods/scrna-preprocess-doublet-qc-harmony|M1]]、[[methods/scrna-marker-annotation|M2]] 和 UMAP 图型页。M1 提供坐标，M2 提供 marker→目标细胞类型映射。示例为合成数据；模板回放只说明画法可运行，不证明真实 marker 特异性。方法侧关系已登记为 adaptable；模板只读接口表，不重算分析。

## 数据要求

### feature_umap（render-umap-feature-long.csv）：UMAP 坐标 + 基因表达长表 + 细胞类型；同一图内来自同一嵌入 [[interfaces/render-umap-feature-long|UMAP 坐标与特征长表]]

| 列 | 类型 | 含义 |
|---|---|---|
| cell_id | str | 细胞标识；同一图内唯一 |
| umap_1 | float | UMAP 第一维坐标 |
| umap_2 | float | UMAP 第二维坐标 |
| group | str | 细胞类型或分组；用于背景点和目标群轮廓 |
| feature | str | 基因/marker 名称 |
| value | float | 该细胞在该 feature 上的表达值；0 表示不画前景点 |

### 可覆盖的 style

- `font_family`：`"sans"`
- `dpi`：`192`
- `width_in`：`11`
- `height_in`：`10`
- `sizing`：`mode` 为 `adaptive`（换数据）或 `fixed`（固定示例回放）；base/per-item/min/max 参数见 `spec.json`。
- `ncol`：`3`
- `genes`：`["Pou4f1", "Gad1", "Onecut1", "Vsx2", "Rho", "Opn1mw", "Glul", "Rpe65", "Pdgfrb"]`
- `gene_to_group`：`{"Pou4f1": "RGC_like", "Gad1": "Amacrine", "Onecut1": "Amacrine_Horizontal_like", "Vsx2": "Bipolar", "Rho": "Rod_Photoreceptor", "Opn1mw": "Cone_Photoreceptor", "Glul": "Muller_Glia", "Rpe65": "RPE", "Pdgfrb": "Vascular_Pericyte"}`
- `bg_color`：`"#CFCFCF"`
- `pt_size_bg`：`0.24`
- `pt_size_fg`：`0.3`
- `alpha_bg`：`0.32`
- `alpha_fg`：`0.96`
- `exp_palette`：`["#74B8AF", "#CFE0C7", "#F1E8AE"]`
- `min_cutoff`：`"q05"`
- `max_cutoff`：`"q98"`
- `title_size`：`13.5`
- `legend_text_size`：`7`
- `xpad_ratio`：`0.018`
- `ypad_ratio`：`0.018`
- `panel_margin`：`7`

## 使用记录

2026-10-22 建模板；R 4.3.1 回放通过；preview 已生成；小多图 panel 尺寸/间距为已知差异。
2026-10-22 作者确认模板可用；补 adaptive sizing，固定示例用 `example/style.json` 的 fixed 模式；`check-entry --record` 已更新。

<!-- user:start -->
<!-- user:end -->
