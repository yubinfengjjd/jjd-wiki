---
type: interface
slug: render-scatter-rgb
title: 配对数值散点的预设颜色表
columns:
  x:
    type: float
    description: 横轴数值；量纲由课题说明
  y:
    type: float
    description: 配对纵轴数值；1:1线仅在同量纲时使用
  red:
    type: int
    description: 预先给定的红通道0..255
  green:
    type: int
    description: 预先给定的绿通道0..255
  blue:
    type: int
    description: 预先给定的蓝通道0..255
---
# 配对数值散点的预设颜色表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| x | float | 必需 | 横轴数值；量纲由课题说明 |
| y | float | 必需 | 配对纵轴数值；1:1线仅在同量纲时使用 |
| red | int | 必需 | 预先给定的红通道0..255 |
| green | int | 必需 | 预先给定的绿通道0..255 |
| blue | int | 必需 | 预先给定的蓝通道0..255 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/2026-10-19-regression-stability__fig03-density-panel--density-scatter|密度散点与边缘分布]]
- 经模板关联的方法（经读取该接口的模板；不是 direct，按方法页准备数据）：[[methods/regression-resampling-evaluation|回归模型的重采样评估与折外预测]]（adaptable）
<!-- facts:end -->

## 含义

一行是图上的一个散点标记：一对配对的 x/y 数值（例如同一验证样本的真实值与预测值）加该点预先指定的 RGB；表本身不带样本、模型或折的身份，同一受试者在多折、多重复或多模型比较中会重复成多行，行数不能当作独立样本量。x、y 沿用课题原始量纲，1:1 线只在两轴同定义同量纲时成立；RGB 是 0–255 整数，渲染时除以 255 得到颜色，不是 0–1，也不是由坐标算出的密度，缺失值没有专门编码，坐标或 RGB 非有限、超界会被绘图函数直接拒绝，须在上游剔除。最容易出错的是以为模板会重算统计：它不拟合、不算 KDE/直方图、不从 RGB 反推频数，RGB、边缘条以及拟合线/注释都是上游给定、模板不重算，边缘条须另由 render-marginal-bars 表提供（示例右边缘沿用旧 0..40 而原图为 0..20，二者本就不保证同源）；色标也须显式给出范围和标签才显示，默认不显示、不假定颜色代表频数。示例的点、RGB 和边缘条均为旧图估读，不能当作原始观测、真实样本量或模型有效性证据。与 [[interfaces/render-marginal-bars]] 的区别是后者一行是一根预计算边缘条、与本页散点表分开给出且互不派生；与 [[interfaces/regression-predictions]] 的区别是后者保留 sample_id、model、repeat、fold 等验证身份，需要保留身份和折结构时用 regression-predictions，进绘图前再整理成本页；x 是类别而非连续数值时改用 [[interfaces/render-category-points]]。

<!-- user:start -->
<!-- user:end -->
