---
type: method
id: melanoma-spatial-immunoediting-workflow
title: 原发性黑色素瘤空间蛋白组与微区转录组免疫编辑复刻流程
status: draft
method_kind: workflow
tags:
- single-cell
- transcriptomics
- survival-analysis
data_domains:
- spatial-omics
- single-cell
- bulk-transcriptomics
- clinical-prognosis
inputs: []
outputs: []
source:
  kind: written
  url: https://github.com/labsyspharm/scimap
  commit: 0b7aaabcce80815a295aec1c1238f974f117fb33
license: CC-BY-NC-ND (article); MIT (upstream scimap algorithms)
cite:
- 'Nirmal AJ, Maliga Z, Vallius T, et al. The Spatial Landscape of Progression and
  Immunoediting in Primary Melanoma at Single-Cell Resolution. Cancer Discovery. 2022;12(6):1518-1541.
  DOI: 10.1158/2159-8290.CD-21-1357'
favorite: false
summary: 文献《The Spatial Landscape of Progression and Immunoediting in Primary Melanoma
  at Single-Cell Resolution》（Nirmal et al., Cancer Discovery 2022, PMC9167783）纯生信分析与
  1:1 复刻组合流程（覆盖 Fig. 1–7 + Supp. Fig. S1–S7 共 14 张图 105 条原子面板记录；已剔除全部纯显微/H&E 图与 Fig.
  S4 及概念图 1A/7I/7J/S2A/S2B）。
keywords:
- CyCIF
- spatial-proteomics
- RCN
- Spatial-LDA
- Voronoi
- TCC
- spatial-lag
- PickSeq
- GeoMx
- immunoediting
- melanoma
- scimap
- paper-replication
- 文献复刻
- GSE171888
- HTA-MELATLAS-1
- TCGA-SKCM
data_contract:
  input: 公开实测抽样集（HTA-MELATLAS-1 S3 MEL02/05/09/11/12 Panel 2 CyCIF 单细胞特征表、GEO GSE171888
    PickSeq mrSEQ 计数矩阵、UCSC Xena TCGA-SKCM 生存/表达、官方 Table S1–S7）与作者 scimap（MIT）源码算法。
  output: 复用与扩展方法分支（cell-type-annotation, dimensionality-reduction, cell-clustering,
    cell-proportion-composition, spatial-transcriptomics-microenvironment, differential-expression,
    gene-set-scoring, gene-set-enrichment, coexpression-ppi-network, immune-infiltration-tme,
    survival-prognosis-analysis）、Wiki `methods/melanoma-spatial-immunoediting-workflow/code/`
    归档代码（83 份脚本）及 6 套新建真实数据绘图模板。
