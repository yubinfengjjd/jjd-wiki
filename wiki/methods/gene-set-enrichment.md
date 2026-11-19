---
type: method
id: gene-set-enrichment
title: 基因集富集分析
status: ready
tags:
- 单细胞分析
- 转录组
inputs:
- deg-result-table
outputs:
- pathway-score-table
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
- 差异与功能分析
summary: 用显式基因列表和背景检验基因集过代表（ORA），GO/KEGG 是资源，GSEA 是另一种策略且本页未实现。
data_contract:
  input: geneID 向量（可选分组）+ 显式 TERM2GENE/TERM2NAME，或由 DE 表派生的基因列表；背景/物种/ID 类型明确。
  output: 每个基因集一行的 ORA 表：ID、Description、GeneRatio、BgRatio、pvalue、p.adjust、qvalue、geneID、Count。
implementations:
- id: scp-enrichment
  title: SCP RunEnrichment 的 ORA 分支
  language: R
  entrypoint: code/analysis.R:run_gene_set_enrichment
  dependencies:
  - clusterProfiler
  - BiocParallel
  - rlang
  verification: verification/scp-enrichment-standalone.json
keywords:
- ORA
- GSEA
- GO
- KEGG
- clusterProfiler
- enrichment
- 基因集
- SCP
figure_relations:
- figure: templates/kegg-cluster-bubble
  compatibility: adaptable
  reason: 多亚群 KEGG/GO 通路富集结果可整理为气泡矩阵（default 主推跨亚群对比画风）；模板不执行富集检验。
  prerequisites:
  - 所有亚群须采用一致的背景基因集、显著性阈值与多重检验校正规则。
  adaptation: 导出 kegg_cluster_bubble.csv（pathway, cluster, count, logp）。
  evidence:
  - methods/gene-set-enrichment.md#输出
  - templates/kegg-cluster-bubble/spec.json
  verification:
    state: not_run
    scope: 2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/cluster-kegg-bars
  compatibility: adaptable
  reason: 各细胞亚群各自 Top N 显著 KEGG 通路及命中基因数可切换为 variant 分面深酒红横向条形图，保留亚群独立排序。
  prerequisites:
  - 每个亚群内按 p_adjust 升序排序；count 为非负整数命中基因数。
  adaptation: 导出 kegg_cluster_bars.csv（cluster, pathway, p_adjust, count）。
  evidence:
  - methods/gene-set-enrichment.md#输出
  - templates/cluster-kegg-bars/spec.json
  verification:
    state: not_run
    scope: 2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/coexpr-module-enrich-bars
  compatibility: adaptable
  reason: WGCNA 或共表达模块富集条形图可切换为 variant 模块配色条形图；模板不执行富集检验。
  prerequisites:
  - 明确模块归属与统一校正口径（FDR / p.adjust）。
  adaptation: 导出模块富集 CSV（module, term, count, p_adjust）。
  evidence:
  - methods/gene-set-enrichment.md#输出
  - templates/coexpr-module-enrich-bars/spec.json
  verification:
    state: not_run
    scope: 2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
- figure: templates/metabolism-lollipop-dotplot
  compatibility: adaptable
  reason: 代谢通路富集结果（Fold enrichment + -log10(P) + 亚群彩点）可切换为 variant 棒棒糖点图展示；模板不执行富集检验。
  prerequisites:
  - GeneRatio 与 BgRatio 比值计算透明一致，不混用原始 P 与校正 P。
  adaptation: 导出 metabolism_lollipop.csv（cluster, pathway, neg_log10_pval, fold_enrichment）。
  evidence:
  - methods/gene-set-enrichment.md#输出
  - templates/metabolism-lollipop-dotplot/spec.json
  verification:
    state: not_run
    scope: 2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    evidence: []
next_steps:
- direction: 方向 1：锁定关键基因集做逐细胞/逐样本活性打分
  when: 从富集通路锁定核心功能基因集后，需定量每个细胞或样本的活性得分时
  analysis_templates:
  - methods/gene-set-scoring
  - recipes/figureya-61gsva
  - recipes/figureya-71ssgsea-update
  intermediate_interface: pathway-score-table
  viz_templates:
  - templates/pathway-stat-violin
  - templates/scp-expr-ridge
  - templates/kegg-cluster-bubble
  - templates/cluster-kegg-bars
  - templates/coexpr-module-enrich-bars
  - templates/metabolism-lollipop-dotplot
- direction: 方向 2：PPI 互作网络与 Hub 候选基因挖掘
  when: 需要围绕富集通路核心基因构建蛋白互作模块并筛选关键枢纽基因时
  analysis_templates:
  - recipes/figureya-53ppimodule
  - recipes/figureya-147plus-string
  intermediate_interface: candidate-biomarker-list
  viz_templates:
  - templates/scp-flow-chord
