---
type: template
id: figureya-1survivalcurve-update--km-curve
title: KM 生存曲线与风险表
status: draft
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
---
# KM 生存曲线与风险表

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
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

个体随访数据画 Kaplan-Meier 曲线：每行一个个体，有随访时间、0/1 事件和一个分组，组数任意（≥2）。图中带 log-rank P、可选置信带和 number-at-risk 风险表。组顺序、图例名和颜色由 style 的 `levels`、`labels`、`palette` 显式给出；组数增加时图高随风险表行数增长。

## 不适用

竞争风险（应画累积发生率）；时间依赖协变量或左截断；只有汇总生存率没有个体记录；需要多重比较校正的两两检验（见 [[recipes/figureya-284pairwiselogrank|三组以上 KM 两两比较]]）。事件编码为 1/2（survival 旧约定）时先在课题副本改成 0/1，再核对含义。

## 知识关联检查

2026-10-27：查了 chart-types/km-curve 与全部模板、方法页。库内此前无 KM 模板，也无产出个体随访表的分析方法，故不写 figure_relations。来源配方：[[recipes/figureya-1survivalcurve-update]]；统计量（survfit、log-rank）与上游相同，改动只在输入列名、分组顺序/颜色参数化与尺寸适配（见 runtime.json）。

## 数据要求

模板化后生成。

## 使用记录

<!-- user:start -->
<!-- user:end -->
