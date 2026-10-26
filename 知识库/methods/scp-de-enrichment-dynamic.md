---
type: method
id: scp-de-enrichment-dynamic
title: 单细胞差异表达、基因集富集与动态特征
status: ready
tags:
- 单细胞分析
- 转录组
keywords:
- SCP
- Seurat
- RunDEtest
- RunEnrichment
- RunGSEA
- RunDynamicFeatures
- RunDynamicEnrichment
- CellScoring
- FindExpressedMarkers
- GO
- KEGG
- GSEA
- GAM
- pseudotime
inputs: []
outputs: []
source:
  kind: repo
  url: https://github.com/zhanghao-njmu/scp
  commit: b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0
license: GPL-3
cite: []
favorite: false
method_kind: technical
summary: SCP 差异表达、富集和动态特征的原始脚本与作者实现记录；分析问题见四个对应家族。
data_contract:
  input: Seurat 对象、分组列、基因集和 pseudotime；原脚本参数在 source/ 中。
  output: SCP DE/富集/动态特征对象与表；本页不重新运行。
---
# 单细胞差异表达、基因集富集与动态特征

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：无
- 标签：单细胞分析、转录组
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

> **资料类型：技术/来源资料，不是默认分析家族。**
> 当前分析问题见：[[methods/differential-expression|差异表达分析]]、[[methods/gene-set-enrichment|基因集富集分析]]、[[methods/gene-set-scoring|基因集与通路签名打分]]、[[methods/dynamic-feature-analysis|拟时序动态特征分析]]。原代码与作者备注保留；本页不再作为分析推荐卡片。

## 用途

用 SCP 的一组函数做“聚类之后”的分析：

- `RunDEtest()`：组间/配对/保守/扰动 marker 的差异检验，结果存入 `srt@tools`。
- `RunEnrichment()`：对 DE 基因做过表达富集（GO/KEGG 等）。
- `RunGSEA()`：对排序基因做 GSEA。
- `RunDynamicFeatures()`：沿 lineage/pseudotime 用 GAM 找动态特征。
- `RunDynamicEnrichment()`：先对 gene set 打分，再沿 lineage 找动态富集条目。
- `CellScoring()`：用 Seurat/AUCell/UCell 对 gene set 打分。
- `FindExpressedMarkers()`：FindMarkers 的 SCP 改造版，返回表达 marker 表。

## 原始实现与家族范围

来源是 SCP v0.5.6 的 `R/SCP-analysis.R`。家族限定为“基于 Seurat 的 DE + 基因集富集/打分 + lineage 动态特征”：

- DE：`RunDEtest()` 支持 `all`、`paired`、`conserved`、`disturbed` marker；`test.use` 默认 `wilcox`；`meta.method` 支持 `maximump`/`minimump`/`wilkinsonp`/`meanp`/`sump`/`votep`。
- 富集：`RunEnrichment()` 依赖 `srt@tools$DEtest_<group_by>` 的 `AllMarkers_<test.use>`；`RunGSEA()` 类似，但用全基因排序。
- 动态：`RunDynamicFeatures()` 需要 lineage 列（通常来自 `RunSlingshot()`）；`RunDynamicEnrichment()` 先打分再调用动态特征。
- 打分：`CellScoring()` 的 `method` 为 `Seurat`、`AUCell`、`UCell`；`classification=TRUE` 时做二分类阈值。
- `FindExpressedMarkers()` 是 SCP 对 Seurat `FindMarkers` 的改写，返回 marker 表；不自动写入 tools。

代码已本地化到 `code/SCP-local/R/SCP-analysis.R`；补丁见 [[methods/scp-local-source|SCP 源码本地化]]。

## 适用

- Seurat 对象已有 cluster/celltype 和表达数据；DE 的组别列明确、每组有足够细胞。
- 需要 all/paired/conserved/disturbed 等不同 marker 设计，或需要 meta 分析合并多个分组变量。
- 富集/GSEA 的物种、基因 ID、数据库版本明确；背景基因集可定义。
- 需要沿 pseudotime/lineage 找动态基因或动态通路；lineage 已由 Slingshot/Monocle 等定义。
- 需要对 gene set 做细胞级打分，供热图/小提琴/UMAP 展示。

## 不适用

