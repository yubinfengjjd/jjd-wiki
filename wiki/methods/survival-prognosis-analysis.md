---
type: method
id: survival-prognosis-analysis
title: 生存分析与临床预后建模
status: ready
tags:
- survival-analysis
- diagnostic-roc
- transcriptomics
data_domains:
- clinical-prognosis
- bulk-transcriptomics
inputs:
- survival-time-event-group
outputs:
- subgroup-effect-table
- candidate-biomarker-list
render_bridges: []
source:
  kind: written
license: none
cite:
- 'Therneau TM, Grambsch PM. Modeling Survival Data: Extending the Cox Model. Springer,
  2000.'
- 'Kamarudin AN, et al. Time-dependent ROC curve analysis in medical research: current
  methods and applications. BMC Medical Research Methodology, 2017.'
- 'Vickers AJ, Elkin EB. Decision curve analysis: a novel method for evaluating prediction
  models. Medical Decision Making, 2006.'
favorite: false
method_kind: analysis
purposes:
- 生存与预后建模
summary: 面向临床随访队列开展 Kaplan-Meier 生存分层、单/多因素 Cox 比例风险回归、LASSO/机器学习预后特征筛选、亚组异质性评估以及
  Time-ROC/列线图/DCA 验证；本库尚未封装统一可运行分析模块。
data_contract:
  input: 个体随访生存表 survival-time-event-group（time, event, group）及可选临床协变量与候选基因表达/风险评分；event
    规范为 0=删失、1=结局事件。
  output: 亚组效应量汇总表 subgroup-effect-table（label, estimate, lower, upper, n, percent,
    p）与候选预后标志物表 candidate-biomarker-list。
keywords:
- Kaplan-Meier
- Cox regression
- hazard ratio
- LASSO Cox
- time-dependent ROC
- nomogram
- DCA
- 生存分析
- 预后建模
figure_relations:
- figure: templates/km-survival-curve
  compatibility: adaptable
  reason: KM 曲线模板直接消费 survival-time-event-group（本方法的输入/分层队列契约表），不在模板内重做 Cox 建模或最佳切点搜索。
  prerequisites:
  - event 必须规范编码为 0（删失）与 1（发生结局）；time 单位统一且非负。
  - 若使用最佳切点（如 surv_cutpoint）分组，必须在统计解释中声明多重检验偏差并在独立队列验证。
  adaptation: 将建模分层或分组后的随访队列导出为 survival-time-event-group.csv（time, event, group），并在模板
    style 中显式固定 levels、labels 与风险表参数。
  evidence:
  - methods/survival-prognosis-analysis.md#输入
  - templates/km-survival-curve/spec.json
  - templates/km-survival-curve/verify/verify.json
  - interfaces/survival-time-event-group.md
  verification:
    state: not_run
    scope: 仅核对 survival-time-event-group 接口契约与 KM 模板 spec.json，尚未执行真实队列分析→出图端到端联调。
    evidence: []
- figure: templates/subgroup-hazard-forest
  compatibility: direct
  reason: 方法输出 subgroup-effect-table 直接对齐临床亚组森林图模板契约（label, estimate, lower, upper,
    n, percent, p）；模板仅做可视化渲染，不拟合 Cox 模型。
  prerequisites:
  - 所有亚组效应量（HR 与 95% CI）须由同一预后模型/分组定义在各临床亚组内分别拟合得到。
  - 交互作用 P 值（p 列）需明确为交互项检验或组内趋势检验，避免混淆。
  adaptation: ''
  evidence:
  - methods/survival-prognosis-analysis.md#输出
  - templates/subgroup-hazard-forest/spec.json
  - templates/subgroup-hazard-forest/verify/verify.json
  - interfaces/subgroup-effect-table.md
  verification:
    state: not_run
    scope: 仅核对 subgroup-effect-table 输出接口与森林图模板 spec.json 契约，尚未执行真实队列分析→出图端到端联调。
    evidence: []
