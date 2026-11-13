---
type: method
id: scrna-marker-annotation
title: 单细胞标记基因注释与聚类检查
status: ready
tags:
- 单细胞分析
inputs: []
outputs: []
source:
  kind: project
  path: E:\青光眼单细胞\annotation.R
license: none
cite: []
favorite: false
keywords:
- GSE251716
- 细胞类型注释
- marker
- SCpubr
- UMAP
- 点图
- 单细胞
method_kind: technical
summary: 青光眼 scRNA 课题的 marker 注释与聚类检查实现记录；分析问题见细胞类型注释与聚类家族。
data_contract:
  input: GSE251716 预处理后的 Seurat 对象、marker 列表和 cluster 标签。
  output: 作者脚本的 celltype 标签、marker 图和注释检查；本页不重新运行。
---
# 单细胞标记基因注释与聚类检查

<!-- facts:start -->
- 来源：E:\青光眼单细胞\annotation.R
- 许可证：仅供个人研究参考
- 引用：无
- 标签：单细胞分析
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

> **资料类型：技术/来源资料，不是默认分析家族。**
> 当前分析问题见：[[methods/cell-type-annotation|细胞类型注释]]、[[methods/cell-clustering|单细胞聚类分析]]。原代码与作者备注保留；本页不再作为分析推荐卡片。

## 用途

用一组组织特异的 marker 基因检查聚类，给每个 cluster 指定细胞类型；产出 celltype 标签、marker 点图、CNS 风格 UMAP、marker 特征 UMAP 和细胞比例图。适用于已有聚类标签的 scRNA-seq 数据，不自动做注释算法或统计检验。

## 原始实现与家族范围

来源是作者课题脚本 `annotation.R`，具体实现为 SCpubr DotPlot + 手工 cluster→celltype 映射 + 自定义 ggplot2 绘图函数。家族限定为“基于 marker 的手工注释与诊断图”；可推广到其他组织，但 marker 列表、cluster 数、细胞类型名和映射表都必须重设。本页的 17 簇→9 类映射是视网膜/眼组织数据特定，不是通用标签体系。

## 适用

- 已有 UMAP、聚类标签和表达矩阵；每个 cluster 有足够细胞。
- marker 基因在表达矩阵中，且 marker 组合能区分目标细胞类型。
- 需要可解释的、与文献 marker 一致的手工注释，以及后续的 UMAP/点图/比例图。
- 需要检查 cluster 是否被过度合并或拆分、marker 是否落在对应群。

## 不适用

- 不能替代自动注释或参考图谱映射；没有特异 marker 时，手工注释会主观。
- 不能把 cluster 编号直接当细胞类型；换数据必须重新检查 marker 和映射。
- 不能从点图的平均表达/百分比推断统计显著性；原脚本没有做差异检验。
- 不能把 celltype 标签当金标准；需要 marker 组合、文献和必要的验证。
- 2026-10-22 历史记录：当时 R 4.3.1 的 Seurat 因 Matrix 版本冲突无法加载，原脚本未重跑；SCpubr 可加载但不能替代 Seurat 对象。2026-10-23 当前隔离库 Seurat 5.6.0 可加载，但 `annotation.R` 仍未函数化/重跑；规范家族状态见 [[methods/cell-type-annotation]]（SingleR not_run；marker 来源未验证）。

## 输入

- Seurat 对象（含 UMAP、聚类、counts/data），或导出的 UMAP 坐标 + cluster + 表达矩阵。
- marker 列表（group → genes）；本页 13 组、52 个基因：RGC、Amacrine、Horizontal、Bipolar、Photoreceptor、Muller_Glia、Astrocyte、Microglia、Macrophage、Endothelial、Pericyte、Fibroblast、RPE。
- cluster → celltype 映射表；本页 17 个 cluster 映射到 9 类（0 Muller_Glia；1 Rod_Photoreceptor；2/5–13 Bipolar；3 Cone_Photoreceptor；4 RGC_like；14 RPE；15 Vascular_Pericyte；16 Amacrine；17 Amacrine_Horizontal_like）。
- 一行代表一个细胞或一个 cluster；表达值需说明是 scaled data 还是 log-normalized data；DotPlot 的 `avg.exp.scaled` 与 `pct.exp` 含义要记录。

