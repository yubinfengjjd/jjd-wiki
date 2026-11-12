---
type: method
id: scp-viz-heatmaps
title: 单细胞表达与动态热图入口
status: ready
inputs: []
outputs: []
license: GPL-3
favorite: false
implementations:
- id: scp-cellcorheatmap
  title: SCP CellCorHeatmap 原生实现
  language: R
  entrypoint: code/cellcorheatmap/code/module.R:CellCorHeatmap
  dependencies:
  - ComplexHeatmap
  - Matrix
  - SeuratObject
  - circlize
  - ggplot2
  - grid
  - methods
  - rlang
  note: 可视化入口
- id: scp-dynamicheatmap
  title: SCP DynamicHeatmap 原生实现
  language: R
  entrypoint: code/dynamicheatmap/code/module.R:DynamicHeatmap
  dependencies:
  - ComplexHeatmap
  - Matrix
  - SeuratObject
  - circlize
  - grid
  - methods
  - rlang
  - stats
  - utils
  verification: verification/scp-dynamicheatmap-f_exp_method_raw-20261101T072104-12072-alg.json
  note: 可视化入口
- id: scp-featureheatmap
  title: SCP FeatureHeatmap 原生实现
  language: R
  entrypoint: code/featureheatmap/code/module.R:FeatureHeatmap
  dependencies:
  - ComplexHeatmap
  - Matrix
  - Seurat
  - SeuratObject
  - grid
  - methods
  - rlang
  - stats
  verification: verification/scp-featureheatmap-default-20261101T072115-19668-alg.json
  note: 可视化入口
- id: scp-groupheatmap
  title: SCP GroupHeatmap 原生实现
  language: R
  entrypoint: code/groupheatmap/code/module.R:GroupHeatmap
  dependencies:
  - ComplexHeatmap
  - Matrix
  - Seurat
  - SeuratObject
  - ggplot2
  - grid
  - methods
  - rlang
  - stats
  verification: verification/scp-groupheatmap-annotation-20261101T072128-6744-alg.json
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
summary: SCP 原生绘图实现的对象输入、上游链路、独立闭包及逐形态证据；资料确认不授予额外分支验证，不作为新分析家族。
data_contract:
  input: CellCorHeatmap：srt_query，可选 srt_ref/bulk_ref、分组、features 或降维表示；DynamicHeatmap：Seurat
    lineages 拟时序列、features；use_fitted 需要相应 DynamicFeatures 结果；FeatureHeatmap：Seurat
    features × cells 表达矩阵及细胞分组/注释；GroupHeatmap：Seurat 表达矩阵、features、group.by；按组聚合并可选阳性比例
  output: CellCorHeatmap：查询/参考相似度矩阵热图；DynamicHeatmap：沿拟时序排序的动态表达热图；FeatureHeatmap：细胞级表达热图；GroupHeatmap：分组表达热图、点阵及附加分布
