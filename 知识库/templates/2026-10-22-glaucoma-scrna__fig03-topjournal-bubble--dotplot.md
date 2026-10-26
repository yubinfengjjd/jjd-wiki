---
type: template
id: 2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot
title: 细胞类型 × 基因气泡点图
status: ready
layouts:
- 2026-10-22-glaucoma-scrna__fig03-topjournal-bubble
panels:
- A
language: r
tags:
- 单细胞分析
chart_types:
- dotplot
favorite: false
keywords:
- GSE251716
- dotplot
---
# 细胞类型 × 基因气泡点图

![[templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot/preview.png]]

<!-- facts:start -->
- 来源版式：[[layouts/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble|顶刊样式气泡点图（GSE251716）]]
- 面板（来源版式）：A
- 语言：r
- 标签：单细胞分析
- 图型：[[chart-types/dotplot]]
- 输入接口：[[interfaces/render-dotplot-long|细胞类型 × 基因点图表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/cell-type-annotation|细胞类型注释]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：预测类型的 marker 平均表达/阳性比例可整理成点图，检查注释是否合理；模板不重算统计。；前提：avg_expression 与 pct_expressed 由表达矩阵按预测标签计算；缩放方式说明。；group/feature 顺序由课题给出；target_group 只用于排序。；适配：导出 render-dotplot-long.csv（group, feature, avg_expression, pct_expressed, target_group）。
    - 关系证据：methods/cell-type-annotation.md#输出；methods/scp-annotation-projection.md#知识关联检查；methods/scp-annotation-projection.md#输出；templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot/spec.json；templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot/verify/verify.json；运行证据：无
  - [[methods/differential-expression|差异表达分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：DE 选出的 marker 可整理成 group/feature/avg_expression/pct_expressed，复用气泡点图；模板不重算 DE。；前提：avg_expression 与 pct_expressed 由表达矩阵按组计算，不能用 avg_log2FC 代替。；group/feature 顺序由课题给出；target_group 只用于排序。；适配：导出 render-dotplot-long.csv（group, feature, avg_expression, pct_expressed, target_group）。
    - 关系证据：methods/differential-expression.md#输出；methods/scp-de-enrichment-dynamic.md#知识关联检查；methods/scp-de-enrichment-dynamic.md#输出；templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot/spec.json；templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot/verify/verify.json；运行证据：无
<!-- facts:end -->

## 适用

细胞类型 × 基因的气泡点图：输入 `group, feature, avg_expression, pct_expressed`，可选 `target_group` 用于基因排序。画灰底黑框、底部细胞类型色块、旋转 x 标签、斜体基因名、Relative Expression 渐变和 Percentage Expressed 大小图例。组数由 `style.x_levels` 控制（示例固定 9 组），换数据必须覆盖或置空；基因数由数据识别。

## 不适用

没有平均表达/阳性比例表；需要差异检验或显著性标注；基因数过多导致 y 标签不可读；不能把颜色或气泡大小当统计显著性。`avg_expression` 若是 scaled data，必须与原始表达区分并在图注说明。

## 知识关联检查

2026-10-22 查过 [[methods/scrna-marker-annotation|M2 注释]] 和点图图型页。M2 产出 `render-dotplot-long` 所需的 group/feature/avg/pct 表；同一数据也可画 SCpubr 点图，但作者确认只保留本顶刊气泡样式。示例为合成数据；方法侧关系已登记为 adaptable；模板只读接口表，不重算分析。

## 数据要求

### dotplot（render-dotplot-long.csv）：细胞类型 × 基因的平均表达和阳性比例；target_group 仅用于基因排序 [[interfaces/render-dotplot-long|细胞类型 × 基因点图表]]

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| group | str | 必需 | 细胞类型或分组；点图 x 轴 |
| feature | str | 必需 | 基因/marker 名称；点图 y 轴 |
| avg_expression | float | 必需 | 该组该基因的平均表达；缩放方式由课题说明 |
| pct_expressed | float | 必需 | 该组该基因的阳性细胞百分比，0–100 |
| target_group | str | 可选 | 该基因对应的目标细胞类型，可为空；仅用于基因排序 |

### 可覆盖的 style

- `font_family`：`"sans"`
- `dpi`：`192`
- `width_in`：`6`
- `height_in`：`12`
- `sizing`：`{"mode": "adaptive", "base_width_in": 3.0, "per_x_in": 0.3, "base_height_in": 2.0, "per_y_in": 0.2, "min_width_in": 6, "min_height_in": 5, "base_label_chars": 10, "per_label_char_in": 0.1, "aspect": null, "max_width_in": null, "max_height_in": null}`
- `x_levels`：`["Muller_Glia", "Rod_Photoreceptor", "Bipolar", "Cone_Photoreceptor", "RGC_like", "RPE", "Vascular_Pericyte", "Amacrine", "Amacrine_Horizontal_like"]`
- `expr_limits`：`[0, 1]`
- `expr_breaks`：`[0, 0.25, 0.5, 0.75, 1]`
- `size_limits`：`[0, 100]`
- `size_breaks`：`[25, 50, 75]`
- `size_range`：`[1.2, 7.0]`
- `panel_fill`：`"#F2F2F2"`
- `italic_y`：`true`
- `expr_palette`：`["#083B6F", "#3B8FC2", "#D9EEF4", "#F6F3EA", "#F07C56", "#8A001F"]`
- `x_colors`：`["#F2A000", "#37B7AE", "#13A25B", "#F0DB35", "#1C9AD6", "#D65F00", "#AEB0B4", "#C98CB7", "#E64B35"]`

## 使用记录

2026-10-22 建模板；R 4.3.1 回放通过；preview 已生成。
2026-10-22 作者确认模板可用；补 adaptive sizing，固定示例用 `example/style.json` 的 fixed 模式；`check-entry --record` 已更新。

<!-- user:start -->
<!-- user:end -->
