---
type: template
id: pseudotime-branch-curves
title: 拟时序多分支基因曲线网格
status: ready
layouts: []
sources:
- methods/trajectory-inference
panels: []
language: r
primary_method: trajectory-inference
tags:
- single-cell
chart_types:
- trend
keywords: []
favorite: false
style_tier: default
journal_style: Cai2026-npjPO
---
# 拟时序多分支基因曲线网格

![[templates/pseudotime-branch-curves/preview.png]]

<!-- facts:start -->
- 来源：[[methods/trajectory-inference|拟时序与轨迹推断]]
- 语言：r
- 标签：single-cell
- 图型：[[chart-types/trend]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - [[methods/trajectory-inference|拟时序与轨迹推断]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：沿多分支拟时序平滑拟合的动态基因表达趋势可切换为 variant 分面曲线网格；模板不执行 GAM 拟合。；前提：pseudotime_norm 已归一化至同一 [0, 1] 区间；各基因纵轴独立缩放需在图注说明。；适配：导出 pseudotime_branch_genes.csv（gene, branch, pseudotime_norm, smoothed_expr）。
    - 关系证据：methods/trajectory-inference.md#输出；templates/pseudotime-branch-curves/spec.json；运行证据：无
<!-- facts:end -->

## 适用

在已确定的细胞谱系内查看基因的平滑表达趋势，按基因分面。对应 Cai 等主图 5I 的 mural 细胞轨迹展示。

## 不适用

原始计数、未拟合的观测和缺乏共同归一化尺度的分支须先处理。拟时序是模型推断的相对顺序，不能解释为实测时间或因果关系。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/trajectory-inference]]。

## 数据要求

### curves（pseudotime_branch_genes.csv）：拟时序多分支平滑表达表（gene、pseudotime_norm、smoothed_expr、branch） （模板内联表结构）

| 列 | 类型 | 含义 |
|---|---|---|
| gene | str | 基因名（分面） |
| pseudotime_norm | float | 归一化拟时间 |
| smoothed_expr | float | 平滑表达量 |
| branch | str | 分支/谱系名称 |

### 可覆盖的 style

- `ncol`：`2`
- `dpi`：`300`
- `width_in`：`5.6`
- `height_in`：`6.4`

## 使用记录

<!-- user:start -->
<!-- user:end -->
