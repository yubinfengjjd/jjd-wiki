---
type: method
id: spatial-transcriptomics-microenvironment
title: 空间转录组空间域识别、微生态定位与微环境解析
status: ready
tags:
- single-cell
- transcriptomics
data_domains:
- spatial-omics
inputs:
- scrna-annotated-cells
outputs:
- cell-proportion-stats
render_bridges: []
source:
  kind: written
license: none
cite:
- 'Palla G, et al. Squidpy: a scalable framework for spatial omics analysis. Nature
  Methods, 2022.'
- Cable DM, et al. Robust decomposition of cell type mixtures in spatial transcriptomics
  (RCTD). Nature Biotechnology, 2022.
- Galeano Niño JL, et al. Effect of the intratumoral microbiota on spatial and cellular
  heterogeneity in cancer. Nature, 2022.
favorite: false
method_kind: analysis
purposes:
- 细胞通讯与微环境
- 注释与参考映射
summary: 面向 Visium 空间转录组与 CyCIF 空间蛋白组执行空间邻域组成（RCN/Spatial LDA）、最近邻置换共现/排斥检验、空间滞后肿瘤群落（TCC）及
  Visium 多通道签名共定位分析，现已封装 4 套跨模态/多语言可执行实现。
data_contract:
  input: 空间转录组 Spot/Cell 表达矩阵或 CyCIF 单细胞空间蛋白表及二维物理坐标（X_um/Y_um 或 imagecol/imagerow），可选配对单细胞参考对象
    scrna-annotated-cells。
  output: cell-proportion-stats（各 Spot/空间生态位 RCN/TCC 的细胞类型比例、空间共现显著性、最近邻距离或 Visium
    签名权重）。
implementations:
- id: scimap-rcn-spatial-lda
  title: CyCIF 半径空间邻域统计与 Spatial LDA / K-means RCN 聚类
  impl_tier: default
  language: Python
  modality: Spatial Proteomics (CyCIF)
  source_paper: 2022-nirmal-melanoma-spatial
  entrypoint: code/scimap_rcn_lda.py:run_scimap_rcn_spatial_lda
  dependencies:
  - numpy
  - pandas
  - scikit-learn
  verification: verification/scimap-rcn-spatial-lda.json
- id: spatial-proximity-interaction
  title: 空间最近邻物理距离与置换共现/排斥检验
  impl_tier: variant
  language: Python
  modality: Spatial Proteomics (CyCIF)
  source_paper: 2022-nirmal-melanoma-spatial
  entrypoint: code/spatial_proximity_interaction.py:run_spatial_proximity_interaction
  dependencies:
  - numpy
  - pandas
  - scikit-learn
  - scipy
  verification: verification/spatial-proximity-interaction.json
- id: spatial-lag-tcc-clustering
  title: 距离加权空间滞后特征矩阵与 TCC 群落聚类
  impl_tier: variant
  language: Python
  modality: Spatial Proteomics (CyCIF)
  source_paper: 2022-nirmal-melanoma-spatial
  entrypoint: code/spatial_lag_tcc.py:run_spatial_lag_tcc
  dependencies:
  - numpy
  - pandas
  - scikit-learn
  verification: verification/spatial-lag-tcc-clustering.json
- id: visium-signature-spatial
  title: Visium Spot 空间签名 L1 加权、共富集分区与多通道配受体共定位
  impl_tier: variant
  language: R
  modality: Visium ST
  source_paper: 2026-cai-stromal-tme
  entrypoint: code/visium_signature_spatial.R:run_visium_signature_spatial
  dependencies:
  - stats
  - utils
  verification: verification/visium-signature-spatial.json
