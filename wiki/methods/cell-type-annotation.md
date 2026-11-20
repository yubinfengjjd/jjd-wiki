---
type: method
id: cell-type-annotation
title: 细胞类型注释
status: ready
tags:
- 单细胞分析
inputs: []
outputs:
- scrna-annotated-cells
source:
  kind: repo
  url: https://github.com/zhanghao-njmu/scp
  commit: b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0
license: GPL-3
cite:
- 'SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)'
favorite: false
method_kind: analysis
purposes:
- 注释与参考映射
summary: 综合参考标签与 marker 集合给细胞分配类型；SingleR 分支在批准公开用例与直接 SingleR 结果一致（非全量 SCP 等价），青光眼
  marker 手工注释尚未函数化。
data_contract:
  input: query Seurat；参考标签分支需 reference Seurat + ref_group，marker 分支需预先定义的 marker→类型映射；同物种/同基因标识。
  output: 每细胞 predicted label 与分数（SingleR 公开 pancreas 用例已验证输出），或手工 marker 注释标签表。
implementations:
- id: scp-singler
  title: SCP RunSingleR 分支
  language: R
  entrypoint: code/analysis.R:run_cell_type_annotation
  dependencies:
  - Seurat
  - SeuratObject
  - Matrix
  - rlang
  - SingleR
  - SingleCellExperiment
  - SummarizedExperiment
  - scrapper
  verification: verification/scp-singler-standalone.json
keywords:
- SingleR
- marker
- cell type
- annotation
- 参考注释
- 手工注释
- SCP
- GSE251716
figure_relations:
- figure: templates/scrna-celltype-umap
  compatibility: adaptable
  reason: 预测细胞类型可作为 UMAP 着色变量；模板不执行注释。
  prerequisites:
  - 预测标签与 UMAP 坐标来自同一查询对象；cell_id 一致。
  - 标签不是 cluster 编号；group_levels 按注释顺序给出。
  adaptation: 导出 render-umap-groups.csv（group=predicted celltype）。
  evidence:
  - methods/cell-type-annotation.md#输出
  - methods/scp-annotation-projection.md#知识关联检查
  - methods/scp-annotation-projection.md#输出
  - templates/scrna-celltype-umap/spec.json
  - templates/scrna-celltype-umap/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
- figure: templates/scrna-feature-umap-grid
  compatibility: adaptable
  reason: 用 marker 表达检查预测标签是否落在对应群，可复用特征 UMAP 网格；模板不做注释或检验。
  prerequisites:
  - marker 表达长表与 UMAP 坐标同源；cell_id 一致。
  - 每个 feature 至少有一个正表达细胞；目标类型在 group 中存在。
  adaptation: 导出 render-umap-feature-long.csv（cell_id, umap_1, umap_2, group, feature,
    value）。
  evidence:
  - methods/cell-type-annotation.md#输出
  - methods/scp-annotation-projection.md#知识关联检查
  - methods/scp-annotation-projection.md#输出
  - templates/scrna-feature-umap-grid/spec.json
  - templates/scrna-feature-umap-grid/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
- figure: templates/marker-bubble-dotplot
  compatibility: adaptable
  reason: 预测类型的 marker 平均表达/阳性比例可整理成点图，检查注释是否合理；模板不重算统计。
  prerequisites:
  - avg_expression 与 pct_expressed 由表达矩阵按预测标签计算；缩放方式说明。
  - group/feature 顺序由课题给出；target_group 只用于排序。
  adaptation: 导出 render-dotplot-long.csv（group, feature, avg_expression, pct_expressed,
    target_group）。
  evidence:
  - methods/cell-type-annotation.md#输出
  - methods/scp-annotation-projection.md#知识关联检查
  - methods/scp-annotation-projection.md#输出
  - templates/marker-bubble-dotplot/spec.json
  - templates/marker-bubble-dotplot/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
