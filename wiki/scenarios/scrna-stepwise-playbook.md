---
type: scenario
id: scrna-stepwise-playbook
title: 单细胞转录组步进决策树（Playbook）
picks:
- id: methods/cell-quality-control
  note: Step 1：按 UMI/基因数/线粒体比例过滤低质量细胞
- id: methods/batch-integration
  note: Step 2：多样本/多批次对齐整合与聚类
- id: methods/cell-type-annotation
  note: Step 3：细胞类型注释与 Marker 复核（核心分叉点）
- id: templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap
  note: 细胞类型注释 UMAP 主图（L2）
- id: templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow
  note: 分支 1：细胞组成比例堆叠流带图（L2）
- id: methods/differential-expression
  note: 分支 2：亚群间/组间差异表达与 Marker 分析
- id: methods/gene-set-scoring
  note: 分支 3：主题基因集多算法活性打分（AUCell/UCell/ssGSEA）
- id: methods/trajectory-inference
  note: 分支 4：关键亚群拟时序轨迹与动态基因
- id: recipes/figureya-310cpdbchordgramv2
  note: 分支 5：CellChat 细胞通讯配受体互作弦图
- id: recipes/figureya-293plus-binaryclassificationml
  note: 分支 6：投射 Bulk 临床队列验证与机器学习建模
tags:
- single-cell
- transcriptomics
keywords:
- 单细胞步进流程
- 走一步看一步
- UMAP
- 细胞注释
- Ro/e
- 基因集打分
- 拟时序
- CellChat
summary: 单细胞转录组“走一步看一步”步进决策树：从 QC、去批次整合到细胞注释后，展开 6 大下游科研探索分支，并用标准中间表衔接可视化模版。
steps:
- id: step-1-qc
  step: 1
  title: 单细胞质量控制与双细胞剔除
  method_id: cell-quality-control
  when: 拿到 CellRanger/原始 counts 矩阵，发现高线粒体或双细胞噪音时
  inputs: []
  outputs:
  - scrna-annotated-cells
  templates:
  - methods/cell-quality-control
  - methods/doublet-detection
  - templates/2026-10-22-scp-example__fig09-bar--bar
  next_steps:
  - step-2-integration
- id: step-2-integration
  step: 2
  title: 多样本批次整合、降维与无监督聚类
  method_id: batch-integration
  when: 多样本合并存在供体/批次偏移，需对齐嵌入并生成 cluster 时
  inputs: []
  outputs:
  - scrna-annotated-cells
  templates:
  - methods/batch-integration
  - methods/dimensionality-reduction
  - methods/cell-clustering
  - templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap
  next_steps:
  - step-3-annotation
- id: step-3-annotation
  step: 3
  title: 细胞类型注释与 Marker 表达验证
  method_id: cell-type-annotation
  when: 已完成聚类，需要给每个 cluster 赋予可靠生物学身份并输出标准注释表时
  inputs: []
  outputs:
  - scrna-annotated-cells
  templates:
  - methods/cell-type-annotation
  - methods/reference-mapping
  - templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap
  - templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap
  - templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot
  next_steps:
  - branch-1-proportion
  - branch-2-deg-enrichment
  - branch-3-geneset-scoring
  - branch-4-trajectory
  - branch-5-cellchat
  - branch-6-bulk-projection
- id: branch-1-proportion
  step: 4
  title: 分支 1：细胞亚群组成比例与 Ro/e 组织偏好
  when: 观察哪类细胞在疾病组显著扩增或萎缩，并检验样本级统计差异时
  inputs:
  - scrna-annotated-cells
  outputs:
  - cell-proportion-stats
  interface: cell-proportion-stats
  templates:
  - recipes/figureya-315singlerfraction
  - templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow
  - templates/2026-10-22-scp-example__fig02-ring--ring
  - templates/2026-10-22-scp-example__fig03-pie--pie
  next_steps:
  - branch-2-deg-enrichment
