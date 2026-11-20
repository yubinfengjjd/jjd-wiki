---
type: scenario
id: stromal-tme-scrna-st-playbook
title: 单细胞与空转肿瘤基质微环境思路分支树（Playbook）
picks:
- id: methods/batch-integration
  note: Stage 1：多队列单细胞去批次整合（Harmony / Seurat Anchor）
- id: methods/cell-type-annotation
  note: Stage 1：基质亚群精细注释与功能包络定位
- id: templates/scrna-celltype-umap
  note: 主推默认 · 标准细胞类型 UMAP 散点图
- id: templates/stromal-hull-umap
  note: 可切换画风 · 带分组虚线包络与编号质心的 UMAP 图
- id: methods/spatial-transcriptomics-microenvironment
  note: Stage 2（双上游汇合）：单细胞注释 + Visium 切片空间反卷积与共定位
- id: templates/spatial-feature-grid
  note: 主推默认 · 多区域空间转录组特征分布网格
- id: templates/spatial-he-deconv-panel
  note: 可切换画风 · H&E 组织切片配准与空间细胞权重对照
- id: templates/spatial-coexpr-multichannel
  note: 可切换画风 · 多通道空间共表达与重点区域叠图
- id: methods/cell-proportion-composition
  note: Stage 3：Ro/e 组织偏好、亚型富集与跨队列比例统计
- id: templates/roe-cox-heatmap
  note: 主推默认 · 多因素 Cox 与 Ro/e 组织/亚型偏好热图
- id: templates/tissue-ratio-prop-combo
  note: 可切换画风 · 组织比例堆叠 + 样本箱线检验组合图
- id: methods/gene-set-scoring
  note: Stage 4A：功能基因程序、PROGENy 通路与 KEGG 代谢刻画
- id: templates/pathway-zscore-heatmap
  note: 主推默认 · 分组功能基因与通路 Z-score 热图
- id: templates/kegg-cluster-bubble
  note: 主推默认 · 多亚群 KEGG 通路富集气泡矩阵
- id: templates/cluster-kegg-bars
  note: 可切换画风 · 亚群分面富集条形图与命中计数
- id: templates/metabolism-lollipop-dotplot
  note: 可切换画风 · 多亚群代谢通路棒棒糖图
- id: methods/trajectory-inference
  note: Stage 4B：DiffusionMap / Slingshot 拟时序分化与动态基因
- id: templates/diffusion-trajectory-overlay
  note: 主推默认 · 降维轨迹与双功能模块激活叠图
- id: templates/pseudotime-branch-curves
  note: 可切换画风 · 拟时序多分支动态基因曲线网格
- id: methods/immune-infiltration-tme
  note: Stage 5：基质–免疫排斥相关矩阵与检查点差异验证
- id: templates/clustered-corr-boxes
  note: 主推默认 · 带层次聚类框与引线的对称相关矩阵
- id: templates/checkpoint-group-boxplot
  note: 可切换画风 · 高/低分组免疫检查点表达箱线图
- id: methods/cell-cell-communication
  note: Stage 6：TLS 与 TAM 空间配受体通讯枢纽解析
- id: templates/lr-bubble-matrix
  note: 主推默认 · 配受体互作概率气泡矩阵
- id: templates/cellchat-count-heatmap
  note: 可切换画风 · 细胞通讯计数柱状热图
- id: templates/lr-bipartite-bubble
  note: 可切换画风 · 配受体双轴连线气泡图
- id: templates/cellchat-signaling-ring
  note: 可切换画风 · 通路定向多节点细胞通讯环形弦图
