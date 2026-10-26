---
type: layout
id: 2026-10-22-glaucoma-scrna__fig06-pathway-violin
title: 分组小提琴与统计标注（GSE251716）
status: pending_template
gallery_entry: 2026-10-22-glaucoma-scrna/figures/fig06-pathway-violin
gallery_version: 1
signedoff_version: 1
language: r
tags:
- 单细胞分析
- 实验统计
panels:
  A: violin
chart_types:
- violin
templates:
- 2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin
template_panels:
  2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin:
  - A
favorite: false
keywords:
- GSE251716
- pathway
---
# 分组小提琴与统计标注（GSE251716）

![[layouts/2026-10-22-glaucoma-scrna__fig06-pathway-violin/thumb.png]]

<!-- facts:start -->
- 来源：青光眼单细胞项目（GSE251716）图表复刻
- 公众号：作者课题
- 日期：2026-10-22
- 画廊条目：2026-10-22-glaucoma-scrna/figures/fig06-pathway-violin
- 语言：r
- 数据来源：synthetic
- 代码来源：adapted
- 标签：单细胞分析、实验统计
- 关键词：GSE251716、pathway
- 图型：[[chart-types/violin]]
- 面板：[[templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin|分组小提琴图（含统计标注）]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

分组分布展示：输入细胞级 `celltype, group, value` 长表 + 预计算 `celltype, group, mean, sd, p_label, p_y, mean_sd_label, mean_y` 摘要。画小提琴 + 箱线 + 抖动、双色分组、每个细胞类型的 p 标签和 Mean/SD 标签。组数/类别数由数据识别，示例 9×2 不是限制。

## 不适用

没有预计算摘要或需要模板自行跑检验；细胞不独立/每组只有 1 个样本时不能做组间推断；不能把 p 标签当因果或样本级显著性。模板只画预计算值，不计算 p 值、均值或 SD；p 值来源必须在图注/方法页说明。

## 知识关联检查

2026-10-22 查过 M3（通路打分与组间比较）和小提琴图型页。V7 与 M3 语义相关：M3 产出 `pathway-group-summary`，模板读取预计算 p/mean/SD；M4 的 Wilcoxon 已并入 M3，不单独成方法页（按 2026-10-22 规则）。当前来源为合成示例，p 标签改为无星号格式；模板待作者签核后建立并补 `figure_relations`。

## 使用记录

2026-10-22 从 `2026-10-22-glaucoma-scrna/figures/fig06-pathway-violin` 收录；机械 QA 0 失败；作者签核待完成。

<!-- user:start -->
<!-- user:end -->
