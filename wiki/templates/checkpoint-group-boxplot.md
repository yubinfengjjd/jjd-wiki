---
type: template
id: checkpoint-group-boxplot
title: 检查点分组表达箱线图
status: draft
layouts: []
sources:
- methods/immune-infiltration-tme
panels: []
language: r
primary_method: immune-infiltration-tme
style_tier: variant
journal_style: Cai2026-npjPO
tags:
- transcriptomics
- single-cell
chart_types:
- boxplot
keywords:
- immune-checkpoint
- Wilcoxon
- group-comparison
favorite: false
---
# 检查点分组表达箱线图

<!-- facts:start -->
- 来源：[[methods/immune-infiltration-tme|肿瘤微环境与免疫浸润评估]]
- 语言：r
- 标签：transcriptomics、single-cell
- 图型：[[chart-types/boxplot]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/immune-infiltration-tme|肿瘤微环境与免疫浸润评估]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：按高/低免疫基质评分或关键标志物四分位分组的多免疫检查点表达分布及 Wilcoxon 检验可切换为 variant 分组箱线图。；前提：分组定义与检验方法（Wilcoxon）在上游明确；展示截断分位数须在图注说明。；适配：导出 checkpoint_expr.csv（sample_id, gene, group, expression, 可选 pval）。
    - 关系证据：methods/immune-infiltration-tme.md#输出；templates/checkpoint-group-boxplot/spec.json；运行证据：无
<!-- facts:end -->

## 适用

按多基因分面对比高/低分组（如 `low #1D8A68` vs `high #D05810`）的免疫检查点或特征基因表达分布，并附 Wilcoxon 秩和检验星号注记与显著性横括号。对应 Cai 等主图 3C 风格。

## 不适用

不适用于配对时间序列轨迹、样本数极少（每组少于 3 例）时的强推断，或不同平台未归一化的跨队列原始计数直接合并比较。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/immune-infiltration-tme]]，作为该方法的 `variant` 分组箱线图模板（来源风格 `Cai2026-npjPO`），与默认相关矩阵 [[templates/clustered-corr-boxes]] 及双轴连线 [[templates/lr-bipartite-bubble]] 搭配使用。

## 数据要求

### expr（checkpoint_expr.csv）：多基因分组表达长表（sample_id、gene、group、expression，可选 pval） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| sample_id | str | 必需 | 样本或 Spot 唯一标识 |
| gene | str | 必需 | 免疫检查点或目标基因名称 |
| group | str | 必需 | 比较分组标签（如 low 与 high） |
| expression | float | 必需 | 归一化表达值或签名分数 |
| pval | float | 可选 | 可选预计算组间检验 p 值（若提供则优先使用） |

### 可覆盖的 style

- `ncol`：`4`
- `group_colors`：`["#1D8A68", "#D05810", "#3B7EB6", "#8856A7"]`
- `y_transform`：`"sqrt"`
- `cap_quantile`：`0.97`
- `show_outliers`：`true`
- `show_bracket`：`true`
- `dpi`：`300`
- `width_in`：`7.6`
- `height_in`：`4.2`

## 使用记录

<!-- user:start -->
<!-- user:end -->
