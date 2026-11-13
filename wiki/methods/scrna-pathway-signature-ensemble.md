---
type: method
id: scrna-pathway-signature-ensemble
title: 单细胞通路签名打分与组间比较
status: ready
tags:
- 单细胞分析
- 实验统计
inputs: []
outputs: []
source:
  kind: project
  path: E:\青光眼单细胞\score_pathway_signatures.R
license: none
cite: []
favorite: false
keywords:
- GSE251716
- 通路打分
- AUCell
- ssGSEA
- UCell
- singscore
- AddModuleScore
- 热图
- 小提琴图
- 单细胞
method_kind: technical
summary: 青光眼课题的通路签名打分与组间比较实现记录；五种分数相加是课题特定组合，不是通用标准。
data_contract:
  input: GSE251716 表达矩阵、GO/KEGG/标记基因集和细胞元数据。
  output: 作者脚本的 AddModuleScore/AUCell/ssGSEA/UCell/singscore 分数及求和；本页不重新运行。
---
# 单细胞通路签名打分与组间比较

<!-- facts:start -->
- 来源：E:\青光眼单细胞\score_pathway_signatures.R
- 许可证：仅供个人研究参考
- 引用：无
- 标签：单细胞分析、实验统计
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

> **资料类型：技术/来源资料，不是默认分析家族。**
> 当前分析问题见：[[methods/gene-set-scoring|基因集与通路签名打分]]。原代码与作者备注保留；本页不再作为分析推荐卡片。

## 用途

用 GO/KEGG 基因集和手工 marker 构建通路签名，对每个细胞用五种方法打分（AddModuleScore、AUCell、ssGSEA、UCell、singscore），把原始分数相加得到每个通路的综合分；再按 celltype 汇总平均分并比较 Control 与 Glaucoma 的补体通路得分。产出细胞级通路得分表、gene overlap 审计表、热图/小提琴图输入表。

## 原始实现与家族范围

来源是作者课题脚本 `score_pathway_signatures.R`；`pathway_heatmap_cns_function.R` 是下游 ComplexHeatmap 绘图函数。家族限定为“gene-set signature scoring + 分层描述/常规组间检验”。具体实现把五种打分直接相加，这是本页的原始做法，不是公认的 consensus 方法；不能把本页的权重当成已验证的最优组合。

## 适用

- 有 log-normalized 表达矩阵、celltype 标签、至少两组条件；gene set 与物种匹配（本页小鼠 `org.Mm.eg.db`）。
- 需要探索性通路活性排序、热图和小提琴展示；适合细胞数较多的探索性分析。
- gene set 可来自 GO、KEGG 和手工 marker；需要记录 raw/overlap 基因数。
- 组间比较只作为描述性/探索性结果；若要推断，必须先在课题中做样本级汇总或混合模型。

## 不适用

- 不能把细胞当独立样本做 Wilcoxon/t 检验：同一受试者的细胞相关，p 值会偏小；本页每组只有 1 个样本，条件与样本完全混杂，不能做组间统计推断。
- 不能把五种打分直接相加当成已验证的 consensus score：AddModuleScore 是相对表达（可正可负），AUCell/UCell/singscore 是 0–1 类排名分数，ssGSEA 是归一化富集分数；量纲不同，直接求和会让某些方法主导。
- 不能把通路得分差异解释为通路激活/抑制或因果机制；得分受基因集、细胞类型、测序深度和细胞组成影响。
- 不能把热图的 row z-score 当绝对活性；它只表示跨列的相对高低。
- 不把常规 Wilcoxon 单列为方法页（按知识库 2026-10-22 新规则）；本页只把它作为组间比较步骤，并写明局限。

## 输入

- Seurat 对象（含 data layer、celltype、phenotype），或导出的表达矩阵 + cell metadata。
- 本页 10 个通路签名：AP1_FOSB、Complement_total、Complement_classical、Inflammation、TNF_NFKB、Microglia_activation、Reactive_glia、Oxidative_stress_NRF2、RGC_injury、RGC_identity。
- gene set 定义：GO ID、KEGG ID、手工 marker；本页用到的 GO/KEGG 包括 GO:0035976、GO:0006956、mmu04610、GO:0006958、GO:0006954、GO:0034612、GO:0007249、mmu04668、mmu04064、GO:0001774、GO:0042116、GO:0061900、GO:0150103、GO:0048143、GO:0006979、GO:0034599、GO:0048678、GO:0031290。
- 物种注释包和 KEGG 网络可用性；`KEGGREST::keggGet` 需要联网，离线时应预先缓存。
- 一行代表一个细胞；表达矩阵为 genes × cells；分组列至少 2 类；细胞类型列用于分层。

## 怎么做

1. 构建 gene set：GOALL → SYMBOL；KEGG pathway → ENTREZID → SYMBOL；手工 marker 直接加入；与表达矩阵取交集；把 raw/overlap gene count 写入审计表。
2. 五种打分：
   - AddModuleScore：Seurat 默认 bin/ctrl，输出相对分数（可正可负）。
   - AUCell：`AUCell_buildRankings` + `AUCell_calcAUC`，`aucMaxRank = 5%` 基因数。
   - ssGSEA：`GSVA::ssgseaParam`，`minSize=1`、`maxSize=Inf`、`normalize=TRUE`。
   - UCell：`ScoreSignatures_UCell`。
   - singscore：`rankGenes` + `simpleScore(centerScore=FALSE)`。
