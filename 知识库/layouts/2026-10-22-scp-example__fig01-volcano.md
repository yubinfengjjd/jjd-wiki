---
type: layout
id: 2026-10-22-scp-example__fig01-volcano
title: 火山图：Endocrine vs 其余细胞（SCP 示例）
status: pending_template
gallery_entry: 2026-10-22-scp-example/figures/fig01-volcano
gallery_version: 2
signedoff_version: 2
language: r
tags:
- 单细胞分析
keywords:
- SCP
- pancreas_sub
- volcano
- DE
panels:
  A: volcano
chart_types:
- volcano
templates:
- 2026-10-22-scp-example__fig01-volcano--volcano
template_panels:
  2026-10-22-scp-example__fig01-volcano--volcano:
  - A
favorite: false
---
# 火山图：Endocrine vs 其余细胞（SCP 示例）

![[layouts/2026-10-22-scp-example__fig01-volcano/thumb.png]]

<!-- facts:start -->
- 来源：SCP v0.5.6 示例数据图型
- 公众号：SCP
- 日期：2026-10-22
- URL：https://github.com/zhanghao-njmu/scp
- 画廊条目：2026-10-22-scp-example/figures/fig01-volcano
- 语言：r
- 数据来源：mixed
- 代码来源：adapted
- 标签：单细胞分析
- 关键词：SCP、pancreas_sub、volcano、DE
- 图型：[[chart-types/volcano]]
- 面板：[[templates/2026-10-22-scp-example__fig01-volcano--volcano|差异表达火山图]]（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

SCP v0.5.6 `VolcanoPlot()` 的单 panel 示例：一个 comparison group（本条目为 `Endocrine`）相对其余细胞的差异表达结果。适合展示 DE 表中基因的 `diff_pct`、signed `-log10(p_val_adj)` 与 `avg_log2FC` 颜色编码，用于快速检查差异方向、显著点和候选标签基因。

本条目只覆盖一个逻辑 panel；原 SCP 函数按 `group1` facet 的多组整图不进入 Wiki，完整原图仅作画廊溯源。

## 不适用

- 不能把 `pancreas_sub` 示例数据当真实生物学比较；该数据集没有病例/对照设计。
- 不能把 signed y 轴当常规火山图；它是 SCP 的显示方式，y 轴标签取绝对值。
- 不能替代 DE 统计、多重校正或样本级推断；图中显著点只是按阈值着色。
- 不能把本条目当多组 facet 整图；其他 CellType 组需要另行选择/建条目。
- 不能把 SCP 默认阈值（`log2FC > 0 & p_adj < 0.05`）当通用阈值；换数据要重设。
- 当前 DE 表由 Seurat `FindMarkers` 代替 SCP `RunDEtest` 计算；p 值与 SCP 原实现不可直接数值比较。

## 知识关联检查

日期 2026-10-22；查过现有 methods（`scp-de-enrichment-dynamic`、`scp-standard-workflow`）与 templates（fig03 dotplot、fig06 violin；尚无 volcano 模板）。

- 候选方法：[[methods/scp-de-enrichment-dynamic|单细胞差异表达、富集、GSEA 与动态特征]] 产出 DE 结果表；本图消费其 `gene/group1/avg_log2FC/pct.1/pct.2/p_val/p_val_adj`。待模板 ready 后，在方法页 `figure_relations` 建立主关系（预期 `adaptable`，接口需从 `srt@tools` 导出）。
- 一方法多图：同一 DE 结果还可进 fig03（dotplot）与 fig06（violin）；本图增加“火山图”语义，不替代其他图。
- 一图多方法：本图也可由其他 DE 实现（Seurat FindMarkers、SCP RunDEtest）产生；当前数据来源为 Seurat FindMarkers，已在 README 记录。
- 无结构直连：本 layout 尚无模板，不能标 direct；方法页也没有把本 layout 当 ready 模板。
- 验证范围：原 SCP `VolcanoPlot()` 已用示例数据运行并生成 source image；复刻用同一 DE 表；机械 QA 0 failure；人工视觉 QA 由 agent 初评（colorbar 刻度密度 WARN），作者签核待定。
- 边界：示例图不是论文原图；不复刻多组 facet；不改变 DE 计算或阈值。

## 使用记录

2026-10-22 创建画廊条目 `2026-10-22-scp-example/figures/fig01-volcano`；用 SCP `VolcanoPlot()` 生成单 panel source；复刻代码在条目 `code/`；`ingest-figure` 建 layout，待作者签核。

<!-- user:start -->
<!-- user:end -->
