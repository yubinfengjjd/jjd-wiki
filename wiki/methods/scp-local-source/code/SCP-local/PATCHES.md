# 本地化补丁清单

上游：`https://github.com/zhanghao-njmu/scp`，commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`，`DESCRIPTION` Version 0.5.6，License GPL (>= 3)。

本地化目标：在**不安装 SCP 包**的前提下，用 `source()` 定义 SCP 的函数。外部依赖（Seurat、Bioconductor、Python 等）仍由作者课题环境提供。

## 收录与排除

`code/SCP-local/R/` 收录 12 个源文件：

`utils.R`、`Seurat-function.R`、`ggsankey.R`、`SCP-cellqc.R`、`SCP-workflow.R`、`SCP-cell_annotation.R`、`SCP-projection.R`、`SCP-analysis.R`、`SCP-plot.R`、`SCP-feature_annotation.R`、`data.R`、`SCP-imputation.R`。

未收录：

- `SCP-app.R`：SCExplorer/Shiny 应用层；其中的 `CreateDataFile`、`CreateMetaFile`、`FetchH5`、`PrepareSCExplorer`、`RunSCExplorer` 不在本地化范围。
- `RcppExports.R`：Rcpp 注册代码；改由 `load_scp_local.R` 中的纯 R `asMatrix()` 代替。
- `reexports.R`：`%>%`、`%||%`、`unit`、`arrow`、`gpar` 由已安装的 dplyr/rlang/grid 提供，不重复定义。
- `zzz.R`：`.onAttach()` 不执行；`load_scp_local.R` 自行设置 `future.globals.maxSize`。
- `data/` 只带 `palette_list.rda` 与 `words_excluded.rda`；示例数据（`pancreas_sub`、`panc8_sub`、`ifnb_sub`）和参考图谱（`ref_scHCL`、`ref_scMCA`、`ref_scZCL`）未带入。

## 代码补丁

| 文件 | 原文 | 本地化后 | 次数 | 原因 |
|---|---|---|---|---|
| `SCP-plot.R` | `SCP::palette_list` | `palette_list` | 2 | 去掉对 SCP 命名空间的依赖；对象由 `data/palette_list.rda` 载入 |
| `SCP-plot.R` | `SCP::words_excluded` | `words_excluded` | 4 | 同上；对象由 `data/words_excluded.rda` 载入 |
| `SCP-analysis.R` | `system.file("python", package = "SCP", mustWork = TRUE)` | `scp_local_python_path()` | 5 | 指向本目录的 `python/`，供 `reticulate::import_from_path()` 使用 |
| `RcppExports.R` | `.Call('_SCP_asMatrix', PACKAGE = 'SCP', ...)` | `load_scp_local.R` 中的纯 R `asMatrix()` | 1 | 不编译 `src/`；保留 `src/asMatrix.cpp` 作为溯源 |
| `reexports.R` / `zzz.R` | 包级 re-export / `.onAttach()` | 不 source | — | 由加载器和依赖包替代 |
| `GetAssayData()` / `SetAssayData()` 调用 | `slot = "data"` 等 | `SCP_local` 中的同名 shim 转为 `layer =` | 多处 | SeuratObject >= 5 将 `slot` 参数改为 `layer` 并设为 defunct；SCP 0.5.6 仍用 `slot` |
| `Assays(object, assay)` shim | `SeuratObject::GetAssay()` | `Seurat::GetAssay()` | 1 | `GetAssay` 由 Seurat 导出，SeuratObject 未导出；修复 Seurat 5 下 DE 等调用报错 |

### 2026-10-22：根目录解析优先级（路径补丁）

`load_scp_local.R` 先读 `getOption("SCP.local.root")` / `SCP_LOCAL_ROOT`，两者都为空时才退回 `sys.frame(1)$ofile`。原因：`replica.R -> render.R` 这类嵌套 `source()` 中，`sys.frame(1)$ofile` 会继承调用者文件，根目录被错误解析成 `code/`，进而找不到 `R/utils.R`。显式设置后，同一本地包可从任意工作目录加载。仅改路径解析，不改函数逻辑或默认参数。

复验：`verify_local.R` 在补丁后 61 PASS / 0 FAIL（2026-10-22）。

除上述命名空间/路径/编译代码适配外，**未修改函数的统计逻辑、算法参数默认值或输出结构**。

## 已知原实现细节（保留，不修正）

- `utils.R` 的 `as_matrix()` 条件写作 `if (!inherits(matrix, "dgCMatrix"))`，检查的是 `matrix` 函数而不是 `x`。因此当前上游版本实际总是走 `as.matrix(x)` 分支，`asMatrix()` 分支未被调用。本地化保留原条件。
- `src/asMatrix.cpp` 以 C++ 0 基行号、1 基列号写入矩阵；`load_scp_local.R` 的纯 R 版本用 `rp + 1L` 与 `cp` 复现同一索引语义。由于上面的条件，该分支在正常调用中不会触发。
- `SCP-cell_annotation.R` 的 roxygen 注释仍提到 `SCP::ref_scHCL`；这是文档注释，不影响代码。参考图谱未随本地化包提供。

## 依赖与副作用

- `load_scp_local.R` 会尝试 attach `DESCRIPTION` 中 Depends/Imports 里已安装的包；缺失的包只警告，不阻止 source。函数真正用到缺失包时才报错。
- 默认设置 `options(future.globals.maxSize = Inf)`，与上游 `.onAttach()` 一致；如课题有更严格限制，可在 source 后改回。
- `scp_local_attach()` 会把 `SCP_local` 环境挂到搜索路径；不调用时使用 `SCP_local$函数名()`。
- `R.utils` 不 attach：它导出的 S3 `draw()` 会遮蔽 ComplexHeatmap 的 S4 `draw()`，导致 `GroupHeatmap()` 等热图无法绘制。SCP 对 R.utils 的调用均为 `R.utils::gunzip()`，保留命名空间即可。
- SeuratObject >= 5 已把 `GetAssayData`/`SetAssayData` 的 `slot` 参数改为 `layer` 并设为 defunct；加载器用同名 shim 转换。SCP 中仍使用 `Assays(object, assay)` 等 Seurat 4 API 的函数（如 `RunDEtest`）未全部适配，调用前需检查。
- 加载器还提供 `Assays(object, assay)` shim（Seurat 4 语义：带 assay 时返回 assay 对象）和 `select()` shim（按第一个参数是否为 AnnotationDb/OrgDb 分派到 AnnotationDbi 或 dplyr），因为 attach 全部 Imports 后 dplyr 会遮蔽 AnnotationDbi。`RunDEtest` 仍受 Seurat 5 `FindMarkers` 参数变化影响，示例中改用 `Seurat::FindMarkers` 生成 DE 表。
- Python 后端函数（`RunPAGA`、`RunSCVELO`、`RunPalantir`、`RunWOT`、`RunCellRank` 等）仍需要 reticulate 与对应 Python 包；本地化只改了 `system.file()` 路径，没有创建 Python 环境。
