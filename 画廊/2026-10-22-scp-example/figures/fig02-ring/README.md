# 2026-10-22-scp-example__fig02-ring

SCP v0.5.6 原生 `CellStatPlot(plot_type = "ring")` 样张，使用 `pancreas_sub` 示例数据。版本 3 为原生重做；旧版（v2）保存在 `history/20261022T091407743157Z/`。

## 来源

- 仓库：<https://github.com/zhanghao-njmu/scp>
- commit：`b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`（SCP 0.5.6）
- 原文件：`R/SCP-plot.R` 的 `CellStatPlot`（4463–4563 行）与 `StatPlot`（4564–5678 行）ring 分支
- 许可证：GPL (>= 3)；原文件 SHA256 `03a0b55f...caca3a02`
- 原图：`source/fig02.png`，SHA256 `a5e297c57511ec76e4a5fa54a75552b896ac8e45d60964b34ae4d0965dc15456`

原图由上游示例直接生成，不是从帖子截图估读：

```r
CellStatPlot(pancreas_sub, stat.by = "Phase", group.by = "CellType",
             plot_type = "ring", label = TRUE)
# ggsave 8 x 6 in, 150 dpi
```

## 输入与数据

`data/ring_phase_by_celltype.csv` 共 15 行，来自 `pancreas_sub@meta.data` 的精确计数：

| 列 | 含义 |
|---|---|
| `CellType` | 环（分组）；显式顺序 Ductal → Ngn3 low EP → Ngn3 high EP → Pre-endocrine → Endocrine |
| `Phase` | 扇区类别；显式顺序 G1 → S → G2M |
| `count` | 该 CellType × Phase 的细胞数，仅用于溯源 |
| `proportion` | `count / 该 CellType 总数`，每组合计为 1 |

`data/estimated_data.csv` 是 QA 工具要求的同内容副本；本图数据不是估读值。

## 代码结构

- `original_code/ring.R`：上游两个函数的只读摘录；`provenance.json` 记录完整文件哈希与行号。
- `code/scp_ring_native.R`：函数化副本。`scp_ring_table()` 只做计数/比例表；`plot_scp_ring()` 逐行保留上游 ring ggplot 构造；`scp_ring_meta()` 串联两者；`scp_ring_proportions()` 读取任意列映射的比例表。
- `code/render.R`：读取 CSV，调用 `scp_ring_proportions()`，导出 PNG/PDF/SVG。
- `code/replica.R`：画廊标准入口，转调 `render.R`。

SCP-local 加载器：`E:/research-wiki/知识库/methods/scp-local-source/code/SCP-local`。可用 `SCP_LOCAL_ROOT` 覆盖。

## 运行

```powershell
cd E:/research-wiki/画廊/2026-10-22-scp-example/figures/fig02-ring
Rscript --vanilla code/replica.R
```

隔离环境变量（本机）：

```powershell
$env:PROCESSOR_ARCHITECTURE='AMD64'
Remove-Item Env:LANG,Env:LC_ALL,Env:LC_CTYPE -ErrorAction SilentlyContinue
$env:TEMP=$env:TMP='E:\research-wiki-env\tmp'
$env:MPLCONFIGDIR='E:\research-wiki-env\tmp\mpl'
$env:R_LIBS_USER='E:/research-wiki-env/R-lib-scp/4.5'
```

## 产物

- `output/replica.png`：1200×900，SHA256 `85b3c9b7...dda8c56a`
- `output/replica.pdf`、`output/replica.svg`（svglite，文字可编辑）
- `compare/side_by_side.png`、`compare/overlay.png`
- `qa_report.md`：机械检查 + agent 目视记录

## 验证

- 原版与函数化版图层数据逐行相等：5 组 × 3 类，`x`/`y`/`fill` 全部相等。
- 7 组 × 5 类、含零组合；显式逆序；count 类型；任意列映射表入口：均与上游 `StatPlot` 图层相等。
- 输入不被修改；非法表（重复 group×stat、比例和不为 1、负值、NA、缺列）均被拒绝。
- `Rscript code/replica.R` 与 `Rscript code/render.R` 从条目录和外目录运行均 exit 0。
- 与源图像素对比：平均绝对差 `1.17e-05`，RMS `0.0036`，差异仅 bbox `(566,466)-(600,489)`（环中心抗锯齿/端点标签）。

## 保留差异与限制

- 上游无表格入口，`scp_ring_proportions()` 是本仓库新增的独立表入口；它要求比例和严格为 1，不做隐式换算。
- 上游 `CellStatPlot` 的环行是细胞级 ggplot，表级重绘时 0%/100% 顶部标签不会自动合并；`merge_polar_endpoints = TRUE` 显式复现该显示，默认开启。该兼容处理是唯一有意偏离上游对象结构的点，像素对比见上。
- 上游 `palette = NULL` 且 `palcolor` 不足时会报错；函数化版保持同样行为，不静默补色。
- 字体仅拉丁字符；未验证中文标签。

## 状态

`draft`。机械检查全 PASS；目视对比完成；作者签核未进行。
