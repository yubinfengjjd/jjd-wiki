---
type: scenario
id: sc-bulk-integration-playbook
title: 单细胞 × Bulk 多组学联合决策树（Playbook）
picks:
- id: methods/cell-type-annotation
  note: Step 1：单细胞注释与关键病变亚群锁定
- id: methods/differential-expression
  note: Step 2：提取关键亚群特异 Marker 与拟时序分支基因
- id: recipes/figureya-112venn
  note: Step 3：单细胞亚群 Marker × Bulk DEG/WGCNA 交集筛选
- id: recipes/figureya-71ssgsea-update
  note: Step 4A：ssGSEA / 反卷积将单细胞亚群丰度投射至 Bulk 队列
- id: recipes/figureya-293plus-binaryclassificationml
  note: Step 4B：联合核心基因构建临床诊断/预后机器学习模型
- id: templates/km-survival-curve
  note: Step 5：投射亚群评分/风险得分的 KM 生存分层（L2）
- id: recipes/figureya-300pancancor
  note: Step 6：关键靶基因泛癌/免疫微环境相关性验证
tags:
- multi-omics
- single-cell
- transcriptomics
- machine-learning
keywords:
- 单细胞与Bulk联合
- 反卷积
- 投射队列
- 细胞丰度预后
- 跨组学验证
summary: 连接单细胞机制发现与大样本 Bulk 临床队列验证的联合决策树：从单细胞关键亚群 Marker/轨迹基因出发，经交集收敛、Bulk 投射/反卷积与机器学习建模完成临床转化验证。
steps:
- id: scbulk-step-1-anchor
  step: 1
  title: 单细胞图谱锁定疾病关联关键亚群
  method_id: cell-type-annotation
  when: 通过单细胞比例 Ro/e 或主题基因集打分锁定 1-2 个核心病变亚群时
  inputs: []
  outputs:
  - scrna-annotated-cells
  interface: scrna-annotated-cells
  templates:
  - methods/cell-type-annotation
  - templates/cell-prop-flow-bar
  next_steps:
  - scbulk-step-2-signature
- id: scbulk-step-2-signature
  step: 2
  title: 提取亚群特异 Marker 与动态驱动基因集
  method_id: differential-expression
  when: 提取单细胞核心亚群高表达特异 Marker、高/低活差异基因或拟时序终末基因时
  inputs:
  - scrna-annotated-cells
  outputs:
  - deg-result-table
  interface: deg-result-table
  templates:
  - methods/differential-expression
  - methods/dynamic-feature-analysis
  - templates/marker-bubble-dotplot
  next_steps:
  - scbulk-step-3-converge
- id: scbulk-step-3-converge
  step: 3
  title: 单细胞核心基因与 Bulk 差异/模块基因取交集
  when: 将单细胞候选基因与 Bulk DEG/WGCNA 交叉验证，选出跨组学稳定改变的核心基因时
  inputs:
  - deg-result-table
  outputs:
  - candidate-biomarker-list
  interface: candidate-biomarker-list
  templates:
  - recipes/figureya-112venn
  - templates/set-venn
  - templates/set-upset
  next_steps:
  - scbulk-step-4-project
- id: scbulk-step-4-project
  step: 4
  title: Bulk 队列亚群丰度投射与临床建模
  method_id: regression-resampling-evaluation
  when: 用 ssGSEA 评估单细胞亚群特征在 Bulk 的浸润丰度，或训练多队列预后/诊断模型时
  inputs:
  - candidate-biomarker-list
  outputs:
  - model-prediction-shap
  interface: model-prediction-shap
  templates:
  - recipes/figureya-71ssgsea-update
  - recipes/figureya-56immune-inflitrationv3
  - recipes/figureya-293plus-binaryclassificationml
  - methods/shap-explanation
  next_steps:
  - scbulk-step-5-validate
