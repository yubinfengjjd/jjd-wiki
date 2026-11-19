---
type: template
id: atlas-workflow-diagram
title: 多源图谱构建流程示意图
status: draft
layouts: []
sources:
- methods/batch-integration
panels: []
language: r
primary_method: batch-integration
style_tier: variant
journal_style: Cai2026-npjPO
tags:
- single-cell
- transcriptomics
chart_types:
- network
keywords:
- study-design
- multi-cohort
- integration
favorite: false
---
# 多源图谱构建流程示意图

<!-- facts:start -->
- 来源：[[methods/batch-integration|单细胞批次整合]]
- 语言：r
- 标签：single-cell、transcriptomics
- 图型：[[chart-types/network]]
- 输入接口：未声明 · 未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

展示多队列、多组学（如单细胞测序与空间转录组）研究的数据采集路径、预处理流程步骤及右侧队列样本量汇总。对应 Cai 等主图 1A 的实验设计与队列构成总览风格。

## 不适用

不适用于推断定量基因调控网络、展示真实统计结果或替代聚类/批次效应评估图；仅用于研究设计、样本来源与实验流程的概览说明。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/batch-integration]]，作为 `variant` 风格模板（来源风格 `Cai2026-npjPO`），与标准降维图 [[templates/scrna-celltype-umap]]（展示整合后细胞分布）互补，专门承载“多中心队列汇总 + 分支流程示意图”。

## 数据要求

### steps（workflow_steps.csv）：多源队列研究流程各分支的步骤节点与连线样式 （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| branch | str | 必需 | 流程分支或组学轨道名称 |
| step_order | int | 必需 | 分支内步骤顺序（从左到右） |
| label | str | 必需 | 步骤框显示标签（可用 `\n` 换行） |
| arrow_style | str | 可选 | 进入该步骤的箭头线型（solid 或 dashed） |
| box_fill | str | 可选 | 可选步骤节点填充色（十六进制） |

### cohorts（workflow_cohorts.csv）：各研究分支汇总的队列名称、样本数及数据来源类型 （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| branch | str | 必需 | 所属流程分支名称 |
| cohort | str | 必需 | 队列或数据集编号 |
| n_samples | int | 必需 | 该队列纳入样本数 |
| origin | str | 可选 | 数据来源（in-house 或 public） |

### 可覆盖的 style

- `inhouse_color`：`"#4FB3C8"`
- `public_color`：`"#B5B2AF"`
- `tissue_fill`：`"#F6E5BB"`
- `tissue_border`：`"#B18470"`
- `nodule_fill`：`"#AB5141"`
- `nodule_border`：`"#982723"`
- `show_source_pie`：`true`
- `dpi`：`300`
- `width_in`：`9.8`
- `height_in`：`4.2`

## 使用记录

<!-- user:start -->
<!-- user:end -->
