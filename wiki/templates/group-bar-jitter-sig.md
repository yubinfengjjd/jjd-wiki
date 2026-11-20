---
type: template
id: group-bar-jitter-sig
title: 多基因分面均值柱状抖动散点显著性图
status: ready
layouts: []
sources:
- methods/differential-expression
panels: []
language: python
primary_method: differential-expression
style_tier: default
journal_style: Cancer Discovery
tags:
- transcriptomics
- experimental-statistics
chart_types:
- bar
keywords:
- barplot
- SEM
- jitter
- significance-bracket
favorite: false
---
# 多基因分面均值柱状抖动散点显著性图

![[templates/group-bar-jitter-sig/preview.png]]

<!-- facts:start -->
- 来源：[[methods/differential-expression|差异表达分析]]
- 语言：python
- 标签：transcriptomics、experimental-statistics
- 图型：[[chart-types/bar]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/differential-expression|差异表达分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：候选差异标志基因在多组样本间的对数表达分布可绘制为多基因分面均值±SEM 柱状图 + 个体抖动散点 + 红色显著性星号横线。；前提：输入为样本级归一化对数表达长表（gene, sample_id, group, log2_expr）。；适配：导出 gene_group_expression_long.csv。
    - 关系证据：methods/differential-expression.md#输出；templates/group-bar-jitter-sig/spec.json；运行证据：无
<!-- facts:end -->

## 适用

按多个特征基因（如黑色素瘤谱系标志物 PMEL、MITF、MLANA、CSPG4、TYR 或趋化因子）分面展示不同病理/解剖分组（如 MIS、Immune、Tumor 或 IM vs EM）的均值±SEM 柱状图，叠加全部个体样本抖动散点与顶部两两比较显著性红线星号（`#C62828`）。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 6B / 6F / 7B / S7A / S7E 画风。

## 不适用

不适用于全转录组数万基因差异显著性总览（请用 [[templates/monochrome-deseq-volcano]] 或 [[templates/bulk-de-volcano]]）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/differential-expression]]，挂入 `(differential-expression, bar)` 输出槽位（该槽位首个模板，标为 `style_tier: default`, `journal_style: Cancer Discovery`），承接候选差异标志基因在分组间的均值±SEM+散点统计可视化。

## 数据要求

### expr（gene_group_expression_long.csv）：多基因按样本分组的对数表达长表（gene, sample_id, group, log2_expr） （模板内联表结构）

| 列 | 类型 | 含义 |
|---|---|---|
| gene | str | 基因符号（分面标题） |
| sample_id | str | 样本唯一编号 |
| group | str | 比较分组名称（如 MIS, Immune, Tumor） |
| log2_expr | float | log2 归一化表达量 |

### 可覆盖的 style

- `ncol`：`3`
- `ylabel`：`"Expression (log$_2$)"`
- `point_size`：`6.0`
- `dpi`：`300`
- `width_in`：`5.0`
- `height_in`：`3.5`
- `rect`：`[0.12, 0.06, 0.84, 0.82]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
