---
type: interface
slug: celltype-gene-expression
title: 细胞类型×基因平均表达表
columns:
  gene:
    type: str
    description: 基因名称（如配体或受体基因符号）
    required: true
  cell_type:
    type: str
    description: 细胞类型或亚群名称
    required: true
  expression:
    type: float
    description: 该基因在该细胞类型中的标准化平均表达值（如 Z-score）
    required: true
  role:
    type: str
    description: 可选基因功能角色标注（如 ligand 或 receptor）
    required: false
---
# 细胞类型×基因平均表达表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| gene | str | 必需 | 基因名称（如配体或受体基因符号） |
| cell_type | str | 必需 | 细胞类型或亚群名称 |
| expression | float | 必需 | 该基因在该细胞类型中的标准化平均表达值（如 Z-score） |
| role | str | 可选 | 可选基因功能角色标注（如 ligand 或 receptor） |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/ks-cellchat-circos-multi--circos|细胞通讯多轨环形图（配受体互作+表达热图+柱状轨）]]
<!-- facts:end -->

## 含义

一行代表一个 `gene × cell_type` 的聚合平均表达单元（例如由 Seurat `AverageExpression` 后按行做 Z-score 标准化得到），用于在多轨细胞通讯环形图（Circos）或分组热图中叠加展示配受体基因在各细胞亚群中的表达强弱。`role` 列为可选项，用于在环形基因标签中区分 `ligand` 与 `receptor` 颜色；若同时存在细胞通讯表，绘图模板也会依据 `ligand` / `receptor` 列自动推断角色。

<!-- user:start -->
<!-- user:end -->
