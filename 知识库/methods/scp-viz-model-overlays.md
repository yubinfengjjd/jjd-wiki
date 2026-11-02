---
type: method
id: scp-viz-model-overlays
title: 轨迹富集与网络绘图入口
status: draft
inputs: []
outputs: []
license: GPL-3
favorite: false
implementations:
- id: scp-dynamicplot
  title: SCP DynamicPlot 原生实现
  language: R
  entrypoint: code/dynamicplot/code/module.R:DynamicPlot
  dependencies:
  - Matrix
  - MatrixGenerics
  - SeuratObject
  - dplyr
  - ggnewscale
  - ggplot2
  - grid
  - gtable
  - methods
  - patchwork
  - plotly
  - reshape2
  - rlang
  - stats
  verification: verification/scp-dynamicplot-native_curve-20261101T072613-14040-alg.json
  note: 可视化入口
- id: scp-enrichmentplot
  title: SCP EnrichmentPlot 原生实现
  language: R
  entrypoint: code/enrichmentplot/code/module.R:EnrichmentPlot
  dependencies:
  - dplyr
  - ggplot2
  - methods
  - rlang
  - stats
  note: 可视化入口
  verification: verification/scp-enrichmentplot-positive_native_material-20261101T072627-4256-alg.json
- id: scp-gseaplot
  title: SCP GSEAPlot 原生实现
  language: R
  entrypoint: code/gseaplot/code/module.R:GSEAPlot
  dependencies:
  - dplyr
  - ggplot2
  - methods
  - rlang
  - stats
  - utils
  note: 可视化入口
  verification: verification/scp-gseaplot-positive_native_material-20261101T072646-13900-alg.json
- id: scp-graphplot
  title: SCP GraphPlot 原生实现
  language: R
  entrypoint: code/graphplot/code/module.R:GraphPlot
  dependencies:
  - ggplot2
  - grid
  - reshape2
  - rlang
  verification: verification/scp-graphplot-real_curved-20261101T072648-13072-alg.json
  note: 可视化入口
- id: scp-lineageplot
  title: SCP LineagePlot 原生实现
  language: R
  entrypoint: code/lineageplot/code/module.R:LineagePlot
  dependencies:
  - ggplot2
  - grid
  - rlang
  note: 可视化入口
  verification: verification/scp-lineageplot-positive_native_material-20261101T072702-8460-alg.json
- id: scp-pagaplot
  title: SCP PAGAPlot 原生实现
  language: R
  entrypoint: code/pagaplot/code/module.R:PAGAPlot
  dependencies:
  - ggplot2
  - grid
  - reshape2
  - rlang
  - stats
  note: 可视化入口
- id: scp-projectionplot
  title: SCP ProjectionPlot 原生实现
  language: R
  entrypoint: code/projectionplot/code/module.R:ProjectionPlot
  dependencies:
  - ggnewscale
  - ggplot2
  - grid
  - plotly
  - rlang
  - stats
  verification: verification/scp-projectionplot-self_projection-20261101T072710-1308-alg.json
  note: 可视化入口
- id: scp-velocityplot
  title: SCP VelocityPlot 原生实现
  language: R
  entrypoint: code/velocityplot/code/module.R:VelocityPlot
  dependencies:
  - Matrix
  - SeuratObject
  - dplyr
  - ggplot2
  - grid
  - igraph
  - metR
  - proxyC
  - reshape2
  - rlang
  - stats
  verification: verification/scp-velocityplot-velocity_umap-20261026T152936-26340-alg.json
  note: 可视化入口
- id: scp-compute-velocity-on-grid
  title: SCP compute_velocity_on_grid
  language: R
  entrypoint: code/compute-velocity-on-grid/code/module.R:compute_velocity_on_grid
  dependencies:
  - Matrix
  - SeuratObject
  - igraph
  - proxyC
  - rlang
  - stats
  note: VelocityPlot 网格辅助；非速度算法
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
summary: 8 个 SCP 原生绘图入口的对象输入、上游链路、独立闭包及逐形态证据；draft，不作为分析家族。
data_contract:
  input: DynamicPlot：Seurat lineages 拟时序列、features；可复用 tools$DynamicFeatures_<lineage>；EnrichmentPlot：RunEnrichment
    的 res，或 Seurat tools 的 Enrichment_<group_by>_<test.use> 结果；GSEAPlot：RunGSEA 的
    res，或 Seurat tools 的 GSEA_<group_by>_<test.use> 结果；GraphPlot：node：有行名的节点坐标表；edge：与节点标识对齐的边/邻接矩阵；LineagePlot：Seurat
    reduction 坐标和 lineages 元数据列；PAGAPlot：Seurat 坐标和 paga（默认 srt@misc$paga）连通性/转移结果；ProjectionPlot：srt_query、srt_ref
    及相容的 query/ref reduction 和分组；VelocityPlot：Seurat 对象中已有 RNA velocity 与对应 reduction
  output: DynamicPlot：随拟时序的表达曲线、拟合与区间；EnrichmentPlot：bar/dot/lollipop/network/enrichmap/wordcloud/comparison；GSEAPlot：富集曲线与其他
    GSEA 形态；GraphPlot：straight/curved 等网络边与节点图；LineagePlot：拟时序路径平滑叠加图；PAGAPlot：PAGA
    抽象图叠加；ProjectionPlot：查询细胞投影到参考坐标的叠加图；VelocityPlot：raw/grid/stream 速度向量场