---
# 原发性黑色素瘤空间蛋白组与微区转录组免疫编辑复刻流程

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：CC-BY-NC-ND (article); MIT (upstream scimap algorithms)
- 引用：Nirmal AJ, Maliga Z, Vallius T, et al. The Spatial Landscape of Progression and Immunoediting in Primary Melanoma at Single-Cell Resolution. Cancer Discovery. 2022;12(6):1518-1541. DOI: 10.1158/2159-8290.CD-21-1357
- 标签：single-cell、transcriptomics、survival-analysis
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/melanoma-spatial-immunoediting-workflow/code/00_sample_data.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/00_sample_data.py) · [methods/melanoma-spatial-immunoediting-workflow/code/01_cycif_qc_rescale_phenotype.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/01_cycif_qc_rescale_phenotype.py) · [methods/melanoma-spatial-immunoediting-workflow/code/02_umap_marker_gradients.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/02_umap_marker_gradients.py) · [methods/melanoma-spatial-immunoediting-workflow/code/03_spatial_rcn_lda.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/03_spatial_rcn_lda.py) · [methods/melanoma-spatial-immunoediting-workflow/code/04_spatial_interaction_pscore.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/04_spatial_interaction_pscore.py) · [methods/melanoma-spatial-immunoediting-workflow/code/05_spatial_lag_tcc.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/05_spatial_lag_tcc.py) · [methods/melanoma-spatial-immunoediting-workflow/code/06_mrseq_deseq2_pca_gsea.R](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/06_mrseq_deseq2_pca_gsea.R) · [methods/melanoma-spatial-immunoediting-workflow/code/07_s100b_network_tcga_survival.R](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/07_s100b_network_tcga_survival.R) · [methods/melanoma-spatial-immunoediting-workflow/code/08_extract_visual_spec.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/08_extract_visual_spec.py) · [methods/melanoma-spatial-immunoediting-workflow/code/figures/fig01_atlas_overview.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/figures/fig01_atlas_overview.py) · [methods/melanoma-spatial-immunoediting-workflow/code/figures/fig02_rcn_atlas.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/figures/fig02_rcn_atlas.py) · [methods/melanoma-spatial-immunoediting-workflow/code/figures/fig03_spatial_rcn_distance.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/figures/fig03_spatial_rcn_distance.py) · [methods/melanoma-spatial-immunoediting-workflow/code/figures/fig04_pdl1_interaction.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/figures/fig04_pdl1_interaction.py) · [methods/melanoma-spatial-immunoediting-workflow/code/figures/fig05_tcc_spatial.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/figures/fig05_tcc_spatial.py) · [methods/melanoma-spatial-immunoediting-workflow/code/figures/fig06_mrseq_tme.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/figures/fig06_mrseq_tme.py) · [methods/melanoma-spatial-immunoediting-workflow/code/figures/fig07_tme_immunoediting.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/figures/fig07_tme_immunoediting.py) · [methods/melanoma-spatial-immunoediting-workflow/code/figures/sfig01_qc_phenotyping.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/figures/sfig01_qc_phenotyping.py) · [methods/melanoma-spatial-immunoediting-workflow/code/figures/sfig02_rcn_validation.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/figures/sfig02_rcn_validation.py) · [methods/melanoma-spatial-immunoediting-workflow/code/figures/sfig03_rcn_stage_stats.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/figures/sfig03_rcn_stage_stats.py) · [methods/melanoma-spatial-immunoediting-workflow/code/figures/sfig05_tumor_heterogeneity.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/figures/sfig05_tumor_heterogeneity.py) · [methods/melanoma-spatial-immunoediting-workflow/code/figures/sfig06_proliferation_survival.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/figures/sfig06_proliferation_survival.py) · [methods/melanoma-spatial-immunoediting-workflow/code/figures/sfig07_ifng_jakstat.py](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/figures/sfig07_ifng_jakstat.py) · [methods/melanoma-spatial-immunoediting-workflow/code/README.md](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/README.md) · [methods/melanoma-spatial-immunoediting-workflow/code/runtime.json](/files/wiki/methods/melanoma-spatial-immunoediting-workflow/code/runtime.json) · 独立 Panel 脚本：共 61 个（见前端「论文复刻」面板）
- 面板覆盖清单：14 张图 / 105 条面板条目（实测/补表 1、本地重算 42、代理 17、剔除湿实验 0、剔除示意图 5、剔除显微影像 38），引用 22 套去重模板

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 用途

复刻 Nirmal et al. (*Cancer Discovery*, 2022, PMC9167783) 从单细胞 CyCIF 空间蛋白组到 PickSeq/GeoMx 微区转录组的原发性黑色素瘤进展与免疫编辑分析链路及全量 1:1 可复刻图表；严格遵守数据诚实边界，剔除全部荧光显微/H&E 图像（含整张 Supp. Fig. S4）、概念机制图与湿实验采集流程。

- **所属专题分支树**：[[scenarios/spatial-proteomics-immunoediting-playbook|多通道空间蛋白组 × mROI 空间转录组肿瘤免疫编辑分支树（Playbook）]]
- **课题走线实录卡**：[[projects/2022-nirmal-melanoma-spatial|原发性黑色素瘤空间进展与免疫编辑多组学解析（Nirmal et al., 2022）]]

