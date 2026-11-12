---
type: method
id: scp-local-source
title: SCP 源码本地化
status: ready
tags:
- 单细胞分析
keywords:
- SCP
- SingleCellPipeline
- 源码本地化
- Seurat
- reticulate
- Rcpp
- GPL-3
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
summary: SCP v0.5.6 源码本地化与加载器资料；不是可执行分析，也不是独立方法家族。
data_contract:
  input: SCP v0.5.6 原始源码、DESCRIPTION 和依赖包。
  output: 可 source 的 SCP_local 环境、加载器和补丁说明；不产生分析结果。
---
# SCP 源码本地化

<!-- facts:start -->
- 来源：https://github.com/zhanghao-njmu/scp（b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0）
- 许可证：GPL-3
- 引用：无
- 标签：单细胞分析
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：[methods/scp-local-source/code/SCP-local/DESCRIPTION](/files/wiki/methods/scp-local-source/code/SCP-local/DESCRIPTION) · [methods/scp-local-source/code/SCP-local/FUNCTIONS.csv](/files/wiki/methods/scp-local-source/code/SCP-local/FUNCTIONS.csv) · [methods/scp-local-source/code/SCP-local/LICENSE.md](/files/wiki/methods/scp-local-source/code/SCP-local/LICENSE.md) · [methods/scp-local-source/code/SCP-local/PATCHES.md](/files/wiki/methods/scp-local-source/code/SCP-local/PATCHES.md) · [methods/scp-local-source/code/SCP-local/R/SCP-analysis.R](/files/wiki/methods/scp-local-source/code/SCP-local/R/SCP-analysis.R) · [methods/scp-local-source/code/SCP-local/R/SCP-cell_annotation.R](/files/wiki/methods/scp-local-source/code/SCP-local/R/SCP-cell_annotation.R) · [methods/scp-local-source/code/SCP-local/R/SCP-cellqc.R](/files/wiki/methods/scp-local-source/code/SCP-local/R/SCP-cellqc.R) · [methods/scp-local-source/code/SCP-local/R/SCP-feature_annotation.R](/files/wiki/methods/scp-local-source/code/SCP-local/R/SCP-feature_annotation.R) · [methods/scp-local-source/code/SCP-local/R/SCP-imputation.R](/files/wiki/methods/scp-local-source/code/SCP-local/R/SCP-imputation.R) · [methods/scp-local-source/code/SCP-local/R/SCP-plot.R](/files/wiki/methods/scp-local-source/code/SCP-local/R/SCP-plot.R) · [methods/scp-local-source/code/SCP-local/R/SCP-projection.R](/files/wiki/methods/scp-local-source/code/SCP-local/R/SCP-projection.R) · [methods/scp-local-source/code/SCP-local/R/SCP-workflow.R](/files/wiki/methods/scp-local-source/code/SCP-local/R/SCP-workflow.R) · [methods/scp-local-source/code/SCP-local/R/Seurat-function.R](/files/wiki/methods/scp-local-source/code/SCP-local/R/Seurat-function.R) · [methods/scp-local-source/code/SCP-local/R/data.R](/files/wiki/methods/scp-local-source/code/SCP-local/R/data.R) · [methods/scp-local-source/code/SCP-local/R/ggsankey.R](/files/wiki/methods/scp-local-source/code/SCP-local/R/ggsankey.R) · [methods/scp-local-source/code/SCP-local/R/utils.R](/files/wiki/methods/scp-local-source/code/SCP-local/R/utils.R) · [methods/scp-local-source/code/SCP-local/README.md](/files/wiki/methods/scp-local-source/code/SCP-local/README.md) · [methods/scp-local-source/code/SCP-local/data/palette_list.rda](/files/wiki/methods/scp-local-source/code/SCP-local/data/palette_list.rda) · [methods/scp-local-source/code/SCP-local/data/words_excluded.rda](/files/wiki/methods/scp-local-source/code/SCP-local/data/words_excluded.rda) · [methods/scp-local-source/code/SCP-local/load_scp_local.R](/files/wiki/methods/scp-local-source/code/SCP-local/load_scp_local.R) · [methods/scp-local-source/code/SCP-local/python/SCP_analysis.py](/files/wiki/methods/scp-local-source/code/SCP-local/python/SCP_analysis.py) · [methods/scp-local-source/code/SCP-local/python/harmonizomeapi.py](/files/wiki/methods/scp-local-source/code/SCP-local/python/harmonizomeapi.py) · [methods/scp-local-source/code/SCP-local/src/RcppExports.cpp](/files/wiki/methods/scp-local-source/code/SCP-local/src/RcppExports.cpp) · [methods/scp-local-source/code/SCP-local/src/asMatrix.cpp](/files/wiki/methods/scp-local-source/code/SCP-local/src/asMatrix.cpp) · [methods/scp-local-source/code/SCP-local/verification.md](/files/wiki/methods/scp-local-source/code/SCP-local/verification.md) · [methods/scp-local-source/code/SCP-local/verify_local.R](/files/wiki/methods/scp-local-source/code/SCP-local/verify_local.R)

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