## 怎么做

1. 固定分辨率（本页 0.05），`Idents` 设为该分辨率。
2. 用 marker 列表画 SCpubr DotPlot（行=cluster，列=marker 组）；检查每个 cluster 的 marker 组合。
3. 手工把 cluster 映射到 celltype；映射表单独保存，不写死在绘图函数里（原脚本是写死的，复用时要外置）。
4. 画 CNS 风格 UMAP（点 + 虚线非凸包 + 簇中心标签 + 左下短箭头）；检查 celltype 在 UMAP 上是否连续、是否有混合。
5. 画 marker 特征 UMAP 网格（灰底 + 表达渐变 + 目标细胞类型轮廓）；检查 marker 是否落在对应群。原脚本只给“基因→目标细胞类型”有映射的 marker 画轮廓；Astrocyte、Microglia、Macrophage、Endothelial、Fibroblast 没有对应细胞类型，排序时落在最后。
6. 画细胞比例堆叠图（按样本/条件）；比例是描述性，不做统计检验。
7. 必要诊断：marker 是否特异、cluster 是否被过度合并/拆分、celltype 比例是否符合组织预期；必要时回到 QC 或聚类分辨率。手工注释的依据（marker 组合、文献、阴性 marker）应记录在注释表或补充材料中。

## 代码

- `source/annotation.R` 为原字节归档，未修改。依赖 Seurat、SCpubr、ggunchull、ggplot2、dplyr、scales、grid。
- 原脚本含 `setwd("E:\\青光眼单细胞")` 和写死的 cluster→celltype 映射；复用时应把映射表作为输入，不要直接改脚本里的常量。
- 验证状态：2026-10-22 记录 SCpubr/ggunchull 在 R 4.3.1 可加载，Seurat 因 Matrix 冲突无法加载，原脚本未重跑。2026-10-23 当前 Seurat 5.6.0 可加载，但 `annotation.R` 仍未函数化/验证；点图/气泡图/特征图/比例图的 ggplot2 核心仍只作图表适配，见 [[methods/cell-type-annotation]]。
- 没有把注释映射包装成自动算法；手工注释不是可复现算法，必须保留映射表和判断依据。

## 输出

- `GSE251716_seurat_annotated.rds`：含 `celltype`。
- 课题内可导出为下游表：
  - `cell-metadata.csv`：`cell_id, cluster, celltype, sample, condition`。
  - `dotplot-long.csv`：`group, feature, avg_expression, pct_expressed`，供点图模板使用。
  - `umap-groups.csv`：`cell_id, umap_1, umap_2, group`（group=celltype），供 UMAP 模板使用。
  - `feature-long.csv`：`cell_id, feature, value`，供 marker 特征图使用。
  - `cell-proportions.csv`：`group, celltype, proportion`，供比例图使用。
- 这些表是课题内导出；点图的 `avg.exp.scaled` 需要说明缩放方式，不能与原始表达混用。

## 知识关联检查

2026-10-23 分类为技术/来源资料：旧 id、`source/` 原字节和作者备注保留，但不再作为默认分析家族推荐。语义配图关系已迁往 [[methods/cell-type-annotation|细胞类型注释]]、[[methods/cell-clustering|单细胞聚类分析]]；本页只保留来源与实现证据链接，不再维护 `figure_relations` 主记录。原页面正文中的模板/证据链接仍可用于溯源；结构相似不等于科学直连。

## 使用记录

2026-10-22 建页，归档原脚本；作者已确认方法页。fig01–fig04 模板已建并用合成示例回放，待作者确认模板。

<!-- user:start -->
<!-- user:end -->
