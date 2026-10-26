---
type: method
id: regression-resampling-evaluation
title: 回归模型的重采样评估与折外预测
status: ready
tags:
- 机器学习
- 实验统计
inputs:
- regression-predictions
outputs:
- regression-fold-metrics
source:
  kind: written
  gallery_entry: 2026-10-19-regression-stability/figures/fig03-density-panel
license: none
cite:
- 原帖：Python机器学习AI，2026-10-19。https://mp.weixin.qq.com/s/LDPZ8guXNKnSRtjZC2YbNg
- 'scikit-learn: Cross-validation: evaluating estimator performance. https://scikit-learn.org/stable/modules/cross_validation.html'
- 'scikit-learn: Nested versus non-nested cross-validation. https://scikit-learn.org/stable/auto_examples/model_selection/plot_nested_cross_validation_iris.html'
- 'scikit-learn: Common pitfalls and recommended practices. https://scikit-learn.org/stable/common_pitfalls.html'
favorite: false
figure_relations:
- figure: templates/2026-10-19-regression-stability__fig03-density-panel--density-scatter
  compatibility: adaptable
  reason: 可用本绘图模板表达真实预测的配对分布，但需上游明确准备RGB/边缘表。
  prerequisites:
  - 连续结局且同一原始量纲；明确样本、模型、重复/折身份。
  - 需先确定密度/边缘分布策略与注释统计，不用估读颜色倒推真实频数。
  adaptation: 课题内准备坐标/RGB/边缘条及真实注释；不从估读点重建频数，密度算法仍需确认。
  evidence:
  - methods/regression-resampling-evaluation.md#输入
  - layouts/2026-10-19-regression-stability__fig03-density-panel.md#适用
  - templates/2026-10-19-regression-stability__fig03-density-panel--density-scatter/spec.json
  - templates/2026-10-19-regression-stability__fig03-density-panel--density-scatter/verify/function-verification.json
  verification:
    state: not_run
    scope: 本轮只验证模板绘图与合成规模；未验证真实方法→准备表→出图流水线。
    evidence: []
- figure: templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot
  compatibility: adaptable
  reason: 逐折指标可用于该单指标分组分布，需上游按已确认规则准备同源点与箱线摘要。
  prerequisites:
  - 同一验证方案、指标定义与单位；明确折间相关性。
  - 按已确认的箱体/须/均值规则产生一致结果，横向抖动仅作展示。
  adaptation: 课题内选定指标、明确采样单位/须规则、整理同源points/summaries；不自动新写统计算法。
  evidence:
  - methods/regression-resampling-evaluation.md#输出
  - layouts/2026-10-19-regression-stability__fig04-boxplot-panel.md#适用
  - templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot/spec.json
  - templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot/verify/function-verification.json
  verification:
    state: not_run
    scope: 本轮只验证模板绘图与合成规模；未验证真实方法→准备表→出图流水线。
    evidence: []
keywords:
- regression
- cross-validation
- 回归评估
- 模型比较
- 折外预测
- 交叉验证
method_kind: analysis
purposes:
- 模型评价
summary: 汇总已有折外回归预测，计算逐折 RMSE/MAE/R2/r；不训练模型、不生成重采样。
data_contract:
  input: 折外预测表 regression-predictions：sample_id/model/repeat/fold/y_true/y_pred/split_design；一行一个验证样本。
  output: 逐折指标表：model/repeat/fold/n_test/RMSE/MAE/R2/r/split_design；另可输出描述性均值/SD。
implementations:
- id: summarize-predictions
  title: 折外预测指标汇总
  language: Python
  entrypoint: code/summarize_predictions.py:summarize
  dependencies:
  - numpy
  - pandas
  verification: verification/summarize-predictions.json
