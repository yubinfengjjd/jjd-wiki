---
type: method
id: doublet-detection
title: 双细胞检测
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
summary: 按样本识别双细胞；scDblFinder 与 DoubletFinder 是不同算法，当前均未在本机跑通，保留来源与精确缺失原因。
data_contract:
  input: 按样本的 Seurat 原始 counts；显式预期双细胞率；scDblFinder 或 DoubletFinder 分支及其预处理前提。
  output: 每细胞 doublet class/score（运行成功时）；当前两条路线均未产生结果。
implementations:
- id: scp-rundoublet
  title: SCP RunDoubletCalling 的 scDblFinder 分支
  language: R
  entrypoint: code/analysis.R:run_doublet_detection
  dependencies:
  - Seurat
  - SeuratObject
  - Matrix
  - rlang
  verification: verification/scp-rundoublet-standalone.json
keywords:
- doublet
- scDblFinder
- DoubletFinder
- Scrublet
- DoubletDetection
- scds
- 双细胞
- SCP
figure_relations:
- figure: templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap
  compatibility: adaptable
  reason: 双细胞标签可作为 UMAP 着色变量检查分布；模板不检测双细胞。
  prerequisites:
  - UMAP 坐标与 QC 标签来自同一 Seurat 对象；cell_id 一致。
  - group_levels 显式给出；Pass/Fail 顺序固定。
  adaptation: 导出 render-umap-groups.csv（group=doublet class 或样本）；标签只作描述。
  evidence:
  - methods/doublet-detection.md#输出
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
  reason: 按样本统计双细胞比例可复用比例图；模板不做双细胞检测或统计检验。
  prerequisites:
  - 每个 group 的 celltype 比例归一化到 1；group 为样本或条件，celltype 为 CellQC。
  - 组间比较只作描述，不能当样本级推断。
  adaptation: 导出 render-cell-proportions.csv（group=样本, celltype=doublet class, proportion）。
  evidence:
  - methods/doublet-detection.md#输出
  - methods/scp-cellqc-doublet.md#知识关联检查
  - methods/scp-cellqc-doublet.md#输出
  - templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/spec.json
  - templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/verify/verify.json
  verification:
    state: not_run
    scope: 2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    evidence: []
---
# 双细胞检测

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
- 代码模板：[methods/doublet-detection/code/analysis.R](/files/wiki/methods/doublet-detection/code/analysis.R) · [methods/doublet-detection/code/doublet_native.R](/files/wiki/methods/doublet-detection/code/doublet_native.R)

