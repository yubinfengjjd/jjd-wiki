---
type: layout
id: 2026-10-19-regression-stability__fig04-boxplot-panel
title: 单panel：箱线散点与均值 EST同款复现：多模型重复实验（K折交叉验证）的密度散点与箱线图评估模型稳定性
status: pending_template
gallery_entry: 2026-10-19-regression-stability/figures/fig04-boxplot-panel
gallery_version: 1
language: python
tags:
- 实验统计
- regression
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
---
# 单panel：箱线散点与均值 EST同款复现：多模型重复实验（K折交叉验证）的密度散点与箱线图评估模型稳定性

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
- 标签：实验统计、regression
- 图型：[[chart-types/boxplot]]
- 面板：[[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|boxplot · 单panel：箱线散点与均值 EST同款复现：多模型重复实验（K折交叉验证）的密度散点与箱线图评估模型稳定性]]（A）
<!-- facts:end -->

## 适用

比较多个类别的一个连续指标分布，同时保留点、箱体、须及均值；模型和指标只是参数。需要points(category,value,jitter)与summaries(category,q1,median,q3,low,high,mean)两张表，图不重新计算统计。真实分析须说明采样单位、层级和须规则。

仅所选A单逻辑panel；inset/边缘/色标属于这个panel。迁移分析文字笔记：[[methods/repeated-benchmark-distribution]]；原文方法：[[methods/regression-resampling-evaluation]]。

## 不适用

不混淆重复划分与独立样本，不用本次独立估读的点/箱体/均值进行推断。横向抖动为合成展示位置，不是测量；换数据须由上游分析生成真实一致的摘要。

## 函数与验证

画廊条目 code/panels.py 为当前源版本，code/panel.py 保留 draw(fig,rect,tables,style)；复制code目录到课题后调用，无知识库路径依赖。调用示例、数据来源与限制见画廊 README，compare/function-verification.json为11项功能验收。已有直接draw调用验证；正式wiki render尚未进行。作者签核后才scaffold-template/verify-template，不提前标ready。

## 使用记录

2026-10-21：按本次确认沿用旧估读数据，箱线图保留合成横向抖动。PNG/PDF/SVG已导出；PNG目视、机械QA、函数可移植性已检查；独立PDF/SVG查看器视觉未测。源图与完整图字节哈希及bbox见画廊source/provenance.json；全部旧组图基线文件哈希保持一致。待作者签核，方法笔记也是draft。

## 知识关联检查

选定范围为一个逻辑panel。关联 [[methods/repeated-benchmark-distribution]] 和 [[methods/regression-resampling-evaluation]]；同帖 [[layouts/2026-10-19-regression-stability__fig02-metric-boxplots]] 为重复指标组图，模型/指标变化可由函数参数表达。当前没有ready箱线模板，不把来源图样标成可调用模板。

<!-- user:start -->
<!-- user:end -->
