---
type: interface
slug: render-correlation-heatmap
title: 相似度矩阵长表
columns:
  row:
    type: str
    description: 行标签（查询细胞/组）；与 column 组成完整矩阵
  column:
    type: str
    description: 列标签（参考细胞/组）；与 row 组成完整矩阵
  similarity:
    type: float
    description: 已计算的相似度；模板不重算
  row_group:
    type: str
    description: 行分组注释；每个 row 一个值
  column_group:
    type: str
    description: 列分组注释；每个 column 一个值
  row_order:
    type: int
    description: 行顺序；从 1 起
  column_order:
    type: int
    description: 列顺序；从 1 起
---
# 相似度矩阵长表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| row | str | 必需 | 行标签（查询细胞/组）；与 column 组成完整矩阵 |
| column | str | 必需 | 列标签（参考细胞/组）；与 row 组成完整矩阵 |
| similarity | float | 必需 | 已计算的相似度；模板不重算 |
| row_group | str | 必需 | 行分组注释；每个 row 一个值 |
| column_group | str | 必需 | 列分组注释；每个 column 一个值 |
| row_order | int | 必需 | 行顺序；从 1 起 |
| column_order | int | 必需 | 列顺序；从 1 起 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]]
<!-- facts:end -->

## 含义

行单位是「一个行标签 × 一个列标签」：`row` 与 `column` 的笛卡尔积必须完整，每个格一个 `similarity`；模板只把已算好的相似度排成矩阵并绘制，不重算相关、距离、KNN 或归一化。`similarity` 的量纲与方向由上游方法决定（如 cosine 0–1、Pearson −1–1），必须在图注/接口说明中写清；不能把距离当相似度，也不能把不同 metric 的矩阵混在同一色标。`row_group`/`column_group` 是行/列的分组注释，每个标签一个值；`row_order`/`column_order` 从 1 起，决定显示顺序；聚类顺序若由上游给定，模板不重新聚类。缺失的 row×column 组合会让矩阵出现空洞，重复组合会冲突；对角线通常是自称相似度 1，但不是必须，需与上游一致。与 `render-group-heatmap` 的区别：后者是 feature × group 的聚合表达，value 是表达量；本接口是样本/细胞/组之间的相似度矩阵，行列标签可以不同。与 `render-feature-heatmap` 的区别：后者是 feature × cell 的表达矩阵，不是相似度。模板不重算分析，也不把相似度转成显著性。

<!-- user:start -->
<!-- user:end -->