## 适用

查阅高通量空间蛋白组（CyCIF）的轮间 DNA 质控、GMM 0–1 分段重标度与层级表型注释、20 μm 局部邻域 Spatial LDA 主题建模（RCN1–10）、Shapely 有限 Voronoi 空间邻域拓扑、1,000 次置换细胞共现检验、20 μm 空间滞后肿瘤细胞群落（TCC1–10）、肿瘤边界距离梯度，以及 PickSeq mROI DESeq2 / GSEA / ssGSEA / `S100B` 共表达网络与 TCGA-SKCM 预后验证完整实现。

## 不适用与严格数据诚实边界

1. **Panel 2 S3 单细胞表代理边界**：HTA-MELATLAS-1 S3 公开的 `MEL02/05/09/11/12` 单细胞特征表均采用 CyCIF Panel 2（21-plex），Panel 1/3/4/5 独有抗体（`S100B`、`MITF`、`KI67`、`PMEL`、`CD63`、`IRF1`、`MIF`、`CD74`、`CCNE2/A2/B1`、`pHH3`、`pRB`）在 S3 表中缺测；相应空间蛋白面板使用实测 Panel 2 指标（`S100a`、`MART1`、`SOX10`、`CCND1`、`HLADPB1`）作为 `proxy` 并在图中显式标注，不将 Panel 2 代理等同于原 Panel 1/3/4/5 全蛋白检测。
2. **PickSeq 120 mROIs 代理 GeoMx 70 mROIs**：`GSE171888` 仅公开 222 例 PickSeq 40 μm mROI 计数矩阵（抽样 120 例），NanoString GeoMx 70 mROIs 原始计数未公开存放在 GEO/S3/Table S6，故原标注 GeoMx 的面板（`6A, 7H, S6E, S7A, S7C, S7H`）统一使用 PickSeq 计数作为 `proxy`。
3. **Cohort 2 原文目视计数**：`Fig. 4F` Cohort 2（n=25）原文仅报告人工目视 PDL1 分箱计数而未沉积单细胞 CSV，复刻仅忠实引用原文分箱并与 Cohort 1（S3 实测 n=5）区分展示。
4. **TCGA-SKCM 缺测基因与抽样边界**：`Fig. S6F` 使用 UCSC Xena TCGA-SKCM 抽样 120 例重算（`PMEL` 映射自旧名 `SILV`）；`MT-ND2` 在 Legacy HiSeqV2 RSEM 矩阵中缺失。
5. **非计算面板剔除与缺失线扫描**：`excluded_imaging` 共 38 项（含整张 **Supp. Fig. S4** 100% 荧光显微图像），`excluded_schematic` 共 5 项（`1A, 7I, 7J, S2A, S2B`），`unavailable_pixel_linescan` 共 2 项（`1I-right, S1H`，60× 3D 突触 0–16 μm 逐像素线扫描未存入 S3 单细胞特征表）。

## 输入

HTA-MELATLAS-1 S3 公开 CyCIF 单细胞特征压缩包（`MEL02/05/09/11/12`）、GEO `GSE171888` PickSeq 计数与元数据、UCSC Xena TCGA-SKCM 生存/表达矩阵、官方 Table S1–S7 与 `upstream_repo/scimap`（MIT）。详见 [归档源码说明](melanoma-spatial-immunoediting-workflow/code/README.md)。

## 怎么做