- figure: templates/cell-prop-flow-bar
  compatibility: adaptable
  reason: 按样本/条件统计预测类型比例，检查注释组成；模板不做统计检验。
  prerequisites:
  - 每个 group 的比例归一化到 1；group 为样本/条件，celltype 为预测标签。
  - 比例是描述性；组间差异不能由该图直接推断。
  adaptation: 导出 render-cell-proportions.csv（group, celltype, proportion）。
  evidence:
  - methods/cell-type-annotation.md#输出
  - methods/scp-annotation-projection.md#知识关联检查
  - methods/scp-annotation-projection.md#输出
  - templates/cell-prop-flow-bar/spec.json
  - templates/cell-prop-flow-bar/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
- figure: templates/stromal-hull-umap
  compatibility: adaptable
  reason: 注释后的精细细胞亚群与高阶功能群（如 mFib/lpFib/iFib）可切换为 variant 红色虚线包络 + 编号质心 UMAP 画风；模板不执行注释。
  prerequisites:
  - umap_1/umap_2 与 subcluster 标签来自同一已注释对象；cell_id 唯一。
  adaptation: 导出 stromal_umap_cells.csv（cell_id, umap_1, umap_2, subcluster, functional_group）。
  evidence:
  - methods/cell-type-annotation.md#输出
  - templates/stromal-hull-umap/spec.json
  verification:
    state: not_run
    scope: 2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/tri-panel-stage-umap
  compatibility: adaptable
  reason: 注释后的单细胞/空间蛋白组细胞类型标签可与进展分期、患者 ID 合并导出为 Cancer Discovery 风格三联 UMAP 变体；模板不执行注释。
  prerequisites:
  - umap_1/umap_2 与 cell_type、stage、patient_id 来自同一质控后对象；cell_id 唯一。
  adaptation: 导出 umap_tripanel_cells.csv（cell_id, umap_1, umap_2, cell_type, stage,
    patient_id）。
  evidence:
  - methods/cell-type-annotation.md#输出
  - templates/tri-panel-stage-umap/spec.json
  verification:
    state: not_run
    scope: 2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/split-condition-umap
  compatibility: adaptable
  reason: 注释后的精细细胞亚群可按组织/实验条件（如 Normal vs Tumor）并排分面展示（灰色全集背景 + 当前条件高亮彩点）；模板不执行注释。
  prerequisites:
  - umap_1/umap_2、subcluster 与 condition 来自同一整合注释对象；cell_id 唯一。
  adaptation: 导出 split_condition_umap_cells.csv（cell_id, umap_1, umap_2, subcluster,
    condition）。
  evidence:
  - methods/cell-type-annotation.md#输出
  - templates/split-condition-umap/spec.json
  verification:
    state: not_run
    scope: 2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/feature-umap-contrast-grid
  compatibility: adaptable
  reason: 谱系标志基因表达量或功能模块评分可在单细胞 UMAP 上按高对比度置顶色阶与 Min/Max 色标渲染为多面板网格；模板不执行打分。
  prerequisites:
  - 坐标与连续特征列来自同一单细胞对象；特征列已完成对数标准化或模块打分。
  adaptation: 导出 feature_umap_scores.csv（cell_id, umap_1, umap_2 及多列连续特征/模块得分）。
  evidence:
  - methods/cell-type-annotation.md#输出
  - templates/feature-umap-contrast-grid/spec.json
  verification:
    state: not_run
    scope: 2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/cycif-feature-umap-strip
  compatibility: adaptable
  reason: 空间蛋白组（CyCIF）或单细胞的多标志物 [0, 1] 归一化强度可按 Cancer Discovery 蓝-灰-红连续色阶条带并排展示。
  prerequisites:
  - 各标志物列已完成对数转换与 [0, 1] 范围缩放；坐标与强度同源。
  adaptation: 导出 cycif_umap_markers.csv（cell_id, umap_1, umap_2 及多标志物归一化强度列）。
  evidence:
  - methods/cell-type-annotation.md#输出
  - templates/cycif-feature-umap-strip/spec.json
  verification:
    state: not_run
    scope: 2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
