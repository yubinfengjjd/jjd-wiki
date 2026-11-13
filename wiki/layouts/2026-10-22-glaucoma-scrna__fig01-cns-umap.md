---
type: layout
id: 2026-10-22-glaucoma-scrna__fig01-cns-umap
title: CNS 细胞类型 UMAP（GSE251716）
status: pending_template
gallery_entry: 2026-10-22-glaucoma-scrna/figures/fig01-cns-umap
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
- 2026-10-22-glaucoma-scrna__fig01-cns-umap--umap
template_panels:
  2026-10-22-glaucoma-scrna__fig01-cns-umap--umap:
  - A
favorite: false
keywords:
- GSE251716
---
# CNS 细胞类型 UMAP（GSE251716）

![[layouts/2026-10-22-glaucoma-scrna__fig01-cns-umap/thumb.png]]

<!-- facts:start -->
- 来源：青光眼单细胞项目（GSE251716）图表复刻
- 公众号：作者课题
- 日期：2026-10-22
- 画廊条目：2026-10-22-glaucoma-scrna/figures/fig01-cns-umap
- 语言：r
- 数据来源：synthetic
- 代码来源：adapted
- 标签：单细胞分析
- 关键词：GSE251716
- 图型：[[chart-types/umap]]
- 面板：[[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap|CNS 细胞类型 UMAP]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

单细胞 UMAP 的分组/细胞类型展示：输入 `cell_id, umap_1, umap_2, group`，group 可以是 cluster 或 celltype。画点、虚线非凸包、簇中心标签、左下短箭头 UMAP_1/UMAP_2 和右侧图例。组数由数据识别，示例 9 组不是限制。

## 不适用

没有 UMAP 坐标或分组列；需要组间定量比较/统计检验；组数过多且标签无法排布；不能用包络形状证明群间差异。真实数据回放需要先导出坐标表，模板不读 Seurat 对象。

## 知识关联检查

2026-10-22 查过 M1（预处理/聚类）、M2（注释）和现有 UMAP 图型页。V1 与 M1/M2 语义相关：M1 提供坐标和 cluster，M2 提供 celltype；同一模板可着两种 group。当前来源为合成示例，未关联真实 GSE251716 回放；模板待作者签核后建立并补 `figure_relations`。

## 使用记录

2026-10-22 从 `2026-10-22-glaucoma-scrna/figures/fig01-cns-umap` 收录；机械 QA 0 失败；作者签核待完成。

<!-- user:start -->
<!-- user:end -->