| 正文计算阶段 | 补充材料 / 数据来源 | 作者参考实现（`scimap` MIT） | 归档分步脚本（`code/`） | 对应复刻图 |
|---|---|---|---|---|
| 0. 公开多组学数据拉取与固定种子抽样 | Data Availability、Table S2–S4、GSE171888、TCGA-SKCM | `downloadDemoData.py` | `00_sample_data.py` | 全流程输入（`2,500` 分层细胞、`1,642` 连续 FOV、`120` mROIs、`120` TCGA 患者） |
| 1. CyCIF DNA 轮间质控、GMM 重标度与层级门控注释 | Table S5（Panel 2 层级规则）、Fig. S1C, S2B | `rescale.py`, `phenotype_cells.py` | `01_cycif_qc_rescale_phenotype.py` | Fig. 1D, 2A–B；Supp. Fig. S1C |
| 2. UMAP 降维、S100A 跨期比例与肿瘤特征 PCA/密度 | Methods: Single-Cell Phenotyping | `umap.py`, `plotting/umap.py` | `02_umap_marker_gradients.py` | Fig. 1D, 2A–C；Supp. Fig. S5A, S5D, S6A |
| 3. 20 μm Spatial LDA、K-means 30、RCN1–10 与 Voronoi 拓扑 | Methods: RCN Analysis；Table S7 | `spatial_count.py`, `spatial_lda.py`, `spatial_cluster.py`, `spatial_distance.py`, `voronoi.py` | `03_spatial_rcn_lda.py` | Fig. 2D–E, 3A, 3C-top, 3D–F；Supp. Fig. S2C-top, S2D–E, S3B, S3D–E |
| 4. 1,000 次置换空间共现、10 μm 邻近体积与肿瘤边界梯度 | Methods: Co-occurrence & Proximity Volume | `spatial_interaction.py`, `spatial_pscore.py` | `04_spatial_interaction_pscore.py` | Fig. 1E, 4B, 4F, 7E–G；Supp. Fig. S3C, S7D-right, S7I-bars |
| 5. 20 μm 空间滞后特征矩阵与肿瘤细胞群落 TCC1–10 | Methods: Spatial Lag Analysis | `spatial_expression.py` | `05_spatial_lag_tcc.py` | Fig. 5B–F；Supp. Fig. S5B–C |
| 6. PickSeq DESeq2 差异分析、PCA、ssGSEA 与 GSEA | GSE171888、Table S6 (`DEG_MIS_vs_EM-IM`, `DEG_EM_vs_IM`) | R (`DESeq2`, `GSVA`, `clusterProfiler`) | `06_mrseq_deseq2_pca_gsea.R` | Fig. 6A–G, 6K, 7B, 7H；Supp. Fig. S6C–E, S7A–C, S7E–H |
| 7. `S100B` Pearson 共表达网络（`r>=0.6`）与 TCGA-SKCM 生存 | Table S6 `S100B` 模块、UCSC Xena TCGA-SKCM | R (`cor`, `igraph`, `survival`, `survminer`) | `07_s100b_network_tcga_survival.R` | Fig. 6I–J；Supp. Fig. S6F |
| 8. 排版尺寸/色调规范提取与 60 面板 / 13 整图 1:1 渲染 | 出版高分辨率原图与 Supp. PDF 页 | — | `08_extract_visual_spec.py`、`figures/*.py`、`panels/*.py` | 13 组复刻全图（`gallery/2026-11-20-nirmal-melanoma-spatial/`） |

[1:1 视觉对照画廊](../../gallery/2026-11-20-nirmal-melanoma-spatial/source.md)记录协调者六维视觉验收 **13/13 PASS**（覆盖 Main Fig. 1–7 与 Supp. Fig. S1–S3, S5–S7；Supp. Fig. S4 整图因 100% 荧光显微图像而排除）。

## 14 张主附图 × 全量面板覆盖矩阵（105 条原子面板条目）

结构化证据分层与输入表追踪见 `methods/melanoma-spatial-immunoediting-workflow/panel-manifest.yaml`（`schema_version: 2`，含全部 60 个可执行独立 Panel 脚本及 45 条排除/缺失记录）：

