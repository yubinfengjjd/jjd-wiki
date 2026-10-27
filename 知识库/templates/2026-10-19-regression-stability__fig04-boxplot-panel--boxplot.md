---
type: template
id: 2026-10-19-regression-stability__fig04-boxplot-panel--boxplot
title: 箱线、散点与均值
status: ready
layouts:
- 2026-10-19-regression-stability__fig04-boxplot-panel
panels:
- A
language: python
tags:
- 机器学习
- 实验统计
chart_types:
- boxplot
favorite: false
keywords:
- regression
- cross-validation
- 回归评估
- 模型比较
- 折外预测
---
# 箱线、散点与均值

![[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot/preview.png]]

<!-- facts:start -->
- 来源：[[layouts/2026-10-19-regression-stability__fig04-boxplot-panel|多模型逐折指标：箱线、散点与均值]]
- 面板（来源版式）：A
- 语言：python
- 标签：机器学习、实验统计
- 图型：[[chart-types/boxplot]]
- 输入接口：[[interfaces/render-category-points|分组数值与显式抖动表]] · [[interfaces/render-box-summaries|预计算分组箱线与均值表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/regression-resampling-evaluation|回归模型的重采样评估与折外预测]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：本轮只验证模板绘图与合成规模；未验证真实方法→准备表→出图流水线。
    - 依据：逐折指标可用于该单指标分组分布，需上游按已确认规则准备同源点与箱线摘要。；前提：同一验证方案、指标定义与单位；明确折间相关性。；按已确认的箱体/须/均值规则产生一致结果，横向抖动仅作展示。；适配：课题内选定指标、明确采样单位/须规则、整理同源points/summaries；不自动新写统计算法。
    - 关系证据：methods/regression-resampling-evaluation.md#输出；layouts/2026-10-19-regression-stability__fig04-boxplot-panel.md#适用；templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot/spec.json；templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot/verify/function-verification.json；运行证据：无
<!-- facts:end -->

## 适用

单指标分组分布：外部提供的点、箱体、须和均值。组数从真实输入识别，模型名称/组数/标签不是函数限制。

点与摘要须来自同一真实分析；图不计算分位数/均值/须或生成抖动。jitter显式提供且绝对值小于0.5；逐类摘要须满足 low≤q1≤median≤q3≤high。点可在须外，图不另重复画fliers。

## 不适用

不将估读示例作为原始观测、真实样本量或模型有效性证据。缺关键数据、统计含义或上游算法时先说明并询问，不能以整理绘图接口为由补算法。

## 数据要求

### points（render-category-points.csv）：每条数值和显式抖动，不在绘图内生成 [[interfaces/render-category-points|分组数值与显式抖动表]]

| 列 | 类型 | 含义 |
|---|---|---|
| category | str | 类别标识；与摘要表一一对应 |
| value | float | 逐条结果值；采样单位/量纲由课题说明 |
| jitter | float | 显式横向展示偏移，绝对值须小于0.5；不参与统计 |

### summaries（render-box-summaries.csv）：独立提供的预计算摘要；真实数据必须与点同源 [[interfaces/render-box-summaries|预计算分组箱线与均值表]]

| 列 | 类型 | 含义 |
|---|---|---|
| category | str | 每类恰好一行；不能缺组 |
| q1 | float | 上游给定第一四分位数 |
| median | float | 上游给定中位数 |
| q3 | float | 上游给定第三四分位数 |
| low | float | 上游给定下须；规则由分析说明 |
| high | float | 上游给定上须；规则由分析说明 |
| mean | float | 上游给定均值；须与真实点使用同一数据来源 |

### 可覆盖的 style

- `font_family`：`"Arial"`
- `dpi`：`300`
- `sizing`：`{"mode": "adaptive", "profile": "categorical_x", "table": "points", "x": "category", "y": null, "item_width_in": 0.8, "item_height_in": 0.32, "plot_width_in": 5.4, "plot_height_in": 4.4, "margins_in": [0.9, 0.25, 0.85, 0.55], "min_width_in": 3.2, "min_height_in": 2.8, "max_width_in": null, "max_height_in": null, "width_in": null, "height_in": null, "label_fontsize": 11, "label_rotation": 45, "label_gap_in": 0.12}`
- `columns`：`{}`
- `limits`：`null`
- `order`：`null`
- `palette`：`null`
- `ticks`：`null`
- `tick_format`：`null`
- `title`：`""`
- `ylabel`：`"Value"`
- `title_size`：`16`
- `label_size`：`13`
- `highlight_first`：`false`
- `point_size`：`45`
- `mean_size`：`150`
- `box_width`：`0.52`
- `canvas_px`：`[872, 777]`
- `bbox`：`[134, 63, 856, 638]`

## 代码与独立调用

`source/panels.py` 原字节保留旧重建代码；不是原作者缺失函数。`code/core.py` 为绘图改造版，`code/panel.py` 保留 draw(fig,rect,tables,style) 并提供 plot_panel(tables,style=None)，两者共享同一核心。代码卡片区分原版/复用版和实际验证范围。

将整个 code/ 复制为课题包 `box_panel/`，使用课题自己的 numpy/pandas/matplotlib 环境；不要在 Wiki 安装包。函数无隐式读写、训练、联网、安装或随机生成。返回 figure、handles、sizing_plan；导出由调用层完成。示例文件对应：points=render-category-points.csv；summaries=render-box-summaries.csv。

```python
from box_panel.panel import plot_panel
# tables为已准备的DataFrame字典；列映射、顺序、颜色和尺寸在style中显式传入。
fig, handles, plan = plot_panel(tables, style)
fig.savefig('result.png', dpi=300)
```

## 尺寸与换数据

默认 W=左右留白+n×每组最小0.8英寸，长标签还可增宽并增加底边距；n为实际任意合法类别数，无白名单。默认无宽度上限、不分面、不缩字；自定义色表不足报错，默认超出来源色数时按n生成颜色而不循环。可覆盖 sizing.item_width_in、plot_height_in、width_in、max_width_in 等。

组合调用不会调整外层figure；空间不足明确报错，交调用方扩大。独立函数与render默认值快照一致，复制后无需Wiki/spec路径。`example/style.json` 专用于来源回放，不随意套到新数据。

## 回放、来源与限制

示例点值、箱体与均值是独立估读，横向抖动为固定合成展示位置；它们不能作为一致的原始验证数据进行统计推断。换数据时由课题分析先准备同源点与摘要。

verify-template 已回放PNG/PDF/SVG，15项绘图/可移植性检查通过：来源维度及数值图元与旧renderer在绝对容差1e-12内一致；任意n的代表规模/长标签/列映射/顺序/配色/上限/不同cwd调用已检查。仅为绘图软件验证，未验证真实课题统计有效性。详情见 verify/function-verification.json。PNG已目视，PDF/SVG为结构检查，独立查看器视觉未测。

2026-10-21 作者明确确认本轮回放，已通过mark-ready标为可用。来源签核继续保留；可独立render，不以来源layout整体ready为前置。

## 知识关联检查

检查现存回归评估/SHAP家族、两个来源及既有SHAP三模板。与 [[methods/regression-resampling-evaluation]] 有条件关联，但该方法的预测/逐折指标需另外整理成预计算绘图表；适配不是新增训练/密度/统计算法授权。关系在方法侧唯一记录，验证范围与模板状态分开。

SHAP图表达特征归因，输入语义不同，未找到当前模板直接读取其表的依据；不为连通图谱硬连。参考来源 [[layouts/2026-10-19-regression-stability__fig04-boxplot-panel]] 与本模板是单panel来源/复用阶段，未收录整图、未创建宽泛迁移方法。

## 使用记录

2026-10-21：按“处理待办”完成所选单panel模板化、原字节存档、回放与复用检查，待作者确认。

<!-- user:start -->
<!-- user:end -->
