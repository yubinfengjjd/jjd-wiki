# 2026-10-22-scp-example__fig13-upset

SCP v0.5.6 原生 `CellStatPlot(plot_type = "upset")` 样张，使用 `pancreas_sub` 示例数据。来源图由未修改的上游函数在固定设备上生成，不是从帖子截图估读。对应 `man/figures/Example-2.jpg` 第 7 格。

## 来源

- 仓库：<https://github.com/zhanghao-njmu/scp>
- commit：`b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`（SCP 0.5.6）
- 原文件：`R/SCP-plot.R` 的 `CellStatPlot`（4463–4563 行）与 `StatPlot`（4564–5678 行）；upset 分支在 5044–5075 行
- 许可证：GPL (>= 3)
- 原始调用：

```r
# pancreas_sub does not ship these four logical columns; they are derived from
# CellType and Phase exactly as the venn panel of Example-2.jpg:
pancreas_sub$Ductal    <- pancreas_sub$CellType %in% c("Ductal", "Ngn3 low EP", "Ngn3 high EP")
pancreas_sub$Endocrine <- pancreas_sub$CellType %in% c("Pre-endocrine", "Endocrine")
pancreas_sub$G1S       <- pancreas_sub$Phase %in% c("G1", "S")
pancreas_sub$G2M       <- pancreas_sub$Phase == "G2M"

CellStatPlot(pancreas_sub,
             stat.by = c("Ductal", "Endocrine", "G1S", "G2M"),
             plot_type = "upset", stat_level = "TRUE")
# ggsave 8 x 6 in, 150 dpi, white background, set.seed(11)
```

- 原图：`source/fig13.png`，SHA256 `b2f0322dfa77068b0e7d5aacd72475b0a8b6ab084ca0ae0b27fe7e3f8a71190a`（1200×900 px）
- 参考 panel：`source/reference_panel.png`（Example-2.jpg 第 7 格，bbox [950, 330, 1400, 680]）；完整原图 `source/full_original.jpg`，SHA256 `a63a3a53beb2c052a4c0278bbeec477c4d741f889d8551808fdcdee9471e4814`

四个集合的成员数：Ductal 488、Endocrine 512、G1S 923、G2M 77，与同图 venn panel 的集合总数一致；交集为 Endocrine∩G1S = 512、Ductal∩G1S = 411、Ductal∩G2M = 77。

## 输入与数据

`data/render-cell-membership.csv` 共 4000 行 = 1000 个细胞 × 4 个集合，每行一个「细胞 × 集合」：

| 列 | 含义 |
|---|---|
| `cell` | 细胞标识；同一集合内唯一 |
| `set` | 集合名；显式顺序 Ductal → Endocrine → G1S → G2M |
| `member` | 该细胞是否属于该集合；只接受 0 或 1 |

`data/upset-intersection-counts.csv` 是同一数据的 3 行交集计数（degree / count / proportion_of_cells），只用于溯源与 QA。`data/estimated_data.csv` 是它的同内容副本（QA 工具要求），本图数据不是估读值。

## 代码结构

- `original_code/cellstat.R`：上游 `CellStatPlot` 与 `StatPlot` 的只读摘录；`provenance.json` 记录完整文件哈希与行号（完整文件 SHA256 `03a0b55f…`，摘录 SHA256 `657e9b89…`）。
- `code/scp_upset_native.R`：函数化副本。`scp_upset_table()` 逐行保留上游的 logical 转换、`All.groups`、`intersection` 构造与过滤；`scp_upset_counts()` 给出柱高计数；`plot_scp_upset()` 逐行保留上游 ggplot 构造；`scp_upset_membership()` 是新增的长表→宽表接口适配。
- `code/core.R`：本地加载 helpers 和 core，不依赖安装的 SCP 包或 Wiki 路径。
- `code/render.R`：读取 `data/render-cell-membership.csv`，调用 `scp_upset_meta()`，导出 PNG/PDF/SVG。
- `code/replica.R`：画廊标准入口，转调 `render.R`。
- `PATCHES.md`：每个兼容补丁的上游行号、原因、替换与几何不变证明。

## 运行

```powershell
cd E:/research-wiki-env/work/scp-native-claude/s2/upset/gallery
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

- `output/replica.png`：1200×900，SHA256 与 `source/fig13.png` 相同
- `output/replica.pdf`、`output/replica.svg`
- `compare/side_by_side.png`、`compare/overlay.png`（像素差 0）
- `thumb.png`（480×360）、`qa_report.md`、`run.log`

## 验证

- 上游调用与函数化版在相同 8×6 @150 设备下逐字节一致：source 与 replica 的 SHA256 均为 `b2f0322d…8a71190a`。
- 表半 `scp_upset_table()` 与上游 `ggplot` 实际收到的数据框 `identical: TRUE`（1000×6，含 `intersection` list 列）。
- 计数表与 `ggplot_build()` 的柱高一致：512 / 411 / 77。
- 模板固定模式输出与画廊 source 同哈希；adaptive 小/大数据、`max_width_in` 拒绝、输入不变、异目录复制的命令与结果记录在工作区 `evidence.json`（模板验收证据，随 staging 交付，不进入 Wiki 目录）。

## 保留差异与限制

- `pancreas_sub` 没有这四个 logical 列；来源按 Example-2 的 venn/upset 语义显式派生，派生式写在 `data/figure_spec.json` 的 `derivation`。
- 上游 upset 分支把 `stat_type` 强制为 `count`，本图没有比例轴；柱高是细胞数。
- 上游固定 `aspect.ratio = 0.6`、combmatrix 标签字号 12、额外间距 6；复刻原样保留，不随画布尺寸缩放。
- `scale_x_upset(n_intersections = 20)` 会截断超过 20 个交集的显示；本图只有 3 个交集，截断分支未验证。
- 上游 `palette` 参数在 upset 分支不参与填色，填色固定 `material-indigo`；模板把它暴露为 `fill_palette`，默认值不变。
- 参考 panel 左侧带少量相邻 panel 的图例残影，仅作溯源。
- 字体仅拉丁字符；未验证中文标签。
