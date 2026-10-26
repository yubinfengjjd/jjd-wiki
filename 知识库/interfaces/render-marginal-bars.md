---
type: interface
slug: render-marginal-bars
title: 预计算边缘分布条表
columns:
  orientation:
    type: str
    description: top或right，分别对应横轴或纵轴边缘
  position:
    type: float
    description: 条形中心坐标，单位与对应轴一致
  height:
    type: float
    description: 预先计算的非负条高，计数/密度含义由上游声明
  width:
    type: float
    description: 预先计算的正条宽，单位与对应轴一致
---
# 预计算边缘分布条表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| orientation | str | 必需 | top或right，分别对应横轴或纵轴边缘 |
| position | float | 必需 | 条形中心坐标，单位与对应轴一致 |
| height | float | 必需 | 预先计算的非负条高，计数/密度含义由上游声明 |
| width | float | 必需 | 预先计算的正条宽，单位与对应轴一致 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/2026-10-19-regression-stability__fig03-density-panel--density-scatter|密度散点与边缘分布]]
- 经模板关联的方法（经读取该接口的模板；不是 direct，按方法页准备数据）：[[methods/regression-resampling-evaluation|回归模型的重采样评估与折外预测]]（adaptable）
<!-- facts:end -->

## 含义

这里一行是一个已经分好箱的边缘分布条，只属于某一 panel 的一条边缘轴（top 走横轴、right 走纵轴），行数是条数而不是样本量。条高是上游给定的非负计数或密度（示例最大约 37，不是 0–1 比例或 0–100 百分数），条宽以对应轴的数据单位给出（示例约 0.45–0.5，不是比例）；模板不重算统计，按原值绘制，不归一化、不另算直方图或 KDE，缺失值没有编码，所有数值必须有限，零高条表示 0 而不是缺失。准备数据时最容易出错的是拿估读散点或 RGB 反推频数、或指望模板按新数据重新分箱——分箱方式、计数/密度定义、重复/折的计数单位都是上游给定，边缘条必须与同图散点同量纲、同批观测，且 top 与 right 两种边缘都要提供，缺一种模板直接报错。与 render-grouped-values 的区别是后者保存未汇总的原始逐点值、由小提琴模板自行计算分布，手上只有原始值时应选它；render-scatter-rgb 只提供配对 x/y 与预设 RGB，与本接口是同一 panel 的配套关系。

<!-- user:start -->
<!-- user:end -->