- figure: templates/roe-cox-heatmap
  compatibility: adaptable
  reason: 多队列（TCGA 与自采队列）Cox 比例风险 HR/p 值可与亚群临床亚型 Ro/e 偏好合并呈现为 variant 热图；模板不做生存回归。
  prerequisites:
  - 各队列 Cox 模型须明确协变量与比例风险假定；HR > 1 标为 Risk，HR < 1 标为 Protective。
  adaptation: 整理 roe_cox_heatmap.csv（cluster, tcga_HR, tcga_p_value, inhouse_HR, inhouse_p_value
    及 Ro/e 列）。
  evidence:
  - methods/survival-prognosis-analysis.md#输出
  - templates/roe-cox-heatmap/spec.json
  verification:
    state: not_run
    scope: 2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
next_steps:
- direction: 方向 1：预后模型重采样评估与 SHAP 可解释性归因
  when: 已构建连续风险评分或机器学习预后模型，需评估交叉验证稳定性及核心特征 SHAP 贡献时
  analysis_templates:
  - methods/regression-resampling-evaluation
  - methods/shap-explanation
  intermediate_interface: model-prediction-shap
  viz_templates:
  - templates/shap-beeswarm
  - templates/shap-importance-bar
  - templates/resampling-metric-box
  - templates/roe-cox-heatmap
- direction: 方向 2：高低风险组间差异表达与生物学通路机制解析
  when: 按预后风险评分划分高低风险组后，解析两组间的差异驱动基因与富集信号通路时
  analysis_templates:
  - methods/differential-expression
  - methods/gene-set-enrichment
  intermediate_interface: deg-result-table
  viz_templates:
  - templates/bulk-de-volcano
- direction: 方向 3：风险分层与肿瘤免疫微环境浸润关联
  when: 评估高/低风险患者在免疫细胞浸润、免疫检查点或肿瘤微环境评分上的差异时
  analysis_templates:
  - methods/immune-infiltration-tme
  - recipes/figureya-230immunelandscape
  intermediate_interface: pathway-score-table
  viz_templates:
  - templates/pathway-stat-violin
- direction: 方向 4：Time-ROC、列线图校准与临床决策曲线（DCA）参考配方
  when: 需要补充多时间点 AUC、诺莫图校准曲线或净临床获益曲线以支撑临床转化评估时
  analysis_templates:
  - recipes/figureya-85timeroc
  - recipes/figureya-30nomogram-update
  - recipes/figureya-33dca-update
  intermediate_interface: subgroup-effect-table
  viz_templates:
  - templates/km-survival-curve
  - templates/subgroup-hazard-forest
---
# 生存分析与临床预后建模

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：仅供个人研究参考
- 引用：Therneau TM, Grambsch PM. Modeling Survival Data: Extending the Cox Model. Springer, 2000.；Kamarudin AN, et al. Time-dependent ROC curve analysis in medical research: current methods and applications. BMC Medical Research Methodology, 2017.；Vickers AJ, Elkin EB. Decision curve analysis: a novel method for evaluating prediction models. Medical Decision Making, 2006.
- 标签：survival-analysis、diagnostic-roc、transcriptomics
- 分析用途：生存与预后建模
- 输入接口：[[interfaces/survival-time-event-group|个体随访生存表]]
- 输出接口：[[interfaces/subgroup-effect-table|亚组效应量汇总表]] · [[interfaces/candidate-biomarker-list|多算法筛选候选特征基因表]]
- 接口结构匹配的图（仅结构候选，未核实语义）：[[templates/subgroup-hazard-forest|亚组分析森林图]]（ready）
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无
- 下一步分析导航（Step N → Step N+1）：
  - **方向 1：预后模型重采样评估与 SHAP 可解释性归因**（触发条件：已构建连续风险评分或机器学习预后模型，需评估交叉验证稳定性及核心特征 SHAP 贡献时；中间表：model-prediction-shap；分析模版：methods/regression-resampling-evaluation、methods/shap-explanation；可视化模版：templates/shap-beeswarm、templates/shap-importance-bar、templates/resampling-metric-box、templates/roe-cox-heatmap）
  - **方向 2：高低风险组间差异表达与生物学通路机制解析**（触发条件：按预后风险评分划分高低风险组后，解析两组间的差异驱动基因与富集信号通路时；中间表：deg-result-table；分析模版：methods/differential-expression、methods/gene-set-enrichment；可视化模版：templates/bulk-de-volcano）
  - **方向 3：风险分层与肿瘤免疫微环境浸润关联**（触发条件：评估高/低风险患者在免疫细胞浸润、免疫检查点或肿瘤微环境评分上的差异时；中间表：pathway-score-table；分析模版：methods/immune-infiltration-tme、recipes/figureya-230immunelandscape；可视化模版：templates/pathway-stat-violin）
  - **方向 4：Time-ROC、列线图校准与临床决策曲线（DCA）参考配方**（触发条件：需要补充多时间点 AUC、诺莫图校准曲线或净临床获益曲线以支撑临床转化评估时；中间表：subgroup-effect-table；分析模版：recipes/figureya-85timeroc、recipes/figureya-30nomogram-update、recipes/figureya-33dca-update；可视化模版：templates/km-survival-curve、templates/subgroup-hazard-forest）

