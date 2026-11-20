---
type: scenario
id: spatial-proteomics-immunoediting-playbook
title: 多通道空间蛋白组 × mROI 空间转录组肿瘤免疫编辑分支树（Playbook）
picks:
- id: methods/cell-type-annotation
  note: Stage 1：CyCIF/CODEX 轮间 DNA 质控、GMM 重标度与层级门控表型注释
- id: templates/tri-panel-stage-umap
  note: 主推变体 · 细胞类型/进展分期/患者三联 UMAP 图谱（Cancer Discovery 风格）
- id: templates/scrna-feature-umap-grid
  note: 配套检查 · 多蛋白/标志物特征强度 UMAP 网格
- id: methods/spatial-transcriptomics-microenvironment
  note: Stage 2（双上游汇合）：20 μm 局部邻域 Spatial LDA（RCN）与 Voronoi 拓扑分析
- id: templates/rcn-composition-stacked-heatmap
  note: 主推默认 · 邻域聚簇 Z-score + 患者/分期堆叠注释复合热图
- id: templates/voronoi-neighborhood-mosaic
  note: 可切换画风 · 高密 Voronoi 细胞邻域镶嵌与矩形/圆形放大框图
- id: methods/cell-proportion-composition
  note: Stage 2–3：跨进展分期邻域比例与免疫–肿瘤物理距离分布偏移
- id: templates/half-violin-decile-shift
  note: 主推默认 · 镜像半小提琴 + 分位数偏移哑铃图
- id: templates/cell-prop-flow-bar
  note: 配套 · 跨分期/腔室细胞构成堆叠流带图
- id: methods/immune-infiltration-tme
  note: Stage 3：1,000 次置换细胞共现检验、边界梯度与免疫检查点热图
- id: templates/pathway-zscore-heatmap
  note: 主推默认 · 检查点/通路 Z-score + 显著性矩阵热图
- id: methods/differential-expression
  note: Stage 5A：PickSeq/GeoMx 微区转录组差异表达、ssGSEA 与 GSEA 通路富集
- id: templates/bulk-de-volcano
  note: 主推默认 · 微区转录组差异表达火山图
- id: methods/coexpression-ppi-network
  note: Stage 5B：相关性共表达网络枢纽模块提取与有序样本趋势
- id: templates/coexpr-hub-radial-network
  note: 主推默认 · 中心枢纽基因共表达放射网络图
- id: methods/survival-prognosis-analysis
  note: Stage 5C：TCGA 临床队列多基因 Kaplan-Meier 生存网格验证
- id: templates/km-survival-risk-grid
  note: 主推默认 · 多基因 TCGA KM 生存风险网格图（含 95% CI 与 HR/Logrank）
tags:
- single-cell
- transcriptomics
- survival-analysis
keywords:
- CyCIF
- CODEX
- IMC
- RCN
- Spatial-LDA
- Voronoi
- spatial-lag
- TCC
- PickSeq
- GeoMx
- immunoediting
- melanoma
summary: 面向「多通道单细胞空间蛋白组（CyCIF / CODEX / IMC）+ 定向微区空间转录组（PickSeq / GeoMx mROI）+ TCGA
  临床队列」的肿瘤免疫编辑与空间进展分析分支树（6 阶段 DAG 子树），支持空间邻域主题建模、肿瘤边界梯度、空间滞后与多基因共表达/预后验证。
steps:
- id: cycif-qc-phenotyping
  step: 1
  title: Stage 1 · 多轮荧光质控、GMM 重标度与层级表型注释
  method_id: cell-type-annotation
  when: 拿到 CyCIF/CODEX/IMC 单细胞量化表，需剔除跨轮脱片细胞（DNA r < 0.8）、统一 0–1 门控尺度并按层级规则树命名肿瘤/免疫/基质细胞时
  inputs: []
  outputs:
  - scrna-annotated-cells
  interface: scrna-annotated-cells
  templates:
  - methods/cell-type-annotation
  - methods/dimensionality-reduction
  - templates/tri-panel-stage-umap
  - templates/scrna-celltype-umap
  - templates/scrna-feature-umap-grid
  - templates/checkpoint-group-boxplot
  next_steps:
  - spatial-rcn-voronoi
  - spatial-interaction-boundary
