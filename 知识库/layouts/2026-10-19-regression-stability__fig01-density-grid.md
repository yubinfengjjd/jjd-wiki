---
type: layout
id: 2026-10-19-regression-stability__fig01-density-grid
title: 六模型验证预测密度散点组图（整图存档）
status: archived
gallery_entry: 2026-10-19-regression-stability/figures/fig01-density-grid
gallery_version: 1
language: python
tags:
- 机器学习
- 实验统计
panels:
  A: density-scatter
  B: density-scatter
  C: density-scatter
  D: density-scatter
  E: density-scatter
  F: density-scatter
chart_types:
- density-scatter
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
# 六模型验证预测密度散点组图（整图存档）

![[layouts/2026-10-19-regression-stability__fig01-density-grid/thumb.png]]

<!-- facts:start -->
- 来源：EST同款复现：多模型重复实验（K折交叉验证）的密度散点与箱线图评估模型稳定性
- 公众号：Python机器学习AI
- 日期：2026-10-19
- URL：https://mp.weixin.qq.com/s/LDPZ8guXNKnSRtjZC2YbNg
- 画廊条目：2026-10-19-regression-stability/figures/fig01-density-grid
- 语言：python
- 数据来源：estimated
- 代码来源：reconstructed
- 标签：机器学习、实验统计
- 关键词：regression、cross-validation、回归评估、模型比较、折外预测
- 图型：[[chart-types/density-scatter]]
- 面板：尚未拆分（A–F）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

连续结局回归模型的验证预测比较；需要真实逐样本观测值、验证预测、模型名和验证折标识。2×3版式同时展示六模型的1:1偏差、预测趋势和边缘分布。可接[[methods/regression-resampling-evaluation|回归模型的重采样评估与折外预测]]，输入表为[[interfaces/regression-predictions]]。换成真实课题时必须重新计算图中指标、拟合线与密度色标。

## 不适用

分类/生存结局、因果或临床效用证明；训练回代预测不能称作折外预测。本条目为原图像素估读，点遮挡导致样本不可恢复，Frequency的原始归一化未知，图上数值仅照录来源。未签核，尚未拆出ready模板。

## 使用记录

## 知识关联检查

本条目保留历史整组范围。代表单panel见 [[layouts/2026-10-19-regression-stability__fig03-density-panel]]，关联 [[methods/regression-resampling-evaluation]]；范围不同，签核状态各自保留。

<!-- user:start -->
<!-- user:end -->