- 方法配图关系（语义审查）：
  - [[templates/km-survival-curve|KM 生存曲线与风险表]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：仅核对 survival-time-event-group 接口契约与 KM 模板 spec.json，尚未执行真实队列分析→出图端到端联调。
    - 依据：KM 曲线模板直接消费 survival-time-event-group（本方法的输入/分层队列契约表），不在模板内重做 Cox 建模或最佳切点搜索。；前提：event 必须规范编码为 0（删失）与 1（发生结局）；time 单位统一且非负。；若使用最佳切点（如 surv_cutpoint）分组，必须在统计解释中声明多重检验偏差并在独立队列验证。；适配：将建模分层或分组后的随访队列导出为 survival-time-event-group.csv（time, event, group），并在模板 style 中显式固定 levels、labels 与风险表参数。
    - 关系证据：methods/survival-prognosis-analysis.md#输入；templates/km-survival-curve/spec.json；templates/km-survival-curve/verify/verify.json；interfaces/survival-time-event-group.md；运行证据：无
  - [[templates/subgroup-hazard-forest|亚组分析森林图]]（ready）：直接可接（direct）；调用验证：not_run；范围：仅核对 subgroup-effect-table 输出接口与森林图模板 spec.json 契约，尚未执行真实队列分析→出图端到端联调。
    - 依据：方法输出 subgroup-effect-table 直接对齐临床亚组森林图模板契约（label, estimate, lower, upper, n, percent, p）；模板仅做可视化渲染，不拟合 Cox 模型。；前提：所有亚组效应量（HR 与 95% CI）须由同一预后模型/分组定义在各临床亚组内分别拟合得到。；交互作用 P 值（p 列）需明确为交互项检验或组内趋势检验，避免混淆。；适配：无格式适配声明
    - 关系证据：methods/survival-prognosis-analysis.md#输出；templates/subgroup-hazard-forest/spec.json；templates/subgroup-hazard-forest/verify/verify.json；interfaces/subgroup-effect-table.md；运行证据：无
  - [[templates/roe-cox-heatmap|多因素Cox与Ro/e热图]]（draft）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：多队列（TCGA 与自采队列）Cox 比例风险 HR/p 值可与亚群临床亚型 Ro/e 偏好合并呈现为 variant 热图；模板不做生存回归。；前提：各队列 Cox 模型须明确协变量与比例风险假定；HR > 1 标为 Risk，HR < 1 标为 Protective。；适配：整理 roe_cox_heatmap.csv（cluster, tcga_HR, tcga_p_value, inhouse_HR, inhouse_p_value 及 Ro/e 列）。
    - 关系证据：methods/survival-prognosis-analysis.md#输出；templates/roe-cox-heatmap/spec.json；运行证据：无
<!-- facts:end -->

## 用途

对带有随访时间与结局事件（OS、PFS、DFS、RFS 等）的临床队列进行生存分层比较（Kaplan-Meier 与 log-rank 检验）、风险因素回归建模（单因素/多因素 Cox 比例风险模型、LASSO-Cox 与多算法预后组合）、亚组效应量森林图汇总，以及时间依赖 ROC、列线图校准和临床决策曲线（DCA）验证。

## 适用

- 拥有清晰随访起点、随访时长 `time`、明确二分类删失/事件编码 `event`（0/1）及独立外部验证队列（或严格划分的训练/验证集）的临床研究。
- 验证比例风险（PH）假定基本成立的 Cox 回归；若存在交叉生存曲线（非比例风险），应改用 RMST 或分段分析。
- 评估连续生物标志物或风险评分在性别、年龄、临床分期等关键临床亚组中的效应稳健性。

## 不适用

- **忽略比例风险假定与竞争风险**：曲线明显交叉仍机械报告 log-rank P 值，或存在高比例竞争死亡事件却直接按普通删失处理。
- **训练集泄露与过拟合**：在全队列上搜索最佳 cutoff（`surv_cutpoint`）或用全队列做 LASSO 选基因后再在同批数据上宣称高 C-index / AUC。
- **混淆删失编码**：将 `1/2` 编码直接喂给期望 `0/1` 编码的模板或函数。

## 输入

读取标准输入接口 [[interfaces/survival-time-event-group|个体随访生存表]]（`time`、`event`、`group`），建模阶段通常还需结合样本临床协变量（分期、年龄、治疗方式）与规范化基因表达矩阵或风险评分。

## 怎么做

1. **随访数据清洗与划分**：统一随访时间单位与 `event`（0/1）编码；在特征筛选前严格锁定训练集与外部/留出验证集边界。
2. **单因素筛查与正则化建模**：在训练集内开展单因素 Cox 回归、LASSO-Cox 或多算法生存机器学习（如 RSF、SuperPC、StepCox）筛选特征并固定模型权重，冻结风险评分公式。
3. **独立队列分层与临床效用检验**：在验证集计算风险评分、绘制 KM 曲线与风险表，并用 Time-ROC、多因素 Cox（检验独立预后价值）、列线图校准曲线及 DCA 评估临床净获益。
4. **亚组异质性分析与输出**：在各临床亚组内分别拟合 Cox 模型并计算交互检验 P 值，汇总为 `subgroup-effect-table` 与 `candidate-biomarker-list`。

## 代码

本锚点页当前尚未封装统一可执行的本库分析模块（状态为 `not_run`）。多类经典生存与临床模型流程可参考已收录源码配方：
- KM 生存与两两/最佳切点比较：[[recipes/figureya-1survivalcurve-update]]、[[recipes/figureya-284pairwiselogrank]]、[[recipes/figureya-35batch-bestseparationv3-update]]
- 单/多因素 Cox 与亚组森林图：[[recipes/figureya-47hrtable]]、[[recipes/figureya-66univariatecox]]、[[recipes/figureya-90subgroup]]
- LASSO-Cox、多算法组合、Time-ROC、列线图与 DCA：[[recipes/figureya-31lasso-update]]、[[recipes/figureya-293machinelearning]]、[[recipes/figureya-85timeroc]]、[[recipes/figureya-30nomogram-update]]、[[recipes/figureya-33dca-update]]

## 输出

- [[interfaces/subgroup-effect-table|亚组效应量汇总表]]：含 `label`、`estimate`、`lower`、`upper`、`n`、`percent`、`p`。
- [[interfaces/candidate-biomarker-list|多算法筛选候选特征基因表]]：含 `gene`、`source_module`、`selection_methods`、`importance_score`。

## 知识关联检查

已核对关联模板 [[templates/km-survival-curve]] 与 [[templates/subgroup-hazard-forest]]：
- `km-survival-curve` 读取 `survival-time-event-group`（位于本方法 `inputs` 而非 `outputs`），故严格登记为 `adaptable`（经分析阶段完成分层并导出规范 0/1 随访分组表后接入，不可误标为 `direct`）。
- `subgroup-hazard-forest` 读取 `subgroup-effect-table`（位于本方法 `outputs`），契约直接对齐，故登记为 `direct`（当前 `verification.state: not_run`，尚未执行真实课题分析→出图联调）。

## 使用记录

<!-- user:start -->
<!-- user:end -->
