---
type: layout
id: 2026-10-19-regression-stability__fig02-metric-boxplots
title: 多模型 RMSE、R² 与 MAE 箱线组图（整图存档）
status: archived
gallery_entry: 2026-10-19-regression-stability/figures/fig02-metric-boxplots
gallery_version: 1
language: python
tags:
- 机器学习
- 实验统计
panels:
  A: boxplot
  B: boxplot
  C: boxplot
chart_types:
- boxplot
templates: []
template_panels: {}
favorite: false
archived_from: pending_template
keywords:
- regression
- cross-validation
- 回归评估
- 模型比较
- 折外预测
---
# 多模型 RMSE、R² 与 MAE 箱线组图（整图存档）

![[layouts/2026-10-19-regression-stability__fig02-metric-boxplots/thumb.png]]

<!-- facts:start -->
- 来源：EST同款复现：多模型重复实验（K折交叉验证）的密度散点与箱线图评估模型稳定性
- 公众号：Python机器学习AI
- 日期：2026-10-19
- URL：https://mp.weixin.qq.com/s/LDPZ8guXNKnSRtjZC2YbNg
- 画廊条目：2026-10-19-regression-stability/figures/fig02-metric-boxplots
- 语言：python
- 数据来源：mixed
- 代码来源：reconstructed
- 标签：机器学习、实验统计
- 关键词：regression、cross-validation、回归评估、模型比较、折外预测
- 图型：[[chart-types/boxplot]]
- 面板：尚未拆分（A–C）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

连续结局回归的多模型误差分布比较：三联展示RMSE、R²与MAE，箱线叠加逐折点与均值菱形。需要各模型共用相同验证划分的真实逐折指标[[interfaces/regression-fold-metrics]]；由[[methods/regression-resampling-evaluation|回归模型的重采样评估与折外预测]]汇总得到。真实课题中箱体、散点和均值必须来自同一批指标值。

## 不适用

不能把相关验证折当独立实验，不能用箱体窄直接证明外部泛化或临床有效性。本条目箱体、点值和均值为独立估读，横向抖动合成，不构成可分析的原始指标表；不能用于显著性检验。分类、生存任务需另选指标。未签核，尚未拆出ready模板。

## 使用记录

## 知识关联检查

本条目保留历史整组范围。代表单panel见 [[layouts/2026-10-19-regression-stability__fig04-boxplot-panel]]，关联 [[methods/regression-resampling-evaluation]]；重复指标属于参数变化，不因此要求每个指标各建模板。

<!-- user:start -->
<!-- user:end -->
