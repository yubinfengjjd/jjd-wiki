---
type: method
id: set-intersection-and-group-stats
title: 集合交集与通用组间统计分析
status: ready
tags:
- experimental-statistics
data_domains:
- general-viz-stats
inputs: []
outputs: []
render_bridges:
- interface: render-cell-membership
  from_output: 多分组基因集、细胞集合或候选特征列表的 0/1 成员定义
  extractor_note: 将多个命名集合的全集成员关系按实体×集合展开为完整笛卡尔长表（cell, set, member 只取 0 或 1），禁止缺行或重复行，供维恩图与
    UpSet 图直接渲染。
  unit: 实体 × 集合
- interface: render-correlation-heatmap
  from_output: 样本间、基因间或细胞亚群间两两相关系数或余弦相似度矩阵
  extractor_note: 将完整的 row × column 相似度/相关性矩阵展平为长表（row, column, similarity, row_group,
    column_group, row_order, column_order），明确度量为 Pearson/Spearman/Cosine，供相关性聚类热图绘制。
  unit: 行实体 × 列实体
source:
  kind: written
license: none
cite:
- 'Lex A, et al. UpSet: visualization of intersecting sets. IEEE Transactions on Visualization
  and Computer Graphics, 2014.'
- 'Gao CH, et al. ggVennDiagram: an intuitive, easy-to-use, and highly customizable
  R package to generate Venn diagram. Frontiers in Genetics, 2021.'
- Wilcoxon F. Individual comparisons by ranking methods. Biometrics Bulletin, 1945.
favorite: false
method_kind: analysis
purposes:
- 集合与通用统计
summary: 提供多集合交集定量（Venn / UpSet）、多变量两两相关性与距离检验、组间分布假设检验（Wilcoxon / Kruskal-Wallis
  / PERMANOVA）及探索性降维排序（PCA / PCoA）的通用分析规范与模板桥接。
data_contract:
  input: 已去重且定义明确的命名集合列表（基因/细胞集合），或同一独立观测单位下的分组连续/分类变量矩阵。
  output: 集合交集计数表与 0/1 成员矩阵、成对相关系数与校正 P 值矩阵、组间假设检验统计量表（均须显式标注采样单位）。
keywords:
- Venn
- UpSet
- correlation
- PCA
- PCoA
- Wilcoxon
- Kruskal-Wallis
- set intersection
- 集合交集
- 组间统计
figure_relations:
- figure: templates/set-venn
  compatibility: adaptable
  reason: 2–7 个集合（推荐 2–4 个）的 0/1 成员关系可整理为 render-cell-membership 驱动维恩图模板；模板仅统计重叠区域并着色，不做超几何富集检验。
  prerequisites:
  - 所有集合必须基于同一实体全集并先做唯一性去重，缺失实体×集合组合行会导致计数失真。
  - 圆/椭圆面积不与集合大小成比例，解读须依据区域标注计数；超过 5 个集合改用 UpSet 图。
  adaptation: 将各集合的 0/1 成员表展开为完整长表 render-cell-membership.csv（cell, set, member）。
  evidence:
  - methods/set-intersection-and-group-stats.md#输出
  - templates/set-venn/spec.json
  - templates/set-venn/verify/verify.json
  verification:
    state: not_run
    scope: 仅核对 render-cell-membership 接口契约与维恩图模板 spec.json，尚未执行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/set-upset
  compatibility: adaptable
  reason: 多集合（尤其 4 个以上集合）的复杂交集可整理为 render-cell-membership 驱动 UpSet 图模板；模板按交集大小排序展示，不做统计检验。
  prerequisites:
  - 所有集合来自同一全集，member 仅允许 0/1 且无 NA。
  - 各集合的筛选阈值与口径须在分析阶段固定，避免因阈值不一致导致伪交集差异。
  adaptation: 导出完整实体的 0/1 成员长表 render-cell-membership.csv（cell, set, member）。
  evidence:
  - methods/set-intersection-and-group-stats.md#输出
  - templates/set-upset/spec.json
  - templates/set-upset/verify/verify.json
  verification:
    state: not_run
    scope: 仅核对 render-cell-membership 接口契约与 UpSet 模板 spec.json，尚未执行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/scp-cell-cor-heatmap
  compatibility: adaptable
  reason: 计算好的两两相关性或余弦相似度矩阵可展平为 render-correlation-heatmap 驱动聚类热图模板；模板不重算相关系数或距离。
  prerequisites:
  - 输入必须为完整的 row × column 笛卡尔积；不同相似度度量（Pearson/Spearman/Cosine）不能混入同一色标。
  - 相关热图只展示线性/单调关联程度，不构成细胞类型相同或因果机制的证明。
  adaptation: 将完整相似度/相关性矩阵展平并附带分组与排序信息，导出 render-correlation-heatmap.csv。
  evidence:
  - methods/set-intersection-and-group-stats.md#输出
  - templates/scp-cell-cor-heatmap/spec.json
  - templates/scp-cell-cor-heatmap/verify/verify.json
  verification:
    state: not_run
    scope: 仅核对 render-correlation-heatmap 接口契约与相似度热图模板 spec.json，尚未执行真实课题分析→出图端到端联调。
    evidence: []