tags:
- single-cell
- transcriptomics
- multi-omics
- survival-analysis
keywords:
- 肿瘤基质微环境
- CAF
- 内皮细胞
- 周细胞
- Visium
- RCTD
- Ro/e
- DiffusionMap
- Slingshot
- CellChat
- 免疫排斥
- TLS
summary: 面向「单细胞转录组 + Visium 空间转录组 + 临床 Bulk 队列」的肿瘤基质微环境专题思路分支树（7 阶段 DAG 子树），支持双上游汇合节点（requires）与多套顶刊风格模板按需切换。
steps:
- id: cell-type-annotation
  step: 1
  title: Stage 1 · 基质精细亚群注释与跨队列整合
  method_id: cell-type-annotation
  when: 拿到多中心肿瘤单细胞数据，完成 QC 后拆出 Fib/EC/Mural 基质区室并做精细亚群命名时
  inputs: []
  outputs:
  - scrna-annotated-cells
  interface: scrna-annotated-cells
  templates:
  - methods/batch-integration
  - methods/cell-type-annotation
  - templates/scrna-celltype-umap
  - templates/stromal-hull-umap
  - templates/scrna-feature-umap-grid
  - templates/marker-bubble-dotplot
  next_steps:
  - spatial-transcriptomics-microenvironment
  - cell-proportion-composition
- id: spatial-transcriptomics-microenvironment
  step: 2
  title: Stage 2 · 空间去卷积与 H&E 组织分区对齐
  method_id: spatial-transcriptomics-microenvironment
  when: 同时具备已注释单细胞图谱与 Visium 空间切片，需要将基质亚群投射回空间并划定病理区域时
  requires:
  - scrna-annotated-cells
  - visium-spatial-object
  inputs:
  - scrna-annotated-cells
  outputs:
  - cell-proportion-stats
  interface: cell-proportion-stats
  templates:
  - methods/spatial-transcriptomics-microenvironment
  - templates/spatial-feature-grid
  - templates/spatial-he-deconv-panel
  - templates/spatial-coexpr-multichannel
  next_steps:
  - cell-proportion-composition
  - immune-infiltration-tme
  - cell-cell-communication
- id: cell-proportion-composition
  step: 3
  title: Stage 3 · Ro/e 组织偏好与多队列 Cox 预后分层
  method_id: cell-proportion-composition
  when: 量化各基质亚群在正常/癌旁/肿瘤/淋巴结及分子亚型中的偏好，并检验 TCGA 与外部队列预后风险时
  requires:
  - stromal-subcluster-markers
  - bulk-clinical-survival
  inputs:
  - scrna-annotated-cells
  outputs:
  - cell-proportion-stats
  - subgroup-effect-table
  interface: cell-proportion-stats
  templates:
  - methods/cell-proportion-composition
  - methods/survival-prognosis-analysis
  - templates/cell-prop-flow-bar
  - templates/roe-cox-heatmap
  - templates/tissue-ratio-prop-combo
  next_steps:
  - gene-set-scoring
  - trajectory-inference
- id: gene-set-scoring
  step: 4
  title: Stage 4A · 功能基因程序、PROGENy 与 KEGG 代谢刻画
  method_id: gene-set-scoring
  when: 比较不同基质亚群的趋化因子/MHC 表达、PROGENy 信号活性与 KEGG 代谢通路分化时
  inputs:
  - scrna-annotated-cells
  - deg-result-table
  outputs:
  - pathway-score-table
  interface: pathway-score-table
  templates:
  - methods/gene-set-scoring
  - methods/differential-expression
  - methods/gene-set-enrichment
  - templates/pathway-zscore-heatmap
  - templates/kegg-cluster-bubble
  - templates/cluster-kegg-bars
  - templates/metabolism-lollipop-dotplot
  - templates/scrna-feature-umap-grid
  - templates/coexpr-module-enrich-bars
  next_steps:
  - trajectory-inference
  - immune-infiltration-tme
- id: trajectory-inference
  step: 4
  title: Stage 4B · DiffusionMap / Slingshot 分化轨迹与功能切换
  method_id: trajectory-inference
  when: 沿连续分化流形推断基质亚群起点与分支命运，并追踪双功能模块及关键标志基因沿伪时序动态变化时
  inputs:
  - scrna-annotated-cells
  outputs:
  - pseudotime-trajectory-table
  interface: pseudotime-trajectory-table
  templates:
  - methods/trajectory-inference
  - templates/diffusion-trajectory-overlay
  - templates/pseudotime-branch-curves
  next_steps:
  - cell-cell-communication
