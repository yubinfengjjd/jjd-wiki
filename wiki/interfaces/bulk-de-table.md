---
type: interface
slug: bulk-de-table
title: bulk 差异表达结果表
columns:
  gene:
    type: str
    description: 基因/特征名，唯一
  log2fc:
    type: float
    description: log2 倍数变化（比较组相对参照组）
  pvalue:
    type: float
    description: 原始 P 值，(0,1]
---
# bulk 差异表达结果表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| gene | str | 必需 | 基因/特征名，唯一 |
| log2fc | float | 必需 | log2 倍数变化（比较组相对参照组） |
| pvalue | float | 必需 | 原始 P 值，(0,1] |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/figureya-59volcanov2--volcano|bulk 差异火山图（分级着色）]]
<!-- facts:end -->

## 含义

一行是一个基因在一次两组比较中的结果（如 limma topTable 的一行）。`log2fc` 为 log2 倍数变化，方向是比较组相对参照组；`pvalue` 为原始 P 值，(0,1]。与 render-de-results 的区别：后者是单细胞 marker 表，带阳性细胞比例和 group1/group2；本表一份文件只放一次比较。

<!-- user:start -->
<!-- user:end -->
