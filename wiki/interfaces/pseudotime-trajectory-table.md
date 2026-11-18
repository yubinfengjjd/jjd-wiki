---
type: interface
slug: pseudotime-trajectory-table
title: 拟时序细胞坐标与分支动态基因表
columns:
  cell_id:
    type: str
    description: 细胞标识或代表节点 ID
    required: true
  pseudotime:
    type: float
    description: 标准化拟时序值（起点为 0）
    required: true
  branch_state:
    type: str
    description: 细胞所处轨迹状态或分支编号
    required: true
  gene:
    type: str
    description: 沿拟时序动态变化的基因名（细胞元数据模式下可留空）
    required: false
  cluster:
    type: str
    description: 动态表达模式聚类编号
    required: false
  qval:
    type: float
    description: 拟时序动态表达或 BEAM 分支检验 q 值
    required: false
  peak_time:
    type: float
    description: 基因表达峰值对应的拟时序位置
    required: false
---
# 拟时序细胞坐标与分支动态基因表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell_id | str | 必需 | 细胞标识或代表节点 ID |
| pseudotime | float | 必需 | 标准化拟时序值（起点为 0） |
| branch_state | str | 必需 | 细胞所处轨迹状态或分支编号 |
| gene | str | 可选 | 沿拟时序动态变化的基因名（细胞元数据模式下可留空） |
| cluster | str | 可选 | 动态表达模式聚类编号 |
| qval | float | 可选 | 拟时序动态表达或 BEAM 分支检验 q 值 |
| peak_time | float | 可选 | 基因表达峰值对应的拟时序位置 |

- 产出方法：[[methods/dynamic-feature-analysis|拟时序动态特征分析]] · [[methods/rna-velocity|RNA 速度分析]] · [[methods/trajectory-inference|拟时序与轨迹推断]]
- 读取方法：[[methods/dynamic-feature-analysis|拟时序动态特征分析]]
- 使用的模板：无
<!-- facts:end -->

## 含义

用于衔接单细胞轨迹推断（Monocle2/3、Slingshot）与动态特征热图/曲线绘图。在细胞坐标模式下，一行对应一个细胞的 `cell_id`、`pseudotime` 与 `branch_state`；在动态基因长表模式下，记录显著随拟时序变化的 `gene`、动态模式 `cluster`、`qval` 及 `peak_time`。使用前提是起点（root state / root cell）必须结合先验生物学知识或 RNA 速率（RNA velocity）显式指定，拟时序值只代表转录状态相对排序，不等同于真实物理时间。常见错误是在跨供体批次未去除时直接拟合轨迹，导致“伪分支”实际反映供体差异。下游可接动态分裂热图、平滑曲线图及驱动基因筛选。

<!-- user:start -->
<!-- user:end -->
