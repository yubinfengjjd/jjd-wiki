---
type: template
id: tissue-ratio-prop-combo
title: 组织构成与样本比例组合图
status: draft
layouts: []
sources:
- methods/cell-proportion-composition
panels: []
language: r
primary_method: cell-proportion-composition
style_tier: variant
journal_style: Cai2026-npjPO
tags:
- single-cell
- experimental-statistics
chart_types:
- bar
- boxplot
keywords:
- tissue-preference
- proportion
- Wilcoxon
favorite: false
---
# 组织构成与样本比例组合图

<!-- facts:start -->
- 来源：[[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]
- 语言：r
- 标签：single-cell、experimental-statistics
- 图型：[[chart-types/bar]] · [[chart-types/boxplot]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：亚群跨组织构成堆叠比例与逐样本比例箱线图及 BH 校正 Wilcoxon 检验可切换至 variant 组合画风；检验以样本为重复单位。；前提：proportion 为各样本内亚群相对比例（0–1）；配对/独立检验以 sample_id 为独立单位。；适配：导出 tissue_ratio_prop.csv（cluster, tissue, sample_id, proportion, 可选 n_cells, pval）。
    - 关系证据：methods/cell-proportion-composition.md#输出；templates/tissue-ratio-prop-combo/spec.json；运行证据：无
<!-- facts:end -->

## 适用

左侧以水平堆叠柱展示各细胞亚群在多种组织来源（如癌旁正常 `ANT #2B9E77`、肿瘤 `T #D95F02`、转移淋巴结 `LM #7570B3`）中的总体构成比例，右侧并排展示逐样本（或逐批次）亚群比例的横向箱线图、散点分布及 BH 校正 Wilcoxon 检验显著性星号。对应 Cai 等附图 2A、4A、5A 右侧组合面板风格。

## 不适用

不适用于未做细胞总数归一化的绝对细胞数直接比较，也不适用于仅有单样本汇总计数而无跨样本方差分布的数据；若需同时并排多队列临床 Cox 风险与亚型 Ro/e 热图，请改用 [[templates/roe-cox-heatmap]]，若仅做基础比例流向堆叠柱请用 [[templates/cell-prop-flow-bar]]。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/cell-proportion-composition]]，作为 `variant` 组织构成与样本分布组合模板（来源风格 `Cai2026-npjPO`），与默认流向柱状图 [[templates/cell-prop-flow-bar]]、Ro/e-Cox 临床偏好热图 [[templates/roe-cox-heatmap]] 并列切换。

## 数据要求

### prop（tissue_ratio_prop.csv）：亚群跨组织构成与样本比例长表（cluster、tissue、sample_id、proportion，可选 n_cells、pval） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cluster | str | 必需 | 细胞亚群名称（纵轴条目） |
| tissue | str | 必需 | 组织来源标签（如 ANT、T、LM） |
| sample_id | str | 必需 | 样本或批次标识（用于配对/独立检验与散点） |
| proportion | float | 必需 | 该样本内亚群所占比例（0–1 小数） |
| n_cells | int | 可选 | 可选各组织合并细胞数（用于左侧总体构成堆叠条） |
| pval | float | 可选 | 可选预计算检验 p 值（前两组比较） |

### 可覆盖的 style

- `tissue_colors`：`["#2B9E77", "#D95F02", "#7570B3", "#E7298A"]`
- `show_ylabels`：`true`
- `paired_test`：`true`
- `prop_unit`：`"percent"`
- `dpi`：`300`
- `width_in`：`6.2`
- `height_in`：`5.4`

## 使用记录

<!-- user:start -->
<!-- user:end -->
