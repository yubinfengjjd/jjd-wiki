---
type: template
id: spatial-he-deconv-panel
title: 配准组织图与反卷积对照
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
- histology
- deconvolution
- RCTD
favorite: false
---
# 配准组织图与反卷积对照

<!-- facts:start -->
- 来源：[[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]
- 语言：r
- 标签：single-cell、transcriptomics
- 图型：[[chart-types/spatial-map]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：配准 H&E 组织切片裁剪图像与 Visium 空间反卷积权重图并排对照可切换为 variant 组织配准面板。；前提：Spot (x, y) 像素坐标须与 H&E 图像分辨率严格对齐（误差 < 1 像素）。；适配：导出 spatial_deconv_spots.csv（spot_id, x, y, feature, score, 可选 region）并附对齐 he_image.png。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/spatial-he-deconv-panel/spec.json；运行证据：无
<!-- facts:end -->

## 适用

将配准后的 H&E 组织切片裁剪图像（若未提供 PNG 则自动按组织染色密度绘制形态轮廓）与同一坐标区域内的 Visium 细胞反卷积权重/签名分布（`#46468A -> #5CB874 -> #F7DC6F -> #C0392B`）并排对照，并在各反卷积特征图上方附紧凑水平色条。对应 Cai 等附图 3B 风格。

## 不适用

不适用于未对齐像素坐标系的跨切片拼接，也不代替上游 RCTD / Cell2location 反卷积或 H&E 病理学定量；若仅需多基因无组织底图网格，请用默认模板 [[templates/spatial-feature-grid]]。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/spatial-transcriptomics-microenvironment]]，作为 `variant` H&E 配准对照画风模板（来源风格 `Cai2026-npjPO`），与默认特征网格 [[templates/spatial-feature-grid]] 及多通道共表达 [[templates/spatial-coexpr-multichannel]] 并列切换。

## 数据要求

### spots（spatial_deconv_spots.csv）：空间反卷积得分与对齐坐标长表（spot_id、x、y、feature、score，可选 region、he_intensity） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| spot_id | str | 必需 | 空间 Spot 唯一标识 |
| x | float | 必需 | 配准坐标横轴（对应 H&E 图像列像素） |
| y | float | 必需 | 配准坐标纵轴（对应 H&E 图像行像素） |
| feature | str | 必需 | 反卷积细胞类型或签名名称 |
| score | float | 必需 | 反卷积权重或签名密度 |
| region | str | 可选 | 可选分区标识（如 Quadrant 1–4） |
| he_intensity | float | 可选 | 可选组织染色密度代理（无 H&E PNG 时自动绘制组织轮廓） |

### 可覆盖的 style

- `he_image`：`"he_image.png"`
- `palette`：`["#46468A", "#5CB874", "#F7DC6F", "#C0392B"]`
- `invert_y`：`true`
- `quantile_cap`：`0.995`
- `gamma`：`1.4`
- `point_size`：`1.15`
- `dpi`：`300`
- `width_in`：`9.4`
- `height_in`：`5.8`

## 使用记录

<!-- user:start -->
<!-- user:end -->
