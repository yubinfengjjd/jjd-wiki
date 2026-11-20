---
type: method
id: coexpression-ppi-network
title: 共表达网络（WGCNA）与分子互作网络分析
status: ready
tags:
- transcriptomics
- network-pharmacology
data_domains:
- bulk-transcriptomics
- multi-omics
inputs: []
outputs:
- candidate-biomarker-list
- highlight-gene-sets
render_bridges: []
source:
  kind: written
license: none
cite:
- 'Langfelder P, Horvath S. WGCNA: an R package for weighted correlation network analysis.
  BMC Bioinformatics, 2008.'
- 'Szklarczyk D, et al. The STRING database in 2023: protein-protein association networks
  and functional enrichment analyses. Nucleic Acids Research, 2023.'
favorite: false
method_kind: analysis
purposes:
- 降维与聚类
- 细胞通讯与微环境
summary: 基于标准化表达谱构建加权基因共表达网络（WGCNA）识别性状关联模块，并结合 STRING/PPI 蛋白互作证据挖掘核心模块与 Hub 候选基因集合，输出候选生物标志物列表与高亮基因集；本库尚未封装独立可执行实现。
data_contract:
  input: 经过归一化与批次核查的 Bulk/多组学表达矩阵（建议样本量 >= 15）与明确临床性状矩阵，或显著差异基因集。
  output: candidate-biomarker-list（基因标志物、模块归属、MM/GS 相关性或网络度值）与 highlight-gene-sets（模块/枢纽基因集定义）。
keywords:
- WGCNA
- co-expression
- PPI
- STRING
- MCODE
- hub gene
- 共表达网络
- 蛋白互作网络
figure_relations:
- figure: templates/coexpr-hub-radial-network
  compatibility: adaptable
  reason: 标准化表达谱构建的 Pearson/WGCNA 共表达网络节点坐标、边表与枢纽基因一步邻域标记可直接渲染为 default 焦橙核心放射网络图；模板不拟合相关矩阵。
  prerequisites:
  - 节点与边来自同一相关阈值过滤后的连通分量；明确相关性阈值（如 r >= 0.6）。
  adaptation: 导出 network_nodes.csv（gene_symbol, x, y, in_s100b_1step, is_key_label）与
    network_edges.csv（from, to, weight）。
  evidence:
  - methods/coexpression-ppi-network.md#输出
  - templates/coexpr-hub-radial-network/spec.json
  verification:
    state: not_run
    scope: 2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/ordered-module-track-curve
  compatibility: adaptable
  reason: 共表达模块（如 S100B 模块）在按分期与活性排序的微区域/样本上的平均表达轨迹可与底部组织学分期色带组合展示。
  prerequisites:
  - mean_log2_norm 为模块内基因在各样本上的平均对数归一化表达量。
  adaptation: 导出 ordered_module_expression.csv（sample_id, site, mean_log2_norm）。
  evidence:
  - methods/coexpression-ppi-network.md#输出
  - templates/ordered-module-track-curve/spec.json
  verification:
    state: not_run
    scope: 2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
next_steps:
- direction: 方向 1：对核心模块基因做通路富集与功能注释
  when: 识别出与关键临床性状显著相关的 WGCNA 模块或高连通度 PPI 子模块时
  analysis_templates:
  - methods/gene-set-enrichment
  intermediate_interface: pathway-score-table
  viz_templates:
  - templates/pathway-stat-violin
- direction: 方向 2：检验模块枢纽基因的预后价值与风险建模
  when: 将网络筛选出的核心候选基因纳入单/多因素 Cox 生存分析或预后列线图评估时
  analysis_templates:
  - methods/survival-prognosis-analysis
  - methods/regression-resampling-evaluation
  intermediate_interface: survival-time-event-group
  viz_templates:
  - templates/km-survival-curve
  - templates/subgroup-hazard-forest
- direction: 方向 3：关联药物靶点与 CMap 候选化合物重定位
  when: 围绕核心基因模块或调控网络检索潜在靶向药物或小分子逆转特征时
  analysis_templates:
  - methods/drug-sensitivity-repositioning
  intermediate_interface: subgroup-effect-table
  viz_templates: []
---
# 共表达网络（WGCNA）与分子互作网络分析

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：仅供个人研究参考
- 引用：Langfelder P, Horvath S. WGCNA: an R package for weighted correlation network analysis. BMC Bioinformatics, 2008.；Szklarczyk D, et al. The STRING database in 2023: protein-protein association networks and functional enrichment analyses. Nucleic Acids Research, 2023.
- 标签：transcriptomics、network-pharmacology
- 分析用途：降维与聚类、细胞通讯与微环境
- 输入接口：未声明
- 输出接口：[[interfaces/candidate-biomarker-list|多算法筛选候选特征基因表]] · [[interfaces/highlight-gene-sets|待标注基因与所属基因集]]
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无
- 下一步分析导航（Step N → Step N+1）：
  - **方向 1：对核心模块基因做通路富集与功能注释**（触发条件：识别出与关键临床性状显著相关的 WGCNA 模块或高连通度 PPI 子模块时；中间表：pathway-score-table；分析模版：methods/gene-set-enrichment；可视化模版：templates/pathway-stat-violin）
  - **方向 2：检验模块枢纽基因的预后价值与风险建模**（触发条件：将网络筛选出的核心候选基因纳入单/多因素 Cox 生存分析或预后列线图评估时；中间表：survival-time-event-group；分析模版：methods/survival-prognosis-analysis、methods/regression-resampling-evaluation；可视化模版：templates/km-survival-curve、templates/subgroup-hazard-forest）
  - **方向 3：关联药物靶点与 CMap 候选化合物重定位**（触发条件：围绕核心基因模块或调控网络检索潜在靶向药物或小分子逆转特征时；中间表：subgroup-effect-table；分析模版：methods/drug-sensitivity-repositioning；可视化模版：无）