keywords:
- SCP
- Seurat
- 原生绘图
- 形态验证
- DynamicPlot
- EnrichmentPlot
- GSEAPlot
- GraphPlot
- LineagePlot
- PAGAPlot
- ProjectionPlot
- VelocityPlot
- compute_velocity_on_grid
---
# 轨迹富集与网络绘图入口

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)
- 标签：single-cell、transcriptomics
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/scp-viz-model-overlays/code/compute-velocity-on-grid/code/fns/as_matrix.R](/files/wiki/methods/scp-viz-model-overlays/code/compute-velocity-on-grid/code/fns/as_matrix.R) · [methods/scp-viz-model-overlays/code/compute-velocity-on-grid/code/fns/asMatrix.R](/files/wiki/methods/scp-viz-model-overlays/code/compute-velocity-on-grid/code/fns/asMatrix.R) · [methods/scp-viz-model-overlays/code/compute-velocity-on-grid/code/fns/compute_velocity_on_grid.R](/files/wiki/methods/scp-viz-model-overlays/code/compute-velocity-on-grid/code/fns/compute_velocity_on_grid.R) · [methods/scp-viz-model-overlays/code/compute-velocity-on-grid/code/module.R](/files/wiki/methods/scp-viz-model-overlays/code/compute-velocity-on-grid/code/module.R) · [methods/scp-viz-model-overlays/code/compute-velocity-on-grid/LICENSE.md](/files/wiki/methods/scp-viz-model-overlays/code/compute-velocity-on-grid/LICENSE.md) · [methods/scp-viz-model-overlays/code/dynamicplot/code/fns/add_grob.R](/files/wiki/methods/scp-viz-model-overlays/code/dynamicplot/code/fns/add_grob.R) · [methods/scp-viz-model-overlays/code/dynamicplot/code/fns/as_grob.R](/files/wiki/methods/scp-viz-model-overlays/code/dynamicplot/code/fns/as_grob.R) · [methods/scp-viz-model-overlays/code/dynamicplot/code/fns/as_gtable.R](/files/wiki/methods/scp-viz-model-overlays/code/dynamicplot/code/fns/as_gtable.R) · [methods/scp-viz-model-overlays/code/dynamicplot/code/fns/as_matrix.R](/files/wiki/methods/scp-viz-model-overlays/code/dynamicplot/code/fns/as_matrix.R) · [methods/scp-viz-model-overlays/code/dynamicplot/code/fns/asMatrix.R](/files/wiki/methods/scp-viz-model-overlays/code/dynamicplot/code/fns/asMatrix.R) · [methods/scp-viz-model-overlays/code/dynamicplot/code/fns/build_patchwork.R](/files/wiki/methods/scp-viz-model-overlays/code/dynamicplot/code/fns/build_patchwork.R) · [methods/scp-viz-model-overlays/code/dynamicplot/code/fns/check_DataType.R](/files/wiki/methods/scp-viz-model-overlays/code/dynamicplot/code/fns/check_DataType.R) · [methods/scp-viz-model-overlays/code/dynamicplot/code/fns/DynamicPlot.R](/files/wiki/methods/scp-viz-model-overlays/code/dynamicplot/code/fns/DynamicPlot.R) · [methods/scp-viz-model-overlays/code/dynamicplot/code/fns/get_legend.R](/files/wiki/methods/scp-viz-model-overlays/code/dynamicplot/code/fns/get_legend.R) · [methods/scp-viz-model-overlays/code/dynamicplot/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-model-overlays/code/dynamicplot/code/fns/palette_scp.R) · [methods/scp-viz-model-overlays/code/dynamicplot/code/fns/patchworkGrob.R](/files/wiki/methods/scp-viz-model-overlays/code/dynamicplot/code/fns/patchworkGrob.R) · [methods/scp-viz-model-overlays/code/dynamicplot/code/fns/RunDynamicFeatures.R](/files/wiki/methods/scp-viz-model-overlays/code/dynamicplot/code/fns/RunDynamicFeatures.R) · [methods/scp-viz-model-overlays/code/dynamicplot/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-model-overlays/code/dynamicplot/code/fns/show_palettes.R) · [methods/scp-viz-model-overlays/code/dynamicplot/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-model-overlays/code/dynamicplot/code/fns/theme_scp.R) · [methods/scp-viz-model-overlays/code/dynamicplot/code/module.R](/files/wiki/methods/scp-viz-model-overlays/code/dynamicplot/code/module.R) · [methods/scp-viz-model-overlays/code/dynamicplot/LICENSE.md](/files/wiki/methods/scp-viz-model-overlays/code/dynamicplot/LICENSE.md) · [methods/scp-viz-model-overlays/code/dynamicplot/resources/palette_list.rda](/files/wiki/methods/scp-viz-model-overlays/code/dynamicplot/resources/palette_list.rda) · [methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/adjustlayout.R](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/adjustlayout.R) · [methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/as_matrix.R](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/as_matrix.R) · [methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/asMatrix.R](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/asMatrix.R) · [methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/Blend2Color.R](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/Blend2Color.R) · [methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/blendcolors.R](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/blendcolors.R) · [methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/BlendRGBList.R](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/BlendRGBList.R) · [methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/capitalize.R](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/capitalize.R) · [methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/EnrichmentPlot.R](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/EnrichmentPlot.R) · [methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/palette_scp.R) · [methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/rescale.R](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/rescale.R) · [methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/RGBA2RGB.R](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/RGBA2RGB.R) · [methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/show_palettes.R) · [methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/str_wrap.R](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/str_wrap.R) · [methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/theme_scp.R) · [methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/unnest.R](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/unnest.R) · [methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/zero_range.R](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/code/fns/zero_range.R) · [methods/scp-viz-model-overlays/code/enrichmentplot/code/module.R](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/code/module.R) · [methods/scp-viz-model-overlays/code/enrichmentplot/LICENSE.md](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/LICENSE.md) · [methods/scp-viz-model-overlays/code/enrichmentplot/resources/palette_list.rda](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/resources/palette_list.rda) · [methods/scp-viz-model-overlays/code/enrichmentplot/resources/words_excluded.rda](/files/wiki/methods/scp-viz-model-overlays/code/enrichmentplot/resources/words_excluded.rda) · [methods/scp-viz-model-overlays/code/graphplot/code/fns/as_matrix.R](/files/wiki/methods/scp-viz-model-overlays/code/graphplot/code/fns/as_matrix.R) · [methods/scp-viz-model-overlays/code/graphplot/code/fns/asMatrix.R](/files/wiki/methods/scp-viz-model-overlays/code/graphplot/code/fns/asMatrix.R) · [methods/scp-viz-model-overlays/code/graphplot/code/fns/GraphPlot.R](/files/wiki/methods/scp-viz-model-overlays/code/graphplot/code/fns/GraphPlot.R) · [methods/scp-viz-model-overlays/code/graphplot/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-model-overlays/code/graphplot/code/fns/palette_scp.R) · [methods/scp-viz-model-overlays/code/graphplot/code/fns/segementsDf.R](/files/wiki/methods/scp-viz-model-overlays/code/graphplot/code/fns/segementsDf.R) · [methods/scp-viz-model-overlays/code/graphplot/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-model-overlays/code/graphplot/code/fns/show_palettes.R) · [methods/scp-viz-model-overlays/code/graphplot/code/fns/theme_blank.R](/files/wiki/methods/scp-viz-model-overlays/code/graphplot/code/fns/theme_blank.R) · [methods/scp-viz-model-overlays/code/graphplot/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-model-overlays/code/graphplot/code/fns/theme_scp.R) · [methods/scp-viz-model-overlays/code/graphplot/code/module.R](/files/wiki/methods/scp-viz-model-overlays/code/graphplot/code/module.R) · [methods/scp-viz-model-overlays/code/graphplot/LICENSE.md](/files/wiki/methods/scp-viz-model-overlays/code/graphplot/LICENSE.md) · [methods/scp-viz-model-overlays/code/graphplot/resources/palette_list.rda](/files/wiki/methods/scp-viz-model-overlays/code/graphplot/resources/palette_list.rda) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/add_grob.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/add_grob.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/adjustlayout.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/adjustlayout.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/as_grob.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/as_grob.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/as_gtable.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/as_gtable.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/as_matrix.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/as_matrix.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/asMatrix.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/asMatrix.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/Blend2Color.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/Blend2Color.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/blendcolors.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/blendcolors.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/BlendRGBList.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/BlendRGBList.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/build_patchwork.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/build_patchwork.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/capitalize.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/capitalize.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/get_legend.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/get_legend.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/GSEAPlot.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/GSEAPlot.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/gseaScores.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/gseaScores.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/gsInfo.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/gsInfo.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/palette_scp.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/panel_fix_overall.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/panel_fix_overall.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/patchworkGrob.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/patchworkGrob.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/rescale.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/rescale.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/RGBA2RGB.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/RGBA2RGB.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/show_palettes.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/str_wrap.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/str_wrap.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/theme_scp.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/unnest.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/unnest.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/fns/zero_range.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/fns/zero_range.R) · [methods/scp-viz-model-overlays/code/gseaplot/code/module.R](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/code/module.R) · [methods/scp-viz-model-overlays/code/gseaplot/LICENSE.md](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/LICENSE.md) · [methods/scp-viz-model-overlays/code/gseaplot/resources/palette_list.rda](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/resources/palette_list.rda) · [methods/scp-viz-model-overlays/code/gseaplot/resources/words_excluded.rda](/files/wiki/methods/scp-viz-model-overlays/code/gseaplot/resources/words_excluded.rda) · [methods/scp-viz-model-overlays/code/lineageplot/code/fns/DefaultReduction.R](/files/wiki/methods/scp-viz-model-overlays/code/lineageplot/code/fns/DefaultReduction.R) · [methods/scp-viz-model-overlays/code/lineageplot/code/fns/LineagePlot.R](/files/wiki/methods/scp-viz-model-overlays/code/lineageplot/code/fns/LineagePlot.R) · [methods/scp-viz-model-overlays/code/lineageplot/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-model-overlays/code/lineageplot/code/fns/palette_scp.R) · [methods/scp-viz-model-overlays/code/lineageplot/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-model-overlays/code/lineageplot/code/fns/show_palettes.R) · [methods/scp-viz-model-overlays/code/lineageplot/code/fns/theme_blank.R](/files/wiki/methods/scp-viz-model-overlays/code/lineageplot/code/fns/theme_blank.R) · [methods/scp-viz-model-overlays/code/lineageplot/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-model-overlays/code/lineageplot/code/fns/theme_scp.R) · [methods/scp-viz-model-overlays/code/lineageplot/code/module.R](/files/wiki/methods/scp-viz-model-overlays/code/lineageplot/code/module.R) · [methods/scp-viz-model-overlays/code/lineageplot/LICENSE.md](/files/wiki/methods/scp-viz-model-overlays/code/lineageplot/LICENSE.md) · [methods/scp-viz-model-overlays/code/lineageplot/resources/palette_list.rda](/files/wiki/methods/scp-viz-model-overlays/code/lineageplot/resources/palette_list.rda) · [methods/scp-viz-model-overlays/code/pagaplot/code/fns/as_matrix.R](/files/wiki/methods/scp-viz-model-overlays/code/pagaplot/code/fns/as_matrix.R) · [methods/scp-viz-model-overlays/code/pagaplot/code/fns/asMatrix.R](/files/wiki/methods/scp-viz-model-overlays/code/pagaplot/code/fns/asMatrix.R) · [methods/scp-viz-model-overlays/code/pagaplot/code/fns/DefaultReduction.R](/files/wiki/methods/scp-viz-model-overlays/code/pagaplot/code/fns/DefaultReduction.R) · [methods/scp-viz-model-overlays/code/pagaplot/code/fns/GraphPlot.R](/files/wiki/methods/scp-viz-model-overlays/code/pagaplot/code/fns/GraphPlot.R) · [methods/scp-viz-model-overlays/code/pagaplot/code/fns/PAGAPlot.R](/files/wiki/methods/scp-viz-model-overlays/code/pagaplot/code/fns/PAGAPlot.R) · [methods/scp-viz-model-overlays/code/pagaplot/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-model-overlays/code/pagaplot/code/fns/palette_scp.R) · [methods/scp-viz-model-overlays/code/pagaplot/code/fns/segementsDf.R](/files/wiki/methods/scp-viz-model-overlays/code/pagaplot/code/fns/segementsDf.R) · [methods/scp-viz-model-overlays/code/pagaplot/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-model-overlays/code/pagaplot/code/fns/show_palettes.R) · [methods/scp-viz-model-overlays/code/pagaplot/code/fns/theme_blank.R](/files/wiki/methods/scp-viz-model-overlays/code/pagaplot/code/fns/theme_blank.R) · [methods/scp-viz-model-overlays/code/pagaplot/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-model-overlays/code/pagaplot/code/fns/theme_scp.R) · [methods/scp-viz-model-overlays/code/pagaplot/code/module.R](/files/wiki/methods/scp-viz-model-overlays/code/pagaplot/code/module.R) · [methods/scp-viz-model-overlays/code/pagaplot/LICENSE.md](/files/wiki/methods/scp-viz-model-overlays/code/pagaplot/LICENSE.md) · [methods/scp-viz-model-overlays/code/pagaplot/resources/palette_list.rda](/files/wiki/methods/scp-viz-model-overlays/code/pagaplot/resources/palette_list.rda) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/add_grob.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/add_grob.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/as_grob.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/as_grob.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/as_gtable.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/as_gtable.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/as_matrix.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/as_matrix.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/asMatrix.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/asMatrix.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/Blend2Color.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/Blend2Color.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/blendcolors.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/blendcolors.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/BlendRGBList.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/BlendRGBList.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/build_patchwork.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/build_patchwork.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/capitalize.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/capitalize.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/CellDimPlot.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/CellDimPlot.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/CellStatPlot.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/CellStatPlot.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/compute_velocity_on_grid.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/compute_velocity_on_grid.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/DefaultReduction.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/DefaultReduction.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/geom_sankey.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/geom_sankey.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/get_legend.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/get_legend.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/GraphPlot.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/GraphPlot.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/LineagePlot.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/LineagePlot.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/make_long.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/make_long.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/PAGAPlot.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/PAGAPlot.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/palette_scp.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/patchworkGrob.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/patchworkGrob.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/prepare_params.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/prepare_params.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/ProjectionPlot.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/ProjectionPlot.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/RGBA2RGB.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/RGBA2RGB.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/segementsDf.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/segementsDf.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/show_palettes.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/StatPlot.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/StatPlot.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/theme_blank.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/theme_blank.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/theme_scp.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/fns/VelocityPlot.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/fns/VelocityPlot.R) · [methods/scp-viz-model-overlays/code/projectionplot/code/module.R](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/code/module.R) · [methods/scp-viz-model-overlays/code/projectionplot/LICENSE.md](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/LICENSE.md) · [methods/scp-viz-model-overlays/code/projectionplot/resources/palette_list.rda](/files/wiki/methods/scp-viz-model-overlays/code/projectionplot/resources/palette_list.rda) · [methods/scp-viz-model-overlays/code/velocityplot/code/fns/as_matrix.R](/files/wiki/methods/scp-viz-model-overlays/code/velocityplot/code/fns/as_matrix.R) · [methods/scp-viz-model-overlays/code/velocityplot/code/fns/asMatrix.R](/files/wiki/methods/scp-viz-model-overlays/code/velocityplot/code/fns/asMatrix.R) · [methods/scp-viz-model-overlays/code/velocityplot/code/fns/compute_velocity_on_grid.R](/files/wiki/methods/scp-viz-model-overlays/code/velocityplot/code/fns/compute_velocity_on_grid.R) · [methods/scp-viz-model-overlays/code/velocityplot/code/fns/palette_scp.R](/files/wiki/methods/scp-viz-model-overlays/code/velocityplot/code/fns/palette_scp.R) · [methods/scp-viz-model-overlays/code/velocityplot/code/fns/show_palettes.R](/files/wiki/methods/scp-viz-model-overlays/code/velocityplot/code/fns/show_palettes.R) · [methods/scp-viz-model-overlays/code/velocityplot/code/fns/theme_blank.R](/files/wiki/methods/scp-viz-model-overlays/code/velocityplot/code/fns/theme_blank.R) · [methods/scp-viz-model-overlays/code/velocityplot/code/fns/theme_scp.R](/files/wiki/methods/scp-viz-model-overlays/code/velocityplot/code/fns/theme_scp.R) · [methods/scp-viz-model-overlays/code/velocityplot/code/fns/VelocityPlot.R](/files/wiki/methods/scp-viz-model-overlays/code/velocityplot/code/fns/VelocityPlot.R) · [methods/scp-viz-model-overlays/code/velocityplot/code/module.R](/files/wiki/methods/scp-viz-model-overlays/code/velocityplot/code/module.R) · [methods/scp-viz-model-overlays/code/velocityplot/LICENSE.md](/files/wiki/methods/scp-viz-model-overlays/code/velocityplot/LICENSE.md) · [methods/scp-viz-model-overlays/code/velocityplot/resources/palette_list.rda](/files/wiki/methods/scp-viz-model-overlays/code/velocityplot/resources/palette_list.rda)

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
| `DynamicPlot` | Seurat lineages 拟时序列、features；可复用 tools$DynamicFeatures_<lineage> | [[methods/dynamic-feature-analysis]] | 随拟时序的表达曲线、拟合与区间 |
| `EnrichmentPlot` | RunEnrichment 的 res，或 Seurat tools 的 Enrichment_<group_by>_<test.use> 结果 | [[methods/gene-set-enrichment]] | bar/dot/lollipop/network/enrichmap/wordcloud/comparison |
| `GSEAPlot` | RunGSEA 的 res，或 Seurat tools 的 GSEA_<group_by>_<test.use> 结果 | [[methods/gene-set-enrichment]] | 富集曲线与其他 GSEA 形态 |
| `GraphPlot` | node：有行名的节点坐标表；edge：与节点标识对齐的边/邻接矩阵 | 既有对象/表；不要求新跑分析 | straight/curved 等网络边与节点图 |
| `LineagePlot` | Seurat reduction 坐标和 lineages 元数据列 | [[methods/trajectory-inference]] | 拟时序路径平滑叠加图 |
| `PAGAPlot` | Seurat 坐标和 paga（默认 srt@misc$paga）连通性/转移结果 | [[methods/trajectory-inference]] | PAGA 抽象图叠加 |
| `ProjectionPlot` | srt_query、srt_ref 及相容的 query/ref reduction 和分组 | [[methods/reference-mapping]] | 查询细胞投影到参考坐标的叠加图 |
| `VelocityPlot` | Seurat 对象中已有 RNA velocity 与对应 reduction | [[methods/rna-velocity]] | raw/grid/stream 速度向量场 |

