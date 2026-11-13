---
type: method
id: scp-viz-statplots
title: 单细胞统计与相关绘图入口
status: ready
inputs: []
outputs: []
license: GPL-3
favorite: false
implementations:
- id: scp-cellstatplot
  title: SCP CellStatPlot 原生实现
  language: R
  entrypoint: code/cellstatplot/code/module.R:CellStatPlot
  dependencies:
  - ggplot2
  - grDevices
  - rlang
  - stats
  verification: verification/scp-cellstatplot-f_plot_type_upset-20261101T072722-15920-alg.json
  note: 可视化入口
- id: scp-featurecorplot
  title: SCP FeatureCorPlot 原生实现
  language: R
  entrypoint: code/featurecorplot/code/module.R:FeatureCorPlot
  dependencies:
  - Matrix
  - SeuratObject
  - gtable
  - patchwork
  - proxyC
  - rlang
  verification: verification/scp-featurecorplot-two_markers-20261101T072731-6580-alg.json
  note: 可视化入口
- id: scp-featurestatplot
  title: SCP FeatureStatPlot 原生实现
  language: R
  entrypoint: code/featurestatplot/code/module.R:FeatureStatPlot
  dependencies:
  - SeuratObject
  - ggplot2
  - methods
  - reshape2
  - rlang
  verification: verification/scp-featurestatplot-f_add_stat_mean-20261101T072744-15780-alg.json
  note: 可视化入口
- id: scp-statplot
  title: SCP StatPlot 原生实现
  language: R
  entrypoint: code/statplot/code/module.R:StatPlot
  dependencies:
  - ggplot2
  - grDevices
  - stats
  verification: verification/scp-statplot-f_position_dodge-20261101T072746-13688-alg.json
  note: 可视化入口
- id: scp-volcanoplot
  title: SCP VolcanoPlot 原生实现
  language: R
  entrypoint: code/volcanoplot/code/module.R:VolcanoPlot
  dependencies:
  - dplyr
  - ggplot2
  - ggrepel
  - methods
  - rlang
  - stats
  - utils
  note: 可视化入口
  verification: verification/scp-volcanoplot-positive_native_material-20261101T072804-15236-alg.json
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
summary: SCP 原生绘图实现的对象输入、上游链路、独立闭包及逐形态证据；资料确认不授予额外分支验证，不作为新分析家族。
data_contract:
  input: CellStatPlot：Seurat 元数据 stat.by、group.by、split.by；FeatureCorPlot：Seurat 中
    features 的逐细胞表达及 group.by；FeatureStatPlot：Seurat features/元数据 stat.by，group.by
    为细胞分组；StatPlot：meta.data：每行一个观测，stat.by 为统计分类，group.by 为分组；VolcanoPlot：RunDEtest
    后 Seurat tools 中 DEtest_<group_by> 的 AllMarkers_<test.use> 表
  output: CellStatPlot：从细胞元数据调用分类统计图；FeatureCorPlot：特征相关图；FeatureStatPlot：violin/box/bar/dot/col
    数值分布或汇总；StatPlot：11 种分类计数、比例、流向与集合图；VolcanoPlot：差异表达指标与显著性展示