keywords:
- spatial transcriptomics
- Visium
- RCTD
- cell2location
- Squidpy
- spatial domain
- intratumoral microbiota
- 空间转录组
- 空间微环境
figure_relations:
- figure: templates/spatial-feature-grid
  compatibility: adaptable
  reason: Visium 空间 Spot 上的连续基因表达、签名密度或 RCTD 反卷积权重可作为 default 主推网格图展示；模板不执行反卷积。
  prerequisites:
  - Spot 坐标（x, y）对齐同一切片；各特征独立着色，色深仅在同一特征内比较。
  adaptation: 导出 spatial_spots_long.csv（x, y, feature, value, 可选 sample）。
  evidence:
  - methods/spatial-transcriptomics-microenvironment.md#输出
  - templates/spatial-feature-grid/spec.json
  verification:
    state: not_run
    scope: 2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/spatial-coexpr-multichannel
  compatibility: adaptable
  reason: 2 至 4 个配受体或 TLS 淋巴细胞标志基因在同一切片/多区域上的通道共定位与高亮区域可切换为 variant 多通道图。
  prerequisites:
  - 同一切片内各通道共享 Spot 坐标系；高分位数截断阈值（如 P99）须一致说明。
  adaptation: 导出 spatial_coexpr_spots.csv（spot_id, x, y, channel, value, 可选 region,
    highlight_zone）。
  evidence:
  - methods/spatial-transcriptomics-microenvironment.md#输出
  - templates/spatial-coexpr-multichannel/spec.json
  verification:
    state: not_run
    scope: 2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/spatial-he-deconv-panel
  compatibility: adaptable
  reason: 配准 H&E 组织切片裁剪图像与 Visium 空间反卷积权重图并排对照可切换为 variant 组织配准面板。
  prerequisites:
  - Spot (x, y) 像素坐标须与 H&E 图像分辨率严格对齐（误差 < 1 像素）。
  adaptation: 导出 spatial_deconv_spots.csv（spot_id, x, y, feature, score, 可选 region）并附对齐
    he_image.png。
  evidence:
  - methods/spatial-transcriptomics-microenvironment.md#输出
  - templates/spatial-he-deconv-panel/spec.json
  verification:
    state: not_run
    scope: 2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/rcn-composition-stacked-heatmap
  compatibility: adaptable
  reason: 20 um 空间邻域 LDA/K-means（RCN）或空间滞后肿瘤群落（TCC）的特征 Z-score 可与患者、分期比例轨道合并展示为主推默认（default）复合热图；模板不执行聚类。
  prerequisites:
  - 主矩阵与左右轨道表须按 cluster_id 一一对齐；患者与分期比例按独立样本或连续 FOV 汇总。
  adaptation: 导出 rcn_cluster_zscore.csv 与 rcn_cluster_tracks.csv。
  evidence:
  - methods/spatial-transcriptomics-microenvironment.md#输出
  - templates/rcn-composition-stacked-heatmap/spec.json
  verification:
    state: not_run
    scope: 2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/voronoi-neighborhood-mosaic
  compatibility: adaptable
  reason: 连续物理视野（FOV）单细胞坐标与 RCN/TCC 邻域标签可切换为 variant 高密 Voronoi 多边形空间镶嵌与局部放大图；模板不做空间聚类。
  prerequisites:
  - 输入必须为未下采样打碎连续拓扑的物理 FOV（x, y），否则 Voronoi 面积失真。
  adaptation: 导出 spatial_cells_voronoi.csv（cell_id, x, y, neighborhood, 可选 fov_id/stage）。
  evidence:
  - methods/spatial-transcriptomics-microenvironment.md#输出
  - templates/voronoi-neighborhood-mosaic/spec.json
  verification:
    state: not_run
    scope: 2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/spatial-expression-contour
  compatibility: adaptable
  reason: 基于物理组织切片坐标（X_um, Y_um）插值的连续蛋白/基因表达密度可切换为 variant 二维等高线地形分面图；模板不执行空间插值或核密度估计。
  prerequisites:
  - 等高线网格坐标与可选单细胞散点坐标来自同一未旋转裁剪的物理视野（fov_id）。
  adaptation: 导出 spatial_contours.csv（fov_id, X_um, Y_um 及特征列）与可选 spatial_cells.csv。
  evidence:
  - methods/spatial-transcriptomics-microenvironment.md#输出
  - templates/spatial-expression-contour/spec.json
  - templates/spatial-expression-contour/verify/verify.json
  verification:
    state: not_run
    scope: 2026-11-21 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/stage-distance-boxen-grid
  compatibility: adaptable
  reason: 各空间细胞邻域（RCN）到目标锚点邻域（如 RCN10）的跨分期微米距离分布可绘制为对数横轴水平 Boxen 分面图。
  prerequisites:
  - 物理距离须基于真实微米坐标计算（> 0 μm），跨分期显著性检验须与右侧星号列对应。
  adaptation: 导出 rcn_to_anchor_distances.csv 与 rcn_distance_ttests.csv。
  evidence:
  - methods/spatial-transcriptomics-microenvironment.md#输出
  - templates/stage-distance-boxen-grid/spec.json
  verification:
    state: not_run
    scope: 2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/spatial-cell-highlight-grid
  compatibility: adaptable
  reason: 单细胞空间物理坐标（X_um, Y_um）上各空间滞后簇（TCC1-10）或邻域的二值高亮空间落点可绘制为多面板网格。
  prerequisites:
  - 高亮表与背景视野表须共享同一物理微米坐标系与 fov_id。
  adaptation: 导出 spatial_cluster_highlights.csv 与 spatial_fov_background.csv。
  evidence:
  - methods/spatial-transcriptomics-microenvironment.md#输出
  - templates/spatial-cell-highlight-grid/spec.json
  verification:
    state: not_run
    scope: 2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/boundary-intensity-gradient
  compatibility: adaptable
  reason: 沿肿瘤-基质侵袭边界有符号距离分箱的多标志物平均荧光强度梯度可绘制为带双向区室箭头的连续剖面曲线。
  prerequisites:
  - 距离分箱以肿瘤-基质边界为 0 μm（负值代表肿瘤侧，正值代表基质侧）。
  adaptation: 导出 boundary_intensity_gradient.csv（dist_bin_um, compartment 及各标志物平均强度列）。
  evidence:
  - methods/spatial-transcriptomics-microenvironment.md#输出
  - templates/boundary-intensity-gradient/spec.json
  verification:
    state: not_run
    scope: 2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/pvalue-threshold-heatmap
  compatibility: adaptable
  reason: 各空间细胞邻域（RCN1-10）在演进分期两两比较下的统计检验 P 值可绘制为 P < 0.05 暖色渐变与 ns 灰块阈值数值热图。
  prerequisites:
  - P 值由上游分期两两统计检验给出（0-1），模板按 alpha_threshold 分割着色。
  adaptation: 导出 stage_pairwise_pvalues.csv（RCN, comparison, p_value）。
  evidence:
  - methods/spatial-transcriptomics-microenvironment.md#输出
  - templates/pvalue-threshold-heatmap/spec.json
  verification:
    state: not_run
    scope: 2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/spatial-cooccurrence-matrix
  compatibility: adaptable
  reason: 空间滞后簇（TCC1-10）与邻近免疫/基质细胞的 1,000 次空间置换检验结果可绘制为共现/排斥/非显著离散三态矩阵。
  prerequisites:
  - 置换检验双侧显著性（P < 0.05）及 Z 分数方向须在上游汇总为 Co-occurrence / Avoidance / Non-Sig。
  adaptation: 导出 spatial_cooccurrence_states.csv（TCC, neighbour, sig_state）。
  evidence:
  - methods/spatial-transcriptomics-microenvironment.md#输出
  - templates/spatial-cooccurrence-matrix/spec.json
  verification:
    state: not_run
    scope: 2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
