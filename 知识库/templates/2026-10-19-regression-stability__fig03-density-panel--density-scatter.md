---
type: template
id: 2026-10-19-regression-stability__fig03-density-panel--density-scatter
title: 密度散点与边缘分布
status: ready
layouts:
- 2026-10-19-regression-stability__fig03-density-panel
panels:
- A
language: python
tags:
- 机器学习
- 实验统计
chart_types:
- density-scatter
favorite: false
keywords:
- regression
- cross-validation
- 回归评估
- 模型比较
- 折外预测
---
# 密度散点与边缘分布

![[templates/2026-10-19-regression-stability__fig03-density-panel--density-scatter/preview.png]]

<!-- facts:start -->
- 来源：[[layouts/2026-10-19-regression-stability__fig03-density-panel|六模型验证预测：密度散点与边缘分布]]
- 面板（来源版式）：A
- 语言：python
- 标签：机器学习、实验统计
- 图型：[[chart-types/density-scatter]]
- 输入接口：[[interfaces/render-scatter-rgb|配对数值散点的预设颜色表]] · [[interfaces/render-marginal-bars|预计算边缘分布条表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/regression-resampling-evaluation|回归模型的重采样评估与折外预测]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：本轮只验证模板绘图与合成规模；未验证真实方法→准备表→出图流水线。
    - 依据：可用本绘图模板表达真实预测的配对分布，但需上游明确准备RGB/边缘表。；前提：连续结局且同一原始量纲；明确样本、模型、重复/折身份。；需先确定密度/边缘分布策略与注释统计，不用估读颜色倒推真实频数。；适配：课题内准备坐标/RGB/边缘条及真实注释；不从估读点重建频数，密度算法仍需确认。
    - 关系证据：methods/regression-resampling-evaluation.md#输入；layouts/2026-10-19-regression-stability__fig03-density-panel.md#适用；templates/2026-10-19-regression-stability__fig03-density-panel--density-scatter/spec.json；templates/2026-10-19-regression-stability__fig03-density-panel--density-scatter/verify/function-verification.json；运行证据：无
<!-- facts:end -->

## 适用

配对坐标的散点与两侧预计算边缘分布，色标可显式启用。一个逻辑 panel，可有主轴、两边缘轴与色标轴。

输入已有坐标、RGB和边缘条；不拟合、不算KDE/直方图、不从RGB倒推频数。1:1线要求两轴同定义同量纲。需要色标时显式传 show_colorbar=True、color_range、color_label，确保上游颜色策略一致；默认不假定颜色是频数。

## 不适用

不将估读示例作为原始观测、真实样本量或模型有效性证据。缺关键数据、统计含义或上游算法时先说明并询问，不能以整理绘图接口为由补算法。

## 数据要求

### points（render-scatter-rgb.csv）：配对坐标与预设RGB；不从颜色反推密度 [[interfaces/render-scatter-rgb|配对数值散点的预设颜色表]]

| 列 | 类型 | 含义 |
|---|---|---|
| x | float | 横轴数值；量纲由课题说明 |
| y | float | 配对纵轴数值；1:1线仅在同量纲时使用 |
| red | int | 预先给定的红通道0..255 |
| green | int | 预先给定的绿通道0..255 |
| blue | int | 预先给定的蓝通道0..255 |

### histograms（render-marginal-bars.csv）：由上游提供的边缘条；不从估读散点重算 [[interfaces/render-marginal-bars|预计算边缘分布条表]]

| 列 | 类型 | 含义 |
|---|---|---|
| orientation | str | top或right，分别对应横轴或纵轴边缘 |
| position | float | 条形中心坐标，单位与对应轴一致 |
| height | float | 预先计算的非负条高，计数/密度含义由上游声明 |
| width | float | 预先计算的正条宽，单位与对应轴一致 |

### 可覆盖的 style

- `font_family`：`"Arial"`
- `dpi`：`300`
- `sizing`：`{"mode": "adaptive", "profile": "fixed", "table": null, "x": null, "y": null, "item_width_in": 0.8, "item_height_in": 0.32, "plot_width_in": 5.4, "plot_height_in": 4.4, "margins_in": [0, 0, 0.12, 0.12], "min_width_in": 3.2, "min_height_in": 2.8, "max_width_in": null, "max_height_in": null, "width_in": 7, "height_in": 6.221476510067114, "label_fontsize": 11, "label_rotation": 45, "label_gap_in": 0.12}`
- `columns`：`{}`
- `limits`：`null`
- `canvas_px`：`[1043, 927]`
- `boxes`：`{"main": [108, 170, 853, 846], "top": [108, 14, 853, 156], "right": [868, 170, 1026, 846], "colorbar": [707, 515, 743, 799]}`
- `identity`：`true`
- `fit`：`null`
- `annotation`：`null`
- `label`：`null`
- `xlabel`：`"Observed"`
- `ylabel`：`"Predicted"`
- `xticks`：`null`
- `yticks`：`null`
- `show_colorbar`：`false`
- `color_range`：`null`
- `color_label`：`null`
- `cmap`：`"RdYlGn_r"`
- `color_ticks`：`null`
- `color_ticklabels`：`null`
- `top_limits`：`null`
- `right_limits`：`null`
- `top_ticks`：`null`
- `right_ticks`：`null`
- `count_label`：`"Supplied marginal"`
- `hist_color`：`"#b2d3d5"`
- `background`：`"#f4f7f9"`
- `point_size`：`12`
- `fit_color`：`"#008798"`

## 代码与独立调用

`source/panels.py` 原字节保留旧重建代码；不是原作者缺失函数。`code/core.py` 为绘图改造版，`code/panel.py` 保留 draw(fig,rect,tables,style) 并提供 plot_panel(tables,style=None)，两者共享同一核心。代码卡片区分原版/复用版和实际验证范围。

将整个 code/ 复制为课题包 `density_panel/`，使用课题自己的 numpy/pandas/matplotlib 环境；不要在 Wiki 安装包。函数无隐式读写、训练、联网、安装或随机生成。返回 figure、handles、sizing_plan；导出由调用层完成。示例文件对应：points=render-scatter-rgb.csv；histograms=render-marginal-bars.csv。

```python
from density_panel.panel import plot_panel
# tables为已准备的DataFrame字典；列映射、顺序、颜色和尺寸在style中显式传入。
fig, handles, plan = plot_panel(tables, style)
fig.savefig('result.png', dpi=300)
```

## 尺寸与换数据

散点不随点数无限增长。默认7×6.2215英寸，预留上下刻度边距；很长的轴标题等可能需显式增加尺寸/边距，固定比例越界会报错。图形回放 example/style.json 使用原比例、原刻度与原标注。

组合调用不会调整外层figure；空间不足明确报错，交调用方扩大。独立函数与render默认值快照一致，复制后无需Wiki/spec路径。`example/style.json` 专用于来源回放，不随意套到新数据。

## 回放、来源与限制

示例点/RGB/边缘条均为旧估读；拟合线、指标、Test(XGBoost)只在 example/style.json 中，未由点重新计算。右边缘保留旧0..40，原单图为0..20，沿用前次已说明的差异。默认复用不带这些旧标注。

verify-template 已回放PNG/PDF/SVG，15项绘图/可移植性检查通过：来源维度及数值图元与旧renderer在绝对容差1e-12内一致；任意n的代表规模/长标签/列映射/顺序/配色/上限/不同cwd调用已检查。仅为绘图软件验证，未验证真实课题统计有效性。详情见 verify/function-verification.json。PNG已目视，PDF/SVG为结构检查，独立查看器视觉未测。

2026-10-21 作者明确确认本轮回放，已通过mark-ready标为可用。来源签核继续保留；可独立render，不以来源layout整体ready为前置。

## 知识关联检查

检查现存回归评估/SHAP家族、两个来源及既有SHAP三模板。与 [[methods/regression-resampling-evaluation]] 有条件关联，但该方法的预测/逐折指标需另外整理成预计算绘图表；适配不是新增训练/密度/统计算法授权。关系在方法侧唯一记录，验证范围与模板状态分开。

SHAP图表达特征归因，输入语义不同，未找到当前模板直接读取其表的依据；不为连通图谱硬连。参考来源 [[layouts/2026-10-19-regression-stability__fig03-density-panel]] 与本模板是单panel来源/复用阶段，未收录整图、未创建宽泛迁移方法。

## 使用记录

2026-10-21：按“处理待办”完成所选单panel模板化、原字节存档、回放与复用检查，待作者确认。

<!-- user:start -->
<!-- user:end -->
