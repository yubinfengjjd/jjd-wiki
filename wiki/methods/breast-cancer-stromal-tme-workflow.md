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
summary: 文献《Integration of single-cell and spatial transcriptomics reveals stromal
  cell features in breast cancer》（Cai et al., npj Precision Oncology 2026）纯生信方法拆解与复刻组合流程（已剔除湿实验
  Fig. 3F–H，含正文-附加材料映射、面板覆盖清单与双份代码存档）。
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
- 代码模板：[methods/breast-cancer-stromal-tme-workflow/code/00_prepare_spatial_and_scrna.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/00_prepare_spatial_and_scrna.R) · [methods/breast-cancer-stromal-tme-workflow/code/00_sample_and_extract_moesm.py](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/00_sample_and_extract_moesm.py) · [methods/breast-cancer-stromal-tme-workflow/code/00c_style_and_manifold.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/00c_style_and_manifold.R) · [methods/breast-cancer-stromal-tme-workflow/code/01_scrna_harmony_de.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/01_scrna_harmony_de.R) · [methods/breast-cancer-stromal-tme-workflow/code/02_progeny_roe_cox.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/02_progeny_roe_cox.R) · [methods/breast-cancer-stromal-tme-workflow/code/03_spatial_scores_deconv.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/03_spatial_scores_deconv.R) · [methods/breast-cancer-stromal-tme-workflow/code/04_trajectory_pseudotime.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/04_trajectory_pseudotime.R) · [methods/breast-cancer-stromal-tme-workflow/code/05_crosstalk_metabolism.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/05_crosstalk_metabolism.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/fig01_stromal_atlas.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/fig01_stromal_atlas.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/fig02_fib_characterization.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/fig02_fib_characterization.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/fig03_abca8_lpfib_tcell.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/fig03_abca8_lpfib_tcell.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/fig04_ec_characterization.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/fig04_ec_characterization.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/fig05_mural_characterization.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/fig05_mural_characterization.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/fig06_tme_crosstalk.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/fig06_tme_crosstalk.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/sfig01_stromal_batch_markers.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/sfig01_stromal_batch_markers.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/sfig02_fib_supp.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/sfig02_fib_supp.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/sfig03_spatial_markers_deconv.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/sfig03_spatial_markers_deconv.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/sfig04_ec_supp.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/sfig04_ec_supp.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/sfig05_mural_supp_chord.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/sfig05_mural_supp_chord.R) · [methods/breast-cancer-stromal-tme-workflow/code/figures/sfig06_spatial_tls_pgf_lr.R](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/figures/sfig06_spatial_tls_pgf_lr.R) · [methods/breast-cancer-stromal-tme-workflow/code/make_side_by_side.py](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/make_side_by_side.py) · [methods/breast-cancer-stromal-tme-workflow/code/README.md](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/README.md) · [methods/breast-cancer-stromal-tme-workflow/code/runtime.json](/files/wiki/methods/breast-cancer-stromal-tme-workflow/code/runtime.json) · 独立 Panel 脚本：共 71 个（见前端「论文复刻」面板）
- 面板覆盖清单：12 张图 / 74 条面板条目（实测/补表 15、本地重算 39、代理 16、剔除湿实验 3、剔除示意图 1），引用 21 套去重模板

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 用途

复刻文献《Integration of single-cell and spatial transcriptomics reveals stromal cell features in breast cancer》的纯生信分析链路与全量可复刻发表级图表；已明确剔除动物/细胞湿实验部分。

- **所属可组合分支树**：[[scenarios/stromal-tme-scrna-st-playbook|单细胞与空转肿瘤基质微环境思路分支树（Playbook）]] · 挂载自 [[scenarios/scrna-stepwise-playbook|单细胞转录组步进决策树]]
- **课题走线实录卡**：[[projects/2026-cai-stromal-tme|乳腺癌基质微环境单细胞与空转联合解析（Cai et al., 2026）]]

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

## 12 张主附图 × 全部面板 → 绘图模板 100% 覆盖矩阵