- id: spatial-rcn-voronoi
  step: 2
  title: Stage 2 · 20 μm 空间邻域 LDA 主题建模（RCN）与 Voronoi 拓扑
  method_id: spatial-transcriptomics-microenvironment
  when: 在物理坐标（X_um, Y_um）上统计细胞邻域频率，经 Spatial LDA + K-means 识别跨患者保守的循环细胞邻域（RCN）并分析距肿瘤距离迁移时
  requires:
  - scrna-annotated-cells
  inputs:
  - scrna-annotated-cells
  outputs:
  - cell-proportion-stats
  interface: cell-proportion-stats
  templates:
  - methods/spatial-transcriptomics-microenvironment
  - methods/cell-clustering
  - methods/cell-proportion-composition
  - templates/rcn-composition-stacked-heatmap
  - templates/voronoi-neighborhood-mosaic
  - templates/half-violin-decile-shift
  - templates/cell-prop-flow-bar
  - templates/resampling-metric-box
  next_steps:
  - spatial-interaction-boundary
  - spatial-lag-tcc
- id: spatial-interaction-boundary
  step: 3
  title: Stage 3 · 置换空间共现检验与肿瘤–基质边界免疫抑制梯度
  method_id: immune-infiltration-tme
  when: 检验 PDL1+ 髓系–PD1+ CTL 等特定配对是否在 10–20 μm 尺度显著共现（1,000 次置换）并量化跨肿瘤边界信号梯度时
  requires:
  - scrna-annotated-cells
  inputs:
  - scrna-annotated-cells
  outputs:
  - pathway-score-table
  interface: pathway-score-table
  templates:
  - methods/immune-infiltration-tme
  - methods/spatial-transcriptomics-microenvironment
  - templates/scp-comp-trend
  - templates/scp-count-bar
  - templates/cell-prop-flow-bar
  next_steps:
  - spatial-lag-tcc
  - mroi-deg-gsea
- id: spatial-lag-tcc
  step: 4
  title: Stage 4 · 20 μm 空间滞后肿瘤细胞群落（TCC）与瘤内状态异质性
  method_id: spatial-transcriptomics-microenvironment
  when: 聚焦肿瘤细胞自身及其 20 μm 空间滞后加权蛋白表型，聚簇划分局部均一肿瘤细胞群落（TCC）并评估其与免疫细胞的共现/排斥时
  requires:
  - scrna-annotated-cells
  inputs:
  - scrna-annotated-cells
  outputs:
  - cell-proportion-stats
  interface: cell-proportion-stats
  templates:
  - methods/spatial-transcriptomics-microenvironment
  - templates/rcn-composition-stacked-heatmap
  - templates/voronoi-neighborhood-mosaic
  - templates/spatial-feature-grid
  - templates/pred-density-scatter
  - templates/scp-comp-pie
  next_steps:
  - mroi-deg-gsea
- id: mroi-deg-gsea
  step: 5
  title: Stage 5A · PickSeq / GeoMx 微区全转录组差异表达、ssGSEA 与 GSEA
  method_id: differential-expression
  when: 结合组织病理分区采集的 mROI 全转录组矩阵，比较原位癌（MIS）、侵袭缘（IM）、外生区（EM）与免疫交界（IB/bTIL）的通路程序时
  requires:
  - mroi-mrseq-counts
  inputs:
  - deg-result-table
  outputs:
  - deg-result-table
  - pathway-score-table
  interface: deg-result-table
  templates:
  - methods/differential-expression
  - methods/gene-set-scoring
  - methods/gene-set-enrichment
  - templates/fy-pca
  - templates/bulk-de-volcano
  - templates/pathway-zscore-heatmap
  - templates/fy-fancybar
  - templates/scp-expr-ridge
  next_steps:
  - coexpr-hub-survival
- id: coexpr-hub-survival
  step: 6
  title: Stage 5B–C · 枢纽基因共表达网络提取与 TCGA 多基因 KM 生存验证
  method_id: coexpression-ppi-network
  when: 从 mROI 标准化矩阵提取高相关共表达模块（如 r >= 0.6）锁定枢纽基因，并在外部 TCGA 临床队列批量检验多基因 KM 生存与 Cox
    风险时
  requires:
  - mroi-mrseq-counts
  - bulk-clinical-survival
  inputs:
  - candidate-biomarker-list
  - survival-time-event-group
  outputs:
  - candidate-biomarker-list
  - subgroup-effect-table
  interface: candidate-biomarker-list
  templates:
  - methods/coexpression-ppi-network
  - methods/survival-prognosis-analysis
  - templates/coexpr-hub-radial-network
  - templates/km-survival-risk-grid
  - templates/scp-comp-trend
  next_steps: []
