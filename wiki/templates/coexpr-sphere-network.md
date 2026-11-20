---
type: template
id: coexpr-sphere-network
title: hdWGCNA 共表达模块球体网络图
status: ready
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
- transcriptomics
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
style_tier: variant
journal_style: hdWGCNA
---
# hdWGCNA 共表达模块球体网络图

![[templates/coexpr-sphere-network/preview.png]]

<!-- facts:start -->
- 来源：[[layouts/2026-11-19-hdwgcna-network__fig01|hdWGCNA 共表达模块球体网络图]]
- 语言：r
- 标签：transcriptomics、single-cell
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

### nodes（gene_module.csv）：模块基因表（每行一个 hub 基因：gene_name、module、可选 color 与 annotation 模块功能注释） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| gene_name | str | 必需 | 基因名或特征名（须与 edge_file 中的节点名一致） |
| module | str | 必需 | 所属共表达模块名称（如 Agrp_M1 或 ME1） |
| color | str | 可选 | 模块十六进制配色（如 #b92d2d；缺省时按模块数自动生成调色板） |
| annotation | str | 可选 | 模块代表功能注释（如 GO/KEGG 最显著富集通路名；缺省只显示模块名） |

### edges（edge_file.csv）：共表达网络连边表（由 TOM > 阈值筛选得到的基因对 from、to 与可选 tom 权重） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| from | str | 必需 | 起点基因名 |
| to | str | 必需 | 终点基因名 |
| tom | float | 可选 | 拓扑重叠矩阵权重或相关性强度（可选，默认 0.1） |

### 可覆盖的 style

- `width_in`：`8.4`
- `height_in`：`8.0`
- `dpi`：`300`
- `point_size`：`1.95`
- `point_alpha`：`0.95`
- `edge_color`：`"#a8a8a8"`
- `edge_alpha`：`0.18`
- `edge_width`：`0.22`
- `label_size`：`3.15`
- `wrap_width`：`28`
- `segment_color`：`"#2f2f2f"`
- `segment_size`：`0.42`
- `seed`：`42`
- `title`：`""`

## 使用记录

<!-- user:start -->
<!-- user:end -->
