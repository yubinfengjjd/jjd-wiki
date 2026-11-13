---
type: interface
slug: render-group-heatmap
title: 分组热图长表
columns:
  matrix:
    type: str
    description: 分组变量/矩阵名，如 CellType；同一 feature 可出现在多个矩阵
  feature:
    type: str
    description: 基因或元数据特征标识；同一矩阵内唯一
  group:
    type: str
    description: 列分组/细胞类型；同一矩阵内唯一
  value:
    type: float
    description: 聚合后的表达值，已按 exp_method 变换（如 zscore）
  percent:
    type: float
    description: 该组中 value > exp_cutoff 的细胞比例，0–1
  matrix_order:
    type: int
    description: 矩阵显示顺序，从 1 起
  group_order:
    type: int
    description: 同一矩阵内列顺序，从 1 起
  feature_order:
    type: int
    description: 行顺序，从 1 起；同一 feature 在各矩阵保持一致
---
# 分组热图长表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| matrix | str | 必需 | 分组变量/矩阵名，如 CellType；同一 feature 可出现在多个矩阵 |
| feature | str | 必需 | 基因或元数据特征标识；同一矩阵内唯一 |
| group | str | 必需 | 列分组/细胞类型；同一矩阵内唯一 |
| value | float | 必需 | 聚合后的表达值，已按 exp_method 变换（如 zscore） |
| percent | float | 必需 | 该组中 value > exp_cutoff 的细胞比例，0–1 |
| matrix_order | int | 必需 | 矩阵显示顺序，从 1 起 |
| group_order | int | 必需 | 同一矩阵内列顺序，从 1 起 |
| feature_order | int | 必需 | 行顺序，从 1 起；同一 feature 在各矩阵保持一致 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]]
<!-- facts:end -->

## 含义

一行代表一个 `matrix × feature × group` 的聚合单元，不是单个细胞。`value` 是上游按 `exp_method` 变换后的组均值（如 zscore；不是原始表达），`percent` 是该组中表达值大于 `exp_cutoff` 的细胞比例，范围 0–1（不是 0–100）。`matrix` 用来并排放多个分组变量（如 CellType、SubCellType），同一 feature 在各矩阵的行顺序由 `feature_order` 固定；`matrix_order`/`group_order` 决定显示顺序，避免读取时按字母重排。准备时最容易出错的是把 zscore 当原始表达、把 percent 当百分数、同一矩阵内重复 feature，或各矩阵的 feature 集合/顺序不一致。与 `render-cell-metadata` 的区别是本表已经聚合且每个 feature×group 一行，后者是每个细胞一行、由模板自行计数；与 `render-dotplot-long` 的区别是本表可含多个矩阵并保留 value/percent 两列，点图接口只有单一 group/feature 表。模板不重算聚合、zscore 或 percent。文件名固定为 `render-group-heatmap.csv`。

<!-- user:start -->
<!-- user:end -->
