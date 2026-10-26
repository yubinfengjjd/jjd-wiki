---
type: method
id: shap-explanation
title: 基于 SHAP 的模型解释
status: ready
tags:
- 机器学习
- 模型解释与特征重要性
inputs: []
outputs:
- shap-summary
- shap-samples
source:
  kind: post
  gallery_entry: 2026-08-17-shap-feature-mechanism/figures/fig01-shap-a-f
license: none
cite:
- Lundberg & Lee. A Unified Approach to Interpreting Model Predictions. NeurIPS, 2017.
- Lundberg et al. From local explanations to global understanding with explainable
  AI for trees. Nature Machine Intelligence, 2020.
- SHAP TreeExplainer official documentation. https://shap.readthedocs.io/en/latest/generated/shap.TreeExplainer.html
- SHAP LinearExplainer official documentation. https://shap.readthedocs.io/en/latest/generated/shap.LinearExplainer.html
- SHAP Explainer official documentation. https://shap.readthedocs.io/en/latest/generated/shap.Explainer.html
favorite: false
figure_relations:
- figure: templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar
  compatibility: direct
  reason: 特征级平均绝对 SHAP 及其占比对应汇总图契约。
  prerequisites:
  - 同一已明确模型输出、解释对象和背景定义；不可混合不同输出单位。
  - 使用真实 SHAP 表；示例估读/合成数据仅作画法参考。
  - 模板为历史固定尺寸实现；任意 n、长标签与配色须另查可读性，尚未迁移为自适应模板。
  adaptation: ''
  evidence:
  - methods/shap-explanation.md#输出
  - templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar/spec.json
  - interfaces/shap-summary.md
  verification:
    state: not_run
    scope: 本轮仅核对知识含义与现存契约，未做实际课题分析→出图联调。
    evidence: []
- figure: templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm
  compatibility: direct
  reason: 逐样本×特征的带符号 SHAP 和着色特征值对应蜂群图契约。
  prerequisites:
  - 同一已明确模型输出、解释对象和背景定义；不可混合不同输出单位。
  - 使用真实 SHAP 表；示例估读/合成数据仅作画法参考。
  - 模板为历史固定尺寸实现；任意 n、长标签与配色须另查可读性，尚未迁移为自适应模板。
  adaptation: ''
  evidence:
  - methods/shap-explanation.md#输出
  - templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm/spec.json
  - interfaces/shap-samples.md
  verification:
    state: not_run
    scope: 本轮仅核对知识含义与现存契约，未做实际课题分析→出图联调。
    evidence: []
- figure: templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--radial-bar
  compatibility: direct
  reason: 特征级平均绝对 SHAP 及其占比对应汇总图契约。
  prerequisites:
  - 同一已明确模型输出、解释对象和背景定义；不可混合不同输出单位。
  - 使用真实 SHAP 表；示例估读/合成数据仅作画法参考。
  - 模板为历史固定尺寸实现；任意 n、长标签与配色须另查可读性，尚未迁移为自适应模板。
  adaptation: ''
  evidence:
  - methods/shap-explanation.md#输出
  - templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--radial-bar/spec.json
  - interfaces/shap-summary.md
  verification:
    state: not_run
    scope: 本轮仅核对知识含义与现存契约，未做实际课题分析→出图联调。
    evidence: []
keywords:
- SHAP
- 方法家族
- 模型解释
method_kind: analysis
purposes:
- 模型解释
summary: 对既定模型输出作 SHAP 归因，输出汇总表和逐样本贡献表；不训练、不划分数据。
data_contract:
  input: 已拟合模型、背景 DataFrame、解释样本 DataFrame；特征列同名同序、有限数值。
  output: 样本×特征 SHAP 矩阵、summary 表（feature/shap/percent）、samples 长表；不产生训练或预测指标。
implementations:
- id: shap-explain-model
  title: SHAP 纯函数封装
  language: Python
  entrypoint: code/explain_model.py:explain_model
  dependencies:
  - shap
  - numpy
  - pandas
  verification: verification/shap-explain-model.json
---
# 基于 SHAP 的模型解释