next_steps:
- direction: 方向 1：空间邻域细胞通讯与信号互作轴解析
  when: 在识别空间生态位与主要细胞/微环境共定位区域后，推断邻近细胞群体的配受体互作时
  analysis_templates:
  - methods/cell-cell-communication
  intermediate_interface: cellchat-lr-table
  viz_templates:
  - templates/cellchat-circos-multi
  - templates/spatial-feature-grid
  - templates/spatial-coexpr-multichannel
  - templates/spatial-he-deconv-panel
- direction: 方向 2：对比不同空间域或组织区域的细胞亚群组成偏好
  when: 量化肿瘤核心区、浸润前沿与正常边界区的细胞比例差异时
  analysis_templates:
  - methods/cell-proportion-composition
  intermediate_interface: cell-proportion-stats
  viz_templates:
  - templates/cell-prop-flow-bar
- direction: 方向 3：空间域标记基因与通路空间活性打分
  when: 检验局部微环境特异基因集或免疫/代谢通路在切片上的空间梯度变化时
  analysis_templates:
  - methods/gene-set-scoring
  intermediate_interface: pathway-score-table
  viz_templates: []
---
# 空间转录组空间域识别、微生态定位与微环境解析

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：仅供个人研究参考
- 引用：Palla G, et al. Squidpy: a scalable framework for spatial omics analysis. Nature Methods, 2022.；Cable DM, et al. Robust decomposition of cell type mixtures in spatial transcriptomics (RCTD). Nature Biotechnology, 2022.；Galeano Niño JL, et al. Effect of the intratumoral microbiota on spatial and cellular heterogeneity in cancer. Nature, 2022.
- 标签：single-cell、transcriptomics
- 分析用途：细胞通讯与微环境、注释与参考映射
- 输入接口：[[interfaces/scrna-annotated-cells|已注释单细胞元数据与降维表]]
- 输出接口：[[interfaces/cell-proportion-stats|细胞亚群比例与 Ro/e 偏好统计表]]
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/spatial-transcriptomics-microenvironment/code/scimap_rcn_lda.py](/files/wiki/methods/spatial-transcriptomics-microenvironment/code/scimap_rcn_lda.py) · [methods/spatial-transcriptomics-microenvironment/code/spatial_lag_tcc.py](/files/wiki/methods/spatial-transcriptomics-microenvironment/code/spatial_lag_tcc.py) · [methods/spatial-transcriptomics-microenvironment/code/spatial_proximity_interaction.py](/files/wiki/methods/spatial-transcriptomics-microenvironment/code/spatial_proximity_interaction.py) · [methods/spatial-transcriptomics-microenvironment/code/visium_signature_spatial.R](/files/wiki/methods/spatial-transcriptomics-microenvironment/code/visium_signature_spatial.R)
- 下一步分析导航（Step N → Step N+1）：
  - **方向 1：空间邻域细胞通讯与信号互作轴解析**（触发条件：在识别空间生态位与主要细胞/微环境共定位区域后，推断邻近细胞群体的配受体互作时；中间表：cellchat-lr-table；分析模版：methods/cell-cell-communication；可视化模版：templates/cellchat-circos-multi、templates/spatial-feature-grid、templates/spatial-coexpr-multichannel、templates/spatial-he-deconv-panel）
  - **方向 2：对比不同空间域或组织区域的细胞亚群组成偏好**（触发条件：量化肿瘤核心区、浸润前沿与正常边界区的细胞比例差异时；中间表：cell-proportion-stats；分析模版：methods/cell-proportion-composition；可视化模版：templates/cell-prop-flow-bar）
  - **方向 3：空间域标记基因与通路空间活性打分**（触发条件：检验局部微环境特异基因集或免疫/代谢通路在切片上的空间梯度变化时；中间表：pathway-score-table；分析模版：methods/gene-set-scoring；可视化模版：无）

