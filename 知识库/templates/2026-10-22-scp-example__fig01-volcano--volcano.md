---
type: template
id: 2026-10-22-scp-example__fig01-volcano--volcano
title: 差异表达火山图
status: ready
layouts:
- 2026-10-22-scp-example__fig01-volcano
panels:
- A
language: r
tags:
- 单细胞分析
keywords:
- SCP
- pancreas_sub
- volcano
- DE
chart_types:
- volcano
favorite: false
---
# 差异表达火山图

![[templates/2026-10-22-scp-example__fig01-volcano--volcano/preview.png]]

<!-- facts:start -->
- 来源版式：[[layouts/2026-10-22-scp-example__fig01-volcano|火山图：Endocrine vs 其余细胞（SCP 示例）]]
- 面板（来源版式）：A
- 语言：r
- 标签：单细胞分析
- 图型：[[chart-types/volcano]]
- 输入接口：[[interfaces/render-de-results|差异表达结果表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/differential-expression|差异表达分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：DE 表可整理成 render-de-results，火山图模板消费该表；模板不重跑检验。；前提：group1 单一；pct_1/pct_2 为 0–1；p_val_adj >0；gene 组内唯一。；模板不重跑 DE 或 p 值校正；阈值由 style 显式给出。；适配：从 AllMarkers 表导出 gene、avg_log2FC、p_val_adj 等字段到 render-de-results。
    - 关系证据：methods/differential-expression.md#输出；methods/scp-de-enrichment-dynamic.md#知识关联检查；methods/scp-de-enrichment-dynamic.md#输出；templates/2026-10-22-scp-example__fig01-volcano--volcano/spec.json；templates/2026-10-22-scp-example__fig01-volcano--volcano/verify/verify.json；运行证据：无
<!-- facts:end -->

## 适用

一个 comparison group 的差异表达结果，画成单 panel 火山图。适合检查 DE 表中基因的 `diff_pct`（或 `avg_log2FC`）、signed `-log10(p_val_adj)` 与 `avg_log2FC` 颜色编码；可按阈值高亮显著点并标注 top 基因。

绘图核心来自 SCP v0.5.6（commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`，GPL >= 3）`VolcanoPlot()`。`scp_volcano_table()` 保留原表内准备（`diff_pct`、带符号 y、DE/border 标记、分位数截断、排序），`scp_volcano_labels()` 抽出原标签选择规则，`plot_scp_volcano()` 消费表并保留原六层点、阈值线、`geom_text_repel`、`scale_color_gradientn`、`facet_wrap` 和 `theme_scp`。`theme_scp`/`palette_scp` 与 `palette_list.rda` 已复制到 `code/`，不依赖已安装的 SCP 包、Wiki 路径或课题工作目录。

示例 `example/style.json` 固定 7×6 in、200 dpi、`nlabel = 8`、`seed = 1`；该固定模式 PNG 与画廊来源逐字节一致。`seed` 必须由调用方显式给出，因为原生 `VolcanoPlot()` 自身不设置种子。

## 不适用

- 只画一个 `group1` 的单 panel；多组表必须用 `group` 选择一个组，不能把多组画成多个 facet。
- 不能替代 DE 统计、p 值校正或样本级推断；点和阈值只做显示。
- 不能把 signed y 轴当常规火山图；这是 SCP 的显示方式，y 轴刻度取绝对值。
- `pct_1`/`pct_2` 必须是 0–1 的阳性细胞比例，不是 0–100 的百分数。
- `p_val_adj` 必须在 (0, 1]；`p_val_adj = 0` 会使 `-log10` 未定义，模板报错而不篡改原表。
- 允许 `avg_log2FC = ±Inf`：来源示例表包含 5 个这样的基因，原生绘图只用 `diff_pct` 作为 x；不要把它误当有限效应量做数值汇总。
- 缺 `gene`、`group1`、`avg_log2FC`、`pct_1`、`pct_2`、`p_val_adj`，或同组 gene 重复时会报错。
- 示例数据的 p 值/效应量不是生物学结论；`pancreas_sub` 没有病例/对照设计。

## 知识关联检查

日期 2026-10-22；查过 methods（`scp-de-enrichment-dynamic`、`scp-standard-workflow`）与 templates（fig03 dotplot、fig06 violin；本模板为 volcano）。

- 候选方法：[[methods/scp-de-enrichment-dynamic|单细胞差异表达、富集、GSEA 与动态特征]] 产出 DE 结果表；本模板消费其 `gene/group1/avg_log2FC/pct_1/pct_2/p_val/p_val_adj`。需要从 `srt@tools$DEtest_*` 导出、把 `pct.1/pct.2` 改为 `pct_1/pct_2`、只保留一个 `group1`；模板不重跑 DE。
- 一方法多图：同一 DE 结果还可进 fig03（dotplot）与 fig06（violin）；本模板增加“火山图”语义，不替代其他图。
- 一图多方法：本模板可由 SCP `RunDEtest`、Seurat `FindMarkers` 或其他 DE 实现产生的表驱动；当前画廊示例使用 Seurat 5.6 `FindMarkers`，已在来源 README 记录。
- 来源 layout：[[layouts/2026-10-22-scp-example__fig01-volcano|单 panel Volcano]]；模板从 A panel 拆出。
- 关系状态：[[methods/scp-de-enrichment-dynamic]] 维护 `adaptable` 关系（读取 `render-de-results`，验证状态 example）；当前不标 direct。
- 验证范围：核心函数契约 37 PASS / 0 FAIL（同表图层、`avg_log2FC`、多组 facet、反序、自定义组列/阈值、非法输入）。模板 CLI 验收 28 PASS / 0 FAIL（固定 7×6@200 与来源同 SHA256 `2b22c692…`，逐字节一致；adaptive 100/7343 基因、30/60 标签、33 字符长标签、自定义列映射、多组选择、`avg_log2FC`、非法 pct/p_val_adj/重复基因、输入不变、异目录复制、无 Wiki/SCP 依赖）。`verify-template` exit 0；preview SHA256 `2b22c692…`。不证明真实 DE 表或科学有效。

## 运行方式

本模板是独立模块：复制 `code/`（含 `data/palette_list.rda`）与 `spec.json` 到课题，用课题自己的 R 环境运行 `code/render.R`；不需要完整 `SCP-local`。必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verify/runtime-portability.json`。本轮已把模板复制到异目录、在新进程、不提供来源库路径运行，PNG 与既有回放逐像素一致（MAD=0）；PDF 因生成时间戳不同、部分 SVG 因设备标识不同而未按字节比较。

## 数据要求

### de（render-de-results.csv）：一个 comparison group 的 DE 结果；group1 必须单一，pct_1/pct_2 为 0–1 阳性细胞比例 [[interfaces/render-de-results|差异表达结果表]]

| 列 | 类型 | 含义 |
|---|---|---|
| gene | str | 基因/特征标识；同一 group1 内唯一 |
| group1 | str | 比较组；一个文件只放一个组，或用 style `group` 选一个 |
| group2 | str | 参照组或 rest |
| avg_log2FC | float | group1 相对 group2 的 log2 倍数变化；允许 ±Inf |
| pct_1 | float | group1 中阳性细胞比例，0–1 |
| pct_2 | float | group2 中阳性细胞比例，0–1 |
| p_val | float | 原始 p 值 |
| p_val_adj | float | 多重校正后的 p 值；必须 > 0 |

### 可覆盖的 style（`spec.json` 的 `style`）

- `group_col`：`"group1"`；`group`：`null`（单组表自动取唯一组，多组表必须显式选择）；`columns`：`null`（命名映射，如 `{"gene":"symbol"}`）
- `x_metric`：`"diff_pct"`（或 `"avg_log2FC"`）；`de_threshold`：`"avg_log2FC > 0 & p_val_adj < 0.05"`
- `palette`：`"RdBu"`；`palcolor`：`null`
- `pt_size`：`1`；`pt_alpha`：`1`；`cols_highlight`：`"black"`；`sizes_highlight`：`1`；`alpha_highlight`：`1`；`stroke_highlight`：`0.5`
- `nlabel`：`8`（每侧）；`features_label`：`null`
- `label_fg` / `label_bg`：`"black"` / `"white"`；`label_bg_r`：`0.1`；`label_size`：`4`
- `xlab` / `ylab`：`null` / `"-log10(p-adjust)"`；`aspect_ratio`：`null`
- `seed`：`1`；`dpi`：`200`；`width_in`：`7`；`height_in`：`6`
- `sizing`：`{"mode":"adaptive","base_width_in":7,"base_height_in":6,"base_label_chars":8,"per_label_char_in":0.12,"base_labels":16,"per_label_in":0.1,"max_width_in":null,"max_height_in":null}`

### 入口

`Rscript code/render.R --data <目录> --out <目录> [--style <json>]`。读取 `<data>/render-de-results.csv`，写出 `figure.png`、`figure.pdf`、`figure.svg` 和 `sizing.json`；`sizing.json` 记录实际宽高、dpi、基因数、标签数与最长标签长度。

## 使用记录

2026-10-22 从 layout `2026-10-22-scp-example__fig01-volcano` 的 A panel 拆出。当前实现：`code/scp_volcano_native.R`（原生 core + 抽出的标签选择函数）+ `code/scp_helpers.R`（本地 `theme_scp`/`palette_scp`）+ `code/data/palette_list.rda` + `code/core.R` + `code/panel.R` + `code/render.R`。旧的自定义 `plot_volcano()` 版本保存在工作区 `archive/template-custom-core/fig01-volcano-68b5aa0/`（Wiki git commit `68b5aa0`），不参与当前模板。`verify-template`、核心契约和 58 项 CLI 验收见上。

<!-- user:start -->
<!-- user:end -->
