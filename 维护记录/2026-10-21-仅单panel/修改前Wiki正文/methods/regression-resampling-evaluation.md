---
type: method
id: regression-resampling-evaluation
title: 回归模型的重采样评估与折外预测
status: ready
tags:
- 回归评估
- 交叉验证
- 模型比较
- 折外预测
inputs:
- regression-predictions
outputs:
- regression-fold-metrics
source:
  kind: written
license: none
cite:
- 原帖：Python机器学习AI，2026-10-19。https://mp.weixin.qq.com/s/LDPZ8guXNKnSRtjZC2YbNg
- 'scikit-learn: Cross-validation: evaluating estimator performance. https://scikit-learn.org/stable/modules/cross_validation.html'
- 'scikit-learn: Nested versus non-nested cross-validation. https://scikit-learn.org/stable/auto_examples/model_selection/plot_nested_cross_validation_iris.html'
- 'scikit-learn: Common pitfalls and recommended practices. https://scikit-learn.org/stable/common_pitfalls.html'
favorite: false
---
# 回归模型的重采样评估与折外预测

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：仅供个人研究参考
- 引用：原帖：Python机器学习AI，2026-10-19。https://mp.weixin.qq.com/s/LDPZ8guXNKnSRtjZC2YbNg；scikit-learn: Cross-validation: evaluating estimator performance. https://scikit-learn.org/stable/modules/cross_validation.html；scikit-learn: Nested versus non-nested cross-validation. https://scikit-learn.org/stable/auto_examples/model_selection/plot_nested_cross_validation_iris.html；scikit-learn: Common pitfalls and recommended practices. https://scikit-learn.org/stable/common_pitfalls.html
- 标签：回归评估、交叉验证、模型比较、折外预测
- 输入接口：[[interfaces/regression-predictions|回归模型逐样本验证预测表]]
- 输出接口：[[interfaces/regression-fold-metrics|回归模型逐折评估指标表]]
- 可接的图：暂无
- 可接的下一步方法：暂无
- 代码模板：[methods/regression-resampling-evaluation/code/__pycache__/summarize_predictions.cpython-312.pyc](/files/wiki/methods/regression-resampling-evaluation/code/__pycache__/summarize_predictions.cpython-312.pyc) · [methods/regression-resampling-evaluation/code/summarize_predictions.py](/files/wiki/methods/regression-resampling-evaluation/code/summarize_predictions.py)
<!-- facts:end -->

## 用途

汇总回归模型在预先规定的数据划分下的验证预测，生成逐折 RMSE、MAE、R²、Pearson r，用密度散点查看预测偏差，用箱线图描述划分间性能波动。适用于任意能导出预测的模型，不绑定 XGBoost、Python 或 R。

本页依据原帖主题及官方文档重新编写，不代表原帖的缺失函数已恢复，也不复现其数值。原帖明确使用模拟数据；文献的重复随机划分与帖子改用的 K 折是两种设计，必须分别记录。

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

验证范围：见同目录 `verification.md`；合成输入检查只验证指标与表格处理，不证明任何真实模型有效。

## 输出

`analysis/regression-fold-metrics.csv` → [[interfaces/regression-fold-metrics|回归模型逐折评估指标表]]，一行代表模型在某次重复的一个验证折/留出划分，列为 `model,repeat,fold,n_test,RMSE,MAE,R2,r,split_design`。

另输出 `regression-metric-summary.csv`，按模型列出逐折指标算术平均值与样本标准差（ddof=1），仅作描述。单折时 SD 缺失；不同折大小不一致时，此算术均值不等于按样本加权或汇总 OOF 的指标。

密度散点读取输入表；指标箱线图读取输出表。已复刻并收录两张组图：[[layouts/2026-10-19-regression-stability__fig01-density-grid|六模型密度散点]]与[[layouts/2026-10-19-regression-stability__fig02-metric-boxplots|三指标箱线图]]。两者均待作者签核；尚未拆出ready图模板。方法笔记本身仍为draft，等待作者确认。
## 使用记录

## 知识关联检查

参考单panel图样：[[layouts/2026-10-19-regression-stability__fig03-density-panel|密度散点与边缘分布]]、[[layouts/2026-10-19-regression-stability__fig04-boxplot-panel|箱线散点与均值]]。均为估读图形/待签核来源，并非已拆出的可调用模板；逐样本预测与逐折指标分别供两类画法使用，不把估读点当真实样本。

与既有 [[methods/shap-explanation|机器学习模型 + SHAP 解释]] 互补：在同一课题中，评估描述模型预测表现，SHAP描述既定模型的特征归因。关联前需核对同一目标/模型与数据划分；性能指标表不包含SHAP所需的模型和特征，不能据此直接串联。此处是普通方法关系，不新增数据流箭头或声称科学方案已通过。

迁移笔记 [[methods/paired-reference-visual-comparison]] 与 [[methods/repeated-benchmark-distribution]] 分别探索参考解比较和重复运行分布；输入条件不同，先保留文字关联，不自动补算法。

<!-- user:start -->
<!-- user:end -->
