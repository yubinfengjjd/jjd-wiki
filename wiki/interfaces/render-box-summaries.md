---
type: interface
slug: render-box-summaries
title: 预计算分组箱线与均值表
columns:
  category:
    type: str
    description: 每类恰好一行；不能缺组
  q1:
    type: float
    description: 上游给定第一四分位数
  median:
    type: float
    description: 上游给定中位数
  q3:
    type: float
    description: 上游给定第三四分位数
  low:
    type: float
    description: 上游给定下须；规则由分析说明
  high:
    type: float
    description: 上游给定上须；规则由分析说明
  mean:
    type: float
    description: 上游给定均值；须与真实点使用同一数据来源
---
# 预计算分组箱线与均值表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| category | str | 必需 | 每类恰好一行；不能缺组 |
| q1 | float | 必需 | 上游给定第一四分位数 |
| median | float | 必需 | 上游给定中位数 |
| q3 | float | 必需 | 上游给定第三四分位数 |
| low | float | 必需 | 上游给定下须；规则由分析说明 |
| high | float | 必需 | 上游给定上须；规则由分析说明 |
| mean | float | 必需 | 上游给定均值；须与真实点使用同一数据来源 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]]
- 经模板关联的方法（经读取该接口的模板；不是 direct，按方法页准备数据）：[[methods/regression-resampling-evaluation|回归模型的重采样评估与折外预测]]（adaptable）
<!-- facts:end -->

## 含义

本表每行是一个类别的预计算箱线摘要（示例中每个模型一行），不是每个样本、细胞或每个折一行；逐条观测值与显式抖动在配套的 render-category-points 表中，两表须来自同一真实分析。六个统计量沿用上游指标的原始量纲（示例点表标注为 RMSE，数值约 7–14；接口未声明 0–1、0–100 或 log 变换），当前实现要求均为有限数，mean 与点值同源，缺失值须由上游给出，不能靠模板补算。最常见的错误是把重复 K 折中的同一受试者/样本当作独立观测、由箱体反推样本量，或把独立估读的示例当作同源数据；准备时还须保证每个类别恰好一行并与点表类别完全对应、low≤q1≤median≤q3≤high，且 jitter 为显式输入、绝对值小于 0.5——这些统计全部上游给定，模板不重算分位数、须、均值，也不从点表补算。与 render-group-summaries 的区别是后者给 celltype×group 的 mean/SD 加 p 标签（模板不重算检验）、用于小提琴图统计标注；render-grouped-values 是细胞级/样本级逐条数值，供小提琴模板（其箱线层也由原始 value 现画）；独立箱线模板只读 render-category-points 与 render-box-summaries，grouped-values 不能直接替代；render-category-points 则是本表的配对点表。本表也不能替代 regression-fold-metrics，方法输出需在课题内另整理成同源 points/summaries，单给本表当前模板无法出图。

<!-- user:start -->
<!-- user:end -->
