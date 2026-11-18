---
type: interface
slug: cellchat-lr-table
title: 细胞通讯配受体互作表
columns:
  source:
    type: str
    description: 信号发出细胞类型（Sender）
    required: true
  target:
    type: str
    description: 信号接收细胞类型（Receiver）
    required: true
  ligand:
    type: str
    description: 配体基因或复合物名称
    required: true
  receptor:
    type: str
    description: 受体基因或复合物名称
    required: true
  pathway_name:
    type: str
    description: 所属信号通路名称
    required: true
  prob:
    type: float
    description: 通讯互作概率或强度值
    required: true
  pval:
    type: float
    description: 置换检验 P 值
    required: true
  group:
    type: str
    description: 比较条件或分组（多组 CellChat 比较时必填）
    required: false
---
# 细胞通讯配受体互作表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| source | str | 必需 | 信号发出细胞类型（Sender） |
| target | str | 必需 | 信号接收细胞类型（Receiver） |
| ligand | str | 必需 | 配体基因或复合物名称 |
| receptor | str | 必需 | 受体基因或复合物名称 |
| pathway_name | str | 必需 | 所属信号通路名称 |
| prob | float | 必需 | 通讯互作概率或强度值 |
| pval | float | 必需 | 置换检验 P 值 |
| group | str | 可选 | 比较条件或分组（多组 CellChat 比较时必填） |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/ks-cellchat-circos-multi--circos|细胞通讯多轨环形图（配受体互作+表达热图+柱状轨）]]
<!-- facts:end -->

## 含义

一行代表一对细胞类型（`source` -> `target`）之间通过特定配受体对（`ligand` - `receptor`，归属 `pathway_name`）的通讯互作强度。`prob` 由 CellChat 等上游模型通过质量作用定律结合置换检验计算并给出 `pval`，绘图模板（弦图、气泡图、桑基图）只做筛选阈值过滤与呈现，不重算通讯概率。最易出错的前提是物种数据库（`CellChatDB.human` vs `CellChatDB.mouse`）错配，以及不同 `group` 的独立 CellChat 对象在合并比较时细胞类型集合不一致导致缺失边被误解为“零通讯”。

<!-- user:start -->
<!-- user:end -->
