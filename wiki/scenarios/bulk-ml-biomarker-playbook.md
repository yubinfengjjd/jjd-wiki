---
type: scenario
id: bulk-ml-biomarker-playbook
title: Bulk 转录组与机器学习临床标志物决策树（Playbook）
picks:
- id: recipes/figureya-203combat
  note: Step 1：多队列去批次（ComBat）与 PCA 检查
- id: recipes/figureya-59plus-geo2deg
  note: Step 2A：Bulk 差异表达分析（limma/DESeq2）
- id: recipes/figureya-17wgcna-heatmap
  note: Step 2B：WGCNA 共表达模块筛选
- id: templates/bulk-de-volcano
  note: Bulk 分级着色火山图（L2）
- id: templates/set-venn
  note: Step 3：DEG × WGCNA × 主题基因集 Venn 交集（L2）
- id: recipes/figureya-293plus-binaryclassificationml
  note: Step 4：101 种机器学习算法组合筛选与多队列评估
- id: methods/shap-explanation
  note: Step 5：SHAP 全局与个体可解释性分析
- id: templates/shap-beeswarm
  note: SHAP 蜂群图（L2）
- id: templates/km-survival-curve
  note: Step 6：高低风险组 KM 生存曲线（L2）
- id: recipes/figureya-30nomogram-update
  note: 临床列线图、校准曲线与 DCA 净获益
tags:
- machine-learning
- transcriptomics
- survival-analysis
- diagnostic-roc
keywords:
- Bulk 转录组
- 101种机器学习
- LASSO
- WGCNA
- SHAP
- KM 曲线
- Nomogram
- Time-ROC
- 免疫浸润
summary: Bulk 转录组与临床队列标志物全流程决策树：从多队列批次校正、DEG/WGCNA 交集筛选、101 种机器学习组合建模到 SHAP 解释、预后验证与免疫药敏分析。
steps:
- id: bulk-step-1-preprocess
  step: 1
  title: 多队列预处理与 ComBat 去批次
  when: 合并多个 GEO/TCGA 表达矩阵用于训练与外部验证时
  inputs: []
  outputs:
  - deg-result-table
  templates:
  - recipes/figureya-203combat
  - recipes/figureya-38pca
  - recipes/figureya-23count2tpm
  next_steps:
  - bulk-step-2-deg-wgcna
- id: bulk-step-2-deg-wgcna
  step: 2
  title: 差异表达分析与 WGCNA 共表达模块
  method_id: differential-expression
  when: 识别疾病 vs 对照显著差异基因，并结合 WGCNA 提取表型强相关模块时
  inputs: []
  outputs:
  - deg-result-table
  interface: deg-result-table
  templates:
  - recipes/figureya-59plus-geo2deg
  - recipes/figureya-17wgcna-heatmap
  - templates/bulk-de-volcano
  - recipes/figureya-60gsea-clusterprofilerv2
  next_steps:
  - bulk-step-3-intersection
- id: bulk-step-3-intersection
  step: 3
  title: 候选基因交集与 PPI 网络收敛
  when: 将 DEG、WGCNA 模块基因与主题基因集取交集，收窄候选标志物集合时
  inputs:
  - deg-result-table
  outputs:
  - candidate-biomarker-list
  interface: candidate-biomarker-list
  templates:
  - recipes/figureya-112venn
  - recipes/figureya-53ppimodule
  - templates/set-venn
  - templates/set-upset
  next_steps:
  - bulk-step-4-ml
- id: bulk-step-4-ml
  step: 4
  title: 特征筛选与 101 种机器学习组合建模
  method_id: regression-resampling-evaluation
  when: 开展 LASSO + SVM-RFE + Boruta + 随机森林或 101 种 ML 组合训练与交叉验证时
  inputs:
  - candidate-biomarker-list
  outputs:
  - model-prediction-shap
  interface: model-prediction-shap
  templates:
  - recipes/figureya-293plus-binaryclassificationml
  - recipes/figureya-293machinelearning
  - recipes/figureya-31lasso-update
  - recipes/figureya-221tenfoldrf
  next_steps:
  - bulk-step-5-shap
  - bulk-step-6-clinical-eval
- id: bulk-step-5-shap
  step: 5
  title: 基于 SHAP 的黑箱模型可解释性拆解
  method_id: shap-explanation
  when: 需要量化最优模型中每个特征基因对预测风险的正/负向边际贡献时
  inputs:
  - model-prediction-shap
  outputs:
  - shap-samples
  interface: shap-samples
  templates:
  - methods/shap-explanation
  - templates/shap-beeswarm
  - templates/shap-importance-bar
  - templates/shap-radial-bar
  next_steps:
  - bulk-step-6-clinical-eval