next_steps:
- direction: 方向 1：交集核心基因的功能富集（ORA / GO / KEGG）
  when: 从多集合交集（如 DEG ∩ WGCNA ∩ 单细胞 Marker）提取核心候选基因列表后，解析其功能通路富集时
  analysis_templates:
  - methods/gene-set-enrichment
  - recipes/figureya-52goplot
  intermediate_interface: pathway-score-table
  viz_templates:
  - templates/marker-bubble-dotplot
- direction: 方向 2：交集候选标志物进入机器学习特征筛选与评估
  when: 将交集筛选出的稳健候选特征送入 LASSO/SVM-RFE/随机森林建模及交叉验证评估时
  analysis_templates:
  - methods/regression-resampling-evaluation
  - methods/shap-explanation
  - recipes/figureya-65svm
  intermediate_interface: candidate-biomarker-list
  viz_templates:
  - templates/resampling-metric-box
  - templates/shap-importance-bar
- direction: 方向 3：交集标志物的临床生存分层与亚组效应验证
  when: 检验交集候选基因或分组变量在独立随访队列中的生存分层与预后风险比时
  analysis_templates:
  - methods/survival-prognosis-analysis
  intermediate_interface: survival-time-event-group
  viz_templates:
  - templates/km-survival-curve
  - templates/subgroup-hazard-forest
---
# 集合交集与通用组间统计分析

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：仅供个人研究参考
- 引用：Lex A, et al. UpSet: visualization of intersecting sets. IEEE Transactions on Visualization and Computer Graphics, 2014.；Gao CH, et al. ggVennDiagram: an intuitive, easy-to-use, and highly customizable R package to generate Venn diagram. Frontiers in Genetics, 2021.；Wilcoxon F. Individual comparisons by ranking methods. Biometrics Bulletin, 1945.
- 标签：experimental-statistics
- 分析用途：集合与通用统计
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无
- 下一步分析导航（Step N → Step N+1）：
  - **方向 1：交集核心基因的功能富集（ORA / GO / KEGG）**（触发条件：从多集合交集（如 DEG ∩ WGCNA ∩ 单细胞 Marker）提取核心候选基因列表后，解析其功能通路富集时；中间表：pathway-score-table；分析模版：methods/gene-set-enrichment、recipes/figureya-52goplot；可视化模版：templates/marker-bubble-dotplot）
  - **方向 2：交集候选标志物进入机器学习特征筛选与评估**（触发条件：将交集筛选出的稳健候选特征送入 LASSO/SVM-RFE/随机森林建模及交叉验证评估时；中间表：candidate-biomarker-list；分析模版：methods/regression-resampling-evaluation、methods/shap-explanation、recipes/figureya-65svm；可视化模版：templates/resampling-metric-box、templates/shap-importance-bar）
  - **方向 3：交集标志物的临床生存分层与亚组效应验证**（触发条件：检验交集候选基因或分组变量在独立随访队列中的生存分层与预后风险比时；中间表：survival-time-event-group；分析模版：methods/survival-prognosis-analysis；可视化模版：templates/km-survival-curve、templates/subgroup-hazard-forest）