next_steps:
- direction: 方向 1：细胞组成比例与 Ro/e 组织偏好分析
  when: 比较疾病组与对照组间各细胞亚群占比变化、样本级差异或组织富集偏好时
  analysis_templates:
  - methods/cell-proportion-composition
  - recipes/figureya-315singlerfraction
  intermediate_interface: cell-proportion-stats
  viz_templates:
  - templates/roe-cox-heatmap
  - templates/tissue-ratio-prop-combo
  - templates/cell-prop-flow-bar
  - templates/scp-comp-ring
  - templates/scp-comp-pie
  - templates/stromal-hull-umap
- direction: 方向 2：亚群差异表达分析与功能富集（DEG / ORA / GSEA）
  when: 筛选特定细胞亚群在疾病 vs 对照条件下的差异基因及功能通路变化时
  analysis_templates:
  - methods/differential-expression
  - methods/gene-set-enrichment
  - recipes/figureya-318genesetdedotplot
  intermediate_interface: deg-result-table
  viz_templates:
  - templates/scp-de-volcano
  - templates/marker-bubble-dotplot
  - templates/scp-group-heatmap
  - templates/kegg-cluster-bubble
  - templates/cluster-kegg-bars
  - templates/metabolism-lollipop-dotplot
- direction: 方向 3：主题基因集多算法打分（AUCell / UCell / ssGSEA / PROGENy）
  when: 评估乳酸化、PTM 修饰、铁死亡、PROGENy 通路或代谢等自定义基因集在各亚群中的活性分布时
  analysis_templates:
  - methods/gene-set-scoring
  - recipes/figureya-275scaucell
  intermediate_interface: pathway-score-table
  viz_templates:
  - templates/pathway-zscore-heatmap
  - templates/pathway-stat-violin
  - templates/scp-expr-ridge
  - templates/scp-feature-heatmap
- direction: 方向 4：关键亚群拟时序轨迹与 RNA 速率演化
  when: 提取目标谱系亚群做精细亚聚类，追踪细胞状态分化路径与动态驱动基因时
  analysis_templates:
  - methods/trajectory-inference
  - methods/rna-velocity
  - methods/dynamic-feature-analysis
  intermediate_interface: pseudotime-trajectory-table
  viz_templates:
  - templates/diffusion-trajectory-overlay
  - templates/pseudotime-branch-curves
  - templates/scrna-celltype-umap
  - templates/scrna-feature-umap-grid
- direction: 方向 5：细胞通讯配受体网络分析（CellChat / CellPhoneDB）
  when: 解析目标亚群与免疫/基质微环境之间的旁分泌或接触式信号通路重塑时
  analysis_templates:
  - methods/cell-cell-communication
  intermediate_interface: cellchat-lr-table
  viz_templates:
  - templates/lr-bubble-matrix
  - templates/cellchat-count-heatmap
  - templates/lr-bipartite-bubble
  - templates/cellchat-signaling-ring
  - templates/cellchat-circos-multi
  - templates/scp-flow-chord
  - templates/scp-flow-sankey
- direction: 方向 6：关键亚群 Marker 投射 Bulk 临床队列与预后建模
  when: 将单细胞核心靶基因带入 TCGA/GEO Bulk 队列验证免疫排斥、检查点或构建诊断/预后模型与 SHAP 解释时
  analysis_templates:
  - methods/immune-infiltration-tme
  - methods/survival-prognosis-analysis
  - recipes/figureya-293plus-binaryclassificationml
  - methods/regression-resampling-evaluation
  - methods/shap-explanation
  intermediate_interface: candidate-biomarker-list
  viz_templates:
  - templates/km-survival-curve
  - templates/subgroup-hazard-forest
  - templates/clustered-corr-boxes
  - templates/checkpoint-group-boxplot
  - templates/shap-beeswarm