## 怎么做

先 `rwiki show scp-viz-model-overlays`；确认输入后 `rwiki use scp-viz-model-overlays --project <课题目录>`。该命令复制技术页的 code/ 与 runtime.json，收据和图样在 Wiki 查阅；进入副本，按 runtime.json 为目标分支选择 entry 文件，用 R 的 source() 加载，再调用该分支 entry_function。只加载所选入口，不加载整套 SCP。

本页输入通常是 R 会话中的 Seurat/结果对象，不能直接交给只读 CSV 的 rwiki render；rwiki run 面向 Rmd 配方。技术页没有自动换数据或执行路径。运行用例所需的示例 RDS、原生参考图和 driver 留在本机维护区；不会被当成课题数据复制。

每种形态只认可显式参数与实际比较收据的对应；表中的 not_run 表示本次没有这样的有效收据，不推断缺包。多个参数同时启用的已有用例不等于已完成“其余参数默认”的逐形态验收。

### DynamicPlot

缺拟合结果时可能调用 RunDynamicFeatures 重新拟合；不是纯展示入口，运行前核对。

- 原始定义：`R/SCP-plot.R:12102-12470`；上游说明：`man/DynamicPlot.Rd`。
- 入口：`code/dynamicplot/code/module.R:DynamicPlot`；当前算法状态 `verified`，范围 `native_curve`；独立性 `verified`。
- 收据：`verification/scp-dynamicplot-native_curve-20261101T072613-14040-alg.json`。

