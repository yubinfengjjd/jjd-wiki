---
type: layout
id: 2026-10-19-regression-stability__fig04-boxplot-panel
title: 多模型逐折指标：箱线、散点与均值
status: pending_template
gallery_entry: 2026-10-19-regression-stability/figures/fig04-boxplot-panel
gallery_version: 1
language: python
tags:
- 机器学习
- 实验统计
panels:
  A: boxplot
chart_types:
- boxplot
templates:
- 2026-10-19-regression-stability__fig04-boxplot-panel--boxplot
template_panels:
  2026-10-19-regression-stability__fig04-boxplot-panel--boxplot:
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
# 多模型逐折指标：箱线、散点与均值

![[layouts/2026-10-19-regression-stability__fig04-boxplot-panel/thumb.png]]

<!-- facts:start -->
- 来源：EST同款复现：多模型重复实验（K折交叉验证）的密度散点与箱线图评估模型稳定性
- 公众号：Python机器学习AI
- 日期：2026-10-19
- URL：https://mp.weixin.qq.com/s/LDPZ8guXNKnSRtjZC2YbNg
- 画廊条目：2026-10-19-regression-stability/figures/fig04-boxplot-panel
- 语言：python
- 数据来源：mixed
- 代码来源：reconstructed
- 标签：机器学习、实验统计
- 关键词：regression、cross-validation、回归评估、模型比较、折外预测
- 图型：[[chart-types/boxplot]]
- 面板：[[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

比较多个类别的一个连续指标分布，同时保留点、箱体、须及均值；模型和指标只是参数。需要points(category,value,jitter)与summaries(category,q1,median,q3,low,high,mean)两张表，图不重新计算统计。真实分析须说明采样单位、层级和须规则。

仅所选A单逻辑panel；inset/边缘/色标属于这个panel。方法家族：[[methods/regression-resampling-evaluation]]。

## 不适用

不混淆重复划分与独立样本，不用本次独立估读的点/箱体/均值进行推断。横向抖动为合成展示位置，不是测量；换数据须由上游分析生成真实一致的摘要。

## 函数与验证

画廊条目 code/panels.py 为当前源版本，code/panel.py 保留 draw(fig,rect,tables,style)；复制code目录到课题后调用，无知识库路径依赖。调用示例、数据来源与限制见画廊 README，compare/function-verification.json为11项功能验收。已有直接draw调用验证；本轮verify-template/render入口回放已完成，2026-10-21作者已确认模板并标为ready，无需再次模板化。

## 使用记录

2026-10-21：按本次确认沿用旧估读数据，箱线图保留合成横向抖动。PNG/PDF/SVG已导出；PNG目视、机械QA、函数可移植性已检查；独立PDF/SVG查看器视觉未测。源图与完整图字节哈希及bbox见画廊source/provenance.json；全部旧组图基线文件哈希保持一致。来源已签核，关联模板已由作者确认可用；本来源用于参考，换数据调用关联模板。

## 知识关联检查

选定范围为一个逻辑panel。关联 [[methods/regression-resampling-evaluation]]；历史重复指标整图已归档，模型/指标变化由单 panel 函数参数表达。本轮已建箱线单panel模板并回放，作者已确认模板为ready；来源与模板阶段分别记录。


本轮待办：[[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot]] 已完成绘图代码、接口、回放及复用检查，作者已确认并标为ready。来源状态保留pending_template，完整模板覆盖已完成，不再列agent待办；无整图交付。

<!-- user:start -->
<!-- user:end -->
