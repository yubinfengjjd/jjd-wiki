---
type: interface
slug: subgroup-effect-table
title: 亚组效应量汇总表
columns:
  label:
    type: str
    description: 行标签；亚组标题行与亚组行按显示顺序排列，前导空格保留为缩进
  estimate:
    type: float
    description: 效应量点估计（HR/OR 等比值）；标题行留空
  lower:
    type: float
    description: 95% CI 下限；标题行留空
  upper:
    type: float
    description: 95% CI 上限；标题行留空
  n:
    type: int
    description: 该行样本数，可选
    required: false
  percent:
    type: float
    description: 该行样本占比（0–100），可选；给出时用于方块大小
    required: false
  p:
    type: str
    description: P 值文本（如交互作用 P），可选，原样显示
    required: false
---
# 亚组效应量汇总表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| label | str | 必需 | 行标签；亚组标题行与亚组行按显示顺序排列，前导空格保留为缩进 |
| estimate | float | 必需 | 效应量点估计（HR/OR 等比值）；标题行留空 |
| lower | float | 必需 | 95% CI 下限；标题行留空 |
| upper | float | 必需 | 95% CI 上限；标题行留空 |
| n | int | 可选 | 该行样本数，可选 |
| percent | float | 可选 | 该行样本占比（0–100），可选；给出时用于方块大小 |
| p | str | 可选 | P 值文本（如交互作用 P），可选，原样显示 |

- 产出方法：无
- 读取方法：无
- 使用的模板：无
<!-- facts:end -->

## 含义

<!-- user:start -->
<!-- user:end -->