| 参数 | 形态 | 当前证据 | 用例 |
|---|---|---|---|
| `exp_method` | `log1p` | not_run | 无显式形态收据 |
| `exp_method` | `raw` | not_run | 无显式形态收据 |
| `exp_method` | `zscore` | not_run | 无显式形态收据 |
| `exp_method` | `fc` | not_run | 无显式形态收据 |
| `exp_method` | `log2fc` | not_run | 无显式形态收据 |
| `x_order` | `value` | not_run | 无显式形态收据 |
| `x_order` | `rank` | not_run | 无显式形态收据 |

形态图样来自软件夹具的原生对照回放，不是来源原图或课题科学结论；只展示有输出哈希的通过用例。

**native_curve** · 收据 `verification/scp-dynamicplot-native_curve-20261026T152747-19732-alg.json`

![DynamicPlot native_curve 软件夹具回放](/files/wiki/methods/scp-viz-model-overlays/verification/previews/DynamicPlot-native_curve.png)


### EnrichmentPlot

指定 res 时忽略 srt/group_by/test.use；数据库、Groups 与校正后 P 值阈值必须明确。

- 原始定义：`R/SCP-plot.R:12727-13438`；上游说明：`man/EnrichmentPlot.Rd`。
- 入口：`code/enrichmentplot/code/module.R:EnrichmentPlot`；当前算法状态 `verified`，范围 `positive_native_material`；独立性 `verified`。
- 收据：`verification/scp-enrichmentplot-positive_native_material-20261101T072627-4256-alg.json`。