- id: branch-2-deg-enrichment
  step: 4
  title: 分支 2：亚群差异表达与通路富集（DEG + ORA/GSEA）
  when: 锁定关键变化亚群后，挖掘疾病 vs 对照差异基因与激活通路时
  method_id: differential-expression
  inputs:
  - scrna-annotated-cells
  outputs:
  - deg-result-table
  interface: deg-result-table
  templates:
  - methods/differential-expression
  - methods/gene-set-enrichment
  - templates/2026-10-22-scp-example__fig01-volcano--volcano
  - templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap
  next_steps:
  - branch-3-geneset-scoring
- id: branch-3-geneset-scoring
  step: 4
  title: 分支 3：主题基因集多算法打分（AUCell / UCell / ssGSEA）
  when: 聚焦乳酸化、PTM 修饰、铁死亡或代谢通路，定位高活性核心亚群时
  method_id: gene-set-scoring
  inputs:
  - scrna-annotated-cells
  outputs:
  - pathway-score-table
  interface: pathway-score-table
  templates:
  - methods/gene-set-scoring
  - recipes/figureya-275scaucell
  - templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin
  - templates/2026-10-22-scp-example__fig16-cell-density--ridge
  next_steps:
  - branch-4-trajectory
  - branch-5-cellchat
- id: branch-4-trajectory
  step: 4
  title: 分支 4：关键亚群拟时序轨迹与 RNA 速率
  when: 提取高关注度谱系细分亚群，推断分化起点、状态转换与动态驱动基因时
  method_id: trajectory-inference
  inputs:
  - scrna-annotated-cells
  outputs:
  - pseudotime-trajectory-table
  interface: pseudotime-trajectory-table
  templates:
  - methods/trajectory-inference
  - methods/rna-velocity
  - methods/dynamic-feature-analysis
  - templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap
  next_steps:
  - branch-6-bulk-projection
- id: branch-5-cellchat
  step: 4
  title: 分支 5：细胞通讯配受体互作网络（CellChat）
  when: 探索高活/疾病富集亚群如何通过分泌配受体调控周围微环境细胞时
  inputs:
  - scrna-annotated-cells
  outputs:
  - cellchat-lr-table
  interface: cellchat-lr-table
  templates:
  - recipes/figureya-310cpdbchordgramv2
  - templates/2026-10-22-scp-example__fig11-chord--chord
  - templates/2026-10-22-scp-example__fig10-sankey--sankey
  next_steps: []
- id: branch-6-bulk-projection
  step: 5
  title: 分支 6：向 Bulk 临床队列投射验证与建模
  when: 将单细胞筛选的核心基因带入外部 TCGA/GEO 临床队列验证预后与诊断价值时
  method_id: shap-explanation
  inputs:
  - candidate-biomarker-list
  outputs:
  - model-prediction-shap
  interface: candidate-biomarker-list
  templates:
  - recipes/figureya-293plus-binaryclassificationml
  - methods/shap-explanation
  - templates/figureya-1survivalcurve-update--km-curve
  - templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm
  next_steps: []
---

# 单细胞转录组步进决策树（Playbook）

## 什么时候用

- 从单细胞原始 counts 出发，希望“每做完一步、看完中间表与图形结果，再根据生物学现象决定下一步走向哪条支线”。
- 涵盖标准上游预处理（QC、双细胞、批次整合、细胞注释）及注释后的 **6 大下游探索分支**。

## 首选组合

<!-- facts:start -->
| 条目 | 级别 | 状态 | 说明 |
|---|---|---|---|
| [[methods/cell-quality-control|单细胞质量控制]] | L2 | ready · 可用 | Step 1：按 UMI/基因数/线粒体比例过滤低质量细胞 |
| [[methods/batch-integration|单细胞批次整合]] | L2 | ready · 可用 | Step 2：多样本/多批次对齐整合与聚类 |
| [[methods/cell-type-annotation|细胞类型注释]] | L2 | ready · 可用 | Step 3：细胞类型注释与 Marker 复核（核心分叉点） |
| [[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap|CNS 细胞类型 UMAP]] | L2 | ready · 可用 | 细胞类型注释 UMAP 主图（L2） |
| [[templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow|细胞比例堆叠流带图]] | L2 | ready · 可用 | 分支 1：细胞组成比例堆叠流带图（L2） |
| [[methods/differential-expression|差异表达分析]] | L2 | ready · 可用 | 分支 2：亚群间/组间差异表达与 Marker 分析 |
| [[methods/gene-set-scoring|基因集与通路签名打分]] | L2 | ready · 可用 | 分支 3：主题基因集多算法活性打分（AUCell/UCell/ssGSEA） |
| [[methods/trajectory-inference|拟时序与轨迹推断]] | L2 | ready · 可用 | 分支 4：关键亚群拟时序轨迹与动态基因 |
| [[recipes/figureya-310cpdbchordgramv2|细胞通讯配体受体弦图]] | L1 | draft · 运行 fail | 分支 5：CellChat 细胞通讯配受体互作弦图 |
| [[recipes/figureya-293plus-binaryclassificationml|多算法二分类模型评估筛选]] | L1 | draft · 运行 fail | 分支 6：投射 Bulk 临床队列验证与机器学习建模 |
<!-- facts:end -->

