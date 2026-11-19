---
type: scenario
id: geneset-theme-playbook
title: 特定修饰与主题基因集挖掘决策树（Playbook）
picks:
- id: methods/gene-set-scoring
  note: Step 1-2：多算法（AUCell/UCell/ssGSEA/AddModuleScore）基因集活性打分
- id: recipes/figureya-275scaucell
  note: 单细胞 AUCell 活性打分与阈值划分
- id: templates/pathway-stat-violin
  note: 分组/亚群主题打分小提琴箱线图（L2）
- id: templates/scp-expr-ridge
  note: 基因集得分山脊密度分布图（L2）
- id: recipes/figureya-318genesetdedotplot
  note: Step 3：高/低活性亚群差异表达与通路富集气泡图
- id: recipes/figureya-310cpdbchordgramv2
  note: 高/低活性亚群 CellChat 通讯差异
- id: recipes/figureya-69cancersubtype
  note: Step 4：Bulk 队列主题基因集无监督共识分型
- id: recipes/figureya-71ssgsea-update
  note: Bulk 队列 ssGSEA 定量与免疫关联
tags:
- single-cell
- transcriptomics
- multi-omics
keywords:
- 乳酸化
- PTM 修饰
- 铁死亡
- 代谢主题
- AUCell
- UCell
- ssGSEA
- irGSEA
- 高低活亚群
summary: 面向乳酸化、泛素化/乙酰化等 PTM 修饰、铁死亡及代谢主题基因集的专病挖掘决策树：从基因集定义、多算法打分到单细胞高活亚群深挖与 Bulk 分子分型闭环。
steps:
- id: theme-step-1-define
  step: 1
  title: 主题基因集收集与跨物种基因名校验
  when: 从 MSigDB、KEGG 或文献整理乳酸化/PTM/铁死亡主题基因集并核对物种符号时
  inputs: []
  outputs:
  - pathway-score-table
  templates:
  - recipes/figureya-32id-table
  - methods/gene-set-enrichment
  next_steps:
  - theme-step-2-score
- id: theme-step-2-score
  step: 2
  title: 多算法基因集活性打分与交叉印证
  method_id: gene-set-scoring
  when: 用 AUCell、UCell、ssGSEA、AddModuleScore 同时计算细胞/样本活性并做一致性检验时
  inputs:
  - scrna-annotated-cells
  outputs:
  - pathway-score-table
  interface: pathway-score-table
  templates:
  - methods/gene-set-scoring
  - recipes/figureya-275scaucell
  - recipes/figureya-71ssgsea-update
  - templates/pathway-stat-violin
  - templates/scp-expr-ridge
  next_steps:
  - theme-step-3-sc-deepdive
  - theme-step-4-bulk-subtyping
- id: theme-step-3-sc-deepdive
  step: 3
  title: 单细胞高活 vs 低活亚群划分与机制深挖
  method_id: differential-expression
  when: 锁定主题得分最高的核心细胞类型，按中位数/四分位数划分为 High vs Low 组探索通讯与轨迹时
  inputs:
  - pathway-score-table
  outputs:
  - deg-result-table
  interface: deg-result-table
  templates:
  - methods/differential-expression
  - recipes/figureya-318genesetdedotplot
  - recipes/figureya-310cpdbchordgramv2
  - methods/trajectory-inference
  - templates/scp-flow-chord
  next_steps:
  - theme-step-4-bulk-subtyping
- id: theme-step-4-bulk-subtyping
  step: 4
  title: Bulk 队列主题分子分型与临床预后闭环
  method_id: shap-explanation
  when: 将单细胞高活亚群标志基因映射至 Bulk 队列做共识聚类分型、预后模型与免疫特征对比时
  inputs:
  - pathway-score-table
  outputs:
  - model-prediction-shap
  interface: model-prediction-shap
  templates:
  - recipes/figureya-69cancersubtype
  - recipes/figureya-293plus-binaryclassificationml
  - templates/km-survival-curve
  - recipes/figureya-56immune-inflitrationv3
  next_steps: []
