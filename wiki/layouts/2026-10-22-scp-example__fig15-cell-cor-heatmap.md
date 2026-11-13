---
type: layout
id: 2026-10-22-scp-example__fig15-cell-cor-heatmap
title: 细胞相似度热图
status: pending_template
gallery_entry: 2026-10-22-scp-example/figures/fig15-cell-cor-heatmap
gallery_version: 1
signedoff_version: 1
language: r
tags:
- 单细胞分析
panels:
  A: heatmap
chart_types:
- heatmap
templates:
- 2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap
template_panels:
  2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap:
  - A
favorite: false
keywords:
- SCP
- pancreas_sub
- heatmap
- similarity
---
# 细胞相似度热图

![[layouts/2026-10-22-scp-example__fig15-cell-cor-heatmap/thumb.png]]

<!-- facts:start -->
- 来源：SCP v0.5.6 示例数据图型
- 公众号：SCP
- 日期：2026-10-22
- URL：https://github.com/zhanghao-njmu/scp
- 画廊条目：2026-10-22-scp-example/figures/fig15-cell-cor-heatmap
- 语言：r
- 数据来源：original
- 代码来源：adapted
- 标签：单细胞分析
- 关键词：SCP、pancreas_sub、heatmap、similarity
- 图型：[[chart-types/heatmap]]
- 面板：[[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

`CellCorHeatmap(srt_query = pancreas_sub, query_group = "SubCellType")` 在 `pancreas_sub` 上的原生单 panel：`Standard_SCP` 后按 SubCellType 折叠为 8×8 查询-查询 cosine 相似度矩阵，行列注释为 SubCellType，色标 `Cosine similarity`（0.62–1），8×6 in、150 dpi。适合检查组间相似度结构、批次/整合效果和参考投影的组水平对应。

来源是 SCP v0.5.6（commit `b9b0eb7a…`，GPL >= 3）`CellCorHeatmap()`；模板从 A panel 拆出，读取 `render-correlation-heatmap` 长表，不重算相似度。

## 不适用

- `similarity` 必须是上游已算好的矩阵；模板不重算 cosine/Pearson/KNN，也不把距离当相似度。
- 只覆盖 query-query、组水平折叠、无 cell annotation 的默认路径；panc8 参考集、细胞级不折叠、nlabel/label_cutoff、annotation、flip/cluster 未验证。
- 相似度量纲/方向由上游决定；不同 metric 的矩阵不能混在同一色标。
- 行列不完整、重复标签或分组缺失会报错；组数/标签过长按 sizing 调整，max 超限报错。
- 示例数据不是病例/对照设计，不能据此作生物学结论；相似度热图不替代统计检验或注释。

## 知识关联检查

日期 2026-10-22；查过 [[methods/scp-visualization-interface]]、[[methods/scp-integration]]、[[methods/scp-standard-workflow]]、[[methods/scp-annotation-projection]] 与 heatmap 图型页。

- 模板：[[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] 从本页 A panel 拆出；读取 `render-correlation-heatmap`，固定示例与来源逐字节一致。
- 方法关系：[[methods/scp-visualization-interface]] 的 `CellCorHeatmap()` 是同一原生实现，已登记 adaptable；相似度矩阵由整合/标准流程/参考投影方法在课题内算好并导出，模板不重算。
- 一图多方法：任何产生完整 row×column 相似度矩阵的方法都可驱动模板。
- 验证范围：表半 `simil_matrix` 与上游 identical；固定 8×6@150 与来源逐字节一致；adaptive 与非法输入已测；未验证参考数据集、细胞级不折叠、nlabel/annotation、flip/cluster 与真实课题流水线。

## 使用记录

2026-10-22 从 SCP v0.5.6 `CellCorHeatmap()` 的原生输出入库；A panel 单 panel；模板 `2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap` 已建，固定回放与来源逐字节一致（SHA256 `6f96f3c2…`）。

<!-- user:start -->
<!-- user:end -->
