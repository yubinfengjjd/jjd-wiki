---
type: method
id: cell-cell-communication
title: 细胞通讯与配受体网络分析
status: ready
tags:
- single-cell
- transcriptomics
data_domains:
- single-cell
- spatial-omics
inputs:
- scrna-annotated-cells
outputs:
- cellchat-lr-table
- celltype-gene-expression
render_bridges: []
source:
  kind: written
license: none
cite:
- Jin S, et al. Inference and analysis of cell-cell communication using CellChat.
  Nature Communications, 2021.
- 'Efremova M, et al. CellPhoneDB: inferring cell-cell communication from combined
  expression of multi-subunit ligand-receptor complexes. Nature Protocols, 2020.'
- 'Browaeys R, et al. NicheNet: modeling intercellular communication by linking ligands
  to target genes. Nature Methods, 2020.'
favorite: false
method_kind: analysis
purposes:
- 细胞通讯与微环境
summary: 基于已注释单细胞或空间转录组数据推断细胞亚群间的配体-受体互作概率、信号通路层级强度及发送/接收角色，输出标准配受体互作表与平均表达表；本库尚未封装独立可执行实现。
data_contract:
  input: 已注释的单细胞 Seurat/AnnData 或空间转录组对象（scrna-annotated-cells），含标准化表达矩阵与明确的 cell_type
    分组；多组比较需显式 condition 列。
  output: cellchat-lr-table（source, target, ligand, receptor, pathway_name, prob,
    pval, group）与 celltype-gene-expression（gene, cell_type, expression, role）。
keywords:
- CellChat
- CellPhoneDB
- NicheNet
- ligand-receptor
- cell-cell communication
- paracrine signaling
- 细胞通讯
- 配受体网络
figure_relations:
- figure: templates/cellchat-circos-multi
  compatibility: direct
  reason: 方法输出的 cellchat-lr-table 与 celltype-gene-expression 直接对应多轨环形图模板接口契约；模板仅负责多轨渲染，不重算通讯概率或置换检验。
  prerequisites:
  - source、target 与 cell_type 标签跨表一致；建议按 prob 与 pval 筛选核心显著通路后控制基因总数。
  - 多条件比较须显式保留 group 列，不能将未分层的合并强度直接等同于组间统计差异。
  adaptation: ''
  evidence:
  - methods/cell-cell-communication.md#输出
  - templates/cellchat-circos-multi/spec.json
  - templates/cellchat-circos-multi/verify/verify.json
  - interfaces/cellchat-lr-table.md
  - interfaces/celltype-gene-expression.md
  verification:
    state: not_run
    scope: 仅核对 cellchat-lr-table 与 celltype-gene-expression 接口契约及模板 spec.json，尚未执行真实分析→出图端到端联调。
    evidence: []
- figure: templates/lr-bubble-matrix
  compatibility: adaptable
  reason: 有向细胞对（source->target）与配体-受体对的 CellChat/CellPhoneDB 互作概率可作为 default 主推气泡矩阵展示；模板不重算概率。
  prerequisites:
  - 同一统计阈值筛出的有向细胞对与 LR 对；缺失组合保持空位而不填零。
  adaptation: 导出 lr_bubble_matrix.csv（pair_label 或 source+target, interaction, prob,
    可选 pval）。
  evidence:
  - methods/cell-cell-communication.md#输出
  - templates/lr-bubble-matrix/spec.json
  verification:
    state: not_run
    scope: 2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/cellchat-count-heatmap
  compatibility: adaptable
  reason: 全部有向发送者×接收者亚群间显著互作计数矩阵及边际总和柱图可切换为 variant 计数热图；模板不做置换检验。
  prerequisites:
  - 所有细胞对采用同一置换检验显著性阈值统计 count；未测组合保留 NA。
  adaptation: 导出 interaction_counts.csv（SOURCE, TARGET, count）。
  evidence:
  - methods/cell-cell-communication.md#输出
  - templates/cellchat-count-heatmap/spec.json
  verification:
    state: not_run
    scope: 2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/lr-bipartite-bubble
  compatibility: adaptable
  reason: 两类细胞群间的多对配体-受体双轴连线与两端平均表达量（着色）/表达阳性细胞比例 0–100%（气泡尺寸）可切换为 variant 双轴连线图；模板不重算
    CellPhoneDB p 值。
  prerequisites:
  - 须明确发送群（配体端）与接收群（受体端），并从同一单细胞表达矩阵分别汇总两群内各基因的平均表达量及 0–100% 阳性细胞比例（分母为对应细胞群总细胞数）。
  - 连线仅表示数据库配对与表达汇总，不代表物理结合或因果调控。
  adaptation: 从配受体结果结合单细胞表达矩阵导出 lr_bipartite_pairs.csv（ligand, receptor, ligand_expr,
    ligand_pct, receptor_expr, receptor_pct）。
  evidence:
  - methods/cell-cell-communication.md#输出
  - templates/lr-bipartite-bubble/spec.json
  verification:
    state: not_run
    scope: 2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/cellchat-signaling-ring
  compatibility: adaptable
  reason: 特定信号通路（如 VEGF）在全图谱亚群环形目录间的有向通讯弧线（含孤立目录节点）可切换为 variant 环形网络图。
  prerequisites:
  - 环形目录节点需包含全图谱所有比较亚群，避免因孤立节点被过滤而改变拓扑外观。
  adaptation: 导出 ring_nodes.csv（node, compartment, color, is_hub）与 ring_edges.csv（from,
    to, weight）。
  evidence:
  - methods/cell-cell-communication.md#输出
  - templates/cellchat-signaling-ring/spec.json
  verification:
    state: not_run
    scope: 2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