<!-- facts:start -->
- 来源：[[layouts/2026-08-17-shap-feature-mechanism__fig01-shap-a-f|双模型 SHAP 特征贡献组图]]
- 许可证：仅供个人研究参考
- 引用：Lundberg & Lee. A Unified Approach to Interpreting Model Predictions. NeurIPS, 2017.；Lundberg et al. From local explanations to global understanding with explainable AI for trees. Nature Machine Intelligence, 2020.；SHAP TreeExplainer official documentation. https://shap.readthedocs.io/en/latest/generated/shap.TreeExplainer.html；SHAP LinearExplainer official documentation. https://shap.readthedocs.io/en/latest/generated/shap.LinearExplainer.html；SHAP Explainer official documentation. https://shap.readthedocs.io/en/latest/generated/shap.Explainer.html
- 标签：机器学习、模型解释与特征重要性
- 分析用途：模型解释
- 输入接口：未声明
- 输出接口：[[interfaces/shap-summary|SHAP 特征贡献汇总表]] · [[interfaces/shap-samples|SHAP 逐样本值表]]
- 接口结构匹配的图（仅结构候选，未核实语义）：[[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar|SHAP 条形图（含环形 inset）]]（ready） · [[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm|SHAP 蜂群图]]（ready） · [[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--radial-bar|SHAP 环形贡献图]]（ready）
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/shap-explanation/code/explain_model.py](/files/wiki/methods/shap-explanation/code/explain_model.py) · [methods/shap-explanation/code/shap_explain.py](/files/wiki/methods/shap-explanation/code/shap_explain.py)

- 方法配图关系（语义审查）：
  - [[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar|SHAP 条形图（含环形 inset）]]（ready）：直接可接（direct）；调用验证：not_run；范围：本轮仅核对知识含义与现存契约，未做实际课题分析→出图联调。
    - 依据：特征级平均绝对 SHAP 及其占比对应汇总图契约。；前提：同一已明确模型输出、解释对象和背景定义；不可混合不同输出单位。；使用真实 SHAP 表；示例估读/合成数据仅作画法参考。；模板为历史固定尺寸实现；任意 n、长标签与配色须另查可读性，尚未迁移为自适应模板。；适配：无格式适配声明
    - 关系证据：methods/shap-explanation.md#输出；templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar/spec.json；interfaces/shap-summary.md；运行证据：无
  - [[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm|SHAP 蜂群图]]（ready）：直接可接（direct）；调用验证：not_run；范围：本轮仅核对知识含义与现存契约，未做实际课题分析→出图联调。
    - 依据：逐样本×特征的带符号 SHAP 和着色特征值对应蜂群图契约。；前提：同一已明确模型输出、解释对象和背景定义；不可混合不同输出单位。；使用真实 SHAP 表；示例估读/合成数据仅作画法参考。；模板为历史固定尺寸实现；任意 n、长标签与配色须另查可读性，尚未迁移为自适应模板。；适配：无格式适配声明
    - 关系证据：methods/shap-explanation.md#输出；templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm/spec.json；interfaces/shap-samples.md；运行证据：无
  - [[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--radial-bar|SHAP 环形贡献图]]（ready）：直接可接（direct）；调用验证：not_run；范围：本轮仅核对知识含义与现存契约，未做实际课题分析→出图联调。
    - 依据：特征级平均绝对 SHAP 及其占比对应汇总图契约。；前提：同一已明确模型输出、解释对象和背景定义；不可混合不同输出单位。；使用真实 SHAP 表；示例估读/合成数据仅作画法参考。；模板为历史固定尺寸实现；任意 n、长标签与配色须另查可读性，尚未迁移为自适应模板。；适配：无格式适配声明
    - 关系证据：methods/shap-explanation.md#输出；templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--radial-bar/spec.json；interfaces/shap-summary.md；运行证据：无
<!-- facts:end -->

## 用途

对既定模型输出作特征归因，分别保存逐样本带符号贡献和特征级平均绝对贡献。此页是有条件的方法家族说明；家族范围、代码分支、实际验证三个维度分开。解释训练模型的行为，不提供因果或临床效用结论。

## 原始实现与家族范围

来源是公众号的 XGBoost＋SHAP 示例；原生片段只保留在画廊条目 `2026-08-17-shap-feature-mechanism/figures/fig01-shap-a-f` 的 `original_code/`，manifest 记录字节哈希。Wiki 的 `code/shap_explain.py` 是历史复用脚本，保留原字节和旧行为；`code/explain_model.py` 是本次新增的纯函数封装，不训练、不划分、不调参。

