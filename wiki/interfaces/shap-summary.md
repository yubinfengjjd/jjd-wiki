---
type: interface
slug: shap-summary
title: SHAP 特征贡献汇总表
columns:
  feature:
    type: str
    description: 特征名
  shap:
    type: float
    description: 该特征在解释样本上的平均绝对 SHAP 值
  percent:
    type: float
    description: 平均绝对 SHAP 占筛选前全部特征的平均绝对 SHAP 之和的百分比，0–100
---
# SHAP 特征贡献汇总表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| feature | str | 必需 | 特征名 |
| shap | float | 必需 | 该特征在解释样本上的平均绝对 SHAP 值 |
| percent | float | 必需 | 平均绝对 SHAP 占筛选前全部特征的平均绝对 SHAP 之和的百分比，0–100 |

- 产出方法：[[methods/shap-explanation|基于 SHAP 的模型解释]]
- 读取方法：无
- 使用的模板：[[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar|SHAP 条形图（含环形 inset）]] · [[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--radial-bar|SHAP 环形贡献图]]
<!-- facts:end -->

## 含义

一行代表一个特征在整个解释样本上的汇总，而不是一个样本或一个样本×特征单元；shap 是该特征的平均绝对 SHAP 值，单个样本的贡献方向与样本间分布不在本表。percent 是 0–100 的占比而非 0–1 比例，分母为筛选前全部特征的平均绝对 SHAP 之和，所以 shap 与 percent 必须来自同一模型输出、同一解释样本和同一套特征定义；shap 的数值尺度随模型输出/解释分支而变，不能把不同输出单位或不同模型的结果拼进同一张表。读取本接口的条形图与环形图模板按固定文件名 `shap-summary.csv` 直接读取、只按给定数值绘图，shap 与 percent 均为上游给定、模板不重算这两列（percent 仅作文字标注，不参与条长或角度计算），也不校验两者是否自洽；用 TOP_N/MIN_MEAN_ABS_SHAP 筛选后 percent 不重新归一化，合计小于 100 属正常，若按剩余行重算百分比就改变了定义；随模板附带的示例 CSV 是不确定转录，只能作画法参考。与相近接口 `shap-samples`（[[interfaces/shap-samples|SHAP 逐样本值表]]）不同，后者每行是样本×特征的带符号值，并用缩放到 0–1 的 feature_value 着色，适合蜂群图看方向和样本间异质性；本表没有方向，只承载全局贡献排序与占比。因此做全局重要性条形图或环形图时用本表，要看方向、个体差异或画蜂群图时用 `shap-samples`；同源的条形图与环形图只是同一张表的两种画法，不能当作两份独立证据。接口未定义 NA；两个模板没有 NA 检查，正式导出前应在上游清理。

<!-- user:start -->
<!-- user:end -->
