---
type: template
id: roe-cox-heatmap
title: 多因素Cox与Ro/e热图
status: ready
layouts: []
sources:
- methods/cell-proportion-composition
panels: []
language: r
primary_method: cell-proportion-composition
tags:
- single-cell
- survival-analysis
chart_types:
- heatmap
keywords: []
favorite: false
style_tier: default
journal_style: Cai2026-npjPO
---
# 多因素Cox与Ro/e热图

![[templates/roe-cox-heatmap/preview.png]]

<!-- facts:start -->
- 来源：[[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]
- 语言：r
- 标签：single-cell、survival-analysis
- 图型：[[chart-types/heatmap]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：各细胞亚群的跨组织/分子亚型 Ro/e 偏好可与外部临床 Cox HR 联合整理为主推默认（default）复合热图展示；模板不拟合 Cox 模型。；前提：Ro/e 与 Cox HR/p 值分别由独立分析步骤严格输出，不能混同样本级与细胞级单位。；适配：整理 roe_cox_input.csv（canonical_subcluster、roe_subtype_*/roe_tissue_* 列及可选 tcga_HR/tcga_p_value、inhouse_HR/inhouse_p_value）。
    - 关系证据：methods/cell-proportion-composition.md#输出；templates/roe-cox-heatmap/spec.json；运行证据：无
  - [[methods/survival-prognosis-analysis|生存分析与临床预后建模]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：多队列（TCGA 与自采队列）Cox 比例风险 HR/p 值可与亚群临床亚型 Ro/e 偏好合并呈现为主推默认（default）复合热图；模板不做生存回归。；前提：各队列 Cox 模型须明确协变量与比例风险假定；HR > 1 标为 Risk，HR < 1 标为 Protective。；适配：整理 roe_cox_input.csv（canonical_subcluster、tcga_HR、tcga_p_value、inhouse_HR、inhouse_p_value 及 roe_subtype_*/roe_tissue_* 列）。
    - 关系证据：methods/survival-prognosis-analysis.md#输出；templates/roe-cox-heatmap/spec.json；运行证据：无
<!-- facts:end -->

## 适用

按相同的细胞亚群对齐多变量 Cox 方向及组织、临床亚型的观察数／期望数（Ro/e）。对应 Cai 等主图 2C、4C、5C。

## 不适用

需要展示 HR 及其置信区间、检验比例风险假设，或从细胞计数重新估计 Ro/e 时，应使用可输出这些统计量的分析方法。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/cell-proportion-composition]]。

## 数据要求

### roe_cox（roe_cox_input.csv）：细胞亚群多因素Cox风险结果（tcga_HR/tcga_p_value、inhouse_HR/inhouse_p_value）与roe_subtype_*、roe_tissue_*宽表 （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| canonical_subcluster | str | 必需 | 规范亚群名称（横轴） |
| tcga_HR | float | 可选 | TCGA队列多因素Cox HR（>1危险因素，<=1保护因素） |
| inhouse_HR | float | 可选 | 内部队列多因素Cox HR |

### 可覆盖的 style

- `roe_cap`：`2.2`
- `text_size`：`2.7`
- `dpi`：`300`
- `width_in`：`8.2`
- `height_in`：`5.4`

## 使用记录

<!-- user:start -->
<!-- user:end -->
