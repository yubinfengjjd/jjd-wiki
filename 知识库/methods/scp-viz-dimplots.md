---
type: method
id: scp-viz-dimplots
title: 单细胞降维与表达绘图入口
status: draft
inputs: []
outputs: []
license: GPL-3
favorite: false
implementations:
- id: scp-celldensityplot
  title: SCP CellDensityPlot 原生实现
  language: R
  entrypoint: code/celldensityplot/code/module.R:CellDensityPlot
  dependencies:
  - SeuratObject
  - dplyr
  - ggplot2
  - ggridges
  - rlang
  verification: verification/scp-celldensityplot-f_x_order_rank-20261101T071920-15996-alg.json
  note: 可视化入口
- id: scp-celldimplot
  title: SCP CellDimPlot 原生实现
  language: R
  entrypoint: code/celldimplot/code/module.R:CellDimPlot
  dependencies:
  - ggplot2
  - grid
  - rlang
  - stats
  verification: verification/scp-celldimplot-mark_circle-20261101T071929-14232-alg.json
  note: 可视化入口
- id: scp-celldimplot3d
  title: SCP CellDimPlot3D 原生实现
  language: R
  entrypoint: code/celldimplot3d/code/module.R:CellDimPlot3D
  dependencies:
  - ggplot2
  - grDevices
  - plotly
  - rlang
  verification: verification/scp-celldimplot3d-cell_3d-20261101T071945-3384-alg.json
  note: 可视化入口
- id: scp-featuredimplot
  title: SCP FeatureDimPlot 原生实现
  language: R
  entrypoint: code/featuredimplot/code/module.R:FeatureDimPlot
  dependencies:
  - SeuratObject
  - ggplot2
  - grid
  - rlang
  - stats
  verification: verification/scp-featuredimplot-keep_all-20261101T071958-19992-alg.json
  note: 可视化入口
- id: scp-featuredimplot3d
  title: SCP FeatureDimPlot3D 原生实现
  language: R
  entrypoint: code/featuredimplot3d/code/module.R:FeatureDimPlot3D
  dependencies:
  - SeuratObject
  - ggplot2
  - grDevices
  - plotly
  - rlang
  - stats
  verification: verification/scp-featuredimplot3d-feature_3d-20261101T072014-13780-alg.json
  note: 可视化入口
tags:
- single-cell
- transcriptomics
source:
  kind: repo
  url: https://github.com/zhanghao-njmu/scp
  commit: b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0
cite:
- 'SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)'
method_kind: technical
summary: 5 个 SCP 原生绘图入口的对象输入、上游链路、独立闭包及逐形态证据；draft，不作为分析家族。
data_contract:
  input: CellDensityPlot：Seurat 各细胞表达或元数据数值，features 指定变量；CellDimPlot：Seurat 降维坐标、group.by
    元数据及可选叠加对象；CellDimPlot3D：Seurat 三维 reduction 坐标与分组元数据；FeatureDimPlot：Seurat 坐标及
    features 对应 assay/slot 表达或元数据；FeatureDimPlot3D：Seurat 三维坐标及 features 表达
  output: CellDensityPlot：细胞表达分布密度图；CellDimPlot：细胞分组散点、圈选与叠加图；CellDimPlot3D：plotly
    三维分组图；FeatureDimPlot：单特征/多特征表达投影；FeatureDimPlot3D：plotly 三维表达图