| 原文献图号 | 保留计算面板 | 排除 / 缺失面板 | 核心分析方法（`methods/`） | 对应绘图模板（`templates/`） |
|---|---|---|---|---|
| **Fig. 1** | **1D, 1E** | 1A (`excluded_schematic`); 1B, 1C, 1F, 1G, 1H, 1I-left, 1J (`excluded_imaging`); 1I-right (`unavailable_pixel_linescan`) | [[methods/cell-type-annotation]] · [[methods/dimensionality-reduction]] · [[methods/spatial-transcriptomics-microenvironment]] | [[templates/scrna-celltype-umap]] · [[templates/scrna-feature-umap-grid]] · [[templates/spatial-feature-grid]] |
| **Fig. 2** | **2A, 2B, 2C, 2D, 2E** | 无 | [[methods/cell-type-annotation]] · [[methods/cell-proportion-composition]] · [[methods/spatial-transcriptomics-microenvironment]] | [[templates/tri-panel-stage-umap]]（新建） · [[templates/scrna-feature-umap-grid]] · [[templates/checkpoint-group-boxplot]] · [[templates/rcn-composition-stacked-heatmap]]（新建） · [[templates/cell-prop-flow-bar]] |
| **Fig. 3** | **3A, 3C-top, 3D, 3E, 3F** | 3B, 3C-bottom (`excluded_imaging`) | [[methods/spatial-transcriptomics-microenvironment]] · [[methods/cell-proportion-composition]] | [[templates/voronoi-neighborhood-mosaic]]（新建） · [[templates/cell-prop-flow-bar]] · [[templates/resampling-metric-box]] · [[templates/half-violin-decile-shift]]（新建） |
| **Fig. 4** | **4B (`proxy`), 4F (`proxy`)** | 4A, 4C, 4D, 4E, 4G (`excluded_imaging`) | [[methods/spatial-transcriptomics-microenvironment]] · [[methods/cell-proportion-composition]] | [[templates/scp-comp-trend]] · [[templates/scp-count-bar]] |
| **Fig. 5** | **5B (`proxy`), 5C, 5D, 5E-top, 5F** | 5A, 5E-bottom-left (`excluded_imaging`) | [[methods/spatial-transcriptomics-microenvironment]] · [[methods/cell-proportion-composition]] | [[templates/spatial-feature-grid]] · [[templates/rcn-composition-stacked-heatmap]]（新建） · [[templates/voronoi-neighborhood-mosaic]]（新建） · [[templates/scp-count-bar]] |
| **Fig. 6** | **6A (`proxy`), 6B, 6C, 6D, 6E, 6F, 6G, 6I, 6J, 6K (`proxy`)** | 6H (`excluded_imaging`) | [[methods/dimensionality-reduction]] · [[methods/differential-expression]] · [[methods/gene-set-scoring]] · [[methods/gene-set-enrichment]] · [[methods/coexpression-ppi-network]] | [[templates/fy-pca]] · [[templates/fy-fancybar]] · [[templates/pathway-zscore-heatmap]] · [[templates/bulk-de-volcano]] · [[templates/coexpr-hub-radial-network]]（新建） · [[templates/scp-comp-trend]] · [[templates/scp-expr-ridge]] |
| **Fig. 7** | **7B, 7E (`proxy`), 7F (`proxy`), 7G-bars, 7H (`proxy`)** | 7A, 7C, 7D, 7G-middle (`excluded_imaging`); 7I, 7J (`excluded_schematic`) | [[methods/differential-expression]] · [[methods/immune-infiltration-tme]] · [[methods/spatial-transcriptomics-microenvironment]] · [[methods/cell-proportion-composition]] | [[templates/fy-fancybar]] · [[templates/cell-prop-flow-bar]] · [[templates/pathway-zscore-heatmap]] |
| **Supp. Fig. 1** | **S1C** | S1A, S1B, S1D–G, S1I (`excluded_imaging`); S1H (`unavailable_pixel_linescan`) | [[methods/cell-type-annotation]] | 面板定制规则树脚本 `code/panels/sfig01_c.py` |
| **Supp. Fig. 2** | **S2C-top, S2D, S2E** | S2A, S2B (`excluded_schematic`); S2C-mid/bot (`excluded_imaging`) | [[methods/cell-clustering]] · [[methods/spatial-transcriptomics-microenvironment]] | [[templates/voronoi-neighborhood-mosaic]]（新建） · [[templates/rcn-composition-stacked-heatmap]]（新建） |
| **Supp. Fig. 3** | **S3B, S3C, S3D, S3E** | S3A (`excluded_imaging`) | [[methods/cell-proportion-composition]] · [[methods/spatial-transcriptomics-microenvironment]] | [[templates/resampling-metric-box]] · [[templates/scp-count-bar]] · [[templates/spatial-feature-grid]] · [[templates/roe-cox-heatmap]] |
| **Supp. Fig. 4** | **无（整图排除）** | **S4A, S4B, S4C** (`excluded_imaging`, 100% CyCIF 荧光显微图像) | — | *Excluded Imaging (Entire Figure)* |
| **Supp. Fig. 5** | **S5A, S5B (`proxy`), S5C, S5D (`proxy`)** | S5E (`excluded_imaging`) | [[methods/dimensionality-reduction]] · [[methods/spatial-transcriptomics-microenvironment]] · [[methods/cell-proportion-composition]] | [[templates/spatial-feature-grid]] · [[templates/pathway-zscore-heatmap]] · [[templates/pred-density-scatter]] |
| **Supp. Fig. 6** | **S6A (`proxy`), S6C, S6D-table (`original_table`), S6E (`proxy`), S6F** | S6B, S6D-images (`excluded_imaging`) | [[methods/cell-proportion-composition]] · [[methods/gene-set-enrichment]] · [[methods/differential-expression]] · [[methods/survival-prognosis-analysis]] | [[templates/scp-comp-pie]] · [[templates/resampling-metric-box]] · [[templates/km-survival-risk-grid]]（新建） |
| **Supp. Fig. 7** | **S7A (`proxy`), S7B, S7C (`proxy`), S7D-right, S7E, S7F (`proxy`), S7G (`proxy`), S7H (`proxy`), S7I-bars** | S7D-left, S7I-images (`excluded_imaging`) | [[methods/differential-expression]] · [[methods/gene-set-enrichment]] · [[methods/gene-set-scoring]] · [[methods/spatial-transcriptomics-microenvironment]] · [[methods/cell-proportion-composition]] · [[methods/immune-infiltration-tme]] | [[templates/fy-fancybar]] · [[templates/pathway-zscore-heatmap]] · [[templates/cell-prop-flow-bar]] |

