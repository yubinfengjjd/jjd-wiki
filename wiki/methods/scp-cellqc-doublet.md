---
type: method
id: scp-cellqc-doublet
title: 单细胞 QC 与双细胞检测
status: ready
tags:
- 单细胞分析
keywords:
- SCP
- Seurat
- RunCellQC
- RunDoubletCalling
- scDblFinder
- Scrublet
- DoubletDetection
- scds
- 双细胞
- 质量控制
- QC
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
summary: SCP QC 与双细胞检测的原始脚本和作者实现记录；分析问题见质量控制与双细胞检测家族。
data_contract:
  input: Seurat 原始 counts 与样本元数据；原脚本参数在 source/ 中。
  output: SCP QC/双细胞对象和标签；本页不重新运行。
---
# 单细胞 QC 与双细胞检测

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：无
- 标签：单细胞分析
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

> **资料类型：技术/来源资料，不是默认分析家族。**
> 当前分析问题见：[[methods/cell-quality-control|单细胞质量控制]]、[[methods/doublet-detection|双细胞检测]]。原代码与作者备注保留；本页不再作为分析推荐卡片。

## 用途

用 SCP 的 `RunCellQC()` / `RunDoubletCalling()` 在 Seurat 对象上做细胞级 QC：双细胞检测、MAD 离群、UMI/基因数、线粒体/核糖体比例、核糖体/线粒体比值、物种污染，以及可选的过滤。产出带 QC 标签和指标的 Seurat 对象；下游可导出 UMAP 着色表、QC 比例表和指标分布表。

## 原始实现与家族范围

来源是 SCP v0.5.6 的 `R/SCP-cellqc.R`。家族限定为“基于 Seurat 的细胞级 QC 与双细胞判断”：

- `RunDoubletCalling()` 包装 `scDblFinder`、`Scrublet`、`DoubletDetection`、`scds`（cxds/bcds/hybrid），按 `db_rate` 或 `ncol/1000 * db_coefficient` 设定预期双细胞数。
- `RunCellQC()` 把双细胞、MAD 离群、UMI、基因数、线粒体、核糖体、核糖体/线粒体比值、物种污染合并成 `CellQC` Pass/Fail；可 `split.by` 按样本分别处理。
- `isOutlier()` 是 MAD 离群工具；`db_*()` 是各双细胞方法的适配器。

代码已本地化到 `code/SCP-local/R/SCP-cellqc.R`（与 `utils.R` 的 `check_DataType` 等辅助函数配合），可 `source()` 后直接调用，不安装 SCP 包；补丁与依赖见 [[methods/scp-local-source|SCP 源码本地化]]。

## 适用

- Seurat 对象含 **raw counts**；一行一个细胞（barcode），一列一个基因。
- 多用户/多样本数据：用 `split.by` 指定样本列，逐个样本做双细胞判断，再合并 QC 标签。
- 物种/组织明确，线粒体、核糖体、血红蛋白基因命名可写成正则；小鼠常用 `^mt-`、`^Rp[sl]`、`^Hb[^(p)]`，人常用 `^MT-`、`^RP[SL]`。
- 需要把 QC 结果作为后续过滤、UMAP 着色、比例统计或补充材料。
- 双细胞方法在 R 侧（scDblFinder/scds）或 Python 侧（Scrublet/DoubletDetection）可用。

## 不适用

