---
type: method
id: differential-expression
title: 差异表达分析
status: ready
tags:
- 单细胞分析
- 转录组
inputs: []
outputs: []
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
summary: 在明确对比组之间检验基因表达差异，输出效应量、p 值与阳性比例；细胞级 p 值不等于样本级推断。
data_contract:
  input: 已标准化/注释的 Seurat 对象 + 分组列；比较组与参照组显式给出，组内细胞数足够。
  output: SCP tools 中的 gene×contrast 表：gene、group1、group2、avg_log2FC、p_val、p_val_adj、pct.1、pct.2。
implementations:
- id: scp-detest
  title: SCP RunDEtest 封装
  language: R
  entrypoint: code/analysis.R:run_differential_expression
  dependencies:
  - Seurat
  - SeuratObject
  - Matrix
  - BiocParallel
  - rlang
  verification: verification/scp-detest-standalone.json
keywords:
- DE
- FindMarkers
- Wilcoxon
- avg_log2FC
- p_val_adj
- 差异基因
- SCP
figure_relations:
- figure: templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot
  compatibility: adaptable
  reason: DE 选出的 marker 可整理成 group/feature/avg_expression/pct_expressed，复用气泡点图；模板不重算
    DE。
  prerequisites:
  - avg_expression 与 pct_expressed 由表达矩阵按组计算，不能用 avg_log2FC 代替。
  - group/feature 顺序由课题给出；target_group 只用于排序。
  adaptation: 导出 render-dotplot-long.csv（group, feature, avg_expression, pct_expressed,
    target_group）。
  evidence:
  - methods/differential-expression.md#输出
  - methods/scp-de-enrichment-dynamic.md#知识关联检查
  - methods/scp-de-enrichment-dynamic.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
- figure: templates/2026-10-22-scp-example__fig01-volcano--volcano
  compatibility: adaptable
  reason: DE 表可整理成 render-de-results，火山图模板消费该表；模板不重跑检验。
  prerequisites:
  - group1 单一；pct_1/pct_2 为 0–1；p_val_adj >0；gene 组内唯一。
  - 模板不重跑 DE 或 p 值校正；阈值由 style 显式给出。
  adaptation: 从 AllMarkers 表导出 gene、avg_log2FC、p_val_adj 等字段到 render-de-results。
  evidence:
  - methods/differential-expression.md#输出
  - methods/scp-de-enrichment-dynamic.md#知识关联检查
  - methods/scp-de-enrichment-dynamic.md#输出
  - templates/2026-10-22-scp-example__fig01-volcano--volcano/spec.json
  - templates/2026-10-22-scp-example__fig01-volcano--volcano/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
---
# 差异表达分析

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)
- 标签：单细胞分析、转录组
- 分析用途：差异与功能分析
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/differential-expression/code/analysis.R](/files/wiki/methods/differential-expression/code/analysis.R) · [methods/differential-expression/code/de_native.R](/files/wiki/methods/differential-expression/code/de_native.R)

