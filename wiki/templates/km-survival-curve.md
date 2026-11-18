---
type: template
id: km-survival-curve
aliases:
- figureya-1survivalcurve-update--km-curve
title: KM 生存曲线与风险表
status: ready
layouts: []
sources:
- recipes/figureya-1survivalcurve-update
panels: []
language: r
license: CC-BY-NC-SA-4.0
tags:
- survival-analysis
chart_types:
- km-curve
keywords:
- survminer
- Kaplan-Meier
- log-rank
- number at risk
- survival
favorite: false
primary_method: survival-prognosis-analysis
---
# KM 生存曲线与风险表

![[templates/km-survival-curve/preview.png]]

> 许可：CC BY-NC-SA 4.0（FigureYa，Lu X, et al. iMetaMed 2025, doi:10.1002/imm3.70005）。仅限非商业使用，署名并引用；改编代码须相同方式共享；`code/` 与 `example/` 不进 Git、不推送。

<!-- facts:start -->
- 来源：[[recipes/figureya-1survivalcurve-update|多组 KM 生存曲线与风险表]]
- 语言：r
- 许可证：CC-BY-NC-SA-4.0
- 标签：survival-analysis
- 图型：[[chart-types/km-curve]]
- 输入接口：[[interfaces/survival-time-event-group|个体随访生存表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/survival-prognosis-analysis|生存分析与临床预后建模]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：仅核对 survival-time-event-group 接口契约与 KM 模板 spec.json，尚未执行真实队列分析→出图端到端联调。
    - 依据：KM 曲线模板直接消费 survival-time-event-group（本方法的输入/分层队列契约表），不在模板内重做 Cox 建模或最佳切点搜索。；前提：event 必须规范编码为 0（删失）与 1（发生结局）；time 单位统一且非负。；若使用最佳切点（如 surv_cutpoint）分组，必须在统计解释中声明多重检验偏差并在独立队列验证。；适配：将建模分层或分组后的随访队列导出为 survival-time-event-group.csv（time, event, group），并在模板 style 中显式固定 levels、labels 与风险表参数。
    - 关系证据：methods/survival-prognosis-analysis.md#输入；templates/km-survival-curve/spec.json；templates/km-survival-curve/verify/verify.json；interfaces/survival-time-event-group.md；运行证据：无
<!-- facts:end -->

## 适用

个体随访数据画 Kaplan-Meier 曲线：每行一个个体，有随访时间、0/1 事件和一个分组，组数任意（≥2）。图中带 log-rank P、可选置信带和 number-at-risk 风险表。组顺序、图例名和颜色由 style 的 `levels`、`labels`、`palette` 显式给出；组数增加时图高随风险表行数增长。

## 不适用

竞争风险（应画累积发生率）；时间依赖协变量或左截断；只有汇总生存率没有个体记录；需要多重比较校正的两两检验（见 [[recipes/figureya-284pairwiselogrank|三组以上 KM 两两比较]]）。事件编码为 1/2（survival 旧约定）时先在课题副本改成 0/1，再核对含义。

## 知识关联检查

2026-10-27：查了 chart-types/km-curve 与全部模板、方法页。库内此前无 KM 模板，也无产出个体随访表的分析方法，故不写 figure_relations。来源配方：[[recipes/figureya-1survivalcurve-update]]；统计量（survfit、log-rank）与上游相同，改动只在输入列名、分组顺序/颜色参数化与尺寸适配（见 runtime.json）。

## 数据要求

### surv（survival-time-event-group.csv）：每行一个个体：随访时间、事件（0/1）与分组；组数任意（≥2） [[interfaces/survival-time-event-group|个体随访生存表]]

| 列 | 类型 | 含义 |
|---|---|---|
| time | float | 随访时间（单位由作者给定，如月），≥0 |
| event | int | 结局事件：1 = 发生（死亡/复发），0 = 删失 |
| group | str | 分组标签；因子顺序由 style.levels 显式给出，否则按出现顺序 |

### 可覆盖的 style

- `levels`：`["high", "med", "low"]`
- `labels`：`["High-expression", "Med-expression", "Low-expression"]`
- `palette`：`["red", "navy", "darkgreen"]`
- `pval`：`true`
- `conf_int`：`true`
- `conf_int_alpha`：`0.1`
- `risk_table`：`true`
- `tables_height`：`0.3`
- `linetype`：`"solid"`
- `legend_title`：`""`
- `legend_pos`：`[0.8, 0.9]`
- `xlab`：`"Months"`
- `ylab`：`"Survival probability"`
- `dpi`：`200`
- `width_in`：`7`
- `height_in`：`6`
- `sizing`：`{"mode": "adaptive", "base_width_in": 7, "base_height_in": 6, "per_group_in": 0.25, "base_label_chars": 16, "per_label_char_in": 0.06, "max_width_in": null, "max_height_in": null}`

## 使用记录

<!-- user:start -->
<!-- user:end -->