> **资料类型：技术/来源资料，不是默认分析家族。**
> 当前分析问题见：[[methods/cell-quality-control|单细胞质量控制]]、[[methods/doublet-detection|双细胞检测]]、[[methods/batch-integration|单细胞批次整合]]、[[methods/differential-expression|差异表达分析]]、[[methods/gene-set-enrichment|基因集富集分析]]、[[methods/gene-set-scoring|基因集与通路签名打分]]、[[methods/trajectory-inference|拟时序与轨迹推断]]、[[methods/rna-velocity|RNA 速度分析]]、[[methods/cell-type-annotation|细胞类型注释]]、[[methods/reference-mapping|参考图谱映射]]、[[methods/dimensionality-reduction|单细胞降维分析]]、[[methods/cell-clustering|单细胞聚类分析]]、[[methods/dynamic-feature-analysis|拟时序动态特征分析]]。原代码与作者备注保留；本页不再作为分析推荐卡片。

## 用途

把 SCP v0.5.6 的 R/Python 源码复制到本知识库，做成可直接 `source()` 的本地函数集合；不安装、不加载 `SCP` 包，也不依赖 `SCP::` 命名空间。适合需要固定版本、审计/修改源码、或在不能安装 GitHub 包的课题环境中复用 SCP 实现的情况。

本地化包位于 `code/SCP-local/`；上游原字节归档在 `source/`，两者分开。该整库保留用于历史归档、审计与原版对照。课题优先复制各规范家族声明的 standalone 闭包，是否验证以当前分支收据为准；全库逐项去向见 [[methods/scp-source-catalog|来源与入口索引]]。

## 适用

- 作者课题环境已有或准备安装 Seurat、SeuratObject 和所需 Bioconductor 包；只希望避免安装 SCP 包本身。
- 需要把函数源码复制到课题、按课题修改参数或加日志；需要保留上游 commit、许可证和补丁记录。
- 需要离线阅读/检索 SCP 的原始顶层定义（本次按固定快照重新解析为 238 项），而不是只看到 `SCP::` 调用。
- 需要把绘图函数固定在某一个版本，避免上游更新改变行为。

## 不适用

- 不能替代 R 包的环境管理：本地包没有 NAMESPACE，依赖靠 `library()` attach；缺包时函数在调用时才会失败。
- 不能保证所有函数可运行：`SCP-app.R`（SCExplorer/Shiny）未收录；Python 后端仍需 reticulate 与 conda/venv；Rcpp 代码用纯 R 替代，未编译。
- 不能证明数值等价或科学有效：2026-10-22 历史记录当时未安装 Seurat/SCP 依赖，未运行 SCP 算法；`verify_local.R` 只检查加载、补丁完整性和少数无 Seurat 依赖的函数。2026-10-23 当前隔离库已有 Seurat 5.6.0/SeuratObject 5.4.0、slingshot、clusterProfiler；部分规范家族分支已实际调用并有收据，缺依赖分支仍 `not_run`。见各家族页；不宣称所有算法已运行或数值等价。
- 不适合把本地包当成公共 R 包分发；它是课题内源码副本，不是 CRAN/Bioconductor 包。
- 不能把 `source/` 的原字节与 `code/` 的补丁版混为一谈；引用/修改时以 `code/` 为准，溯源以 `source/` 和 commit 为准。