下表将全篇 **12 张计算图（Main Fig. 1–6［剔除示意图 1A 与湿实验 3F–H］+ Supp. Fig. 1–6）** 的全部独立面板拆解并映射至 `wiki/templates/<slug>`（面板表直接映射 **21 套**去重模板［含全部 **18 套** Cai 2026 原生/升级模板（均已通过 `verify-template` 并批量确认升级为 `status: ready`）+ 3 套核心复用主库模板］，另关联 3 套同域备选复用模板共 24 套；按 `style_tier: default | variant` 区分主推默认与可切换变体；结构化覆盖与证据分层清单见 `methods/breast-cancer-stromal-tme-workflow/panel-manifest.yaml`）：

| 原文献图号 | 面板范围 | 生物学展示内容 | 所属规范方法（`methods/`） | 对应绘图模板（`templates/`） |
|---|---|---|---|---|
| **Fig. 1** | **1A** | *多队列 scRNA + Visium 空间图谱构建研究流程示意图（示意图已排除，不建通用模板）* | — | *Excluded Schematic* |
| **Fig. 1** | **1B** | 基质三大区室（Fib/EC/Mural）全景 UMAP 与编号质心 | [[methods/cell-type-annotation]] | [[templates/scrna-celltype-umap]] (`default`) |
| **Fig. 1** | **1C** | 9 个主谱系 Marker（`COL1A1/DCN/PECAM1/ACTA2` 等）特征 UMAP 网格 | [[methods/cell-type-annotation]] | [[templates/scrna-feature-umap-grid]] (`default`) |
| **Fig. 1** | **1D** | Fib / EC / Mural 36 个精细亚群分面 + 红虚线功能包络轮廓 UMAP | [[methods/cell-type-annotation]] | [[templates/stromal-hull-umap]] (`variant`) |
| **Fig. 2** | **2A** | Fib 亚群 Normal vs Tumor 拆分 UMAP 对比 | [[methods/cell-type-annotation]] | [[templates/scrna-celltype-umap]] (`default`) |
| **Fig. 2** | **2B** | CAF 4 大功能模块（lpCAF/mCAF/tCAF/ifnCAF）UMAP 激活分布 | [[methods/gene-set-scoring]] | [[templates/scrna-feature-umap-grid]] (`default`) |
| **Fig. 2** | **2C** | Fib 14 亚群 TCGA/院内 Cox HR + 分子亚型 & 组织 `Ro/e` 偏好热图 | [[methods/cell-proportion-composition]] · [[methods/survival-prognosis-analysis]] | [[templates/roe-cox-heatmap]] (`default`) |
| **Fig. 2** | **2D** | Fib 趋化因子 / MHC-I / MHC-II Z-score + 发表 DEG 空心圆热图 | [[methods/differential-expression]] · [[methods/gene-set-scoring]] | [[templates/pathway-zscore-heatmap]] (`default`) |
| **Fig. 2** | **2E** | Fib 14 亚群 PROGENy 14 条经典通路活性 Z-score 热图 | [[methods/gene-set-scoring]] | [[templates/pathway-zscore-heatmap]] (`default`) |
| **Fig. 2** | **2F–I** | Fib DiffusionMap 轨迹、DPT/Slingshot 伪时序与 4 模块叠色 | [[methods/trajectory-inference]] | [[templates/diffusion-trajectory-overlay]] (`default`) |
| **Fig. 2** | **2J** | `CAA_ST` 切片 14 个 Fib 亚群空间签名评分与相对权重分布网格 | [[methods/spatial-transcriptomics-microenvironment]] | [[templates/spatial-feature-grid]] (`default`) |
| **Fig. 2** | **2K** | Fib → Malignant（COL1A1/COL6A–CD44/SDC4）CellChat 配受体气泡矩阵 | [[methods/cell-cell-communication]] | [[templates/lr-bubble-matrix]] (`default`) |
| **Fig. 3** | **3A** | Bulk 微环境 35×35 层次聚类黑框对称相关矩阵 + 侧边引线标签 | [[methods/immune-infiltration-tme]] | [[templates/clustered-corr-boxes]] (`default`) |
| **Fig. 3** | **3B** | `CAA_ST` 四分区 Tumor / `C10_lpFib_ABCA8` / CD8⁺ T / 耗竭 T 空间热斑 | [[methods/spatial-transcriptomics-microenvironment]] | [[templates/spatial-feature-grid]] (`default`) |
| **Fig. 3** | **3C** | `ABCA8` 高/低四分位组 8 个免疫检查点表达 Wilcoxon 箱线图 | [[methods/immune-infiltration-tme]] | [[templates/checkpoint-group-boxplot]] (`default`) |
| **Fig. 3** | **3D** | Fib–T 细胞免疫抑制性配体–受体 CellPhoneDB 双轴连线气泡图 | [[methods/cell-cell-communication]] · [[methods/immune-infiltration-tme]] | [[templates/lr-bipartite-bubble]] (`variant`) |
| **Fig. 3** | **3E** | `C10_lpFib_ABCA8` / T 细胞共高区与 `LGALS3/HAVCR2/CD86/CTLA4` 空间共定位 | [[methods/spatial-transcriptomics-microenvironment]] | [[templates/spatial-coexpr-multichannel]] (`variant`) |
| **Fig. 3** | **3F–H** | *小鼠 4T1 共培养、流式与多重免疫荧光（湿实验已剔除，不建模板）* | — | *Excluded Wet-Lab* |
| **Fig. 4** | **4A–E** | EC 亚群 Normal/Tumor UMAP、Marker 特征、Cox+Ro/e、功能与 PROGENy 热图 | [[methods/cell-type-annotation]] · [[methods/cell-proportion-composition]] · [[methods/gene-set-scoring]] | [[templates/scrna-celltype-umap]] · [[templates/scrna-feature-umap-grid]] · [[templates/roe-cox-heatmap]] · [[templates/pathway-zscore-heatmap]] |
| **Fig. 4** | **4F–H** | EC DiffusionMap、DPT/Slingshot 伪时序与 Stalk/Tip-like 模块叠色 | [[methods/trajectory-inference]] | [[templates/diffusion-trajectory-overlay]] (`default`) |
| **Fig. 4** | **4I** | EC → 基质 12×36 细胞通讯计数矩阵与边际合计柱状热图 | [[methods/cell-cell-communication]] | [[templates/cellchat-count-heatmap]] (`default`) |
| **Fig. 4** | **4J** | `CAA_ST` 6 空间区域 `TipEC/VenEC/emtEC` 签名局部栅格分布 | [[methods/spatial-transcriptomics-microenvironment]] | [[templates/spatial-feature-grid]] (`default`) |
| **Fig. 4** | **4K** | EC 亚群 Top 20 KEGG 代谢通路富集 `-log10(P)` 棒棒糖散点图 | [[methods/gene-set-enrichment]] · [[methods/gene-set-scoring]] | [[templates/metabolism-lollipop-dotplot]] (`default`) |
| **Fig. 5** | **5A–H** | Mural 亚群拆分 UMAP、签名 UMAP、Cox+Ro/e、功能/PROGENy 与分化轨迹 | [[methods/cell-type-annotation]] · [[methods/cell-proportion-composition]] · [[methods/trajectory-inference]] | [[templates/scrna-celltype-umap]] · [[templates/scrna-feature-umap-grid]] · [[templates/roe-cox-heatmap]] · [[templates/pathway-zscore-heatmap]] · [[templates/diffusion-trajectory-overlay]] |
| **Fig. 5** | **5I** | Mural Lineage 2 8 个关键基因沿伪时序平滑表达曲线网格 | [[methods/trajectory-inference]] | [[templates/pseudotime-branch-curves]] (`default`) |
| **Fig. 5** | **5J** | Mural → EC（JAG1-NOTCH / COL4-ITGA9 等）配受体概率气泡矩阵 | [[methods/cell-cell-communication]] | [[templates/lr-bubble-matrix]] (`default`) |
| **Fig. 5** | **5K** | Mural 亚群 KEGG 代谢通路富集棒棒糖图 | [[methods/gene-set-enrichment]] | [[templates/metabolism-lollipop-dotplot]] (`default`) |
| **Fig. 6** | **6A** | 52 群基质+免疫微环境细胞联合投影 UMAP 与三列色卡 | [[methods/cell-type-annotation]] | [[templates/scrna-celltype-umap]] (`default`) |
| **Fig. 6** | **6B** | 16 类免疫/上皮细胞 ↔ 36 基质亚群 CellPhoneDB 通讯计数矩阵与边际柱图 | [[methods/cell-cell-communication]] | [[templates/cellchat-count-heatmap]] (`default`) |
| **Fig. 6** | **6C** | `C8_iFib_CCL19` → 20 类 TME 细胞 TLS 相关配受体概率气泡矩阵 | [[methods/cell-cell-communication]] | [[templates/lr-bubble-matrix]] (`default`) |
| **Fig. 6** | **6D–E** | 全切片及右半区 TLS 8 项签名/基因空间分布网格 | [[methods/spatial-transcriptomics-microenvironment]] | [[templates/spatial-feature-grid]] (`default`) |
| **Fig. 6** | **6F–G** | `C4_TipEC_PGF` → M1/M2 配受体气泡图 + 三信号空间分布网格 | [[methods/cell-cell-communication]] · [[methods/spatial-transcriptomics-microenvironment]] | [[templates/lr-bubble-matrix]] · [[templates/spatial-feature-grid]] |
| **Fig. 6** | **6H** | `CAA_ST` 切片 `CCL14`–`CCR1` 双通道空间共表达叠加图 | [[methods/spatial-transcriptomics-microenvironment]] | [[templates/spatial-coexpr-multichannel]] (`variant`) |
| **Supp. Fig. 1** | **S1A–B** | 基质主群按 GSE 队列着色的批次 UMAP + 9 个主谱系 Marker 气泡点图 | [[methods/batch-integration]] · [[methods/cell-type-annotation]] | [[templates/scrna-celltype-umap]] · [[templates/marker-bubble-dotplot]] (`default`) |
| **Supp. Fig. 2** | **S2A** | Fib 按队列批次 UMAP + ANT/T/LM 组织堆叠比例与样本箱线 Wilcoxon 检验 | [[methods/batch-integration]] · [[methods/cell-proportion-composition]] | [[templates/scrna-celltype-umap]] · [[templates/tissue-ratio-prop-combo]] (`variant`) |
| **Supp. Fig. 2** | **S2B–C** | Fib 36 个标志基因 DotPlot + `Angiogenic_signature` UMAP | [[methods/cell-type-annotation]] · [[methods/gene-set-scoring]] | [[templates/marker-bubble-dotplot]] · [[templates/scrna-feature-umap-grid]] |
| **Supp. Fig. 2** | **S2D–E** | Fib 42 条 KEGG 通路气泡矩阵 + 16 条代谢通路棒棒糖图 | [[methods/gene-set-enrichment]] | [[templates/kegg-cluster-bubble]] (`default`) · [[templates/metabolism-lollipop-dotplot]] (`default`) |
| **Supp. Fig. 3** | **S3A** | `CAA_ST` 8 区域 `COL1A1/COL1A2/DCN` 空间表达网格 | [[methods/spatial-transcriptomics-microenvironment]] | [[templates/spatial-feature-grid]] (`default`) |
| **Supp. Fig. 3** | **S3B** | 四象限低分辨率 H&E 组织图与 `C10_lpFib_ABCA8` / `CD8_Cytotoxic_T` 空间反卷积对照 | [[methods/spatial-transcriptomics-microenvironment]] | [[templates/spatial-he-deconv-panel]] (`variant`) |
| **Supp. Fig. 4** | **S4A–C** | EC 批次 UMAP + 组织构成比例箱线组合图 + 32 基因 DotPlot + Tip-cell 特征图 | [[methods/cell-proportion-composition]] · [[methods/cell-type-annotation]] | [[templates/tissue-ratio-prop-combo]] · [[templates/marker-bubble-dotplot]] · [[templates/scrna-feature-umap-grid]] |
| **Supp. Fig. 4** | **S4D** | EC 12 亚群分面 Top 5 KEGG 水平条形图（含基因数标签） | [[methods/gene-set-enrichment]] | [[templates/cluster-kegg-bars]] (`variant`) |
| **Supp. Fig. 5** | **S5A–C** | Mural 批次 UMAP + 组织构成箱线组合图 + 32 基因 DotPlot + Top 7 KEGG 条形图 | [[methods/cell-proportion-composition]] · [[methods/gene-set-enrichment]] | [[templates/tissue-ratio-prop-combo]] · [[templates/marker-bubble-dotplot]] · [[templates/cluster-kegg-bars]] (`variant`) |
| **Supp. Fig. 5** | **S5D** | 52 节点基质 + TME VEGF 通路定向细胞通讯环形弦图 | [[methods/cell-cell-communication]] | [[templates/cellchat-signaling-ring]] (`variant`) |
| **Supp. Fig. 6** | **S6A** | `CAA_ST` 3 区域 9 种基质/免疫细胞空间密度网格 | [[methods/spatial-transcriptomics-microenvironment]] | [[templates/spatial-feature-grid]] (`default`) |
| **Supp. Fig. 6** | **S6B–C** | `CAA_ST` 8 区域 `CCL19/CCR7` 2 通道与 `CD8A/CD79A/CD19/CD3E` 4 通道 TLS 共定位 | [[methods/spatial-transcriptomics-microenvironment]] | [[templates/spatial-coexpr-multichannel]] (`variant`) |
| **Supp. Fig. 6** | **S6D** | `C4_TipEC_PGF` → 21 类 TME 细胞 14 对配受体 CellChat 概率气泡矩阵 | [[methods/cell-cell-communication]] | [[templates/lr-bubble-matrix]] (`default`) |