---
# 回归模型的重采样评估与折外预测

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：仅供个人研究参考
- 引用：原帖：Python机器学习AI，2026-10-19。https://mp.weixin.qq.com/s/LDPZ8guXNKnSRtjZC2YbNg；scikit-learn: Cross-validation: evaluating estimator performance. https://scikit-learn.org/stable/modules/cross_validation.html；scikit-learn: Nested versus non-nested cross-validation. https://scikit-learn.org/stable/auto_examples/model_selection/plot_nested_cross_validation_iris.html；scikit-learn: Common pitfalls and recommended practices. https://scikit-learn.org/stable/common_pitfalls.html
- 标签：机器学习、实验统计
- 分析用途：模型评价
- 输入接口：[[interfaces/regression-predictions|回归模型逐样本验证预测表]]
- 输出接口：[[interfaces/regression-fold-metrics|回归模型逐折评估指标表]]
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/regression-resampling-evaluation/code/summarize_predictions.py](/files/wiki/methods/regression-resampling-evaluation/code/summarize_predictions.py)

- 方法配图关系（语义审查）：
  - [[templates/2026-10-19-regression-stability__fig03-density-panel--density-scatter|密度散点与边缘分布]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：本轮只验证模板绘图与合成规模；未验证真实方法→准备表→出图流水线。
    - 依据：可用本绘图模板表达真实预测的配对分布，但需上游明确准备RGB/边缘表。；前提：连续结局且同一原始量纲；明确样本、模型、重复/折身份。；需先确定密度/边缘分布策略与注释统计，不用估读颜色倒推真实频数。；适配：课题内准备坐标/RGB/边缘条及真实注释；不从估读点重建频数，密度算法仍需确认。
    - 关系证据：methods/regression-resampling-evaluation.md#输入；layouts/2026-10-19-regression-stability__fig03-density-panel.md#适用；templates/2026-10-19-regression-stability__fig03-density-panel--density-scatter/spec.json；templates/2026-10-19-regression-stability__fig03-density-panel--density-scatter/verify/function-verification.json；运行证据：无
  - [[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：本轮只验证模板绘图与合成规模；未验证真实方法→准备表→出图流水线。
    - 依据：逐折指标可用于该单指标分组分布，需上游按已确认规则准备同源点与箱线摘要。；前提：同一验证方案、指标定义与单位；明确折间相关性。；按已确认的箱体/须/均值规则产生一致结果，横向抖动仅作展示。；适配：课题内选定指标、明确采样单位/须规则、整理同源points/summaries；不自动新写统计算法。
    - 关系证据：methods/regression-resampling-evaluation.md#输出；layouts/2026-10-19-regression-stability__fig04-boxplot-panel.md#适用；templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot/spec.json；templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot/verify/function-verification.json；运行证据：无
<!-- facts:end -->

## 用途

汇总回归模型在预先规定的数据划分下的验证预测，生成逐折 RMSE、MAE、R²、Pearson r，用密度散点查看预测偏差，用箱线图描述划分间性能波动。适用于任意能导出预测的模型，不绑定 XGBoost、Python 或 R。

## 原始实现与家族范围

本页依据原帖主题及官方文档重新编写，不代表原帖的缺失函数已恢复，也不复现其数值。原帖明确使用模拟数据；文献的重复随机划分与帖子改用的 K 折是两种设计，必须分别记录。

家族限定为连续结局预测模型的验证评估：可对不同模型沿用相同预测/指标定义，但训练、调参与验证划分仍在课题中实现。现有 `code/summarize_predictions.py` 只汇总已有验证预测，不包含原帖缺失的模型训练函数；其他模型或重采样分支不因写入家族说明就视为已实现或验证。



## 来源与实现选择

| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| 原帖回归 + 重采样示例 | 画廊 `2026-10-19-regression-stability/figures/fig03-density-panel`；原帖链接见 frontmatter | 训练、验证、绘图组合 | 原始材料只作来源；训练/重采样未在本库实现 |
| `summarize_predictions` | `code/summarize_predictions.py` | 已有折外预测表 → 逐折指标 | verified：手算指标、coverage、输入不变 |
| 训练/调参/验证划分 | 课题原有代码 | 模型与重采样 | 本库不训练、不重采样；不能由汇总脚本声称已完成 |
## 适用

- 连续结局、可追踪样本标识、明确验证设计的监督学习回归任务。
- 多模型在相同验证划分上比较；一行保存一个验证样本的真实值与预测值。
- 用于描述预测误差和划分敏感性；所有特征处理、模型选择都必须遵守训练/验证边界。

## 不适用

- 分类、存活结局或多输出回归不能直接套用这些指标。
- 患者多次测量、双眼、多中心或时间依赖数据，不能直接使用普通随机 K 折；应在课题环境中实施分组、中心留出或时间划分。
- 只知道每折均值而没有逐样本预测，不能补造散点；没有真实数据时只能制作明确标注的合成视觉示例。
- 箱体窄、相关性高、K 折标准差小，均不足以证明外部泛化、临床效用或因果机制。

## 输入

[[interfaces/regression-predictions|回归模型逐样本验证预测表]]：文件名 `regression-predictions.csv`，必需列为 `sample_id,model,repeat,fold,y_true,y_pred,split_design`。一行是一个样本在某模型、重复、验证折上的预测。标识须跨模型保持一致；同一标识的结局也须一致。

`split_design` 取 `kfold`、`repeated_kfold`、`group_kfold`、`time_series` 或 `repeated_holdout`。K 折每次重复中每个样本至多验证一次；重复留出中一个样本可多次出现，不能将汇总后的点数当作独立样本量。时间划分可能包含无法获得预测的初始训练窗口，应说明覆盖率。

## 怎么做

1. **先在课题里固定验证方案。** 独立样本可用 K 折；评估划分敏感性可用重复 K 折或重复留出。多模型复用完全相同的验证索引。随机种子固定并保留拆分清单；K 折并不会消除所有划分偏差，也不等于进行了 K 次独立实验。
2. **防止泄漏。** 标准化、缺失值填补、特征选择、过采样都只在当前训练折拟合，再应用于验证折；可用 Pipeline 包装。患者/中心不得跨越不应共享的边界。
3. **调参与评估分开。** 超参数已事先固定时可直接获得折外预测；需要调参时，在外层每个训练折里另做内层搜索，再预测外层验证折。不能在全开发集调好参数后，把同一批折的性能当作无偏评估。若有锁定的独立测试集，先完成开发流程与选择，最后一次评估测试集，不再反复据其结果选模型。
4. **导出真实验证预测。** 不用在全数据拟合的模型回代预测冒充 OOF。将外层验证预测整理为输入表；真实结局和预测保持原始量纲，记录每折样本数。训练步骤在课题自己的环境里完成；包缺失时列出包名交作者决定，不在知识库里安装。
5. **运行本页脚本。** 先复制到 `<课题>/scripts/`，设置输入/输出；如需验证 K 折全覆盖，提供预期样本清单。脚本检查同折重复样本、跨模型划分不一致和真实结局矛盾，计算逐折指标。它不能从预测表判断训练阶段是否泄漏，也不替代训练索引审计。
6. **检查结果可信度。** 与同一训练折拟合的简单均值/既有基线比较；若 R²普遍为负或 RMSE 不优于基线，先检查数据和流程。常量真实值时 R²未定义；真实值或预测为常量时相关系数未定义，保留缺失，不填成 0 或 1。不能用模型名判断优劣。
7. **出图并解释。** 散点加 1:1 参考线，拟合线仅作描述；KDE 色标表示局部密度而非未经定义的“频数”。多次重复的同一受试者点不独立。箱线图使用实际逐折值，不从期望均值补造；“均值±SD”是相关折分数的描述，不能直接当置信区间。逐折 R²的平均值通常不等于把全部 OOF 预测混合计算的 R²，图注须写清。

与原帖的处理差异：保留图形设计及验证评估主题；不沿用“彻底消除划分偏差”“箱体窄即可证明卓越泛化”等推论；不把同一 K 折用于调参与最终无偏估计；不把 r 高解释为预测校准良好。

## 代码

`code/summarize_predictions.py` 是本次新写的可复用指标汇总代码，依赖 `numpy`、`pandas`，不训练模型，也不联网。参数集中在文件开头：

| 参数 | 含义 |
|---|---|
| `INPUT` | 课题导出的 `regression-predictions.csv` |
| `OUTPUT` | 输出目录，通常为课题的 `analysis/` |
| `EXPECTED_IDS` | 可选样本清单 CSV，含 `sample_id`；K 折时用于检查每次重复全覆盖 |

训练及内层调参使用课题原有代码。Python 可用 scikit-learn 的 KFold/RepeatedKFold/GroupKFold/TimeSeriesSplit 与 Pipeline；R 可用相应重采样框架，最终导出相同接口。这里没有将原帖缺失的模型代码当成可运行实现。

验证：2026-10-23 用合成预测表检查手算 RMSE/MAE/R2/r、常数预测的 r 未定义、输入不变和完整 coverage 拒绝；收据为 `verification/summarize-predictions.json`。scope 仅指标与表格处理，不证明真实模型有效。

## 输出

`analysis/regression-fold-metrics.csv` → [[interfaces/regression-fold-metrics|回归模型逐折评估指标表]]，一行代表模型在某次重复的一个验证折/留出划分，列为 `model,repeat,fold,n_test,RMSE,MAE,R2,r,split_design`。

另输出 `regression-metric-summary.csv`，按模型列出逐折指标算术平均值与样本标准差（ddof=1），仅作描述。单折时 SD 缺失；不同折大小不一致时，此算术均值不等于按样本加权或汇总 OOF 的指标。

密度散点的模板读取 `render-scatter-rgb`/`render-marginal-bars`，需从 `regression-predictions` 整理；指标箱线图的模板读取 `render-category-points`/`render-box-summaries`，需从逐折指标整理；不是直接读取原始输入/输出表。已复刻并收录两个代表单 panel：[[layouts/2026-10-19-regression-stability__fig03-density-panel|密度散点与边缘分布]]与[[layouts/2026-10-19-regression-stability__fig04-boxplot-panel|箱线散点与均值]]。两张来源已签核、关联模板已可用；本方法当前为已确认笔记，现存脚本仅汇总预测，不提供模型训练。2026-10-21 作者再次要求处理待办后，新建了密度与箱线单panel模板并完成回放，作者随后明确确认，两个模板已通过mark-ready标为可用。
## 使用记录

## 知识关联检查

本方法对应两种单panel画法；关系主记录指向两个 ready 模板，来源 layout 只作 evidence/溯源，前端按模板展示。数据来源与准备步骤不同，不把两张图都误写为直接读取逐折指标。

| 图模板 | 模板读取接口 | 对应数据 | 仍需适配 |
|---|---|---|---|
| [[templates/2026-10-19-regression-stability__fig03-density-panel--density-scatter|密度散点与边缘分布]] | `render-scatter-rgb`、`render-marginal-bars` | 方法输入中的逐样本真实值/验证预测 | 明确颜色密度含义与算法、边缘分布及真实注释后准备绘图表；不得沿用估读颜色推断真实频数。 |
| [[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]] | `render-category-points`、`render-box-summaries` | 方法输出中的逐折指标，选择一个实际指标 | 核对验证单位和折间相关性；明确箱体/须规则，准备同源点和摘要，抖动只作展示。 |

两张绘图模板已由作者确认可用，估读/合成示例仅说明画法；真实方法→准备表→绘图的课题流水线尚未联调。可查看模板代码并复制到课题，缺上游算法仍需先与作者确认，不能以格式适配名义补写。

已双向核查现存方法、来源、模板及接口。与 [[methods/shap-explanation|机器学习模型 + SHAP 解释]] 互补：本方法评估预测表现，SHAP解释既定模型的特征归因。预测/指标表不包含SHAP所需模型、特征与背景，因此不新增虚假的数据流连接；SHAP三图也不据此被标成性能评估图。

两篇旧宽泛迁移笔记 配对值迁移（已归档）（条目已删除）、基准分布迁移（已归档）（条目已删除） 保留历史且不再推荐。有依据内容限定在本家族：配对与量纲一致、重复/折身份可追踪、点与摘要同源。方法家族不推广成参考解、耗时/内存等其他分析。

<!-- user:start -->
<!-- user:end -->