---

# 多通道空间蛋白组 × mROI 空间转录组肿瘤免疫编辑分支树（Playbook）

## 什么时候用

- 当研究以 **高通量单细胞空间蛋白组（CyCIF / CODEX / IMC，20–60 plex，百万级单细胞物理坐标）** 为主骨架，同时耦合 **定向微区空间转录组（PickSeq / GeoMx CTA mROIs）** 与 **TCGA 临床生存队列**，旨在解析肿瘤自癌前/原位向侵袭演化过程中的空间生态重构与免疫编辑机制时启用本 Playbook。
- 与面向 Visium 全片反卷积的 [[scenarios/stromal-tme-scrna-st-playbook|单细胞与空转肿瘤基质微环境思路分支树]] 互补：Visium 擅长“55 μm Spot 级转录组去卷积 + H&E 配准”，本 Playbook 擅长“单细胞物理坐标下的 20 μm Spatial LDA 邻域（RCN）、Voronoi 镶嵌拓扑、空间滞后肿瘤群落（TCC）及定向 mROI 全转录组印证”。

## 首选组合

<!-- facts:start -->
| 条目 | 级别 | 状态 | 说明 |
|---|---|---|---|
| [[methods/cell-type-annotation|细胞类型注释]] | L2 | ready · 可用 | Stage 1：CyCIF/CODEX 轮间 DNA 质控、GMM 重标度与层级门控表型注释 |
| [[templates/tri-panel-stage-umap|三联分群分期患者 UMAP]] | L2 | ready · 可用 | 主推变体 · 细胞类型/进展分期/患者三联 UMAP 图谱（Cancer Discovery 风格） |
| [[templates/scrna-feature-umap-grid|marker 特征 UMAP 小多图]] | L2 | ready · 可用 | 配套检查 · 多蛋白/标志物特征强度 UMAP 网格 |
| [[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]] | note | ready | Stage 2（双上游汇合）：20 μm 局部邻域 Spatial LDA（RCN）与 Voronoi 拓扑分析 |
| [[templates/rcn-composition-stacked-heatmap|RCN 聚簇与分期堆叠复合热图]] | L2 | ready · 可用 | 主推默认 · 邻域聚簇 Z-score + 患者/分期堆叠注释复合热图 |
| [[templates/voronoi-neighborhood-mosaic|Voronoi 细胞空间邻域镶嵌图]] | L2 | ready · 可用 | 可切换画风 · 高密 Voronoi 细胞邻域镶嵌与矩形/圆形放大框图 |
| [[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]] | note | ready | Stage 2–3：跨进展分期邻域比例与免疫–肿瘤物理距离分布偏移 |
| [[templates/half-violin-decile-shift|半小提琴与分位数偏移哑铃图]] | L2 | ready · 可用 | 主推默认 · 镜像半小提琴 + 分位数偏移哑铃图 |
| [[templates/cell-prop-flow-bar|细胞比例堆叠流带图]] | L2 | ready · 可用 | 配套 · 跨分期/腔室细胞构成堆叠流带图 |
| [[methods/immune-infiltration-tme|肿瘤微环境与免疫浸润评估]] | note | ready | Stage 3：1,000 次置换细胞共现检验、边界梯度与免疫检查点热图 |
| [[templates/pathway-zscore-heatmap|功能基因与通路Zscore热图]] | L2 | ready · 可用 | 主推默认 · 检查点/通路 Z-score + 显著性矩阵热图 |
| [[methods/differential-expression|差异表达分析]] | L2 | ready · 可用 | Stage 5A：PickSeq/GeoMx 微区转录组差异表达、ssGSEA 与 GSEA 通路富集 |
| [[templates/bulk-de-volcano|bulk 差异火山图（分级着色）]] | L2 | ready | 主推默认 · 微区转录组差异表达火山图 |
| [[methods/coexpression-ppi-network|共表达网络（WGCNA）与分子互作网络分析]] | note | ready | Stage 5B：相关性共表达网络枢纽模块提取与有序样本趋势 |
| [[templates/coexpr-hub-radial-network|枢纽基因共表达放射网络图]] | L2 | ready · 可用 | 主推默认 · 中心枢纽基因共表达放射网络图 |
| [[methods/survival-prognosis-analysis|生存分析与临床预后建模]] | note | ready | Stage 5C：TCGA 临床队列多基因 Kaplan-Meier 生存网格验证 |
| [[templates/km-survival-risk-grid|多基因 TCGA 生存风险网格图]] | L2 | ready · 可用 | 主推默认 · 多基因 TCGA KM 生存风险网格图（含 95% CI 与 HR/Logrank） |
<!-- facts:end -->

