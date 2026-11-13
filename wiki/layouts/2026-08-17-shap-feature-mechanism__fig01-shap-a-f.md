---
type: layout
id: 2026-08-17-shap-feature-mechanism__fig01-shap-a-f
title: 双模型 SHAP 特征贡献组图
status: archived
gallery_entry: 2026-08-17-shap-feature-mechanism/figures/fig01-shap-a-f
gallery_version: 1
language: python
panels:
  A: bar
  B: beeswarm
  C: radial-bar
  D: bar
  E: beeswarm
  F: radial-bar
chart_types:
- bar
- beeswarm
- radial-bar
templates:
- 2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar
- 2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm
- 2026-08-17-shap-feature-mechanism__fig01-shap-a-f--radial-bar
template_panels:
  2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar:
  - A
  - D
  2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm:
  - B
  - E
  2026-08-17-shap-feature-mechanism__fig01-shap-a-f--radial-bar:
  - C
  - F
favorite: false
tags:
- 机器学习
- 模型解释与特征重要性
- 化学信息与QSAR
archived_from: ready
keywords:
- SHAP
- LightGBM
- CatBoost
- pLC50
- AR-DBP
- QSAR
---
# 双模型 SHAP 特征贡献组图

![[layouts/2026-08-17-shap-feature-mechanism__fig01-shap-a-f/thumb.png]]

<!-- facts:start -->
- 来源：期刊配图：基于SHAP的特征驱动机制条形图、蜂群图与环形贡献配图形式
- 公众号：Python机器学习AI
- 日期：2026-08-17
- URL：https://mp.weixin.qq.com/s/Shi2jsgSzbf4nYQEHhjhog
- 画廊条目：2026-08-17-shap-feature-mechanism/figures/fig01-shap-a-f
- 语言：python
- 数据来源：mixed
- 代码来源：reconstructed
- 标签：机器学习、模型解释与特征重要性、化学信息与QSAR
- 关键词：SHAP、LightGBM、CatBoost、pLC50、AR-DBP、QSAR
- 图型：[[chart-types/bar]] · [[chart-types/beeswarm]] · [[chart-types/radial-bar]]
- 面板：[[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar|SHAP 条形图（含环形 inset）]]（A、D）；[[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm|SHAP 蜂群图]]（B、E）；[[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--radial-bar|SHAP 环形贡献图]]（C、F）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

两行三联的模型解释组图，每行一个模型：条形图（左，含环形占比 inset）给出各特征的平均绝对 SHAP 排名，蜂群图（中）给出逐样本 SHAP 的方向与分布，环形图（右）给出各特征贡献与百分比。适合比较两个树模型（原图为 LightGBM 与 CatBoost）在同一组特征上的解释是否一致。需要每个模型的 SHAP 汇总表与逐样本 SHAP 值；两行的特征数可以不同。

## 不适用

不负责模型训练与 SHAP 计算，也不证明因果。画廊复刻的数据是图中印刷值的候选转录，蜂群为固定种子合成近似（见画廊 README），不能当作原始观测引用。只有一个模型、或要比较三个以上模型时，布局不合适；拆成单图模板后可以单独使用其中一张。

## 使用记录

## 知识关联检查

本来源为整组图，拆出的三种模板分别记录自己的接口和状态。关联 [[methods/shap-explanation]]；与模型性能评估的关系由 [[methods/regression-resampling-evaluation]] 和方法页说明，不将SHAP输出接口伪装为回归性能输入。

<!-- user:start -->
<!-- user:end -->