- 方法配图关系（语义审查）：
  - [[templates/spatial-feature-grid|空间转录组特征分布网格]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：Visium 空间 Spot 上的连续基因表达、签名密度或 RCTD 反卷积权重可作为 default 主推网格图展示；模板不执行反卷积。；前提：Spot 坐标（x, y）对齐同一切片；各特征独立着色，色深仅在同一特征内比较。；适配：导出 spatial_spots_long.csv（x, y, feature, value, 可选 sample）。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/spatial-feature-grid/spec.json；运行证据：无
  - [[templates/spatial-coexpr-multichannel|多通道空间表达与重点区域]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：2 至 4 个配受体或 TLS 淋巴细胞标志基因在同一切片/多区域上的通道共定位与高亮区域可切换为 variant 多通道图。；前提：同一切片内各通道共享 Spot 坐标系；高分位数截断阈值（如 P99）须一致说明。；适配：导出 spatial_coexpr_spots.csv（spot_id, x, y, channel, value, 可选 region, highlight_zone）。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/spatial-coexpr-multichannel/spec.json；运行证据：无
  - [[templates/spatial-he-deconv-panel|配准组织图与反卷积对照]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：配准 H&E 组织切片裁剪图像与 Visium 空间反卷积权重图并排对照可切换为 variant 组织配准面板。；前提：Spot (x, y) 像素坐标须与 H&E 图像分辨率严格对齐（误差 < 1 像素）。；适配：导出 spatial_deconv_spots.csv（spot_id, x, y, feature, score, 可选 region）并附对齐 he_image.png。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/spatial-he-deconv-panel/spec.json；运行证据：无
  - [[templates/rcn-composition-stacked-heatmap|RCN 聚簇与分期堆叠复合热图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：20 um 空间邻域 LDA/K-means（RCN）或空间滞后肿瘤群落（TCC）的特征 Z-score 可与患者、分期比例轨道合并展示为主推默认（default）复合热图；模板不执行聚类。；前提：主矩阵与左右轨道表须按 cluster_id 一一对齐；患者与分期比例按独立样本或连续 FOV 汇总。；适配：导出 rcn_cluster_zscore.csv 与 rcn_cluster_tracks.csv。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/rcn-composition-stacked-heatmap/spec.json；运行证据：无
  - [[templates/voronoi-neighborhood-mosaic|Voronoi 细胞空间邻域镶嵌图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：连续物理视野（FOV）单细胞坐标与 RCN/TCC 邻域标签可切换为 variant 高密 Voronoi 多边形空间镶嵌与局部放大图；模板不做空间聚类。；前提：输入必须为未下采样打碎连续拓扑的物理 FOV（x, y），否则 Voronoi 面积失真。；适配：导出 spatial_cells_voronoi.csv（cell_id, x, y, neighborhood, 可选 fov_id/stage）。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/voronoi-neighborhood-mosaic/spec.json；运行证据：无
  - [[templates/spatial-expression-contour|空间蛋白表达等高线地形图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-21 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：基于物理组织切片坐标（X_um, Y_um）插值的连续蛋白/基因表达密度可切换为 variant 二维等高线地形分面图；模板不执行空间插值或核密度估计。；前提：等高线网格坐标与可选单细胞散点坐标来自同一未旋转裁剪的物理视野（fov_id）。；适配：导出 spatial_contours.csv（fov_id, X_um, Y_um 及特征列）与可选 spatial_cells.csv。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/spatial-expression-contour/spec.json；templates/spatial-expression-contour/verify/verify.json；运行证据：无
  - [[templates/stage-distance-boxen-grid|多分期对数坐标水平 Boxen 空间距离图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：各空间细胞邻域（RCN）到目标锚点邻域（如 RCN10）的跨分期微米距离分布可绘制为对数横轴水平 Boxen 分面图。；前提：物理距离须基于真实微米坐标计算（> 0 μm），跨分期显著性检验须与右侧星号列对应。；适配：导出 rcn_to_anchor_distances.csv 与 rcn_distance_ttests.csv。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/stage-distance-boxen-grid/spec.json；运行证据：无
  - [[templates/spatial-cell-highlight-grid|空间单细胞坐标表型高亮散点分面网格]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：单细胞空间物理坐标（X_um, Y_um）上各空间滞后簇（TCC1-10）或邻域的二值高亮空间落点可绘制为多面板网格。；前提：高亮表与背景视野表须共享同一物理微米坐标系与 fov_id。；适配：导出 spatial_cluster_highlights.csv 与 spatial_fov_background.csv。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/spatial-cell-highlight-grid/spec.json；运行证据：无
  - [[templates/boundary-intensity-gradient|肿瘤基质边界空间荧光强度梯度曲线]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：沿肿瘤-基质侵袭边界有符号距离分箱的多标志物平均荧光强度梯度可绘制为带双向区室箭头的连续剖面曲线。；前提：距离分箱以肿瘤-基质边界为 0 μm（负值代表肿瘤侧，正值代表基质侧）。；适配：导出 boundary_intensity_gradient.csv（dist_bin_um, compartment 及各标志物平均强度列）。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/boundary-intensity-gradient/spec.json；运行证据：无
  - [[templates/pvalue-threshold-heatmap|分期两两比较显著性阈值数值热图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：各空间细胞邻域（RCN1-10）在演进分期两两比较下的统计检验 P 值可绘制为 P < 0.05 暖色渐变与 ns 灰块阈值数值热图。；前提：P 值由上游分期两两统计检验给出（0-1），模板按 alpha_threshold 分割着色。；适配：导出 stage_pairwise_pvalues.csv（RCN, comparison, p_value）。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/pvalue-threshold-heatmap/spec.json；运行证据：无
  - [[templates/spatial-cooccurrence-matrix|空间邻域置换检验离散三态共现矩阵]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：空间滞后簇（TCC1-10）与邻近免疫/基质细胞的 1,000 次空间置换检验结果可绘制为共现/排斥/非显著离散三态矩阵。；前提：置换检验双侧显著性（P < 0.05）及 Z 分数方向须在上游汇总为 Co-occurrence / Avoidance / Non-Sig。；适配：导出 spatial_cooccurrence_states.csv（TCC, neighbour, sig_state）。
    - 关系证据：methods/spatial-transcriptomics-microenvironment.md#输出；templates/spatial-cooccurrence-matrix/spec.json；运行证据：无
<!-- facts:end -->

## 用途

在保留组织切片原始空间二维坐标的前提下，解析细胞亚群、病理生态位与肿瘤内微生物信号的空间分布格局，衔接配对单细胞参考图谱进行 Spot 细胞成分去卷积与空间邻域相关性分析。

## 适用

- 具备空间捕获点坐标、组织染色切片与表达计数矩阵的空间转录组数据（如 10x Visium）。
- 需结合配对单细胞转录组先验完成 spot-level 细胞比例解卷积，或在切片坐标上刻画外源微生物读段/微环境局部富集。

## 不适用

- **忽略测序污染对照分析肿瘤低丰度微生物信号**：必须设置空白/非组织区域质控以排除环境背景污染。
- **直接将 Spot 原始捕获信号当作单细胞分辨率细胞计数**。
- **跨切片直接拼接坐标而未对切片批次与比例尺校正**。

## 输入

空间 Spot 表达矩阵、二维坐标表及可选配对参考单细胞对象 [[interfaces/scrna-annotated-cells|已注释单细胞数据对象]]。

## 怎么做

1. **切片质控与组织前景对齐**：过滤组织外部 Spot 及极低捕获量区域，并与 H&E 组织病理分区对齐。
2. **去卷积或空间信号映射**：若为低分辨率 Spot 数据，引入高质量 scRNA-seq 参考执行 RCTD/cell2location 细胞组成估计；若检测外源特征（如细菌 UMI），需先统计空白背景 Spot 本底分布。
3. **空间统计与邻域比较**：基于空间邻接图计算自相关（Moran's I）与不同空间区域（肿瘤区/基质区/微生物富集区）的细胞比例及功能特征差异。

## 代码

本目录已封装 4 套独立可运行的跨模态空间微环境分析实现（均通过 `verify-method` 实跑真实论文切片并附 SHA256 收据，依赖声明见 `runtime.json`）：

- `scimap-rcn-spatial-lda`（`default`, Python, CyCIF）：`code/scimap_rcn_lda.py:run_scimap_rcn_spatial_lda`，实现 20 μm BallTree 邻域计数、Spatial LDA 主题建模与 K-means RCN 聚类。
- `spatial-proximity-interaction`（`variant`, Python, CyCIF）：`code/spatial_proximity_interaction.py:run_spatial_proximity_interaction`，实现表型对最近邻物理距离与度保持置换共现/排斥检验。
- `spatial-lag-tcc-clustering`（`variant`, Python, CyCIF）：`code/spatial_lag_tcc.py:run_spatial_lag_tcc`，实现反距离加权空间滞后特征矩阵与 TCC 聚类。
- `visium-signature-spatial`（`variant`, R, Visium ST）：`code/visium_signature_spatial.R:run_visium_signature_spatial`，实现 Visium Spot 5% 分位平移非负 L1 签名加权、共富集分区与多通道几何均值共定位。

另可参考历史归档模板 [[recipes/figureya-323stpathseq]]（空间转录组微生物分布与组织共定位分析）。

## 输出

输出各空间区域或 Spot 的 [[interfaces/cell-proportion-stats|细胞/微生态组成统计表]]，支持下游空间通讯、比例流向与通路空间打分。

## 参数

- `spot_min_counts` / `in_tissue_only`：切片组织掩膜与低质量捕获点过滤。
- `spatial_radius` / `n_neighbors`：空间邻接图构建的邻域半径或邻居数量。

## 上一步 / 下一步

- 上一步通常衔接 [[methods/reference-mapping]] 或 [[methods/cell-type-annotation]]；下游推荐跳转到 [[methods/cell-cell-communication]]、[[methods/cell-proportion-composition]] 或 [[methods/gene-set-scoring]]。

## 知识关联检查

已核对本方法接入 [[interfaces/scrna-annotated-cells]] 与输出 [[interfaces/cell-proportion-stats]] 的语义定义，并绑定三大可切换空间可视化模板：[[templates/spatial-feature-grid]]（default 特征网格）、[[templates/spatial-coexpr-multichannel]]（variant 多通道共定位）与 [[templates/spatial-he-deconv-panel]]（variant H&E 配准反卷积对照），均为 adaptable。

## 使用记录

<!-- user:start -->
<!-- user:end -->