- 不能把细胞级 DE 的 p 值当样本级推断：同一受试者的细胞相关，p 值会偏小；没有生物学重复时只能作描述/探索。正式推断应先 pseudobulk（样本×细胞类型）或混合模型。
- 不能把 `avg_log2FC` 当平均表达；它只是组间 log 倍数变化，不能填进点图的 `avg_expression`。
- 富集/GSEA 结果依赖数据库版本、基因 ID 映射、背景和阈值；不是因果机制。
- `RunEnrichment()` 不会自动重跑 DE；必须先有 `srt@tools$DEtest_<group_by>` 的结果，否则会报错或结果为空。
- 动态特征只表示沿 lineage 的统计关联，不是因果或真实时间；GAM 在细胞少、lineage 短或分母不稳时不可靠。
- `CellScoring()` 的不同方法量纲不同（AddModuleScore 可正可负，AUCell/UCell 0–1 类），不能直接相加或混用阈值。
- `FindExpressedMarkers()` 不是新的统计方法；它仍依赖 Seurat 的检验实现。
- 2026-10-22 历史记录：当时未在安装 Seurat/SCP 依赖的环境中运行；数据库、GAM、打分和 p 值未验证。2026-10-23 当前规范家族：DE wilcox、ORA（自定义 TERM2GENE）、Seurat/AddModuleScore、Gaussian 动态特征有 `verified` 收据；GSEA/在线 GO/KEGG/AUCell/UCell/计数 family 仍 `not_run`。见四个家族页。

## 输入

- Seurat 对象；`assay`、`slot`（`data`/`counts`）；分组列 `group_by`；可选的 `group1`/`group2`、`cells1`/`cells2`、`features`。
- DE 参数：`markers_type`、`grouping.var`、`meta.method`、`test.use`、`only.pos`、`fc.threshold`、`base`、`min.pct`、`min.diff.pct`、`max.cells.per.ident`、`latent.vars`、`min.cells.group`、`p.adjust.method`。
- 富集参数：`species`、`IDtype`、`db`、`db_version`、`DE_threshold`、`minGSSize`/`maxGSSize`、`GO_simplify`、`TERM2GENE`/`TERM2NAME`。
- 动态参数：`lineages`（metadata 中的 lineage 列名）、`features`/`n_candidates`、`suffix`、`minfreq`、`family`、`slot`；`RunDynamicEnrichment()` 还要 `score_method`、`db`。
- 打分参数：`features`（named list）或 `db`/`termnames`；`method`；`classification`；`name`；`new_assay`。
- 一行代表一个细胞；富集/GSEA 的基因 ID 与表达矩阵一致；lineage 列与细胞 ID 对齐。

## 怎么做

1. 先确认 cluster/celltype 和样本/条件列；决定 DE 设计：all markers（每个 cluster vs 其余）、paired（配对样本）、conserved/disturbed（多分组变量）。
2. `RunDEtest()`：显式传 `group_by`、`test.use`、`fc.threshold`、`only.pos`、`min.pct`；检查每组细胞数、p 值分布和效应量。结果在 `srt@tools$DEtest_<group_by>`。
3. 选基因：按 `p_val_adj`、`avg_log2FC`、`pct.1`/`pct.2` 设阈值；记录阈值。若做细胞级 p 值，明确是描述性。
4. `RunEnrichment()`：传 `db`、`species`、`IDtype`、`DE_threshold`；检查 `geneMap` 和输入基因数；结果在 `srt@tools$Enrichment_<group_by>_<test.use>`。`RunGSEA()` 类似，结果在 `GSEA_<group_by>_<test.use>`。
5. `RunDynamicFeatures()`：先有 lineage 列；传 `lineages`、`n_candidates`/`features`、`family`、`slot`；检查 GAM 的 `r.sq`、`dev.expl`、`padjust` 和拟合曲线。结果在 `srt@tools$DynamicFeatures_<lineage>`。
6. `RunDynamicEnrichment()`：先 `CellScoring()` 或内部打分，再沿 lineage 找动态条目；结果按 lineage+db 存储。`CellScoring()` 的分数列名由 `name` + term 决定，检查是否与 metadata 冲突。
7. 必要诊断：DE 组大小/配对关系、p 值校准、富集背景/基因覆盖、GSEA 排序方向、GAM 拟合、不同 lineage 的一致性。
8. 导出点图/小提琴/UMAP/火山图接口表；volcano 已有原生模板（读 `render-de-results`），富集/GSEA/动态热图仍无模板，作为候选，不强行建模板。

## 代码

- 原始字节：`source/SCP-analysis.R`（只读归档，未修改）。
- 本地化副本：`code/SCP-local/R/SCP-analysis.R`；辅助函数在 `utils.R`、`Seurat-function.R`。加载方式：
  ```r
  source("path/to/SCP-local/load_scp_local.R")
  srt <- SCP_local$RunDEtest(srt, group_by = "celltype", test.use = "wilcox",
                             only.pos = TRUE, fc.threshold = 1.5)
  srt <- SCP_local$RunEnrichment(srt, group_by = "celltype", db = "GO_BP",
                                 species = "Homo_sapiens")
  srt <- SCP_local$RunGSEA(srt, group_by = "celltype", db = "GO_BP",
                           species = "Homo_sapiens")
  ```
  这只是调用模式，不是已跑通的本机示例。
