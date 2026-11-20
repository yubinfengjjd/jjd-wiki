---
type: project
slug: 2022-nirmal-melanoma-spatial
title: 原发性黑色素瘤空间进展与免疫编辑多组学解析（Nirmal et al., 2022）
playbook: spatial-proteomics-immunoediting-playbook
status: active
templates:
- tri-panel-stage-umap
- rcn-composition-stacked-heatmap
- voronoi-neighborhood-mosaic
- half-violin-decile-shift
- coexpr-hub-radial-network
- km-survival-risk-grid
- rcn-horizontal-bar-pie
- compartment-dual-track-bars
- stage-track-block-heatmap
- spatial-expression-contour
- gsea-running-enrichment
- scrna-celltype-umap
- scrna-feature-umap-grid
- spatial-feature-grid
- checkpoint-group-boxplot
- cell-prop-flow-bar
- resampling-metric-box
- roe-cox-heatmap
- pathway-zscore-heatmap
- bulk-de-volcano
- fy-pca
- fy-fancybar
- scp-comp-trend
- scp-count-bar
- scp-comp-pie
- scp-expr-ridge
- pred-density-scatter
methods:
- cell-type-annotation
- dimensionality-reduction
- cell-clustering
- cell-proportion-composition
- spatial-transcriptomics-microenvironment
- differential-expression
- gene-set-scoring
- gene-set-enrichment
- coexpression-ppi-network
- immune-infiltration-tme
- survival-prognosis-analysis
summary: Nirmal et al. (Cancer Discovery, 2022, PMC9167783) 原发性黑色素瘤 CyCIF 空间蛋白组 + PickSeq/GeoMx mROI 转录组 + TCGA-SKCM 5 阶段步进走线实录：从 CyCIF 单细胞门控演进图谱、20 μm RCN 空间邻域、边界 PDL1–PD1 免疫互作、空间滞后 TCC 异质性到 S100B 枢纽网络与预后验证（已剔除全部显微图像与 Fig. S4）。
---
# 原发性黑色素瘤空间进展与免疫编辑多组学解析（Nirmal et al., 2022）

- **所属决策树**：[[scenarios/spatial-proteomics-immunoediting-playbook|多通道空间蛋白组 × mROI 空间转录组肿瘤免疫编辑分支树]]
- **复刻流程与源码档案**：[[methods/melanoma-spatial-immunoediting-workflow|原发性黑色素瘤空间蛋白组与微区转录组免疫编辑复刻流程]]（归档 83 份便携脚本；本地工作区 `<sources_root>/papers/pmc9167783/`）
- **1:1 视觉对照画廊**：[13 张主附图 1:1 视觉对比画廊（13/13 PASS）](../../gallery/2026-11-20-nirmal-melanoma-spatial/source.md)（Main Fig. 1–7 + Supp. Fig. S1–S3, S5–S7；注：`Supp. Fig. S4` 因 100% 荧光显微图像整图排除，视觉复刻验收不等同于原百万级细胞全切片重计算）
- **数据诚实边界与排除声明**：
  1. **Panel 2 S3 公开表代理**：HTA-MELATLAS-1 S3 `MEL02/05/09/11/12` 单细胞表仅含 Panel 2（21-plex），Panel 1/3/4/5 独有蛋白（`S100B/MITF/KI67/PMEL/CD63/IRF1/MIF/CD74` 等）以实测 Panel 2 标志物（`S100a/MART1/SOX10/CCND1/HLADPB1`）或 PickSeq 转录组作为 `proxy`。
  2. **PickSeq 120 mROIs 代理 GeoMx 70 mROIs**：GeoMx CTA 计数未公开沉积于 `GSE171888` / S3 / Table S6，相应面板以同解剖位点 PickSeq 计数（抽样 120 例）作为 `proxy`。
  3. **Cohort 2 原文目视计数**：`Fig. 4F` Cohort 2（n=25）忠实引用原文人工目视分箱结果，不伪造单细胞源表。
  4. **排除与不可用项**：`excluded_imaging`（含整张 **Fig. S4** 及 35 个局部显微面板）、`excluded_schematic`（`1A, 7I, 7J, S2A, S2B`）、`unavailable_pixel_linescan`（`1I-right, S1H`）。许可为文章 `CC BY-NC-ND` 与算法 `MIT`（`labsyspharm/scimap`）。

## 5 阶段科学步进走线实录

### Stage 1（Main Fig. 1D–E, 2A–C & Supp. Fig. S1C）：CyCIF 演进图谱构建与层级门控表型注释