data_domains:
- single-cell
- bulk-transcriptomics
---
# 基因集富集分析

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)
- 标签：单细胞分析、转录组
- 分析用途：差异与功能分析
- 输入接口：[[interfaces/deg-result-table|差异表达标准结果表]]
- 输出接口：[[interfaces/pathway-score-table|通路富集与多算法基因集打分表]]
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/gene-set-enrichment/code/analysis.R](/files/wiki/methods/gene-set-enrichment/code/analysis.R) · [methods/gene-set-enrichment/code/enrichment_native.R](/files/wiki/methods/gene-set-enrichment/code/enrichment_native.R)
- 下一步分析导航（Step N → Step N+1）：
  - **方向 1：锁定关键基因集做逐细胞/逐样本活性打分**（触发条件：从富集通路锁定核心功能基因集后，需定量每个细胞或样本的活性得分时；中间表：pathway-score-table；分析模版：methods/gene-set-scoring、recipes/figureya-61gsva、recipes/figureya-71ssgsea-update；可视化模版：templates/pathway-stat-violin、templates/scp-expr-ridge、templates/kegg-cluster-bubble、templates/cluster-kegg-bars、templates/coexpr-module-enrich-bars、templates/metabolism-lollipop-dotplot）
  - **方向 2：PPI 互作网络与 Hub 候选基因挖掘**（触发条件：需要围绕富集通路核心基因构建蛋白互作模块并筛选关键枢纽基因时；中间表：candidate-biomarker-list；分析模版：recipes/figureya-53ppimodule、recipes/figureya-147plus-string；可视化模版：templates/scp-flow-chord）

