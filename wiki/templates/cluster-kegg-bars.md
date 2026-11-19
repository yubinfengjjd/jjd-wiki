---
type: template
id: cluster-kegg-bars
title: 亚群富集条形图与命中数
status: draft
layouts: []
sources:
- methods/gene-set-enrichment
panels: []
language: r
primary_method: gene-set-enrichment
style_tier: variant
journal_style: Cai2026-npjPO
tags:
- single-cell
- transcriptomics
chart_types:
- bar
keywords:
- KEGG
- enrichment
- subcluster
favorite: false
---
# 亚群富集条形图与命中数

<!-- facts:start -->
- 来源：[[methods/gene-set-enrichment|基因集富集分析]]
- 语言：r
- 标签：single-cell、transcriptomics
- 图型：[[chart-types/bar]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/gene-set-enrichment|基因集富集分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：各细胞亚群各自 Top N 显著 KEGG 通路及命中基因数可切换为 variant 分面深酒红横向条形图，保留亚群独立排序。；前提：每个亚群内按 p_adjust 升序排序；count 为非负整数命中基因数。；适配：导出 kegg_cluster_bars.csv（cluster, pathway, p_adjust, count）。
    - 关系证据：methods/gene-set-enrichment.md#输出；templates/cluster-kegg-bars/spec.json；运行证据：无
<!-- facts:end -->

## 适用

按细胞亚群分面展示各自显著富集的 Top 通路横向条形图（深酒红色 `#8E1D41`），横轴为 `-log10(p.adjust)`，并在条柱末端标注命中基因数 `count`。每个亚群保留独立纵轴排序，互不挤压。对应 Cai 等附图 4D、5C 风格。

## 不适用

不适用于只展示跨亚群共享通路的矩阵比较（此时请使用默认气泡矩阵 [[templates/kegg-cluster-bubble]]）或未做多重检验校正的原始基因列表；跨亚群比较时须保持一致的背景基因集与校正口径。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/gene-set-enrichment]]，作为 `variant` 风格模板（来源风格 `Cai2026-npjPO`），与默认跨亚群气泡矩阵 [[templates/kegg-cluster-bubble]]、代谢棒棒糖图 [[templates/metabolism-lollipop-dotplot]] 形成可切换组合，专用于“每个亚群独立展示 Top 通路与条尾命中基因数”。

## 数据要求

### kegg（kegg_cluster_bars.csv）：多亚群 KEGG 富集条形图输入表（cluster、pathway、p_adjust、count） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cluster | str | 必需 | 细胞亚群或对比分组名称 |
| pathway | str | 必需 | 富集通路名称（Description） |
| p_adjust | float | 必需 | 多重检验校正后 p 值（如 BH p.adjust） |
| count | int | 必需 | 通路命中基因数（打印于条柱末端） |

### 可覆盖的 style

- `bar_fill`：`"#8E1D41"`
- `top_n`：`5`
- `ncol`：`3`
- `wrap_width`：`34`
- `base_size`：`7.5`
- `dpi`：`300`
- `width_in`：`9.8`
- `height_in`：`6.4`

## 使用记录

<!-- user:start -->
<!-- user:end -->