keywords:
- SCP
- Seurat
- 原生绘图
- 形态验证
- CellStatPlot
- FeatureCorPlot
- FeatureStatPlot
- StatPlot
- VolcanoPlot
---
# 单细胞统计与相关绘图入口

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)
- 标签：single-cell、transcriptomics
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/scp-viz-statplots/code/cellstatplot/code/fns/add_grob.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/add_grob.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/as_grob.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/as_grob.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/as_gtable.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/as_gtable.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/Blend2Color.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/Blend2Color.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/blendcolors.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/blendcolors.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/BlendRGBList.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/BlendRGBList.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/build_patchwork.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/build_patchwork.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/capitalize.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/capitalize.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/CellStatPlot.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/CellStatPlot.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/find_default_space.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/find_default_space.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/geom_alluvial.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/geom_alluvial.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/geom_alluvial_label.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/geom_alluvial_label.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/geom_alluvial_text.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/geom_alluvial_text.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/geom_sankey.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/geom_sankey.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/geom_sankey_bump.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/geom_sankey_bump.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/geom_sankey_label.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/geom_sankey_label.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/geom_sankey_text.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/geom_sankey_text.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/get_legend.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/get_legend.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/make_long.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/make_long.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/palette_scp.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/patchworkGrob.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/patchworkGrob.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/prepare_params.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/prepare_params.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/RGBA2RGB.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/RGBA2RGB.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/show_palettes.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/sigmoid.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/sigmoid.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/StatPlot.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/StatPlot.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/StatSankeyBumpFlow.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/StatSankeyBumpFlow.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/StatSankeyFlow.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/StatSankeyFlow.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/StatSankeyNode.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/StatSankeyNode.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/StatSankeyText.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/StatSankeyText.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/theme_alluvial.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/theme_alluvial.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/theme_blank.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/theme_blank.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/theme_sankey.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/theme_sankey.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/theme_sankey_bump.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/theme_sankey_bump.R) · [methods/scp-viz-statplots/code/cellstatplot/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/fns/theme_scp.R) · [methods/scp-viz-statplots/code/cellstatplot/code/module.R](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/code/module.R) · [methods/scp-viz-statplots/code/cellstatplot/LICENSE.md](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/LICENSE.md) · [methods/scp-viz-statplots/code/cellstatplot/resources/palette_list.rda](/files/wiki/methods/scp-viz-statplots/code/cellstatplot/resources/palette_list.rda) · [methods/scp-viz-statplots/code/featurecorplot/code/fns/add_grob.R](/files/wiki/methods/scp-viz-statplots/code/featurecorplot/code/fns/add_grob.R) · [methods/scp-viz-statplots/code/featurecorplot/code/fns/as_grob.R](/files/wiki/methods/scp-viz-statplots/code/featurecorplot/code/fns/as_grob.R) · [methods/scp-viz-statplots/code/featurecorplot/code/fns/as_gtable.R](/files/wiki/methods/scp-viz-statplots/code/featurecorplot/code/fns/as_gtable.R) · [methods/scp-viz-statplots/code/featurecorplot/code/fns/as_matrix.R](/files/wiki/methods/scp-viz-statplots/code/featurecorplot/code/fns/as_matrix.R) · [methods/scp-viz-statplots/code/featurecorplot/code/fns/asMatrix.R](/files/wiki/methods/scp-viz-statplots/code/featurecorplot/code/fns/asMatrix.R) · [methods/scp-viz-statplots/code/featurecorplot/code/fns/build_patchwork.R](/files/wiki/methods/scp-viz-statplots/code/featurecorplot/code/fns/build_patchwork.R) · [methods/scp-viz-statplots/code/featurecorplot/code/fns/FeatureCorPlot.R](/files/wiki/methods/scp-viz-statplots/code/featurecorplot/code/fns/FeatureCorPlot.R) · [methods/scp-viz-statplots/code/featurecorplot/code/fns/get_legend.R](/files/wiki/methods/scp-viz-statplots/code/featurecorplot/code/fns/get_legend.R) · [methods/scp-viz-statplots/code/featurecorplot/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-statplots/code/featurecorplot/code/fns/palette_scp.R) · [methods/scp-viz-statplots/code/featurecorplot/code/fns/patchworkGrob.R](/files/wiki/methods/scp-viz-statplots/code/featurecorplot/code/fns/patchworkGrob.R) · [methods/scp-viz-statplots/code/featurecorplot/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-statplots/code/featurecorplot/code/fns/show_palettes.R) · [methods/scp-viz-statplots/code/featurecorplot/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-statplots/code/featurecorplot/code/fns/theme_scp.R) · [methods/scp-viz-statplots/code/featurecorplot/code/module.R](/files/wiki/methods/scp-viz-statplots/code/featurecorplot/code/module.R) · [methods/scp-viz-statplots/code/featurecorplot/LICENSE.md](/files/wiki/methods/scp-viz-statplots/code/featurecorplot/LICENSE.md) · [methods/scp-viz-statplots/code/featurecorplot/resources/palette_list.rda](/files/wiki/methods/scp-viz-statplots/code/featurecorplot/resources/palette_list.rda) · [methods/scp-viz-statplots/code/featurestatplot/code/fns/add_grob.R](/files/wiki/methods/scp-viz-statplots/code/featurestatplot/code/fns/add_grob.R) · [methods/scp-viz-statplots/code/featurestatplot/code/fns/as_grob.R](/files/wiki/methods/scp-viz-statplots/code/featurestatplot/code/fns/as_grob.R) · [methods/scp-viz-statplots/code/featurestatplot/code/fns/as_gtable.R](/files/wiki/methods/scp-viz-statplots/code/featurestatplot/code/fns/as_gtable.R) · [methods/scp-viz-statplots/code/featurestatplot/code/fns/as_matrix.R](/files/wiki/methods/scp-viz-statplots/code/featurestatplot/code/fns/as_matrix.R) · [methods/scp-viz-statplots/code/featurestatplot/code/fns/asMatrix.R](/files/wiki/methods/scp-viz-statplots/code/featurestatplot/code/fns/asMatrix.R) · [methods/scp-viz-statplots/code/featurestatplot/code/fns/build_patchwork.R](/files/wiki/methods/scp-viz-statplots/code/featurestatplot/code/fns/build_patchwork.R) · [methods/scp-viz-statplots/code/featurestatplot/code/fns/check_DataType.R](/files/wiki/methods/scp-viz-statplots/code/featurestatplot/code/fns/check_DataType.R) · [methods/scp-viz-statplots/code/featurestatplot/code/fns/ExpressionStatPlot.R](/files/wiki/methods/scp-viz-statplots/code/featurestatplot/code/fns/ExpressionStatPlot.R) · [methods/scp-viz-statplots/code/featurestatplot/code/fns/FeatureStatPlot.R](/files/wiki/methods/scp-viz-statplots/code/featurestatplot/code/fns/FeatureStatPlot.R) · [methods/scp-viz-statplots/code/featurestatplot/code/fns/get_legend.R](/files/wiki/methods/scp-viz-statplots/code/featurestatplot/code/fns/get_legend.R) · [methods/scp-viz-statplots/code/featurestatplot/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-statplots/code/featurestatplot/code/fns/palette_scp.R) · [methods/scp-viz-statplots/code/featurestatplot/code/fns/patchworkGrob.R](/files/wiki/methods/scp-viz-statplots/code/featurestatplot/code/fns/patchworkGrob.R) · [methods/scp-viz-statplots/code/featurestatplot/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-statplots/code/featurestatplot/code/fns/show_palettes.R) · [methods/scp-viz-statplots/code/featurestatplot/code/fns/theme_blank.R](/files/wiki/methods/scp-viz-statplots/code/featurestatplot/code/fns/theme_blank.R) · [methods/scp-viz-statplots/code/featurestatplot/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-statplots/code/featurestatplot/code/fns/theme_scp.R) · [methods/scp-viz-statplots/code/featurestatplot/code/module.R](/files/wiki/methods/scp-viz-statplots/code/featurestatplot/code/module.R) · [methods/scp-viz-statplots/code/featurestatplot/LICENSE.md](/files/wiki/methods/scp-viz-statplots/code/featurestatplot/LICENSE.md) · [methods/scp-viz-statplots/code/featurestatplot/resources/palette_list.rda](/files/wiki/methods/scp-viz-statplots/code/featurestatplot/resources/palette_list.rda) · [methods/scp-viz-statplots/code/statplot/code/fns/add_grob.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/add_grob.R) · [methods/scp-viz-statplots/code/statplot/code/fns/as_grob.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/as_grob.R) · [methods/scp-viz-statplots/code/statplot/code/fns/as_gtable.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/as_gtable.R) · [methods/scp-viz-statplots/code/statplot/code/fns/Blend2Color.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/Blend2Color.R) · [methods/scp-viz-statplots/code/statplot/code/fns/blendcolors.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/blendcolors.R) · [methods/scp-viz-statplots/code/statplot/code/fns/BlendRGBList.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/BlendRGBList.R) · [methods/scp-viz-statplots/code/statplot/code/fns/build_patchwork.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/build_patchwork.R) · [methods/scp-viz-statplots/code/statplot/code/fns/capitalize.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/capitalize.R) · [methods/scp-viz-statplots/code/statplot/code/fns/find_default_space.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/find_default_space.R) · [methods/scp-viz-statplots/code/statplot/code/fns/geom_alluvial.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/geom_alluvial.R) · [methods/scp-viz-statplots/code/statplot/code/fns/geom_alluvial_label.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/geom_alluvial_label.R) · [methods/scp-viz-statplots/code/statplot/code/fns/geom_alluvial_text.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/geom_alluvial_text.R) · [methods/scp-viz-statplots/code/statplot/code/fns/geom_sankey.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/geom_sankey.R) · [methods/scp-viz-statplots/code/statplot/code/fns/geom_sankey_bump.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/geom_sankey_bump.R) · [methods/scp-viz-statplots/code/statplot/code/fns/geom_sankey_label.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/geom_sankey_label.R) · [methods/scp-viz-statplots/code/statplot/code/fns/geom_sankey_text.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/geom_sankey_text.R) · [methods/scp-viz-statplots/code/statplot/code/fns/get_legend.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/get_legend.R) · [methods/scp-viz-statplots/code/statplot/code/fns/make_long.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/make_long.R) · [methods/scp-viz-statplots/code/statplot/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/palette_scp.R) · [methods/scp-viz-statplots/code/statplot/code/fns/patchworkGrob.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/patchworkGrob.R) · [methods/scp-viz-statplots/code/statplot/code/fns/prepare_params.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/prepare_params.R) · [methods/scp-viz-statplots/code/statplot/code/fns/RGBA2RGB.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/RGBA2RGB.R) · [methods/scp-viz-statplots/code/statplot/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/show_palettes.R) · [methods/scp-viz-statplots/code/statplot/code/fns/sigmoid.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/sigmoid.R) · [methods/scp-viz-statplots/code/statplot/code/fns/StatPlot.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/StatPlot.R) · [methods/scp-viz-statplots/code/statplot/code/fns/StatSankeyBumpFlow.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/StatSankeyBumpFlow.R) · [methods/scp-viz-statplots/code/statplot/code/fns/StatSankeyFlow.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/StatSankeyFlow.R) · [methods/scp-viz-statplots/code/statplot/code/fns/StatSankeyNode.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/StatSankeyNode.R) · [methods/scp-viz-statplots/code/statplot/code/fns/StatSankeyText.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/StatSankeyText.R) · [methods/scp-viz-statplots/code/statplot/code/fns/theme_alluvial.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/theme_alluvial.R) · [methods/scp-viz-statplots/code/statplot/code/fns/theme_blank.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/theme_blank.R) · [methods/scp-viz-statplots/code/statplot/code/fns/theme_sankey.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/theme_sankey.R) · [methods/scp-viz-statplots/code/statplot/code/fns/theme_sankey_bump.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/theme_sankey_bump.R) · [methods/scp-viz-statplots/code/statplot/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/fns/theme_scp.R) · [methods/scp-viz-statplots/code/statplot/code/module.R](/files/wiki/methods/scp-viz-statplots/code/statplot/code/module.R) · [methods/scp-viz-statplots/code/statplot/LICENSE.md](/files/wiki/methods/scp-viz-statplots/code/statplot/LICENSE.md) · [methods/scp-viz-statplots/code/statplot/resources/palette_list.rda](/files/wiki/methods/scp-viz-statplots/code/statplot/resources/palette_list.rda) · [methods/scp-viz-statplots/code/volcanoplot/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-statplots/code/volcanoplot/code/fns/palette_scp.R) · [methods/scp-viz-statplots/code/volcanoplot/code/fns/rescale.R](/files/wiki/methods/scp-viz-statplots/code/volcanoplot/code/fns/rescale.R) · [methods/scp-viz-statplots/code/volcanoplot/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-statplots/code/volcanoplot/code/fns/show_palettes.R) · [methods/scp-viz-statplots/code/volcanoplot/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-statplots/code/volcanoplot/code/fns/theme_scp.R) · [methods/scp-viz-statplots/code/volcanoplot/code/fns/VolcanoPlot.R](/files/wiki/methods/scp-viz-statplots/code/volcanoplot/code/fns/VolcanoPlot.R) · [methods/scp-viz-statplots/code/volcanoplot/code/fns/zero_range.R](/files/wiki/methods/scp-viz-statplots/code/volcanoplot/code/fns/zero_range.R) · [methods/scp-viz-statplots/code/volcanoplot/code/module.R](/files/wiki/methods/scp-viz-statplots/code/volcanoplot/code/module.R) · [methods/scp-viz-statplots/code/volcanoplot/LICENSE.md](/files/wiki/methods/scp-viz-statplots/code/volcanoplot/LICENSE.md) · [methods/scp-viz-statplots/code/volcanoplot/resources/palette_list.rda](/files/wiki/methods/scp-viz-statplots/code/volcanoplot/resources/palette_list.rda)

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 用途