- 方法配图关系（语义审查）：
  - [[templates/kegg-cluster-bubble|多亚群KEGG通路气泡矩阵]]（draft）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：多亚群 KEGG/GO 通路富集结果可整理为气泡矩阵（default 主推跨亚群对比画风）；模板不执行富集检验。；前提：所有亚群须采用一致的背景基因集、显著性阈值与多重检验校正规则。；适配：导出 kegg_cluster_bubble.csv（pathway, cluster, count, logp）。
    - 关系证据：methods/gene-set-enrichment.md#输出；templates/kegg-cluster-bubble/spec.json；运行证据：无
  - [[templates/cluster-kegg-bars|亚群富集条形图与命中数]]（draft）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：各细胞亚群各自 Top N 显著 KEGG 通路及命中基因数可切换为 variant 分面深酒红横向条形图，保留亚群独立排序。；前提：每个亚群内按 p_adjust 升序排序；count 为非负整数命中基因数。；适配：导出 kegg_cluster_bars.csv（cluster, pathway, p_adjust, count）。
    - 关系证据：methods/gene-set-enrichment.md#输出；templates/cluster-kegg-bars/spec.json；运行证据：无
  - [[templates/coexpr-module-enrich-bars|共表达模块功能富集分面条图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：WGCNA 或共表达模块富集条形图可切换为 variant 模块配色条形图；模板不执行富集检验。；前提：明确模块归属与统一校正口径（FDR / p.adjust）。；适配：导出模块富集 CSV（module, term, count, p_adjust）。
    - 关系证据：methods/gene-set-enrichment.md#输出；templates/coexpr-module-enrich-bars/spec.json；运行证据：无
  - [[templates/metabolism-lollipop-dotplot|多亚群代谢通路棒棒糖图]]（draft）：需要适配（adaptable）；调用验证：not_run；范围：2026-11-19 仅核对方法输出语义与模板 spec.json 契约；未运行真实课题分析→出图端到端联调。
    - 依据：代谢通路富集结果（Fold enrichment + -log10(P) + 亚群彩点）可切换为 variant 棒棒糖点图展示；模板不执行富集检验。；前提：GeneRatio 与 BgRatio 比值计算透明一致，不混用原始 P 与校正 P。；适配：导出 metabolism_lollipop.csv（cluster, pathway, neg_log10_pval, fold_enrichment）。
    - 关系证据：methods/gene-set-enrichment.md#输出；templates/metabolism-lollipop-dotplot/spec.json；运行证据：无
<!-- facts:end -->

## 用途

给定一组候选基因（例如 DE 上调基因）和明确的基因集资源，检验哪些 GO/KEGG/自定义基因集被过代表。输出是基因集级结果表，用于描述候选基因集的生物学主题，不是通路活性或因果证明。

## 原理与选择

ORA 用超几何/富集检验比较列表内外的基因集命中；GSEA 则使用全基因排序和基因集内基因的位置。两者不是同一策略：GO、KEGG 只是资源，ORA/GSEA 才是方法。SCP `RunEnrichment` 封装 clusterProfiler/DOSE 的 ORA 分支，也支持自定义 `TERM2GENE`；本页只验证了自定义基因集的 ORA，在线 GO/KEGG 数据库下载和 GSEA 未运行。



## 来源与实现选择

| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `RunEnrichment` 的 ORA + 显式 TERM2GENE | [[methods/scp-de-enrichment-dynamic]]；`SCP-local/R/SCP-analysis.R` | 基因列表/背景、基因集；ORA 表 | 已封装并 verified（两个自定义基因集） |
| 在线 GO/KEGG 数据库、GO simplify、GSEA | 同上 | 物种/ID 资源、排序列表 | 未运行；GSEA 是不同策略，未实现 |
| 青光眼 `score_pathway_signatures.R` | [[methods/scrna-pathway-signature-ensemble]] | GO/KEGG 用于构建签名基因集，随后打分 | 是打分来源，不是 ORA 实现；未函数化为富集 |
## 适用

- 有一个定义清楚的基因列表（来源、阈值、方向可追溯）和一个合适的背景/宇宙。
- 基因 ID 类型、物种与基因集资源一致；自定义基因集可显式提供 `TERM2GENE`/`TERM2NAME`。
- 用于描述主题或生成假设，后续用独立数据验证。

## 不适用

- 没有背景基因集、把全转录组当列表、或混合不同 ID 类型/物种。
- 把 ORA 的 p 值当作通路活性、因果机制或治疗靶点证据。
- 用同一批数据反复筛选基因列表和基因集，再报告“显著”。

## 输入

`geneID` 向量（可带 `geneID_groups`），`IDtype`、`species`、`minGSSize`/`maxGSSize`，以及 `TERM2GENE`/`TERM2NAME` 或数据库参数。每个基因集一行结果；背景和基因列表版本必须记录。

## 怎么做

1. 明确基因列表来源（DE 对比、阈值、方向）和背景/宇宙；不要把整个基因组默认当背景而不说明。
2. 统一基因 ID 与物种；自定义基因集先检查 term-gene 对和重复。
3. 运行 `RunEnrichment` 的 ORA 分支，设置基因集大小范围；检查 `GeneRatio`、`BgRatio`、`p.adjust` 和命中基因。
4. 对基因列表阈值、背景和基因集版本做敏感性分析；不要只报告最显著的通路。
5. 若要 GSEA，另建排序列表和相应实现；不能把 ORA 结果改称 GSEA。

## 代码

本目录是所选分支的最小调用闭包：复制 `code/`（以及 `runtime.json` 列出的资源）即可在课题环境运行，不再需要完整 `SCP-local`。`bundle` 参数仅为兼容旧调用而接受，函数不会读取；必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verification/*-portability.json`。

入口 `methods/gene-set-enrichment/code/analysis.R:run_gene_set_enrichment(gene_ids, bundle = NULL, parameters)`，封装 SCP `RunEnrichment`，统计逻辑未改。2026-10-23 用两个显式自定义基因集和 7 个基因实际调用；结果表与保留的完整 bundle 参考一致（异目录复制、新进程、无网络）。scope 仅软件调用，基因集是合成示例，不代表真实通路结论。

在线 GO/KEGG 注释下载、GSEA、GO simplify 分支未运行；缺失时保留函数与 not_run 说明，不安装依赖。

## 输出

`result$result$results` 是每个分组/物种组合的 `enrichResult` 列表；取 `@result` 得到 data.frame，一行一个基因集，含 `ID`、`Description`、`GeneRatio`、`BgRatio`、`pvalue`、`p.adjust`、`qvalue`、`geneID`、`Count`。可另导出 CSV；本页不强制统一 CSV。

## 知识关联检查

2026-10-23 检查了现有单 panel 模板。ORA 结果是 gene-set×ontology 表，现有 dotplot 的 group×feature 语义不匹配，分组小提琴也不表达富集比例；本库暂无 ORA/GSEA 专用模板，因此不建立 figure_relations。2026-11-19 更新：已补齐专用富集可视化模板 [[templates/kegg-cluster-bubble]]（default）、[[templates/cluster-kegg-bars]]、[[templates/coexpr-module-enrich-bars]] 与 [[templates/metabolism-lollipop-dotplot]]（adaptable），并按统一背景集与多重校正口径接入。


### scop 候选来源（未运行）

另有 [[methods/scop-analysis-guide|scop 0.9.2 候选来源]]：`RunEnrichment`、`RunGSEA`、`RunDynamicEnrichment`。ORA、GSEA 和动态富集不是同一估计目标；基因背景、排序、物种与 ID 类型需显式确定。 本机尚未执行，不继承本页 SCP/其他实现的验证；未修改本页实现或统计逻辑。

## 使用记录

2026-10-23：在隔离 R 环境用自定义 TERM2GENE/TERM2NAME 实际运行 ORA 并与上游比较；未运行在线 GO/KEGG 或 GSEA。

## 本机组学课题来源增量（2026-11-02）

clusterProfiler 与 irGSEA.integrate/RRA 的候选技术来源；打分、组间整合与 irGSEA.heatmap 分开，不将热图重复收为新方法。 来源清单见 [[methods/uc-ptm-source-catalog]]、[[methods/asthma-lactylation-source-catalog]]；具体实现与原始路径对照见 [[methods/local-omics-analysis-guide]]，图形调用见 [[methods/local-omics-visualization-guide]]。本段只补知识与来源，不更改现有实现、运行/独立性收据、状态或作者确认。

<!-- user:start -->
<!-- user:end -->
