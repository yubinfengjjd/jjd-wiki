# SCP 本地化源码包

SCP v0.5.6 的源码副本，已做最小补丁，使函数可以在**不安装 SCP 包**的情况下通过 `source()` 使用。上游 commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`，License GPL (>= 3)。补丁逐项见 `PATCHES.md`。

## 快速开始

```r
source("path/to/SCP-local/load_scp_local.R")

# 方式一：显式调用本地环境
srt <- SCP_local$RunCellQC(srt, split.by = "sample")

# 方式二：挂到搜索路径后直接调用
scp_local_attach()
srt <- RunCellQC(srt, split.by = "sample")

# 只导出需要的函数到全局环境
scp_local_export(c("RunCellQC", "Standard_SCP", "CellDimPlot"))
```

`load_scp_local.R` 会：

1. 尝试 attach `DESCRIPTION` 中 Depends/Imports 里已安装的包；缺失包只警告。
2. 载入 `palette_list` 与 `words_excluded` 两个数据对象。
3. 定义纯 R 的 `asMatrix()`，替代 Rcpp 版本。
4. 把 12 个 R 源文件 source 进 `SCP_local` 环境。
5. 设置 `options(future.globals.maxSize = Inf)`（与上游 `.onAttach()` 一致）。

函数在 `SCP_local` 环境里互相调用，不污染全局环境；`scp_local_attach()` 才会挂到搜索路径。

## 收录范围

- `R/`：12 个上游 R 源文件（`SCP-app.R`、`RcppExports.R`、`reexports.R`、`zzz.R` 除外）。
- `python/`：`SCP_analysis.py`、`harmonizomeapi.py`。
- `data/`：`palette_list.rda`、`words_excluded.rda`。
- `src/`：`asMatrix.cpp`、`RcppExports.cpp`，仅作溯源，不编译。
- `FUNCTIONS.csv`：172 个 NAMESPACE 导出与 226 个顶层定义的索引；162 个导出由本地源码定义。10 个例外：`%>%`、`%||%`、`unit`、`arrow`、`gpar` 由依赖包提供；`CreateDataFile`、`CreateMetaFile`、`FetchH5`、`PrepareSCExplorer`、`RunSCExplorer` 属于未收录的 `SCP-app.R`。
- `verify_local.R`：静态与免 Seurat 运行检查；当前 0 failure。

## 依赖

当前 R 4.5.0 环境可加载本地源码，但下列上游 Imports 尚未安装，调用相关函数前需要在课题环境安装：

`biomaRt`、`circlize`、`ComplexHeatmap`、`HDF5Array`、`intrinsicDimension`、`proxyC`、`R.cache`、`reticulate`、`rhdf5`、`simplifyEnrichment`、`slingshot`、`Signac`、`Seurat`、`SeuratObject`、`uwot`。

已安装并会被 attach 的 Imports：`AnnotationDbi`、`BiocParallel`、`clusterProfiler`、`data.table`、`dplyr`、`future`、`future.apply`、`ggnewscale`、`ggplot2`、`ggrepel`、`ggforce`、`GO.db`、`GOSemSim`、`grDevices`、`grid`、`gtable`、`igraph`、`methods`、`mgcv`、`Matrix`、`patchwork`、`pbapply`、`png`、`plotly`、`R.utils`、`reshape2`、`rlang`、`scales`。

方法族另有 Suggests 依赖，按需安装：

- QC/双细胞：`scDblFinder`、`scds`；Scrublet/DoubletDetection 需要 Python。
- 注释/投影：`SingleR`、`scmap`、`symphony`、`SingleCellExperiment`、`SummarizedExperiment`、`S4Vectors`。
- 整合：`harmony`、`batchelor`、`conos`、`sva`、`glmGamPoi`、`RcppML`、`RcppParallel`。
- 轨迹：`monocle`、`DDRTree`、`destiny`、`slingshot`。
- 富集：`org.Hs.eg.db`、`org.Mm.eg.db`、`reactome.db`、`PFAM.db`、`ggwordcloud`、`ggupset`、`ggVennDiagram`。
- 打分：`AUCell`、`UCell`。

Python 后端（`RunPAGA`、`RunSCVELO`、`RunCellRank`、`RunPalantir`、`RunWOT`）还需要 reticulate 和对应 Python 包：`scanpy`、`scvelo`、`cellrank`、`palantir`、`wot`、`magic-impute`、`matplotlib`、`numpy`、`pandas`；Leiden 聚类需要 `leidenalg`。本地化包不创建 Python 环境。

## 限制

- 这是源码副本，不是 R 包；没有 NAMESPACE 导入机制，依赖靠 attach。若你的项目已 attach 同名函数，可能发生遮蔽；用 `SCP_local$函数名()` 最明确。
- `SCP-app.R`（SCExplorer/Shiny）未本地化。
- Rcpp `asMatrix()` 用纯 R 版本替代；`utils.R::as_matrix()` 的原条件检查的是 `matrix` 函数，当前上游版本实际走 `as.matrix()` 分支，本地化未修正。
- 示例数据和参考图谱未带入；需要时从上游仓库或作者数据获取。
- 未在安装 Seurat/SCP 依赖的环境中运行 SCP 算法；数值等价、真实数据表现和科学有效性未验证。`verify_local.R` 只证明源码可加载、命名空间/路径补丁完整、少数不依赖 Seurat 的函数可执行。
