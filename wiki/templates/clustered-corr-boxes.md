---
type: template
id: clustered-corr-boxes
title: 带聚类框与引线的相关矩阵
status: ready
layouts: []
sources:
- methods/immune-infiltration-tme
panels: []
language: r
primary_method: immune-infiltration-tme
style_tier: default
journal_style: Cai2026-npjPO
tags:
- transcriptomics
- single-cell
chart_types:
- heatmap
keywords:
- correlation-matrix
- hierarchical-clustering
- TME-cooccurrence
favorite: false
---
# 带聚类框与引线的相关矩阵

![[templates/clustered-corr-boxes/preview.png]]

<!-- facts:start -->
- 来源：[[methods/immune-infiltration-tme|肿瘤微环境与免疫浸润评估]]
- 语言：r
- 标签：transcriptomics、single-cell
- 图型：[[chart-types/heatmap]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/immune-infiltration-tme|肿瘤微环境与免疫浸润评估]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：Bulk 队列免疫/基质反卷积丰度与细胞亚群特征间的对称层次聚类相关矩阵及对角黑框可作为 default 主推共现相关矩阵。；前提：相关系数矩阵须来自同一标准化队列，对称且主对角线为 1；样本量须满足相关检验。；适配：导出 corr_matrix.csv（首列 feature + N 列对称相关系数，或 tidy 格式 row, col, r）。
    - 关系证据：methods/immune-infiltration-tme.md#输出；templates/clustered-corr-boxes/spec.json；运行证据：无
<!-- facts:end -->

## 适用

展示 Bulk 转录组或反卷积细胞亚群共变相关矩阵（`+1` 深蓝至 `0` 白色至 `-1` 深红），自动执行层次聚类（或保留输入顺序），沿对角线绘制共现模块黑色聚类方框，并在右侧以双列错位虚线引线展示高密度特征名称。对应 Cai 等主图 3A 风格。

## 不适用

不适用于非对称有向通讯矩阵（请用 [[templates/cellchat-count-heatmap]]）、需要同时并排临床 Cox/Ro/e 分块的场景（请用 [[templates/roe-cox-heatmap]]），或未经过同一队列批次校正的多数据源直接相关性拼接。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/immune-infiltration-tme]]，作为该方法的 `default` 对称相关矩阵模板（来源风格 `Cai2026-npjPO`），与检查点分组箱线图 [[templates/checkpoint-group-boxplot]]、双轴配受体图 [[templates/lr-bipartite-bubble]] 形成免疫微环境共定位与功能验证组合。

## 数据要求

### corr（corr_matrix.csv）：对称相关性矩阵（wide 格式首列 feature 加 N 列数值，或 tidy 格式 row、col、r） （模板内联表结构）

- 矩阵/自由列结构，按模板示例表格式提供输入。

### 可覆盖的 style

- `n_clusters`：`5`
- `cluster_method`：`"ward.D2"`
- `preserve_order`：`false`
- `palette`：`["#67001F", "#B2182B", "#F7F7F7", "#2166AC", "#053061"]`
- `box_color`：`"#202020"`
- `box_linewidth`：`0.55`
- `label_size`：`2.3`
- `dpi`：`300`
- `width_in`：`8.2`
- `height_in`：`6.4`

## 使用记录

<!-- user:start -->
<!-- user:end -->