## 步进决策树（走一步看一步）

| 阶段 | 当前完成状态 / 观察现象 | 决策判断（When） | 对接中间表（Interface） | 推荐分析与可视化模版 |
|---|---|---|---|---|
| **Step 1** | 原始 counts 导入 | 线粒体比例偏高或高上样量多样本 | `scrna-annotated-cells` | [[methods/cell-quality-control]] · [[methods/doublet-detection]] |
| **Step 2** | 质控完成 | 多供体/多批次存在明显分离偏移 | `scrna-annotated-cells` | [[methods/batch-integration]] · [[methods/cell-clustering]] |
| **Step 3** | 聚类完成 | 结合 Marker 气泡图与 SingleR/参考映射注释 | `scrna-annotated-cells` | [[methods/cell-type-annotation]] · [[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap]] · [[templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot]] |
| **Step 4.1** | 注释完成 → 看比例 | 某类免疫/上皮细胞在疾病组明显增多 | `cell-proportion-stats` | [[recipes/figureya-315singlerfraction]] · [[templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow]] · [[templates/2026-10-22-scp-example__fig02-ring--ring]] |
| **Step 4.2** | 注释完成 → 看差异 | 找出目标亚群疾病 vs 对照 DEG 与通路 | `deg-result-table` | [[methods/differential-expression]] · [[methods/gene-set-enrichment]] · [[templates/2026-10-22-scp-example__fig01-volcano--volcano]] |
| **Step 4.3** | 注释完成 → 看主题活性 | 关注乳酸化/铁死亡/PTM 等特定基因集得分 | `pathway-score-table` | [[methods/gene-set-scoring]] · [[recipes/figureya-275scaucell]] · [[templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin]] · [[templates/2026-10-22-scp-example__fig16-cell-density--ridge]] |
| **Step 4.4** | 聚焦核心谱系 → 看演化 | 探索高活亚群的分化起点、分支与驱动基因 | `pseudotime-trajectory-table` | [[methods/trajectory-inference]] · [[methods/rna-velocity]] · [[methods/dynamic-feature-analysis]] |
| **Step 4.5** | 聚焦核心谱系 → 看互作 | 分析高活亚群与其他细胞的配受体通讯 | `cellchat-lr-table` | [[recipes/figureya-310cpdbchordgramv2]] · [[templates/2026-10-22-scp-example__fig11-chord--chord]] · [[templates/2026-10-22-scp-example__fig10-sankey--sankey]] |
| **Step 5** | 锁定候选靶基因 → 临床验证 | 投射至 TCGA/GEO Bulk 队列验证诊断与预后 | `candidate-biomarker-list` → `model-prediction-shap` | [[recipes/figureya-293plus-binaryclassificationml]] · [[methods/shap-explanation]] · [[templates/figureya-1survivalcurve-update--km-curve]] |

## 注意

- 细胞级差异检验（`FindMarkers` / Wilcoxon）不能直接代替样本级统计学推断，关键亚群比例和基因变化建议配合样本级聚合验证。
- 进入 Step 4.4（拟时序）前务必从全细胞注释表中提取同一发育谱系并重新标准化降维，避免跨谱系强行拟合轨迹。

<!-- user:start -->
<!-- user:end -->