keywords:
- SCP
- Seurat
- 原生绘图
- 形态验证
- CellCorHeatmap
- DynamicHeatmap
- FeatureHeatmap
- GroupHeatmap
---
# 单细胞表达与动态热图入口

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)
- 标签：single-cell、transcriptomics
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/scp-viz-heatmaps/code/cellcorheatmap/LICENSE.md](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/LICENSE.md) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/Blend2Color.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/Blend2Color.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/BlendRGBList.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/BlendRGBList.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/CellCorHeatmap.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/CellCorHeatmap.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/CellStatPlot.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/CellStatPlot.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/ExpressionStatPlot.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/ExpressionStatPlot.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/FeatureStatPlot.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/FeatureStatPlot.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/FindConservedMarkers2.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/FindConservedMarkers2.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/RGBA2RGB.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/RGBA2RGB.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/RunDEtest.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/RunDEtest.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/RunKNNPredict.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/RunKNNPredict.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/StatPlot.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/StatPlot.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/StatSankeyBumpFlow.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/StatSankeyBumpFlow.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/StatSankeyFlow.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/StatSankeyFlow.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/StatSankeyNode.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/StatSankeyNode.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/StatSankeyText.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/StatSankeyText.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/add_grob.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/add_grob.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/asMatrix.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/asMatrix.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/as_grob.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/as_grob.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/as_gtable.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/as_gtable.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/as_matrix.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/as_matrix.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/blendcolors.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/blendcolors.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/build_patchwork.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/build_patchwork.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/capitalize.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/capitalize.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/check_DataType.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/check_DataType.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/find_default_space.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/find_default_space.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/geom_alluvial.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/geom_alluvial.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/geom_alluvial_label.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/geom_alluvial_label.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/geom_alluvial_text.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/geom_alluvial_text.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/geom_sankey.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/geom_sankey.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/geom_sankey_bump.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/geom_sankey_bump.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/geom_sankey_label.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/geom_sankey_label.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/geom_sankey_text.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/geom_sankey_text.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/get_legend.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/get_legend.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/heatmap_fixsize.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/heatmap_fixsize.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/heatmap_rendersize.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/heatmap_rendersize.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/make_long.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/make_long.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/maximump.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/maximump.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/meanp.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/meanp.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/metap.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/metap.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/minimump.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/minimump.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/palette_scp.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/panel_fix_overall.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/panel_fix_overall.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/patchworkGrob.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/patchworkGrob.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/prepare_params.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/prepare_params.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/show_palettes.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/sigmoid.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/sigmoid.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/sump.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/sump.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/theme_alluvial.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/theme_alluvial.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/theme_blank.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/theme_blank.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/theme_sankey.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/theme_sankey.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/theme_sankey_bump.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/theme_sankey_bump.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/theme_scp.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/votep.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/votep.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/wilkinsonp.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/fns/wilkinsonp.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/code/module.R](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/code/module.R) · [methods/scp-viz-heatmaps/code/cellcorheatmap/resources/palette_list.rda](/files/wiki/methods/scp-viz-heatmaps/code/cellcorheatmap/resources/palette_list.rda) · [methods/scp-viz-heatmaps/code/dynamicheatmap/LICENSE.md](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/LICENSE.md) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/Blend2Color.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/Blend2Color.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/BlendRGBList.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/BlendRGBList.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/CellDensityPlot.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/CellDensityPlot.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/DynamicHeatmap.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/DynamicHeatmap.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/DynamicPlot.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/DynamicPlot.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/GeneConvert.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/GeneConvert.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/ListDB.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/ListDB.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/PrepareDB.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/PrepareDB.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/RGBA2RGB.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/RGBA2RGB.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/RunDynamicFeatures.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/RunDynamicFeatures.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/RunEnrichment.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/RunEnrichment.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/add_grob.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/add_grob.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/asMatrix.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/asMatrix.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/as_grob.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/as_grob.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/as_gtable.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/as_gtable.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/as_matrix.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/as_matrix.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/blendcolors.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/blendcolors.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/build_patchwork.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/build_patchwork.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/capitalize.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/capitalize.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/check_DataType.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/check_DataType.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/cluster_within_group2.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/cluster_within_group2.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/fc_matrix.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/fc_matrix.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/get_legend.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/get_legend.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/heatmap_enrichment.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/heatmap_enrichment.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/heatmap_fixsize.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/heatmap_fixsize.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/heatmap_rendersize.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/heatmap_rendersize.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/kegg_get.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/kegg_get.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/log1p_matrix.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/log1p_matrix.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/log2fc_matrix.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/log2fc_matrix.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/matrix_process.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/matrix_process.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/mestimate.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/mestimate.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/palette_scp.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/panel_fix_overall.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/panel_fix_overall.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/patchworkGrob.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/patchworkGrob.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/rescale.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/rescale.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/searchDatasets.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/searchDatasets.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/show_palettes.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/standardise.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/standardise.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/theme_scp.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/try_get.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/try_get.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/unnest.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/unnest.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/zero_range.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/zero_range.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/zscore_matrix.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/fns/zscore_matrix.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/code/module.R](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/code/module.R) · [methods/scp-viz-heatmaps/code/dynamicheatmap/resources/palette_list.rda](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/resources/palette_list.rda) · [methods/scp-viz-heatmaps/code/dynamicheatmap/resources/words_excluded.rda](/files/wiki/methods/scp-viz-heatmaps/code/dynamicheatmap/resources/words_excluded.rda) · [methods/scp-viz-heatmaps/code/featureheatmap/LICENSE.md](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/LICENSE.md) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/Blend2Color.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/Blend2Color.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/BlendRGBList.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/BlendRGBList.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/FeatureHeatmap.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/FeatureHeatmap.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/GeneConvert.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/GeneConvert.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/ListDB.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/ListDB.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/PrepareDB.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/PrepareDB.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/RGBA2RGB.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/RGBA2RGB.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/RunEnrichment.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/RunEnrichment.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/asMatrix.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/asMatrix.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/as_grob.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/as_grob.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/as_gtable.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/as_gtable.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/as_matrix.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/as_matrix.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/blendcolors.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/blendcolors.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/build_patchwork.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/build_patchwork.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/capitalize.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/capitalize.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/cluster_within_group2.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/cluster_within_group2.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/fc_matrix.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/fc_matrix.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/heatmap_enrichment.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/heatmap_enrichment.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/heatmap_fixsize.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/heatmap_fixsize.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/heatmap_rendersize.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/heatmap_rendersize.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/kegg_get.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/kegg_get.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/log1p_matrix.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/log1p_matrix.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/log2fc_matrix.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/log2fc_matrix.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/matrix_process.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/matrix_process.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/mestimate.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/mestimate.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/palette_scp.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/panel_fix_overall.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/panel_fix_overall.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/patchworkGrob.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/patchworkGrob.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/rescale.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/rescale.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/searchDatasets.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/searchDatasets.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/show_palettes.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/standardise.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/standardise.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/theme_scp.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/try_get.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/try_get.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/unnest.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/unnest.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/zero_range.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/zero_range.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/fns/zscore_matrix.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/fns/zscore_matrix.R) · [methods/scp-viz-heatmaps/code/featureheatmap/code/module.R](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/code/module.R) · [methods/scp-viz-heatmaps/code/featureheatmap/resources/palette_list.rda](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/resources/palette_list.rda) · [methods/scp-viz-heatmaps/code/featureheatmap/resources/words_excluded.rda](/files/wiki/methods/scp-viz-heatmaps/code/featureheatmap/resources/words_excluded.rda) · [methods/scp-viz-heatmaps/code/groupheatmap/LICENSE.md](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/LICENSE.md) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/Blend2Color.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/Blend2Color.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/BlendRGBList.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/BlendRGBList.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/CellStatPlot.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/CellStatPlot.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/ExpressionStatPlot.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/ExpressionStatPlot.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/FeatureStatPlot.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/FeatureStatPlot.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/GeneConvert.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/GeneConvert.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/GroupHeatmap.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/GroupHeatmap.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/ListDB.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/ListDB.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/PrepareDB.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/PrepareDB.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/RGBA2RGB.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/RGBA2RGB.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/RunEnrichment.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/RunEnrichment.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/StatPlot.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/StatPlot.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/StatSankeyBumpFlow.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/StatSankeyBumpFlow.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/StatSankeyFlow.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/StatSankeyFlow.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/StatSankeyNode.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/StatSankeyNode.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/StatSankeyText.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/StatSankeyText.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/add_grob.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/add_grob.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/adjcolors.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/adjcolors.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/asMatrix.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/asMatrix.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/as_grob.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/as_grob.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/as_gtable.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/as_gtable.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/as_matrix.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/as_matrix.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/blendcolors.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/blendcolors.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/build_patchwork.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/build_patchwork.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/capitalize.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/capitalize.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/check_DataType.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/check_DataType.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/cluster_within_group2.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/cluster_within_group2.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/extractgrobs.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/extractgrobs.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/fc_matrix.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/fc_matrix.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/find_default_space.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/find_default_space.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/geom_alluvial.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/geom_alluvial.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/geom_alluvial_label.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/geom_alluvial_label.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/geom_alluvial_text.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/geom_alluvial_text.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/geom_sankey.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/geom_sankey.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/geom_sankey_bump.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/geom_sankey_bump.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/geom_sankey_label.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/geom_sankey_label.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/geom_sankey_text.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/geom_sankey_text.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/get_legend.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/get_legend.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/grid_draw.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/grid_draw.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/heatmap_enrichment.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/heatmap_enrichment.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/heatmap_fixsize.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/heatmap_fixsize.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/heatmap_rendersize.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/heatmap_rendersize.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/kegg_get.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/kegg_get.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/log1p_matrix.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/log1p_matrix.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/log2fc_matrix.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/log2fc_matrix.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/make_long.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/make_long.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/matrix_process.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/matrix_process.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/mestimate.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/mestimate.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/palette_scp.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/panel_fix_overall.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/panel_fix_overall.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/patchworkGrob.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/patchworkGrob.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/prepare_params.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/prepare_params.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/rescale.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/rescale.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/searchDatasets.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/searchDatasets.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/show_palettes.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/sigmoid.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/sigmoid.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/standardise.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/standardise.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/theme_alluvial.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/theme_alluvial.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/theme_blank.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/theme_blank.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/theme_sankey.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/theme_sankey.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/theme_sankey_bump.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/theme_sankey_bump.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/theme_scp.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/try_get.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/try_get.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/unnest.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/unnest.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/zero_range.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/zero_range.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/fns/zscore_matrix.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/fns/zscore_matrix.R) · [methods/scp-viz-heatmaps/code/groupheatmap/code/module.R](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/code/module.R) · [methods/scp-viz-heatmaps/code/groupheatmap/resources/palette_list.rda](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/resources/palette_list.rda) · [methods/scp-viz-heatmaps/code/groupheatmap/resources/words_excluded.rda](/files/wiki/methods/scp-viz-heatmaps/code/groupheatmap/resources/words_excluded.rda)

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
| `CellCorHeatmap` | srt_query，可选 srt_ref/bulk_ref、分组、features 或降维表示 | [[methods/cell-type-annotation]] | 查询/参考相似度矩阵热图 |
| `DynamicHeatmap` | Seurat lineages 拟时序列、features；use_fitted 需要相应 DynamicFeatures 结果 | [[methods/dynamic-feature-analysis]] | 沿拟时序排序的动态表达热图 |
| `FeatureHeatmap` | Seurat features × cells 表达矩阵及细胞分组/注释 | 既有对象/表；不要求新跑分析 | 细胞级表达热图 |
| `GroupHeatmap` | Seurat 表达矩阵、features、group.by；按组聚合并可选阳性比例 | 既有对象/表；不要求新跑分析 | 分组表达热图、点阵及附加分布 |

