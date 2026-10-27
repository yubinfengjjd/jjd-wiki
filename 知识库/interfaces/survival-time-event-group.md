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
- 使用的模板：无
<!-- facts:end -->

## 含义

<!-- user:start -->
<!-- user:end -->
