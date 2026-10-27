---
type: interface
slug: highlight-gene-sets
title: 待标注基因与所属基因集
columns:
  gene:
    type: str
    description: 要圈出并标注的基因，须在差异表中
  set:
    type: str
    description: 所属基因集/通路，用于标注颜色与图例
---
# 待标注基因与所属基因集

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| gene | str | 必需 | 要圈出并标注的基因，须在差异表中 |
| set | str | 必需 | 所属基因集/通路，用于标注颜色与图例 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/figureya-59volcanov2--volcano|bulk 差异火山图（分级着色）]]
<!-- facts:end -->

## 含义

一行是一个要在火山图上圈出并标注的基因及其所属基因集（通路）。`gene` 须与 bulk-de-table 的 gene 一致；`set` 决定标注颜色，一个基因集一种颜色。不在差异表里的基因默认报错，`missing_highlight: drop` 时丢弃并记录。

<!-- user:start -->
<!-- user:end -->
