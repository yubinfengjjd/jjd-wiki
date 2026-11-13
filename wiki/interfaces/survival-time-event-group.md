---
type: interface
slug: survival-time-event-group
title: 个体随访生存表
columns:
  time:
    type: float
    description: 随访时间（单位由作者给定，如月），≥0
  event:
    type: int
    description: 结局事件：1 = 发生（死亡/复发），0 = 删失
  group:
    type: str
    description: 分组标签；因子顺序由 style.levels 显式给出，否则按出现顺序
---
# 个体随访生存表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| time | float | 必需 | 随访时间（单位由作者给定，如月），≥0 |
| event | int | 必需 | 结局事件：1 = 发生（死亡/复发），0 = 删失 |
| group | str | 必需 | 分组标签；因子顺序由 style.levels 显式给出，否则按出现顺序 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/figureya-1survivalcurve-update--km-curve|KM 生存曲线与风险表]]
<!-- facts:end -->

## 含义

一行是一个个体（患者/样本），不是一个时间点。`time` 为随访时长，单位由课题给定（月/天），图的横轴标签在 style.xlab 写明；`event` 只接受 0（删失）/1（事件），survival 包的 1/2 旧编码要先改。`group` 是已定义好的分组（如表达高低、分型），切点或分型方法不在本表里决定。与 subgroup-effect-table 的区别：这里是个体原始随访，后者是已算好的效应量汇总。

<!-- user:start -->
<!-- user:end -->
