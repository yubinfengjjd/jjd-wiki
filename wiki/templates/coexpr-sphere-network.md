---
type: template
id: coexpr-sphere-network
title: hdWGCNA 共表达模块球体网络图
status: draft
layouts: []
sources:
- layouts/2026-11-19-hdwgcna-network__fig01
panels: []
language: r
primary_method: coexpression-ppi-network
data_domains:
- single-cell
- bulk-transcriptomics
tags:
- single-cell
chart_types:
- network
keywords:
- hdWGCNA
- WGCNA
- igraph
- ggrepel
- 共表达网络
favorite: false
---
# hdWGCNA 共表达模块球体网络图

<!-- facts:start -->
- 来源：[[layouts/2026-11-19-hdwgcna-network__fig01|hdWGCNA 共表达模块球体网络图]]
- 语言：r
- 标签：single-cell
- 图型：[[chart-types/network]]
- 输入接口：未声明 · 未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

- 展示单细胞 `hdWGCNA` 或 bulk RNA / 蛋白组 WGCNA 构建的多模块共表达拓扑网络，在球形力导向簇外叠加模块代表通路/功能注释与防重叠引导线。
- 仅需上游筛选后的两张轻量表即可出图：`gene_module.csv`（`gene_name`、`module`，可选 `color` 与 `annotation`）与 `edge_file.csv`（`from`、`to`，可选 `tom` 权重），支持任意模块数 `n` 自适应。

## 不适用

- 不直接接收完整 `Seurat` / `TOM` 矩阵并在线筛选基因；需先在上游按 `GetTOM` + `GetHubGenes`（或相关阈值）裁剪连边后再传入。
- 当跨模块边过密且未过滤弱连接（如未设 `tom > 阈值`）时，灰色连边会过饱和掩盖内部簇分布。

## 知识关联检查

2026-11-18：新建模板主归属方法 [[methods/coexpression-ppi-network]]。经 `rwiki check-dup` 查重，同方法同图型下仅有环形相关性/PPI 导出配方（`fy-correlationv2`、`fy-linkcor`、`figureya-53ppimodule`），尚无面向多模块 hub 基因与 GO 注释叠加的球体网络原生模板，故新建为独立短 slug 模板。示例输入 `example/` 为依据原图视觉特征生成的 14 模块合成近似数据（`synthetic visual approximation`），用于验证渲染通路与样式。

## 数据要求

待填写 spec.json。

## 使用记录

<!-- user:start -->
<!-- user:end -->