## 怎么做

先 `rwiki show scp-viz-heatmaps`；确认输入后 `rwiki use scp-viz-heatmaps --project <课题目录>`。该命令复制技术页的 code/ 与 runtime.json，收据和图样在 Wiki 查阅；进入副本，按 runtime.json 为目标分支选择 entry 文件，用 R 的 source() 加载，再调用该分支 entry_function。只加载所选入口，不加载整套 SCP。

本页输入通常是 R 会话中的 Seurat/结果对象，不能直接交给只读 CSV 的 rwiki render；rwiki run 面向 Rmd 配方。技术页没有自动换数据或执行路径。运行用例所需的示例 RDS、原生参考图和 driver 留在本机维护区；不会被当成课题数据复制。

每种形态只认可显式参数与实际比较收据的对应；表中的 not_run 表示本次没有这样的有效收据，不推断缺包。多个参数同时启用的已有用例不等于已完成“其余参数默认”的逐形态验收。

### CellCorHeatmap

当前未验证原因：原生 self_cor 调用失败：No cell overlap between new meta data and Seurat object；缺缓存或参数变化会自动调用 RunKNNPredict，可能含特征选择和 DE，不是纯绘图。

query/ref 细胞或组粒度由 collapsing 参数控制；当前 self_cor 夹具存在原生失败。

