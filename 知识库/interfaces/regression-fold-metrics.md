---
type: interface
slug: regression-fold-metrics
title: 回归模型逐折评估指标表
columns:
  model:
    type: str
    description: 完整模型流程名称
  repeat:
    type: int
    description: 重复编号
  fold:
    type: int
    description: 验证折或随机划分编号
  n_test:
    type: int
    description: 本折验证样本数，不是独立重复次数
  RMSE:
    type: float
    description: 本折均方根误差，原目标单位
  MAE:
    type: float
    description: 本折平均绝对误差，原目标单位
  R2:
    type: float
    description: 1-SSE/SST；常量真实结局或不足2例时缺失
  r:
    type: float
    description: Pearson相关；任一变量常量或不足2例时缺失
  split_design:
    type: str
    description: 原样保留上游验证设计
---
# 回归模型逐折评估指标表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| model | str | 必需 | 完整模型流程名称 |
| repeat | int | 必需 | 重复编号 |
| fold | int | 必需 | 验证折或随机划分编号 |
| n_test | int | 必需 | 本折验证样本数，不是独立重复次数 |
| RMSE | float | 必需 | 本折均方根误差，原目标单位 |
| MAE | float | 必需 | 本折平均绝对误差，原目标单位 |
| R2 | float | 必需 | 1-SSE/SST；常量真实结局或不足2例时缺失 |
| r | float | 必需 | Pearson相关；任一变量常量或不足2例时缺失 |
| split_design | str | 必需 | 原样保留上游验证设计 |

- 产出方法：[[methods/regression-resampling-evaluation|回归模型的重采样评估与折外预测]]
- 读取方法：无
- 使用的模板：无
<!-- facts:end -->

## 含义

一行代表某模型在一次重复的一个验证折/留出划分上的汇总指标。行单位是“模型 × 重复 × 折”，不是受试者；`n_test` 是该折验证样本数，不是独立重复次数。`RMSE`/`MAE` 保留原目标单位，`R2`/`r` 无量纲，`repeat`/`fold` 从 1 起，全表只能有一种 `split_design`。各折共享训练样本，逐折分数通常相关，不能当独立实验；逐折指标的算术均值通常不等于把全部折外预测混在一起后重算的值。`R2` 在真实结局为常量或验证集不足 2 例时缺失，`r` 在任一变量为常量或不足 2 例时缺失，不要填 0。准备时最容易出错的是把 `n_test` 当样本量、把不同 `split_design` 混进同一文件、或把回代预测的指标冒充折外指标。与 `regression-predictions` 的区别是本表只存逐折汇总，后者保留逐样本折外预测；需要逐样本配对散点或自行复算指标时用 `regression-predictions`，只需现成逐折指标时用本表。文件名固定为 `regression-fold-metrics.csv`。

<!-- user:start -->
<!-- user:end -->
