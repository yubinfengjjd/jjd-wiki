---
type: interface
slug: cell-proportion-stats
title: 细胞亚群比例与 Ro/e 偏好统计表
columns:
  sample_id:
    type: str
    description: 样本编号；用于样本级独立统计与检验
    required: true
  group:
    type: str
    description: 实验分组或组织来源（如 Control、Model）
    required: true
  cell_type:
    type: str
    description: 细胞类型或亚群名称
    required: true
  count:
    type: int
    description: 该样本中该细胞类型的细胞计数
    required: true
  proportion:
    type: float
    description: 该样本内该细胞类型的比例（0-1 小数，同样本之和为 1）
    required: true
  roe_value:
    type: float
    description: 组织或分组富集偏好比值 Ro/e（观测数/期望数）
    required: false
  p_adj:
    type: float
    description: 样本级组间比例差异检验校正后 P 值
    required: false
---
# 细胞亚群比例与 Ro/e 偏好统计表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| sample_id | str | 必需 | 样本编号；用于样本级独立统计与检验 |
| group | str | 必需 | 实验分组或组织来源（如 Control、Model） |
| cell_type | str | 必需 | 细胞类型或亚群名称 |
| count | int | 必需 | 该样本中该细胞类型的细胞计数 |
| proportion | float | 必需 | 该样本内该细胞类型的比例（0-1 小数，同样本之和为 1） |
| roe_value | float | 可选 | 组织或分组富集偏好比值 Ro/e（观测数/期望数） |
| p_adj | float | 可选 | 样本级组间比例差异检验校正后 P 值 |

- 产出方法：[[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]] · [[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]
- 读取方法：无
- 使用的模板：无
<!-- facts:end -->

## 含义

一行代表某个 `sample_id`（所属 `group`）内某一 `cell_type` 的汇总统计记录，而不是单个细胞。`proportion` 使用 0–1 之间的小数而非百分比，同一 `sample_id` 下所有 `cell_type` 的 `proportion` 之和应为 1（缺失组合需显式补 0）；`roe_value`（Observed/Expected ratio）用于评估细胞亚群在特定分组/组织中的富集偏好（通常 `Ro/e > 1` 表示富集）；`p_adj` 必须基于样本级（而非把每个细胞当独立观测的卡方检验）统计检验由上游给出，下游绘图模板不重算。与 `render-cell-proportions` 的区别：本表保留 `sample_id`、`count`、`roe_value` 与 `p_adj`，既可用于流带图/同心环图，也可支持箱线图误差棒与 Ro/e 热图。

<!-- user:start -->
<!-- user:end -->
