---
type: scenario
id: dimension-reduction-single-cell
title: 降维与单细胞
picks:
- id: templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap
  note: 细胞类型 UMAP（L2）
- id: templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot
  note: 细胞类型 × 基因气泡点图（L2）
- id: methods/scp-standard-workflow
  note: 单细胞标准预处理、降维与聚类
- id: figureya:FigureYa244PCAPlot
  note: bulk PCA 图（L0）
- id: figureya:FigureYa229PCOA
  note: PCoA 图（L0）
- id: figureya:FigureYa254scViolin
  note: 单细胞小提琴（L0）
- id: figureya:FigureYa267scCellChat
  note: CellChat 细胞通讯（L0）
- id: figureya:FigureYa178receptorLigand
  note: 受体—配体图（L0）
tags:
- single-cell
keywords:
- 降维
- PCA
- PCoA
- UMAP
- tSNE
- 单细胞
- 细胞通讯
- marker
- 拟时序
summary: 样本或细胞的降维展示、单细胞注释与 marker、细胞通讯和轨迹。
---

# 降维与单细胞

## 什么时候用

- bulk 样本 PCA / PCoA 看分组分离。
- 单细胞 UMAP、marker 气泡图、细胞比例、通讯与轨迹。

## 首选组合

首选按常用顺序排列；`find` 命中本场景时这些条目排在前面。

<!-- facts:start -->
| 条目 | 级别 | 状态 | 说明 |
|---|---|---|---|
| [[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap|CNS 细胞类型 UMAP]] | L2 | ready · 可用 | 细胞类型 UMAP（L2） |
| [[templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot|细胞类型 × 基因气泡点图]] | L2 | ready · 可用 | 细胞类型 × 基因气泡点图（L2） |
| [[methods/scp-standard-workflow|单细胞标准预处理、降维与聚类]] | note | ready | 单细胞标准预处理、降维与聚类 |
| `figureya:FigureYa244PCAPlot` | L0 | catalog | bulk PCA 图（L0） |
| `figureya:FigureYa229PCOA` | L0 | catalog | PCoA 图（L0） |
| `figureya:FigureYa254scViolin` | L0 | catalog | 单细胞小提琴（L0） |
| `figureya:FigureYa267scCellChat` | L0 | catalog | CellChat 细胞通讯（L0） |
| `figureya:FigureYa178receptorLigand` | L0 | catalog | 受体—配体图（L0） |
<!-- facts:end -->

## 注意

- L0 条目未在 Wiki 运行，用前先 promote 并原样跑通。
- 单细胞流程参数（分辨率、批次方法）属于分析决策，按课题确认。

## 作者备注

<!-- user:start -->
<!-- user:end -->
