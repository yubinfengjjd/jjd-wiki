> 2026-10-23 复验说明：本文件只记录 source-only 加载级 61 PASS，不是分析算法验证。当前隔离环境已补齐 Seurat 5.6.0、SeuratObject 5.4.0、slingshot 2.16.0、clusterProfiler 4.16.0；各分析分支的实际调用与 not_run 见 `knowledge base methods/*/verification/*.json`。下面的 2026-10-22 缺失包清单保留为历史环境记录。

# Verification

日期 2026-10-22；环境 Windows 11，R 4.5.0，Rscript `D:\R-4.5.0\bin\Rscript.exe`。

命令：

```powershell
Rscript --vanilla verify_local.R
```

结果：**61 PASS，0 FAIL**。覆盖：

- `source()` 加载本地源码，不需要安装 SCP；`SCP_local` 环境 236 个对象。
- 48 个核心分析/绘图函数已定义。
- 5 个 SCP-app 函数被排除（`CreateDataFile`、`CreateMetaFile`、`FetchH5`、`PrepareSCExplorer`、`RunSCExplorer`）。
- `palette_list`、`words_excluded` 数据对象已载入。
- `isOutlier()`、`capitalize()`、`as_matrix()`、纯 R `asMatrix()` 小数据执行。
- 本地化 R 文件中没有残留 `SCP::`、`system.file(..., package="SCP")` 或 `.Call`。
- `FUNCTIONS.csv` 中标记为 `localized=yes` 的 NAMESPACE 导出全部存在。

未覆盖：

- Seurat/SCP 算法函数（`RunCellQC`、`Standard_SCP`、`Integration_SCP`、`RunDEtest`、注释、轨迹、速度等）未运行；依赖包缺失。
- Python 后端（PAGA/scVelo/Palantir/WOT/CellRank）未运行。
- 数值等价、真实数据表现、科学有效性未验证。
- `as_matrix()` 因上游条件 `inherits(matrix, ...)` 实际走 `as.matrix()` 分支；`asMatrix()` 测试只检查纯 R 版本的索引语义，未与编译版 C++ 对比。

当前 R 环境缺失的上游 Imports：

`biomaRt`、`circlize`、`ComplexHeatmap`、`HDF5Array`、`intrinsicDimension`、`proxyC`、`R.cache`、`reticulate`、`rhdf5`、`simplifyEnrichment`、`slingshot`、`Signac`、`Seurat`、`SeuratObject`、`uwot`。

复现建议：在作者课题的 R 环境安装上述包后，先运行 `verify_local.R`，再用小数据/示例数据逐函数检查；不要由本页的加载通过推断算法可用。