- **【科学问题与假设】**：经跨循环 DNA 保留率质控（`r >= 0.8`）与 GMM 0–1 分段重标度后，能否用统一样本层级门控规则（Table S5）稳定分辨黑色素瘤从 Normal → Precursor → MIS → IM 演进中的 12/16 类主要上皮、肿瘤与免疫亚群，并捕获早期的表型偏移（如 `S100A` 上调）？
- **【方法与模板】**：[[methods/cell-type-annotation]] + [[methods/dimensionality-reduction]] + [[methods/cell-proportion-composition]] + [[templates/tri-panel-stage-umap]]（三联分群/分期/患者 UMAP） + [[templates/scrna-celltype-umap]] + [[templates/scrna-feature-umap-grid]] + [[templates/checkpoint-group-boxplot]]
- **【原文结论与本地数据边界】**：原文对 ~1.7M CyCIF 细胞通过 `scimap` GMM 重标度与层级表型树注释，发现 `S100A+` 比例从 Normal 到 MIS/IM 显著上升；**本地边界**：本地抽取 `MEL02/05/09/11/12` 分层 2,500 细胞（QC 后 1,987 细胞）与 4 个完整连续 FOV（QC 后 1,418 细胞），UMAP 为基于 Panel 2 实测 15 个公共蛋白重算，EM 期因仅存于未附 ROI 掩膜的 MEL01 而如实留空说明。
- **【触发下一步分叉】**：完成单细胞门控注释后，保留连续物理坐标（`X_um, Y_um`），进入 Stage 2 开展 20 μm 局部邻域细胞组成主题建模（Spatial LDA → RCN1–10）。

### Stage 2（Main Fig. 2D–E, 3A, 3C-top, 3D–F & Supp. Fig. S2C–E, S3B–E）：20 μm RCN 空间邻域主题建模与 Voronoi 拓扑重构

- **【科学问题与假设】**：单细胞表型在 20 μm 物理微邻域内是否反复组装为保守的“循环细胞邻域（RCN1–10）”，且在黑色素瘤进展轴（Normal → Precursor → MIS → IM）中发生空间重构与免疫-黑素细胞距离迁移？
- **【方法与模板】**：[[methods/spatial-transcriptomics-microenvironment]] + [[methods/cell-clustering]] + [[methods/cell-proportion-composition]] + [[templates/rcn-composition-stacked-heatmap]]（30 聚簇复合热图） + [[templates/rcn-horizontal-bar-pie]]（邻域水平堆叠+5 组功能饼图） + [[templates/voronoi-neighborhood-mosaic]]（高密 Voronoi 空间镶嵌与圆形裁剪） + [[templates/half-violin-decile-shift]]（半小提琴 + 分位数哑铃偏移） + [[templates/cell-prop-flow-bar]] + [[templates/resampling-metric-box]]
- **【原文结论与本地数据边界】**：原文通过 20 μm `spatial_count` + `spatial_lda`（10 motifs）+ K-means（k=30）并簇得到表皮型（RCN1）、髓系富集（RCN2–4）、免疫抑制（RCN5/8）、T 细胞富集（RCN6/7）与黑素瘤主群（RCN9/10），并揭示 Precursor 期淋巴/髓系细胞相对 Normal 已显著靠近黑素细胞（Fig. 3F）；**本地边界**：基于 1,418 个连续物理 FOV 细胞完整重跑 LDA + K-means + Shapely Voronoi，样本 N/P FOV 中 `RCN10` 细胞数为 0 时在 Fig. 3E 显式标注 `0 RCN10 in sample FOV`，`S3E` 与 `Table S7` 互校。
- **【触发下一步分叉】**：在空间邻域识别出 `RCN5/8`（PDL1+ 髓系–PD1+ CTL 富集）及肿瘤侵袭前沿后，触发 Stage 3 检验特定免疫检查点细胞对的直接空间共现与肿瘤边界细胞因子梯度。

### Stage 3（Main Fig. 4B, 4F, 7E–H & Supp. Fig. S3C, S7D-right, S7F–I）：肿瘤边界距离梯度与 PDL1⁺ 髓系–PD1⁺ CTL 空间交互

- **【科学问题与假设】**：`PDL1+` 髓系细胞（巨噬/树突细胞）与 `PD1+` CTL 在空间上是否于 20 μm 尺度显著共现（1,000 次置换检验），并在侵袭肿瘤–基质边界形成受抑梯度（`IRF1`、`MHC-II`、`IDO1`、`MIF-CD74`）？
- **【方法与模板】**：[[methods/spatial-transcriptomics-microenvironment]] + [[methods/immune-infiltration-tme]] + [[methods/cell-proportion-composition]] + [[templates/scp-comp-trend]] + [[templates/scp-count-bar]] + [[templates/compartment-dual-track-bars]]（表皮/真皮双区室堆叠条图） + [[templates/stage-track-block-heatmap]]（分期色带分块热图） + [[templates/cell-prop-flow-bar]]
- **【原文结论与本地数据边界】**：原文展示 PDL1+ DC/巨噬细胞与 PD1+ CTL 在 MIS→IM 共现显著增强且 Cohort 1/2 均检测到髓系 PDL1 阳性；肿瘤侵袭前沿形成紧邻肿瘤边界的免疫抑制带；**本地边界**：`Fig. 4B` 基于 4 个连续 FOV 的 16 个子 ROI 执行 1,000 次置换检验作为 `proxy`；`Fig. 4F` 区分 Cohort 1（S3 实测重算）与 Cohort 2（原文目视分箱）；`Fig. 7E` 以 Panel 2 实测 `HLADPB1`（MHC-II）代理 `IRF1` 边界曲线；`Fig. 4A/C/D/E/G` 与 `Fig. S4` 整图全部因纯显微图像排除。
- **【触发下一步分叉】**：免疫编辑抑制前沿解释了微环境外围抵抗，但侵袭肿瘤内部的克隆/细胞状态空间异质性驱动机制仍未解析，触发 Stage 4 肿瘤中心 20 μm 空间滞后分析。

