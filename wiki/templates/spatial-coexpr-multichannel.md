---
type: template
id: spatial-coexpr-multichannel
title: 多通道空间表达与重点区域
status: draft
layouts: []
sources:
- methods/spatial-transcriptomics-microenvironment
panels: []
language: r
primary_method: spatial-transcriptomics-microenvironment
style_tier: variant
journal_style: Cai2026-npjPO
tags:
- single-cell
- transcriptomics
chart_types:
- spatial-map
keywords:
- Visium
- spatial-coexpression
- TLS
favorite: false
---
# 多通道空间表达与重点区域

<!-- facts:start -->
- 来源：[[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]
- 语言：r
- 标签：single-cell、transcriptomics
- 图型：[[chart-types/spatial-map]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：2 至 4 个配受体或 TLS 淋巴细胞标志基因在同一切片/多区域上的通道共定位与高亮区域可切换为 variant 多通道图。；前提：同一切片内各通道共享 Spot 坐标系；高分位数截断阈值（如 P99）须一致说明。；适配：导出 spatial_coexpr_spots.csv（spot_id, x, y, channel, value, 可选 region, highlight_zone）。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/spatial-coexpr-multichannel/spec.json；运行证据：无
<!-- facts:end -->

## 适用

在同一组织切片（或分区域切片网格）的 Spot 坐标上叠加 2 至 4 个独立基因通道的空间共表达强度，可选圈注共定位重点高亮区域（`highlight_zone`），并在右侧堆叠独立通道色标。支持双通道同心环套色（如 `CCL14` 绿 + `CCR1` 红，或 `CCL19` 蓝 + `CCR7` 红）及四通道微点偏移（如 `CD8A/CD79A/CD19/CD3E` TLS 淋巴细胞共定位）。对应 Cai 等主图 3E、6H 及附图 6B–C 风格。

## 不适用

不适用于展示单个连续特征的跨区平铺密度网格（请用默认模板 [[templates/spatial-feature-grid]]）或需要配准原始 H&E 组织切片图像对照的场景（请用 [[templates/spatial-he-deconv-panel]]）。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/spatial-transcriptomics-microenvironment]]，作为 `variant` 多通道共定位模板（来源风格 `Cai2026-npjPO`），与单通道特征网格 [[templates/spatial-feature-grid]]、H&E 反卷积对照 [[templates/spatial-he-deconv-panel]] 构成空间微环境可切换三大画风。

## 数据要求

### spots（spatial_coexpr_spots.csv）：多通道空间共表达 Spot 长表（spot_id、x、y、channel、value，可选 region、highlight_zone） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| spot_id | str | 必需 | 空间 Spot 唯一标识 |
| x | float | 必需 | 组织切片 Spot 横坐标（如 imagecol） |
| y | float | 必需 | 组织切片 Spot 纵坐标（如 imagerow） |
| channel | str | 必需 | 通道基因或标志物名称（2 至 4 个通道） |
| value | float | 必需 | 对应通道的表达量或强度 |
| region | str | 可选 | 可选分面区域标识（如 Area 1–Area 4） |
| highlight_zone | int | 可选 | 可选重点共定位高亮区标记（1 为高亮圈注，0 为常规） |

### 可覆盖的 style

- `channel_mode`：`"auto"`
- `channel_colors`：`["#D73027", "#31A354", "#3B7EB6", "#8856A7"]`
- `invert_y`：`true`
- `ncol`：`2`
- `point_size`：`0.95`
- `quantile_cap`：`0.99`
- `dpi`：`300`
- `width_in`：`7.6`
- `height_in`：`6.2`

## 使用记录

<!-- user:start -->
<!-- user:end -->
