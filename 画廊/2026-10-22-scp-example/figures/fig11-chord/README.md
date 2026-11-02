# 2026-10-22-scp-example__fig11-chord

SCP v0.5.6 原生 `CellStatPlot(plot_type = "chord")` 样张，使用 `pancreas_sub` 示例数据。来源图由未修改的上游函数在固定设备上生成，不是从帖子截图估读。

## 来源

- 仓库：<https://github.com/zhanghao-njmu/scp>
- commit：`b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`（SCP 0.5.6）
- 原文件：`R/SCP-plot.R` 的 `CellStatPlot`（4463–4563 行）与 `StatPlot`（4564–5678 行）；chord 分支 4960–5148 行
- 许可证：GPL (>= 3)
- 原始调用：

```r
CellStatPlot(pancreas_sub, stat.by = c("CellType", "Phase"), plot_type = "chord")
# 返回 recordedplot；在 8 x 6 in、150 dpi、白底设备上 replayPlot
```

- 原图：`source/fig11.png`，1200×900 px，SHA256 `6674db75622654c4da8e7a96250d264fb0be29720f380889c2ee78e9dcd36de6`
- 参考 panel：`source/reference_panel.png`（Example-2.jpg 第 4 格，bbox `[1454, 0, 1939, 337]`）。该格在原整图中底部两个类别标签被 panel 边界裁切；完整原图另存 `source/full_original.jpg`。

## recordedplot 与设备

上游 `StatPlot()` 的 chord 分支先在临时 `png(temp)` 设备上 `dev.control("enable")`，用 `circlize::chordDiagram()` 作画，`circos.clear()` 后 `recordPlot()` 返回 `recordedplot`；`CellStatPlot()` 再返回外层 `recordPlot()`。该对象没有 `ggsave` 方法。source 与 replica 使用完全相同的设备调用重放：

- PNG：`grDevices::png(width = 1200, height = 900, res = 150, bg = "white"); grDevices::replayPlot(p)`（8×6 in @150 dpi）
- PDF：`grDevices::cairo_pdf(width = 8, height = 6, bg = "white"); grDevices::replayPlot(p)`
- SVG：`svglite::svglite(width = 8, height = 6, bg = "white"); grDevices::replayPlot(p)`

记录阶段本身沿用上游的 `png(temp)` 默认设备参数；source 与 replica 都完整执行同一段记录代码，因此 PNG 逐字节一致。

## 输入与数据

`data/render-cell-linkage.csv` 共 2000 行（1000 个细胞 × 2 个维度），由 `pancreas_sub@meta.data` 的 `CellType`、`Phase` 逐细胞导出，未做任何聚合：

| 列 | 含义 |
|---|---|
| `cell` | 细胞标识；同一维度内唯一；每个细胞每个维度一行 |
| `dimension` | 维度/注释名；本图 `CellType`（order 1）与 `Phase`（order 2） |
| `category` | 该维度下该细胞的类别 |
| `dimension_order` | 维度顺序；1 起；决定矩阵的行/列次序（CellType 为行，Phase 为列） |

显式类别顺序：`CellType` = Ductal → Ngn3 low EP → Ngn3 high EP → Pre-endocrine → Endocrine；`Phase` = G1 → S → G2M。模板按 `table(CellType, Phase, useNA = "ifany")` 重建 5×3 计数矩阵，不重算比例；`stat_type` 被上游强制为 count。

`data/chord-count-matrix.csv` 是同一数据的 15 行聚合计数表（`count` 与 `within_row_proportion`），仅用于 QA 与溯源；`data/estimated_data.csv` 是 QA 工具要求的同内容副本；本图数据不是估读值。

## 代码结构

- `original_code/cellstat.R`：上游 `CellStatPlot` 与 `StatPlot` 的只读摘录（4463–5678 行，带 2 行来源头）；`provenance.json` 记录完整文件哈希、行号与许可证。
- `code/scp_chord_native.R`：函数化副本。
  - `scp_chord_table()`：表半，复现上游因子处理与 `table(useNA = "ifany")` 矩阵（5117–5119 行）。
  - `scp_chord_colors()`：上游 5116 行的 `palette_scp()` 调用（本地 palette 数据）。
  - `plot_scp_chord()`：绘图半，逐行保留上游临时记录设备、`circlize::chordDiagram()` 参数、`circos.clear()` 与 `recordPlot()`。
  - `scp_chord_meta()`：串联表半与绘图半。
  - `scp_chord_linkage_wide()` / `scp_chord_long_meta()` / `scp_chord_linkage_summary()`：长表接口适配与尺寸摘要。