- 方法配图关系（语义审查）：
  - [[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap|CNS 细胞类型 UMAP]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：双细胞标签可作为 UMAP 着色变量检查分布；模板不检测双细胞。；前提：UMAP 坐标与 QC 标签来自同一 Seurat 对象；cell_id 一致。；group_levels 显式给出；Pass/Fail 顺序固定。；适配：导出 render-umap-groups.csv（group=doublet class 或样本）；标签只作描述。
    - 关系证据：methods/doublet-detection.md#输出；methods/scp-cellqc-doublet.md#知识关联检查；methods/scp-cellqc-doublet.md#输出；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/spec.json；templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap/verify/verify.json；运行证据：无
  - [[templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow|细胞比例堆叠流带图]]（ready）：需要适配（adaptable）；调用验证：not_run；范围：2026-10-23 只核对方法输出与模板接口；未运行真实课题分析→出图。
    - 依据：按样本统计双细胞比例可复用比例图；模板不做双细胞检测或统计检验。；前提：每个 group 的 celltype 比例归一化到 1；group 为样本或条件，celltype 为 CellQC。；组间比较只作描述，不能当样本级推断。；适配：导出 render-cell-proportions.csv（group=样本, celltype=doublet class, proportion）。
    - 关系证据：methods/doublet-detection.md#输出；methods/scp-cellqc-doublet.md#知识关联检查；methods/scp-cellqc-doublet.md#输出；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/spec.json；templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow/verify/verify.json；运行证据：无
<!-- facts:end -->

## 用途

在 QC 阶段识别同一液滴中两个及以上细胞，避免双细胞在聚类、差异表达和轨迹分析中形成假中间态。输出是细胞级 doublet 标签/分数，供过滤或敏感性分析使用。

## 原理与选择

scDblFinder 通过模拟双细胞/表达距离并参考预期双细胞率判断异常液滴；DoubletFinder 先做参数扫描选 pK，再用同型双细胞比例校正预期数（青光眼脚本用 7.5%），每样本独立运行。两者都依赖原始 counts、样本结构和预期率，但模型/参数不同，不能把一者的阈值或结果直接套到另一者。SCP `RunDoubletCalling` 还可分发 Scrublet、DoubletDetection、scds；本页保留这些可选分支的入口和包检查，但本机缺 scDblFinder/scds/Python 后端，均未运行。

## 来源与实现选择

| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `RunDoubletCalling` 的 scDblFinder 分支 | [[methods/scp-cellqc-doublet]]；`SCP-local/R/SCP-cellqc.R` | 原始 counts、按样本、预期双细胞率；输出 class/score | 已封装；scDblFinder 缺失，`not_run` |
| 青光眼 `preprocess.R` 的 DoubletFinder | [[methods/scrna-preprocess-doublet-qc-harmony]]；`source/preprocess.R` | 预处理对象、按样本；paramSweep 选 pK、modelHomotypic、7.5% 预期率 | 原脚本未函数化；DoubletFinder 缺失，未验证 |
| SCP 的 Scrublet / DoubletDetection / scds 分支 | `SCP-local/R/SCP-cellqc.R` | 原始 counts；不同算法假设不同 | 已保留可选入口，依赖缺失，未运行；不能与 scDblFinder 互换 |

## 适用

- 10x 等液滴 scRNA-seq 原始 counts，按样本分别处理。
- 有可解释的预期双细胞率，或至少有同批上样量/阴性对照记录。
- 双细胞标签用于过滤和敏感性分析，而不是作为生物学分组。

## 不适用

- 已聚合的伪 bulk、无细胞级 counts 的数据不能直接使用。
- 不同样本/建库协议双细胞率差异大时，不能用一个固定比例跨样本删除。
- doublet score 不是细胞类型或疾病状态；不能把高分细胞直接解释为某种生物学亚群。
- scDblFinder 与 DoubletFinder 结果不一致时，不能静默选一个；要说明算法差异和敏感性。

## 输入

按样本的 Seurat 原始 counts、`assay`、预期双细胞率；scDblFinder 分支用 `db_method="scDblFinder"`/`db_rate`，DoubletFinder 分支需要预处理对象、PC 数、pN、预期率和同型校正。输出每行一个细胞，保留样本、方法和参数。

## 怎么做

1. 按样本确认上样细胞数、建库批次和预期双细胞率；没有记录时先与作者确认，不猜“标准”比例。
2. 选算法：scDblFinder 或 DoubletFinder；说明选择依据，不把两者当可互换。
3. scDblFinder：按样本运行并保留 class/score；DoubletFinder：Normalize/HVG/PCA/FindNeighbors/FindClusters/UMAP → paramSweep → 最优 pK → 同型校正 → doubletFinder，保留参数。
4. 查看 score 分布和样本差异；阈值改变时重跑下游，记录对聚类/差异分析的影响。
5. 双细胞过滤后仍检查高线粒体、低 UMI 和物种混合；这些不是同一问题。

## 代码

本目录是所选分支的最小调用闭包：复制 `code/`（以及 `runtime.json` 列出的资源）即可在课题环境运行，不再需要完整 `SCP-local`。`bundle` 参数仅为兼容旧调用而接受，函数不会读取；必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verification/*-portability.json`。

- scDblFinder：`methods/doublet-detection/code/analysis.R:run_doublet_detection(srt, bundle = NULL, parameters)` 封装 SCP `RunDoubletCalling`。本机缺 scDblFinder，精确错误为 `Missing R dependency: scDblFinder; automatic installation is disabled`，状态 `not_run`。
- DoubletFinder：青光眼 `preprocess.R` 的 paramSweep/modelHomotypic/7.5% 逻辑保留在 [[methods/scrna-preprocess-doublet-qc-harmony]] 的 `source/`；本轮未函数化、未验证，DoubletFinder 也未安装。
- 两条路线都不能因另一条通过/失败而升级；当前没有任何 verified 双细胞分支。

## 输出

运行成功时输出每细胞 doublet class 与 score、方法和参数；当前没有结果。不得用其他样本的 doublet 标签或另一种算法的结果冒充本数据输出。

## 知识关联检查

2026-10-23 检查了 UMAP 分组图与细胞比例图模板。双细胞标签可作为 UMAP 着色或样本比例，模板不执行检测，关系为 adaptable；没有 direct。双细胞 score 的分布图本库暂无专用模板。来源页 [[methods/scp-cellqc-doublet]] 与 [[methods/scrna-preprocess-doublet-qc-harmony]] 提供 SCP 与 DoubletFinder 原始实现，双向链接已建立。

## 使用记录

2026-10-23：核对 SCP scDblFinder 分支与青光眼 DoubletFinder 脚本；scDblFinder/DoubletFinder 均缺失，保留 not_run/未函数化，不安装。

<!-- user:start -->
<!-- user:end -->
