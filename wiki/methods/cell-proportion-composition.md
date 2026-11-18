---
type: method
id: cell-proportion-composition
title: 细胞亚群组成比例与流向分析
status: ready
tags:
- single-cell
- experimental-statistics
data_domains:
- single-cell
inputs:
- scrna-annotated-cells
outputs:
- cell-proportion-stats
render_bridges:
- interface: render-cell-proportions
  from_output: cell-proportion-stats
  extractor_note: 按分组 group 与细胞类型 celltype 汇总细胞占比并归一化使每组比例之和为 1，输出 group、celltype、proportion
    三列。
  unit: 分组 × 细胞类型
- interface: render-cell-metadata
  from_output: scrna-annotated-cells
  extractor_note: 从已注释单细胞对象提取每个细胞的分组与亚群归属（cell, group, stat），供饼图、玫瑰图、计数柱图与堆叠面积/趋势图按细胞计数聚合。
  unit: 单细胞
- interface: render-cell-linkage
  from_output: scrna-annotated-cells
  extractor_note: 将单细胞在多个分类维度（如样本分组、聚类簇、注释类型或功能状态）的映射展开为长表（cell, dimension, category,
    dimension_order），供桑基图与和弦图绘制流向。
  unit: 单细胞 × 分类维度
source:
  kind: written
license: none
cite:
- Zhang L, et al. Lineage tracking reveals dynamic relationships of T cells in colorectal
  cancer. Nature, 2018.
- 'Phipson B, et al. propeller: testing for differences in cell type proportions in
  single cell data. Bioinformatics, 2022.'
- Buttner M, et al. scCODA is a Bayesian model for compositional single-cell data
  analysis. Nature Communications, 2021.
favorite: false
method_kind: analysis
purposes:
- 注释与参考映射
- 细胞通讯与微环境
summary: 统计各样本或临床分组的细胞亚群计数、相对占比、Ro/e 组织偏好与样本级比例差异检验；严格区分描述性细胞汇总与以样本为独立单位的成分统计推断，并通过显式渲染桥接对接
  10 类组成/流向模板。
data_contract:
  input: 已注释的单细胞元数据表（scrna-annotated-cells），必须含可追踪的 sample_id、条件 group 与 cell_type。
  output: 样本×细胞类型组成统计表 cell-proportion-stats（sample_id, group, cell_type, count, proportion,
    roe_value, p_adj）。