- 原始定义：`R/SCP-plot.R:10113-10888`；上游说明：`man/CellCorHeatmap.Rd`。
- 入口：`code/cellcorheatmap/code/module.R:CellCorHeatmap`；当前算法状态 `not_run`，范围 `无通过收据`；独立性 `declared`。

| 参数 | 形态 | 当前证据 | 用例 |
|---|---|---|---|
| `features_type` | `HVF` | not_run | 无显式形态收据 |
| `features_type` | `DE` | not_run | 无显式形态收据 |

### DynamicHeatmap

表达变换、基因筛选、细胞分箱会影响结果；不能把拟时序解释成真实时间。

- 原始定义：`R/SCP-plot.R:11020-12022`；上游说明：`man/DynamicHeatmap.Rd`。
- 入口：`code/dynamicheatmap/code/module.R:DynamicHeatmap`；当前算法状态 `verified`，范围 `f_exp_method_raw`；独立性 `verified`。
- 收据：`verification/scp-dynamicheatmap-f_exp_method_raw-20261101T072104-12072-alg.json`。

| 参数 | 形态 | 当前证据 | 用例 |
|---|---|---|---|
| `split_method` | `mfuzz` | not_run | 无显式形态收据 |
| `split_method` | `kmeans` | not_run | 无显式形态收据 |
| `split_method` | `kmeans-peaktime` | not_run | 无显式形态收据 |
| `split_method` | `hclust` | passed | f_exp_method_raw |
| `split_method` | `hclust-peaktime` | passed | f_split_method_hclust_peaktime |
| `order_by` | `peaktime` | passed | f_order_by_peaktime |
| `order_by` | `valleytime` | passed | f_order_by_valleytime |
| `exp_method` | `zscore` | not_run | 无显式形态收据 |
| `exp_method` | `raw` | passed | f_exp_method_raw |
| `exp_method` | `fc` | not_run | 无显式形态收据 |
| `exp_method` | `log2fc` | not_run | 无显式形态收据 |
| `exp_method` | `log1p` | not_run | 无显式形态收据 |