复用已拆出的 SCP 0.5.6 原生绘图闭包。每个入口独立声明依赖；读取 Seurat 对象或原生结果，不强制转成 CSV。以下范围由当前字节的实际收据核对；资料确认与逐分支运行验证分别记录。

## 适用

已有符合下表的对象和上游结果，需要原生绘图形态；或由 agent 先选择分析家族，再按链路选择能消费该结果的绘图入口。已存在的 CSV 单 panel 模板继续服务表格数据。

## 不适用

不能把一个用例通过扩大到整函数、所有参数、Assay5 或所有 Seurat 5 对象。当前对象证据主要来自旧 Assay 示例；Assay5/layers 未普遍适配。原生像素/trace 对照不证明课题科学有效，也不代表作者确认。缺包须另列审批，模块不会自动安装。

## 输入

| 入口 | 输入语义 | 上游方法 | 输出 |
|---|---|---|---|
| `CellStatPlot` | Seurat 元数据 stat.by、group.by、split.by | 既有对象/表；不要求新跑分析 | 从细胞元数据调用分类统计图 |
| `FeatureCorPlot` | Seurat 中 features 的逐细胞表达及 group.by | 既有对象/表；不要求新跑分析 | 特征相关图 |
| `FeatureStatPlot` | Seurat features/元数据 stat.by，group.by 为细胞分组 | 既有对象/表；不要求新跑分析 | violin/box/bar/dot/col 数值分布或汇总 |
| `StatPlot` | meta.data：每行一个观测，stat.by 为统计分类，group.by 为分组 | 既有对象/表；不要求新跑分析 | 11 种分类计数、比例、流向与集合图 |
| `VolcanoPlot` | RunDEtest 后 Seurat tools 中 DEtest_<group_by> 的 AllMarkers_<test.use> 表 | [[methods/differential-expression]] | 差异表达指标与显著性展示 |