- 依赖：Seurat、SeuratObject、clusterProfiler、GOSemSim、GO.db、AnnotationDbi、biomaRt、mgcv、BiocParallel、simplifyEnrichment；打分另需 AUCell/UCell。完整清单见 [[methods/scp-local-source|SCP 源码本地化]]。
- 验证状态：2026-10-22 记录本地源码可 `source()`、`verify_local.R` 通过，当时依赖未安装、未运行。2026-10-23 当前范围见 [[methods/differential-expression]]、[[methods/gene-set-enrichment]]、[[methods/gene-set-scoring]]、[[methods/dynamic-feature-analysis]] 的收据；GSEA/在线库/其他打分分支未运行。
- 本地化未改变检验、富集、GAM 或打分算法；只去掉 `SCP::`/包路径。

## 输出

Seurat `tools`/`meta.data` 中新增（列名以运行结果为准）：

- `srt@tools$DEtest_<group_by>`：`AllMarkers_<test.use>`、`PairedMarkers_<test.use>`、`PairedMarkersMatrix_<test.use>`、`ConservedMarkers_<test.use>`、`DisturbedMarkers_<test.use>`；典型列为 `gene`、`group1`、`group2`、`avg_log2FC`、`pct.1`、`pct.2`、`p_val`、`p_val_adj`。
- `srt@tools$Enrichment_<group_by>_<test.use>`：list，含 `enrichment`、`results`、`geneMap`、`input`、`DE_threshold`。
- `srt@tools$GSEA_<group_by>_<test.use>`：同上，`results` 为 GSEA 对象。
- `srt@tools$DynamicFeatures_<lineage>`：list，含 `DynamicFeatures`（features、pvalue、padjust、r.sq、dev.expl、peaktime 等，具体以运行结果为准）、`raw_matrix`、`fitted_matrix`、`upr_matrix`、`lwr_matrix`、`libsize`、`lineages`、`family`。
- `CellScoring()`：按 `name` 生成 metadata 分数列；`new_assay=TRUE` 时写入新 assay。
- 下游表：
  - `render-dotplot-long.csv`：`group, feature, avg_expression, pct_expressed, target_group`。`avg_expression`/`pct_expressed` 必须从表达矩阵按组计算；DE 表只用于选基因和分组，不能把 `avg_log2FC` 当平均表达。适配函数 `scp_dotplot_long()`（`pct_scale` 必须显式给 `percent` 或 `fraction`）。
  - `render-de-results.csv`：`gene, group1, group2, avg_log2FC, pct_1, pct_2, p_val, p_val_adj`（`pct_1`/`pct_2` 为 0–1；`group1` 单一），供 volcano 模板 [[templates/2026-10-22-scp-example__fig01-volcano--volcano|volcano · 单panel]]。从 `AllMarkers_<test.use>` 导出，把 `pct.1/pct.2` 改名为 `pct_1/pct_2`；模板不重跑 DE 或校正。
  - `render-grouped-values.csv`：`celltype, group, value`（每个通路/动态特征一个文件；value 为得分或表达，单位要说明）；适配函数 `scp_grouped_values()`。
  - `render-group-summaries.csv`：`celltype, group, mean, sd, p_value, p_label` 等，由分析阶段预计算；模板不重算检验。
  - `render-umap-feature-long.csv`：`cell_id, umap_1, umap_2, group, feature, value`（拟时序/动态特征值）；适配函数 `scp_umap_feature_long()`。
  - 所有适配函数见 [[methods/scp-visualization-interface|SCP 可视化函数族与接口映射]] 的 `code/scp_tables.R`。

## 知识关联检查

2026-10-23 分类为技术/来源资料：旧 id、`source/` 原字节和作者备注保留，但不再作为默认分析家族推荐。语义配图关系已迁往 [[methods/differential-expression|差异表达分析]]、[[methods/gene-set-enrichment|基因集富集分析]]、[[methods/gene-set-scoring|基因集与通路签名打分]]、[[methods/dynamic-feature-analysis|拟时序动态特征分析]]；本页只保留来源与实现证据链接，不再维护 `figure_relations` 主记录。原页面正文中的模板/证据链接仍可用于溯源；结构相似不等于科学直连。

## 使用记录

2026-10-22 建页；归档 `SCP-analysis.R` 原字节，本地化副本进入共享源码包；按作者代签授权标为 ready；验收记录见 `acceptance.json`。

<!-- user:start -->
<!-- user:end -->