keywords:
- cell proportion
- composition
- Ro/e
- propeller
- scCODA
- Sankey
- chord
- 细胞比例
- 组织偏好
- 组成分析
figure_relations:
- figure: templates/cell-prop-flow-bar
  compatibility: adaptable
  reason: 按样本或临床分组汇总细胞类型占比后，可导出 render-cell-proportions 绘制堆叠流带柱图；流带仅作视觉连接。
  prerequisites:
  - 明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。
  - 成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。
  adaptation: 从 cell-proportion-stats 汇总并归一化每组占比为 1，导出 render-cell-proportions.csv（group,
    celltype, proportion）。
  evidence:
  - methods/cell-proportion-composition.md#输出
  - templates/cell-prop-flow-bar/spec.json
  - templates/cell-prop-flow-bar/verify/verify.json
  verification:
    state: not_run
    scope: 仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/scp-comp-ring
  compatibility: adaptable
  reason: 分组细胞比例表可导出 render-cell-proportions 复用同心环占比模板；模板不做统计检验。
  prerequisites:
  - 明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。
  - 成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。
  adaptation: 按分组归一化占比后导出 render-cell-proportions.csv（group, celltype, proportion）。
  evidence:
  - methods/cell-proportion-composition.md#输出
  - templates/scp-comp-ring/spec.json
  - templates/scp-comp-ring/verify/verify.json
  verification:
    state: not_run
    scope: 仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/scp-comp-pie
  compatibility: adaptable
  reason: 单细胞元数据中的分组与细胞类型标签可整理为 render-cell-metadata 驱动饼图。
  prerequisites:
  - 明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。
  - 成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。
  adaptation: 从 scrna-annotated-cells 提取 cell, group, stat 导出 render-cell-metadata.csv。
  evidence:
  - methods/cell-proportion-composition.md#输出
  - templates/scp-comp-pie/spec.json
  - templates/scp-comp-pie/verify/verify.json
  verification:
    state: not_run
    scope: 仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/scp-comp-rose
  compatibility: adaptable
  reason: 单细胞分组与亚群类别表可导出 render-cell-metadata 绘制玫瑰图。
  prerequisites:
  - 明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。
  - 成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。
  adaptation: 从 scrna-annotated-cells 提取 cell, group, stat 导出 render-cell-metadata.csv。
  evidence:
  - methods/cell-proportion-composition.md#输出
  - templates/scp-comp-rose/spec.json
  - templates/scp-comp-rose/verify/verify.json
  verification:
    state: not_run
    scope: 仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/scp-comp-trend
  compatibility: adaptable
  reason: 按样本/时间阶段排序的细胞构成可整理为 render-cell-metadata 绘制趋势连线图。
  prerequisites:
  - 明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。
  - 成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。
  adaptation: 整理有序分组与类别到 render-cell-metadata.csv（cell, group, stat）。
  evidence:
  - methods/cell-proportion-composition.md#输出
  - templates/scp-comp-trend/spec.json
  - templates/scp-comp-trend/verify/verify.json
  verification:
    state: not_run
    scope: 仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/scp-comp-area
  compatibility: adaptable
  reason: 多分组细胞构成演化可导出 render-cell-metadata 复用堆积面积图。
  prerequisites:
  - 明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。
  - 成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。
  adaptation: 整理有序分组与类别到 render-cell-metadata.csv（cell, group, stat）。
  evidence:
  - methods/cell-proportion-composition.md#输出
  - templates/scp-comp-area/spec.json
  - templates/scp-comp-area/verify/verify.json
  verification:
    state: not_run
    scope: 仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/scp-comp-dot
  compatibility: adaptable
  reason: 分组与亚群构成比例可用点图展示，需导出 render-cell-metadata；点大小仅反映统计汇总。
  prerequisites:
  - 明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。
  - 成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。
  adaptation: 整理 cell, group, stat 到 render-cell-metadata.csv。
  evidence:
  - methods/cell-proportion-composition.md#输出
  - templates/scp-comp-dot/spec.json
  - templates/scp-comp-dot/verify/verify.json
  verification:
    state: not_run
    scope: 仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/scp-count-bar
  compatibility: adaptable
  reason: 各分组或亚群绝对细胞计数可直接由 render-cell-metadata 汇总柱图展示。
  prerequisites:
  - 明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。
  - 成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。
  adaptation: 从 scrna-annotated-cells 导出 render-cell-metadata.csv（cell, group, stat）。
  evidence:
  - methods/cell-proportion-composition.md#输出
  - templates/scp-count-bar/spec.json
  - templates/scp-count-bar/verify/verify.json
  verification:
    state: not_run
    scope: 仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/scp-flow-sankey
  compatibility: adaptable
  reason: 多层级细胞标签（分组→簇→细胞类型）的映射流向可整理为 render-cell-linkage 绘制桑基图。
  prerequisites:
  - 明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。
  - 成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。
  adaptation: 将多维度分类列按细胞展开为 render-cell-linkage.csv（cell, dimension, category, dimension_order）。
  evidence:
  - methods/cell-proportion-composition.md#输出
  - templates/scp-flow-sankey/spec.json
  - templates/scp-flow-sankey/verify/verify.json
  verification:
    state: not_run
    scope: 仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/scp-flow-chord
  compatibility: adaptable
  reason: 跨维度或组间细胞类别关联计数可导出 render-cell-linkage 绘制流向和弦图。
  prerequisites:
  - 明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。
  - 成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。
  adaptation: 将二维或跨维度分类映射导出为 render-cell-linkage.csv（cell, dimension, category, dimension_order）。
  evidence:
  - methods/cell-proportion-composition.md#输出
  - templates/scp-flow-chord/spec.json
  - templates/scp-flow-chord/verify/verify.json
  verification:
    state: not_run
    scope: 仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    evidence: []
