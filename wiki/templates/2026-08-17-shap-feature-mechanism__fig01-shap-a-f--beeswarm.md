---
type: template
id: 2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm
title: SHAP 蜂群图
status: ready
layouts:
- 2026-08-17-shap-feature-mechanism__fig01-shap-a-f
panels:
- B
- E
language: python
chart_types:
- beeswarm
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
# SHAP 蜂群图

![[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm/preview.png]]

<!-- facts:start -->
- 来源：[[layouts/2026-08-17-shap-feature-mechanism__fig01-shap-a-f|双模型 SHAP 特征贡献组图]]
- 面板（来源版式）：B、E
- 语言：python
- 标签：机器学习、模型解释与特征重要性、化学信息与QSAR
- 图型：[[chart-types/beeswarm]]
- 输入接口：[[interfaces/shap-samples|SHAP 逐样本值表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：[[methods/shap-explanation|基于 SHAP 的模型解释]]（ready）

- 方法配图关系（语义审查）：
  - [[methods/shap-explanation|基于 SHAP 的模型解释]]（ready）：直接可接（direct）；调用验证：not_run；范围：本轮仅核对知识含义与现存契约，未做实际课题分析→出图联调。
    - 依据：逐样本×特征的带符号 SHAP 和着色特征值对应蜂群图契约。；前提：同一已明确模型输出、解释对象和背景定义；不可混合不同输出单位。；使用真实 SHAP 表；示例估读/合成数据仅作画法参考。；模板为历史固定尺寸实现；任意 n、长标签与配色须另查可读性，尚未迁移为自适应模板。；适配：无格式适配声明
    - 关系证据：methods/shap-explanation.md#输出；templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm/spec.json；interfaces/shap-samples.md；运行证据：无
<!-- facts:end -->

## 适用

展示各特征逐样本 SHAP 的分布、正负方向及特征值高低。输入 feature、shap、feature_value；默认按平均绝对 SHAP 降序，可用 feature_order 对齐其他面板。单图显示特征名，组合版式通过 show_feature_labels=false 使用同行条形图的共享标签。

## 不适用

本模板只绘图，不训练模型或计算 SHAP。示例为视觉复刻：条形/环形数值是不确定转录，蜂群是合成近似；不能据此作科学验证、真实样本量或因果解释。原帖的 XGBoost/SR 示例不是目标图 LightGBM/CatBoost 的生成代码。单独出图用固定版心；特征名都很短时，标签一侧会留空，可用 --style 覆盖 rect。

## 数据要求

### SHAP逐样本值（shap-samples.csv）：逐样本 SHAP 及特征值，每特征可有多个点；示例为固定种子合成近似，不代表真实样本量 [[interfaces/shap-samples|SHAP 逐样本值表]]

| 列 | 类型 | 含义 |
|---|---|---|
| feature | str | 特征名 |
| shap | float | 该样本该特征的带符号 SHAP 值 |
| feature_value | float | 该特征取值在解释样本内按最小–最大缩放到 0–1，用于着色；常量特征取 0 |

### 可覆盖的 style

- `font_family`：`"Arial"`
- `dpi`：`600`
- `shap_label`：`"SHAP Value"`
- `font_weight`：`"bold"`
- `axes_linewidth`：`0.8`
- `hidden_spines`：`["left", "top", "right"]`
- `width_in`：`4.0`
- `height_in`：`3.5`
- `rect`：`[0.29, 0.11, 0.6, 0.86]`
- `xlim`：`null`
- `xticks`：`null`
- `clim`：`null`
- `feature_order`：`null`
- `cmap`：`"RdBu_r"`
- `zero_line_color`：`"#999999"`
- `feature_value_label`：`"Feature value"`
- `high_label`：`"High"`
- `low_label`：`"Low"`
- `x_tick_direction`：`"in"`
- `show_feature_labels`：`true`
- `major_tick_width`：`0.8`
- `minor_tick_width`：`0.6`
- `axis_offset_size`：`7.5`
- `axis_tick_size`：`7.0`
- `axis_label_size`：`12.0`
- `colorbar_tick_size`：`5.0`
- `colorbar_label_size`：`6.0`
- `feature_label_size`：`7.5`
- `zero_line_width`：`1.0`
- `grid_line_width`：`0.5`

## 知识关联检查

- 检查日期：2026-10-22。
- 检查范围：本模板页、`methods/shap-explanation`、同源条形图与环形贡献图、`interfaces/shap-samples`。
- 一方法多图：`methods/shap-explanation` 已明确声明与本模板的 `figure_relations`（直接可接；依据为逐样本×特征的带符号 SHAP 与着色特征值对应蜂群图契约），并与条形图、环形贡献图并列。本模板不重复维护关系。
- 一图多方法：当前仅 `shap-explanation` 的逐样本解释契约使用 `shap-samples`；未发现其他 ready 方法具有相同输入/输出语义，故不新增关联。
- 同源关系：蜂群图与条形图/环形图来自同一 SHAP 分析，分别表达逐样本分布和特征级汇总；不能把不同 panel 当作独立样本或独立证据。
- 未关联原因与边界：示例为估读/合成数据，回放只证明当前代码与示例可运行；真实课题须重新计算 SHAP，并核对模型、解释对象、背景分布和单位。未验证其他模型或任意 n 的适配。

## 使用记录

<!-- user:start -->
<!-- user:end -->