形态图样来自软件夹具的原生对照回放，不是来源原图或课题科学结论；只展示有输出哈希的通过用例。

**f_exp_method_raw** · 收据 `verification/scp-dynamicheatmap-f_exp_method_raw-20261101T070746-11884-alg.json`

![DynamicHeatmap f_exp_method_raw 软件夹具回放](/files/wiki/methods/scp-viz-heatmaps/verification/previews/DynamicHeatmap-f_exp_method_raw.png)

**f_order_by_peaktime** · 收据 `verification/scp-dynamicheatmap-f_order_by_peaktime-20261101T070613-8160-alg.json`

![DynamicHeatmap f_order_by_peaktime 软件夹具回放](/files/wiki/methods/scp-viz-heatmaps/verification/previews/DynamicHeatmap-f_order_by_peaktime.png)

**f_order_by_valleytime** · 收据 `verification/scp-dynamicheatmap-f_order_by_valleytime-20261101T070700-8024-alg.json`

![DynamicHeatmap f_order_by_valleytime 软件夹具回放](/files/wiki/methods/scp-viz-heatmaps/verification/previews/DynamicHeatmap-f_order_by_valleytime.png)

**f_split_method_hclust_peaktime** · 收据 `verification/scp-dynamicheatmap-f_split_method_hclust_peaktime-20261101T070521-4548-alg.json`

![DynamicHeatmap f_split_method_hclust_peaktime 软件夹具回放](/files/wiki/methods/scp-viz-heatmaps/verification/previews/DynamicHeatmap-f_split_method_hclust_peaktime.png)


### FeatureHeatmap

与 GroupHeatmap 的按组汇总不同；split、注释与聚类是独立形态。

