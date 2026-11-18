---
type: interface
slug: candidate-biomarker-list
title: 多算法筛选候选特征基因表
columns:
  gene:
    type: str
    description: 候选标志物基因符号
    required: true
  source_module:
    type: str
    description: 来源分析模块（如 DEG、WGCNA_turquoise、scRNA_ClusterMarker）
    required: true
  selection_methods:
    type: str
    description: 命中的特征筛选算法组合（如 LASSO+SVM-RFE+Boruta）
    required: true
  importance_score:
    type: float
    description: 综合重要性得分或重采样选中频率（0-1 或模型权重）
    required: true
---
# 多算法筛选候选特征基因表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| gene | str | 必需 | 候选标志物基因符号 |
| source_module | str | 必需 | 来源分析模块（如 DEG、WGCNA_turquoise、scRNA_ClusterMarker） |
| selection_methods | str | 必需 | 命中的特征筛选算法组合（如 LASSO+SVM-RFE+Boruta） |
| importance_score | float | 必需 | 综合重要性得分或重采样选中频率（0-1 或模型权重） |

- 产出方法：无
- 读取方法：无
- 使用的模板：无
<!-- facts:end -->

## 含义

一行代表一个通过上游差异分析、WGCNA 共表达模块或单细胞关键亚群与特征选择算法交叉筛选出的候选标志物基因。`source_module` 记录候选基因进入筛选池的依据，`selection_methods` 明确列举其被哪些算法共同命中（如 Venn/UpSet 交集或 101 种机器学习组合中的核心筛选器），`importance_score` 记录随机森林 Gini/Permutation 重要性、LASSO 回归系数绝对值或重采样选中频率。常见错误是在未严格划分训练集/验证集的情况下对全队列做监督特征筛选（数据泄漏），导致后续验证 AUC 虚高。下游对接诊断/预后建模、SHAP 解释、临床相关性与免疫浸润分析。

<!-- user:start -->
<!-- user:end -->
