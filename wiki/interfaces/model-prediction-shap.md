---
type: interface
slug: model-prediction-shap
title: 临床模型预测风险与 SHAP 贡献表
columns:
  sample_id:
    type: str
    description: 样本或患者唯一编号
    required: true
  cohort:
    type: str
    description: 所属队列（如 Train、InternalTest、GSE_External）
    required: true
  y_true:
    type: float
    description: 真实二分类标签（0/1）或连续临床结局
    required: true
  risk_score:
    type: float
    description: 模型预测风险得分或正类预测概率
    required: true
  time:
    type: float
    description: 随访生存时间（生存分析必填，单位需全队列统一）
    required: false
  event:
    type: int
    description: 生存结局事件（0=删失，1=终点事件发生）
    required: false
  shap_summary:
    type: str
    description: 关联 SHAP 汇总标识或个体高贡献特征摘要
    required: false
---
# 临床模型预测风险与 SHAP 贡献表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| sample_id | str | 必需 | 样本或患者唯一编号 |
| cohort | str | 必需 | 所属队列（如 Train、InternalTest、GSE_External） |
| y_true | float | 必需 | 真实二分类标签（0/1）或连续临床结局 |
| risk_score | float | 必需 | 模型预测风险得分或正类预测概率 |
| time | float | 可选 | 随访生存时间（生存分析必填，单位需全队列统一） |
| event | int | 可选 | 生存结局事件（0=删失，1=终点事件发生） |
| shap_summary | str | 可选 | 关联 SHAP 汇总标识或个体高贡献特征摘要 |

- 产出方法：无
- 读取方法：[[methods/shap-explanation|基于 SHAP 的模型解释]]
- 使用的模板：无
<!-- facts:end -->

## 含义

一行代表一个样本在某一临床预测模型与特定队列（`cohort`）中的模型预测输出与结局对照记录，用于衔接机器学习建模与临床评估可视化（ROC/Time-ROC、KM 生存曲线、校准曲线、DCA 决策曲线、列线图及 SHAP 解释图）。`cohort` 必须严格区分训练集与独立外部验证集；生存模型中 `time` 的单位（天/月/年）必须在所有验证队列间统一；`risk_score` 由训练冻结模型在各队列独立预测生成，严禁在外部验证集重新拟合模型系数或重新按最优截断值反复寻优。与 `shap-summary`/`shap-samples` 的区别：本表是样本级模型输出主表，可进一步关联逐样本 SHAP 贡献矩阵。

<!-- user:start -->
<!-- user:end -->
