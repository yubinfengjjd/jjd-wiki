---
type: interface
slug: render-umap-groups
title: UMAP 坐标与分组表
columns:
  cell_id:
    type: str
    description: 细胞标识；同一图内唯一
  umap_1:
    type: float
    description: UMAP 第一维坐标
  umap_2:
    type: float
    description: UMAP 第二维坐标
  group:
    type: str
    description: 分组或细胞类型；用于着色、包络和标签
---
# UMAP 坐标与分组表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell_id | str | 必需 | 细胞标识；同一图内唯一 |
| umap_1 | float | 必需 | UMAP 第一维坐标 |
| umap_2 | float | 必需 | UMAP 第二维坐标 |
| group | str | 必需 | 分组或细胞类型；用于着色、包络和标签 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap|CNS 细胞类型 UMAP]]
- 经模板关联的方法（经读取该接口的模板；不是 direct，按方法页准备数据）：[[methods/batch-integration|单细胞批次整合]]（adaptable） · [[methods/cell-clustering|单细胞聚类分析]]（adaptable） · [[methods/cell-quality-control|单细胞质量控制]]（adaptable） · [[methods/cell-type-annotation|细胞类型注释]]（adaptable） · [[methods/dimensionality-reduction|单细胞降维分析]]（adaptable） · [[methods/doublet-detection|双细胞检测]]（adaptable） · [[methods/reference-mapping|参考图谱映射]]（adaptable） · [[methods/trajectory-inference|拟时序与轨迹推断]]（adaptable）
<!-- facts:end -->

## 含义

一行代表一个细胞，cell_id 在同一图内唯一（示例 1804 行即 1804 个细胞、9 个 group），点、虚线包络和组标签都由这些行在出图时生成，不是每组一行或每细胞×组一行。umap_1/umap_2 是同一嵌入的原始 UMAP 坐标，未见归一化（示例 x 约 -8–11、y 约 -14–12，且坐标轴刻度被隐藏），不能按 0–1 或 0–100 解读；group 是分类标签，顺序和配色由 style 的 group_levels 与 palette 决定，坐标 NA 或 group 值不在 group_levels 中会直接报错。最容易出错的前提是坐标与 group 必须来自同一嵌入且 cell_id 对齐：模板不读 Seurat/RDS，也不重算降维、聚类或注释（上游给定/模板不重算），只在出图时计算包络和组内坐标中位数作为标签位置；换数据若沿用示例 group_levels 会报错，模板也不检查 cell_id 唯一性，重复行会重复画点并影响包络和标签。与 [[interfaces/render-umap-feature-long|render-umap-feature-long]] 的区别是后者为每细胞×feature 一行并携带 value（0 表示不画前景点，各基因按自己的 q05/q98 裁剪色标）：只按 cluster/celltype/batch/QC 等标签给整群着色时用 render-umap-groups，要看 marker 表达梯度时用 render-umap-feature-long。

<!-- user:start -->
<!-- user:end -->
