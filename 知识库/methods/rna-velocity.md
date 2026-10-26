---
type: method
id: rna-velocity
title: RNA 速度分析
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
- 轨迹与动态分析
summary: 利用 spliced/unspliced 计数推断转录动态方向；当前 Python 后端缺失，函数保留但未运行。
data_contract:
  input: 含 spliced/unspliced layers 的 Seurat 对象或 AnnData；同一细胞集合的剪接/未剪接计数。
  output: velocity 图、latent time、velocity confidence（运行成功时）；当前未产生结果。
implementations:
- id: scp-scvelo
  title: SCP RunSCVELO 分支
  language: R
  entrypoint: code/analysis.R:run_rna_velocity
  dependencies:
  - reticulate
  - Seurat
  - SeuratObject
  - Matrix
  - rlang
  - scanpy
  - numpy
  - scvelo
  verification: verification/scp-scvelo-standalone.json
keywords:
- RNA velocity
- scVelo
- spliced
- unspliced
- latent time
- SCP
figure_relations: []
---
# RNA 速度分析

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：SCP: https://github.com/zhanghao-njmu/scp (commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0)
- 标签：单细胞分析
- 分析用途：轨迹与动态分析
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/rna-velocity/code/analysis.R](/files/wiki/methods/rna-velocity/code/analysis.R) · [methods/rna-velocity/code/data/palette_list.rda](/files/wiki/methods/rna-velocity/code/data/palette_list.rda) · [methods/rna-velocity/code/velocity_native.R](/files/wiki/methods/rna-velocity/code/velocity_native.R)

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 用途

从剪接（spliced）和未剪接（unspliced）计数估计每个细胞的转录速率方向，在嵌入上显示速度箭头、latent time 或驱动基因。用于提出方向性假设，不是直接观测细胞命运。

## 原理与选择

scVelo 等模型假设剪接动力学可解释未剪接/剪接比例；steady-state、stochastic、dynamical 等模式对数据和先验要求不同。SCP `RunSCVELO` 通过 reticulate 调 Python scVelo，需要 spliced/unspliced layers、速度基因和合适的降维。本页只封装该分支；本机没有 reticulate 可用的 Python 后端和 scvelo/scanpy/numpy，函数未运行。



## 来源与实现选择

| 策略 / 实现 | 原始来源 | 输入与目标 | 本库状态 |
|---|---|---|---|
| SCP `RunSCVELO`（scVelo） | [[methods/scp-trajectory-velocity]]；`SCP-local/R/SCP-analysis.R` | spliced/unspliced + 降维；速度/潜时间 | 已封装；RETICULATE_PYTHON/scVelo 缺失，`not_run` |
| 其他 velocity 实现 | — | 需不同层/模型 | 未实现；不以其他算法冒充 |
| 青光眼课题 | `source/` 中未发现独立 velocity 脚本 | — | 不声称有独立课题实现 |
## 适用

- 有真实的 spliced/unspliced 计数（例如 velocyto、STARsolo 等产出），且与表达矩阵同一细胞。
- 数据深度足够、速度基因可识别；有明确的嵌入和细胞群。
- 用于方向性探索，并用独立时间点/谱系信息验证。

## 不适用

- 只有成熟 mRNA counts、没有 intron/unspliced 信息；或不同样本/平台的层定义不一致。
- 把速度箭头当作因果方向、真实时间或细胞命运决定。
- 数据稀疏、速度基因很少时，强行解释箭头。

## 输入

Seurat 对象的 `spliced`/`unspliced` assay/layers，或 AnnData；需显式 `assay_X`、`assay_layers`、`group_by` 和降维。每个细胞一行速度/潜时间结果（运行成功时）。

## 怎么做

1. 核对 spliced/unspliced 的来源、参考基因组和细胞条码一致性；确认不是把 total counts 复制成两层。
2. 在课题 Python 环境准备 scVelo/scanpy，设置 `RETICULATE_PYTHON`；知识库不安装。
3. 按 scVelo 流程做过滤、moments、速度基因和速度图；记录模式、kNN、PC 数。
4. 检查速度与已知 marker/时间点的一致性，做参数敏感性分析；没有验证时只报告探索性方向。
5. 若只有 R 环境，不要用其他算法的输出冒充 RNA velocity。

## 代码

本目录是所选分支的最小调用闭包：复制 `code/`（以及 `runtime.json` 列出的资源）即可在课题环境运行，不再需要完整 `SCP-local`。`bundle` 参数仅为兼容旧调用而接受，函数不会读取；必要/可选依赖、复制清单和独立性证据见 `runtime.json` 与 `verification/*-portability.json`。

入口 `methods/rna-velocity/code/analysis.R:run_rna_velocity(srt, bundle = NULL, parameters)`，封装 SCP `RunSCVELO`。本机执行时在 `check_Python("scvelo")` 处停止，精确错误为 `Set RETICULATE_PYTHON to an existing project interpreter; installation disabled`；未设置后端、未安装 scvelo/scanpy/numpy，函数保留为 `not_run`。

该分支不能由其他家族的通过结果批准；即使以后设置 Python 后端，也需重新运行并写独立收据。

## 输出

运行成功时由 scVelo 生成速度图、latent time、velocity confidence 和驱动基因表；当前没有输出。不得用普通 UMAP 分组图冒充速度图。

## 知识关联检查

2026-10-23 检查了现有 UMAP/特征图模板。它们不能画 velocity 箭头、流线或 latent time 场，普通分组 UMAP 也不表达速度方向；本库暂无速度专用模板，因此不建立 figure_relations。无图原因：缺少语义匹配的速度图模板，不用“结构像”强行直连。

## 使用记录

2026-10-23：核对 SCP RunSCVELO 与本机 reticulate/Python 依赖；后端缺失，保留 not_run，未安装。

<!-- user:start -->
<!-- user:end -->