next_steps:
- direction: 方向 1：细胞通讯多轨环形图与配受体弦图可视化
  when: 已筛选显著配受体通路并整理各亚群配受体标准化表达，准备展示整体通讯网络与表达热图轨时
  analysis_templates:
  - recipes/figureya-310cpdbchordgramv2
  intermediate_interface: cellchat-lr-table
  viz_templates:
  - templates/cellchat-circos-multi
  - templates/scp-flow-chord
  - templates/lr-bubble-matrix
  - templates/cellchat-count-heatmap
  - templates/lr-bipartite-bubble
  - templates/cellchat-signaling-ring
- direction: 方向 2：接收方亚群下游差异表达与通路响应验证
  when: 识别出关键配受体信号轴后，检验接收方细胞亚群内下游靶基因或通路是否发生同步差异改变时
  analysis_templates:
  - methods/differential-expression
  - methods/gene-set-enrichment
  intermediate_interface: deg-result-table
  viz_templates:
  - templates/scp-de-volcano
  - templates/marker-bubble-dotplot
- direction: 方向 3：关键信号轴与拟时序或 Bulk 免疫微环境/预后验证
  when: 追踪通讯信号沿细胞分化轨迹的动态变化，或将核心配受体基因投射到 Bulk 临床队列评估免疫浸润与生存预后时
  analysis_templates:
  - methods/trajectory-inference
  - methods/immune-infiltration-tme
  - methods/survival-prognosis-analysis
  intermediate_interface: candidate-biomarker-list
  viz_templates:
  - templates/km-survival-curve
  - templates/subgroup-hazard-forest
---
# 细胞通讯与配受体网络分析

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：仅供个人研究参考
- 引用：Jin S, et al. Inference and analysis of cell-cell communication using CellChat. Nature Communications, 2021.；Efremova M, et al. CellPhoneDB: inferring cell-cell communication from combined expression of multi-subunit ligand-receptor complexes. Nature Protocols, 2020.；Browaeys R, et al. NicheNet: modeling intercellular communication by linking ligands to target genes. Nature Methods, 2020.
- 标签：single-cell、transcriptomics
- 分析用途：细胞通讯与微环境
- 输入接口：[[interfaces/scrna-annotated-cells|已注释单细胞元数据与降维表]]
- 输出接口：[[interfaces/cellchat-lr-table|细胞通讯配受体互作表]] · [[interfaces/celltype-gene-expression|细胞类型×基因平均表达表]]
- 接口结构匹配的图（仅结构候选，未核实语义）：[[templates/cellchat-circos-multi|细胞通讯多轨环形图（配受体互作+表达热图+柱状轨）]]（ready）
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无
- 下一步分析导航（Step N → Step N+1）：
  - **方向 1：细胞通讯多轨环形图与配受体弦图可视化**（触发条件：已筛选显著配受体通路并整理各亚群配受体标准化表达，准备展示整体通讯网络与表达热图轨时；中间表：cellchat-lr-table；分析模版：recipes/figureya-310cpdbchordgramv2；可视化模版：templates/cellchat-circos-multi、templates/scp-flow-chord、templates/lr-bubble-matrix、templates/cellchat-count-heatmap、templates/lr-bipartite-bubble、templates/cellchat-signaling-ring）
  - **方向 2：接收方亚群下游差异表达与通路响应验证**（触发条件：识别出关键配受体信号轴后，检验接收方细胞亚群内下游靶基因或通路是否发生同步差异改变时；中间表：deg-result-table；分析模版：methods/differential-expression、methods/gene-set-enrichment；可视化模版：templates/scp-de-volcano、templates/marker-bubble-dotplot）
  - **方向 3：关键信号轴与拟时序或 Bulk 免疫微环境/预后验证**（触发条件：追踪通讯信号沿细胞分化轨迹的动态变化，或将核心配受体基因投射到 Bulk 临床队列评估免疫浸润与生存预后时；中间表：candidate-biomarker-list；分析模版：methods/trajectory-inference、methods/immune-infiltration-tme、methods/survival-prognosis-analysis；可视化模版：templates/km-survival-curve、templates/subgroup-hazard-forest）

