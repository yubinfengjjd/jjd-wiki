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
- 使用的模板：无
<!-- facts:end -->

## 含义

<!-- user:start -->
<!-- user:end -->
