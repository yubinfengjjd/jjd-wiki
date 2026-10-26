---
type: interface
slug: shap-samples
title: SHAP 逐样本值表
columns:
  feature:
    type: str
    description: 特征名
  shap:
    type: float
    description: 该样本该特征的带符号 SHAP 值
  feature_value:
    type: float
    description: 该特征取值在解释样本内按最小–最大缩放到 0–1，用于着色；常量特征取 0
---
# SHAP 逐样本值表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| feature | str | 必需 | 特征名 |
| shap | float | 必需 | 该样本该特征的带符号 SHAP 值 |
| feature_value | float | 必需 | 该特征取值在解释样本内按最小–最大缩放到 0–1，用于着色；常量特征取 0 |

- 产出方法：[[methods/shap-explanation|基于 SHAP 的模型解释]]
- 读取方法：无
- 使用的模板：[[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm|SHAP 蜂群图]]
<!-- facts:end -->

## 含义

一行代表一个“解释样本 × 特征”的带符号 SHAP 值；同一特征会按样本重复多行，是长表，行数为解释样本数 × 表中特征数，不是受试者数（上游若保留同一受试者的多行或重复测量，也按行计）。shap 的量纲由实际解释分支决定（TreeExplainer、LinearExplainer、Explainer 各有条件，分类时不能一律当作概率贡献），不同模型或不同输出分支的表不能拼接，图注需说明尺度。feature_value 是上游把该特征在解释样本内的取值按最小–最大值缩放到 0–1 的结果（不是 0–100，也不是原始值），常量特征一律记 0、不能读作真实低值；这个 0–1 只在同一批解释样本内可比，换样本或换表后不要直接合并比较。准备数据时最容易出错的是配对、重复计数和归一化：表中没有样本 ID，样本只能靠行位置隐式对应，接口也未规定按样本还是按特征分块，重排、抽行或合并后跨特征配对即失效；接口未定义缺失值编码，需在上游先定；本库唯一产出方法的脚本会先按 TOP_N/MIN_MEAN_ABS_SHAP 筛特征、只在测试集前 EXPLAIN_SAMPLES 个样本上解释，表不覆盖全部特征或全队列；SHAP 值和 0–1 缩放都是上游给定/模板不重算，模板只在 feature_order 为空时按平均绝对 SHAP 排序，并用当前表的 shap/feature_value 推 x 轴与色标范围，截取子集会改变配色与轴范围，必要时用 style.clim/xlim/feature_order 固定。与相近接口 `shap-summary`（[[interfaces/shap-summary]]）的关键区别是它每特征一行、只给平均绝对 SHAP 和 0–100 的 percent（供条形/环形图），本接口保留逐样本的方向与分布：看分布、方向和特征值高低用 `shap-samples`（蜂群图），看跨特征排名与占比用 `shap-summary`；两者出自同一次解释和同一批入选特征，不是独立证据。

<!-- user:start -->
<!-- user:end -->