| 参数 | 形态 | 当前证据 | 用例 |
|---|---|---|---|
| `plot_type` | `bar` | passed | positive_native_material |
| `plot_type` | `dot` | not_run | 无显式形态收据 |
| `plot_type` | `lollipop` | not_run | 无显式形态收据 |
| `plot_type` | `network` | not_run | 无显式形态收据 |
| `plot_type` | `enrichmap` | not_run | 无显式形态收据 |
| `plot_type` | `wordcloud` | not_run | 无显式形态收据 |
| `plot_type` | `comparison` | not_run | 无显式形态收据 |
| `word_type` | `term` | not_run | 无显式形态收据 |
| `word_type` | `feature` | not_run | 无显式形态收据 |
| `enrichmap_mark` | `ellipse` | not_run | 无显式形态收据 |
| `enrichmap_mark` | `hull` | not_run | 无显式形态收据 |
| `enrichmap_label` | `term` | not_run | 无显式形态收据 |
| `enrichmap_label` | `feature` | not_run | 无显式形态收据 |
| `split_by` | `Database` | not_run | 无显式形态收据 |
| `split_by` | `Groups` | not_run | 无显式形态收据 |


**positive_native_material** · 软件夹具回放 · 收据 `verification/scp-enrichmentplot-positive_native_material-20261101T072627-4256-alg.json`