---

# 特定修饰与主题基因集挖掘决策树（Playbook）

## 什么时候用

- 围绕特定生物学主题（如 **乳酸化 Lactylation**、**20 种蛋白质翻译后修饰 PTM**、**铁死亡/铜死亡**、**糖酵解/脂代谢**）开展单细胞 + Bulk 机制挖掘。
- 避免只用单一打分算法导致争议，强调多算法相互印证与“高活亚群 → 通讯/轨迹 → Bulk 分子分型”的因果链构建。

## 首选组合

<!-- facts:start -->
| 条目 | 级别 | 状态 | 说明 |
|---|---|---|---|
| [[methods/gene-set-scoring|基因集与通路签名打分]] | L2 | ready · 可用 | Step 1-2：多算法（AUCell/UCell/ssGSEA/AddModuleScore）基因集活性打分 |
| [[recipes/figureya-275scaucell|单细胞AUCell基因集评分]] | L1 | draft · 运行 fail | 单细胞 AUCell 活性打分与阈值划分 |
| [[templates/pathway-stat-violin|分组小提琴图（含统计标注）]] | L2 | ready · 可用 | 分组/亚群主题打分小提琴箱线图（L2） |
| [[templates/scp-expr-ridge|分组表达密度图]] | L2 | ready · 可用 | 基因集得分山脊密度分布图（L2） |
| [[recipes/figureya-318genesetdedotplot|单细胞通路活性差异点图]] | L1 | draft · 运行 fail | Step 3：高/低活性亚群差异表达与通路富集气泡图 |
| [[recipes/figureya-310cpdbchordgramv2|细胞通讯配体受体弦图]] | L1 | draft · 运行 fail | 高/低活性亚群 CellChat 通讯差异 |
| [[recipes/figureya-69cancersubtype|多组学共识聚类分子分型]] | L1 | ready · 运行 pass | Step 4：Bulk 队列主题基因集无监督共识分型 |
| [[recipes/figureya-71ssgsea-update|免疫浸润ssGSEA注释热图]] | L1 | draft · 运行 fail | Bulk 队列 ssGSEA 定量与免疫关联 |
<!-- facts:end -->

## 步进决策树（走一步看一步）

| 阶段 | 核心问题 | 操作与判断依据 | 标准中间表 | 推荐模版与配方 |
|---|---|---|---|---|
| **Step 1** | 基因集可靠吗？ | 明确物种映射（人/鼠大小写）与基因集覆盖度 | — | [[recipes/figureya-32id-table]] · [[methods/gene-set-enrichment]] |
| **Step 2** | 哪个细胞/分组活性最高？ | 联合 AUCell / UCell / ssGSEA 多算法打分，规避单算法偏差 | `pathway-score-table` | [[methods/gene-set-scoring]] · [[recipes/figureya-275scaucell]] · [[templates/pathway-stat-violin]] · [[templates/scp-expr-ridge]] |
| **Step 3** | 高活亚群有什么生物学行为？ | 在靶细胞内划分 High/Low 组，做 DEG、拟时序与 CellChat 通讯差异 | `deg-result-table` / `cellchat-lr-table` | [[recipes/figureya-318genesetdedotplot]] · [[recipes/figureya-310cpdbchordgramv2]] · [[methods/trajectory-inference]] |
| **Step 4** | 能否区分患者临床亚型与预后？ | 提取核心修饰基因在 Bulk 做共识分型、KM 预后与免疫浸润 | `model-prediction-shap` | [[recipes/figureya-69cancersubtype]] · [[templates/km-survival-curve]] · [[recipes/figureya-56immune-inflitrationv3]] |

## 注意

- `AUCell`、`UCell` 与 `ssGSEA` 的原始得分量纲完全不同，绘图对比多算法时需先各自做 Z-score 标准化或统一用 RRA 综合排名，不可混在同一个未经归一化的纵轴直接取均值。

<!-- user:start -->
<!-- user:end -->