- 方法配图关系（语义审查）：
  - [[templates/set-venn|多集合交集维恩图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：仅核对 render-cell-membership 接口契约与维恩图模板 spec.json，尚未执行真实课题分析→出图端到端联调。
    - 依据：2–7 个集合（推荐 2–4 个）的 0/1 成员关系可整理为 render-cell-membership 驱动维恩图模板；模板仅统计重叠区域并着色，不做超几何富集检验。；前提：所有集合必须基于同一实体全集并先做唯一性去重，缺失实体×集合组合行会导致计数失真。；圆/椭圆面积不与集合大小成比例，解读须依据区域标注计数；超过 5 个集合改用 UpSet 图。；适配：将各集合的 0/1 成员表展开为完整长表 render-cell-membership.csv（cell, set, member）。
    - 关系证据：methods/set-intersection-and-group-stats.md#输出；templates/set-venn/spec.json；templates/set-venn/verify/verify.json；运行证据：无
  - [[templates/set-upset|多集合交集 UpSet 图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：仅核对 render-cell-membership 接口契约与 UpSet 模板 spec.json，尚未执行真实课题分析→出图端到端联调。
    - 依据：多集合（尤其 4 个以上集合）的复杂交集可整理为 render-cell-membership 驱动 UpSet 图模板；模板按交集大小排序展示，不做统计检验。；前提：所有集合来自同一全集，member 仅允许 0/1 且无 NA。；各集合的筛选阈值与口径须在分析阶段固定，避免因阈值不一致导致伪交集差异。；适配：导出完整实体的 0/1 成员长表 render-cell-membership.csv（cell, set, member）。
    - 关系证据：methods/set-intersection-and-group-stats.md#输出；templates/set-upset/spec.json；templates/set-upset/verify/verify.json；运行证据：无
  - [[templates/scp-cell-cor-heatmap|细胞相似度热图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：仅核对 render-correlation-heatmap 接口契约与相似度热图模板 spec.json，尚未执行真实课题分析→出图端到端联调。
    - 依据：计算好的两两相关性或余弦相似度矩阵可展平为 render-correlation-heatmap 驱动聚类热图模板；模板不重算相关系数或距离。；前提：输入必须为完整的 row × column 笛卡尔积；不同相似度度量（Pearson/Spearman/Cosine）不能混入同一色标。；相关热图只展示线性/单调关联程度，不构成细胞类型相同或因果机制的证明。；适配：将完整相似度/相关性矩阵展平并附带分组与排序信息，导出 render-correlation-heatmap.csv。
    - 关系证据：methods/set-intersection-and-group-stats.md#输出；templates/scp-cell-cor-heatmap/spec.json；templates/scp-cell-cor-heatmap/verify/verify.json；运行证据：无
<!-- facts:end -->

## 用途

提供跨组学通用的基础统计与集合整理流程：包括多来源基因/细胞集合的精确交集统计（Venn 与 UpSet）、多变量成对相关性矩阵计算与显著性校正、样本级组间参数/非参数分布检验，以及探索性主成分/主坐标分析（PCA / PCoA）。

## 适用

- 来自同一物种与同一基因/细胞 ID 体系下的多个独立候选集合的交集筛选。
- 需要明确独立采样单位（样本或受试者）并校验正态性/方差齐性后的多组均值或中位数比较。
- 多指标之间两两线性（Pearson）或秩相关（Spearman）关联矩阵的探索性分析与多重比较校正。

## 不适用

- **忽略背景全集与 ID 对齐**：不同基因命名版本（Symbol vs Ensembl）或跨物种直接求交集；或仅把交集数目当成显著性（未做背景置换或超几何检验）。
- **把技术重复或单细胞当独立样本**：做组间箱线/小提琴统计检验时混淆患者数与细胞数。
- **把相关性当因果**：高相关系数不代表直接调控，也可能是混杂批次或细胞比例变化所致。

## 输入

本页覆盖通用统计学与集合比较场景，输入可为多个命名基因/细胞集合列表，或标准样本×特征观测矩阵（暂不绑定单一特定组学 `inputs` 接口）。

## 怎么做

1. **统一 ID 与定义全集**：对所有集合做去重与基因/细胞标识对齐，明确背景全集；若需出图，构造完整的实体×集合 0/1 成员矩阵。
2. **明确检验单位与多重校正**：组间比较先确认观测独立性，选择合适的参数（t 检验/ANOVA）或非参数（Wilcoxon/Kruskal-Wallis）方法，并对多指标检验应用 BH/FDR 校正。
3. **计算相关或降维矩阵**：按度量需求计算 Pearson/Spearman 相关矩阵或距离矩阵（PCA/PCoA/PERMANOVA），记录缺失值处理与样本排序规则。
4. **经桥接接口导出**：整理为 `render-cell-membership` 或 `render-correlation-heatmap` 交付对应模板绘制。

## 代码

本锚点页当前尚未封装独立可运行的本库分析模块（状态为 `not_run`）。常用集合交集、相关性矩阵、箱线/小提琴比较与 PCA 参考源码配方见：
- 集合与相关：[[recipes/figureya-112venn]]、[[recipes/figureya-65svm]]、[[recipes/figureya-76corrgram]]、[[recipes/figureya-9heatmap]]、[[recipes/figureya-228linkcor]]
- 组间比较、PCA 与倾向得分匹配：[[recipes/figureya-162boxviolin]]、[[recipes/figureya-227boxdensity]]、[[recipes/figureya-38pca]]、[[recipes/figureya-229pcoa]]、[[recipes/figureya-7psm]]

## 输出

本页暂无单一固定语义输出接口（`outputs: []`）；分析结果通过 `render_bridges` 明确转换为绘图长表 `render-cell-membership` 与 `render-correlation-heatmap` 对接标准化单 panel 模板。

## 知识关联检查

已核对通用统计与集合模板 [[templates/set-venn]]、[[templates/set-upset]] 与 [[templates/scp-cell-cor-heatmap]]：
- `set-venn` 与 `set-upset` 均读取 `render-cell-membership`；2–4 集合推荐维恩图，5 个及以上集合或需按交集规模排序时推荐 UpSet 图，均已登记为 `adaptable`（`verification.state: not_run`）。
- `scp-cell-cor-heatmap` 读取 `render-correlation-heatmap`，已登记为 `adaptable`（`verification.state: not_run`）。
- 三个模板均消费 `render-*` 绘图专用长表，严格保持在 `render_bridges` 与 `adaptable` 语义边界内，不虚构 `direct` 或已运行结论。

## 使用记录

<!-- user:start -->
<!-- user:end -->