## 怎么做

先 `rwiki show scp-viz-statplots`；确认输入后 `rwiki use scp-viz-statplots --project <课题目录>`。该命令复制技术页的 code/ 与 runtime.json，收据和图样在 Wiki 查阅；进入副本，按 runtime.json 为目标分支选择 entry 文件，用 R 的 source() 加载，再调用该分支 entry_function。只加载所选入口，不加载整套 SCP。

本页输入通常是 R 会话中的 Seurat/结果对象，不能直接交给只读 CSV 的 rwiki render；rwiki run 面向 Rmd 配方。技术页没有自动换数据或执行路径。运行用例所需的示例 RDS、原生参考图和 driver 留在本机维护区；不会被当成课题数据复制。

每种形态只认可显式参数与实际比较收据的对应；表中的 not_run 表示本次没有这样的有效收据，不推断缺包。多个参数同时启用的已有用例不等于已完成“其余参数默认”的逐形态验收。

### CellStatPlot

细胞计数不能冒充独立患者数；共享 StatPlot 形态不表示所有包装路径均通过。

- 原始定义：`R/SCP-plot.R:4463-4490`；上游说明：`man/CellStatPlot.Rd`。
- 入口：`code/cellstatplot/code/module.R:CellStatPlot`；当前算法状态 `verified`，范围 `f_plot_type_upset`；独立性 `verified`。
- 收据：`verification/scp-cellstatplot-f_plot_type_upset-20261101T072722-15920-alg.json`。

