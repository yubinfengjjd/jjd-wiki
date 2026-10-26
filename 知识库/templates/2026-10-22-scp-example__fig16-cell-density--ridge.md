---
type: template
id: 2026-10-22-scp-example__fig16-cell-density--ridge
title: 分组表达密度图
status: ready
layouts:
- 2026-10-22-scp-example__fig16-cell-density
panels:
- A
language: r
tags:
- 单细胞分析
chart_types:
- ridge
favorite: false
---
# 分组表达密度图

![[templates/2026-10-22-scp-example__fig16-cell-density--ridge/preview.png]]

<!-- facts:start -->
- 来源版式：[[layouts/2026-10-22-scp-example__fig16-cell-density|分组表达密度图]]
- 面板（来源版式）：A
- 语言：r
- 标签：单细胞分析
- 图型：[[chart-types/ridge]]
- 输入接口：[[interfaces/render-cell-feature-values|细胞级特征值长表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

读取 `render-cell-feature-values` 的细胞级长表（每个细胞每个 feature 一行，含 `value`、`group` 与显式顺序），按原 `CellDensityPlot()` 的 ggplot/ggridges 分支绘制分组密度脊线：每组一条密度曲线，x 轴是特征值，y 轴是组；保留上游的 `ggridges` 几何、`scale_fill_manual`、`theme_scp`、图例与分面/组合规则。模板按 `feature × group` 计算密度，这是图的统计变换，不重算差异检验或均值。

示例为 `pancreas_sub` 的 Sox9、SubCellType 8 组（1000 个细胞），8×6 in @150 dpi；固定输出与画廊 source 逐字节一致（SHA256 `72a7a07a…`）。特征数与组数从数据读取，不写死 1 个特征或 8 组；`flip`、`reverse`、`x_order` 等由 style 给出。

## 不适用

- 只画 ridge 单 panel；不能把小提琴/箱线/点图混进同一模板。
- 每组观测很少时核密度不可靠；应改用箱线图或逐点展示，并标注每组 n。
- 不同组的样本量不同，密度面积按组归一化；曲线高度不能比较组的总量。
- `value` 的单位/变换（raw counts、data、score、log 尺度）必须由上游明确；多个 feature 量纲不同时不能共用一个坐标解释。
- 长表必须每个细胞每个 feature 恰好一行；`group` 不能是 NA；缺失/重复会改变密度形状。
- 组数/特征数/标签过长时按 `sizing` 增宽/增高；`max_width_in`/`max_height_in` 超限报错，不缩字体。
- 示例数据不是病例/对照设计，不能据此作生物学结论。
- ggridges 的带宽/平滑参数使用上游默认；模板未暴露带宽调参。

## 知识关联检查

日期 2026-10-22；查过 methods（`scp-standard-workflow`、`scp-annotation-projection`、`scp-cellqc-doublet`、`scp-de-enrichment-dynamic`、`scp-visualization-interface`）与 templates（glaucoma fig06 violin、本模板）。

- 候选方法：[[methods/scp-standard-workflow]] / [[methods/scp-annotation-projection]] 产出 celltype/cluster；[[methods/scp-cellqc-doublet]] 可提供 QC 分组；[[methods/scp-de-enrichment-dynamic]] 可提供特征/得分。它们需要在课题内导出 `render-cell-feature-values` 长表（cell, feature, value, group + 顺序），模板不重算分析。
- 一方法多图：同一份细胞级特征值可由 ridge 或 [[templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin|分组小提琴图]] 表达；ridge 强调多个有序组的分布形状，violin 每个类别一个对称密度并常带统计标注；两者不互相替代。
- 一图多方法：任何产生同一细胞全集连续特征值与分组的方法都可驱动本模板，不限于 SCP。
- 来源 layout：[[layouts/2026-10-22-scp-example__fig16-cell-density|分组表达密度图来源]]；模板从 A panel 拆出。
- 关系状态：已登记到 [[methods/scp-visualization-interface]] 的 `adaptable` 关系；模板读取 `render-cell-feature-values`，验证状态 example。
- 验证范围：表半 `plot_data` 与上游 `ggplot_build()` 数据在列、行、顺序、分组水平上一致；固定 8×6@150 与画廊 source 逐字节一致；adaptive 2 组/12 组、3 特征、长标签、max 拒绝、输入不变、异目录复制通过。未验证真实 Seurat→CSV→模板、非默认 flip/reverse/x_order、CJK 标签与科学有效性。

## 运行方式

本模板是独立模块：复制 `code/`（含 `data/palette_list.rda`）与 `spec.json` 到课题，用课题自己的 R 环境运行 `code/render.R`；不需要完整 `SCP-local`。必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verify/runtime-portability.json`。本轮已把模板复制到异目录、在新进程、不提供来源库路径运行，PNG 与既有回放逐像素一致（MAD=0）；PDF 因生成时间戳不同、部分 SVG 因设备标识不同而未按字节比较。

## 数据要求

### density（render-cell-feature-values.csv）：每个细胞每个 feature 一行的数值长表（cell, feature, value, group + 显式顺序列）；模板按原 CellDensityPlot 的 ggplot/ggridges 构造绘制分组密度脊线，不在模板内做特征提取、归一化或分组统计 [[interfaces/render-cell-feature-values|细胞级特征值长表]]

| 列 | 类型 | 含义 |
|---|---|---|
| cell | str | 细胞标识；同一特征内唯一；每个细胞每个特征一行 |
| feature | str | 基因或特征标识；一张图可含多个特征 |
| value | float | 该细胞该特征的数值（表达/得分）；单位由上游定义 |
| group | str | 密度分组的类别；每个细胞一个值 |
| feature_order | int | 特征面板/行顺序；从 1 起 |
| group_order | int | 组（山脊线）顺序；从 1 起 |

### 可覆盖的 style

- `cell_col`：`"cell"`
- `feature_col`：`"feature"`
- `value_col`：`"value"`
- `group_col`：`"group"`
- `feature_order_col`：`"feature_order"`
- `group_order_col`：`"group_order"`
- `split_col`：`"split"`
- `split_order_col`：`"split_order"`
- `group_by`：`"SubCellType"`
- `split_by`：`"All.groups"`
- `feature_levels`：`null`
- `group_levels`：`null`
- `x_order`：`"value"`
- `flip`：`false`
- `reverse`：`false`
- `decreasing`：`null`
- `palette`：`"Paired"`
- `palcolor`：`null`
- `keep_empty`：`false`
- `y_nbreaks`：`4`
- `y_min`：`null`
- `y_max`：`null`
- `aspect_ratio`：`null`
- `title`：`null`
- `subtitle`：`null`
- `legend_position`：`"right"`
- `legend_direction`：`"vertical"`
- `theme_use`：`"theme_scp"`
- `theme_args`：`{}`
- `combine`：`true`
- `nrow`：`null`
- `ncol`：`null`
- `byrow`：`true`
- `width_in`：`8`
- `height_in`：`6`
- `dpi`：`150`
- `seed`：`11`
- `sizing`：`{"mode": "adaptive", "base_in": 5.5, "per_feature_in": 3.5, "per_char_in": 0.09, "base_label_chars": 10, "min_width_in": 5.0, "base_height_in": 3.2, "per_group_in": 0.35, "min_height_in": 3.0, "max_width_in": null, "max_height_in": null}`

## 使用记录

2026-10-22 从 layout `2026-10-22-scp-example__fig16-cell-density` 的 A panel 拆出；原生调用 `CellDensityPlot(pancreas_sub, features = "Sox9", group.by = "SubCellType")`。表半 `scp_cell_density_meta()` 返回 1000 行 cell×feature 表，绘图半保留 ggplot/ggridges 构造；固定 8×6@150 与画廊 source 逐字节一致（SHA256 `72a7a07a…`），`verify-template` exit 0；方法关系登记在 [[methods/scp-visualization-interface]]。

<!-- user:start -->
<!-- user:end -->
