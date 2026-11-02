# 2026-10-22-scp-example__fig10-sankey

SCP v0.5.6 原生 `CellStatPlot(stat.by = c("CellType", "Phase"), plot_type = "sankey")` 样张，使用 `pancreas_sub` 示例数据。来源图由上游 `CellStatPlot()` / `StatPlot()` 在固定设备上生成，不是从帖子截图估读。

## 来源

- 仓库：<https://github.com/zhanghao-njmu/scp>
- commit：`b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`（SCP 0.5.6）
- 原文件：`R/SCP-plot.R` 的 `CellStatPlot`（4463–4563 行）与 `StatPlot`（4564–5678 行）；`R/ggsankey.R` 的 `make_long`/`geom_sankey` 等
- 许可证：GPL (>= 3)
- 原始调用：

```r
CellStatPlot(pancreas_sub, stat.by = c("CellType", "Phase"), plot_type = "sankey")
# ggsave 8 x 6 in, 150 dpi, white background, seed 11
```

- 原图：`source/fig10.png`，SHA256 `7b16c62001e6780ff1c4fd2bee40eb230127704717bc37b4a792afc675fcbf95`
- 参考 panel：`source/reference_panel.png`（Example-2.jpg 第 12 格，bbox [1454, 675, 1939, 1013]）

## 兼容性补丁

上游 `StatPlot()` 在当前依赖版本（patchwork 1.3.1 / gtable 0.3.6 / ggplot2 3.5.2）下无法直接出图。逐条补丁、原因、替换与几何不变证明见 `PATCHES.md`；`code/scp_helpers.R` 与 `code/scp_sankey_native.R` 的文件头也记录了同样的补丁。source 与 replica 使用同一套打过补丁的函数。

## 输入与数据

`data/render-cell-linkage.csv` 共 2000 行，是“一个细胞 × 一个维度”的长表，来自 `pancreas_sub@meta.data`：

| 列 | 含义 |
|---|---|
| `cell` | 细胞标识；同一维度内唯一；每个细胞每个维度一行 |
| `dimension` | 维度名；`CellType`、`Phase` |
| `category` | 该维度下的类别；每个细胞每个维度一个值 |
| `dimension_order` | 维度顺序；1 = CellType，2 = Phase |

显式类别顺序：CellType 为 Ductal → Ngn3 low EP → Ngn3 high EP → Pre-endocrine → Endocrine；Phase 为 G1 → S → G2M。`data/celltype_phase_counts.csv` 是 15 行聚合计数/组内比例，仅用于 QA 与溯源；模板读取细胞级长表，并按上游 `make_long()`/`geom_sankey()` 重新计数。`data/estimated_data.csv` 是 QA 工具要求的同内容副本；本图数据不是估读值。

## 代码结构

- `original_code/cellstat.R`：上游 `CellStatPlot` 与 `StatPlot` 的只读摘录；`provenance.json` 记录完整文件哈希、行号与 ggsankey 摘录范围。
- `code/scp_sankey_native.R`：函数化副本。`scp_sankey_table()` 复现上游中间数据（factor levels、dat_use、colors、`make_long()`、node/flow 表）；`plot_scp_sankey()` 逐行保留上游 sankey 分支的 ggplot/legend/gtable 构造；`scp_sankey_meta()` 是原始元数据入口；`scp_sankey_linkage_wide()` / `scp_sankey_linkage_plot()` 读取接口长表。
- `code/scp_helpers.R`：`theme_scp`、`palette_scp`、`capitalize`，以及从 `R/ggsankey.R` 复制的 `prepare_params`、`find_default_space`、`sigmoid`、`make_long`、`StatSankeyFlow`、`StatSankeyNode`、`geom_sankey`；`as_grob`/`as_gtable`/`add_grob` 来自 `R/SCP-plot.R` 14710–14794。
- `code/core.R`：本地加载 helpers 和 core，不依赖安装的 SCP 包或 Wiki 路径。
- `code/render.R`：读取 `data/render-cell-linkage.csv`，调用 `scp_sankey_linkage_plot()`，导出 PNG/PDF/SVG。
- `code/replica.R`：画廊标准入口，转调 `render.R`。

## 运行

```powershell
cd E:/research-wiki-env/work/scp-native-claude/s2/sankey/gallery
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

- `output/replica.png`：1200×900
- `output/replica.pdf`、`output/replica.svg`
- `compare/side_by_side.png`、`compare/overlay.png`
- `qa_report.md`、`PATCHES.md`

## 验证

- 上游调用（打补丁后）与函数化版在相同 8×6@150 设备下逐字节一致：SHA256 `7b16c62001e6780ff1c4fd2bee40eb230127704717bc37b4a792afc675fcbf95`（见 `run.log`）。
- 表半 `identical()`：`make_long()` 输出、`dat_use`、`colors`、每个维度的图例 levels 全为 TRUE；node 矩形与 flow 几何对照 `ggplot_build()` 完全一致；flow 计数与 `table(CellType, Phase)` 一致（12 条非零流向，合计 1000 个细胞）。
- 两个图例（CellType、Phase）均在图中可见、可读（见 `output/replica.png` 与 `PATCHES.md` 的 P3 证据）。

## 保留差异与限制

- 参考 panel 12 的图例按字母序显示（Ductal、Endocrine、Ngn3 high EP、Ngn3 low EP、Pre-endocrine；G1、G2M、S）；当前上游函数按 factor level 顺序显示（Ductal、Ngn3 low EP、Ngn3 high EP、Pre-endocrine、Endocrine；G1、S、G2M）。本条目保留上游顺序，不“改进”参考图。
- 上游 sankey 分支忽略 `group.by`、强制 `stat_type = "count"`；本核心保留该行为并照常 warning。
- 只实现默认单 split（`split.by = NULL`）；上游多 split 的组合循环未实现。
- `flip`、`label`、`title`、`subtitle`、`xlab`/`ylab` 在 sankey 分支不生效（上游行为）。
- 未验证 NA 类别、超过 100 levels、多个 split、其他 palette 与该分支的相互作用；这些分支未运行。
- 字体仅拉丁字符；未验证中文标签。