- 方法配图关系（语义审查）：
  - [[templates/coexpr-hub-radial-network|枢纽基因共表达放射网络图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：标准化表达谱构建的 Pearson/WGCNA 共表达网络节点坐标、边表与枢纽基因一步邻域标记可直接渲染为 default 焦橙核心放射网络图；模板不拟合相关矩阵。；前提：节点与边来自同一相关阈值过滤后的连通分量；明确相关性阈值（如 r >= 0.6）。；适配：导出 network_nodes.csv（gene_symbol, x, y, in_s100b_1step, is_key_label）与 network_edges.csv（from, to, weight）。
    - 关系证据：methods/coexpression-ppi-network.md#输出；templates/coexpr-hub-radial-network/spec.json；运行证据：无
  - [[templates/ordered-module-track-curve|排序样本共表达模块曲线与分期色带图]]（draft）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-20 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：共表达模块（如 S100B 模块）在按分期与活性排序的微区域/样本上的平均表达轨迹可与底部组织学分期色带组合展示。；前提：mean_log2_norm 为模块内基因在各样本上的平均对数归一化表达量。；适配：导出 ordered_module_expression.csv（sample_id, site, mean_log2_norm）。
    - 关系证据：methods/coexpression-ppi-network.md#输出；templates/ordered-module-track-curve/spec.json；运行证据：无
<!-- facts:end -->

## 用途

从系统生物学视角识别协同变化的基因共表达模块（WGCNA）及其与临床/表型特征的关联，或基于 STRING 等先验蛋白互作网络提取功能紧密的互作子模块与核心调控节点（Hub Genes）。

## 适用

- 拥有足够独立样本量（WGCNA 通常要求 >= 15 例样本）的标准化表达矩阵与数值型/二分类临床性状矩阵。
- 从差异表达、多组学筛选结果出发结合 STRING 互作证据评分筛选核心模块与互作关系图谱。

## 不适用

- **极小样本运行无尺度网络**：样本量过少导致相关系数极度不稳定，软阈值强行拟合伪无尺度拓扑。
- **把表达共线或数据库共现等同于直接物理结合或因果调控**。
- **未经过多组交叉验证仅凭单队列度值（Degree）宣称临床金标准标志物**。

## 输入

标准化且过滤低表达/低方差基因的表达矩阵（配对性状表），或明确过滤阈值后的候选基因列表。

## 怎么做

1. **样本质控与基因过滤**：剔除离群样本（样本聚类树检查），按方差或 MAD 筛选前 25%–50% 高变异基因降低噪声。
2. **无尺度软阈值选择与模块划分**：选取满足无尺度拓扑拟合度 $R^2 \ge 0.85$ 且保持平均连通度的最小软阈值 $\beta$，构建拓扑重叠矩阵（TOM）与动态剪切树模块，并关联性状计算 Module Eigengene 相关性。
3. **PPI 子网络挖掘与枢纽筛选**：结合 STRING 综合得分阈值筛选高置信边集，结合模块内连通度（kME/MM）与 Trait GS 联合定位候选标志物，并导出标准基因列表供下游验证。

## 代码

本锚点页当前尚未封装独立可运行的本库 R/Python 分析模块。请参考下方的 FigureYa L1 参考源码配方（如 `figureya-17wgcna-heatmap`、`figureya-53ppimodule`、`figureya-147interaction`、`figureya-147plus-string`、`figureya-153ccgraph`）获取 WGCNA 与 STRING/PPI 网络挖掘实现。

## 输出

关联 [[interfaces/candidate-biomarker-list|核心候选标志物列表]] 与 [[interfaces/highlight-gene-sets|高亮基因集]]，用于下游功能富集、生存建模或靶向药物分析。

## 参数

- `power`（软阈值 $\beta$）与 `networkType`（`signed` / `unsigned`）。
- `minModuleSize`、`mergeCutHeight`：模块最小基因数与相似模块合并阈值。
- `string_score_cutoff`：PPI 网络过滤的高置信度互作阈值（如 `>= 0.7`）。

## 上一步 / 下一步

- 上一步可由 [[methods/bulk-expression-preprocessing]] 或 [[methods/differential-expression]] 接入；下一步可跳转 [[methods/gene-set-enrichment]]、[[methods/survival-prognosis-analysis]] 或 [[methods/drug-sensitivity-repositioning]]。

## 知识关联检查

已核对下游方法 [[methods/gene-set-enrichment]]、[[methods/survival-prognosis-analysis]] 与 [[methods/drug-sensitivity-repositioning]] 的输入契约；本方法输出 [[interfaces/candidate-biomarker-list]] 与 [[interfaces/highlight-gene-sets]]，无未验证跨模块自动执行声明。

## 使用记录

<!-- user:start -->
<!-- user:end -->