- id: scbulk-step-5-validate
  step: 5
  title: 外部临床队列生存验证与微环境关联
  when: 在独立验证集展示投射亚群/风险模型的 KM 分层、Time-ROC 及与免疫细胞相关性时
  inputs:
  - model-prediction-shap
  outputs:
  - model-prediction-shap
  interface: model-prediction-shap
  templates:
  - templates/km-survival-curve
  - templates/subgroup-hazard-forest
  - recipes/figureya-85timeroc
  - recipes/figureya-228linkcor
  next_steps: []
---

# 单细胞 × Bulk 多组学联合决策树（Playbook）

## 什么时候用

- 单细胞数据样本量通常有限（几例到十几例），需要借助大样本 Bulk 临床队列（TCGA / GEO）验证发现的细胞亚群和基因是否具有人群稳健性与临床预后价值。
- 既支持“亚群基因集 ssGSEA 投射预后”，也支持“跨组学交集基因机器学习建模”。

## 首选组合

<!-- facts:start -->
| 条目 | 级别 | 状态 | 说明 |
|---|---|---|---|
| [[methods/cell-type-annotation|细胞类型注释]] | L2 | ready · 可用 | Step 1：单细胞注释与关键病变亚群锁定 |
| [[methods/differential-expression|差异表达分析]] | note | ready | Step 2：提取关键亚群特异 Marker 与拟时序分支基因 |
| [[recipes/figureya-112venn|四组韦恩图占比渐变填色]] | L1 | ready · 运行 pass | Step 3：单细胞亚群 Marker × Bulk DEG/WGCNA 交集筛选 |
| [[recipes/figureya-71ssgsea-update|免疫浸润ssGSEA注释热图]] | L1 | draft · 运行 fail | Step 4A：ssGSEA / 反卷积将单细胞亚群丰度投射至 Bulk 队列 |
| [[recipes/figureya-293plus-binaryclassificationml|多算法二分类模型评估筛选]] | L1 | draft · 运行 fail | Step 4B：联合核心基因构建临床诊断/预后机器学习模型 |
| [[templates/km-survival-curve|KM 生存曲线与风险表]] | L2 | ready · 可用 | Step 5：投射亚群评分/风险得分的 KM 生存分层（L2） |
| [[recipes/figureya-300pancancor|泛癌签名得分相关散点图]] | L1 | draft · 运行 fail | Step 6：关键靶基因泛癌/免疫微环境相关性验证 |
<!-- facts:end -->

## 步进决策树（走一步看一步）

| 阶段 | 跨组学桥接动作 | 判断依据 | 标准中间表 | 推荐模版与配方 |
|---|---|---|---|---|
| **Step 1** | 单细胞锁定靶亚群 | 疾病组比例显著升高（Ro/e > 1）或主题打分最高 | `scrna-annotated-cells` | [[methods/cell-type-annotation]] · [[templates/cell-prop-flow-bar]] |
| **Step 2** | 提取亚群分子特征 | 筛选亚群高特异 Marker（`pct.1` 高、`pct.2` 低）或轨迹基因 | `deg-result-table` | [[methods/differential-expression]] · [[methods/dynamic-feature-analysis]] |
| **Step 3** | 跨组学交集收敛 | 单细胞核心基因 ∩ Bulk DEG/WGCNA 关键模块 | `candidate-biomarker-list` | [[templates/set-venn]] · [[recipes/figureya-112venn]] |
| **Step 4** | Bulk 投射与建模 | ssGSEA 量化 Bulk 中该亚群特征丰度，或构建 ML 风险模型 | `model-prediction-shap` | [[recipes/figureya-71ssgsea-update]] · [[recipes/figureya-293plus-binaryclassificationml]] · [[methods/shap-explanation]] |
| **Step 5** | 外部队列临床验证 | 验证高/低亚群丰度或风险组生存差异（KM/Time-ROC/相关性） | `model-prediction-shap` | [[templates/km-survival-curve]] · [[templates/subgroup-hazard-forest]] · [[recipes/figureya-85timeroc]] |

## 注意

- 投射单细胞特征到 Bulk 时，尽量优先选取不受核糖体/管家基因干扰的细胞类型特异基因；避免把非特异性的通用细胞周期/应激基因直接当亚群丰度代理。

<!-- user:start -->
<!-- user:end -->
