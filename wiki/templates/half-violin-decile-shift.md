---
type: template
id: half-violin-decile-shift
title: 半小提琴与分位数偏移哑铃图
status: draft
layouts: []
sources:
- methods/cell-proportion-composition
panels: []
language: python
primary_method: cell-proportion-composition
style_tier: default
journal_style: Cancer Discovery
tags:
- experimental-statistics
chart_types:
- violin
keywords:
- half-violin
- quantile-shift
- dumbbell
- spatial-distance
- Cancer Discovery
favorite: false
---
# 半小提琴与分位数偏移哑铃图

![[templates/half-violin-decile-shift/preview.png]]

<!-- facts:start -->
- 来源：[[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]
- 语言：python
- 标签：experimental-statistics
- 图型：[[chart-types/violin]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：两组间物理距离或连续分布在不同细胞类群的迁移可导出为 default 镜像半小提琴 + 十分位数哑铃偏移图；模板不计算最近邻距离。；前提：仅用于严格两分组全正值（log 轴）分布比较；明确样本/FOV 边界。；适配：导出 distance_shift_groups.csv（panel, group, value）。
    - 关系证据：methods/cell-proportion-composition.md#输出；templates/half-violin-decile-shift/spec.json；运行证据：无
<!-- facts:end -->

## 适用

对数坐标下比较两组（如 `Normal` vs `Precursor`）在不同细胞类别中的空间距离或连续分布迁移：上下对称半小提琴密度、抖动散点、IQR 黑条与中位数白圆点，辅以 9 条红色 10%–90% 十分位数连线（Quantile-shift dumbbell）直观揭示整体分布向近端或远端的非线性漂移。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 3F 风格。

## 不适用

仅适用于严格两分组、全正值（log 轴）分布对比；若需三组及以上常规箱线分布检验，请改用 [[templates/checkpoint-group-boxplot]] 或 [[templates/resampling-metric-box]]。示例数据取自 `MEL11` Normal/Precursor 真实物理坐标计算表（`fig3f_mel_immune_raw_distances.csv` 与 `fov_cells_with_rcn.csv`）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/cell-proportion-composition]]，槽位 `(cell-proportion-composition, violin)` 此前无 `default` 模板，设为 `style_tier: default` 并同步关联至 [[methods/spatial-transcriptomics-microenvironment]]。

## 数据要求

### distances（distance_shift_groups.csv）：两组对比分布长表 （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| panel | str | 必需 | 分面类别（如免疫细胞亚群） |
| group | str | 必需 | 对比组别（如 Normal vs Precursor） |
| value | float | 必需 | 正值观测数值（如空间距离 um） |

### 可覆盖的 style

- `top_group`：`"Normal"`
- `bottom_group`：`"Precursor"`
- `xlabel`：`"Distance from melanocytes (um)"`
- `dpi`：`300`
- `width_in`：`7.4`
- `height_in`：`2.75`

## 使用记录

<!-- user:start -->
<!-- user:end -->