### Stage 4（Main Fig. 5B–F & Supp. Fig. S5A–D, S6A）：20 μm 空间滞后肿瘤细胞群落（TCC）异质性与增殖状态

- **【科学问题与假设】**：利用肿瘤细胞自身及 20 μm 邻域空间滞后蛋白表达（`spatial_expression`），能否在侵袭性黑色素瘤中划分出空间局部均一的肿瘤细胞群落（TCC1–10），并与不同免疫排斥/增殖状态关联？
- **【方法与模板】**：[[methods/spatial-transcriptomics-microenvironment]] + [[methods/dimensionality-reduction]] + [[methods/cell-proportion-composition]] + [[templates/rcn-composition-stacked-heatmap]] + [[templates/voronoi-neighborhood-mosaic]] + [[templates/spatial-expression-contour]]（2D 蛋白表达等高线地形图） + [[templates/spatial-feature-grid]] + [[templates/pred-density-scatter]] + [[templates/scp-comp-pie]]
- **【原文结论与本地数据边界】**：原文基于 `S100A/MITF/S100B` 与 `KI67` 鉴定出高增殖、低抗原呈递或免疫互作型 TCC1–10；**本地边界**：基于 Panel 2 肿瘤细胞 20 μm 空间滞后特征完整重算 TCC1–10 与 TCC×免疫细胞 1,000 次置换共现矩阵（`S5C`）；因 S3 Panel 2 缺测 `S100B/MITF/KI67/CCNA2/B1/E2`，`Fig. 5B/S5B` 以 `MART1/S100a/SOX10` 代理，`Fig. S5D/S6A` 以 `CCND1` 等 Panel 2 指标作为增殖代理并明确注明。
- **【触发下一步分叉】**：蛋白通道受限（21–30 plex）难以揭示深层信号通路与共表达转录程序，触发 Stage 5 汇合 PickSeq/GeoMx 微区全转录组与 TCGA-SKCM 队列。

### Stage 5（Main Fig. 6A–G, 6I–K, 7B & Supp. Fig. S6C–F, S7A–C, S7E）：PickSeq/GeoMx mROI 转录组、`S100B` 枢纽网络、IFNγ/JAK-STAT 与 TCGA-SKCM 预后

- **【科学问题与假设】**：沿组织病理显微分区（MIS、IR、bTIL、IB、IM、EM）采集的 mROI 全转录组中，侵袭缘（IM）与外生肿瘤（EM）在 EMT/KRAS/IFNγ-JAK-STAT 通路及 `S100B` 共表达模块上有何差异，且枢纽基因是否影响患者临床生存？
- **【方法与模板】**：[[methods/differential-expression]] + [[methods/gene-set-scoring]] + [[methods/gene-set-enrichment]] + [[methods/coexpression-ppi-network]] + [[methods/survival-prognosis-analysis]] + [[templates/coexpr-hub-radial-network]]（中心枢纽放射共表达网） + [[templates/km-survival-risk-grid]]（8 基因 KM 网格） + [[templates/stage-track-block-heatmap]]（分期色带分块热图） + [[templates/gsea-running-enrichment]]（GSEA 跑分曲线与条码图） + [[templates/fy-pca]] + [[templates/bulk-de-volcano]] + [[templates/fy-fancybar]] + [[templates/scp-expr-ridge]]
- **【原文结论与本地数据边界】**：`DESeq2`、`GSEA` 与 Pearson 网络（`r >= 0.6`）识别出 EM/IM 间的 EMT/KRAS/IFNγ-JAK-STAT 分化及 35/64 基因 `S100B` 核心共表达模块（本地重算与 Table S6 交集 22 个基因），并在 TCGA-SKCM 中验证 `S100B` 等基因生存分层；**本地边界**：GeoMx 70 mROIs 以公开 `GSE171888` PickSeq 120 mROIs 代理；TCGA-SKCM 抽样 n=120 患者重算 8 个模块基因 KM 曲线（`PMEL` 映射自 `SILV`，`MT-ND2` 在 Legacy HiSeqV2 矩阵缺测）。
- **【课题收口状态说明】**：全部 13 组画廊图（13/13 PASS，Fig. S4 整图排除）、83 份零硬编码便携脚本、105 条原子面板清单（`panel-manifest.yaml`）、11 套真实数据通用绘图模板（含同论文同质化归并的 5 套衍生风格模板，均已通过 `verify-template`、`check-entry --record` 与 `mark-ready` 并完成方法关联）及本专题 Playbook 均已完整入库。