| 参数 | 形态 | 当前证据 | 用例 |
|---|---|---|---|
| `stat_type` | `percent` | passed | f_stat_type_percent |
| `stat_type` | `count` | passed | f_stat_type_count |
| `position` | `stack` | passed | f_position_stack |
| `position` | `dodge` | passed | f_position_dodge |
| `plot_type` | `bar` | passed | f_position_dodge |
| `plot_type` | `rose` | passed | f_plot_type_rose |
| `plot_type` | `ring` | passed | f_plot_type_ring |
| `plot_type` | `pie` | passed | f_plot_type_pie |
| `plot_type` | `trend` | passed | f_plot_type_trend |
| `plot_type` | `area` | passed | f_plot_type_area |
| `plot_type` | `dot` | passed | f_plot_type_dot |
| `plot_type` | `sankey` | not_run | 无显式形态收据 |
| `plot_type` | `chord` | not_run | 无显式形态收据 |
| `plot_type` | `venn` | not_run | 无显式形态收据 |
| `plot_type` | `upset` | passed | f_plot_type_upset |

形态图样来自软件夹具的原生对照回放，不是来源原图或课题科学结论；只展示有输出哈希的通过用例。

**bar_celltype** · 收据 `verification/scp-cellstatplot-bar_celltype-20261026T152948-11976-alg.json`

![CellStatPlot bar_celltype 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/CellStatPlot-bar_celltype.png)

**f_plot_type_area** · 收据 `verification/scp-cellstatplot-f_plot_type_area-20261101T070928-7484-alg.json`

![CellStatPlot f_plot_type_area 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/CellStatPlot-f_plot_type_area.png)

**f_plot_type_dot** · 收据 `verification/scp-cellstatplot-f_plot_type_dot-20261101T070940-21968-alg.json`

![CellStatPlot f_plot_type_dot 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/CellStatPlot-f_plot_type_dot.png)

**f_plot_type_pie** · 收据 `verification/scp-cellstatplot-f_plot_type_pie-20261101T070906-14720-alg.json`

![CellStatPlot f_plot_type_pie 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/CellStatPlot-f_plot_type_pie.png)

**f_plot_type_ring** · 收据 `verification/scp-cellstatplot-f_plot_type_ring-20261101T070855-3708-alg.json`

![CellStatPlot f_plot_type_ring 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/CellStatPlot-f_plot_type_ring.png)

**f_plot_type_rose** · 收据 `verification/scp-cellstatplot-f_plot_type_rose-20261101T070844-11048-alg.json`

![CellStatPlot f_plot_type_rose 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/CellStatPlot-f_plot_type_rose.png)

**f_plot_type_trend** · 收据 `verification/scp-cellstatplot-f_plot_type_trend-20261101T070917-16792-alg.json`

![CellStatPlot f_plot_type_trend 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/CellStatPlot-f_plot_type_trend.png)

**f_plot_type_upset** · 收据 `verification/scp-cellstatplot-f_plot_type_upset-20261101T070952-18988-alg.json`

