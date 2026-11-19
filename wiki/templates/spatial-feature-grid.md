---
type: template
id: spatial-feature-grid
title: 空间转录组特征分布网格
status: ready
layouts: []
sources:
- methods/spatial-transcriptomics-microenvironment
panels: []
language: r
primary_method: spatial-transcriptomics-microenvironment
tags:
- single-cell
- transcriptomics
chart_types:
- spatial-map
keywords: []
favorite: false
style_tier: default
journal_style: Cai2026-npjPO
---
# 空间转录组特征分布网格

![[templates/spatial-feature-grid/preview.png]]

<!-- facts:start -->
- 来源：[[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]
- 语言：r
- 标签：single-cell、transcriptomics
- 图型：[[chart-types/spatial-map]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：Visium 空间 Spot 上的连续基因表达、签名密度或 RCTD 反卷积权重可作为 default 主推网格图展示；模板不执行反卷积。；前提：Spot 坐标（x, y）对齐同一切片；各特征独立着色，色深仅在同一特征内比较。；适配：导出 spatial_spots_long.csv（x, y, feature, value, 可选 sample）。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/spatial-feature-grid/spec.json；运行证据：无
<!-- facts:end -->

## 适用

在同一组织切片的 spot 坐标上并排展示连续基因表达、签名分数或反卷积值。对应 Cai 等主图 2J、6D–G 及附图 3、6 的空间分布展示。

## 不适用

输入只有亚群汇总、缺少空间坐标，或需要叠加 H&E、做空间插值、在多切片之间配准时，应使用相应的上游工具。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/spatial-transcriptomics-microenvironment]]。

## 数据要求

### spots（spatial_spots_long.csv）：空间转录组 Spot 坐标与特征/基因强度长表（x、y、feature、value、可选 sample） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| x | float | 必需 | 组织切片 Spot 横坐标（如 imagecol） |
| y | float | 必需 | 组织切片 Spot 纵坐标（如 imagerow，渲染时按显微图像习惯倒置或正置） |
| feature | str | 必需 | 展示的细胞类型分数、签名密度或基因名 |
| value | float | 必需 | 对应 Spot 的表达值或反卷积/签名强度 |
| sample | str | 可选 | 可选样本切片标识（多切片分面时使用） |

### 可覆盖的 style

- `ncol`：`4`
- `point_size`：`0.9`
- `point_alpha`：`0.95`
- `palette`：`"spectral"`
- `invert_y`：`true`
- `dpi`：`300`
- `width_in`：`9.6`
- `height_in`：`3.0`

## 使用记录

<!-- user:start -->
<!-- user:end -->