- 方法配图关系（语义审查）：
  - [[templates/cellchat-circos-multi|细胞通讯多轨环形图（配受体互作+表达热图+柱状轨）]]（ready）：直接可接（direct）；调用验证：not_run；范围：仅核对 cellchat-lr-table 与 celltype-gene-expression 接口契约及模板 spec.json，尚未执行真实分析→出图端到端联调。
    - 依据：方法输出的 cellchat-lr-table 与 celltype-gene-expression 直接对应多轨环形图模板接口契约；模板仅负责多轨渲染，不重算通讯概率或置换检验。；前提：source、target 与 cell_type 标签跨表一致；建议按 prob 与 pval 筛选核心显著通路后控制基因总数。；多条件比较须显式保留 group 列，不能将未分层的合并强度直接等同于组间统计差异。；适配：无格式适配声明
    - 关系证据：methods/cell-cell-communication.md#输出；templates/cellchat-circos-multi/spec.json；templates/cellchat-circos-multi/verify/verify.json；interfaces/cellchat-lr-table.md；interfaces/celltype-gene-expression.md；运行证据：无
  - [[templates/lr-bubble-matrix|配受体互作概率气泡矩阵]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：有向细胞对（source->target）与配体-受体对的 CellChat/CellPhoneDB 互作概率可作为 default 主推气泡矩阵展示；模板不重算概率。；前提：同一统计阈值筛出的有向细胞对与 LR 对；缺失组合保持空位而不填零。；适配：导出 lr_bubble_matrix.csv（pair_label 或 source+target, interaction, prob, 可选 pval）。
    - 关系证据：methods/cell-cell-communication.md#输出；templates/lr-bubble-matrix/spec.json；运行证据：无
  - [[templates/cellchat-count-heatmap|细胞通讯计数柱状热图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：全部有向发送者×接收者亚群间显著互作计数矩阵及边际总和柱图可切换为 variant 计数热图；模板不做置换检验。；前提：所有细胞对采用同一置换检验显著性阈值统计 count；未测组合保留 NA。；适配：导出 interaction_counts.csv（SOURCE, TARGET, count）。
    - 关系证据：methods/cell-cell-communication.md#输出；templates/cellchat-count-heatmap/spec.json；运行证据：无
  - [[templates/lr-bipartite-bubble|配受体双轴连线气泡图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：两类细胞群间的多对配体-受体双轴连线与两端平均表达量（着色）/表达阳性细胞比例 0–100%（气泡尺寸）可切换为 variant 双轴连线图；模板不重算 CellPhoneDB p 值。；前提：须明确发送群（配体端）与接收群（受体端），并从同一单细胞表达矩阵分别汇总两群内各基因的平均表达量及 0–100% 阳性细胞比例（分母为对应细胞群总细胞数）。；连线仅表示数据库配对与表达汇总，不代表物理结合或因果调控。；适配：从配受体结果结合单细胞表达矩阵导出 lr_bipartite_pairs.csv（ligand, receptor, ligand_expr, ligand_pct, receptor_expr, receptor_pct）。
    - 关系证据：methods/cell-cell-communication.md#输出；templates/lr-bipartite-bubble/spec.json；运行证据：无
  - [[templates/cellchat-signaling-ring|通路定向细胞通讯弦图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：特定信号通路（如 VEGF）在全图谱亚群环形目录间的有向通讯弧线（含孤立目录节点）可切换为 variant 环形网络图。；前提：环形目录节点需包含全图谱所有比较亚群，避免因孤立节点被过滤而改变拓扑外观。；适配：导出 ring_nodes.csv（node, compartment, color, is_hub）与 ring_edges.csv（from, to, weight）。
    - 关系证据：methods/cell-cell-communication.md#输出；templates/cellchat-signaling-ring/spec.json；运行证据：无
<!-- facts:end -->

## 用途

基于已注释的单细胞转录组（scRNA-seq）或空间转录组数据，结合先验配体-受体（L-R）复合物及辅助因子数据库，推断细胞亚群之间的旁分泌、自分泌与接触式信号通讯强度，并识别疾病与对照组之间发生重塑的核心信号通路。

## 适用

- 已完成质量控制、批次校正与细胞类型注释的单细胞或空间转录组表达矩阵，且目标亚群细胞数量充足。
- 物种、基因符号（Human / Mouse）与所选配受体数据库（如 CellChatDB、CellPhoneDB）严格匹配。
- 比较不同生理或病理条件（如疾病 vs 对照）时，各条件均具备对应细胞亚群或已明确缺失亚群的处理规则。

## 不适用

- 未完成稳定细胞注释或仅含极少细胞（如单亚群 <10 细胞）时强行估算通讯概率。
- 把 mRNA 水平的共表达互作推断直接等同于物理蛋白结合、空间真实邻接或因果调控证据（尤须结合空间坐标或功能实验验证）。
- 混用不同物种基因标识或将细胞级置换检验 p 值误当患者样本级独立显著性结论。

## 输入

读取标准输入接口 [[interfaces/scrna-annotated-cells|已注释单细胞元数据与降维表]]（或空间转录组等价注释对象），需包含标准化表达矩阵（log-normalized counts）、明确的 `cell_type` 分组列及实验条件 `group`（多组比较时）。

## 怎么做

1. **统一物种与数据库**：根据研究物种加载对应 CellChatDB / CellPhoneDB 数据库，筛选表达矩阵中可匹配的配受体及辅助亚基基因。
2. **识别过表达配受体与互作概率**：按亚群计算配体、受体的平均/截尾表达量及过表达检验，进而估算每对发送者（`source`）→ 接收者（`target`）的互作概率 `prob` 与置换检验 `pval`。
3. **聚合通路层级与多组比较**：将配受体对汇总至 `pathway_name` 层级；若有多个 `group`（如 Normal vs Disease），须先保持细胞类型词表对齐再分别推断并对比差异通路。
4. **导出标准结果表**：整理显著互作记录为 `cellchat-lr-table`，并计算配受体基因在各细胞类型中的 Z-score 标准化平均表达表 `celltype-gene-expression`，供多轨环形图或其他下游分析消费。

## 代码

本锚点页当前尚未封装独立可运行的本库 R/Python 分析模块（状态为 `not_run`）。实际课题分析时，请参考配套源码配方 [[recipes/figureya-310cpdbchordgramv2|细胞通讯配体受体弦图]]（CellPhoneDB + Seurat 差异通讯流向），或在课题 R 环境中调用 CellChat / CellPhoneDB 官方工作流后按输出契约导出 CSV 接入 [[templates/cellchat-circos-multi|细胞通讯多轨环形图]]。

## 输出

- [[interfaces/cellchat-lr-table|细胞通讯配受体互作表]]：含 `source`、`target`、`ligand`、`receptor`、`pathway_name`、`prob`、`pval` 及可选 `group` 列。
- [[interfaces/celltype-gene-expression|细胞类型×基因平均表达表]]：含 `gene`、`cell_type`、`expression`（如跨细胞类型的 Z-score 标准化表达）及可选 `role`（`ligand` / `receptor`）。

## 知识关联检查

已核对上游注释方法 [[methods/cell-type-annotation]] 与下游多轨可视化模板 [[templates/cellchat-circos-multi]]：模板 `spec.json` 声明读取 `cellchat-lr-table`（必需）与 `celltype-gene-expression`（可选），与本方法 `outputs` 完全对齐，故登记为 `direct`（当前 `verification.state: not_run`，尚未执行真实课题端到端分析→出图联调）。与 [[templates/scp-flow-chord]] 的区别在于后者仅展示二维计数流向而非配受体基因级网络。

## 使用记录

<!-- user:start -->
<!-- user:end -->