![CellStatPlot f_plot_type_upset 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/CellStatPlot-f_plot_type_upset.png)

**f_position_dodge** · 收据 `verification/scp-cellstatplot-f_position_dodge-20261101T070832-20600-alg.json`

![CellStatPlot f_position_dodge 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/CellStatPlot-f_position_dodge.png)

**f_position_stack** · 收据 `verification/scp-cellstatplot-f_position_stack-20261101T070821-20932-alg.json`

![CellStatPlot f_position_stack 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/CellStatPlot-f_position_stack.png)

**f_stat_type_count** · 收据 `verification/scp-cellstatplot-f_stat_type_count-20261101T070810-20832-alg.json`

![CellStatPlot f_stat_type_count 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/CellStatPlot-f_stat_type_count.png)

**f_stat_type_percent** · 收据 `verification/scp-cellstatplot-f_stat_type_percent-20261101T070759-13468-alg.json`

![CellStatPlot f_stat_type_percent 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/CellStatPlot-f_stat_type_percent.png)


### FeatureCorPlot

相关不代表因果；细胞与生物学重复单位要区分，不能仅凭列名复用。

**计算边界（2026-11-12 源码复核）**：此入口接收 Seurat 表达/元数据，并非只展示上游已算好的相关表。它始终按所选细胞、特征与 `split.by` 调用 `proxyC::simil`；默认 `cor_method="pearson"`，Spearman 分支先做秩变换。默认 `add_smooth=TRUE`、`add_r2=TRUE`、`add_pvalue=TRUE`，会拟合线性模型并计算 R²/斜率检验 p 值；图上的这项 p 值不能冒充预先给定的相关检验结果。即使把四个 `add_smooth/add_equation/add_r2/add_pvalue` 全关，也仍计算相似度矩阵，不存在完全无计算的原生模式。

若课题已固定相关系数、p 值或样本层级检验，使用消费预计算表的模板，不再用本函数重算。需要本函数计算时，先显式固定细胞/生物学样本单位、assay/slot、特征、分组、相关方式和四个开关；不得把细胞数当独立生物学重复。这里仅说明真实行为，未更改算法，也未把下表 not_run 形态升级为通过。

- 原始定义：`R/SCP-plot.R:5232-5624`；上游说明：`man/FeatureCorPlot.Rd`。
- 入口：`code/featurecorplot/code/module.R:FeatureCorPlot`；当前算法状态 `verified`，范围 `two_markers`；独立性 `verified`。
- 收据：`verification/scp-featurecorplot-two_markers-20261101T072731-6580-alg.json`。

| 参数 | 形态 | 当前证据 | 用例 |
|---|---|---|---|
| `cor_method` | `pearson` | not_run | 无显式形态收据 |
| `cor_method` | `spearman` | not_run | 无显式形态收据 |
| `cor_method` | `kendall` | not_run | 无显式形态收据 |

形态图样来自软件夹具的原生对照回放，不是来源原图或课题科学结论；只展示有输出哈希的通过用例。

**two_markers** · 收据 `verification/scp-featurecorplot-two_markers-20261026T153002-23016-alg.json`

![FeatureCorPlot two_markers 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/FeatureCorPlot-two_markers.png)


### FeatureStatPlot

默认逐细胞展示；检验与汇总的统计单位、配对及多重比较需课题确认。

**计算与展示边界（2026-11-12 源码复核）**：入口读取表达/元数据后转交 `ExpressionStatPlot`。`comparisons` 非空会添加 `ggpubr::stat_compare_means`，`multiplegroup_comparisons=TRUE` 也会重新做多组检验；默认方法分别为 `wilcox.test` 与 `kruskal.test`。这些是计算入口，不是显示上游 p 值的开关；`ref_group`、分组与 split 必须由课题显式给出。

只要展示、不重新检验时，显式设置 `comparisons=NULL, multiplegroup_comparisons=FALSE, add_stat="none", calculate_coexp=FALSE`；小提琴、箱线、直方/点等几何仍会计算其描述性分布，不能据此宣称无汇总计算。`add_stat="mean"/"median"` 会再计算描述统计，点/柱等形式也可能按表达值汇总。若连这些汇总也由上游固定，改用消费预计算表的模板。已有收据不证明样本级推断、配对设计或未覆盖开关已被验证。

- 原始定义：`R/SCP-plot.R:3524-3718`；上游说明：`man/FeatureStatPlot.Rd`。
- 入口：`code/featurestatplot/code/module.R:FeatureStatPlot`；当前算法状态 `verified`，范围 `f_add_stat_mean`；独立性 `verified`。
- 收据：`verification/scp-featurestatplot-f_add_stat_mean-20261101T072744-15780-alg.json`。