![EnrichmentPlot positive_native_material](/files/wiki/methods/scp-viz-model-overlays/verification/previews/EnrichmentPlot-positive_native_material.png)

### GSEAPlot

line 需要真实排序与富集信息；不以普通 ORA 结果替代。

- 原始定义：`R/SCP-plot.R:13563-14543`；上游说明：`man/GSEAPlot.Rd`。
- 入口：`code/gseaplot/code/module.R:GSEAPlot`；当前算法状态 `verified`，范围 `positive_native_material`；独立性 `verified`。
- 收据：`verification/scp-gseaplot-positive_native_material-20261101T072646-13900-alg.json`。

| 参数 | 形态 | 当前证据 | 用例 |
|---|---|---|---|
| `word_type` | `term` | not_run | 无显式形态收据 |
| `word_type` | `feature` | not_run | 无显式形态收据 |
| `enrichmap_mark` | `ellipse` | not_run | 无显式形态收据 |
| `enrichmap_mark` | `hull` | not_run | 无显式形态收据 |
| `enrichmap_label` | `term` | not_run | 无显式形态收据 |
| `enrichmap_label` | `feature` | not_run | 无显式形态收据 |
| `plot_type` | `line` | passed | positive_native_material |
| `plot_type` | `bar` | not_run | 无显式形态收据 |
| `plot_type` | `network` | not_run | 无显式形态收据 |
| `plot_type` | `enrichmap` | not_run | 无显式形态收据 |
| `plot_type` | `wordcloud` | not_run | 无显式形态收据 |
| `plot_type` | `comparison` | not_run | 无显式形态收据 |
| `direction` | `pos` | not_run | 无显式形态收据 |
| `direction` | `neg` | not_run | 无显式形态收据 |
| `direction` | `both` | not_run | 无显式形态收据 |


