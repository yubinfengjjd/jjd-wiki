# 2026-10-22-scp-example__fig09-bar

SCP v0.5.6 原生 `CellStatPlot(plot_type = "bar")` 样张，使用 `pancreas_sub` 示例数据。来源图由未修改的上游函数在固定设备上生成，不是从帖子截图估读。

## 来源

- 仓库：<https://github.com/zhanghao-njmu/scp>
- commit：`b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`（SCP 0.5.6）
- 原文件：`R/SCP-plot.R` 的 `CellStatPlot`（4463–4490 行）与 `StatPlot`（4564–5624 行）；`original_code/cellstat.R` 是 4463–5678 行的逐字节摘录，含两函数之间的 roxygen 块
- 许可证：GPL (>= 3)
- 原始调用：

```r
CellStatPlot(pancreas_sub, stat.by = "Phase", group.by = "CellType",
             stat_type = "count", plot_type = "bar", label = TRUE)
# ggsave 8 x 6 in, 150 dpi, bg = "white"
```

- 原图：`source/fig09.png`，SHA256 `d9375658c7c439c9da75cf735d68211c5acb666fd282c2955d33cdc10d58ba71`
- 参考 panel：`source/reference_panel.png`（Example-2.jpg 第 2 格，bbox [484, 0, 969, 337]）；完整原图 `source/full_original.jpg`，SHA256 `a63a3a53beb2c052a4c0278bbeec477c4d741f889d8551808fdcdee9471e4814`

## 输入与数据

`data/render-cell-metadata.csv` 共 1000 行，每行一个细胞，来自 `pancreas_sub@meta.data`：

| 列 | 含义 |
|---|---|
| `cell` | 细胞标识；同一图内唯一 |
| `CellType` | 分组 / x 轴类别；每个细胞一个值；显式顺序 Ductal → Ngn3 low EP → Ngn3 high EP → Pre-endocrine → Endocrine（`meta.data$CellType` 的 factor levels） |
| `Phase` | 系列类别；每个细胞一个值；显式顺序 G1 → S → G2M（`meta.data$Phase` 的 factor levels） |

CSV 中点值的出现顺序与 factor levels 不同（`unique()` 顺序），分类顺序必须由显式 levels 提供，不能依赖 CSV 行序。

`data/phase_by_celltype.csv` 是同一数据的 15 行聚合表（count + proportion），仅用于溯源的 QA 对照；模板读取细胞级表并调用原 `StatPlot` 的 xtabs 计数步骤。`data/estimated_data.csv` 是 QA 工具要求的同内容副本；本图数据不是估读值。

## 代码结构

- `original_code/cellstat.R`：上游 `CellStatPlot` 与 `StatPlot` 的只读摘录；`provenance.json` 记录完整文件哈希、函数与摘录行号、摘录哈希。
- `code/scp_bar_native.R`：函数化副本。`scp_stat_table()` 做计数表（xtabs + dplyr）；`plot_scp_stat()` 逐行保留上游 ggplot 构造（bar 分支 4821–4831）；`scp_stat_meta()` 串联原始元数据入口；`scp_stat_values()` 是显式表入口（本图未用）。
- `code/scp_helpers.R`：`theme_scp()`、`palette_scp()`、`capitalize()` 的本地副本，配 `code/data/palette_list.rda`；只把 `palette_list` 的来源从 `SCP::palette_list` 改为本地环境。
- `code/core.R`：本地加载 helpers 和 core，不依赖安装的 SCP 包或 Wiki 路径。
- `code/render.R`：读取 `data/render-cell-metadata.csv`，调用 `scp_stat_meta()`（内部 `scp_stat_table()` + `plot_scp_stat()`），导出 PNG/PDF/SVG。
- `code/replica.R`：画廊标准入口，转调 `render.R`。
- `PATCHES.md`：与上游 bar 路径的全部差异、理由与逐字节证据。

## 运行

```powershell
cd E:/research-wiki-env/work/scp-native-claude/s2/bar/gallery
Rscript --vanilla code/replica.R
```

隔离环境变量（本机）：

```powershell
$env:PROCESSOR_ARCHITECTURE='AMD64'
Remove-Item Env:LANG,Env:LC_ALL,Env:LC_CTYPE -ErrorAction SilentlyContinue
$env:TEMP=$env:TMP='E:/research-wiki-env/tmp'
$env:MPLCONFIGDIR='E:/research-wiki-env/tmp/mpl'
$env:R_LIBS_USER='E:/research-wiki-env/R-lib-scp/4.5'
```

## 产物

- `output/replica.png`：1200×900，SHA256 `d9375658c7c439c9da75cf735d68211c5acb666fd282c2955d33cdc10d58ba71`
- `output/replica.pdf`、`output/replica.svg`（svglite；SVG 与 source 逐字节一致）
- `compare/side_by_side.png`、`compare/overlay.png`
- `thumb.png`：480×360
- `qa_report.md`、`run.log`

## 验证

- 原版与函数化版在相同调用、相同 8×6@150 设备下 PNG 逐字节一致（像素 mad = 0，RMS = 0）；SVG 亦逐字节一致；PDF 有一个尾部压缩流字节不同（cairo 内部标识），页面内容未观察到差异。
- 表半 `scp_stat_table()` 与上游 `ggplot$data`：列名、列类型、factor levels、行序、行名与每个值全部相同；`identical()` 仅在 core 额外附加的 5 个 provenance attributes 上为 FALSE，去掉这些 attributes 后为 TRUE。
- bar 分支六种组合（stack/dodge × count/percent × label × flip）均与上游逐字节一致：`../source/variants/compare.csv`。
- 模板固定模式输出与 `source/fig09.png` 同哈希；adaptive、上限拒绝、输入不变、异目录复制见 `../evidence.json`。

## 保留差异与限制

- 参考 panel（Example-2.jpg 第 2 格）与记录的 native call 同为 `position = "stack"` 的计数柱；第 1 格是 `position = "dodge"` 的变体，dodge 也已逐字节核对，但不作为本 entry 的参考 panel。
- 上游 `CellStatPlot` 没有独立表入口；`scp_stat_values()` 是本仓库新增的显式表入口，要求显式列映射与顺序。
- `NA_stat = TRUE` 的缺失类别、`bg.by` 背景变量、`split.by`、`individual = TRUE` 与多 `stat.by` 未在本样张中运行；模板不支持这些分支。
- 字体仅拉丁字符；未验证中文标签。
