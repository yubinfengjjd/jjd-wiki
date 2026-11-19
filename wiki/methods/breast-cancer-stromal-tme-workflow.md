---
type: method
id: breast-cancer-stromal-tme-workflow
title: 乳腺癌基质单细胞与空转微环境复刻流程
status: draft
method_kind: workflow
tags:
- scrna
- spatial-transcriptomics
- breast-cancer
- stromal-tme
- caf
- endothelial
- mural-cell
- paper-replication
data_domains:
- scrna
- spatial-transcriptomics
- bulk-rna
inputs: []
outputs: []
source:
  kind: written
license: LicenseRef-Literature-Workflow
cite:
- 'Integration of single-cell and spatial transcriptomics reveals stromal cell features
  in breast cancer (npj Precision Oncology, 2026) DOI: 10.1038/s41698-026-01718-1'
favorite: false
summary: 文献《Integration of single-cell and spatial t》纯生信方法拆解与复刻组合流程（已剔除湿实验，含正文-附加材料映射与双份代码存档）。
keywords:
- 文献复刻
- TCGA-BRCA
- GSE167036
- GSE139495
- GSE148673
data_contract:
  input: 原始数据/抽样子集（TCGA-BRCA, GSE167036, GSE139495, GSE148673, GSE161529, GSE176078,
    GSE180286, GSE195861, GSE225600, GSE246613, E-MTAB-10607, GSE190811, GSE13949551,
    GSE14867352, GSE16152953, GSE17607820, GSE18028654, GSE19586155, GSE22560056,
    GSE24661357）与文献 Methods/附加材料流程。
  output: 复用方法分支（batch-integration, differential-expression, gene-set-scoring, gene-set-enrichment,
    cell-proportion-composition, survival-prognosis-analysis, trajectory-inference,
    spatial-transcriptomics-microenvironment, cell-cell-communication, immune-infiltration-tme）、本地
    `src/` 与 Wiki `methods/breast-cancer-stromal-tme-workflow/code/` 源码及复刻可视化模板。
---
# 乳腺癌基质单细胞与空转微环境复刻流程

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：LicenseRef-Literature-Workflow
- 引用：Integration of single-cell and spatial transcriptomics reveals stromal cell features in breast cancer (npj Precision Oncology, 2026) DOI: 10.1038/s41698-026-01718-1
- 标签：scrna、spatial-transcriptomics、breast-cancer、stromal-tme、caf、endothelial、mural-cell、paper-replication
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/breast-cancer-stromal-tme-workflow/code/00_prepare_spatial_and_scrna.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/00_prepare_spatial_and_scrna.R) · [methods/breast-cancer-stromal-tme-workflow/code/00_sample_and_extract_moesm.py](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/00_sample_and_extract_moesm.py) · [methods/breast-cancer-stromal-tme-workflow/code/00c_style_and_manifold.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/00c_style_and_manifold.R) · [methods/breast-cancer-stromal-tme-workflow/code/01_scrna_harmony_de.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/01_scrna_harmony_de.R) · [methods/breast-cancer-stromal-tme-workflow/code/02_progeny_roe_cox.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/02_progeny_roe_cox.R) · [methods/breast-cancer-stromal-tme-workflow/code/03_spatial_scores_deconv.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/03_spatial_scores_deconv.R) · [methods/breast-cancer-stromal-tme-workflow/code/04_trajectory_pseudotime.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/04_trajectory_pseudotime.R) · [methods/breast-cancer-stromal-tme-workflow/code/05_crosstalk_metabolism.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/05_crosstalk_metabolism.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/fig01_stromal_atlas.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/fig01_stromal_atlas.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/fig02_fib_characterization.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/fig02_fib_characterization.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/fig03_abca8_lpfib_tcell.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/fig03_abca8_lpfib_tcell.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/fig04_ec_characterization.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/fig04_ec_characterization.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/fig05_mural_characterization.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/fig05_mural_characterization.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/fig06_tme_crosstalk.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/fig06_tme_crosstalk.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/sfig01_stromal_batch_markers.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/sfig01_stromal_batch_markers.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/sfig02_fib_supp.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/sfig02_fib_supp.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/sfig03_spatial_markers_deconv.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/sfig03_spatial_markers_deconv.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/sfig04_ec_supp.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/sfig04_ec_supp.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/sfig05_mural_supp_chord.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/sfig05_mural_supp_chord.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/sfig06_spatial_tls_pgf_lr.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/sfig06_spatial_tls_pgf_lr.R) · [methods/breast-cancer-stromal-tme-workflow/code/make_side_by_side.py](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/make_side_by_side.py) · [methods/breast-cancer-stromal-tme-workflow/code/README.md](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/README.md) · [methods/breast-cancer-stromal-tme-workflow/code/runtime.json](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/runtime.json)

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 用途

