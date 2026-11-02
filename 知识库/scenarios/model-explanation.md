---
type: scenario
id: model-explanation
title: 模型解释与特征重要性
picks:
- id: templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm
  note: SHAP 蜂群图（L2）
- id: templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar
  note: SHAP 条形图（L2）
- id: methods/shap-explanation
  note: SHAP 模型解释方法页
- id: figureya:FigureYa316RF_XGBoost_Boruta
  note: RF / XGBoost / Boruta 特征筛选（L0）
- id: recipes/figureya-293machinelearning
  note: 多算法组合预后模型比较（重）
tags:
- model-explanation-shap
- machine-learning
keywords:
- SHAP
- 特征重要性
- 模型解释
- 机器学习
- 随机森林
- XGBoost
- Boruta
summary: 机器学习模型的特征重要性与 SHAP 解释图，以及特征筛选。
---

# 模型解释与特征重要性

## 什么时候用

- 已训练好模型，要展示全局或个体层面的特征贡献。
- 要比较多种算法或做特征筛选。

## 首选组合

首选按常用顺序排列；`find` 命中本场景时这些条目排在前面。

<!-- facts:start -->
| 条目 | 级别 | 状态 | 说明 |
|---|---|---|---|
| [[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm|SHAP 蜂群图]] | L2 | ready · 可用 | SHAP 蜂群图（L2） |
| [[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar|SHAP 条形图（含环形 inset）]] | L2 | ready · 可用 | SHAP 条形图（L2） |
| [[methods/shap-explanation|基于 SHAP 的模型解释]] | note | ready | SHAP 模型解释方法页 |
<!-- facts:end -->

## 注意

- SHAP 值来自模型，不等于因果效应。
- 特征筛选与模型评价应在独立数据上验证。

<!-- figureya-selection:start -->
## 样式筛选记录

2026-11-02 按作者的 FigureYa 样式筛选更新当前首选展示：原 5 项，当前展示 3 项。

被移除项退出当前首选表；原 `picks` 关系保留用于恢复和溯源，不能据历史关系重新推荐已移除样式。
<!-- figureya-selection:end -->

## 作者备注

<!-- user:start -->
<!-- user:end -->