- 方法配图关系（语义审查）：
  - [[templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot|细胞类型 × 基因气泡点图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：DE 选出的 marker 可整理成 group/feature/avg_expression/pct_expressed，复用气泡点图；模板不重算 DE。；前提：avg_expression 与 pct_expressed 由表达矩阵按组计算，不能用 avg_log2FC 代替。；group/feature 顺序由课题给出；target_group 只用于排序。；适配：导出 render-dotplot-long.csv（group, feature, avg_expression, pct_expressed, target_group）。
    - 关系证据：methods/differential-expression.md#输出；methods/scp-de-enrichment-dynamic.md#知识关联检查；methods/scp-de-enrichment-dynamic.md#输出；templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot/spec.json；templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot/verify/verify.json；运行证据：无
  - [[templates/2026-10-22-scp-example__fig01-volcano--volcano|差异表达火山图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：DE 表可整理成 render-de-results，火山图模板消费该表；模板不重跑检验。；前提：group1 单一；pct_1/pct_2 为 0–1；p_val_adj >0；gene 组内唯一。；模板不重跑 DE 或 p 值校正；阈值由 style 显式给出。；适配：从 AllMarkers 表导出 gene、avg_log2FC、p_val_adj 等字段到 render-de-results。
    - 关系证据：methods/differential-expression.md#输出；methods/scp-de-enrichment-dynamic.md#知识关联检查；methods/scp-de-enrichment-dynamic.md#输出；templates/2026-10-22-scp-example__fig01-volcano--volcano/spec.json；templates/2026-10-22-scp-example__fig01-volcano--volcano/verify/verify.json；运行证据：无
<!-- facts:end -->

## 用途

在两组细胞之间找出表达差异的基因，输出效应量、p 值、校正后 p 值和两组阳性比例。用于生成候选 marker、检查注释是否合理，或为富集分析提供基因列表。

## 原理与选择

SCP `RunDEtest` 默认调用 Seurat `FindMarkers` 的 Wilcoxon 分支，并按指定方法重新校正 p 值；它支持自定义细胞组、 conserved/disturbed marker 等分支。细胞级检验把每个细胞当独立观测，适合筛选描述性 marker，但不能直接当作样本/患者水平的组间推断；后者需要伪 bulk 或按样本聚合。检验方法、`only.pos`、`fc.threshold`、`min.pct` 都必须显式记录。



## 来源与实现选择

| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `RunDEtest`：Seurat `FindMarkers` + p 校正 | [[methods/scp-de-enrichment-dynamic]]；`SCP-local/R/SCP-analysis.R` | 标准化 Seurat、分组列；gene×contrast 表 | 已封装并 verified（Ductal vs Endocrine） |
| conserved/disturbed marker 等分支 | 同上 | 多分组/配对设计 | 未实现、未运行 |
| 青光眼课题 | `source/` 中未发现独立 DE 脚本；旧 SCP 技术页只归档 SCP 实现 | — | 不声称有独立课题实现 |
## 适用

- 已标准化/注释的 Seurat 对象，比较组和参照组明确。
- 组内细胞数足够（SCP 要求每组至少 3 个细胞），且细胞类型/状态相对一致。
- 用于 marker 筛选、注释检查或为 ORA/GSEA 提供排序列表。

## 不适用

- 把细胞级 p 值当作患者/样本级显著性或组间因果证据。
- 分组与批次、供体或处理完全混杂时，DE 结果不可解释为处理效应。
- 只用 p 值排序、不看效应量和阳性比例；或反复改分组直到得到想要的基因。

## 输入

已标准化/注释的 Seurat 对象、`group_by` 列、`group1`/`group2`（不指定 group2 时与其余细胞比较）。每个基因×对比一行结果；细胞身份和分组必须在对象中可追踪。

## 怎么做

1. 先明确对比：哪两组、参照是谁、是否只看正向 marker；把分组和批次写进分析记录。
2. 在课题环境检查数据是否为 log-normalized；按需设置 `test.use`、`only.pos`、`fc.threshold`、`min.pct`。
3. 运行 `RunDEtest`，从 `tools$DEtest_custom$AllMarkers_<test>` 取表；检查 gene、group1/2、avg_log2FC、p_val_adj、pct.1/2。
4. 用效应量和阳性比例筛选，不只用 p 值；对关键结论做 pseudobulk/样本级敏感性分析。
5. 把筛选规则和完整表一起保存；富集分析的输入基因列表要能追溯到这里。

## 代码

本目录是所选分支的最小调用闭包：复制 `code/`（以及 `runtime.json` 列出的资源）即可在课题环境运行，不再需要完整 `SCP-local`。`bundle` 参数仅为兼容旧调用而接受，函数不会读取；必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verification/*-portability.json`。

入口 `methods/differential-expression/code/analysis.R:run_differential_expression(srt, bundle = NULL, parameters)`，封装 SCP `RunDEtest`，统计逻辑未改。2026-10-23 在 `pancreas_sub` 全数据、`Ductal` vs `Endocrine`、wilcox 上实际调用；`AllMarkers_wilcox` 表与保留的完整 bundle 参考一致（异目录复制、新进程、`BiocParallel::SerialParam()`）。scope 仅软件调用，不代表这些基因在真实研究中显著或可重复。

输出对象是 Seurat；DE 表在 `result$result@tools$DEtest_custom$AllMarkers_wilcox`，不是直接 CSV。页面不把对象存在当成科学结论。

## 输出

`AllMarkers_<test>` 为 data.frame，一行一个 gene×对比，含 `gene`、`group1`、`group2`、`avg_log2FC`、`p_val`、`p_val_adj`、`pct.1`、`pct.2` 等列。可另导出为 CSV；出图模板读取的是整理后的 `render-dotplot-long` 或 `render-de-results`，不是这个原始对象。

## 知识关联检查

2026-10-23 检查了气泡点图和火山图模板。DE marker 可整理为 group×feature 的平均表达/阳性比例，或 gene×effect/p 值的火山图输入；两者均为 adaptable，模板不重算 DE。没有 direct：模板不读 Seurat tools 槽。细胞级 p 值不能直接标注为样本级显著性，图注需说明检验层级。

## 使用记录

2026-10-23：在隔离 R 环境用 `pancreas_sub` 实际运行并与上游表比较；未做真实课题的 pseudobulk 或样本级推断。

<!-- user:start -->
<!-- user:end -->
