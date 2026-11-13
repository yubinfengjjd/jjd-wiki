---
type: layout
id: 2026-10-22-glaucoma-scrna__fig03-topjournal-bubble
title: 顶刊样式气泡点图（GSE251716）
status: pending_template
gallery_entry: 2026-10-22-glaucoma-scrna/figures/fig03-topjournal-bubble
gallery_version: 1
signedoff_version: 1
language: r
tags:
- 单细胞分析
panels:
  A: dotplot
chart_types:
- dotplot
templates:
- 2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot
template_panels:
  2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot:
  - A
favorite: false
keywords:
- GSE251716
- dotplot
---
# 顶刊样式气泡点图（GSE251716）

![[layouts/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble/thumb.png]]

<!-- facts:start -->
- 来源：青光眼单细胞项目（GSE251716）图表复刻
- 公众号：作者课题
- 日期：2026-10-22
- 画廊条目：2026-10-22-glaucoma-scrna/figures/fig03-topjournal-bubble
- 语言：r
- 数据来源：synthetic
- 代码来源：adapted
- 标签：单细胞分析
- 关键词：GSE251716、dotplot
- 图型：[[chart-types/dotplot]]
- 面板：[[templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot|细胞类型 × 基因气泡点图]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

细胞类型 × 基因的气泡点图：输入 `group, feature, avg_expression, pct_expressed`，可选 `target_group` 用于基因排序。画灰底黑框、底部细胞类型色块、旋转 x 标签、斜体基因名、Relative Expression 渐变和 Percentage Expressed 大小图例。组数/基因数由数据识别，示例 9×52 不是限制。

## 不适用

没有平均表达/阳性比例表；需要差异检验或显著性标注；基因数过多导致 y 标签不可读；不能把颜色或气泡大小当统计显著性。`avg_expression` 若是 scaled data，必须与原始表达区分并在图注说明。

## 知识关联检查

2026-10-22 查过 M2（marker 注释）和点图图型页。V4 与 M2 语义相关：M2 产出 dotplot-long 和 marker 目标映射；同一数据也可画 SCpubr 点图，但按作者确认只保留本顶刊气泡样式。当前来源为合成示例；模板待作者签核后建立并补 `figure_relations`。

## 使用记录

2026-10-22 从 `2026-10-22-glaucoma-scrna/figures/fig03-topjournal-bubble` 收录；机械 QA 0 失败；作者签核待完成。

<!-- user:start -->
<!-- user:end -->