## 代码

- **本地工程工作区**：`<sources_root>/papers/2026-cai-stromal-tme/`（`upstream_repo/` 原始镜像 + `src/` 分步源码）
- **许可与再分发边界说明**：原论文 *npj Precision Oncology* (2026, `10.1038/s41698-026-01718-1`) 以 CC BY-NC-ND 4.0 发表，上游 GitHub 仓库（`qingyaolab/breastcancer-Stromal-Cell`）未附带显式开源 LICENSE 文件；`source/` 原脚本快照与 `gallery/` 并排对照图仅作个人科研知识库内部学习、复现核验与出处溯源使用，不主张商业或公开再分发授权。
- **Wiki 固定代码存档**：`methods/breast-cancer-stromal-tme-workflow/source/`（已归档原文脚本 8 个 + README/manifest，见 `source-manifest.json`）与 `methods/breast-cancer-stromal-tme-workflow/code/`（已归档复刻脚本 23 个）
- **关联分支树与课题实录**：[[scenarios/stromal-tme-scrna-st-playbook]]、[[scenarios/scrna-stepwise-playbook]]、[[projects/2026-cai-stromal-tme]]
- 关联分析家族：[[methods/batch-integration]]、[[methods/cell-type-annotation]]、[[methods/differential-expression]]、[[methods/gene-set-scoring]]、[[methods/gene-set-enrichment]]、[[methods/cell-proportion-composition]]、[[methods/survival-prognosis-analysis]]、[[methods/trajectory-inference]]、[[methods/spatial-transcriptomics-microenvironment]]、[[methods/cell-cell-communication]]、[[methods/immune-infiltration-tme]]
- 全部衍生绘图模板（18 套 Cai 2026 原生模板）：[[templates/stromal-hull-umap]]、[[templates/spatial-feature-grid]]、[[templates/spatial-he-deconv-panel]]、[[templates/spatial-coexpr-multichannel]]、[[templates/roe-cox-heatmap]]、[[templates/tissue-ratio-prop-combo]]、[[templates/pathway-zscore-heatmap]]、[[templates/kegg-cluster-bubble]]、[[templates/cluster-kegg-bars]]、[[templates/metabolism-lollipop-dotplot]]、[[templates/diffusion-trajectory-overlay]]、[[templates/pseudotime-branch-curves]]、[[templates/clustered-corr-boxes]]、[[templates/checkpoint-group-boxplot]]、[[templates/cellchat-count-heatmap]]、[[templates/lr-bubble-matrix]]、[[templates/lr-bipartite-bubble]]、[[templates/cellchat-signaling-ring]]（复用既有库模板：[[templates/scrna-celltype-umap]]、[[templates/scrna-feature-umap-grid]]、[[templates/marker-bubble-dotplot]]、[[templates/cell-prop-flow-bar]]、[[templates/coexpr-module-enrich-bars]]、[[templates/cellchat-circos-multi]]）

## 输出

各阶段分析中间表与复刻图表产物。

## 知识关联检查

查重说明：11 项通用分析方法均复用规范家族，仅新增本篇专属 workflow 总览页及 18 套通过查重与风格分层（`default` / `variant`）的绘图模板；已挂载专题决策树 [[scenarios/stromal-tme-scrna-st-playbook]]、主干树 [[scenarios/scrna-stepwise-playbook]] 及课题走线实录卡 [[projects/2026-cai-stromal-tme]]。workflow 页仅记录跨方法串联流程，不声明 `figure_relations` 主记录；全部 18 套衍生模板与 11 个规范分析家族已完成语义关系入库。

## 使用记录

<!-- user:start -->
<!-- user:end -->
