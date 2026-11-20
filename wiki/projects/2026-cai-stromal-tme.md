---
type: project
slug: 2026-cai-stromal-tme
title: 乳腺癌基质微环境单细胞与空转联合解析（Cai et al., 2026）
playbook: stromal-tme-scrna-st-playbook
status: active
templates:
- scrna-celltype-umap
- stromal-hull-umap
- scrna-feature-umap-grid
- marker-bubble-dotplot
- roe-cox-heatmap
- tissue-ratio-prop-combo
- cell-prop-flow-bar
- pathway-zscore-heatmap
- kegg-cluster-bubble
- cluster-kegg-bars
- coexpr-module-enrich-bars
- metabolism-lollipop-dotplot
- diffusion-trajectory-overlay
- pseudotime-branch-curves
- spatial-feature-grid
- spatial-he-deconv-panel
- spatial-coexpr-multichannel
- clustered-corr-boxes
- checkpoint-group-boxplot
- lr-bubble-matrix
- cellchat-count-heatmap
- lr-bipartite-bubble
- cellchat-signaling-ring
- cellchat-circos-multi
methods:
- batch-integration
- cell-type-annotation
- cell-proportion-composition
- survival-prognosis-analysis
- differential-expression
- gene-set-scoring
- gene-set-enrichment
- trajectory-inference
- spatial-transcriptomics-microenvironment
- cell-cell-communication
- immune-infiltration-tme
summary: Cai et al. (npj Precision Oncology, 2026) 乳腺癌基质单细胞 + Visium 空转 + Bulk 队列 6 阶段走线实录：从多队列基质图谱注释、Ro/e 与 Cox 预后筛选到 ABCA8+ lpFib 免疫排斥与 CCL19+ iFib / PGF+ TipEC 空间通讯验证（已剔除 Fig. 3F–H 湿实验）。
---
# 乳腺癌基质微环境单细胞与空转联合解析（Cai et al., 2026）

- **所属决策树**：[[scenarios/stromal-tme-scrna-st-playbook|单细胞与空转肿瘤基质微环境思路分支树]] · 挂载自 [[scenarios/scrna-stepwise-playbook|单细胞转录组步进决策树]]（Branch 7）
- **复刻流程与源码档案**：[[methods/breast-cancer-stromal-tme-workflow|乳腺癌基质单细胞与空转微环境复刻流程]]（作者原版 `source/` 8 份 R 脚本 + 便携 `code/` 23 份分步/成图脚本；本地工作区 `<sources_root>/papers/2026-cai-stromal-tme/`）
- **1:1 视觉对照画廊**：[12 张主附图 1:1 视觉对比画廊（12/12 PASS）](../../gallery/2026-11-19-cai-stromal-tme/source.md)（Main Fig. 1–6［剔除湿实验 Fig. 3F–H］+ Supp. Fig. 1–6；注：视觉复刻验收不等同于原队列全量数据重分析验证）
- **湿实验排除与许可边界**：`Fig. 3F`（小鼠 4T1 CAF–T 细胞共培养模型）、`Fig. 3G`（流式细胞术定量）、`Fig. 3H`（人乳腺癌多重免疫荧光 mIF）明确排除于纯生信复刻范围之外。原论文许可为 CC BY-NC-ND 4.0，上游代码库未提供显式 LICENSE 文件，归档源码与对照图仅供个人科研内部复核与学习，不做对外再分发。
- **证据分层口径**：下文各阶段均显式区分「原文主张 / 发表补表（MOESM1–8）实测 / 本地小规模降维与代理边界 / 湿实验排除」，绝不把局部视觉或代理回放等同于全队列原始计算复算。

## 6 阶段步进走线实录

### Stage 1（Main Fig. 1 & Supp. Fig. 1）：多中心乳腺癌基质图谱构建与精细亚群注释

- **【科学问题与假设】**：多队列整合后能否把肿瘤微环境基质区室（Fibroblast、Endothelial cell、Mural cell）稳定解析为具有明确功能边界的 36 个精细亚群，且不受测序批次主导？
- **【所用分析方法与可切换模板】**：[[methods/batch-integration]] + [[methods/cell-type-annotation]] + [[templates/scrna-celltype-umap]] / [[templates/stromal-hull-umap]]（包络边界变体） + [[templates/scrna-feature-umap-grid]] + [[templates/marker-bubble-dotplot]]
- **【原文结论与本地小规模边界】**：原文基于多中心 Harmony 整合与经典谱系标志物（`COL1A1/DCN`、`PECAM1/VWF`、`ACTA2/PDGFRB/MCAM`）划分出 14 个 Fib、12 个 EC 与 10 个 Mural 亚群；**本地降维边界**：受单机内存约束，本地子集为 1,800 细胞 × 289 基因且仅含 4 个模拟批次，成图时在图例保留原队列完整色卡并采用连续密度底图保证视觉保真度。
- **【触发下一步分叉】**：完成 `scrna-annotated-cells` 注释后，分两条线推进：① 按组织来源（Normal / Tumor / Lymphnode）与分子分型检验亚群偏好及生存预后（Stage 3）；② 汇合 Visium 切片进行空间生态位映射（Stage 2）。

