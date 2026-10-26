---
type: interface
slug: render-cell-feature-values
title: 细胞级特征值长表
columns:
  cell:
    type: str
    description: 细胞标识；同一特征内唯一；每个细胞每个特征一行
  feature:
    type: str
    description: 基因或特征标识；一张图可含多个特征
  value:
    type: float
    description: 该细胞该特征的数值（表达/得分）；单位由上游定义
  group:
    type: str
    description: 密度分组的类别；每个细胞一个值
  feature_order:
    type: int
    description: 特征面板/行顺序；从 1 起
  group_order:
    type: int
    description: 组（山脊线）顺序；从 1 起
---
# 细胞级特征值长表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell | str | 必需 | 细胞标识；同一特征内唯一；每个细胞每个特征一行 |
| feature | str | 必需 | 基因或特征标识；一张图可含多个特征 |
| value | float | 必需 | 该细胞该特征的数值（表达/得分）；单位由上游定义 |
| group | str | 必需 | 密度分组的类别；每个细胞一个值 |
| feature_order | int | 必需 | 特征面板/行顺序；从 1 起 |
| group_order | int | 必需 | 组（山脊线）顺序；从 1 起 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/2026-10-22-scp-example__fig16-cell-density--ridge|分组表达密度图]]
<!-- facts:end -->

## 含义

行单位是「一个细胞 × 一个特征」：同一 `feature` 下每个 `cell` 恰好一行，`value` 是该细胞该特征的数值（表达、得分或其它连续量），`group` 是该细胞用于密度分组的类别，`feature_order`/`group_order` 从 1 起决定多特征面板与山脊线的显示顺序。模板按 `feature × group` 计算密度/山脊线并绘制；密度是图的统计变换，不是额外分析，模板不重算差异检验或汇总均值。`value` 的单位与变换（raw counts、normalized data、score、log 尺度）必须由上游明确并保持一致；同一张图里的多个 feature 若量纲不同，应分面或显式说明，不能共用一个色标/坐标解释。最容易出错的是把每个 group 的均值当成一行（会丢失分布）、把同一个细胞在不同 feature 下的 group 写成不同值、或让 `cell × feature` 缺失/重复；这些都会改变密度形状。`group` 的 NA 不是真实类别；`value` 的 NA/Inf 需在准备阶段处理。与 `render-cell-metadata` 的区别：后者只有分类标签、没有数值，模板做计数/比例；本接口是连续值，模板做密度。与 `render-grouped-values` 的区别：后者是单个数值列 + 分组（常用于小提琴/箱线），本接口支持多个 feature 且明确 cell×feature 粒度。模板不重算分析，只从本表还原上游密度图。

<!-- user:start -->
<!-- user:end -->
