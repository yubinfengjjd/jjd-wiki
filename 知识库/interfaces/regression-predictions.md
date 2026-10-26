---
type: interface
slug: regression-predictions
title: 回归模型逐样本验证预测表
columns:
  sample_id:
    type: str
    description: 课题内唯一的样本标识；重复测量仍需另有受试者分组
  model:
    type: str
    description: 模型或完整训练流程名称
  repeat:
    type: int
    description: 重采样重复编号，从1起；普通K折为1
  fold:
    type: int
    description: 本次重复内的验证折或划分编号，从1起
  y_true:
    type: float
    description: 该验证样本的真实连续结局
  y_pred:
    type: float
    description: 未使用该验证样本训练或调参的流程给出的预测
  split_design:
    type: str
    description: kfold/repeated_kfold/group_kfold/time_series/repeated_holdout
---
# 回归模型逐样本验证预测表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| sample_id | str | 必需 | 课题内唯一的样本标识；重复测量仍需另有受试者分组 |
| model | str | 必需 | 模型或完整训练流程名称 |
| repeat | int | 必需 | 重采样重复编号，从1起；普通K折为1 |
| fold | int | 必需 | 本次重复内的验证折或划分编号，从1起 |
| y_true | float | 必需 | 该验证样本的真实连续结局 |
| y_pred | float | 必需 | 未使用该验证样本训练或调参的流程给出的预测 |
| split_design | str | 必需 | kfold/repeated_kfold/group_kfold/time_series/repeated_holdout |

- 产出方法：无
- 读取方法：[[methods/regression-resampling-evaluation|回归模型的重采样评估与折外预测]]
- 使用的模板：无
<!-- facts:end -->

## 含义

一行是一个 `sample_id` 在某个模型、某次重复、某个验证折上的折外预测，行本身不是独立受试者；K 折每次重复中每个样本至多验证一次，重复留出则允许同一受试者跨划分重复出现，不同折/重复因共享训练样本而彼此相关，重复测量还须在课题侧另设受试者分组。`y_true` 与 `y_pred` 按课题声明的原始结局量纲保留（不做统一的 0–1 归一化），文件名固定为 `regression-predictions.csv`；必需列不允许缺失或非有限值，`repeat`/`fold` 从 1 起，全表只能有一种 `split_design`。准备时最容易出错的是把行数当样本量、各模型没有复用完全相同的验证样本、用全数据拟合的回代预测冒充折外预测；脚本只能检查表内重复、跨模型配对、结局一致性和可选的全覆盖，训练/调参泄漏必须另行审计。与 `regression-fold-metrics` 的区别是本表保留逐样本预测、后者只存逐折汇总指标（逐折指标的算术均值通常不等于混合全部预测后重算的值）：需要逐样本配对散点（先整理成绘图接口）或自行复算指标时用 `regression-predictions`，只需现成逐折指标时用 `regression-fold-metrics`。若要出密度散点，模板并不直接读取本表，而是读取由本表整理的 `render-scatter-rgb`/`render-marginal-bars` 准备表；坐标、RGB 与边缘条均为上游给定、模板不重算。

<!-- user:start -->
<!-- user:end -->