- 不适用于只有归一化/整合后数据、没有 raw counts 的对象；`RunDoubletCalling()` 会检查 counts 并停止。
- 不能把默认阈值当成通用阈值：`UMI_threshold=3000`、`gene_threshold=1000`、`mito_threshold=20`、`ribo_threshold=50` 是本实现的默认值，换组织、建库方式、测序深度必须重新检查。
- 不能把 `db_rate` 的默认公式当成真实双细胞率；它只是按细胞数估计的近似值，不同上机量/组织不同。
- 不能把 MAD 离群当成人工 QC 的替代；阈值的敏感性应报告。
- 单核 RNA-seq、空间转录组、跨物种/PDX 数据需要改线粒体/核糖体/物种前缀，不能直接套用。
- `RunCellQC()` 的物种污染指标只适用于有物种混合/异种移植设计的数据；普通单物种数据应跳过。
- 2026-10-22 历史记录：当时未在安装 Seurat/SCP 依赖的环境中运行；默认参数的真实表现未验证。2026-10-23 当前规范家族：QC 的 UMI/基因数/线粒体阈值分支 `verified`；scDblFinder `not_run`（缺包）；DoubletFinder 未函数化。见 [[methods/cell-quality-control]]、[[methods/doublet-detection]]。

## 输入

- Seurat 对象；`assay`（默认 `RNA`）的 `counts` 层；`split.by` 样本列。
- 双细胞方法：`db_method`（一个或多个；如 `c("scDblFinder", "scds_cxds")`）、`db_rate` 或 `db_coefficient`。
- QC 指标：`qc_metrics` 向量；`outlier_threshold` 形如 `metric:direction:nmads`，例如 `log10_nCount:lower:2.5`。
- 物种参数：`species`、`species_gene_prefix`，以及 `mito_pattern`、`ribo_pattern` 或显式 `mito_gene`/`ribo_gene`。
- 阈值：`UMI_threshold`、`gene_threshold`、`mito_threshold`、`ribo_threshold`、`ribo_mito_ratio_range`、`species_percent`。
- 一行代表一个细胞；QC 标签不跨样本复用；细胞 ID 在对象内唯一。

## 怎么做

1. 检查 `counts` 是否为 raw counts；确认 `nCount_<assay>`、`nFeature_<assay>` 是否存在（`RunCellQC()` 会在缺失时计算）。
2. 多用户/多样本时设 `split.by`；先在各样本内跑双细胞方法，再合并。不要先 merge 再跑双细胞。
3. 选双细胞方法：R 侧优先 `scDblFinder`（默认）；需要多方法交叉时可加 `scds_cxds`/`scds_bcds`/`scds_hybrid`；Python 侧 `Scrublet`/`DoubletDetection` 需要 reticulate 和对应 Python 包。
4. 计算线粒体、核糖体、物种基因组比例；检查基因命名是否匹配 `mito_pattern`/`ribo_pattern`。线粒体/核糖体比例的分母是 counts。
5. 设 `outlier_threshold`：对 `log10_nCount`、`log10_nFeature` 做 MAD；`featurecount_dist` 是 log10 nFeature 对 log10 nCount 的 loess 残差，低端离群提示低复杂度细胞。`outlier_n` 是至少几个指标同时失败才判离群。
6. 设 UMI/基因数/线粒体/核糖体阈值；`ribo_mito_ratio_range` 默认 `c(1, Inf)`，即只标记比值过低；`species_percent` 默认 95。
7. `RunCellQC()` 生成 `db_qc`、`outlier_qc`、`umi_qc`、`gene_qc`、`mito_qc`、`ribo_qc`、`ribo_mito_ratio_qc`、`species_qc` 和合并的 `CellQC`；`return_filtered=TRUE` 只保留 `CellQC == "Pass"` 并删除 QC 列。
8. 必要诊断：每个样本的细胞数、各指标失败数、失败重叠（upset）、双细胞分数分布、QC 前后细胞数、阈值敏感性；不要只看一个总失败数。
9. 把 QC 标签和指标导出为下游表（见“输出”），再进入 [[methods/scp-standard-workflow|标准流程]] 或 [[methods/scp-integration|整合]]。

## 代码

