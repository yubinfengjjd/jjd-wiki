---
type: interface
slug: render-feature-heatmap
title: 特征×细胞表达矩阵长表
columns:
  matrix:
    type: str
    description: 矩阵/分组变量名；同一图可含多个 matrix
  feature:
    type: str
    description: 基因或特征标识；同一矩阵内唯一
  cell:
    type: str
    description: 细胞标识；同一矩阵内唯一；每个细胞每个特征一行
  group:
    type: str
    description: 细胞所属分组（列注释）；每个细胞一个值
  value:
    type: float
    description: 已按 exp_method 变换的表达值（如 zscore）；模板不重算变换
  matrix_order:
    type: int
    description: 矩阵显示顺序；从 1 起
  feature_order:
    type: int
    description: 特征行顺序；从 1 起；各矩阵需一致
  cell_order:
    type: int
    description: 细胞列顺序；从 1 起
  group_order:
    type: int
    description: 分组图例/注释顺序；从 1 起
---
# 特征×细胞表达矩阵长表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| matrix | str | 必需 | 矩阵/分组变量名；同一图可含多个 matrix |
| feature | str | 必需 | 基因或特征标识；同一矩阵内唯一 |
| cell | str | 必需 | 细胞标识；同一矩阵内唯一；每个细胞每个特征一行 |
| group | str | 必需 | 细胞所属分组（列注释）；每个细胞一个值 |
| value | float | 必需 | 已按 exp_method 变换的表达值（如 zscore）；模板不重算变换 |
| matrix_order | int | 必需 | 矩阵显示顺序；从 1 起 |
| feature_order | int | 必需 | 特征行顺序；从 1 起；各矩阵需一致 |
| cell_order | int | 必需 | 细胞列顺序；从 1 起 |
| group_order | int | 必需 | 分组图例/注释顺序；从 1 起 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]]
<!-- facts:end -->

## 含义

行单位是「一个 matrix × 一个特征 × 一个细胞」：同一 `matrix` 下每个 `feature × cell` 恰好一行，长表透视为 `feature × cell` 矩阵；同一图可含多个 matrix（如按 group.by 变量并列），各矩阵的特征集合与 `feature_order` 应一致。`value` 是已按 `exp_method` 变换后的数值（SCP `FeatureHeatmap` 默认 zscore），模板只负责排布与绘制，不重算 zscore、归一化或缩放。`group` 是细胞所属分组（列注释），`group_order` 决定图例/注释顺序；`matrix_order` 决定矩阵显示顺序。`feature_order` 与 `cell_order` 从 1 起，分别决定行/列顺序；聚类排序由上游给定，模板不重新聚类。最容易出错的是把原始 counts 或已经聚合的 group 均值当 `value`：前者会把文库大小/基因长度带进颜色，后者会丢失细胞级分布并与 `render-group-heatmap` 混淆。缺失任一 `matrix × feature × cell` 行会在透视后变成 NA；重复行会覆盖或放大；`value` 的 NA/Inf 必须在准备阶段处理。与 `render-group-heatmap` 的区别：后者是 feature × group 的聚合矩阵（无细胞列，value 与 percent 已聚合），本接口是 cell-level 表达矩阵，用于逐细胞热图与列注释。与 `render-cell-feature-values` 的区别：后者只给 cell/feature/value/group 与顺序，用于密度或分布图，不包含 matrix 分组与矩阵顺序。模板不重算分析，只从本表重建上游绘制对象。

<!-- user:start -->
<!-- user:end -->
