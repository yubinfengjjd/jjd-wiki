# 2026-10-22-scp-example__fig07-dot

SCP v0.5.6 原生 `CellStatPlot(plot_type = "dot")` 样张，使用 `pancreas_sub` 示例数据。来源图由未修改的上游函数在固定设备上生成，不是从帖子截图估读。

## 来源

- 仓库：<https://github.com/zhanghao-njmu/scp>
- commit：`b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`（SCP 0.5.6）
- 原文件：`R/SCP-plot.R` 的 `CellStatPlot`（4463–4563 行）与 `StatPlot`（4564–5678 行）
- 许可证：GPL (>= 3)
- 原始调用：

```r
CellStatPlot(pancreas_sub, stat.by = "Phase", group.by = "CellType", plot_type = "dot")
# ggsave 8 x 6 in, 150 dpi
```

- 原图：`source/fig07.png`，SHA256 `ddabf0eed555227b0a7d25848ebc3a5aa68676f570f9d2e5b6d737044e112117`
- 参考 panel：`source/reference_panel.png`（Example-2.jpg 第 10 格，bbox [484, 675, 969, 1013]）

## 输入与数据

`data/render-cell-metadata.csv` 共 1000 行，每行一个细胞，来自 `pancreas_sub@meta.data`：

| 列 | 含义 |
|---|---|
| `cell` | 细胞标识；同一图内唯一 |
| `CellType` | 分组 / x 轴类别；每个细胞一个值；显式顺序 Ductal → Ngn3 low EP → Ngn3 high EP → Pre-endocrine → Endocrine |
| `Phase` | 系列类别；每个细胞一个值；显式顺序 G1 → S → G2M |

`data/phase_by_celltype.csv` 是同一数据的 15 行聚合表（count + proportion），仅用于溯源；模板读取细胞级表并调用原 `StatPlot` 的计数步骤。`data/estimated_data.csv` 是 QA 工具要求的同内容副本；本图数据不是估读值。

## 代码结构

- `original_code/cellstat.R`：上游 `CellStatPlot` 与 `StatPlot` 的只读摘录；`provenance.json` 记录完整文件哈希与行号。
- `code/scp_stat_native.R`：函数化副本。`scp_stat_table()` 做计数/比例表；`plot_scp_stat()` 逐行保留上游 ggplot 构造；`scp_stat_values()` 读取任意列映射的表；`scp_stat_meta()` 串联原始元数据入口。
- `code/core.R`：本地加载 helpers 和 core，不依赖安装的 SCP 包或 Wiki 路径。
- `code/render.R`：读取 `data/render-cell-metadata.csv`，调用 `scp_stat_meta()`（内部 `scp_stat_table()` 计数/比例 + `plot_scp_stat()` 绘图），导出 PNG/PDF/SVG。
- `code/replica.R`：画廊标准入口，转调 `render.R`。

## 运行

```powershell
cd E:/research-wiki/画廊/2026-10-22-scp-example/figures/fig07-dot
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
- `qa_report.md`

## 验证

- 原版与函数化版在相同调用、相同 8×6@150 设备下逐字节一致（见 `run.log` 的 SHA256）。
- CSV 表入口 `scp_stat_values()` 与原函数输出逐字节一致。
- 契约测试：工作区 `E:/research-wiki-env/work/scp-native-claude/scripts/test_cellstat_contract.R`（67 PASS / 0 FAIL）。

## 保留差异与限制

- 上游 `CellStatPlot` 没有独立表入口；`scp_stat_values()` 是本仓库新增的显式表入口，要求显式列映射与顺序。
- 极坐标端点标签由上游原函数在细胞级自动处理；表级重绘默认与原图一致，未启用额外合并。
- `area` 的首列百分比标签在 8×6 固定画布上会被上游 panel 边界裁切；原函数同样如此，模板 adaptive 模式按实际标签加宽画布，但不改变上游 x 轴几何。
- 字体仅拉丁字符；未验证中文标签。
