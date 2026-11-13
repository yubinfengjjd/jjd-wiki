# 2026-10-22-scp-example__fig12-venn

SCP v0.5.6 原生 `CellStatPlot(plot_type = "venn")` 样张，使用 `pancreas_sub` 示例数据。来源图由上游 `CellStatPlot()` 入口在固定设备上生成；其中 `StatPlot()` 的 venn 分支按 `PATCHES.md` 记录的兼容补丁在本地重建几何后运行（ggVennDiagram 1.4 起移除了 sf 几何，上游原样代码无法在 1.5.7 上运行）。不是从帖子截图估读。

## 来源

- 仓库：<https://github.com/zhanghao-njmu/scp>
- commit：`b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`（SCP 0.5.6）
- 原文件：`R/SCP-plot.R`；`CellStatPlot` 4463–4490 行，`StatPlot` 4564–5159 行（完整文件 SHA256 见 `original_code/provenance.json`）
- 许可证：GPL (>= 3)
- 原始调用：

```r
pancreas_sub$Ductal <- pancreas_sub$CellType %in% c("Ductal", "Ngn3 low EP", "Ngn3 high EP")
pancreas_sub$Endocrine <- pancreas_sub$CellType %in% c("Pre-endocrine", "Endocrine")
pancreas_sub$G1S <- pancreas_sub$Phase %in% c("G1", "S")
pancreas_sub$G2M <- pancreas_sub$Phase == "G2M"
CellStatPlot(pancreas_sub,
  stat.by = c("Ductal", "Endocrine", "G1S", "G2M"),
  plot_type = "venn", stat_level = "TRUE"
)
# ggsave 8 x 6 in, 150 dpi, white background, set.seed(11)
```

- 原图：`source/fig12.png`，SHA256 `a5bf19955f2efc74b28c1133945c886cf8f8370ce179fb2582f530c6d96b6119`
- 参考 panel：`source/reference_panel.png`（`Example-2.jpg` 第 8 格，bbox [1454, 337, 1939, 675]）；完整原图 `source/full_original.jpg`，SHA256 `a63a3a53beb2c052a4c0278bbeec477c4d741f889d8551808fdcdee9471e4814`

> 任务简报写作 `CellStatPlot 4463–4563, StatPlot 4564–5678`。本 checkout 的 `StatPlot()` 实际结束于 5159 行（完整文件哈希与简报给出的 commit 一致）；5160–5678 属于下一个 `FeatureCorPlot` 块，因此 `original_code/cellstat.R` 只收录两个函数的真实范围，并在文件头注明。

## 输入与数据

`data/render-cell-membership.csv` 共 1000 行，每行一个细胞，来自 `pancreas_sub@meta.data`：

| 列 | 含义 |
|---|---|
| `cell` | 细胞标识；同一图内唯一 |
| `Ductal` | 逻辑成员：CellType ∈ {Ductal, Ngn3 low EP, Ngn3 high EP}，488 个细胞 |
| `Endocrine` | 逻辑成员：CellType ∈ {Pre-endocrine, Endocrine}，512 个细胞 |
| `G1S` | 逻辑成员：Phase ∈ {G1, S}，923 个细胞 |
| `G2M` | 逻辑成员：Phase == G2M，77 个细胞 |

集合顺序由 `data/figure_spec.json` 的 `params.set_cols` 显式给出（Ductal → Endocrine → G1S → G2M）；模板不从列名字母序推断。`data/venn_intersections.csv` 是同一数据的 15 行交集区域表（id、sets、count、percent、color），`data/venn_set_sizes.csv` 是 4 行集合大小表，均用于溯源与 QA；`data/estimated_data.csv` 是交集表的同内容副本。本图数据不是估读值。

## 代码结构

- `original_code/cellstat.R`：上游 `CellStatPlot` 与 `StatPlot` 的只读摘录；`provenance.json` 记录完整文件哈希、行号与摘录哈希。
- `code/scp_venn_native.R`：函数化副本。`scp_venn_table()` 复现上游 venn 计数路径（`stat_level` 处理、每个集合的细胞列表、`Venn`/`process_data`、区域 count/百分比/颜色）；`plot_scp_venn()` 逐行保留上游 `geom_sf`、`geom_text_repel`、identity scales 与 theme；`scp_venn_region_sf()` / `scp_venn_setedge_sf()` / `scp_venn_setlabel_sf()` 是 ggVennDiagram ≥ 1.4 的几何兼容层。
- `code/scp_helpers.R`：`palette_scp()`、`blendcolors()` 及其依赖，来自上游同 commit，只有 palette 数据读取位置改动。
- `code/core.R`：本地加载 helpers 与 core，不依赖安装的 SCP 包或 Wiki 路径。
- `code/render.R`：读取 `data/render-cell-membership.csv` 与 `data/figure_spec.json`，导出 PNG/PDF/SVG。
- `code/replica.R`：画廊标准入口，转调 `render.R`。

## 运行

```powershell
cd E:/research-wiki-env/work/scp-native-claude/s2/venn/gallery
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
- `output/replica.pdf`、`output/replica.svg`（svglite，文字为 `<text>`）
- `compare/side_by_side.png`、`compare/overlay.png`
- `thumb.png`：480×360（PNG 来源缩放）
- `qa_report.md`、`run.log`

## 验证

- `source/fig12.png` 与 `output/replica.png` 逐字节一致：SHA256 `a5bf19…b6119`，PNG 像素 mad = 0、RMS = 0。
- 表半与上游中间结果 `identical()`：15 行区域的 id/name/item/count/colors/label 全部相同；集合大小 488/512/923/77 相同；`Venn`/`process_data` 不消耗 RNG。
- 模板固定模式（8×6@150、white）输出与来源同哈希；adaptive 2 集合 6.70×5.03 in、7 集合 8.69×6.52 in；`max_width_in=4` 正确报错；输入 CSV 运行前后哈希不变；模板复制到 `E:/research-wiki-env/tmp/venn-template-copy` 后仍同哈希运行。
- 详细补丁与几何不变性证据见 `PATCHES.md`。

## 保留差异与限制

- 上游 SCP 0.5.6 的 venn 分支针对 ggVennDiagram < 1.4（仍返回 sf 几何）编写；本机 1.5.7 不返回 sf 几何。几何由包自身的 `regionEdge`/`setEdge`/`setLabel` 坐标重建，`st_centroid()` 与 `venn_region()` 的标签坐标逐行完全相等（差值 0），区域计数/颜色/标签与上游中间结果 `identical()`；但没有在 ggVennDiagram 1.2.x 环境里再跑一次逐字节对照。
- 上游 `stat_level = NULL` 对逻辑列默认取 `FALSE`；模板显式使用 `set_level = "TRUE"`（成员表的语义）。
- 仅支持 2–7 个集合（`Venn` 上限）；模板不支持 `group.by`/`split.by` 多分面（上游 venn 分支也不使用 `group.by`；多 split 会生成多图，本模板只做一个 panel）。
- 区域标签固定为 `count` + 1 位小数百分比，与上游一致，未参数化。
- 字体仅拉丁字符；未验证中文集合名。
- 未验证的其他分支：upset/sankey/chord 共用同一上游分支段，但不在本模板范围；示例图与 `Example-2.jpg` 第 8 格视觉核对通过，参考图是 JPEG 裁图（左侧 `Ductal` 标签被原版面裁切），不能做像素级比对。
- 本条目只证明示例调用与表入口可重复，不证明科学有效性或任意数据的统计前提。