复刻文献《Integration of single-cell and spatial transcriptomics reveals stromal cell features in breast cancer》的纯生信分析链路与全量可复刻发表级图表；已明确剔除动物/细胞湿实验部分。

## 适用

- 原文开源代码仓库：https://github.com/qingyaolab/breastcancer-Stromal-Cell
- 关联数据编号：TCGA-BRCA, GSE167036, GSE139495, GSE148673, GSE161529, GSE176078, GSE180286, GSE195861, GSE225600, GSE246613, E-MTAB-10607, GSE190811, GSE13949551, GSE14867352, GSE16152953, GSE17607820, GSE18028654, GSE19586155, GSE22560056, GSE24661357
- 附加材料：41698_2026_1718_MOESM1_ESM.docx, 41698_2026_1718_MOESM2_ESM.xlsx, 41698_2026_1718_MOESM3_ESM.xlsx, 41698_2026_1718_MOESM4_ESM.xlsx, 41698_2026_1718_MOESM5_ESM.xlsx, 41698_2026_1718_MOESM6_ESM.xlsx, 41698_2026_1718_MOESM7_ESM.xlsx, 41698_2026_1718_MOESM8_ESM.xlsx

## 不适用

- 小规模复现基于官方MOESM1-8附加表、Zenodo 19562239单张真实Visium切片(2241 spots x 17922 genes含H&E)及36亚群1800细胞抽样scRNA；12张计算图(Main 1-6剔除湿实验3F-H + Supp 1-6)经Orca/Codex串行1:1视觉复刻并通过6维终审；monocle3/CellChat/scMetabolism未装分支已如实记录。

## 输入

详见各关联分析方法与衍生模板数据契约。

## 怎么做

- **步骤 1 · 质控与标准化预处理**：关键词 `seurat, quality control` ｜ 附加材料：正文主导 ｜ 参考脚本：`重建脚本` ｜ 关联图：`见图表清单`
- **步骤 2 · 多样本整合与批次校正**：关键词 `harmony, batch` ｜ 附加材料：1 段补充说明 ｜ 参考脚本：`重建脚本` ｜ 关联图：`Supplementary Figure 1, Supplementary Figure 2, Supplementary Figure 4, Supplementary Figure 5`
- **步骤 3 · 降维（PCA/UMAP）与细胞聚类**：关键词 `pca, umap, findclusters, clustering` ｜ 附加材料：1 段补充说明 ｜ 参考脚本：`重建脚本` ｜ 关联图：`Fig. 2, Fig. 4, Fig. 5, Fig. 6, Supplementary Figure 1, Supplementary Figure 2, Supplementary Figure 4, Supplementary Figure 5`
- **步骤 4 · 差异表达分析**：关键词 `differential, deg, findallmarkers` ｜ 附加材料：正文主导 ｜ 参考脚本：`重建脚本` ｜ 关联图：`见图表清单`
- **步骤 5 · 功能通路富集与活性评分（GO/KEGG/GSEA/PROGENy/scMetabolism）**：关键词 `enrichment, gsea, progeny, scmetabolism, pathway, kegg` ｜ 附加材料：1 段补充说明 ｜ 参考脚本：`Fig2_CAF_program_distribution_progeny.R` ｜ 关联图：`Supplementary Figure 2, Supplementary Figure 4, Supplementary Figure 5`
- **步骤 6 · 共表达网络（WGCNA/hdWGCNA）与互作分析**：关键词 `co-expression` ｜ 附加材料：正文主导 ｜ 参考脚本：`重建脚本` ｜ 关联图：`见图表清单`
- **步骤 7 · 空间转录组反卷积与邻域定位**：关键词 `rctd, visium, deconvolution, spatial` ｜ 附加材料：1 段补充说明 ｜ 参考脚本：`ST_RCTD_CAF_multiSample.R` ｜ 关联图：`Supplementary Figure 3, Supplementary Figure 6`
- **步骤 8 · 细胞通讯分析**：关键词 `ligand-receptor` ｜ 附加材料：2 段补充说明 ｜ 参考脚本：`重建脚本` ｜ 关联图：`Supplementary Figure 5, Supplementary Figure 6`
- **步骤 9 · 拟时序/细胞轨迹分析（Monocle2/3/DiffusionMap）**：关键词 `monocle3, diffusion map, trajectory, pseudotime` ｜ 附加材料：正文主导 ｜ 参考脚本：`CAF_PVL_Endo_pseudotime.R` ｜ 关联图：`见图表清单`
- **步骤 10 · 细胞比例与组织偏好分析（Ro/e）**：关键词 `ro/e, proportion, composition` ｜ 附加材料：1 段补充说明 ｜ 参考脚本：`重建脚本` ｜ 关联图：`Supplementary Figure 2, Supplementary Figure 4, Supplementary Figure 5`
- **步骤 11 · 生存分析与预后建模（KM/Cox/Nomogram）**：关键词 `survival` ｜ 附加材料：1 段补充说明 ｜ 参考脚本：`重建脚本` ｜ 关联图：`见图表清单`

