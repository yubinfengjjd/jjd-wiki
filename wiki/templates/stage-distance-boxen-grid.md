---
type: template
id: stage-distance-boxen-grid
title: 多分期对数坐标水平 Boxen 空间距离图
status: draft
layouts: []
sources:
- methods/spatial-transcriptomics-microenvironment
panels: []
language: python
primary_method: spatial-transcriptomics-microenvironment
style_tier: default
journal_style: Cancer Discovery
tags:
- single-cell
- transcriptomics
chart_types:
- boxplot
keywords:
- boxenplot
- spatial-distance
- RCN
- log-scale
favorite: false
---
# 多分期对数坐标水平 Boxen 空间距离图

![[templates/stage-distance-boxen-grid/preview.png]]

<!-- facts:start -->
- 来源：[[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]
- 语言：python
- 标签：single-cell、transcriptomics
- 图型：[[chart-types/boxplot]]
- 输入接口：未声明 · 未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：各空间细胞邻域（RCN）到目标锚点邻域（如 RCN10）的跨分期微米距离分布可绘制为对数横轴水平 Boxen 分面图。；前提：物理距离须基于真实微米坐标计算（> 0 μm），跨分期显著性检验须与右侧星号列对应。；适配：导出 rcn_to_anchor_distances.csv 与 rcn_distance_ttests.csv。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/stage-distance-boxen-grid/spec.json；运行证据：无
<!-- facts:end -->

## 适用

按疾病演进分期（Normal、Precursor、MIS、IM）并排分面展示各递归细胞邻域（RCN2–8）到目标锚点邻域（如 RCN10）的物理微米距离分布：采用对数横轴（`6, 90, 1,000 μm` 灰色虚线参考线）、水平多阶分位数 Boxen 图，并在右侧标注跨分期比较红色标题与显著性星号。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 3E 画风。

## 不适用

不适用于两组单变量距离偏移比较（请用 [[templates/half-violin-decile-shift]]）或常规线性坐标分组箱线图（请用 [[templates/stage-boxplot-jitter-sig]]）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/spatial-transcriptomics-microenvironment]]，挂入 `(spatial-transcriptomics-microenvironment, boxplot)` 输出槽位（该槽位首个模板，标为 `style_tier: default`, `journal_style: Cancer Discovery`），沉淀空间组学跨分期物理距离多阶分位数分布图型。

## 数据要求

### distances（rcn_to_anchor_distances.csv）：单细胞到锚点邻域的空间物理距离表（cell_uid, fov_id, Stage, RCN, dist_to_RCN10_um） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell_uid | str | 必需 | 细胞唯一标识 |
| fov_id | str | 可选 | 视野编号 |
| Stage | str | 必需 | 疾病演进分期（Normal, Precursor, MIS, IM） |
| RCN | str | 必需 | 细胞所属空间邻域编号 |
| dist_to_RCN10_um | float | 必需 | 到目标锚点邻域的最近距离（μm） |

### ttests（rcn_distance_ttests.csv）（可选表）：跨分期距离比较显著性检验表（RCN, stage_1, stage_2, p_value） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| RCN | str | 必需 | 空间邻域编号 |
| stage_1 | str | 必需 | 比较分期 1 |
| stage_2 | str | 必需 | 比较分期 2 |
| p_value | float | 必需 | 双样本检验 P 值 |

### 可覆盖的 style

- `xlabel`：`"Distance from RCN10 (μm)"`
- `ref_lines`：`[6, 90, 1000]`
- `dpi`：`300`
- `width_in`：`6.8`
- `height_in`：`2.6`
- `rect`：`[0.08, 0.2, 0.88, 0.64]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