### Stage 2（Main Fig. 2J, 3B, 4J, 6D/E/G & Supp. Fig. 3）：单细胞参考 × Visium 空转切片空间映射与 H&E 对齐

- **【科学问题与假设】**：单细胞鉴定的基质亚群在原位肿瘤组织切片中是否占据特定病理生态位，并与肿瘤细胞或淋巴细胞形成空间共定位/排斥？
- **【所用分析方法与可切换模板】**：[[methods/spatial-transcriptomics-microenvironment]]（双上游汇合 `requires: [scrna-annotated-cells, visium-spatial-object]`） + [[templates/spatial-feature-grid]]（默认多区域空间网格） + [[templates/spatial-he-deconv-panel]]（H&E 配准对照） + [[templates/spatial-coexpr-multichannel]]（多通道空间共表达）
- **【原文结论与本地代理边界】**：原文对多张 Visium 切片执行 RCTD 空间反卷积；**本地代理边界**（见 `code/03_spatial_scores_deconv.R`）：本机环境未安装 `spacexr/RCTD` 且仅取 Zenodo 单张真实切片 `CAA_ST`（2,241 spots + 低清 H&E），故采用**非负 5th-percentile 偏移 L1 归一化 16 细胞签名加权**作为 RCTD 近似代理，绝不宣称等价于全模式 RCTD 反卷积；另原始切片缺测 `LGALS9`，在 Fig. 3E 明确以同家族 `LGALS3` 替代并在面板标题写明代理边界。
- **【触发下一步分叉】**：空转区域划定为“ABCA8⁺ lpFib 高/低分区”与“TLS/血管富集区”，分别驱动 Stage 5 免疫排斥相关性分析与 Stage 6 空间配受体通讯分析。

### Stage 3（Main Fig. 2A–C, 4A–C, 5A–C & Supp. Fig. 2A, 4A, 5A）：Ro/e 组织偏好与跨队列 Cox 预后分层

- **【科学问题与假设】**：36 个基质亚群中，哪些亚群在乳腺癌肿瘤组织（及特定分子亚型）中显著富集，且与 TCGA-BRCA 及院内队列临床预后相关？
- **【所用分析方法与可切换模板】**：[[methods/cell-proportion-composition]] + [[methods/survival-prognosis-analysis]] + [[templates/roe-cox-heatmap]]（默认 Ro/e + Cox 组合热图） + [[templates/tissue-ratio-prop-combo]]（组织堆叠 + 样本箱线检验） + [[templates/cell-prop-flow-bar]]
- **【原文结论与本地回放边界】**：依据原文及发表补表 MOESM5，识别出 `C10_lpFib_ABCA8`、`C8_iFib_CCL19` 等具有显著组织偏好与生存风险关联的关键亚群；**本地边界**：Cox HR 直接整理自发表补表 MOESM5（本地未重拟合原 TCGA/院内临床队列）；在本地小规模抽样对象中，由于缺少真实患者样本 ID，暂以 `batch × tissue` 伪样本近似执行 Wilcoxon + BH 检验（仅限本地小规模视觉复现，真实课题须严格按独立患者样本 ID 分组检验）。
- **【触发下一步分叉】**：锁定高风险/高保护基质亚群后，转入 Stage 4A（功能基因程序与代谢）与 Stage 4B（分化轨迹）。

### Stage 4（Main Fig. 2D–I, 4D–H/K, 5D–I/K & Supp. Fig. 2B–E, 4B–D, 5B–C）：功能程序、PROGENy、代谢重编程与 DiffusionMap/Slingshot 轨迹

