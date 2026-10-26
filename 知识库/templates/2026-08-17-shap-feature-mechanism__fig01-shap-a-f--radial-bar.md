---
type: template
id: 2026-08-17-shap-feature-mechanism__fig01-shap-a-f--radial-bar
title: SHAP 环形贡献图
status: ready
layouts:
- 2026-08-17-shap-feature-mechanism__fig01-shap-a-f
panels:
- C
- F
language: python
chart_types:
- radial-bar
favorite: false
tags:
- 机器学习
- 模型解释与特征重要性
- 化学信息与QSAR
keywords:
- SHAP
- LightGBM
- CatBoost
- pLC50
- AR-DBP
- QSAR
---
# SHAP 环形贡献图

![[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--radial-bar/preview.png]]

<!-- facts:start -->
- 来源版式：[[layouts/2026-08-17-shap-feature-mechanism__fig01-shap-a-f|双模型 SHAP 特征贡献组图]]
- 面板（来源版式）：C、F
- 语言：python
- 标签：机器学习、模型解释与特征重要性、化学信息与QSAR
- 图型：[[chart-types/radial-bar]]
- 输入接口：[[interfaces/shap-summary|SHAP 特征贡献汇总表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：[[methods/shap-explanation|基于 SHAP 的模型解释]]（ready）

- 方法配图关系（语义审查）：
  - [[methods/shap-explanation|基于 SHAP 的模型解释]]（ready）：直接可接（direct）；调用验证：not_run；范围：本轮仅核对知识含义与现存契约，未做实际课题分析→出图联调。
    - 依据：特征级平均绝对 SHAP 及其占比对应汇总图契约。；前提：同一已明确模型输出、解释对象和背景定义；不可混合不同输出单位。；使用真实 SHAP 表；示例估读/合成数据仅作画法参考。；模板为历史固定尺寸实现；任意 n、长标签与配色须另查可读性，尚未迁移为自适应模板。；适配：无格式适配声明
    - 关系证据：methods/shap-explanation.md#输出；templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--radial-bar/spec.json；interfaces/shap-summary.md；运行证据：无
<!-- facts:end -->

## 适用

展示全局特征贡献大小及百分比，以环形条和中心色标表达。每特征一条平均绝对 SHAP 和百分比；默认按 SHAP 降序，可用 feature_order 对齐条形图。

## 不适用

本模板只绘图，不训练模型或计算 SHAP。示例为视觉复刻：条形/环形数值是不确定转录，蜂群是合成近似；不能据此作科学验证、真实样本量或因果解释。原帖的 XGBoost/SR 示例不是目标图 LightGBM/CatBoost 的生成代码。特征较多时，最细扇区上的数值标签会与描边重叠、难以辨认。

## 数据要求

### SHAP汇总（shap-summary.csv）：每特征一条 SHAP 贡献及百分比；示例为不确定转录 [[interfaces/shap-summary|SHAP 特征贡献汇总表]]

| 列 | 类型 | 含义 |
|---|---|---|
| feature | str | 特征名 |
| shap | float | 该特征在解释样本上的平均绝对 SHAP 值 |
| percent | float | 平均绝对 SHAP 占全部特征之和的百分比，0–100 |

### 可覆盖的 style

- `font_family`：`"Arial"`
- `dpi`：`600`
- `font_weight`：`"bold"`
- `axes_linewidth`：`0.8`
- `tick_direction`：`"out"`
- `width_in`：`3.7`
- `height_in`：`4`
- `rect`：`[0, 0.025, 0.94, 0.9]`
- `clim`：`null`
- `ticks`：`null`
- `feature_order`：`null`
- `cmap`：`"RdBu_r"`
- `colorbar_height`：`0.24`
- `radial_outer_padding`：`1.6`
- `absolute_shap_label`：`"|SHAP Value|"`
- `colorbar_tick_width`：`0.5`
- `colorbar_tick_size`：`4.5`
- `colorbar_title_size`：`4.3`
- `feature_label_max_size`：`5.7`
- `feature_label_scale`：`85.5`
- `bar_value_max_size`：`3.8`
- `bar_value_scale`：`57`
- `bar_edge_width`：`0.8`
- `ring_edge_width`：`0.9`

## 知识关联检查

- 检查日期：2026-10-22。
- 检查范围：本模板页、`methods/shap-explanation`、同源条形图与蜂群图、`interfaces/shap-summary`。
- 一方法多图：`methods/shap-explanation` 已明确声明与本模板的 `figure_relations`（直接可接；依据为特征级平均绝对 SHAP 及占比对应汇总图契约），并与条形图、蜂群图并列。本模板不重复维护关系。
- 一图多方法：当前仅 `shap-explanation` 的汇总图契约直接使用 `shap-summary`；未发现其他 ready 方法具有相同输入/输出语义，故不新增关联。
- 同源关系：环形贡献图与条形图读取同一 `shap-summary` 接口，是同一数据的不同表达；可按版式需要选用，但不能把两图当作两份独立证据。
- 未关联原因与边界：示例为估读/合成数据，回放只证明当前代码与示例可运行；真实课题须重新计算 SHAP，并核对模型、解释对象、背景分布和单位。未验证其他模型或任意 n 的适配。

## 使用记录

<!-- user:start -->
<!-- user:end -->
