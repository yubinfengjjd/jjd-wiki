---
type: template
id: cellchat-circos-multi
aliases:
- ks-cellchat-circos-multi--circos
title: 细胞通讯多轨环形图（配受体互作+表达热图+柱状轨）
status: ready
sources:
- sources/ks-wechat
layouts: []
panels: []
language: r
license: MIT
tags:
- 单细胞分析
chart_types:
- circos
keywords:
- CellChat
- CellPhoneDB
- circlize
- pyCirclize
- 细胞通讯
- 受配体
- 环形热图
favorite: false
primary_method: cell-cell-communication
---
# 细胞通讯多轨环形图（配受体互作+表达热图+柱状轨）

![[templates/cellchat-circos-multi/preview.png]]

<!-- facts:start -->
- 来源：[[sources/ks-wechat|单细胞与顶刊多轨可视化代码库 (KS-account-codes)]]
- 语言：r
- 许可证：MIT
- 标签：单细胞分析
- 图型：[[chart-types/circos]]
- 输入接口：[[interfaces/cellchat-lr-table|细胞通讯配受体互作表]] · [[interfaces/celltype-gene-expression|细胞类型×基因平均表达表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：[[methods/cell-cell-communication|细胞通讯与配受体网络分析]]（ready）

- 方法配图关系（语义审查）：
  - [[methods/cell-cell-communication|细胞通讯与配受体网络分析]]（ready）：直接可接（direct）；调用验证：not_run；范围：仅核对 cellchat-lr-table 与 celltype-gene-expression 接口契约及模板 spec.json，尚未执行真实分析→出图端到端联调。
    - 依据：方法输出的 cellchat-lr-table 与 celltype-gene-expression 直接对应多轨环形图模板接口契约；模板仅负责多轨渲染，不重算通讯概率或置换检验。；前提：source、target 与 cell_type 标签跨表一致；建议按 prob 与 pval 筛选核心显著通路后控制基因总数。；多条件比较须显式保留 group 列，不能将未分层的合并强度直接等同于组间统计差异。；适配：无格式适配声明
    - 关系证据：methods/cell-cell-communication.md#输出；templates/cellchat-circos-multi/spec.json；templates/cellchat-circos-multi/verify/verify.json；interfaces/cellchat-lr-table.md；interfaces/celltype-gene-expression.md；运行证据：无
<!-- facts:end -->

## 适用

参考单细胞多轨可视化公开实现（`https://mp.weixin.qq.com/s/bF8f_hoVPwbCdKGPCGJ5Ng`），基于 R `circlize` + `ComplexHeatmap` 独立复刻并参数化为单 panel 可调用模板。一张图同时呈现四层信息：

1. **外圈扇区弧与基因角色标签**：按细胞亚群（如 `ECs`、`Tcell`、`SMCs`、`Mon`、`Kers`、`Fibs`、`Mast`、`lang`、`Men`）分扇区；基因标签斜体展示并按功能区分颜色（绿色 `ligand` 配体 vs 粉红色 `receptor` 受体）。
2. **外环表达量热图轨（Track 1）**：展示每个配体/受体基因在所有细胞亚群中的标准化表达强弱（蓝-白-红 Z-score 色阶）。
3. **中环强度柱状轨（Track 2）**：统计并展示各基因在当前细胞亚群中的累积互作强度（`0–100` 归一化刻度）。
4. **内环弦图连线（Track 3）**：按 `Interaction Score`（黄-绿-蓝-紫 `YlGnBu` 渐变）连接发送方配体与接收方受体，并可加粗高亮 Top N 关键受配体通路。

## 不适用

- 仅作可视化呈现：模板读取上游 CellChat / CellPhoneDB 导出的配受体互作表（`cellchat-lr-table`）及可选表达表（`celltype-gene-expression`），不重算通讯概率 `prob` 或置换检验 `pval`。
- 当细胞亚群数量过多（> 18 个）或基因总数超过 120 个时，外圈扇区标签容易拥挤，建议在输入表阶段先按 `prob` 与 `pval` 过滤出核心受配体对，或在操控台增大画布宽高（`width` / `height`）。
- 若未提供表达量表（`celltype-gene-expression.csv`），热图轨会退化为基于互作参与度的示意强度，不能当真实表达量解释。

## 知识关联检查

- 上游标准接口：主要消费 [[interfaces/cellchat-lr-table|细胞通讯配受体互作表]]（必需），可选配合 [[interfaces/celltype-gene-expression|细胞类型×基因平均表达表]]。
- 与 [[templates/scp-flow-chord|分组流向和弦图]] 的区别：后者统计单细胞二维计数矩阵，本模板专为细胞通讯的“配受体基因级连线 + 表达热图 + 强度柱状轨”设计，不互相替代。

## 数据要求

### interactions（cellchat-lr-table.csv）：细胞通讯配受体互作表（source, target, ligand, receptor, pathway_name, prob, pval） [[interfaces/cellchat-lr-table|细胞通讯配受体互作表]]

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

### expression（celltype-gene-expression.csv）（可选表）：配受体基因在各细胞类型中的 Z-score 表达矩阵长表（gene, cell_type, expression） [[interfaces/celltype-gene-expression|细胞类型×基因平均表达表]]

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| gene | str | 必需 | 基因名称（如配体或受体基因符号） |
| cell_type | str | 必需 | 细胞类型或亚群名称 |
| expression | float | 必需 | 该基因在该细胞类型中的标准化平均表达值（如 Z-score） |
| role | str | 可选 | 可选基因功能角色标注（如 ligand 或 receptor） |

### 可覆盖的 style

- `source_col`：`"source"`
- `target_col`：`"target"`
- `ligand_col`：`"ligand"`
- `receptor_col`：`"receptor"`
- `prob_col`：`"prob"`
- `pval_col`：`"pval"`
- `pathway_col`：`"pathway_name"`
- `gene_col`：`"gene"`
- `cell_type_col`：`"cell_type"`
- `expression_col`：`"expression"`
- `palette`：`"NPG"`
- `width_in`：`9.8`
- `height_in`：`7.6`
- `dpi`：`200`
- `title`：`""`
- `font_size`：`10.0`
- `score_threshold`：`0.05`
- `pval_threshold`：`0.05`
- `expr_limit`：`2.5`
- `show_bar_track`：`true`
- `highlight_top_n`：`2`
- `sector_gap`：`4.5`
- `start_degree`：`88`

## 使用记录

2026-11-18：在本地 R 4.5.0（`circlize` + `ComplexHeatmap`）中完成细胞通讯多轨环形图独立复刻、示例数据构建与参数 Schema 接入。

<!-- user:start -->
<!-- user:end -->