- 原始定义：`R/SCP-plot.R:9114-9978`；上游说明：`man/FeatureHeatmap.Rd`。
- 入口：`code/featureheatmap/code/module.R:FeatureHeatmap`；当前算法状态 `verified`，范围 `default`；独立性 `verified`。
- 收据：`verification/scp-featureheatmap-default-20261101T072115-19668-alg.json`。

| 参数 | 形态 | 当前证据 | 用例 |
|---|---|---|---|
| `split_method` | `kmeans` | not_run | 无显式形态收据 |
| `split_method` | `hclust` | not_run | 无显式形态收据 |
| `split_method` | `mfuzz` | not_run | 无显式形态收据 |
| `exp_method` | `zscore` | not_run | 无显式形态收据 |
| `exp_method` | `raw` | not_run | 无显式形态收据 |
| `exp_method` | `fc` | not_run | 无显式形态收据 |
| `exp_method` | `log2fc` | not_run | 无显式形态收据 |
| `exp_method` | `log1p` | not_run | 无显式形态收据 |
| `features_type` | `HVF` | not_run | 无显式形态收据 |
| `features_type` | `DE` | not_run | 无显式形态收据 |

形态图样来自软件夹具的原生对照回放，不是来源原图或课题科学结论；只展示有输出哈希的通过用例。

**default** · 收据 `verification/scp-featureheatmap-default-20261026T152344-8892-alg.json`

![FeatureHeatmap default 软件夹具回放](/files/wiki/methods/scp-viz-heatmaps/verification/previews/FeatureHeatmap-default.png)


### GroupHeatmap

exp_method/点大小/阈值语义分别核对；组均值不能反推阳性细胞比例。

- 原始定义：`R/SCP-plot.R:7911-9036`；上游说明：`man/GroupHeatmap.Rd`。
- 入口：`code/groupheatmap/code/module.R:GroupHeatmap`；当前算法状态 `verified`，范围 `annotation`；独立性 `verified`。
- 收据：`verification/scp-groupheatmap-annotation-20261101T072128-6744-alg.json`。

| 参数 | 形态 | 当前证据 | 用例 |
|---|---|---|---|
| `split_method` | `kmeans` | passed | kmeans_split |
| `split_method` | `hclust` | not_run | 无显式形态收据 |
| `split_method` | `mfuzz` | not_run | 无显式形态收据 |
| `exp_method` | `zscore` | not_run | 无显式形态收据 |
| `exp_method` | `raw` | passed | raw_exp |
| `exp_method` | `fc` | not_run | 无显式形态收据 |
| `exp_method` | `log2fc` | not_run | 无显式形态收据 |
| `exp_method` | `log1p` | not_run | 无显式形态收据 |
| `features_type` | `HVF` | not_run | 无显式形态收据 |
| `features_type` | `DE` | not_run | 无显式形态收据 |

形态图样来自软件夹具的原生对照回放，不是来源原图或课题科学结论；只展示有输出哈希的通过用例。

**annotation** · 收据 `verification/scp-groupheatmap-annotation-20261026T152726-11680-alg.json`

![GroupHeatmap annotation 软件夹具回放](/files/wiki/methods/scp-viz-heatmaps/verification/previews/GroupHeatmap-annotation.png)

**default** · 收据 `verification/scp-groupheatmap-default-20261026T152359-20724-alg.json`

![GroupHeatmap default 软件夹具回放](/files/wiki/methods/scp-viz-heatmaps/verification/previews/GroupHeatmap-default.png)

**dot_flip** · 收据 `verification/scp-groupheatmap-dot_flip-20261026T152653-24456-alg.json`

![GroupHeatmap dot_flip 软件夹具回放](/files/wiki/methods/scp-viz-heatmaps/verification/previews/GroupHeatmap-dot_flip.png)

**flip** · 收据 `verification/scp-groupheatmap-flip-20261026T152513-37732-alg.json`

![GroupHeatmap flip 软件夹具回放](/files/wiki/methods/scp-viz-heatmaps/verification/previews/GroupHeatmap-flip.png)