keywords:
- SCP
- Seurat
- 原生绘图
- 形态验证
- CellDensityPlot
- CellDimPlot
- CellDimPlot3D
- FeatureDimPlot
- FeatureDimPlot3D
---
# 单细胞降维与表达绘图入口

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)
- 标签：single-cell、transcriptomics
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/scp-viz-dimplots/code/celldensityplot/code/fns/as_matrix.R](/files/wiki/methods/scp-viz-dimplots/code/celldensityplot/code/fns/as_matrix.R) · [methods/scp-viz-dimplots/code/celldensityplot/code/fns/asMatrix.R](/files/wiki/methods/scp-viz-dimplots/code/celldensityplot/code/fns/asMatrix.R) · [methods/scp-viz-dimplots/code/celldensityplot/code/fns/CellDensityPlot.R](/files/wiki/methods/scp-viz-dimplots/code/celldensityplot/code/fns/CellDensityPlot.R) · [methods/scp-viz-dimplots/code/celldensityplot/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-dimplots/code/celldensityplot/code/fns/palette_scp.R) · [methods/scp-viz-dimplots/code/celldensityplot/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-dimplots/code/celldensityplot/code/fns/show_palettes.R) · [methods/scp-viz-dimplots/code/celldensityplot/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-dimplots/code/celldensityplot/code/fns/theme_scp.R) · [methods/scp-viz-dimplots/code/celldensityplot/code/module.R](/files/wiki/methods/scp-viz-dimplots/code/celldensityplot/code/module.R) · [methods/scp-viz-dimplots/code/celldensityplot/LICENSE.md](/files/wiki/methods/scp-viz-dimplots/code/celldensityplot/LICENSE.md) · [methods/scp-viz-dimplots/code/celldensityplot/resources/palette_list.rda](/files/wiki/methods/scp-viz-dimplots/code/celldensityplot/resources/palette_list.rda) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/add_grob.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/add_grob.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/as_grob.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/as_grob.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/as_gtable.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/as_gtable.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/as_matrix.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/as_matrix.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/asMatrix.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/asMatrix.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/Blend2Color.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/Blend2Color.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/blendcolors.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/blendcolors.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/BlendRGBList.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/BlendRGBList.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/build_patchwork.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/build_patchwork.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/capitalize.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/capitalize.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/CellDimPlot.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/CellDimPlot.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/CellStatPlot.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/CellStatPlot.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/compute_velocity_on_grid.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/compute_velocity_on_grid.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/DefaultReduction.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/DefaultReduction.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/find_default_space.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/find_default_space.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/geom_alluvial.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/geom_alluvial.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/geom_alluvial_label.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/geom_alluvial_label.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/geom_alluvial_text.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/geom_alluvial_text.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/geom_sankey.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/geom_sankey.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/geom_sankey_bump.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/geom_sankey_bump.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/geom_sankey_label.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/geom_sankey_label.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/geom_sankey_text.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/geom_sankey_text.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/get_legend.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/get_legend.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/GraphPlot.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/GraphPlot.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/LineagePlot.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/LineagePlot.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/make_long.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/make_long.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/PAGAPlot.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/PAGAPlot.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/palette_scp.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/patchworkGrob.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/patchworkGrob.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/prepare_params.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/prepare_params.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/RGBA2RGB.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/RGBA2RGB.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/segementsDf.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/segementsDf.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/show_palettes.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/sigmoid.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/sigmoid.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/StatPlot.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/StatPlot.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/StatSankeyBumpFlow.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/StatSankeyBumpFlow.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/StatSankeyFlow.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/StatSankeyFlow.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/StatSankeyNode.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/StatSankeyNode.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/StatSankeyText.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/StatSankeyText.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/theme_alluvial.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/theme_alluvial.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/theme_blank.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/theme_blank.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/theme_sankey.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/theme_sankey.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/theme_sankey_bump.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/theme_sankey_bump.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/theme_scp.R) · [methods/scp-viz-dimplots/code/celldimplot/code/fns/VelocityPlot.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/fns/VelocityPlot.R) · [methods/scp-viz-dimplots/code/celldimplot/code/module.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/code/module.R) · [methods/scp-viz-dimplots/code/celldimplot/LICENSE.md](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/LICENSE.md) · [methods/scp-viz-dimplots/code/celldimplot/resources/palette_list.rda](/files/wiki/methods/scp-viz-dimplots/code/celldimplot/resources/palette_list.rda) · [methods/scp-viz-dimplots/code/celldimplot3d/code/fns/CellDimPlot3D.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot3d/code/fns/CellDimPlot3D.R) · [methods/scp-viz-dimplots/code/celldimplot3d/code/fns/col2hex.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot3d/code/fns/col2hex.R) · [methods/scp-viz-dimplots/code/celldimplot3d/code/fns/DefaultReduction.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot3d/code/fns/DefaultReduction.R) · [methods/scp-viz-dimplots/code/celldimplot3d/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot3d/code/fns/palette_scp.R) · [methods/scp-viz-dimplots/code/celldimplot3d/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot3d/code/fns/show_palettes.R) · [methods/scp-viz-dimplots/code/celldimplot3d/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot3d/code/fns/theme_scp.R) · [methods/scp-viz-dimplots/code/celldimplot3d/code/module.R](/files/wiki/methods/scp-viz-dimplots/code/celldimplot3d/code/module.R) · [methods/scp-viz-dimplots/code/celldimplot3d/LICENSE.md](/files/wiki/methods/scp-viz-dimplots/code/celldimplot3d/LICENSE.md) · [methods/scp-viz-dimplots/code/celldimplot3d/resources/palette_list.rda](/files/wiki/methods/scp-viz-dimplots/code/celldimplot3d/resources/palette_list.rda) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/add_grob.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/add_grob.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/adjcolors.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/adjcolors.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/as_grob.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/as_grob.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/as_gtable.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/as_gtable.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/as_matrix.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/as_matrix.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/asMatrix.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/asMatrix.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/Blend2Color.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/Blend2Color.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/blendcolors.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/blendcolors.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/BlendRGBList.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/BlendRGBList.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/build_patchwork.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/build_patchwork.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/check_DataType.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/check_DataType.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/DefaultReduction.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/DefaultReduction.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/FeatureDimPlot.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/FeatureDimPlot.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/get_legend.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/get_legend.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/LineagePlot.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/LineagePlot.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/palette_scp.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/patchworkGrob.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/patchworkGrob.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/rescale.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/rescale.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/RGBA2RGB.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/RGBA2RGB.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/show_palettes.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/theme_blank.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/theme_blank.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/theme_scp.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/fns/zero_range.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/fns/zero_range.R) · [methods/scp-viz-dimplots/code/featuredimplot/code/module.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/code/module.R) · [methods/scp-viz-dimplots/code/featuredimplot/LICENSE.md](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/LICENSE.md) · [methods/scp-viz-dimplots/code/featuredimplot/resources/palette_list.rda](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot/resources/palette_list.rda) · [methods/scp-viz-dimplots/code/featuredimplot3d/code/fns/as_matrix.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot3d/code/fns/as_matrix.R) · [methods/scp-viz-dimplots/code/featuredimplot3d/code/fns/asMatrix.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot3d/code/fns/asMatrix.R) · [methods/scp-viz-dimplots/code/featuredimplot3d/code/fns/check_DataType.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot3d/code/fns/check_DataType.R) · [methods/scp-viz-dimplots/code/featuredimplot3d/code/fns/col2hex.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot3d/code/fns/col2hex.R) · [methods/scp-viz-dimplots/code/featuredimplot3d/code/fns/DefaultReduction.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot3d/code/fns/DefaultReduction.R) · [methods/scp-viz-dimplots/code/featuredimplot3d/code/fns/FeatureDimPlot3D.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot3d/code/fns/FeatureDimPlot3D.R) · [methods/scp-viz-dimplots/code/featuredimplot3d/code/module.R](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot3d/code/module.R) · [methods/scp-viz-dimplots/code/featuredimplot3d/LICENSE.md](/files/wiki/methods/scp-viz-dimplots/code/featuredimplot3d/LICENSE.md)

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 用途

