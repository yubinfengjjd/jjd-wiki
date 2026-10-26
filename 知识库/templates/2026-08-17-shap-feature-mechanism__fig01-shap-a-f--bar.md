---
type: template
id: 2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar
title: SHAP 条形图（含环形 inset）
status: ready
layouts:
- 2026-08-17-shap-feature-mechanism__fig01-shap-a-f
panels:
- A
- D
language: python
chart_types:
- bar
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
# SHAP 条形图（含环形 inset）

![[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar/preview.png]]

<!-- facts:start -->
- 来源版式：[[layouts/2026-08-17-shap-feature-mechanism__fig01-shap-a-f|双模型 SHAP 特征贡献组图]]
- 面板（来源版式）：A、D
- 语言：python
- 标签：机器学习、模型解释与特征重要性、化学信息与QSAR
- 图型：[[chart-types/bar]]
- 输入接口：[[interfaces/shap-summary|SHAP 特征贡献汇总表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：[[methods/shap-explanation|基于 SHAP 的模型解释]]（ready）

- 方法配图关系（语义审查）：
  - [[methods/shap-explanation|基于 SHAP 的模型解释]]（ready）：直接可接（direct）；调用验证：not_run；范围：本轮仅核对知识含义与现存契约，未做实际课题分析→出图联调。
    - 依据：特征级平均绝对 SHAP 及其占比对应汇总图契约。；前提：同一已明确模型输出、解释对象和背景定义；不可混合不同输出单位。；使用真实 SHAP 表；示例估读/合成数据仅作画法参考。；模板为历史固定尺寸实现；任意 n、长标签与配色须另查可读性，尚未迁移为自适应模板。；适配：无格式适配声明
    - 关系证据：methods/shap-explanation.md#输出；templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar/spec.json；interfaces/shap-summary.md；运行证据：无
<!-- facts:end -->

## 适用

展示模型的全局特征贡献大小及相对占比。输入每特征一条平均绝对 SHAP 和百分比，按 SHAP 降序排列；左下环形 inset 和左侧色标随主轴定位。

## 不适用

本模板只绘图，不训练模型或计算 SHAP。示例为视觉复刻：条形/环形数值是不确定转录，蜂群是合成近似；不能据此作科学验证、真实样本量或因果解释。原帖的 XGBoost/SR 示例不是目标图 LightGBM/CatBoost 的生成代码。单独出图用固定版心；特征名都很短时，标签一侧会留空，可用 --style 覆盖 rect。

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
- `shap_label`：`"SHAP Value"`
- `high_label`：`"High"`
- `low_label`：`"Low"`
- `font_weight`：`"bold"`
- `axes_linewidth`：`0.8`
- `hidden_spines`：`["left", "top"]`
- `width_in`：`4.8`
- `height_in`：`3.5`
- `rect`：`[0.14, 0.11, 0.5, 0.83]`
- `palette`：`[[0.6941176470588235, 0.09411764705882353, 0.1803921568627451], [0.6862745098039216, 0.09803921568627451, 0.16862745098039217], [0.6941176470588235, 0.09019607843137255, 0.16862745098039217], [0.6980392156862745, 0.09411764705882353, 0.17647058823529413], [0.7176470588235294, 0.16862745098039217, 0.19607843137254902], [0.8588235294117647, 0.4117647058823529, 0.33725490196078434], [0.9450980392156862, 0.615686274509804, 0.48627450980392156], [0.9450980392156862, 0.6392156862745098, 0.5098039215686274], [0.8196078431372549, 0.8941176470588236, 0.9372549019607843], [0.3254901960784314, 0.615686274509804, 0.7764705882352941], [0.2901960784313726, 0.592156862745098, 0.7647058823529411], [0.26666666666666666, 0.5803921568627451, 0.7607843137254902], [0.2823529411764706, 0.5725490196078431, 0.7529411764705882], [0.26666666666666666, 0.5803921568627451, 0.7647058823529411], [0.25882352941176473, 0.5803921568627451, 0.7647058823529411]]`
- `xlim`：`null`
- `xticks`：`null`
- `x_tick_direction`：`"in"`
- `annotation_linewidth`：`0.25`
- `major_tick_width`：`0.8`
- `minor_tick_width`：`0.6`
- `axis_offset_size`：`7.5`
- `axis_tick_size`：`7.5`
- `axis_label_size`：`12.0`
- `bar_value_size`：`4.8`
- `colorbar_label_size`：`11.0`
- `colorbar_end_size`：`10.0`
- `feature_label_max_size`：`10`
- `feature_label_scale`：`150`
- `inset_label_max_size`：`3.9`
- `inset_label_scale`：`58.5`
- `inset_edge_width`：`0.2`

## 知识关联检查

- 检查日期：2026-10-22。
- 检查范围：本模板页、`methods/shap-explanation`、同源蜂群图与环形贡献图、`interfaces/shap-summary`。
- 一方法多图：`methods/shap-explanation` 已明确声明与本模板的 `figure_relations`（直接可接；依据为特征级平均绝对 SHAP 及占比对应汇总图契约），并与蜂群图、环形贡献图并列。本模板不重复维护关系，反向展示由方法页派生。
- 一图多方法：当前仅 `shap-explanation` 的汇总图契约直接使用 `shap-summary`；未发现其他 ready 方法具有相同输入/输出语义，故不新增关联。
- 同源关系：条形图与环形贡献图读取同一 `shap-summary` 接口，是同一数据的不同表达；可按版式需要选用，但不能把两图当作两份独立证据。
- 未关联原因与边界：示例为估读/合成数据，回放只证明当前代码与示例可运行；真实课题须重新计算 SHAP，并核对模型、解释对象、背景分布和单位。未验证其他模型或任意 n 的适配。

## 使用记录

<!-- user:start -->
<!-- user:end -->
