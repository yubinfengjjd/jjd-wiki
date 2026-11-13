---
type: layout
id: 2026-10-22-glaucoma-scrna__fig02-marker-feature-umap
title: marker 特征 UMAP 小多图（GSE251716）
status: pending_template
gallery_entry: 2026-10-22-glaucoma-scrna/figures/fig02-marker-feature-umap
gallery_version: 1
signedoff_version: 1
language: r
tags:
- 单细胞分析
panels:
  A: umap
chart_types:
- umap
templates:
- 2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap
template_panels:
  2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap:
  - A
favorite: false
keywords:
- GSE251716
- marker
---
# marker 特征 UMAP 小多图（GSE251716）

![[layouts/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap/thumb.png]]

<!-- facts:start -->
- 来源：青光眼单细胞项目（GSE251716）图表复刻
- 公众号：作者课题
- 日期：2026-10-22
- 画廊条目：2026-10-22-glaucoma-scrna/figures/fig02-marker-feature-umap
- 语言：r
- 数据来源：synthetic
- 代码来源：adapted
- 标签：单细胞分析
- 关键词：GSE251716、marker
- 图型：[[chart-types/umap]]
- 面板：[[templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap|marker 特征 UMAP 小多图]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

多个 marker 在同一 UMAP 上的小多图：输入 UMAP 坐标 + `cell_id, feature, value` 长表 + 细胞类型分组 + 基因→目标细胞类型映射。每个小图保留灰色背景、表达渐变、目标群虚线轮廓、独立 colorbar 和短箭头。基因数由数据识别，示例 9 个不是限制。

## 不适用

没有坐标/表达长表；基因在数据中全为零；基因或组数过多导致网格不可读；不能把特征图当差异表达或统计检验。模板按基因分别裁剪 q05/q98，不能比较不同基因的绝对表达量。

## 知识关联检查

2026-10-22 查过 M1（UMAP）、M2（marker 注释）和现有 UMAP 图型页。V2 与 M1/M2 语义相关：M1 提供坐标，M2 提供 marker→细胞类型映射和 celltype 轮廓。当前来源为合成示例；模板待作者签核后建立并补 `figure_relations`。

## 使用记录

2026-10-22 从 `2026-10-22-glaucoma-scrna/figures/fig02-marker-feature-umap` 收录；机械 QA 0 失败；视觉 QA 记录 panel 尺寸/间距 WARN；作者签核待完成。

<!-- user:start -->
<!-- user:end -->