## 输入

- 上游源码：`https://github.com/zhanghao-njmu/scp`，commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`，Version 0.5.6，License GPL (>= 3)。
- 作者的 R 环境：R >= 4.1；Seurat/SeuratObject、Bioconductor 包和绘图包按所用函数安装。
- Python 环境（仅 Python 后端函数）：scanpy、scvelo、cellrank、palantir、wot、magic-impute、matplotlib、numpy、pandas；Leiden 需要 leidenalg。
- 作者数据：Seurat 对象或函数要求的矩阵/表；本地包不提供示例数据（`pancreas_sub`、`panc8_sub`、`ifnb_sub`）和参考图谱（`ref_scHCL`、`ref_scMCA`、`ref_scZCL`）。

## 怎么做

1. 复制 `code/SCP-local/` 到课题目录；保留 `R/`、`python/`、`data/`、`DESCRIPTION`、`LICENSE.md` 的相对结构。
2. 在课题 R 会话中 `source(".../load_scp_local.R")`。加载器会：
   - 先按 `options(SCP.local.root = "...")` 或环境变量 `SCP_LOCAL_ROOT` 解析本地包根目录；两者都未设置时才使用 `source()` 的文件路径。嵌套 `source()` 场景应显式设置，避免 `ofile` 继承调用者；
   - 读取 `DESCRIPTION` 的 Depends/Imports，attach 已安装的包；缺失包给出警告；
   - 载入 `palette_list`、`words_excluded`；
   - 定义纯 R `asMatrix()`；
   - 定义 `GetAssayData`/`SetAssayData` 兼容 shim，把 SeuratObject >= 5 已废弃的 `slot` 参数转成 `layer`；
   - 把 12 个 R 文件 source 进 `SCP_local` 环境；
   - 不 attach `R.utils`（避免其 S3 `draw` 遮蔽 ComplexHeatmap 的 S4 `draw`），但保留 `R.utils::gunzip` 的命名空间调用；
   - 设置 `future.globals.maxSize = Inf`（与上游 `.onAttach()` 一致）。
3. 调用方式：`SCP_local$RunCellQC(...)`，或 `scp_local_attach()` 后直接 `RunCellQC(...)`，或 `scp_local_export(c("RunCellQC", "CellDimPlot"))`。
4. 按方法族页的“怎么做”检查数据前提、参数和诊断；本地化只改变命名空间/路径/编译代码，不改变算法。
5. Python 后端函数需要先配置 reticulate 的 Python 环境；本地化只把 `system.file("python", package="SCP")` 改为 `scp_local_python_path()`，不创建环境。
6. 修改源码时在 `PATCHES.md` 追加记录；不要直接改 `source/` 的原字节。改动统计逻辑前先与作者确认并另做验证。

## 代码

- `code/SCP-local/R/`：12 个上游 R 文件的最小补丁副本。
- `code/SCP-local/python/`：`SCP_analysis.py`、`harmonizomeapi.py`。
- `code/SCP-local/data/`：`palette_list.rda`、`words_excluded.rda`。
- `code/SCP-local/src/`：`asMatrix.cpp`、`RcppExports.cpp`，仅作溯源，不编译。
- `code/SCP-local/load_scp_local.R`：加载器；定义 `SCP_local`、`scp_local_attach()`、`scp_local_export()`、`scp_local_list()`。
- `code/SCP-local/FUNCTIONS.csv`：历史加载器索引，不能作为当前上游导出计数；固定快照重新核对为 142 个 NAMESPACE 导出和 238 个 R 顶层定义，见 [[methods/scp-source-catalog|全库来源索引]]。
- `code/SCP-local/PATCHES.md`：逐项补丁、排除文件、已知原实现细节。
- `code/SCP-local/README.md`：快速开始、依赖、限制。
- `code/SCP-local/verify_local.R`：可重复的静态/免 Seurat 运行检查；2026-10-22 记录 61 PASS / 0 FAIL，2026-10-23 未重跑该脚本。
- `code/SCP-local/verification.md`：2026-10-22 命令、覆盖范围、未覆盖项与环境清单；当前算法范围另见各家族收据。

代码状态：2026-10-22/23 记录本地包已实际 `source()` 通过（`SCP_local` 236 个对象），并执行了 `isOutlier()`、`capitalize()`、`as_matrix()` 与 `asMatrix()` 的小数据检查；隔离库已有 Seurat 5.6.0/SeuratObject 5.4.0，`pancreas_sub` 示例上跑通了 `CellDimPlot`、`FeatureDimPlot`、`CellStatPlot`、`FeatureStatPlot`、`CellDensityPlot`、`GroupHeatmap`、`VolcanoPlot` 等图。2026-10-23 规范家族补验：DE、Slingshot、Seurat_integrate 等分支通过；RunSeuratMap 投影、部分富集/轨迹/速度分支仍 `not_run`，见各家族页与收据。不宣称数值等价或所有算法可用。

## 输出

- R 会话中的 `SCP_local` 环境：历史加载器暴露的函数名数量按其 FUNCTIONS.csv 解释；上游 NAMESPACE 实际有 142 个导出（含重导出），不以历史加载器计数替代。加载器还包含内部辅助函数、`palette_list`、`words_excluded`、`asMatrix`。
- 可选：`scp_local_attach()` 挂到搜索路径；`scp_local_export()` 把指定函数复制到全局环境。
- 不产生分析结果表或图；各方法族页负责说明如何把 SCP 返回的 Seurat 对象/tools 槽整理成图接口表。

## 知识关联检查

2026-10-23 分类为技术/来源资料：旧 id、`source/` 原字节和作者备注保留，但不再作为默认分析家族推荐。语义配图关系已迁往 [[methods/cell-quality-control|单细胞质量控制]]、[[methods/doublet-detection|双细胞检测]]、[[methods/batch-integration|单细胞批次整合]]、[[methods/differential-expression|差异表达分析]]、[[methods/gene-set-enrichment|基因集富集分析]]、[[methods/gene-set-scoring|基因集与通路签名打分]]、[[methods/trajectory-inference|拟时序与轨迹推断]]、[[methods/rna-velocity|RNA 速度分析]]、[[methods/cell-type-annotation|细胞类型注释]]、[[methods/reference-mapping|参考图谱映射]]、[[methods/dimensionality-reduction|单细胞降维分析]]、[[methods/cell-clustering|单细胞聚类分析]]、[[methods/dynamic-feature-analysis|拟时序动态特征分析]]；本页只保留来源与实现证据链接，不再维护 `figure_relations` 主记录。原页面正文中的模板/证据链接仍可用于溯源；结构相似不等于科学直连。


### scop 候选来源（未运行）

后续衍生来源见 [[methods/scop-source-catalog|scop 0.9.2 来源]]。其 object/layer、thisplot/thisutils 与 C++ 依赖不能由本历史加载器或旧 SCP 收据替代；本页原字节和兼容代码不改。

## 使用记录

2026-10-22 建页；从 commit `b9b0eb7` 归档 23 个原始文件，生成 12 个 R 文件的最小补丁副本；`verify_local.R` 全部通过（0 failure）。按作者代签授权标为 ready；验收记录见 `acceptance.json`。

2026-10-22 追加根目录显式解析补丁（`SCP.local.root` / `SCP_LOCAL_ROOT` 优先），修复嵌套 `source()` 时路径继承；补丁后 `verify_local.R` 61 PASS / 0 FAIL。补丁记录在 `code/SCP-local/PATCHES.md`。

<!-- user:start -->
<!-- user:end -->
