---
type: method
id: cell-quality-control
title: 单细胞质量控制
status: ready
tags:
- 单细胞分析
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
- 预处理与质量控制
summary: 按显式阈值计算逐细胞 UMI、基因数与线粒体/核糖体比例，标记 Pass/Fail，不把 QC 指标当生物学分组。
data_contract:
  input: Seurat RNA assay 的原始 counts（基因×细胞）；每个细胞一列，每个基因一行。
  output: 每细胞一行的 QC 结果：nCount_RNA、nFeature_RNA、percent.mito、percent.ribo、CellQC=Pass/Fail。
implementations:
- id: scp-runcellqc
  title: SCP RunCellQC 封装
  language: R
  entrypoint: code/analysis.R:run_cell_quality_control
  dependencies:
  - Seurat
  - SeuratObject
  - Matrix
  - rlang
  verification: verification/scp-runcellqc-standalone.json
keywords:
- QC
- nCount
- nFeature
- percent.mito
- percent.ribo
- 低质量细胞
- SCP
figure_relations:
- figure: templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap
  compatibility: adaptable
  reason: QC 的 Pass/Fail 或指标可作为 UMAP 着色变量；模板只画表，不计算 QC。
  prerequisites:
  - UMAP 坐标与 QC 标签来自同一 Seurat 对象；cell_id 一致。
  - group_levels 显式给出；Pass/Fail 顺序固定。
  adaptation: 导出 render-umap-groups.csv（cell_id, umap_1, umap_2, group=CellQC 或样本）；模板不读
    RDS。
  evidence:
  - methods/cell-quality-control.md#输出
  - methods/scp-cellqc-doublet.md#知识关联检查
  - methods/scp-cellqc-doublet.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
- figure: templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow
  compatibility: adaptable
  reason: 按样本/条件统计 QC Pass/Fail 比例，可复用比例堆叠与流带模板；模板不做统计检验。
  prerequisites:
  - 每个 group 的 celltype 比例归一化到 1；group 为样本或条件，celltype 为 CellQC。
  - 组间比较只作描述，不能当样本级推断。
  adaptation: 导出 render-cell-proportions.csv（group, celltype, proportion）；比例只作描述。
  evidence:
  - methods/cell-quality-control.md#输出
  - methods/scp-cellqc-doublet.md#知识关联检查
  - methods/scp-cellqc-doublet.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
- figure: templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin
  compatibility: adaptable
  reason: QC 指标按样本或细胞类型分组的分布可用分组小提琴展示；模板不重算阈值。
  prerequisites:
  - 每个值有明确的采样单位（细胞或样本）；细胞级分布不能当样本级推断。
  - p/mean/SD 若展示，必须由分析阶段预计算并说明来源。
  adaptation: 导出 render-grouped-values.csv 和可选的 render-group-summaries.csv。
  evidence:
  - methods/cell-quality-control.md#输出
  - methods/scp-cellqc-doublet.md#知识关联检查
  - methods/scp-cellqc-doublet.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
---
# 单细胞质量控制

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)
- 标签：单细胞分析
- 分析用途：预处理与质量控制
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/cell-quality-control/code/analysis.R](/files/wiki/methods/cell-quality-control/code/analysis.R) · [methods/cell-quality-control/code/cellqc_native.R](/files/wiki/methods/cell-quality-control/code/cellqc_native.R)