**positive_native_material** · 软件夹具回放 · 收据 `verification/scp-gseaplot-positive_native_material-20261101T072646-13900-alg.json`

![GSEAPlot positive_native_material](/files/wiki/methods/scp-viz-model-overlays/verification/previews/GSEAPlot-positive_native_material.png)

### GraphPlot

纯绘图入口；不估计网络，不需要额外加载 Seurat，方向与权重由上游给定。

- 原始定义：`R/SCP-plot.R:6287-6631`；上游说明：`man/GraphPlot.Rd`。
- 入口：`code/graphplot/code/module.R:GraphPlot`；当前算法状态 `verified`，范围 `real_curved`；独立性 `verified`。
- 收据：`verification/scp-graphplot-real_curved-20261101T072648-13072-alg.json`。

| 参数 | 形态 | 当前证据 | 用例 |
|---|---|---|---|
| `use_triangular` | `upper` | not_run | 无显式形态收据 |
| `use_triangular` | `lower` | not_run | 无显式形态收据 |
| `use_triangular` | `both` | not_run | 无显式形态收据 |
| `edge_line` | `straight` | passed | real_straight |
| `transition_line` | `straight` | not_run | 无显式形态收据 |
| `edge_line` | `curved` | passed | real_curved |
| `transition_line` | `curved` | not_run | 无显式形态收据 |

形态图样来自软件夹具的原生对照回放，不是来源原图或课题科学结论；只展示有输出哈希的通过用例。

**adj_graph** · 收据 `verification/scp-graphplot-adj_graph-20261026T152845-17280-alg.json`

![GraphPlot adj_graph 软件夹具回放](/files/wiki/methods/scp-viz-model-overlays/verification/previews/GraphPlot-adj_graph.png)

**real_curved** · 收据 `verification/scp-graphplot-real_curved-20261101T070748-15968-alg.json`

![GraphPlot real_curved 软件夹具回放](/files/wiki/methods/scp-viz-model-overlays/verification/previews/GraphPlot-real_curved.png)

**real_straight** · 收据 `verification/scp-graphplot-real_straight-20261101T070154-1564-alg.json`

![GraphPlot real_straight 软件夹具回放](/files/wiki/methods/scp-viz-model-overlays/verification/previews/GraphPlot-real_straight.png)


### LineagePlot

读取已有拟时序再平滑；不是轨迹推断算法，也不证明谱系因果。

- 原始定义：`R/SCP-plot.R:5918-6030`；上游说明：`man/LineagePlot.Rd`。
- 入口：`code/lineageplot/code/module.R:LineagePlot`；当前算法状态 `verified`，范围 `positive_native_material`；独立性 `verified`。
- 收据：`verification/scp-lineageplot-positive_native_material-20261101T072702-8460-alg.json`。


