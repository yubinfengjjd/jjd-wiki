---
type: interface
slug: pathway-score-table
title: 通路富集与多算法基因集打分表
columns:
  entity_id:
    type: str
    description: 细胞条形码（单细胞）或样本 ID（Bulk）
    required: true
  group:
    type: str
    description: 实验分组或临床表型
    required: true
  cell_type:
    type: str
    description: 细胞类型或亚群名称（Bulk 场景可填 Bulk）
    required: false
  pathway:
    type: str
    description: 通路、GO/KEGG 条目或主题基因集名称（如 Lactylation）
    required: true
  score_aucell:
    type: float
    description: AUCell 算法计算的活动度得分
    required: false
  score_ucell:
    type: float
    description: UCell 秩次打分结果
    required: false
  score_ssgsea:
    type: float
    description: ssGSEA 富集得分
    required: false
  padj:
    type: float
    description: 富集检验或组间打分差异校正后 P 值
    required: false
---
# 通路富集与多算法基因集打分表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| entity_id | str | 必需 | 细胞条形码（单细胞）或样本 ID（Bulk） |
| group | str | 必需 | 实验分组或临床表型 |
| cell_type | str | 可选 | 细胞类型或亚群名称（Bulk 场景可填 Bulk） |
| pathway | str | 必需 | 通路、GO/KEGG 条目或主题基因集名称（如 Lactylation） |
| score_aucell | float | 可选 | AUCell 算法计算的活动度得分 |
| score_ucell | float | 可选 | UCell 秩次打分结果 |
| score_ssgsea | float | 可选 | ssGSEA 富集得分 |
| padj | float | 可选 | 富集检验或组间打分差异校正后 P 值 |

- 产出方法：[[methods/gene-set-enrichment|基因集富集分析]] · [[methods/gene-set-scoring|基因集与通路签名打分]]
- 读取方法：无
- 使用的模板：无
<!-- facts:end -->

## 含义

一行代表一个观测单元（`entity_id`，即单个细胞或单个 Bulk 样本）在某一条 `pathway`/主题基因集上的活性打分结果（长表格式）。多算法（如 `AUCell`、`UCell`、`ssGSEA`）的分数分别保存在对应列中，不可把不同算法未经过归一化的原始分数混在同一列比较；若下游需要综合打分（如 `irGSEA` RRA 综合排名或 Z-score 均值），应由上游打分模块明确计算或用 `padj` 记录显著性。最易出错的前提是基因集物种与表达矩阵基因命名（Human 大写 vs Mouse 首字母大写）不一致导致命中基因为零。下游可接小提琴图、山脊图、热图及高/低活亚群划分（用于后续拟时序与 CellChat 通讯）。

<!-- user:start -->
<!-- user:end -->