## 步进决策树（空间蛋白组 × 微区转录组免疫编辑）

| 阶段 | 核心科学问题 | 汇合前提（`requires`） | 分析方法 | 推荐与可切换模板 |
|---|---|---|---|---|
| **Stage 1** | 如何从多轮荧光强度中稳健注释细胞并观察早期演进？ | — | [[methods/cell-type-annotation]] · [[methods/dimensionality-reduction]] | [[templates/tri-panel-stage-umap]] · [[templates/scrna-feature-umap-grid]] · [[templates/checkpoint-group-boxplot]] |
| **Stage 2** | 细胞在 20 μm 物理邻域如何组装成 RCN 并随分期迁移？ | `scrna-annotated-cells` | [[methods/spatial-transcriptomics-microenvironment]] · [[methods/cell-clustering]] · [[methods/cell-proportion-composition]] | [[templates/rcn-composition-stacked-heatmap]] · [[templates/voronoi-neighborhood-mosaic]] · [[templates/half-violin-decile-shift]] · [[templates/cell-prop-flow-bar]] |
| **Stage 3** | 特定免疫–肿瘤或髓系–T 细胞对是否在边界形成抑制性共现？ | `scrna-annotated-cells` | [[methods/immune-infiltration-tme]] · [[methods/spatial-transcriptomics-microenvironment]] | [[templates/scp-comp-trend]] · [[templates/scp-count-bar]] · [[templates/pathway-zscore-heatmap]] |
| **Stage 4** | 肿瘤细胞内部的空间滞后表达程序（TCC）如何分群？ | `scrna-annotated-cells` | [[methods/spatial-transcriptomics-microenvironment]] | [[templates/rcn-composition-stacked-heatmap]] · [[templates/voronoi-neighborhood-mosaic]] · [[templates/spatial-feature-grid]] · [[templates/pred-density-scatter]] |
| **Stage 5A** | 微区病理区域（MIS/IM/EM/bTIL）在全转录组通路上有何差异？ | `mroi-mrseq-counts` | [[methods/differential-expression]] · [[methods/gene-set-scoring]] · [[methods/gene-set-enrichment]] | [[templates/fy-pca]] · [[templates/bulk-de-volcano]] · [[templates/pathway-zscore-heatmap]] · [[templates/fy-fancybar]] |
| **Stage 5B–C** | 关键调控程序的核心共表达枢纽是否预测临床预后？ | `mroi-mrseq-counts` + `bulk-clinical-survival` | [[methods/coexpression-ppi-network]] · [[methods/survival-prognosis-analysis]] | [[templates/coexpr-hub-radial-network]] · [[templates/km-survival-risk-grid]] · [[templates/scp-comp-trend]] |

## 实操案例与母树入口

- **实操案例卡**：[[projects/2022-nirmal-melanoma-spatial|原发性黑色素瘤空间进展与免疫编辑多组学解析（Nirmal et al., 2022）]]
- **对应复刻流程**：[[methods/melanoma-spatial-immunoediting-workflow]]
- **姐妹专题分支树**：[[scenarios/stromal-tme-scrna-st-playbook|单细胞与空转肿瘤基质微环境思路分支树（Playbook）]] · [[scenarios/scrna-stepwise-playbook|单细胞转录组步进决策树（Playbook）]]

## 注意

- **不可跨越物理连续性与抗体面板边界**：计算 Spatial LDA、Voronoi 多边形、空间置换检验与空间滞后时，必须使用**未抽样打碎的连续物理 FOV 视野**，禁止对随机抽样残片强行构建空间邻域；多面板 CyCIF 若部分蛋白仅存于其他 Panel，须诚实标注 `proxy` 或留空。
- **纯显微图像排除原则**：原始多通道荧光显微图像、H&E 病理扫描图与 3D 表面渲染图不属于生信统计/空间量化模板范围，按 `excluded_imaging` 口径仅在图版对应位置说明出处。

<!-- user:start -->
<!-- user:end -->
