---
type: interface
slug: deg-result-table
title: 差异表达标准结果表
columns:
  gene:
    type: str
    description: 基因符号或特征名
    required: true
  group_case:
    type: str
    description: 处理组或比较组名称（分子侧）
    required: true
  group_ctrl:
    type: str
    description: 对照组或参照组名称（分母侧）
    required: true
  cell_type:
    type: str
    description: 单细胞亚群名称（Bulk 转录组场景填 Bulk 或 All）
    required: false
  log2FC:
    type: float
    description: log2 倍数变化（group_case 相对 group_ctrl）
    required: true
  pct_1:
    type: float
    description: group_case 中阳性表达细胞比例（0-1）
    required: false
  pct_2:
    type: float
    description: group_ctrl 中阳性表达细胞比例（0-1）
    required: false
  p_val:
    type: float
    description: 原始检验 P 值
    required: true
  padj:
    type: float
    description: 多重检验校正后 P 值（FDR/BH）
    required: true
---
# 差异表达标准结果表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| gene | str | 必需 | 基因符号或特征名 |
| group_case | str | 必需 | 处理组或比较组名称（分子侧） |
| group_ctrl | str | 必需 | 对照组或参照组名称（分母侧） |
| cell_type | str | 可选 | 单细胞亚群名称（Bulk 转录组场景填 Bulk 或 All） |
| log2FC | float | 必需 | log2 倍数变化（group_case 相对 group_ctrl） |
| pct_1 | float | 可选 | group_case 中阳性表达细胞比例（0-1） |
| pct_2 | float | 可选 | group_ctrl 中阳性表达细胞比例（0-1） |
| p_val | float | 必需 | 原始检验 P 值 |
| padj | float | 必需 | 多重检验校正后 P 值（FDR/BH） |

- 产出方法：[[methods/differential-expression|差异表达分析]]
- 读取方法：[[methods/gene-set-enrichment|基因集富集分析]]
- 使用的模板：无
<!-- facts:end -->

## 含义

一行代表一个基因在一次明确对比（`group_case` vs `group_ctrl`，单细胞场景下限定在 `cell_type` 内）中的差异表达检验结果。`log2FC` 方向严格为比较组相对参照组（正值表示在 `group_case` 上调）；`pct_1` 与 `pct_2` 取值范围为 0–1（部分工具输出为 0–100 时必须在导出前归一化）；`padj` 为上游给出的校正 P 值，下游火山图与富集分析直接消费本表，不再重跑检验。单细胞细胞级检验（如 Wilcoxon）得到的 `p_val`/`padj` 不可直接等同于患者/样本级统计显著性；若做样本级推断需先聚合伪批量（pseudobulk）后再填入本表。与 `bulk-de-table` 和 `render-de-results` 的区别：本表统一兼容单细胞亚群对比与 Bulk 对比，承接富集分析与候选标志物筛选。

<!-- user:start -->
<!-- user:end -->