## 代码

- **本地工程工作区**：`<sources_root>/papers/pmc9167783/`（`upstream_repo/scimap` 原始镜像 + `src/` 分步与拼图源码）
- **Wiki 固定代码存档**：`methods/melanoma-spatial-immunoediting-workflow/code/`（83 份零硬编码便携脚本：9 份主流程脚本 + 13 份整图合成脚本 + 60 份单面板脚本 + `_fig_common.py`）
- **关联分支树与课题实录**：[[scenarios/spatial-proteomics-immunoediting-playbook]]、[[projects/2022-nirmal-melanoma-spatial]]
- **新建 6 套 Layer-2 通用绘图模板（均使用真实分析表抽样，遵循 *Cancer Discovery* 审美）**：[[templates/tri-panel-stage-umap]]、[[templates/rcn-composition-stacked-heatmap]]、[[templates/voronoi-neighborhood-mosaic]]、[[templates/half-violin-decile-shift]]、[[templates/coexpr-hub-radial-network]]、[[templates/km-survival-risk-grid]]

## 输出

各阶段分析中间表（`runs/step00`–`step07`）、60 面板单图与 13 张 1:1 复刻画廊图版。

## 知识关联检查

查重说明：分析步骤复用本库既有 11 个规范分析方法家族（不新建重复分析家族），仅新建本篇专属 workflow 总览页、课题实录卡、空间蛋白组免疫编辑 Playbook 与 6 套通过 `style_tier` 槽位检查的新模板；workflow 页仅记录跨方法串联流程，不声明 `figure_relations` 主记录，6 套新模板均已挂载回对应规范分析家族的 `figure_relations`。

## 使用记录

<!-- user:start -->
<!-- user:end -->
