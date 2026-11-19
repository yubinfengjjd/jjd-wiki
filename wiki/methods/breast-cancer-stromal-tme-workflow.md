---
type: method
id: breast-cancer-stromal-tme-workflow
title: 乳腺癌基质单细胞与空转微环境复刻流程
status: draft
method_kind: workflow
tags:
- single-cell
- transcriptomics
- survival-analysis
data_domains:
- single-cell
- spatial-omics
- bulk-transcriptomics
- clinical-prognosis
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
- scrna
- spatial-transcriptomics
- breast-cancer
- stromal-tme
- caf
- endothelial
- mural-cell
- paper-replication
- 文献复刻
- TCGA-BRCA
- GSE167036
- GSE139495
- GSE148673
data_contract:
  input: 原始数据/抽样子集（TCGA-BRCA, GSE167036, GSE139495, GSE148673, GSE161529, GSE176078,
    GSE180286, GSE195861, GSE225600, GSE246613, E-MTAB-10607, GSE190811）与文献 Methods/附加材料流程。
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
- 标签：single-cell、transcriptomics、survival-analysis
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

查阅 Cai 等的基质细胞图谱构建、亚群差异表达与通路分析、组织偏好和预后、空间定位、轨迹及细胞通讯流程。小规模回放使用发表补充表、Zenodo 19562239 的单张 Visium 切片（2,241 个 spot、17,922 个基因及 H&E）和小型 scRNA 对象。归档准备脚本依据已发表标记模拟 36 个亚群、1,800 个细胞、289 个基因及四个批次，步骤 1 收据记录了模拟批次。

## 不适用

该回放不支持把模拟单细胞结果或单张切片外推到原研究全队列。Monocle3、CellChat 与 scMetabolism 未在小规模工程中运行。轨迹采用 Diffusion Map 与 Slingshot，通讯读取发表结果，代谢部分使用 KEGG 富集与小型表达对象构建代理。湿实验排除 Fig. 3F（4T1 共培养示意）、Fig. 3G（流式细胞术）和 Fig. 3H（多重免疫荧光）。

## 输入

发表的 MOESM1–8、公开 Visium 对象、原图参考页和上游 R 脚本。各步的输入文件、代理结果与回放边界见 [归档源码说明](breast-cancer-stromal-tme-workflow/code/README.md)。

## 怎么做

MOESM1 含 Supplementary Data 1–7 索引和附图 1–6 图注。MOESM2–8 依次为上述数据表。下表的脚本名称相对于本页同名目录下的 `source/breastcancer-stromal-cell/` 和 `code/`。图号表示步骤涉及的已归档图，并不代表每张图的全部面板均由该步直接生成。

| 正文步骤 | 补充材料 | 作者 R 脚本（`source/`） | 归档步骤脚本（`code/`） | 复刻图 |
| --- | --- | --- | --- | --- |
| 1. 质控和标准化 | MOESM1 图注；MOESM2 登记病例表（队列背景）；MOESM3 标记作为小型对象的生成依据 | `Fig1_stromal_annotation_and_subset.R` | `00_sample_and_extract_moesm.py`、`00_prepare_spatial_and_scrna.R` | 主图 1（输入） |
| 2. 多样本整合与 Harmony 批次校正 | MOESM1 附图说明 | `CAF_scRNA_integration_annotation_pipeline.R`、`Endo_Analysis_FullPipeline_Complete.R`、`PVL_Analysis_Final.R` | `01_scrna_harmony_de.R` | 主图 1、2、4、5；附图 1、2、4、5 |
| 3. PCA、UMAP、聚类及注释 | MOESM1 图注；MOESM4 亚群分层注释 | `Fig1_stromal_annotation_and_subset.R`、`CAF_scRNA_integration_annotation_pipeline.R`、`Endo_Analysis_FullPipeline_Complete.R`、`PVL_Analysis_Final.R` | `01_scrna_harmony_de.R` | 主图 1、2、4–6；附图 1、2、4、5 |
| 4. 差异表达与标记整理 | MOESM3 三类基质细胞 DEG | `CAF_scRNA_integration_annotation_pipeline.R`、`Endo_Analysis_FullPipeline_Complete.R`、`PVL_Analysis_Final.R` | `01_scrna_harmony_de.R`、`02_progeny_roe_cox.R` | 主图 1、2、4、5；附图 1、2、4、5 |
| 5. GO/KEGG 富集、通路评分与代谢展示 | MOESM6 GO/KEGG；MOESM1 附图说明 | `Fig2_CAF_program_distribution_progeny.R`、`Endo_Analysis_FullPipeline_Complete.R`、`PVL_Analysis_Final.R` | `02_progeny_roe_cox.R`、`05_crosstalk_metabolism.R` | 主图 2、4、5；附图 2、4、5 |
| 6. 共表达与细胞丰度相关性 | MOESM7 Bulk 和 ST 的 ABCA8⁺ lpFib 相关性表 | 无单列归档的网络拟合脚本 | `05_crosstalk_metabolism.R`、`figures/fig03_abca8_lpfib_tcell.R` 读取或展示相关性；`code/` 无独立 WGCNA/hdWGCNA 回放 | 主图 3A–C |
| 7. 空间反卷积、签名评分与邻域定位 | MOESM3 标记；MOESM7 的 ST 相关性表；MOESM1 附图说明 | `ST_RCTD_CAF_multiSample.R` | `03_spatial_scores_deconv.R` | 主图 1–3、4、6；附图 3、6 |
| 8. 配体–受体通讯 | MOESM8 CellChat 概率及 CellPhoneDB 显著性和计数 | `Cross-talk.R` | `05_crosstalk_metabolism.R` | 主图 2–6；附图 5、6 |
| 9. 拟时序与轨迹 | MOESM1 图注；轨迹模型依据正文 | `CAF_PVL_Endo_pseudotime.R` | `04_trajectory_pseudotime.R` | 主图 2、4、5 |
| 10. 组织偏好与亚群比例（Ro/e） | MOESM1 附图说明；MOESM4 亚群标识 | `Fig2_CAF_program_distribution_progeny.R`、`Endo_Analysis_FullPipeline_Complete.R`、`PVL_Analysis_Final.R` | `02_progeny_roe_cox.R` | 主图 2、4、5；附图 2、4、5 |
| 11. 生存与预后 | MOESM5 TCGA-BRCA 和院内队列多变量 Cox 汇总 | 无单列归档的 Cox 拟合脚本 | `02_progeny_roe_cox.R` 整理发表 Cox 结果，局部回放未重拟合原队列 | 主图 2、4、5 |

[1:1 视觉对照画廊](../../gallery/2026-11-19-cai-stromal-tme/source.md)记录协调者六维视觉验收 **12/12 PASS**，覆盖主图 1–6（Fig. 3 仅 A–E）与附图 1–6。验收范围为视觉复刻。各图的具体数据、估读及代理边界见归档源码说明。

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