next_steps:
- direction: 方向 1：异常富集亚群的差异表达与功能打分深挖
  when: 通过 Ro/e 或样本级比例检验锁定疾病组显著扩张/耗竭的细胞亚群后，解析其转录组程序改变时
  analysis_templates:
  - methods/differential-expression
  - methods/gene-set-scoring
  intermediate_interface: deg-result-table
  viz_templates:
  - templates/scp-de-volcano
  - templates/pathway-stat-violin
- direction: 方向 2：组成变化亚群的微环境配受体通讯分析
  when: 探索比例升高或降低的关键细胞亚群与其他微环境细胞之间的信号交互重塑时
  analysis_templates:
  - methods/cell-cell-communication
  intermediate_interface: cellchat-lr-table
  viz_templates:
  - templates/cellchat-circos-multi
  - templates/scp-flow-chord
- direction: 方向 3：关键亚群特征在 Bulk 队列免疫浸润与临床预后中的验证
  when: 将单细胞中鉴定的关键浸润亚群特征（Marker 集）推广至 TCGA/GEO Bulk 队列验证其免疫浸润与预后关联时
  analysis_templates:
  - methods/immune-infiltration-tme
  - methods/survival-prognosis-analysis
  intermediate_interface: survival-time-event-group
  viz_templates:
  - templates/km-survival-curve
  - templates/subgroup-hazard-forest
---
# 细胞亚群组成比例与流向分析

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：仅供个人研究参考
- 引用：Zhang L, et al. Lineage tracking reveals dynamic relationships of T cells in colorectal cancer. Nature, 2018.；Phipson B, et al. propeller: testing for differences in cell type proportions in single cell data. Bioinformatics, 2022.；Buttner M, et al. scCODA is a Bayesian model for compositional single-cell data analysis. Nature Communications, 2021.
- 标签：single-cell、experimental-statistics
- 分析用途：注释与参考映射、细胞通讯与微环境
- 输入接口：[[interfaces/scrna-annotated-cells|已注释单细胞元数据与降维表]]
- 输出接口：[[interfaces/cell-proportion-stats|细胞亚群比例与 Ro/e 偏好统计表]]
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无
- 下一步分析导航（Step N → Step N+1）：
  - **方向 1：异常富集亚群的差异表达与功能打分深挖**（触发条件：通过 Ro/e 或样本级比例检验锁定疾病组显著扩张/耗竭的细胞亚群后，解析其转录组程序改变时；中间表：deg-result-table；分析模版：methods/differential-expression、methods/gene-set-scoring；可视化模版：templates/scp-de-volcano、templates/pathway-stat-violin）
  - **方向 2：组成变化亚群的微环境配受体通讯分析**（触发条件：探索比例升高或降低的关键细胞亚群与其他微环境细胞之间的信号交互重塑时；中间表：cellchat-lr-table；分析模版：methods/cell-cell-communication；可视化模版：templates/cellchat-circos-multi、templates/scp-flow-chord）
  - **方向 3：关键亚群特征在 Bulk 队列免疫浸润与临床预后中的验证**（触发条件：将单细胞中鉴定的关键浸润亚群特征（Marker 集）推广至 TCGA/GEO Bulk 队列验证其免疫浸润与预后关联时；中间表：survival-time-event-group；分析模版：methods/immune-infiltration-tme、methods/survival-prognosis-analysis；可视化模版：templates/km-survival-curve、templates/subgroup-hazard-forest）

