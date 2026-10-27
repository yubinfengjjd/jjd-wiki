---
type: scenario
id: clinical-prediction-survival
title: 临床预测与生存分析
picks:
- id: recipes/figureya-1survivalcurve-update
  note: 两组/多组 KM 曲线 + 风险表，最常用起点
- id: recipes/figureya-284pairwiselogrank
  note: ≥3 组时加两两 log-rank 表
- id: recipes/figureya-6rhrsv2
  note: 已算好 HR 的临床亚组森林图
- id: recipes/figureya-193risktable
  note: 训练/验证集 riskscore 多因素森林表
- id: recipes/figureya-31lasso-update
  note: LASSO Cox 筛基因、建签名
- id: recipes/figureya-141risk
  note: 风险评分分布 + 生存状态 + 签名热图
- id: recipes/figureya-30nomogram-update
  note: 列线图与校准曲线
- id: recipes/figureya-85timeroc
  note: 时间依赖 ROC
- id: recipes/figureya-138nicecalibration
  note: Logistic 诊断模型校准（不用于预后模型）
- id: recipes/figureya-33dca-update
  note: 决策曲线 / 净获益
- id: recipes/figureya-99smoothhrv2
  note: RCS 非线性 HR 曲线
- id: recipes/figureya-102multipanelroc
  note: 多变量 Logistic 训练/测试 ROC
- id: recipes/figureya-293machinelearning
  note: 多算法组合预后模型 C 指数比较（重）
- id: figureya:FigureYa186swimmerplot
  note: 治疗时间线泳道图（L0，未在 Wiki 运行）
tags:
- survival-analysis
- diagnostic-roc
keywords:
- 生存曲线
- KM
- Cox
- 森林图
- 列线图
- nomogram
- 校准
- DCA
- ROC
- timeROC
- RCS
- 风险评分
- LASSO
- 预后模型
- 临床预测
summary: 队列随访或二分类结局：生存曲线、HR 森林图、预后模型构建与评价（区分度、校准、临床获益）。
---

# 临床预测与生存分析

## 什么时候用

- 有个体随访时间与事件，要比较组间生存或报告 HR。
- 构建并评价预后/诊断模型：变量筛选（LASSO）→ 列线图 → ROC/timeROC、校准、DCA。
- 连续暴露的非线性风险（RCS）。

## 首选组合

首选按常用顺序排列；`find` 命中本场景时这些条目排在前面。

<!-- facts:start -->
| 条目 | 级别 | 状态 | 说明 |
|---|---|---|---|
| [[recipes/figureya-1survivalcurve-update|多组 KM 生存曲线与风险表]] | L1 | ready · 运行 pass | 两组/多组 KM 曲线 + 风险表，最常用起点 |
| [[recipes/figureya-284pairwiselogrank|三组以上 KM 曲线与两两比较表]] | L1 | ready · 运行 pass | ≥3 组时加两两 log-rank 表 |
| [[recipes/figureya-6rhrsv2|临床亚组分析森林图]] | L1 | ready · 运行 pass | 已算好 HR 的临床亚组森林图 |
| [[recipes/figureya-193risktable|训练与验证集风险评分多因素森林表]] | L1 | ready · 运行 pass | 训练/验证集 riskscore 多因素森林表 |
| [[recipes/figureya-31lasso-update|LASSO Cox 系数路径与交叉验证图]] | L1 | ready · 运行 pass | LASSO Cox 筛基因、建签名 |
| [[recipes/figureya-141risk|风险评分分布与签名基因热图联图]] | L1 | ready · 运行 pass | 风险评分分布 + 生存状态 + 签名热图 |
| [[recipes/figureya-30nomogram-update|Cox/Logistic 列线图与校准曲线]] | L1 | ready · 运行 pass | 列线图与校准曲线 |
| [[recipes/figureya-85timeroc|多模型时间依赖 ROC 曲线]] | L1 | ready · 运行 pass | 时间依赖 ROC |
| [[recipes/figureya-138nicecalibration|Logistic 模型校准曲线与 HL 检验]] | L1 | ready · 运行 pass | Logistic 诊断模型校准（不用于预后模型） |
| [[recipes/figureya-33dca-update|决策曲线与净获益分析]] | L1 | ready · 运行 pass | 决策曲线 / 净获益 |
| [[recipes/figureya-99smoothhrv2|限制性立方样条 HR 曲线]] | L1 | ready · 运行 pass | RCS 非线性 HR 曲线 |
| [[recipes/figureya-102multipanelroc|多变量 Logistic 模型训练/测试 ROC]] | L1 | ready · 运行 pass | 多变量 Logistic 训练/测试 ROC |
| [[recipes/figureya-293machinelearning|多算法组合预后模型 C 指数比较]] | L1 | draft · 运行 fail | 多算法组合预后模型 C 指数比较（重） |
| `figureya:FigureYa186swimmerplot` | L0 | catalog | 治疗时间线泳道图（L0，未在 Wiki 运行） |
<!-- facts:end -->

## 注意

- HR、OR、C 指数等统计量由上游代码计算；换数据前确认结局编码（0/1）、时间单位和参考组。
- Logistic 校准不能当预后模型校准；生存模型用 30nomogram 的 bootstrap 校准或另行确认。
- 最佳截断、多模型挑最优都有过拟合风险，正式结论需外部验证。

## 作者备注

<!-- user:start -->
<!-- user:end -->