- **【科学问题与假设】**：不同亚群的功能分化是否伴随特定趋化因子/MHC、PROGENy 通路及代谢重编程变化，并沿连续拟时序轨迹发生状态切换？
- **【所用分析方法与可切换模板】**：[[methods/differential-expression]] + [[methods/gene-set-scoring]] + [[methods/gene-set-enrichment]] + [[methods/trajectory-inference]] + [[templates/pathway-zscore-heatmap]] + [[templates/kegg-cluster-bubble]] / [[templates/cluster-kegg-bars]] + [[templates/metabolism-lollipop-dotplot]] + [[templates/diffusion-trajectory-overlay]] + [[templates/pseudotime-branch-curves]]
- **【原文结论与本地回放边界】**：通过趋化因子/MHC/血管生成基因 Z-score（叠加发表补表 DEG 标记）、PROGENy 14 通路及 KEGG 代谢棒棒糖图刻画 Fib/EC/Mural 功能谱；使用 Diffusion Map（DPT）与 Slingshot 展示连续流形转换；**本地边界**：小规模基因集缺测 `COL6A3` 时在曲线格显式留空标注，不伪造平滑曲线。
- **【触发下一步分叉】**：发现 `C10_lpFib_ABCA8` 高表达特定免疫调控程序且空间富集于肿瘤边界，触发 Stage 5 对 T 细胞空间排斥相关性与检查点表达的生信核验。

### Stage 5（Main Fig. 3A–E，剔除 3F–H）：`C10_lpFib_ABCA8` 与 T 细胞空间排斥及免疫检查点关联分析（纯生信部分）

- **【科学问题与假设】**：`C10_lpFib_ABCA8` 在 Bulk 免疫生态与空间组织中是否与杀伤性 T 细胞呈负相关排斥趋势，并伴随免疫检查点上调及抑制性配受体互作预测？
- **【所用分析方法与可切换模板】**：[[methods/immune-infiltration-tme]] + [[methods/cell-cell-communication]] + [[templates/clustered-corr-boxes]]（35×35 聚类黑框相关矩阵） + [[templates/checkpoint-group-boxplot]]（ABCA8 高/低四分位检查点箱线图） + [[templates/lr-bipartite-bubble]]（Fib–T 细胞双轴配受体图） + [[templates/spatial-coexpr-multichannel]]
- **【发表补表实测与湿实验排除边界】**：基于发表补表 MOESM7/MOESM8 与 `CAA_ST` 四分区签名评分，复现了 `C10_lpFib_ABCA8` 高富集区与特征检查点分子差异表达及预测抑制性配受体轴（如 `PVR-TIGIT`、`CD274-PDCD1`、`LGALS9-HAVCR2`）的统计学关联与空间共定位；**因果边界**：本阶段计算结果仅支持相关性、共定位与配受体预测，原文用于支持因果机制的湿实验（Fig. 3F–H：4T1 共培养、流式、mIF）已严格剔除并在图注位置标注边界。
- **【触发下一步分叉】**：在免疫排斥关联之外，进一步全局扫描微环境中与三级淋巴结构（TLS）及巨噬细胞极化（M1/M2）空间共定位的核心基质–免疫通讯枢纽（Stage 6）。

### Stage 6（Main Fig. 2K, 4I, 5J, 6A–H & Supp. Fig. 5D, 6A–D）：`C8_iFib_CCL19`–TLS 与 `C4_TipEC_PGF`–TAM 空间配受体通讯预测与共定位

- **【科学问题与假设】**：非免疫基质亚群分别通过哪些预测配受体网络与三级淋巴结构（TLS）或巨噬细胞（M1/M2）呈现空间共定位？
- **【所用分析方法与可切换模板】**：[[methods/cell-cell-communication]] + [[methods/spatial-transcriptomics-microenvironment]] + [[templates/lr-bubble-matrix]] + [[templates/cellchat-count-heatmap]] + [[templates/cellchat-signaling-ring]] + [[templates/spatial-coexpr-multichannel]]
- **【发表补表实测与本地回放边界】**：依据发表补表 MOESM8 与单张 `CAA_ST` 切片空间共表达复现：① `C8_iFib_CCL19` 通过 `CCL19-CCR7`、`CXCL9/10/11-CXCR3` 预测轴与 CD8⁺ T、Tfh、GC B、Memory B 细胞存在高互作概率，并在切片右侧 TLS 区域呈现空间共定位；② `C4_TipEC_PGF` 通过 `CCL14-CCR1`、`MIF-CD74-CXCR4/CD44`、`VEGF` 预测信号（SFig. 5D 52 节点环形图）与 M1/M2 巨噬细胞互作并在双通道空间切片共表达；SFig. 6D 按原始子表补齐 MOESM8 全量 CellChat 概率并留空未检出格子。
- **【课题收口状态说明】**：全部 18 套新建/升级绘图模板与 11 个规范分析方法的 `figure_relations` 均已入库并关联至本走线卡；全部 **18 套 Cai 2026 模板均已通过本地示例 `verify-template` 回放并经作者批量确认升级为 `status: ready`**，结构化覆盖与证据分层清单已同步落盘至 `methods/breast-cancer-stromal-tme-workflow/panel-manifest.yaml`。