复用已拆出的 SCP 0.5.6 原生绘图闭包。每个入口独立声明依赖；读取 Seurat 对象或原生结果，不强制转成 CSV。以下范围由当前字节的实际收据核对，页面保持 draft。

## 适用

已有符合下表的对象和上游结果，需要原生绘图形态；或由 agent 先选择分析家族，再按链路选择能消费该结果的绘图入口。已存在的 CSV 单 panel 模板继续服务表格数据。

## 不适用

不能把一个用例通过扩大到整函数、所有参数、Assay5 或所有 Seurat 5 对象。当前对象证据主要来自旧 Assay 示例；Assay5/layers 未普遍适配。原生像素/trace 对照不证明课题科学有效，也不代表作者确认。缺包须另列审批，模块不会自动安装。

## 输入

| 入口 | 输入语义 | 上游方法 | 输出 |
|---|---|---|---|
| `CellDensityPlot` | Seurat 各细胞表达或元数据数值，features 指定变量 | 既有对象/表；不要求新跑分析 | 细胞表达分布密度图 |
| `CellDimPlot` | Seurat 降维坐标、group.by 元数据及可选叠加对象 | [[methods/dimensionality-reduction]] | 细胞分组散点、圈选与叠加图 |
| `CellDimPlot3D` | Seurat 三维 reduction 坐标与分组元数据 | [[methods/dimensionality-reduction]] | plotly 三维分组图 |
| `FeatureDimPlot` | Seurat 坐标及 features 对应 assay/slot 表达或元数据 | [[methods/dimensionality-reduction]] | 单特征/多特征表达投影 |
| `FeatureDimPlot3D` | Seurat 三维坐标及 features 表达 | [[methods/dimensionality-reduction]] | plotly 三维表达图 |