- id: immune-infiltration-tme
  step: 5
  title: Stage 5 · 基质–免疫排斥相关矩阵与检查点验证
  method_id: immune-infiltration-tme
  when: 锁定关键基质亚群后，评估其与微环境免疫细胞浸润的相关性、空间排斥格局及检查点表达差异时
  requires:
  - scrna-annotated-cells
  - visium-spatial-object
  inputs:
  - bulk-de-table
  - scrna-annotated-cells
  outputs:
  - pathway-score-table
  interface: pathway-score-table
  templates:
  - methods/immune-infiltration-tme
  - templates/clustered-corr-boxes
  - templates/checkpoint-group-boxplot
  next_steps:
  - cell-cell-communication
- id: cell-cell-communication
  step: 6
  title: Stage 6 · TLS / TAM 空间配受体通讯枢纽解析
  method_id: cell-cell-communication
  when: 解析核心基质亚群与恶性细胞、TLS 淋巴细胞或巨噬细胞之间的旁分泌/血管调控配受体信号轴并在空转共定位验证时
  requires:
  - scrna-annotated-cells
  - visium-spatial-object
  inputs:
  - scrna-annotated-cells
  outputs:
  - cellchat-lr-table
  interface: cellchat-lr-table
  templates:
  - methods/cell-cell-communication
  - templates/lr-bubble-matrix
  - templates/cellchat-count-heatmap
  - templates/lr-bipartite-bubble
  - templates/cellchat-signaling-ring
  - templates/cellchat-circos-multi
  next_steps: []
---

# 单细胞与空转肿瘤基质微环境思路分支树（Playbook）

## 什么时候用

- 从多队列单细胞转录组出发，在主干树 [[scenarios/scrna-stepwise-playbook|单细胞转录组步进决策树]] 完成 Step 1–3 后，若课题聚焦 **肿瘤基质微环境（Fib / EC / Mural）** 且同时拥有 **Visium 空间转录组切片** 与 **TCGA/院内 Bulk 临床队列**，从 Branch 7 切入本专题子树。
- 本子树解决纯树无法表达“多上游汇合”的问题：在空间反卷积（Stage 2）、预后关联（Stage 3）、免疫排斥验证（Stage 5）与空间通讯（Stage 6）显式标注 `requires:` 多源输入条件，并为每个研究节点挂接多套可按需切换的绘图模板（`default` 主推默认风格 + `variant` 顶刊复刻风格）。

## 首选组合