- 方法配图关系（语义审查）：
  - [[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap|CNS 细胞类型 UMAP]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：QC 的 Pass/Fail 或指标可作为 UMAP 着色变量；模板只画表，不计算 QC。；前提：UMAP 坐标与 QC 标签来自同一 Seurat 对象；cell_id 一致。；group_levels 显式给出；Pass/Fail 顺序固定。；适配：导出 render-umap-groups.csv（cell_id, umap_1, umap_2, group=CellQC 或样本）；模板不读 RDS。
    - 关系证据：methods/cell-quality-control.md#输出；methods/scp-cellqc-doublet.md#知识关联检查；methods/scp-cellqc-doublet.md#输出；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json；运行证据：无
  - [[templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow|细胞比例堆叠流带图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：按样本/条件统计 QC Pass/Fail 比例，可复用比例堆叠与流带模板；模板不做统计检验。；前提：每个 group 的 celltype 比例归一化到 1；group 为样本或条件，celltype 为 CellQC。；组间比较只作描述，不能当样本级推断。；适配：导出 render-cell-proportions.csv（group, celltype, proportion）；比例只作描述。
    - 关系证据：methods/cell-quality-control.md#输出；methods/scp-cellqc-doublet.md#知识关联检查；methods/scp-cellqc-doublet.md#输出；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/spec.json；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/verify/verify.json；运行证据：无
  - [[templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin|分组小提琴图（含统计标注）]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：QC 指标按样本或细胞类型分组的分布可用分组小提琴展示；模板不重算阈值。；前提：每个值有明确的采样单位（细胞或样本）；细胞级分布不能当样本级推断。；p/mean/SD 若展示，必须由分析阶段预计算并说明来源。；适配：导出 render-grouped-values.csv 和可选的 render-group-summaries.csv。
    - 关系证据：methods/cell-quality-control.md#输出；methods/scp-cellqc-doublet.md#知识关联检查；methods/scp-cellqc-doublet.md#输出；templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/spec.json；templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin/verify/verify.json；运行证据：无
<!-- facts:end -->

## 用途

在进入归一化、整合、降维之前，逐细胞计算文库大小、检出基因数、线粒体/核糖体读段比例，并按课题预先规定的阈值标记 Pass/Fail。结果用于决定哪些细胞进入下游，不是把 QC 指标当作细胞类型或生物学分组。

## 原理与选择

破损细胞常表现为低 UMI、低基因数或高线粒体比例；双细胞、环境 RNA、物种混合是不同问题，需分别检测。阈值受组织、建库版本和测序深度影响，不能照搬固定值。SCP `RunCellQC` 把 UMI、基因数、线粒体、核糖体、ribo/mito 比、离群点和双细胞组合成 `CellQC`；本页只验证了 UMI/基因数/线粒体阈值分支，双细胞与离群点分支未运行。



## 来源与实现选择

| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `RunCellQC`：UMI、基因数、线粒体/核糖体比例、可选双细胞/离群点 | [[methods/scp-cellqc-doublet]]；`SCP-local/R/SCP-cellqc.R` | 原始 counts，按样本；输出细胞级 QC 指标与 CellQC | UMI/基因数/线粒体阈值分支已封装并 verified；双细胞/离群点未运行 |
| 青光眼 `preprocess.R`：Seurat 指标 + MAD 3× 离群点 | [[methods/scrna-preprocess-doublet-qc-harmony]]；`source/preprocess.R` | 原始 counts，按样本；MAD 阈值 | 原脚本未函数化，未在本库验证；阈值是课题设定 |
## 适用

- 原始 counts，且基因标识与物种明确；可按样本分别检查。
- 需要把细胞级 QC 失败原因记录并带入后续分析，而不是静默删细胞。
- 阈值由课题数据分布、组织类型、建库协议和既往经验共同确定，并写入方法。

## 不适用

- 已归一化/积分的表达值不能直接当 raw counts 计算这些指标。
- 不能仅凭 QC 指标给细胞定型，也不能把 Pass/Fail 当作处理组或生物学差异。
- 不同物种/建库方案共用固定阈值、或跨样本比较未标准化的线粒体比例，容易得出误导结论。

## 输入

Seurat 对象（`RNA` assay 的 `counts`），或能转为同样基因×细胞矩阵的对象；`qc_metrics`、`UMI_threshold`、`gene_threshold`、`mito_threshold`、`ribo_threshold` 等参数显式传入。每个细胞是一行结果，不是每个样本一行。

## 怎么做

1. 按样本查看 nCount、nFeature、percent.mito 的分布，结合组织与建库记录确定阈值；不要先看下游聚类再倒推阈值。
2. 显式列出要计算的指标；本页已验证 UMI、基因数、线粒体阈值。
3. 运行 `RunCellQC`，保留 Pass/Fail 及每个失败原因；若决定过滤，记录过滤前后细胞数和样本组成。
4. 对边界细胞做敏感性分析（保留/剔除各跑一次下游），不要把单次阈值当唯一真值。
5. 双细胞、离群点、物种混合按各自方法单独处理；本页不把它们的阈值混入 UMI/基因数结论。

## 代码

本目录是所选分支的最小调用闭包：复制 `code/`（以及 `runtime.json` 列出的资源）即可在课题环境运行，不再需要完整 `SCP-local`。`bundle` 参数仅为兼容旧调用而接受，函数不会读取；必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verification/*-portability.json`。

入口 `methods/cell-quality-control/code/analysis.R:run_cell_quality_control(srt, bundle = NULL, parameters)`。参数与 SCP `RunCellQC` 同名，统计逻辑未改；双细胞辅助函数只在 `qc_metrics` 包含 doublets 时检查其包。

验证：2026-10-23 在 `pancreas_sub` 的 80 个细胞上实际调用，封装与上游 `CellQC` 一致，输入对象未被修改；scope 仅软件调用，不代表科学有效或真实课题阈值合理。双细胞/离群点分支未运行，缺失原因见对应家族页。

## 输出

返回 `list(result=Seurat, diagnostics=...)`。`result@meta.data` 增加 `nCount_RNA`、`nFeature_RNA`、`percent.mito`、`percent.ribo`、`CellQC`（Pass/Fail）等字段；一行一个细胞。没有强制 CSV；出图前由课题显式导出对应接口表。

## 知识关联检查

2026-10-23 检查了 `templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap`、`fig04-cell-proportion-flow--stacked-bar-flow`、`fig06-pathway-violin--violin`。QC Pass/Fail 或指标可作为 UMAP 着色、样本比例、分组分布；模板不计算 QC，关系为 adaptable。没有 direct：模板不读 Seurat 对象，需先导出 `render-umap-groups`、`render-cell-proportions`、`render-grouped-values` 等接口。双细胞图不在此页直连，见 [[methods/doublet-detection]]。


### scop 候选来源（未运行）

另有 [[methods/scop-analysis-guide|scop 0.9.2 候选来源]]：`RunCellQC`、`RunATACQC`、`RunSpotQC`、`RunSpotSweeper`。RNA 细胞、ATAC 细胞与空间 spot 的 QC 指标和阈值分开；不能沿用旧 RNA 阈值覆盖其他平台。 本机尚未执行，不继承本页 SCP/其他实现的验证；未修改本页实现或统计逻辑。

## 使用记录

2026-10-23：在隔离 R 环境用 `pancreas_sub` 80 细胞做软件调用、输入不变和上游一致性检查；未做真实课题阈值决策。

<!-- user:start -->
<!-- user:end -->