**kmeans_split** · 收据 `verification/scp-groupheatmap-kmeans_split-20261026T152427-8448-alg.json`

![GroupHeatmap kmeans_split 软件夹具回放](/files/wiki/methods/scp-viz-heatmaps/verification/previews/GroupHeatmap-kmeans_split.png)

**raw_exp** · 收据 `verification/scp-groupheatmap-raw_exp-20261026T152446-17412-alg.json`

![GroupHeatmap raw_exp 软件夹具回放](/files/wiki/methods/scp-viz-heatmaps/verification/previews/GroupHeatmap-raw_exp.png)

**split_dot_reticle** · 收据 `verification/scp-groupheatmap-split_dot_reticle-20261026T152708-16988-alg.json`

![GroupHeatmap split_dot_reticle 软件夹具回放](/files/wiki/methods/scp-viz-heatmaps/verification/previews/GroupHeatmap-split_dot_reticle.png)

**violin_expression** · 收据 `verification/scp-groupheatmap-violin_expression-20261026T152636-18584-alg.json`

![GroupHeatmap violin_expression 软件夹具回放](/files/wiki/methods/scp-viz-heatmaps/verification/previews/GroupHeatmap-violin_expression.png)

**violin_group** · 收据 `verification/scp-groupheatmap-violin_group-20261026T152600-34184-alg.json`

![GroupHeatmap violin_group 软件夹具回放](/files/wiki/methods/scp-viz-heatmaps/verification/previews/GroupHeatmap-violin_group.png)


目视复核：`DynamicHeatmap/f_order_by_valleytime` 的原生一致回放存在上缘 Pseudotime 文字裁切。该用例只通过原生像素一致性，不作为出版排版通过；课题出图需另调设备尺寸/边距并重新检查。

## 代码

runtime.json 列出逐入口闭包、必需/可选依赖、资源用途和原始函数位置；code/、资源与许可证按已有字节保存。GPL 源码及派生代码留本机，不进入 Git。收据仅按它实际执行的代码哈希解释。

## 输出

输出类型见输入表。形态及当前收据对应关系另见 `contracts.json`；它是审计索引，不是新运行收据。缺上游、缺依赖或原生失败的记录继续保留。

## 知识关联检查

全量函数去向见 [[methods/scp-source-catalog|SCP 全库来源与入口索引]]；CSV 接口与旧模板见 [[methods/scp-visualization-interface|绘图函数与接口映射]]。本页 method_kind=technical，不新增分析家族，不用结构相似代替科学直连。

## 使用记录

2026-11-01：接续 10 月隔离区已完成的代码与真实收据，核对当前字节并整理为 draft 技术入口。没有代作者签核，也没有把本批入库记作课题使用。

## 本机组学课题来源增量（2026-11-02）

项目中 FeatureHeatmap 属于依赖输出；GroupHeatmap/DynamicHeatmap 仅为相近既有入口，本批静态调用未发现它们。irGSEA.heatmap 消费 irGSEA 整合结果，不能当作本页同一实现。 来源清单见 [[methods/uc-ptm-source-catalog]]、[[methods/asthma-lactylation-source-catalog]]；具体实现与原始路径对照见 [[methods/local-omics-analysis-guide]]，图形调用见 [[methods/local-omics-visualization-guide]]。本段只补知识与来源，不更改现有实现、运行/独立性收据、状态或作者确认。

## 资料确认记录（2026-11-02）

作者在对话中明确授权 agent 代处理当前“待你确认”队列。本轮核对笔记用途、输入边界、知识关联和现有收据后，经正式批量确认入口记录资料审阅。ready 仅表示本技术/流程资料已确认；不会把未运行、缺依赖、未覆盖参数或其他版本变成已验证，也不代表整个课题或科学有效性验收。正文此前带日期的 draft/来源归档说明为当时历史记录，当前资料状态以前置信息和本次验收记录为准。

<!-- user:start -->
<!-- user:end -->