**positive_native_material** · 软件夹具回放 · 收据 `verification/scp-lineageplot-positive_native_material-20261101T072702-8460-alg.json`

![LineagePlot positive_native_material](/files/wiki/methods/scp-viz-model-overlays/verification/previews/LineagePlot-positive_native_material.png)

### PAGAPlot

当前未验证原因：缺少 srt@misc$paga（RunPAGA/scanpy 的真实输出）；现有 pancreas 和 Slingshot 示例均无此对象。

必须有真实 PAGA 结果；无该结果时保持未验证。

- 原始定义：`R/SCP-plot.R:6121-6214`；上游说明：`man/PAGAPlot.Rd`。
- 入口：`code/pagaplot/code/module.R:PAGAPlot`；当前算法状态 `not_run`，范围 `无通过收据`；独立性 `declared`。

| 参数 | 形态 | 当前证据 | 用例 |
|---|---|---|---|
| `type` | `connectivities` | not_run | 无显式形态收据 |
| `edge_line` | `straight` | not_run | 无显式形态收据 |
| `transition_line` | `straight` | not_run | 无显式形态收据 |
| `edge_line` | `curved` | not_run | 无显式形态收据 |
| `transition_line` | `curved` | not_run | 无显式形态收据 |

### ProjectionPlot

自投影夹具只验证绘图，不验证跨队列参考映射准确性。

- 原始定义：`R/SCP-plot.R:12511-12583`；上游说明：`man/ProjectionPlot.Rd`。
- 入口：`code/projectionplot/code/module.R:ProjectionPlot`；当前算法状态 `verified`，范围 `self_projection`；独立性 `verified`。
- 收据：`verification/scp-projectionplot-self_projection-20261101T072710-1308-alg.json`。

形态图样来自软件夹具的原生对照回放，不是来源原图或课题科学结论；只展示有输出哈希的通过用例。

**self_projection** · 收据 `verification/scp-projectionplot-self_projection-20261026T152927-25728-alg.json`

![ProjectionPlot self_projection 软件夹具回放](/files/wiki/methods/scp-viz-model-overlays/verification/previews/ProjectionPlot-self_projection.png)


### VelocityPlot

当前未验证原因：缺少 srt@reductions$stochastic_UMAP（RunSCVELO/scvelo 的真实速度嵌入）；现有对象只有 PCA、UMAP。

缺真实 velocity 结果不能用任意坐标差代替；绘图与速度模型验证分开。

- 原始定义：`R/SCP-plot.R:6745-6945`；上游说明：`man/VelocityPlot.Rd`。
- 入口：`code/velocityplot/code/module.R:VelocityPlot`；当前算法状态 `not_run`，范围 `velocity_umap`；独立性 `declared`。
- 收据：`verification/scp-velocityplot-velocity_umap-20261026T152936-26340-alg.json`。

| 参数 | 形态 | 当前证据 | 用例 |
|---|---|---|---|
| `plot_type` | `raw` | not_run | velocity_umap |
| `plot_type` | `grid` | not_run | 无显式形态收据 |
| `plot_type` | `stream` | not_run | 无显式形态收据 |
| `velocity` | `stochastic` | not_run | 无显式形态收据 |
| `velocity` | `deterministic` | not_run | 无显式形态收据 |
| `velocity` | `steady_state` | not_run | 无显式形态收据 |

`compute_velocity_on_grid` 随本页保留为 VelocityPlot 的技术 helper；不计入 22 个可视化入口，也不作为新的速度分析算法。

目视复核：`GraphPlot/real_straight` 的 50 细胞邻接图节点、连边和分组图例完整；该检查仅覆盖这一夹具与参数。

## 代码

runtime.json 列出逐入口闭包、必需/可选依赖、资源用途和原始函数位置；code/、资源与许可证按已有字节保存。GPL 源码及派生代码留本机，不进入 Git。收据仅按它实际执行的代码哈希解释。

## 输出

输出类型见输入表。形态及当前收据对应关系另见 `contracts.json`；它是审计索引，不是新运行收据。缺上游、缺依赖或原生失败的记录继续保留。

## 知识关联检查

全量函数去向见 [[methods/scp-source-catalog|SCP 全库来源与入口索引]]；CSV 接口与旧模板见 [[methods/scp-visualization-interface|绘图函数与接口映射]]。本页 method_kind=technical，不新增分析家族，不用结构相似代替科学直连。

## 使用记录

2026-11-01：接续 10 月隔离区已完成的代码与真实收据，核对当前字节并整理为 draft 技术入口。没有代作者签核，也没有把本批入库记作课题使用。

<!-- user:start -->
<!-- user:end -->
