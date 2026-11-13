---
type: layout
id: 2026-10-19-regression-stability__fig03-density-panel
title: 六模型验证预测：密度散点与边缘分布
status: pending_template
gallery_entry: 2026-10-19-regression-stability/figures/fig03-density-panel
gallery_version: 1
language: python
tags:
- 机器学习
- 实验统计
panels:
  A: density-scatter
chart_types:
- density-scatter
templates:
- 2026-10-19-regression-stability__fig03-density-panel--density-scatter
template_panels:
  2026-10-19-regression-stability__fig03-density-panel--density-scatter:
  - A
favorite: false
signedoff_version: 1
keywords:
- regression
- cross-validation
- 回归评估
- 模型比较
- 折外预测
---
# 六模型验证预测：密度散点与边缘分布

![[layouts/2026-10-19-regression-stability__fig03-density-panel/thumb.png]]

<!-- facts:start -->
- 来源：EST同款复现：多模型重复实验（K折交叉验证）的密度散点与箱线图评估模型稳定性
- 公众号：Python机器学习AI
- 日期：2026-10-19
- URL：https://mp.weixin.qq.com/s/LDPZ8guXNKnSRtjZC2YbNg
- 画廊条目：2026-10-19-regression-stability/figures/fig03-density-panel
- 语言：python
- 数据来源：estimated
- 代码来源：reconstructed
- 标签：机器学习、实验统计
- 关键词：regression、cross-validation、回归评估、模型比较、折外预测
- 图型：[[chart-types/density-scatter]]
- 面板：[[templates/2026-10-19-regression-stability__fig03-density-panel--density-scatter|密度散点与边缘分布]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

用逐案例配对数值查看数值输出与参考值的分布和偏差；保留边缘分布、1:1线、显式拟合及指标标注。需要points和histograms两张已准备表；颜色与色标含义由上游说明。真实分析需保留案例身份及单位，当前估读图不提供这些身份。

仅所选A单逻辑panel；inset/边缘/色标属于这个panel。方法家族：[[methods/regression-resampling-evaluation]]。

## 不适用

不以相关线证明一致性，不在异量纲上使用1:1线，不把估读点/颜色当原始观测或实际频数。右边缘0..40保留旧估读，源单图0..20，使用前需理解此差异。

## 函数与验证

画廊条目 code/panels.py 为当前源版本，code/panel.py 保留 draw(fig,rect,tables,style)；复制code目录到课题后调用，无知识库路径依赖。调用示例、数据来源与限制见画廊 README，compare/function-verification.json为11项功能验收。已有直接draw调用验证；本轮verify-template/render入口回放已完成，2026-10-21作者已确认模板并标为ready，无需再次模板化。

## 使用记录

2026-10-21：按本次确认沿用旧估读数据，箱线图保留合成横向抖动。PNG/PDF/SVG已导出；PNG目视、机械QA、函数可移植性已检查；独立PDF/SVG查看器视觉未测。源图与完整图字节哈希及bbox见画廊source/provenance.json；全部旧组图基线文件哈希保持一致。来源已签核，关联模板已由作者确认可用；本来源用于参考，换数据调用关联模板。

## 知识关联检查

选定范围为一个逻辑panel，边缘分布与色标随主图。关联 [[methods/regression-resampling-evaluation]]；历史重复模型整图已归档，仅保留在画廊作溯源。已查既有SHAP模板，图形编码与接口不同，未作为密度图模板复用。


本轮待办：[[templates/2026-10-19-regression-stability__fig03-density-panel--density-scatter]] 已完成绘图代码、接口、回放及复用检查，作者已确认并标为ready。来源状态保留pending_template，完整模板覆盖已完成，不再列agent待办；无整图交付。

<!-- user:start -->
<!-- user:end -->