- direction: 方向 7：单细胞 × Visium 空间转录组基质微环境联合解析（Branch 7 子树）
  when: 同时具备已注释单细胞图谱与 Visium 空间切片，需要开展空间反卷积/签名映射、H&E 分区对齐与空间配受体共定位时（详见 scenarios/stromal-tme-scrna-st-playbook）
  analysis_templates:
  - methods/spatial-transcriptomics-microenvironment
  intermediate_interface: scrna-annotated-cells
  viz_templates:
  - templates/spatial-feature-grid
  - templates/spatial-he-deconv-panel
  - templates/spatial-coexpr-multichannel
data_domains:
- single-cell
render_bridges:
- interface: render-dotplot-long
  from_output: scrna-annotated-cells
  extractor_note: 按注释后的 cell_type 分组计算经典 marker 基因平均表达（avg_expression）与阳性细胞比例（pct_expressed），整理为
    group、feature、avg_expression、pct_expressed、target_group 长表。
  unit: 细胞类型 × Marker 基因
- interface: render-umap-feature-long
  from_output: scrna-annotated-cells
  extractor_note: 从已注释对象抽取每个细胞的 UMAP 坐标（umap_1, umap_2）、所属细胞类型 group 与目标 marker 基因表达值，输出
    cell_id、umap_1、umap_2、group、feature、value 长表。
  unit: 细胞 × Marker 基因
- interface: render-umap-groups
  from_output: scrna-annotated-cells
  extractor_note: 导出每个细胞的 UMAP 坐标与预测/手工注释细胞类型标签（cell_id, umap_1, umap_2, group），显式固定
    group_levels 顺序。
  unit: 单细胞