## 代码

- **本地工程工作区**：`<sources_root>/papers/2026-cai-stromal-tme/`（`upstream_repo/` 原始镜像 + `src/` 分步源码）
- **Wiki 固定代码存档**：`methods/breast-cancer-stromal-tme-workflow/source/`（已归档原文脚本 9 个，见 `source-manifest.json`）与 `methods/breast-cancer-stromal-tme-workflow/code/`（已归档复刻脚本 23 个）
- 关联分析家族：[[methods/batch-integration]]、[[methods/differential-expression]]、[[methods/gene-set-scoring]]、[[methods/gene-set-enrichment]]、[[methods/cell-proportion-composition]]、[[methods/survival-prognosis-analysis]]、[[methods/trajectory-inference]]、[[methods/spatial-transcriptomics-microenvironment]]、[[methods/cell-cell-communication]]、[[methods/immune-infiltration-tme]]
- 衍生可视化模板：[[templates/spatial-feature-grid]]、[[templates/roe-cox-heatmap]]、[[templates/pathway-zscore-heatmap]]、[[templates/cellchat-count-heatmap]]、[[templates/lr-bubble-matrix]]、[[templates/lr-bipartite-bubble]]、[[templates/metabolism-lollipop-dotplot]]、[[templates/pseudotime-branch-curves]]、[[templates/kegg-cluster-bubble]]

## 输出

各阶段分析中间表与复刻图表产物。

## 知识关联检查

查重说明：10项通用分析方法均复用规范家族，仅新增本篇专属workflow总览页及9个通过check-dup查重的原生单面板模板。 workflow 页仅记录跨方法串联流程，不声明 `figure_relations` 主记录；已挂载衍生方法：[[methods/batch-integration]]、[[methods/differential-expression]]、[[methods/gene-set-scoring]]、[[methods/gene-set-enrichment]]、[[methods/cell-proportion-composition]]、[[methods/survival-prognosis-analysis]]、[[methods/trajectory-inference]]、[[methods/spatial-transcriptomics-microenvironment]]、[[methods/cell-cell-communication]]、[[methods/immune-infiltration-tme]]；衍生模板：[[templates/spatial-feature-grid]]、[[templates/roe-cox-heatmap]]、[[templates/pathway-zscore-heatmap]]、[[templates/cellchat-count-heatmap]]、[[templates/lr-bubble-matrix]]、[[templates/lr-bipartite-bubble]]、[[templates/metabolism-lollipop-dotplot]]、[[templates/pseudotime-branch-curves]]、[[templates/kegg-cluster-bubble]]。

## 使用记录

<!-- user:start -->
<!-- user:end -->
