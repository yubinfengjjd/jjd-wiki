---
type: method
id: shap-explanation
title: 机器学习模型 + SHAP 解释
status: ready
tags:
- 模型解释
- SHAP
- 可换模型
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
favorite: false
---
# 机器学习模型 + SHAP 解释

<!-- facts:start -->
- 来源：[[layouts/2026-08-17-shap-feature-mechanism__fig01-shap-a-f|Fig. 4 期刊配图：基于SHAP的特征驱动机制条形图、蜂群图与环形贡献配图形式]]
- 许可证：仅供个人研究参考
- 引用：Lundberg & Lee. A Unified Approach to Interpreting Model Predictions. NeurIPS, 2017.；Lundberg et al. From local explanations to global understanding with explainable AI for trees. Nature Machine Intelligence, 2020.
- 标签：模型解释、SHAP、可换模型
- 输入接口：未声明
- 输出接口：[[interfaces/shap-summary|SHAP 特征贡献汇总表]] · [[interfaces/shap-samples|SHAP 逐样本值表]]
- 可接的图：[[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar|SHAP 条形图（含环形 inset）]]（ready） · [[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm|SHAP 蜂群图]]（ready） · [[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--radial-bar|SHAP 环形贡献图]]（ready）
- 可接的下一步方法：暂无
- 代码模板：[methods/shap-explanation/code/shap_explain.py](/files/wiki/methods/shap-explanation/code/shap_explain.py)
<!-- facts:end -->

## 用途

训练一个监督学习模型，用 SHAP 把每个预测拆成各特征的贡献，整理成两张表交给 SHAP 图模板：一张按特征汇总（平均绝对 SHAP 与占比），一张逐样本（带符号的贡献值与用于着色的特征取值）。

SHAP 解释的是**训练好的模型**怎么用这些特征做预测，不区分模型来自哪个库。同一个方法换 `MODEL` 就换模型；图模板读的是表，与模型无关。

## 适用

- 任务：回归或二分类，表格数据，特征是数值列（类别列先编码）。
- 样本：足以划出有代表性的测试集；模型本身要拟合得比基线好，否则解释没有意义。
- 想要的东西：哪些特征在推动预测、方向如何、个体差异多大，而不是因果。
- 模型选择：
  - 树模型（XGBoost、LightGBM、CatBoost、随机森林、GBDT、ExtraTrees）：`TreeExplainer`，快且精确，优先用。
  - 线性模型（逻辑回归、线性回归、LASSO）：`LinearExplainer`，系数直接对应贡献。
  - 其他模型（SVM、MLP 等）：`shap.Explainer` 通用解释器，较慢，解释样本控制在几百个。

## 不适用

- 分类里多分类：每个类别各有一套 SHAP，图模板一次只能画一个类别；本模板按二分类写，多分类需取某一类。
- 含大量缺失值、未编码类别列、时间序列或同一患者多行的数据：先做相应处理或分组划分，不能直接套本脚本的随机划分。
- 相关很强的特征：归因会在它们之间分摊，排名不能解读成“哪个变量真正起作用”。
- 因果结论、诊断价值、外部验证：SHAP 都不提供。

## 输入

`data.csv`：一行一个样本，数值特征列 + 目标列。`TARGET` 指定目标列名；分类目标可以是 0/1 或字符串标签（脚本按字母序编码）。

## 怎么做

1. 复制 `code/shap_explain.py` 到课题目录，改文件开头“要改的”一节：`DATA`、`TARGET`、`TASK`、`MODEL`，需要时加 `MODEL_PARAMS`。
2. 运行，先看打印的测试集表现：
   - 回归看 R²、RMSE 与括号里的均值基线 RMSE；R² 明显为负或 RMSE 高于基线，说明模型没学到东西，解释不可信，先改模型或特征。
   - 分类看 AUROC 与准确率；AUROC 接近 0.5 同样不能解释。
3. 需要调参时改 `MODEL_PARAMS`（如树深、树数量）；本脚本不含网格搜索，调参在课题里另行进行，调好后把参数填进来再重跑。
4. 看 `TOP_N` 与 `MIN_MEAN_ABS_SHAP` 是否合适：特征多时先保留 15–20 个给图模板。

## 代码

`code/shap_explain.py`：完整可运行的单文件模板，参数集中在开头，已在本机用四类模型实测：

| MODEL | 解释器 | 任务 | 测试集表现 |
|---|---|---|---|
| `xgboost` | TreeExplainer | 回归（sklearn 糖尿病数据，442×10） | R² 0.35，RMSE 59.3（均值基线 73.7） |
| `random_forest` | TreeExplainer | 二分类（合成 400×8） | AUROC 0.94 |
| `logistic` | LinearExplainer | 二分类（同一份） | AUROC 0.78 |
| `svm` | shap.Explainer | 二分类（同一份） | 约 3 秒/百样本 |

依赖：`pandas`、`numpy`、`scipy`、`shap`、`scikit-learn`；`xgboost` / `lightgbm` / `catboost` 按 `MODEL` 需要。脚本不装包，缺包时在课题环境里装。

原始来源：本库的 SHAP 组图（[[layouts/2026-08-17-shap-feature-mechanism__fig01-shap-a-f]]）来自一篇公众号帖子，其附带代码是 XGBoost + 网格搜索的示例，归档在 `source/`。本方法把它推广到任意模型：网格搜索属于调参步骤，交给了课题自己的流程。

## 输出

`analysis/shap-summary.csv` → [[interfaces/shap-summary|SHAP 特征贡献汇总表]]：

| feature | shap | percent |
|---|---|---|
| 特征名 | 解释样本上的平均绝对 SHAP | 占全部特征平均绝对 SHAP 之和的百分比（筛选前计算） |

`analysis/shap-samples.csv` → [[interfaces/shap-samples|SHAP 逐样本值表]]：`feature`、带符号 `shap`、`feature_value`（在解释样本内按特征最小–最大缩放到 0–1，常数特征取 0）。

两张表只含 `TOP_N` 与 `MIN_MEAN_ABS_SHAP` 筛选后保留的特征；百分比不重新归一化。输出目录可直接交给图模板：`render <模板 id> --data <课题>\analysis --out <课题>\figures\<名>`。

## 使用记录

## 知识关联检查

[[methods/regression-resampling-evaluation|回归模型的重采样评估与折外预测]] 与本方法互补：前者描述预测性能和划分敏感性，本方法描述训练模型的特征归因。SHAP图不能替代预测评估，回归指标表也不能直接作为SHAP输入；真实课题需要另外提供同一模型、特征数据及明确的验证边界。链接是有条件的方法参考，不是接口串联。既有三个SHAP模板继续按各自输入接口和状态使用。

<!-- user:start -->
<!-- user:end -->