- 原始字节：`source/SCP-cellqc.R`（只读归档，未修改）。
- 本地化副本：`code/SCP-local/R/SCP-cellqc.R`；辅助函数在 `code/SCP-local/R/utils.R`。加载方式：
  ```r
  source("path/to/SCP-local/load_scp_local.R")
  srt <- SCP_local$RunCellQC(
    srt,
    split.by = "sample",
    db_method = "scDblFinder",
    qc_metrics = c("doublets", "outlier", "umi", "gene", "mito", "ribo"),
    UMI_threshold = 3000, gene_threshold = 1000,
    mito_threshold = 20, ribo_threshold = 50
  )
  ```
  这只是调用模式，不是已跑通的本机示例；参数必须按数据重设。
- 依赖：Seurat、SeuratObject、SingleCellExperiment、Matrix；`scDblFinder`（Bioc）、`scds`（Suggests）；Python 侧还需要 reticulate、Scrublet/DoubletDetection。依赖清单与本地化补丁见 [[methods/scp-local-source|SCP 源码本地化]]。
- 验证状态：2026-10-22 记录本地源码可 `source()`、`verify_local.R` 通过，当时 QC 函数依赖未安装、未运行。2026-10-23 当前收据见 [[methods/cell-quality-control]]（`verified`）与 [[methods/doublet-detection]]（`not_run`）；不宣称阈值/双细胞率在真实数据已验证。
- 本地化未改变 `RunCellQC()`/`RunDoubletCalling()` 的算法、默认阈值或输出结构；只去掉了 `SCP::` 和包路径依赖。

## 输出

Seurat `meta.data` 中新增（列名以运行结果为准）：

- 基础指标：`nCount_RNA`、`nFeature_RNA`（若原对象没有）；按物种后缀生成 `percent.mito.<species>`、`percent.ribo.<species>`、`percent.genome.<species>`、`ribo.mito.ratio.<species>`、`log10_nCount_RNA.<species>`、`log10_nFeature_RNA.<species>`、`featurecount_dist.<species>`。
- 双细胞：`db.<method>_score`、`db.<method>_class`（`singlet`/`doublet`）。
- 单指标 QC：`db_qc`、`outlier_qc`、`umi_qc`、`gene_qc`、`mito_qc`、`ribo_qc`、`ribo_mito_ratio_qc`、`species_qc`，以及合并的 `CellQC`；均为 `Pass`/`Fail` 因子。
- 若 `return_filtered=TRUE`：只返回 `CellQC == "Pass"` 的细胞，并删除上述 QC 列。

下游表（课题内导出，不写回知识库）：

- `render-umap-groups.csv`：`cell_id, umap_1, umap_2, group`（group=`CellQC` 或 `sample`），供 fig01 UMAP 模板。
- `render-cell-proportions.csv`：`group, celltype, proportion`（group=样本/条件，celltype=`CellQC`），供 fig04 比例模板。
- `render-grouped-values.csv`：`celltype, group, value`（每个 QC 指标一个文件；value 为细胞级或样本级，必须在页面/图注说明单位），供 fig06 小提琴模板。
- 如需 p/mean/SD 标注，另写 `render-group-summaries.csv`；由分析阶段预计算，模板不重算检验。
- 表适配函数见 [[methods/scp-visualization-interface|SCP 可视化函数族与接口映射]] 的 `code/scp_tables.R`：`scp_umap_groups()`、`scp_cell_proportions()`、`scp_grouped_values()`。

## 知识关联检查

2026-10-23 分类为技术/来源资料：旧 id、`source/` 原字节和作者备注保留，但不再作为默认分析家族推荐。语义配图关系已迁往 [[methods/cell-quality-control|单细胞质量控制]]、[[methods/doublet-detection|双细胞检测]]；本页只保留来源与实现证据链接，不再维护 `figure_relations` 主记录。原页面正文中的模板/证据链接仍可用于溯源；结构相似不等于科学直连。

## 使用记录

2026-10-22 建页；归档 `SCP-cellqc.R` 原字节，本地化副本进入共享源码包；按作者代签授权标为 ready；验收记录见 `acceptance.json`。

<!-- user:start -->
<!-- user:end -->
