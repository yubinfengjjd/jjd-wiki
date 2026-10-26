---
type: interface
slug: render-cell-linkage
title: 细胞级多维流向长表
columns:
  cell:
    type: str
    description: 细胞标识；同一维度内唯一；每个细胞每个维度一行
  dimension:
    type: str
    description: 维度/注释名；如 CellType、Phase；显式顺序沿流向排列
  category:
    type: str
    description: 该维度下的类别；每个细胞每个维度一个值
  dimension_order:
    type: int
    description: 维度顺序；从 1 起；决定桑基/和弦的左右次序
---
# 细胞级多维流向长表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell | str | 必需 | 细胞标识；同一维度内唯一；每个细胞每个维度一行 |
| dimension | str | 必需 | 维度/注释名；如 CellType、Phase；显式顺序沿流向排列 |
| category | str | 必需 | 该维度下的类别；每个细胞每个维度一个值 |
| dimension_order | int | 必需 | 维度顺序；从 1 起；决定桑基/和弦的左右次序 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/2026-10-22-scp-example__fig10-sankey--sankey|分组流向桑基图]] · [[templates/2026-10-22-scp-example__fig11-chord--chord|分组流向和弦图]]
<!-- facts:end -->

## 含义

行单位是「一个细胞 × 一个维度」：同一 `cell` 在每个 `dimension` 下恰好一行，长表里一个细胞出现多次；模板先按 `dimension_order` 与显式类别顺序透视为 `cell × dimension` 宽表，再执行上游 `table()`/`make_long()`。表内只有分类标签，没有数值列；桑基/和弦的流量就是满足「该维度类别组合」的细胞行数，不是权重，也不做组内比例。`dimension_order` 从 1 连续递增，决定左右次序；同一维度内的类别顺序由 `style.dimension_levels` 显式给出，未给时按输入首次出现顺序。最容易出错的是把宽表直接存成一行一个细胞、多列并排：本接口要求长表，宽表会让模板把同一细胞重复计数或无法判断维度。缺失任一 `cell × dimension` 行会让该细胞在透视后变成 NA，模板应报错而不是静默丢弃；`cell × dimension` 重复会把对应流量成倍放大；`category` 的 NA 不是真实类别。与 `render-cell-metadata` 的区别：后者每个细胞只有一行、恰好一个 `group` 与一个 `stat`，用于组成图并在模板内算组内比例；本接口支持两个以上维度，只做计数流向，不计算比例。与 `render-cell-membership` 的区别：本接口每个维度是互斥的单值类别，成员表是每个集合独立的 0/1，一个细胞可同时属于多个集合。模板不重算分析，只从本表重建上游计数表；准备数据时须先在课题内把 Seurat 元数据或注释表整理成长表，并核对维度名、类别顺序与细胞全集。

<!-- user:start -->
<!-- user:end -->
