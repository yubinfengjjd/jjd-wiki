---
type: template
id: lr-bipartite-bubble
title: 配受体双轴连线气泡图
status: ready
layouts: []
sources:
- methods/cell-cell-communication
panels: []
language: r
primary_method: cell-cell-communication
tags:
- single-cell
chart_types:
- bubble
keywords: []
favorite: false
style_tier: variant
journal_style: Cai2026-npjPO
---
# 配受体双轴连线气泡图

![[templates/lr-bipartite-bubble/preview.png]]

<!-- facts:start -->
- 来源：[[methods/cell-cell-communication|细胞通讯与配受体网络分析]]
- 语言：r
- 标签：single-cell
- 图型：[[chart-types/bubble]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/cell-cell-communication|细胞通讯与配受体网络分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：两类细胞群间的多对配体-受体双轴连线与两端平均表达量（着色）/表达阳性细胞比例 0–100%（气泡尺寸）可切换为 variant 双轴连线图；模板不重算 CellPhoneDB p 值。；前提：须明确发送群（配体端）与接收群（受体端），并从同一单细胞表达矩阵分别汇总两群内各基因的平均表达量及 0–100% 阳性细胞比例（分母为对应细胞群总细胞数）。；连线仅表示数据库配对与表达汇总，不代表物理结合或因果调控。；适配：从配受体结果结合单细胞表达矩阵导出 lr_bipartite_pairs.csv（ligand, receptor, ligand_expr, ligand_pct, receptor_expr, receptor_pct）。
    - 关系证据：methods/cell-cell-communication.md#输出；templates/lr-bipartite-bubble/spec.json；运行证据：无
  - [[methods/immune-infiltration-tme|肿瘤微环境与免疫浸润评估]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：关键免疫抑制基质亚群（发送群）与耗竭 T 细胞（接收群）间的配受体连线及两端平均表达量（着色）/0–100% 阳性细胞比例（尺寸）可切换为 variant 双轴连线气泡图；模板不重算检验。；前提：须明确发送群与接收群定义，并从单细胞表达矩阵额外汇总两群内配体/受体的平均表达量及 0–100% 阳性细胞比例（分母为各自定义细胞群总细胞数）。；适配：从配受体清单结合单细胞表达矩阵导出 lr_bipartite_pairs.csv（ligand, receptor, ligand_expr, ligand_pct, receptor_expr, receptor_pct）。
    - 关系证据：methods/immune-infiltration-tme.md#输出；templates/lr-bipartite-bubble/spec.json；运行证据：无
<!-- facts:end -->

## 适用

以有向连线展示预先选定的配体–受体候选关系，并用两端气泡比较平均表达与表达比例。连线样式参考 Cai 等主图 3D。

## 不适用

不适用于仅有互作 P 值或要估计空间邻近、通讯概率的输入。原图 3D 的 CellPhoneDB 置换检验支持度和显著比例须按原图的统计口径另行展示。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/cell-cell-communication]]。

## 数据要求

### pairs（lr_bipartite_pairs.csv）：配体-受体双轴连线气泡表（ligand、receptor、ligand_expr、ligand_pct、receptor_expr、receptor_pct） （模板内联表结构）

| 列 | 类型 | 含义 |
|---|---|---|
| ligand | str | 配体基因/细胞端标签 |
| receptor | str | 受体基因/靶细胞端标签 |
| ligand_expr | float | 配体平均表达量 |
| ligand_pct | float | 配体表达占比 (0-100) |
| receptor_expr | float | 受体平均表达量 |
| receptor_pct | float | 受体表达占比 (0-100) |

### 可覆盖的 style

- `dpi`：`300`
- `width_in`：`7.6`
- `height_in`：`3.4`

## 使用记录

<!-- user:start -->
<!-- user:end -->