<!-- facts:start -->
| 条目 | 级别 | 状态 | 说明 |
|---|---|---|---|
| [[methods/batch-integration|单细胞批次整合]] | L2 | ready · 可用 | Stage 1：多队列单细胞去批次整合（Harmony / Seurat Anchor） |
| [[methods/cell-type-annotation|细胞类型注释]] | L2 | ready · 可用 | Stage 1：基质亚群精细注释与功能包络定位 |
| [[templates/scrna-celltype-umap|CNS 细胞类型 UMAP]] | L2 | ready · 可用 | 主推默认 · 标准细胞类型 UMAP 散点图 |
| [[templates/stromal-hull-umap|基质亚群功能包络UMAP]] | L2 | ready · 可用 | 可切换画风 · 带分组虚线包络与编号质心的 UMAP 图 |
| [[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]] | note | ready | Stage 2（双上游汇合）：单细胞注释 + Visium 切片空间反卷积与共定位 |
| [[templates/spatial-feature-grid|空间转录组特征分布网格]] | L2 | ready · 可用 | 主推默认 · 多区域空间转录组特征分布网格 |
| [[templates/spatial-he-deconv-panel|配准组织图与反卷积对照]] | L2 | ready · 可用 | 可切换画风 · H&E 组织切片配准与空间细胞权重对照 |
| [[templates/spatial-coexpr-multichannel|多通道空间表达与重点区域]] | L2 | ready · 可用 | 可切换画风 · 多通道空间共表达与重点区域叠图 |
| [[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]] | note | ready | Stage 3：Ro/e 组织偏好、亚型富集与跨队列比例统计 |
| [[templates/roe-cox-heatmap|多因素Cox与Ro/e热图]] | L2 | ready · 可用 | 主推默认 · 多因素 Cox 与 Ro/e 组织/亚型偏好热图 |
| [[templates/tissue-ratio-prop-combo|组织构成与样本比例组合图]] | L2 | ready · 可用 | 可切换画风 · 组织比例堆叠 + 样本箱线检验组合图 |
| [[methods/gene-set-scoring|基因集与通路签名打分]] | L2 | ready · 可用 | Stage 4A：功能基因程序、PROGENy 通路与 KEGG 代谢刻画 |
| [[templates/pathway-zscore-heatmap|功能基因与通路Zscore热图]] | L2 | ready · 可用 | 主推默认 · 分组功能基因与通路 Z-score 热图 |
| [[templates/kegg-cluster-bubble|多亚群KEGG通路气泡矩阵]] | L2 | ready · 可用 | 主推默认 · 多亚群 KEGG 通路富集气泡矩阵 |
| [[templates/cluster-kegg-bars|亚群富集条形图与命中数]] | L2 | ready · 可用 | 可切换画风 · 亚群分面富集条形图与命中计数 |
| [[templates/metabolism-lollipop-dotplot|多亚群代谢通路棒棒糖图]] | L2 | ready · 可用 | 可切换画风 · 多亚群代谢通路棒棒糖图 |
| [[methods/trajectory-inference|拟时序与轨迹推断]] | L2 | ready · 可用 | Stage 4B：DiffusionMap / Slingshot 拟时序分化与动态基因 |
| [[templates/diffusion-trajectory-overlay|降维轨迹与功能模块叠图]] | L2 | ready · 可用 | 主推默认 · 降维轨迹与双功能模块激活叠图 |
| [[templates/pseudotime-branch-curves|拟时序多分支基因曲线网格]] | L2 | ready · 可用 | 可切换画风 · 拟时序多分支动态基因曲线网格 |
| [[methods/immune-infiltration-tme|肿瘤微环境与免疫浸润评估]] | note | ready | Stage 5：基质–免疫排斥相关矩阵与检查点差异验证 |
| [[templates/clustered-corr-boxes|带聚类框与引线的相关矩阵]] | L2 | ready · 可用 | 主推默认 · 带层次聚类框与引线的对称相关矩阵 |
| [[templates/checkpoint-group-boxplot|检查点分组表达箱线图]] | L2 | ready | 可切换画风 · 高/低分组免疫检查点表达箱线图 |
| [[methods/cell-cell-communication|细胞通讯与配受体网络分析]] | note | ready | Stage 6：TLS 与 TAM 空间配受体通讯枢纽解析 |
| [[templates/lr-bubble-matrix|配受体互作概率气泡矩阵]] | L2 | ready · 可用 | 主推默认 · 配受体互作概率气泡矩阵 |
| [[templates/cellchat-count-heatmap|细胞通讯计数柱状热图]] | L2 | ready · 可用 | 可切换画风 · 细胞通讯计数柱状热图 |
| [[templates/lr-bipartite-bubble|配受体双轴连线气泡图]] | L2 | ready · 可用 | 可切换画风 · 配受体双轴连线气泡图 |
| [[templates/cellchat-signaling-ring|通路定向细胞通讯弦图]] | L2 | ready | 可切换画风 · 通路定向多节点细胞通讯环形弦图 |
<!-- facts:end -->

## 步进决策树（双上游汇合 × 可切换顶刊模板）