- `code/scp_helpers.R`：仅保留 chord 需要的 `palette_scp()`（函数体与上游一致）与 `palette_list.rda`。
- `code/core.R`：本地加载 helpers 与 core，不依赖安装的 SCP 包或 Wiki 路径。
- `code/render.R`：读取 `data/render-cell-linkage.csv` 与 `data/figure_spec.json`，调用原生 core，显式打开 PNG/PDF/SVG 设备重放。
- `code/replica.R`：画廊标准入口，转调 `render.R`。

## 运行

```powershell
cd E:/research-wiki-env/work/scp-native-claude/s2/chord/gallery
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

- `output/replica.png`：1200×900，与 `source/fig11.png` 同 SHA256
- `output/replica.pdf`、`output/replica.svg`
- `compare/side_by_side.png`、`compare/overlay.png`
- `thumb.png`：480×360
- `qa_report.md`、`run.log`

## 验证

- 表半：`identical(upstream_m, scp_chord_table(...))` 为 `TRUE`；矩阵 5×3，dimnames 与计数完全一致。上游矩阵由拦截 `chordDiagram()` 实参捕获，并与按上游代码行重建的矩阵 `identical()` 一致。
- 颜色：捕获的 `grid.col` 与 `scp_chord_colors()` 输出 `identical()` 为 `TRUE`（Ductal `#A6CEE3`、Ngn3 low EP `#1F78B4`、Ngn3 high EP `#B2DF8A`、Pre-endocrine `#33A02C`、Endocrine `#FDBF6F`、G1 `#FF7F00`、S `#FB9A99`、G2M `#E31A1C`、NA `grey`）。
- 逐字节：source 与 replica PNG SHA256 相同（`6674db…36de6`），像素 mad = 0、RMS = 0。
- 模板固定模式：8×6 in、150 dpi 输出与画廊 source 同 SHA256。
- 模板 adaptive：small 6.4×5.0 in、large 11.83×8.87 in；`max_width_in=6` 时以清晰错误拒绝；运行两次输入 CSV 哈希不变；复制到另一目录后仍能运行且输出同哈希。
- 模板列映射：把四列改名为 `cid/dim/cat/ord` 后输出与 source 同哈希；显式反序维度（Phase 先）正常出图且哈希不同。
- 上游 `stat_type` 强制转 count 的 warning 被保留并记录在 `work/source-summary.json`（工作区）。

## 保留差异与限制

- 参考 panel 来自 Example-2.jpg 的多 panel 拼图，底部标签被网格边界裁切，且分辨率/缩放与独立 8×6 输出不同；`source/fig11.png` 是上游函数在 8×6@150 的独立输出，二者只作结构与颜色对照，不做像素对照。
- 上游 chord 只支持两个 `stat.by`；`group.by` 被忽略（上游会 warning），`split.by` 会产生多 panel。模板只实现单 panel（`combine = TRUE`、单个 split 层），未实现 `split.by`/`combine = FALSE` 的多图列表。
- 上游 chord 分支不使用 `alpha`、`label` 与 ggplot 图例；模板 style 中的 `alpha`/`label`/`legend` 为接口统一保留，必须保持默认值，否则不会改变图像。
- `stat_type = "percent"` 被上游强制为 count；本模板不提供比例和弦。
- 类别为 NA 时上游矩阵列名改为 `"NA"`；长表接口不接受缺失 `category`，也不把字面 `"NA"` 与缺失值区分。
- 两个维度出现同名类别时，`circlize` 会把它们合并为同一扇区；模板不做改名。
- PNG 逐字节一致依赖同一 R 版本（4.5.0）、cairo png 设备与相同设备参数；换 R/图形设备可能得到像素相同但字节不同的 PNG。PDF 内含创建时间，不能跨次逐字节比较；SVG 由 svglite 输出，文字为 `<text>` 元素。
- 字体仅拉丁字符；未验证中文/特殊字符标签。
- 记录设备为上游临时 `png(temp)`（默认 480×480 px）；`circlize` 的坐标在记录时确定，重放到 8×6 画布按比例缩放。改变记录设备尺寸不在本模板范围内。
