---
type: template
id: stromal-hull-umap
title: 基质亚群功能包络UMAP
status: ready
layouts: []
sources:
- methods/cell-type-annotation
panels: []
language: r
primary_method: cell-type-annotation
style_tier: variant
journal_style: Cai2026-npjPO
tags:
- single-cell
chart_types:
- umap
keywords:
- stromal-subcluster
- convex-hull
- UMAP
favorite: false
---
# 基质亚群功能包络UMAP

![[templates/stromal-hull-umap/preview.png]]

<!-- facts:start -->
- 来源：[[methods/cell-type-annotation|细胞类型注释]]
- 语言：r
- 标签：single-cell
- 图型：[[chart-types/umap]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/batch-integration|单细胞批次整合]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：整合后精细亚群降维流形可导出坐标与功能群标签切换至 variant 包络画风；模板不做整合。；前提：坐标与 subcluster 来自同一整合嵌入；cell_id 唯一；坐标无 NA。；适配：导出 stromal_umap_cells.csv（cell_id, umap_1, umap_2, subcluster, 可选 functional_group）。
    - 关系证据：methods/batch-integration.md#输出；templates/stromal-hull-umap/spec.json；运行证据：无
  - [[methods/cell-type-annotation|细胞类型注释]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：注释后的精细细胞亚群与高阶功能群（如 mFib/lpFib/iFib）可切换为 variant 红色虚线包络 + 编号质心 UMAP 画风；模板不执行注释。；前提：umap_1/umap_2 与 subcluster 标签来自同一已注释对象；cell_id 唯一。；适配：导出 stromal_umap_cells.csv（cell_id, umap_1, umap_2, subcluster, functional_group）。
    - 关系证据：methods/cell-type-annotation.md#输出；templates/stromal-hull-umap/spec.json；运行证据：无
<!-- facts:end -->

## 适用

绘制高密度精细细胞亚群 UMAP 流形，按功能群（`functional_group`）自动生成光滑红色虚线包络轮廓（`#D63A2F`）与白边描边功能群标签，在亚群质心标注白色描边数字编号，左下角附 L 形坐标短箭头，并在图底排布分组多列彩点图例。对应 Cai 等主图 1D 风格。

## 不适用

不适用于不含高阶亚群/功能群分层的常规大群 UMAP（请改用默认模板 [[templates/scrna-celltype-umap]]），也不适用于展示连续基因表达网格（请用 [[templates/scrna-feature-umap-grid]]）；包络线仅作视觉分区导引，不能作为群间统计学边界检验依据。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/cell-type-annotation]]，作为 `variant` 高密度精细亚群画风模板（来源风格 `Cai2026-npjPO`），与默认基础细胞类型图 [[templates/scrna-celltype-umap]]、marker 特征网格 [[templates/scrna-feature-umap-grid]] 并列切换；区别于基础 UMAP 模板，本模板提供数字编号质心、周期样条光滑红虚线功能包络及底部多列分层彩点图例。

## 数据要求

### cells（stromal_umap_cells.csv）：细胞亚群降维坐标与高阶功能群表（cell_id、umap_1、umap_2、subcluster，可选 functional_group、compartment） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell_id | str | 必需 | 细胞唯一标识 |
| umap_1 | float | 必需 | UMAP 横坐标 |
| umap_2 | float | 必需 | UMAP 纵坐标 |
| subcluster | str | 必需 | 细胞精细亚群标签（自动按顺序编号） |
| functional_group | str | 可选 | 可选高阶功能群标签（绘制红色虚线包络轮廓） |
| compartment | str | 可选 | 可选大类分区（多分区时并排分面展示，如 Fib/EC/Mural cell） |

### 可覆盖的 style

- `hull_color`：`"#D63A2F"`
- `hull_linewidth`：`0.36`
- `dot_size`：`0.85`
- `legend_cols`：`4`
- `show_hulls`：`true`
- `show_centroids`：`true`
- `dpi`：`300`
- `width_in`：`9.6`
- `height_in`：`6.2`

## 使用记录

<!-- user:start -->
<!-- user:end -->