| 阶段 | 核心科学问题 | 汇合前提（`requires`） | 分析方法 | 可切换绘图模板（主推默认 / 顶刊变体） |
|---|---|---|---|---|
| **Stage 1** | 基质细胞可分出哪些稳定功能亚群？ | — | [[methods/batch-integration]] · [[methods/cell-type-annotation]] | [[templates/scrna-celltype-umap]]（默认） / [[templates/stromal-hull-umap]]（包络变体） · [[templates/marker-bubble-dotplot]] |
| **Stage 2** | 亚群在组织切片 H&E 上处于哪类病理生态位？ | `scrna-annotated-cells` + `visium-spatial-object` | [[methods/spatial-transcriptomics-microenvironment]] | [[templates/spatial-feature-grid]]（默认） / [[templates/spatial-he-deconv-panel]] · [[templates/spatial-coexpr-multichannel]] |
| **Stage 3** | 哪些亚群富集于肿瘤并显著影响患者生存？ | `stromal-subcluster-markers` + `bulk-clinical-survival` | [[methods/cell-proportion-composition]] · [[methods/survival-prognosis-analysis]] | [[templates/roe-cox-heatmap]]（默认） / [[templates/tissue-ratio-prop-combo]] · [[templates/cell-prop-flow-bar]] |
| **Stage 4A** | 关键亚群驱动了哪些趋化/信号/代谢程序？ | — | [[methods/gene-set-scoring]] · [[methods/differential-expression]] · [[methods/gene-set-enrichment]] | [[templates/pathway-zscore-heatmap]] · [[templates/kegg-cluster-bubble]] / [[templates/cluster-kegg-bars]] · [[templates/metabolism-lollipop-dotplot]] |
| **Stage 4B** | 亚群间是否存在连续分化路径与功能切换？ | — | [[methods/trajectory-inference]] | [[templates/diffusion-trajectory-overlay]]（默认） / [[templates/pseudotime-branch-curves]] |
| **Stage 5** | 关键基质亚群是否介导 T 细胞排斥与耗竭？ | `scrna-annotated-cells` + `visium-spatial-object` | [[methods/immune-infiltration-tme]] | [[templates/clustered-corr-boxes]]（默认） / [[templates/checkpoint-group-boxplot]] |
| **Stage 6** | 谁通过哪些配受体在空间上招募/重塑 TLS 与 TAM？ | `scrna-annotated-cells` + `visium-spatial-object` | [[methods/cell-cell-communication]] | [[templates/lr-bubble-matrix]]（默认） / [[templates/cellchat-count-heatmap]] · [[templates/lr-bipartite-bubble]] · [[templates/cellchat-signaling-ring]] · [[templates/cellchat-circos-multi]] |

## 如何向本分支树嫁接新课题分支

1. **三查复用**：若新文献属于同样“scRNA + Visium ST + Bulk”基质微环境研究，直接复用上述 7 阶段方法与模板，不新建重复分析家族。
2. **新画风挂回方法页**：新论文产出不同排版或配色风格时，建入 `wiki/templates/<short-slug>/` 并标记 `style_tier: variant` 与 `journal_style`，挂载至对应 `methods/<id>.md` 的 `figure_relations`，即可在决策树同一节点一键切换。
3. **新增专题子树与独立案例卡**：若引入全新组学维度（如空间代谢组/蛋白组），在 `scenarios/` 新增专题子树并声明 `requires`，同时为具体课题建独立走线实录卡（参考 [[projects/2026-cai-stromal-tme]]）。

## 注意

- `Stage 2`、`Stage 5` 与 `Stage 6` 均要求 `scrna-annotated-cells` 与 `visium-spatial-object` 双上游就绪；若课题仅有纯单细胞数据，请留在主干树 [[scenarios/scrna-stepwise-playbook]] 的分支 1–6，不要强行跨入空转节点。
- 细胞比例检验必须按患者/批次样本聚合计算，避免将单细胞数作为独立重复；湿实验验证（如共培养、流式、mIF）不属于纯生信决策树执行范围。

<!-- user:start -->
<!-- user:end -->
