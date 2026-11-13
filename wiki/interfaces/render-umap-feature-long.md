---
type: interface
slug: render-umap-feature-long
title: UMAP 坐标与特征长表
columns:
  cell_id:
    type: str
    description: 细胞标识；同一 feature 内唯一，唯一键为 (cell_id, feature)
  umap_1:
    type: float
    description: UMAP 第一维坐标
  umap_2:
    type: float
    description: UMAP 第二维坐标
  group:
    type: str
    description: 细胞类型或分组；用于背景点和目标群轮廓
  feature:
    type: str
    description: 基因/marker 名称
  value:
    type: float
    description: 该细胞在该 feature 上的表达值；0 表示不画前景点
---
# UMAP 坐标与特征长表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell_id | str | 必需 | 细胞标识；同一 feature 内唯一，唯一键为 (cell_id, feature) |
| umap_1 | float | 必需 | UMAP 第一维坐标 |
| umap_2 | float | 必需 | UMAP 第二维坐标 |
| group | str | 必需 | 细胞类型或分组；用于背景点和目标群轮廓 |
| feature | str | 必需 | 基因/marker 名称 |
| value | float | 必需 | 该细胞在该 feature 上的表达值；0 表示不画前景点 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap|marker 特征 UMAP 小多图]]
- 经模板关联的方法（经读取该接口的模板；不是 direct，按方法页准备数据）：[[methods/cell-type-annotation|细胞类型注释]]（adaptable） · [[methods/dimensionality-reduction|单细胞降维分析]]（adaptable） · [[methods/dynamic-feature-analysis|拟时序动态特征分析]]（adaptable） · [[methods/trajectory-inference|拟时序与轨迹推断]]（adaptable）
<!-- facts:end -->

## 含义

本表以「每个细胞 × 每个 feature 一行」为粒度，同一 cell_id 会按 feature 数重复出现（唯一键是 `(cell_id, feature)`；接口页写的“同一图内唯一”应理解为同一 feature 内唯一）；模板用 unique(cell_id, umap_1, umap_2, group) 取坐标，所以一个细胞的坐标和 group 必须在它所有 feature 行里完全一致。value 本身由上游给定：可以是 counts、log-normalized 或 scaled 表达，方法页也允许写 pseudotime 或动态特征得分，接口不规定单位，模板不归一化、不重算表达、不做统计检验；只有 value > 0 的行进入前景，0 与「该 feature 没有这一行或值为 NA」都只留灰底，视觉上无法区分，scaled 值的负值也会这样被丢掉。最容易出错的是重复键和配对：同一 (cell_id, feature) 出现多行时模板按 match 静默取第一条，混入不同嵌入或不同批次的坐标会让前景点和目标群轮廓落在错的位置。另一个前提是每个基因的 colorbar 上下限由模板按该基因前景值自行重算 q05/q98 并 squish，不是上游给定；画哪些 feature 由 style.genes 决定（未给时才用表内全部），给了 style.genes 后表里多出的 feature 不会进网格，目标群轮廓还要求 style.gene_to_group 为该 feature 指定一个表中存在的 group。若只需按细胞类型给 UMAP 着色、不需要表达值，用 render-umap-groups（每细胞一行）；若已有 group × feature 的平均表达和阳性比例要画气泡点图，用 render-dotplot-long（上游先聚合），本接口保留细胞级表达、模板不做聚合。

<!-- user:start -->
<!-- user:end -->