- id: bulk-step-6-clinical-eval
  step: 6
  title: 临床评估（KM/ROC/Nomogram/DCA）与免疫药敏
  when: 冻结模型并在独立队列评估区分度、校准度、临床净获益及免疫微环境相关性时
  inputs:
  - model-prediction-shap
  outputs:
  - model-prediction-shap
  interface: model-prediction-shap
  templates:
  - templates/km-survival-curve
  - templates/subgroup-hazard-forest
  - recipes/figureya-85timeroc
  - recipes/figureya-30nomogram-update
  - recipes/figureya-33dca-update
  - recipes/figureya-56immune-inflitrationv3
  - recipes/figureya-212drugtargetv2
  next_steps: []
---

# Bulk 转录组与机器学习临床标志物决策树（Playbook）

## 什么时候用

- 手头有 TCGA 或 GEO Bulk 转录组队列（含二分类诊断标签或随访生存结局），希望筛选高稳健性的诊断/预后生物标志物。
- 需要严格隔离训练集特征筛选与独立外部验证集评估，避免数据泄漏。

## 首选组合

<!-- facts:start -->
| 条目 | 级别 | 状态 | 说明 |
|---|---|---|---|
| [[recipes/figureya-203combat|跨平台表达谱批次校正]] | L1 | draft · 运行 fail | Step 1：多队列去批次（ComBat）与 PCA 检查 |
| [[recipes/figureya-59plus-geo2deg|GEO芯片差异表达与火山图]] | L1 | ready · 运行 pass | Step 2A：Bulk 差异表达分析（limma/DESeq2） |
| [[recipes/figureya-17wgcna-heatmap|WGCNA模块基因表达热图]] | L1 | ready · 运行 pass | Step 2B：WGCNA 共表达模块筛选 |
| [[templates/bulk-de-volcano|bulk 差异火山图（分级着色）]] | L2 | ready | Bulk 分级着色火山图（L2） |
| [[templates/set-venn|多集合交集维恩图]] | L2 | ready · 可用 | Step 3：DEG × WGCNA × 主题基因集 Venn 交集（L2） |
| [[recipes/figureya-293plus-binaryclassificationml|多算法二分类模型评估筛选]] | L1 | draft · 运行 fail | Step 4：101 种机器学习算法组合筛选与多队列评估 |
| [[methods/shap-explanation|基于 SHAP 的模型解释]] | L2 | ready · 可用 | Step 5：SHAP 全局与个体可解释性分析 |
| [[templates/shap-beeswarm|SHAP 蜂群图]] | L2 | ready · 可用 | SHAP 蜂群图（L2） |
| [[templates/km-survival-curve|KM 生存曲线与风险表]] | L2 | ready · 可用 | Step 6：高低风险组 KM 生存曲线（L2） |
| [[recipes/figureya-30nomogram-update|Cox/Logistic 列线图与校准曲线]] | L1 | ready · 运行 pass | 临床列线图、校准曲线与 DCA 净获益 |
<!-- facts:end -->

## 步进决策树（走一步看一步）

| 阶段 | 当前目标 | 关键决策依据（When） | 标准中间表 | 推荐模版与配方 |
|---|---|---|---|---|
| **Step 1** | 表达标准化与多队列去批次 | 跨平台/跨批次表达量分布存在偏移 | — | [[recipes/figureya-203combat]] · [[recipes/figureya-23count2tpm]] |
| **Step 2** | 差异表达与共表达网络 | 筛选显著 DEG 并用 WGCNA 锁定关键临床表型模块 | `deg-result-table` | [[recipes/figureya-59plus-geo2deg]] · [[recipes/figureya-17wgcna-heatmap]] · [[templates/bulk-de-volcano]] |
| **Step 3** | 多来源交集收敛 | 对 DEG、WGCNA 模块基因及专题基因集取交集 | `candidate-biomarker-list` | [[templates/set-venn]] · [[templates/set-upset]] · [[recipes/figureya-53ppimodule]] |
| **Step 4** | 机器学习特征筛选与建模 | 仅在训练集内执行 LASSO/RF/SVM/101 种组合并冻结模型 | `model-prediction-shap` | [[recipes/figureya-293plus-binaryclassificationml]] · [[recipes/figureya-293machinelearning]] · [[recipes/figureya-31lasso-update]] |
| **Step 5** | 模型可解释性拆解 | 展示特征全局重要性及高/低表达对预测风险的方向 | `shap-samples` | [[methods/shap-explanation]] · [[templates/shap-beeswarm]] · [[templates/shap-importance-bar]] |
| **Step 6** | 临床效用与机制延展 | 外部队列 KM/Time-ROC/Nomogram/DCA + 免疫浸润与药物敏感性 | `model-prediction-shap` | [[templates/km-survival-curve]] · [[templates/subgroup-hazard-forest]] · [[recipes/figureya-30nomogram-update]] · [[recipes/figureya-56immune-inflitrationv3]] |

## 注意

- 严格禁止把外部验证集并入训练队列做 ComBat 去批次或监督特征筛选，否则 AUC/C-index 会因信息泄漏虚高。
- 二分类诊断校准优先用 Logistic 校准（[[recipes/figureya-138nicecalibration]]），生存预后模型请用时间依赖校准与 Time-ROC。

<!-- user:start -->
<!-- user:end -->