- 方法配图关系（语义审查）：
  - [[templates/cell-prop-flow-bar|细胞比例堆叠流带图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    - 依据：按样本或临床分组汇总细胞类型占比后，可导出 render-cell-proportions 绘制堆叠流带柱图；流带仅作视觉连接。；前提：明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。；成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。；适配：从 cell-proportion-stats 汇总并归一化每组占比为 1，导出 render-cell-proportions.csv（group, celltype, proportion）。
    - 关系证据：methods/cell-proportion-composition.md#输出；templates/cell-prop-flow-bar/spec.json；templates/cell-prop-flow-bar/verify/verify.json；运行证据：无
  - [[templates/scp-comp-ring|分组构成同心环图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    - 依据：分组细胞比例表可导出 render-cell-proportions 复用同心环占比模板；模板不做统计检验。；前提：明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。；成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。；适配：按分组归一化占比后导出 render-cell-proportions.csv（group, celltype, proportion）。
    - 关系证据：methods/cell-proportion-composition.md#输出；templates/scp-comp-ring/spec.json；templates/scp-comp-ring/verify/verify.json；运行证据：无
  - [[templates/scp-comp-pie|分组构成饼图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    - 依据：单细胞元数据中的分组与细胞类型标签可整理为 render-cell-metadata 驱动饼图。；前提：明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。；成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。；适配：从 scrna-annotated-cells 提取 cell, group, stat 导出 render-cell-metadata.csv。
    - 关系证据：methods/cell-proportion-composition.md#输出；templates/scp-comp-pie/spec.json；templates/scp-comp-pie/verify/verify.json；运行证据：无
  - [[templates/scp-comp-rose|分组构成玫瑰图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    - 依据：单细胞分组与亚群类别表可导出 render-cell-metadata 绘制玫瑰图。；前提：明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。；成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。；适配：从 scrna-annotated-cells 提取 cell, group, stat 导出 render-cell-metadata.csv。
    - 关系证据：methods/cell-proportion-composition.md#输出；templates/scp-comp-rose/spec.json；templates/scp-comp-rose/verify/verify.json；运行证据：无
  - [[templates/scp-comp-trend|分组构成趋势图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    - 依据：按样本/时间阶段排序的细胞构成可整理为 render-cell-metadata 绘制趋势连线图。；前提：明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。；成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。；适配：整理有序分组与类别到 render-cell-metadata.csv（cell, group, stat）。
    - 关系证据：methods/cell-proportion-composition.md#输出；templates/scp-comp-trend/spec.json；templates/scp-comp-trend/verify/verify.json；运行证据：无
  - [[templates/scp-comp-area|分组构成面积图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    - 依据：多分组细胞构成演化可导出 render-cell-metadata 复用堆积面积图。；前提：明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。；成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。；适配：整理有序分组与类别到 render-cell-metadata.csv（cell, group, stat）。
    - 关系证据：methods/cell-proportion-composition.md#输出；templates/scp-comp-area/spec.json；templates/scp-comp-area/verify/verify.json；运行证据：无
  - [[templates/scp-comp-dot|分组构成点图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    - 依据：分组与亚群构成比例可用点图展示，需导出 render-cell-metadata；点大小仅反映统计汇总。；前提：明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。；成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。；适配：整理 cell, group, stat 到 render-cell-metadata.csv。
    - 关系证据：methods/cell-proportion-composition.md#输出；templates/scp-comp-dot/spec.json；templates/scp-comp-dot/verify/verify.json；运行证据：无
  - [[templates/scp-count-bar|分组计数柱图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    - 依据：各分组或亚群绝对细胞计数可直接由 render-cell-metadata 汇总柱图展示。；前提：明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。；成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。；适配：从 scrna-annotated-cells 导出 render-cell-metadata.csv（cell, group, stat）。
    - 关系证据：methods/cell-proportion-composition.md#输出；templates/scp-count-bar/spec.json；templates/scp-count-bar/verify/verify.json；运行证据：无
  - [[templates/scp-flow-sankey|分组流向桑基图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    - 依据：多层级细胞标签（分组→簇→细胞类型）的映射流向可整理为 render-cell-linkage 绘制桑基图。；前提：明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。；成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。；适配：将多维度分类列按细胞展开为 render-cell-linkage.csv（cell, dimension, category, dimension_order）。
    - 关系证据：methods/cell-proportion-composition.md#输出；templates/scp-flow-sankey/spec.json；templates/scp-flow-sankey/verify/verify.json；运行证据：无
  - [[templates/scp-flow-chord|分组流向和弦图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：仅核对组成统计输出与渲染桥接接口契约，尚未执行真实课题分析→出图端到端联调。
    - 依据：跨维度或组间细胞类别关联计数可导出 render-cell-linkage 绘制流向和弦图。；前提：明确分析单位：描述性绘图可汇总分组比例，但显著性检验必须以样本（sample_id）为独立重复，避免细胞级假重复。；成分比例之和恒为 1 存在负相关约束；多维度流向连线仅为视觉映射，不代表细胞发育轨迹或因果转移。；适配：将二维或跨维度分类映射导出为 render-cell-linkage.csv（cell, dimension, category, dimension_order）。
    - 关系证据：methods/cell-proportion-composition.md#输出；templates/scp-flow-chord/spec.json；templates/scp-flow-chord/verify/verify.json；运行证据：无
<!-- facts:end -->

## 用途

定量评估单细胞数据中各细胞亚群在不同样本、组织来源或疾病条件下的绝对细胞数、相对占比、观测/期望比（$R_{o/e}$ 组织偏好）及跨维度标签映射流向，为微环境重塑分析提供组成层面证据。

## 适用

- 已完成质控、去双细胞、批次整合与细胞类型注释的单细胞对象，且保留完整的 `sample_id` 与实验条件 `group`。
- 具有多个生物学重复样本，适合采用 propeller（logit/arcsin 变换方差分析）、scCODA（成分贝叶斯模型）或样本级非参数检验比较亚群占比。
- 需要追踪聚类簇、注释细胞类型与样本分组之间对应关系的流向展示。

## 不适用

- **细胞级假重复检验**：直接将数千个单细胞混合后做卡方/Fisher 检验并宣称疾病组比例显著升高，忽略同一患者内细胞的高度相关性。
- **把成分比例当独立指标**：所有亚群比例之和恒为 1，某一大群扩张会压低其余亚群相对比例（成分数据闭合效应），须结合 $R_{o/e}$ 或参考基准校正解释。
- **把流带/桑基图当生物学演化**：`cell-prop-flow-bar` 或 `scp-flow-sankey` 的连线只是分类映射与视觉插值，不能解读为细胞命运分化轨迹。

## 输入

读取 [[interfaces/scrna-annotated-cells|已注释单细胞元数据与降维表]]，核心依赖 `cell_id`、`sample_id`、`group` 与 `cell_type`（及可选 `subcluster`）列。

## 怎么做

1. **按样本而非池化细胞计数**：先构建 `sample_id × cell_type` 列联表，核对是否存在极低总细胞数样本（建议设定最低纳入阈值并记录剔除原因）。
2. **计算相对比例与 $R_{o/e}$**：计算每个样本内各亚群比例；若评估跨组织/条件偏好，基于列联表期望频数计算 $R_{o/e} = \text{Observed} / \text{Expected}$。
3. **执行样本级统计检验**：采用 propeller、scCODA 或样本级 Wilcoxon/Kruskal-Wallis + BH 多重比较校正，输出 `p_adj`。
4. **按需提取绘图桥接表**：根据目标图型导出 `render-cell-proportions`、`render-cell-metadata` 或 `render-cell-linkage` 表，再调用对应可视化模板。

## 代码

本锚点页当前尚未封装独立可运行的本库 R/Python 分析模块（状态为 `not_run`）。参考做法可查阅 [[recipes/figureya-315singlerfraction|SingleR细胞来源占比箱图]]（按队列×患者统计占比并做 Kruskal-Wallis 检验）；若已有统计表，可通过下方 `render_bridges` 规范导出至 10 个组成与流向可视化模板。

## 输出

- 语义输出接口 [[interfaces/cell-proportion-stats|细胞亚群比例与 Ro/e 偏好统计表]]：包含 `sample_id`、`group`、`cell_type`、`count`、`proportion`、`roe_value`、`p_adj`。
- 可视化桥接（非分析直接输出）：经 `render_bridges` 转换提取为 `render-cell-proportions`、`render-cell-metadata` 或 `render-cell-linkage` 后驱动对应模板。

## 知识关联检查

已核对库内 10 个组成与流向模板，均读取 `render-*` 绘图专用中间表（`render-cell-proportions` 对应 `cell-prop-flow-bar` 与 `scp-comp-ring`；`render-cell-metadata` 对应 `scp-comp-pie`、`scp-comp-rose`、`scp-comp-trend`、`scp-comp-area`、`scp-comp-dot`、`scp-count-bar`；`render-cell-linkage` 对应 `scp-flow-sankey`、`scp-flow-chord`）。为保持分析输出接口语义纯净，本页仅将 `cell-proportion-stats` 列入 `outputs`，通过 `render_bridges` 与 `adaptable` 关系清晰标明提取转换规则与样本级统计前提（`verification.state: not_run`）。

## 使用记录

<!-- user:start -->
<!-- user:end -->