## 怎么做

先 `rwiki show scp-viz-dimplots`；确认输入后 `rwiki use scp-viz-dimplots --project <课题目录>`。该命令复制技术页的 code/ 与 runtime.json，收据和图样在 Wiki 查阅；进入副本，按 runtime.json 为目标分支选择 entry 文件，用 R 的 source() 加载，再调用该分支 entry_function。只加载所选入口，不加载整套 SCP。

本页输入通常是 R 会话中的 Seurat/结果对象，不能直接交给只读 CSV 的 rwiki render；rwiki run 面向 Rmd 配方。技术页没有自动换数据或执行路径。运行用例所需的示例 RDS、原生参考图和 driver 留在本机维护区；不会被当成课题数据复制。

每种形态只认可显式参数与实际比较收据的对应；表中的 not_run 表示本次没有这样的有效收据，不推断缺包。多个参数同时启用的已有用例不等于已完成“其余参数默认”的逐形态验收。

### CellDensityPlot

这是沿表达轴的密度/岭线分布，不是 UMAP 二维细胞密度。

- 原始定义：`R/SCP-plot.R:5679-5872`；上游说明：`man/CellDensityPlot.Rd`。
- 入口：`code/celldensityplot/code/module.R:CellDensityPlot`；当前算法状态 `verified`，范围 `f_x_order_rank`；独立性 `verified`。
- 收据：`verification/scp-celldensityplot-f_x_order_rank-20261101T071920-15996-alg.json`。

| 参数 | 形态 | 当前证据 | 用例 |
|---|---|---|---|
| `x_order` | `value` | passed | f_x_order_value |
| `x_order` | `rank` | passed | f_x_order_rank |

形态图样来自软件夹具的原生对照回放，不是来源原图或课题科学结论；只展示有输出哈希的通过用例。

**f_x_order_rank** · 收据 `verification/scp-celldensityplot-f_x_order_rank-20261101T070343-19120-alg.json`

![CellDensityPlot f_x_order_rank 软件夹具回放](/files/wiki/methods/scp-viz-dimplots/verification/previews/CellDensityPlot-f_x_order_rank.png)

**f_x_order_value** · 收据 `verification/scp-celldensityplot-f_x_order_value-20261101T070332-17284-alg.json`

![CellDensityPlot f_x_order_value 软件夹具回放](/files/wiki/methods/scp-viz-dimplots/verification/previews/CellDensityPlot-f_x_order_value.png)

