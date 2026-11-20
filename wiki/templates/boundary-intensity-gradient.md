---
type: template
id: boundary-intensity-gradient
title: 肿瘤基质边界空间荧光强度梯度曲线
status: ready
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
- trend
keywords:
- boundary-gradient
- spatial-profile
- CyCIF
- fluorescence-intensity
favorite: false
---
# 肿瘤基质边界空间荧光强度梯度曲线

![[templates/boundary-intensity-gradient/preview.png]]

<!-- facts:start -->
- 来源：[[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]
- 语言：python
- 标签：single-cell、transcriptomics
- 图型：[[chart-types/trend]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：沿肿瘤-基质侵袭边界有符号距离分箱的多标志物平均荧光强度梯度可绘制为带双向区室箭头的连续剖面曲线。；前提：距离分箱以肿瘤-基质边界为 0 μm（负值代表肿瘤侧，正值代表基质侧）。；适配：导出 boundary_intensity_gradient.csv（dist_bin_um, compartment 及各标志物平均强度列）。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/boundary-intensity-gradient/spec.json；运行证据：无
<!-- facts:end -->

## 适用

沿肿瘤–基质物理边界法向距离（如 `-100 μm` 肿瘤内部至 `+100 μm` 基质区，以 `0 μm` 垂直虚线标识侵袭边界）绘制多通道蛋白荧光强度或空间基因表达连续梯度曲线，并在顶部标注向外的 `<- Tumor | Stroma ->` 双向指示箭头。对应 Nirmal et al. (*Cancer Discovery*, 2022) Fig. 7E / S7D-right 画风。

## 不适用

不适用于按伪时间排序的无物理距离轴拟时序基因分支曲线（请改用 [[templates/pseudotime-branch-curves]]）。

## 知识关联检查

2026-11-20：新建模板主归属方法 [[methods/spatial-transcriptomics-microenvironment]]，挂入 `(spatial-transcriptomics-microenvironment, trend)` 输出槽位（该槽位首个模板，标为 `style_tier: default`, `journal_style: Cancer Discovery`），沉淀空间病理边界浸润梯度分析标准图型。

## 数据要求

### gradient（boundary_intensity_gradient.csv）：沿肿瘤-基质边界距离分箱的多标志物平均荧光强度表（dist_bin_um, compartment, SOX10, HLADPB1, CD11c 等） （模板内联表结构）

| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| dist_bin_um | float | 必需 | 距肿瘤-基质边界的有符号微米距离（负值为 Tumor，正值为 Stroma） |
| compartment | str | 可选 | 所在组织区室（Tumor / Boundary / Stroma） |
| SOX10 | float | 可选 | SOX10 平均归一化荧光强度 |
| HLADPB1 | float | 可选 | HLADPB1 (MHC-II / IRF1 proxy) 平均归一化荧光强度 |
| CD11c | float | 可选 | CD11c 平均归一化荧光强度 |

### 可覆盖的 style

- `markers`：`["SOX10", "HLADPB1", "CD11c"]`
- `line_width`：`2.0`
- `xlabel`：`"Distance from boundary (μm)"`
- `ylabel`：`"Fluorescence intensity"`
- `dpi`：`300`
- `width_in`：`3.8`
- `height_in`：`3.5`
- `rect`：`[0.2, 0.16, 0.74, 0.74]`

## 使用记录

<!-- user:start -->
<!-- user:end -->