可推广的核心是“明确模型输出→选择适用解释器/背景→计算归因→整理结果”，而非承诺所有模型都支持同一入口：
- 树分支：TreeExplainer 支持列出的模型家族，输出模式与特征依赖假设有条件。
- 线性分支：LinearExplainer 可解释线性模型，背景与特征相关性处理影响归因。
- 通用分支：Explainer 依据模型、masker 和算法选择估计器；成本与解释含义须核对。



## 来源与实现选择

| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| 原帖 XGBoost + SHAP 示例 | 画廊 `2026-08-17-shap-feature-mechanism/figures/fig01-shap-a-f` `original_code/`；旧复用脚本 `code/shap_explain.py` | 训练/预测/归因的组合脚本 | 原字节保留；历史脚本未提升为已验证实现 |
| 纯函数 `explain_model` | 本次从旧脚本归因分支提炼；`code/explain_model.py` | 已拟合模型 + background + samples；values/summary/samples | verified：解析线性模型数值、顺序、输入不变 |
| 树/线性/通用解释器 | 同上 | 不同模型/输出 | 代码分支存在；真实模型/课题未运行 |
## 适用

已明确研究任务、训练好的模型、特征处理、背景/解释样本及模型输出。`explain_model` 面向数值表格的回归/分类；真实课题先审查训练/验证边界、类别编码、缺失值与重复测量。标签名或模型名不能代替这些前提。

## 不适用

不能直接据此处理多分类、多输出、时序/分组划分或任意原生类别特征；需要另核接口和实现。特征归因不等于因果、预测校准、外部验证或模型临床有效性。相关特征与背景选择必须说明，不能仅看排名定机制。

## 输入

`explain_model(model, background, samples, ...)` 接收已拟合模型、背景 DataFrame 和解释样本 DataFrame；两者特征列必须同名同序、非空、有限数值。`explainer_kind` 取 `tree`/`linear`/`model_agnostic`；分类通用分支用 `predict_proba[:, output_index]`。训练、数据划分、样本选择和背景定义都由调用方负责，函数不隐式重做。

## 怎么做

1. 在课题中先固定模型、特征处理、背景和解释样本；不要用全数据回代或测试集调参后的模型冒充独立解释。
2. 选择与实际模型匹配的解释器；树/线性/通用分支的前提不同。
3. 显式传入 `task`、`output_index`、`top_n`、`min_mean_abs_shap` 和解释器/调用参数；随机方法要传 seed。
4. 运行后检查 SHAP 矩阵形状、summary 百分比、样本表行数和特征顺序；用已知线性模型做数值 sanity check。
5. 解释图只描述模型行为；需要因果/临床结论时另做设计和验证。

## 代码

入口 `methods/shap-explanation/code/explain_model.py:explain_model`，依赖 numpy、pandas、shap。2026-10-23 用解析线性模型验证：SHAP 值与闭式解一致、summary 百分比合计 100、samples 行数为样本×特征、输入和模型系数未变、特征顺序不一致会报错。scope 仅软件/数值夹具，不代表真实模型或临床有效性。

`code/shap_explain.py` 是历史脚本，未改字节；本轮没有把它当作已验证实现。

## 输出

`values`：样本×特征 SHAP 矩阵；`summary`：feature、shap（平均绝对归因）、percent（筛选前总贡献占比）；`samples`：每行样本×特征的带符号 shap 和 feature_value（解释样本内各特征 min/max 缩放，常量=0）；`diagnostics`：解释器、任务、输出索引、样本/背景数、特征顺序、shap 版本等。TOP_N/MIN_MEAN_ABS_SHAP 筛选后不重新归一化 percent。

## 使用记录

2026-10-21：方法边界、代码来源和关系核查，未运行真实课题分析。
2026-10-23：新增 `explain_model` 并用解析线性模型做数值验证；未运行真实模型或课题出图。

## 知识关联检查

2026-10-23 检查现存方法页、单 panel 来源、模板与接口，包括另一来源的回归评估。SHAP 汇总可配条形/环形，逐样本贡献可配蜂群，同一方法对应多图，关系唯一记在 frontmatter，反向由程序派生。三个历史模板为 direct（表结构无需改名/整形），但不证明上游分支或当前课题已联调；模板仍为历史固定尺寸。

[[methods/regression-resampling-evaluation]] 与 SHAP 是互补参考：前者评估预测，后者归因。预测/指标表没有 SHAP 所需模型、特征及背景，不能直接串联；未发现第二个有依据的现存方法可直接读取 SHAP 图表契约。

<!-- user:start -->
<!-- user:end -->