3. 把五种原始分数直接相加（原脚本做法），删除中间列，只保留每个通路的综合分。注意：这一步没有归一化/加权，五种分数的量纲不同；本页按原样记录，不静默修正。若要改成标准化/加权/单一方法，应先与作者确认，并把它作为新方案另记，不能与原文数值混用。
4. 按 celltype × phenotype 计算平均通路得分；构建 pathway × column 矩阵；行 z-score；用 ComplexHeatmap 画列分割（celltype）、底部 condition 注释、行聚类。
5. 组间比较（原 M4 内容并入本页）：对每个 celltype，用 Wilcoxon 比较 Control vs Glaucoma 的 `Complement_total_score`；把 p 值、mean、SD 作为注释加到小提琴图。原脚本把细胞当独立样本，且每组只有 1 个样本；本页必须写明这是描述性/探索性，不能作为组间推断。要做正式比较，应在课题中先做 pseudobulk（每个样本×celltype 的平均分）或混合效应模型，并需要生物学重复。
6. 必要诊断：gene overlap 是否足够（审计表）；五种分数的分布/相关性；AUCell/ssGSEA/UCell/singscore 的尺度差异；每个 celltype 每组的细胞数；热图 row z-score 是否被少数极端值主导。
7. 输出细胞级得分表、gene overlap 审计表、heatmap 矩阵/列注释、violin 输入表（含预计算 p/mean/SD）。

## 代码

- `source/score_pathway_signatures.R` 为原字节归档，未修改。依赖 Seurat、SeuratObject、AUCell、GSVA、UCell、singscore、org.Mm.eg.db、AnnotationDbi、KEGGREST、BiocParallel、dplyr、tibble、ggpubr、tidyr、tidyverse、ComplexHeatmap、circlize、grid。
- `pathway_heatmap_cns_function.R` 是下游绘图函数，不是分析代码；它的原字节应随 V6 图模板归档，不在本方法页 `source/` 中重复。实际热图调用在本分析脚本末尾，使用 `scale_rows=TRUE`、`cluster_rows=TRUE`、`show_panel_label=FALSE`。
- 原脚本含联网 `KEGGREST`、`source("pathway_heatmap_cns_function.R")`、硬编码文件名和 `setwd` 外的相对路径；复用时要显式设置输入/输出和 gene set，不要把联网/路径操作藏进函数。
- 验证状态：2026-10-22 历史记录：当时 Seurat 因 Matrix 版本冲突无法加载；AUCell/GSVA/UCell/singscore 等包未逐项检查，原脚本未重跑。2026-10-23 当前 Seurat 5.6.0 可加载，但五分数脚本仍未函数化/重跑，其他打分包是否有当前证据需另查；规范家族 Seurat/AddModuleScore 分支见 [[methods/gene-set-scoring]]（verified），不扩为五种分数已验证。
- 常规 Wilcoxon 没有单独包装成函数；按新规则不建独立方法页，只在本页作为步骤/图注说明。

## 输出

- `GSE251716_seurat_annotated_pathway_scored.rds`：含 10 个通路综合分。
- `pathway_score_gene_overlaps.csv`：审计表，列为 `pathway, go_ids, kegg_ids, marker_genes, raw_gene_count, overlap_gene_count, overlap_genes`。
- 课题内可导出为下游表：
  - `cell-pathway-scores.csv`：`cell_id, celltype, condition, pathway, score`（长表；score 为五方法原始和）。
  - `pathway-heatmap.csv`：`pathway, column_id, value`（celltype×condition 平均分；是否 row z-score 要注明）。
  - `pathway-heatmap-columns.csv`：`column_id, celltype, condition`。
  - `pathway-group-summary.csv`：`celltype, group, n_cells, mean, sd, p_value, p_label`（p 值来自本页 Wilcoxon 步骤，仅作描述；正式推断需 pseudobulk/混合模型）。它不是 `render-group-summaries` 接口；后者还需要 `p_y`、`mean_y`、`mean_sd_label`。出图前要在课题副本补齐标注位置并整理成 `render-group-summaries.csv`，否则小提琴模板无法读取。
- 这些表是课题内导出；不要把细胞级 p 值当成样本级推断。

## 知识关联检查

2026-10-23 分类为技术/来源资料：旧 id、`source/` 原字节和作者备注保留，但不再作为默认分析家族推荐。语义配图关系已迁往 [[methods/gene-set-scoring|基因集与通路签名打分]]；本页只保留来源与实现证据链接，不再维护 `figure_relations` 主记录。原页面正文中的模板/证据链接仍可用于溯源；结构相似不等于科学直连。

## 使用记录

2026-10-22 建页，归档原脚本；作者已确认方法页。fig06 模板已建并用合成示例回放；fig05 热图来源已归档，未建模板。

## 本机组学课题来源增量（2026-11-02）

两个新增来源有同类五分数求和；按 gene-set-scoring 统一导航，不按疾病/签名列表再造同义分析页。 来源清单见 [[methods/uc-ptm-source-catalog]]、[[methods/asthma-lactylation-source-catalog]]；具体实现与原始路径对照见 [[methods/local-omics-analysis-guide]]，图形调用见 [[methods/local-omics-visualization-guide]]。本段只补知识与来源，不更改现有实现、运行/独立性收据、状态或作者确认。

<!-- user:start -->
<!-- user:end -->