| 参数 | 形态 | 当前证据 | 用例 |
|---|---|---|---|
| `plot_type` | `violin` | passed | f_add_stat_mean |
| `plot_type` | `box` | passed | box |
| `plot_type` | `bar` | passed | bar |
| `plot_type` | `dot` | passed | dot |
| `plot_type` | `col` | passed | col |
| `plot.by` | `group` | passed | f_plot_by_group |
| `plot.by` | `feature` | not_run | 无显式形态收据 |
| `fill.by` | `group` | passed | f_fill_by_group |
| `fill.by` | `feature` | not_run | 无显式形态收据 |
| `fill.by` | `expression` | passed | f_fill_by_expression |
| `add_stat` | `none` | passed | f_add_stat_none |
| `add_stat` | `mean` | passed | f_add_stat_mean |
| `add_stat` | `median` | not_run | 无显式形态收据 |
| `sig_label` | `p.signif` | not_run | 无显式形态收据 |
| `sig_label` | `p.format` | not_run | 无显式形态收据 |

形态图样来自软件夹具的原生对照回放，不是来源原图或课题科学结论；只展示有输出哈希的通过用例。

**bar** · 收据 `verification/scp-featurestatplot-bar-20261026T153120-10136-alg.json`

![FeatureStatPlot bar 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/FeatureStatPlot-bar.png)

**box** · 收据 `verification/scp-featurestatplot-box-20261026T153054-26704-alg.json`

![FeatureStatPlot box 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/FeatureStatPlot-box.png)

**col** · 收据 `verification/scp-featurestatplot-col-20261026T153207-21212-alg.json`

![FeatureStatPlot col 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/FeatureStatPlot-col.png)

**dot** · 收据 `verification/scp-featurestatplot-dot-20261026T153141-9292-alg.json`

![FeatureStatPlot dot 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/FeatureStatPlot-dot.png)

**f_add_stat_mean** · 收据 `verification/scp-featurestatplot-f_add_stat_mean-20261101T071100-10360-alg.json`

![FeatureStatPlot f_add_stat_mean 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/FeatureStatPlot-f_add_stat_mean.png)

**f_add_stat_none** · 收据 `verification/scp-featurestatplot-f_add_stat_none-20261101T071047-18232-alg.json`

![FeatureStatPlot f_add_stat_none 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/FeatureStatPlot-f_add_stat_none.png)

**f_fill_by_expression** · 收据 `verification/scp-featurestatplot-f_fill_by_expression-20261101T071034-12344-alg.json`

![FeatureStatPlot f_fill_by_expression 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/FeatureStatPlot-f_fill_by_expression.png)

**f_fill_by_group** · 收据 `verification/scp-featurestatplot-f_fill_by_group-20261101T071020-15652-alg.json`

![FeatureStatPlot f_fill_by_group 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/FeatureStatPlot-f_fill_by_group.png)

**f_plot_by_group** · 收据 `verification/scp-featurestatplot-f_plot_by_group-20261101T071006-9640-alg.json`

![FeatureStatPlot f_plot_by_group 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/FeatureStatPlot-f_plot_by_group.png)

**violin** · 收据 `verification/scp-featurestatplot-violin-20261026T153024-17908-alg.json`

![FeatureStatPlot violin 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/FeatureStatPlot-violin.png)


### StatPlot

venn/upset 需要显式集合成员编码；计数和百分比的分母必须核对。

- 原始定义：`R/SCP-plot.R:4564-5159`；上游说明：`man/StatPlot.Rd`。
- 入口：`code/statplot/code/module.R:StatPlot`；当前算法状态 `verified`，范围 `f_position_dodge`；独立性 `verified`。
- 收据：`verification/scp-statplot-f_position_dodge-20261101T072746-13688-alg.json`。

| 参数 | 形态 | 当前证据 | 用例 |
|---|---|---|---|
| `stat_type` | `percent` | passed | pie |
| `stat_type` | `count` | passed | f_position_dodge |
| `position` | `stack` | passed | f_position_stack |
| `position` | `dodge` | passed | f_position_dodge |
| `plot_type` | `bar` | passed | f_position_dodge |
| `plot_type` | `rose` | passed | rose |
| `plot_type` | `ring` | passed | ring |
| `plot_type` | `pie` | passed | pie |
| `plot_type` | `trend` | passed | trend |
| `plot_type` | `area` | passed | area |
| `plot_type` | `dot` | passed | dot |
| `plot_type` | `sankey` | not_run | 无显式形态收据 |
| `plot_type` | `chord` | passed | chord |
| `plot_type` | `venn` | not_run | 无显式形态收据 |
| `plot_type` | `upset` | passed | upset |

形态图样来自软件夹具的原生对照回放，不是来源原图或课题科学结论；只展示有输出哈希的通过用例。

**area** · 收据 `verification/scp-statplot-area-20261026T153247-33292-alg.json`