**ins1_density** · 收据 `verification/scp-celldensityplot-ins1_density-20261026T151827-19740-alg.json`

![CellDensityPlot ins1_density 软件夹具回放](/files/wiki/methods/scp-viz-dimplots/verification/previews/CellDensityPlot-ins1_density.png)


### CellDimPlot

mark_type 需 add_mark=TRUE；轨迹、图、速度叠加还需对应上游结果。

- 原始定义：`R/SCP-plot.R:1328-1851`；上游说明：`man/CellDimPlot.Rd`。
- 入口：`code/celldimplot/code/module.R:CellDimPlot`；当前算法状态 `verified`，范围 `mark_circle`；独立性 `verified`。
- 收据：`verification/scp-celldimplot-mark_circle-20261101T071929-14232-alg.json`。

| 参数 | 形态 | 当前证据 | 用例 |
|---|---|---|---|
| `mark_type` | `hull` | passed | mark_hull |
| `mark_type` | `ellipse` | passed | mark_ellipse |
| `mark_type` | `rect` | passed | mark_rect |
| `mark_type` | `circle` | passed | mark_circle |
| `stat_plot_position` | `stack` | not_run | 无显式形态收据 |
| `stat_plot_position` | `dodge` | not_run | 无显式形态收据 |
| `stat_plot_type` | `pie` | not_run | 无显式形态收据 |
| `stat_type` | `percent` | not_run | 无显式形态收据 |

形态图样来自软件夹具的原生对照回放，不是来源原图或课题科学结论；只展示有输出哈希的通过用例。

**celltype_umap** · 收据 `verification/scp-celldimplot-celltype_umap-20261026T151840-34948-alg.json`

![CellDimPlot celltype_umap 软件夹具回放](/files/wiki/methods/scp-viz-dimplots/verification/previews/CellDimPlot-celltype_umap.png)

**mark_circle** · 收据 `verification/scp-celldimplot-mark_circle-20261026T151955-28940-alg.json`

![CellDimPlot mark_circle 软件夹具回放](/files/wiki/methods/scp-viz-dimplots/verification/previews/CellDimPlot-mark_circle.png)

**mark_ellipse** · 收据 `verification/scp-celldimplot-mark_ellipse-20261026T151904-19288-alg.json`

![CellDimPlot mark_ellipse 软件夹具回放](/files/wiki/methods/scp-viz-dimplots/verification/previews/CellDimPlot-mark_ellipse.png)

**mark_hull** · 收据 `verification/scp-celldimplot-mark_hull-20261026T151852-11356-alg.json`

![CellDimPlot mark_hull 软件夹具回放](/files/wiki/methods/scp-viz-dimplots/verification/previews/CellDimPlot-mark_hull.png)

**mark_rect** · 收据 `verification/scp-celldimplot-mark_rect-20261026T151939-5760-alg.json`

![CellDimPlot mark_rect 软件夹具回放](/files/wiki/methods/scp-viz-dimplots/verification/previews/CellDimPlot-mark_rect.png)

**subcelltype** · 收据 `verification/scp-celldimplot-subcelltype-20261026T151916-27644-alg.json`

![CellDimPlot subcelltype 软件夹具回放](/files/wiki/methods/scp-viz-dimplots/verification/previews/CellDimPlot-subcelltype.png)


### CellDimPlot3D

必须有三个有效维度；trace 相等不等于浏览器全部交互已验收。

- 原始定义：`R/SCP-plot.R:2843-3044`；上游说明：`man/CellDimPlot3D.Rd`。
- 入口：`code/celldimplot3d/code/module.R:CellDimPlot3D`；当前算法状态 `verified`，范围 `cell_3d`；独立性 `verified`。
- 收据：`verification/scp-celldimplot3d-cell_3d-20261101T071945-3384-alg.json`。

### FeatureDimPlot

混色、共表达与分面不是同一形态；显式指定 assay、slot、features 和 reduction。

