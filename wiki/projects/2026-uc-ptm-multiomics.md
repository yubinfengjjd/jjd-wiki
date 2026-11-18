---
type: project
slug: 2026-uc-ptm-multiomics
title: 溃疡性结肠炎 20 种翻译后修饰（PTM）多组学挖掘
playbook: geneset-theme-playbook
status: active
templates:
- 2026-10-22-scp-example__fig01-volcano--volcano
- 2026-10-22-scp-example__fig12-venn--venn
- 2026-10-22-scp-example__fig16-cell-density--ridge
- figureya-1survivalcurve-update--km-curve
- 2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm
methods:
- differential-expression
- gene-set-scoring
- cell-type-annotation
- shap-explanation
- regression-resampling-evaluation
summary: 溃疡性结肠炎（UC）单细胞与 Bulk 队列联合的 20 种 PTM 修饰基因集筛选、101 种机器学习诊断建模与 SHAP 可解释性记录。
---
# 溃疡性结肠炎 20 种翻译后修饰（PTM）多组学挖掘

- **所属主线**：[[scenarios/geneset-theme-playbook|特定修饰与主题基因集挖掘决策树]] · [[scenarios/sc-bulk-integration-playbook|单细胞 × Bulk 多组学联合决策树]]
- **课题来源清单**：[[methods/uc-ptm-source-catalog|UC-20种修饰来源清单]] · [[methods/uc-ptm-workflow|UC-20种修饰流程]]

## 步进记录

### Step 1：UC Bulk 队列预处理、差异表达与 20 种 PTM 基因集筛选

- **【所用模版】**：[[recipes/figureya-203combat]] + [[methods/differential-expression]] + [[templates/2026-10-22-scp-example__fig01-volcano--volcano]] + [[templates/2026-10-22-scp-example__fig12-venn--venn]]
- **【观察结果与排坑】**：多个 GEO 肠黏膜队列按训练/独立验证集严格拆分后，仅在训练集做 ComBat 校验与 DEG+WGCNA 交集，规避验证集信息泄漏；筛选出与活动性 UC 强相关的 PTM 修饰候选特征。
- **【触发下一步】**：使用 [[methods/gene-set-scoring]] 在单细胞图谱定位高 PTM 活性上皮/免疫细胞亚群（接口 `pathway-score-table`）。

### Step 2：单细胞 PTM 活性定位与跨组学候选标志物收敛

- **【所用模版】**：[[methods/cell-type-annotation]] + [[methods/gene-set-scoring]] + [[templates/2026-10-22-scp-example__fig16-cell-density--ridge]]
- **【观察结果与排坑】**：单细胞多算法打分锁定炎症上皮与巨噬细胞为关键 PTM 富集细胞群；将亚群 Marker 与 Bulk 交集，输出标准中间表 `candidate-biomarker-list`。
- **【触发下一步】**：进入【101 种机器学习算法组合建模】与【SHAP 特征解释】（接口 `candidate-biomarker-list` -> `model-prediction-shap`）。

### Step 3：101 种机器学习建模、SHAP 可解释性与外部队列验证

- **【所用模版】**：[[recipes/figureya-293plus-binaryclassificationml]] + [[methods/shap-explanation]] + [[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm]] + [[templates/figureya-1survivalcurve-update--km-curve]]
- **【观察结果与排坑】**：101 种组合中 Stepglm+RF/Lasso+GBM 跨队列验证 AUC 表现稳健；SHAP 蜂群图直观揭示核心修饰基因正向驱动 UC 风险得分。
- **【触发下一步】**：冻结最终模型参数，输出外部队列校准曲线与免疫浸润相关性图表用于论文主图拼版。