---
# 细胞类型注释

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)
- 标签：单细胞分析
- 分析用途：注释与参考映射
- 输入接口：未声明
- 输出接口：[[interfaces/scrna-annotated-cells|已注释单细胞元数据与降维表]]
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：[[methods/cell-cell-communication|细胞通讯与配受体网络分析]]（ready） · [[methods/cell-proportion-composition|细胞亚群组成比例与流向分析]]（ready） · [[methods/differential-expression|差异表达分析]]（ready） · [[methods/gene-set-scoring|基因集与通路签名打分]]（ready） · [[methods/rna-velocity|RNA 速度分析]]（ready） · [[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]（ready） · [[methods/trajectory-inference|拟时序与轨迹推断]]（ready）
- 代码模板：[methods/cell-type-annotation/code/analysis.R](/files/wiki/methods/cell-type-annotation/code/analysis.R) · [methods/cell-type-annotation/code/annotation_native.R](/files/wiki/methods/cell-type-annotation/code/annotation_native.R)
- 下一步分析导航（Step N → Step N+1）：
  - **方向 1：细胞组成比例与 Ro/e 组织偏好分析**（触发条件：比较疾病组与对照组间各细胞亚群占比变化、样本级差异或组织富集偏好时；中间表：cell-proportion-stats；分析模版：methods/cell-proportion-composition、recipes/figureya-315singlerfraction；可视化模版：templates/roe-cox-heatmap、templates/tissue-ratio-prop-combo、templates/cell-prop-flow-bar、templates/scp-comp-ring、templates/scp-comp-pie、templates/stromal-hull-umap）
  - **方向 2：亚群差异表达分析与功能富集（DEG / ORA / GSEA）**（触发条件：筛选特定细胞亚群在疾病 vs 对照条件下的差异基因及功能通路变化时；中间表：deg-result-table；分析模版：methods/differential-expression、methods/gene-set-enrichment、recipes/figureya-318genesetdedotplot；可视化模版：templates/scp-de-volcano、templates/marker-bubble-dotplot、templates/scp-group-heatmap、templates/kegg-cluster-bubble、templates/cluster-kegg-bars、templates/metabolism-lollipop-dotplot）
  - **方向 3：主题基因集多算法打分（AUCell / UCell / ssGSEA / PROGENy）**（触发条件：评估乳酸化、PTM 修饰、铁死亡、PROGENy 通路或代谢等自定义基因集在各亚群中的活性分布时；中间表：pathway-score-table；分析模版：methods/gene-set-scoring、recipes/figureya-275scaucell；可视化模版：templates/pathway-zscore-heatmap、templates/pathway-stat-violin、templates/scp-expr-ridge、templates/scp-feature-heatmap）
  - **方向 4：关键亚群拟时序轨迹与 RNA 速率演化**（触发条件：提取目标谱系亚群做精细亚聚类，追踪细胞状态分化路径与动态驱动基因时；中间表：pseudotime-trajectory-table；分析模版：methods/trajectory-inference、methods/rna-velocity、methods/dynamic-feature-analysis；可视化模版：templates/diffusion-trajectory-overlay、templates/pseudotime-branch-curves、templates/scrna-celltype-umap、templates/scrna-feature-umap-grid）
  - **方向 5：细胞通讯配受体网络分析（CellChat / CellPhoneDB）**（触发条件：解析目标亚群与免疫/基质微环境之间的旁分泌或接触式信号通路重塑时；中间表：cellchat-lr-table；分析模版：methods/cell-cell-communication；可视化模版：templates/lr-bubble-matrix、templates/cellchat-count-heatmap、templates/lr-bipartite-bubble、templates/cellchat-signaling-ring、templates/cellchat-circos-multi、templates/scp-flow-chord、templates/scp-flow-sankey）
  - **方向 6：关键亚群 Marker 投射 Bulk 临床队列与预后建模**（触发条件：将单细胞核心靶基因带入 TCGA/GEO Bulk 队列验证免疫排斥、检查点或构建诊断/预后模型与 SHAP 解释时；中间表：candidate-biomarker-list；分析模版：methods/immune-infiltration-tme、methods/survival-prognosis-analysis、recipes/figureya-293plus-binaryclassificationml、methods/regression-resampling-evaluation、methods/shap-explanation；可视化模版：templates/km-survival-curve、templates/subgroup-hazard-forest、templates/clustered-corr-boxes、templates/checkpoint-group-boxplot、templates/shap-beeswarm）
  - **方向 7：单细胞 × Visium 空间转录组基质微环境联合解析（Branch 7 子树）**（触发条件：同时具备已注释单细胞图谱与 Visium 空间切片，需要开展空间反卷积/签名映射、H&E 分区对齐与空间配受体共定位时（详见 scenarios/stromal-tme-scrna-st-playbook）；中间表：scrna-annotated-cells；分析模版：methods/spatial-transcriptomics-microenvironment；可视化模版：templates/spatial-feature-grid、templates/spatial-he-deconv-panel、templates/spatial-coexpr-multichannel）

- 方法配图关系（语义审查）：
  - [[templates/scrna-celltype-umap|单细胞细胞类型 UMAP（标准版）]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：预测细胞类型可作为 UMAP 着色变量；模板不执行注释。；前提：预测标签与 UMAP 坐标来自同一查询对象；cell_id 一致。；标签不是 cluster 编号；group_levels 按注释顺序给出。；适配：导出 render-umap-groups.csv（group=predicted celltype）。
    - 关系证据：methods/cell-type-annotation.md#输出；methods/scp-annotation-projection.md#知识关联检查；methods/scp-annotation-projection.md#输出；templates/scrna-celltype-umap/spec.json；templates/scrna-celltype-umap/verify/verify.json；运行证据：无
  - [[templates/scrna-feature-umap-grid|marker 特征 UMAP 小多图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：用 marker 表达检查预测标签是否落在对应群，可复用特征 UMAP 网格；模板不做注释或检验。；前提：marker 表达长表与 UMAP 坐标同源；cell_id 一致。；每个 feature 至少有一个正表达细胞；目标类型在 group 中存在。；适配：导出 render-umap-feature-long.csv（cell_id, umap_1, umap_2, group, feature, value）。
    - 关系证据：methods/cell-type-annotation.md#输出；methods/scp-annotation-projection.md#知识关联检查；methods/scp-annotation-projection.md#输出；templates/scrna-feature-umap-grid/spec.json；templates/scrna-feature-umap-grid/verify/verify.json；运行证据：无
  - [[templates/marker-bubble-dotplot|细胞类型 × 基因气泡点图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：预测类型的 marker 平均表达/阳性比例可整理成点图，检查注释是否合理；模板不重算统计。；前提：avg_expression 与 pct_expressed 由表达矩阵按预测标签计算；缩放方式说明。；group/feature 顺序由课题给出；target_group 只用于排序。；适配：导出 render-dotplot-long.csv（group, feature, avg_expression, pct_expressed, target_group）。
    - 关系证据：methods/cell-type-annotation.md#输出；methods/scp-annotation-projection.md#知识关联检查；methods/scp-annotation-projection.md#输出；templates/marker-bubble-dotplot/spec.json；templates/marker-bubble-dotplot/verify/verify.json；运行证据：无
  - [[templates/cell-prop-flow-bar|细胞比例堆叠流带图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：按样本/条件统计预测类型比例，检查注释组成；模板不做统计检验。；前提：每个 group 的比例归一化到 1；group 为样本/条件，celltype 为预测标签。；比例是描述性；组间差异不能由该图直接推断。；适配：导出 render-cell-proportions.csv（group, celltype, proportion）。
    - 关系证据：methods/cell-type-annotation.md#输出；methods/scp-annotation-projection.md#知识关联检查；methods/scp-annotation-projection.md#输出；templates/cell-prop-flow-bar/spec.json；templates/cell-prop-flow-bar/verify/verify.json；运行证据：无
  - [[templates/stromal-hull-umap|基质亚群功能包络UMAP]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：注释后的精细细胞亚群与高阶功能群（如 mFib/lpFib/iFib）可切换为 variant 红色虚线包络 + 编号质心 UMAP 画风；模板不执行注释。；前提：umap_1/umap_2 与 subcluster 标签来自同一已注释对象；cell_id 唯一。；适配：导出 stromal_umap_cells.csv（cell_id, umap_1, umap_2, subcluster, functional_group）。
    - 关系证据：methods/cell-type-annotation.md#输出；templates/stromal-hull-umap/spec.json；运行证据：无
  - [[templates/tri-panel-stage-umap|三联分群分期患者 UMAP]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：注释后的单细胞/空间蛋白组细胞类型标签可与进展分期、患者 ID 合并导出为 Cancer Discovery 风格三联 UMAP 变体；模板不执行注释。；前提：umap_1/umap_2 与 cell_type、stage、patient_id 来自同一质控后对象；cell_id 唯一。；适配：导出 umap_tripanel_cells.csv（cell_id, umap_1, umap_2, cell_type, stage, patient_id）。
    - 关系证据：methods/cell-type-annotation.md#输出；templates/tri-panel-stage-umap/spec.json；运行证据：无
  - [[templates/split-condition-umap|双条件并排分面亚群 UMAP]]（draft）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：注释后的精细细胞亚群可按组织/实验条件（如 Normal vs Tumor）并排分面展示（灰色全集背景 + 当前条件高亮彩点）；模板不执行注释。；前提：umap_1/umap_2、subcluster 与 condition 来自同一整合注释对象；cell_id 唯一。；适配：导出 split_condition_umap_cells.csv（cell_id, umap_1, umap_2, subcluster, condition）。
    - 关系证据：methods/cell-type-annotation.md#输出；templates/split-condition-umap/spec.json；运行证据：无
  - [[templates/feature-umap-contrast-grid|高对比度连续特征 UMAP 网格]]（draft）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：谱系标志基因表达量或功能模块评分可在单细胞 UMAP 上按高对比度置顶色阶与 Min/Max 色标渲染为多面板网格；模板不执行打分。；前提：坐标与连续特征列来自同一单细胞对象；特征列已完成对数标准化或模块打分。；适配：导出 feature_umap_scores.csv（cell_id, umap_1, umap_2 及多列连续特征/模块得分）。
    - 关系证据：methods/cell-type-annotation.md#输出；templates/feature-umap-contrast-grid/spec.json；运行证据：无
  - [[templates/cycif-feature-umap-strip|多标志物连续蛋白强度 UMAP 条带]]（draft）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：空间蛋白组（CyCIF）或单细胞的多标志物 [0, 1] 归一化强度可按 Cancer Discovery 蓝-灰-红连续色阶条带并排展示。；前提：各标志物列已完成对数转换与 [0, 1] 范围缩放；坐标与强度同源。；适配：导出 cycif_umap_markers.csv（cell_id, umap_1, umap_2 及多标志物归一化强度列）。
    - 关系证据：methods/cell-type-annotation.md#输出；templates/cycif-feature-umap-strip/spec.json；运行证据：无
<!-- facts:end -->

## 用途

把查询数据集的细胞分配到已知或预先定义的细胞类型。可由参考数据集的标签学习（SingleR 等），也可由作者预先定义的 marker→类型映射做手工注释；两条路线都需用 marker 表达、组成和独立方法复核，不能把标签当已验证的生物学身份。

## 原理与选择

参考标签路线用参考数据集的差异基因/标签给 query 打分（SingleR），要求 query/ref 组织、物种、平台和基因标识可比。Marker 路线用一组先验 marker 检查 cluster/细胞的表达并人工指定类型，依赖 marker 特异性和作者判断；它不需要参考数据，但不能自动发现 novel 类型。Seurat label transfer 属于 reference-mapping 家族，不应与 SingleR 或手工注释混为同一算法。

## 来源与实现选择

| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| 参考标签注释：SCP `RunSingleR`（cell/cluster level） | [[methods/scp-annotation-projection]]；`SCP-local/R/SCP-cell_annotation.R` | query/reference Seurat + ref 标签；预测标签/分数 | 2026-11-04 指定公开用例与 direct SingleR 对齐；当前本机缺包，完整原版 SCP 等价未通过 |
| 青光眼 marker 手工注释 | [[methods/scrna-marker-annotation]]；`source/annotation.R` | 预处理对象、作者 marker 列表/`celltype_map`；手动标签 | 原脚本硬编码 marker/映射，未函数化、未验证；不是 SingleR 替代品 |
| 参考图谱映射（Seurat 标签转移） | [[methods/reference-mapping]] | query/reference + 参考标签；预测/分数 | 属参考映射家族；本页不重复实现，也不把它当 SingleR |

## 适用

- 参考路线：有匹配组织/物种、标签可靠的 reference，且 query/ref 共享足够基因。
- Marker 路线：有组织/状态特异的 marker 列表和可解释的 cluster；作者能说明 marker→类型的依据。
- 两条路线都用 marker、组成、独立方法或人工复核交叉检查；novel 类型允许保留“未定”。

## 不适用

- SingleR 没有合适 reference 时不适用；这不等于“无参考就不能注释”，可改用有依据的 marker 路线，但必须明确其主观性和局限。
- 参考/查询组织、物种、平台差异大，或参考标签本身不可靠；novel 类型可能被强行分配到最近标签。
- 只靠 cluster 编号或单个 marker 名字猜类型；把预测标签或手工标签当已验证的生物学身份、分类概率或因果结论。

## 输入

参考路线：query/reference Seurat、`ref_group` 标签列、assay；marker 路线：query Seurat、命名 marker 列表或 `celltype_map`、cluster/细胞标签。两条路线都需同物种、同基因标识和可追踪的细胞身份。

## 怎么做

1. 先选路线：有可靠 reference 时可用 SingleR；没有 reference 但有组织特异 marker 时可用 marker 路线；两者都不可行时不要强行命名。
2. 参考路线：核对参考来源/标签/物种/平台，检查基因交集和数据尺度，运行 SingleR，保留每细胞/每 cluster 分数和 pruned label。
3. Marker 路线：先固定 marker 列表和类型映射，检查 marker 在 cluster/细胞中的表达与特异性；按预先规则分配，记录人工判断和不确定项。
4. 用 UMAP、marker 点图、样本组成和独立方法复核；低置信度/混合群保留“未定/待定”。
5. 注释结果再进入图样；不要让注释反过来证明聚类正确，也不要把手工注释写成自动算法验证。

## 代码

本目录是所选分支的最小调用闭包：复制 `code/`（以及 `runtime.json` 列出的资源）即可在课题环境运行，不再需要完整 `SCP-local`。`bundle` 参数仅为兼容旧调用而接受，函数不会读取；必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verification/*-portability.json`。

- 参考路线：`methods/cell-type-annotation/code/analysis.R:run_cell_type_annotation(srt_query, srt_ref, bundle = NULL, parameters)`。早期缺包记录属于当时环境；`verification/scp-singler-standalone.json` 记录 2026-11-04 的 100 query / 300 reference 公开 pancreas 用例与 direct SingleR 标签、原上游分数表达式相同。完整未修改 SCP 在旧 Seurat API 失败，不声称与它整体等价。2026-11-12 当前本机 Wiki R 4.5.0 配置仍查不到 SingleR；作者选择不安装，本次没有重新运行该分支。历史执行收据、本机当前缺包与未执行分支分别解释。
- Marker 路线：青光眼 `annotation.R` 是硬编码 marker 列表和 `celltype_map` 的课题脚本，保留在 [[methods/scrna-marker-annotation]] 的 `source/`；本轮未函数化、未验证，不提供可执行入口。
- 参考图谱映射见 [[methods/reference-mapping]]；它是另一家族，不因本页 SingleR 未运行而自动可用。

## 输出

参考路线返回注释对象/列表，含 `singler_annotation`、`singler_score` 等；2026-11-04 收据只覆盖上节指定公开用例。marker 路线应输出 cell/cluster、label、依据 marker 和不确定标记，尚无本页 marker 路线验证；不得把参考标签或手工标签直接复制成“自动注释结果”。

## 知识关联检查

2026-10-23 检查了 UMAP 分组、特征 UMAP、气泡点图和细胞比例模板。预测标签或手工标签都可着色 UMAP、检查 marker、展示组成；均为 adaptable，模板不执行注释。没有 direct：模板不读 Seurat 注释结果。来源页 [[methods/scrna-marker-annotation]] 提供 marker 手工注释原始脚本，[[methods/scp-annotation-projection]] 提供 SCP SingleR/投影来源；双向链接已建立。注释与参考映射的区别见 [[methods/reference-mapping]]。


### scop 候选来源（未运行）

另有 [[methods/scop-analysis-guide|scop 0.9.2 候选来源]]：`RunSingleR`、`RunCellTypist`、`RunScmap`、`RunKNNPredict`、`RunSciBet`。核对参考物种、基因 ID、标签与查询/参考独立性；相似度不是校准概率。 本机尚未执行，不继承本页 SCP/其他实现的验证；未修改本页实现或统计逻辑。

## 使用记录

2026-10-23：核对 SCP RunSingleR、青光眼 marker 注释脚本与本机依赖；SingleR 缺失、marker 脚本未函数化，均未写成已验证实现。

## 本机组学课题来源增量（2026-11-02）

marker 注释、SingleR 调用与图形来源；细胞标签、参考库与手工判断需按原对象核对。 来源清单见 [[methods/uc-ptm-source-catalog]]、[[methods/asthma-lactylation-source-catalog]]；具体实现与原始路径对照见 [[methods/local-omics-analysis-guide]]，图形调用见 [[methods/local-omics-visualization-guide]]。本段只补知识与来源，不更改现有实现、运行/独立性收据、状态或作者确认。

<!-- user:start -->
<!-- user:end -->