![StatPlot area 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/StatPlot-area.png)

**bar** · 收据 `verification/scp-statplot-bar-20261026T153224-23772-alg.json`

![StatPlot bar 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/StatPlot-bar.png)

**chord** · 收据 `verification/scp-statplot-chord-20261026T153304-3644-alg.json`

![StatPlot chord 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/StatPlot-chord.png)

**dot** · 收据 `verification/scp-statplot-dot-20261026T153254-21080-alg.json`

![StatPlot dot 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/StatPlot-dot.png)

**f_position_dodge** · 收据 `verification/scp-statplot-f_position_dodge-20261101T071103-22416-alg.json`

![StatPlot f_position_dodge 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/StatPlot-f_position_dodge.png)

**f_position_stack** · 收据 `verification/scp-statplot-f_position_stack-20261101T071102-15136-alg.json`

![StatPlot f_position_stack 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/StatPlot-f_position_stack.png)

**pie** · 收据 `verification/scp-statplot-pie-20261026T153238-28252-alg.json`

![StatPlot pie 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/StatPlot-pie.png)

**ring** · 收据 `verification/scp-statplot-ring-20261026T153233-27176-alg.json`

![StatPlot ring 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/StatPlot-ring.png)

**rose** · 收据 `verification/scp-statplot-rose-20261026T153228-25996-alg.json`

![StatPlot rose 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/StatPlot-rose.png)

**trend** · 收据 `verification/scp-statplot-trend-20261026T153243-23940-alg.json`

![StatPlot trend 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/StatPlot-trend.png)

**upset** · 收据 `verification/scp-statplot-upset-20261026T153315-22464-alg.json`

![StatPlot upset 软件夹具回放](/files/wiki/methods/scp-viz-statplots/verification/previews/StatPlot-upset.png)


### VolcanoPlot

原生签名没有 res 参数；x_metric 默认 diff_pct，不自动等同 avg_log2FC。

- 原始定义：`R/SCP-plot.R:7088-7194`；上游说明：`man/VolcanoPlot.Rd`。
- 入口：`code/volcanoplot/code/module.R:VolcanoPlot`；当前算法状态 `verified`，范围 `positive_native_material`；独立性 `verified`。
- 收据：`verification/scp-volcanoplot-positive_native_material-20261101T072804-15236-alg.json`。


**positive_native_material** · 软件夹具回放 · 收据 `verification/scp-volcanoplot-positive_native_material-20261101T072804-15236-alg.json`

![VolcanoPlot positive_native_material](/files/wiki/methods/scp-viz-statplots/verification/previews/VolcanoPlot-positive_native_material.png)

## 代码

runtime.json 列出逐入口闭包、必需/可选依赖、资源用途和原始函数位置；code/、资源与许可证按已有字节保存。GPL 源码及派生代码留本机，不进入 Git。收据仅按它实际执行的代码哈希解释。

## 输出

输出类型见输入表。形态及当前收据对应关系另见 `contracts.json`；它是审计索引，不是新运行收据。缺上游、缺依赖或原生失败的记录继续保留。

## 知识关联检查

全量函数去向见 [[methods/scp-source-catalog|SCP 全库来源与入口索引]]；CSV 接口与旧模板见 [[methods/scp-visualization-interface|绘图函数与接口映射]]。本页 method_kind=technical，不新增分析家族，不用结构相似代替科学直连。

## 使用记录

2026-11-01：接续 10 月隔离区已完成的代码与真实收据，核对当前字节并整理为 draft 技术入口。没有代作者签核，也没有把本批入库记作课题使用。

## 本机组学课题来源增量（2026-11-02）

项目中的 FeatureStatPlot 记录为依赖调用；CellStatPlot 仅为相近既有入口，本批静态调用未发现它。汇总/统计选项需逐形态核对，未运行。 来源清单见 [[methods/uc-ptm-source-catalog]]、[[methods/asthma-lactylation-source-catalog]]；具体实现与原始路径对照见 [[methods/local-omics-analysis-guide]]，图形调用见 [[methods/local-omics-visualization-guide]]。本段只补知识与来源，不更改现有实现、运行/独立性收据、状态或作者确认。

## 资料确认记录（2026-11-02）

作者在对话中明确授权 agent 代处理当前“待你确认”队列。本轮核对笔记用途、输入边界、知识关联和现有收据后，经正式批量确认入口记录资料审阅。ready 仅表示本技术/流程资料已确认；不会把未运行、缺依赖、未覆盖参数或其他版本变成已验证，也不代表整个课题或科学有效性验收。正文此前带日期的 draft/来源归档说明为当时历史记录，当前资料状态以前置信息和本次验收记录为准。

<!-- user:start -->
<!-- user:end -->