- 原始定义：`R/SCP-plot.R:2042-2815`；上游说明：`man/FeatureDimPlot.Rd`。
- 入口：`code/featuredimplot/code/module.R:FeatureDimPlot`；当前算法状态 `verified`，范围 `keep_all`；独立性 `verified`。
- 收据：`verification/scp-featuredimplot-keep_all-20261101T071958-19992-alg.json`。

| 参数 | 形态 | 当前证据 | 用例 |
|---|---|---|---|
| `color_blend_mode` | `blend` | passed | two_blend |
| `color_blend_mode` | `average` | not_run | 无显式形态收据 |
| `color_blend_mode` | `screen` | not_run | 无显式形态收据 |
| `color_blend_mode` | `multiply` | not_run | 无显式形态收据 |
| `keep_scale` | `feature` | not_run | 无显式形态收据 |
| `keep_scale` | `all` | passed | keep_all |

形态图样来自软件夹具的原生对照回放，不是来源原图或课题科学结论；只展示有输出哈希的通过用例。

**keep_all** · 收据 `verification/scp-featuredimplot-keep_all-20261026T152108-23548-alg.json`

![FeatureDimPlot keep_all 软件夹具回放](/files/wiki/methods/scp-viz-dimplots/verification/previews/FeatureDimPlot-keep_all.png)

**neurog3** · 收据 `verification/scp-featuredimplot-neurog3-20261026T152031-18804-alg.json`

![FeatureDimPlot neurog3 软件夹具回放](/files/wiki/methods/scp-viz-dimplots/verification/previews/FeatureDimPlot-neurog3.png)

**two_blend** · 收据 `verification/scp-featuredimplot-two_blend-20261026T152045-3188-alg.json`

![FeatureDimPlot two_blend 软件夹具回放](/files/wiki/methods/scp-viz-dimplots/verification/previews/FeatureDimPlot-two_blend.png)


### FeatureDimPlot3D

必须有三个有效维度；输出 HTML 与 trace，不能用 PNG 替代交互证据。

- 原始定义：`R/SCP-plot.R:3066-3369`；上游说明：`man/FeatureDimPlot3D.Rd`。
- 入口：`code/featuredimplot3d/code/module.R:FeatureDimPlot3D`；当前算法状态 `verified`，范围 `feature_3d`；独立性 `verified`。
- 收据：`verification/scp-featuredimplot3d-feature_3d-20261101T072014-13780-alg.json`。

## 代码

runtime.json 列出逐入口闭包、必需/可选依赖、资源用途和原始函数位置；code/、资源与许可证按已有字节保存。GPL 源码及派生代码留本机，不进入 Git。收据仅按它实际执行的代码哈希解释。

## 输出

输出类型见输入表。形态及当前收据对应关系另见 `contracts.json`；它是审计索引，不是新运行收据。缺上游、缺依赖或原生失败的记录继续保留。

## 知识关联检查

全量函数去向见 [[methods/scp-source-catalog|SCP 全库来源与入口索引]]；CSV 接口与旧模板见 [[methods/scp-visualization-interface|绘图函数与接口映射]]。本页 method_kind=technical，不新增分析家族，不用结构相似代替科学直连。

## 使用记录

2026-11-01：接续 10 月隔离区已完成的代码与真实收据，核对当前字节并整理为 draft 技术入口。没有代作者签核，也没有把本批入库记作课题使用。

## 本机组学课题来源增量（2026-11-02）

项目中的 CellDimPlot/FeatureDimPlot 记录为依赖原生调用与参数来源，不新建同义 UMAP 模板，不继承本页验证。 来源清单见 [[methods/uc-ptm-source-catalog]]、[[methods/asthma-lactylation-source-catalog]]；具体实现与原始路径对照见 [[methods/local-omics-analysis-guide]]，图形调用见 [[methods/local-omics-visualization-guide]]。本段只补知识与来源，不更改现有实现、运行/独立性收据、状态或作者确认。

<!-- user:start -->
<!-- user:end -->
