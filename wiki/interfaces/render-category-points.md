---
type: interface
slug: render-category-points
title: 分组数值与显式抖动表
columns:
  category:
    type: str
    description: 类别标识；与摘要表一一对应
  value:
    type: float
    description: 逐条结果值；采样单位/量纲由课题说明
  jitter:
    type: float
    description: 显式横向展示偏移，绝对值须小于0.5；不参与统计
---
# 分组数值与显式抖动表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| category | str | 必需 | 类别标识；与摘要表一一对应 |
| value | float | 必需 | 逐条结果值；采样单位/量纲由课题说明 |
| jitter | float | 必需 | 显式横向展示偏移，绝对值须小于0.5；不参与统计 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]]
- 经模板关联的方法（经读取该接口的模板；不是 direct，按方法页准备数据）：[[methods/regression-resampling-evaluation|回归模型的重采样评估与折外预测]]（adaptable）
<!-- facts:end -->

## 含义

一行代表某个 category 下实际画出的一个观测值（例如回归评估中某一折的指标），同类可有多行，行数就是图上点数，不应直接当作独立受试者数或原始样本量，接口声明的列也不保留配对、重复或折身份。value 的量纲、0–1 还是 0–100、是否已取 log 须由课题说明并在数值中直接体现，模板不做单位换算、反变换或归一化；jitter 是上游给定的显式横向展示偏移，绝对值须小于 0.5，不参与统计且模板不生成；本模板不接受缺失值，value、jitter 与摘要数值都须有限，空值/NaN 行要在上游剔除或按已记录规则处理。最容易出错的是点与摘要不同源：箱体、须和均值全部由 render-box-summaries 上游给定、模板不重算分位数/均值/须，也不另画 fliers；若摘要不是由同一批点按同一规则得到，或点在上游被再次筛选，箱体就会与散点矛盾；摘要每类恰一行、类别集合必须与点完全一致，多个指标也应各自成文件、不要直接拼接后共用模型名作为 category，否则会与摘要唯一行冲突。与只含预计算箱线摘要的 render-box-summaries 不同，本接口提供逐点值，是本模板的必需输入而非可替代项（只有摘要时无法运行）；render-grouped-values 是 celltype+group 两级分组、没有 jitter 列（小提琴模板内部生成抖动），配合同组摘要 render-group-summaries（mean/sd/p 标签）用于小提琴图，而本接口只按 category 一个维度分组、抖动由上游显式给出，用于箱线加散点的单指标分布。模板示例的点值、箱体和均值是独立估读，抖动为合成展示位置，不能当作真实观测、样本量或统计推断依据。

<!-- user:start -->
<!-- user:end -->
