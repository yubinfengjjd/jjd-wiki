# 2026-10-22-scp-example__fig16-cell-density

SCP v0.5.6 原生 `CellDensityPlot(features = "Sox9", group.by = "SubCellType")` 样张，使用 `pancreas_sub` 示例数据。来源图由未修改的上游函数在固定设备上生成，不是估读。

## 来源

- 仓库：<https://github.com/zhanghao-njmu/scp>
- commit：`b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`（SCP 0.5.6）
- 原文件：`R/SCP-plot.R` 的 `CellDensityPlot`（5679–5917 行）
- 许可证：GPL (>= 3)
- 原始调用：

```r
CellDensityPlot(pancreas_sub, features = "Sox9", group.by = "SubCellType")
# ggsave 8 x 6 in, 150 dpi
```

- 原图：`source/fig16.png`，SHA256 `72a7a07ac71b45fbe7f5db2e3c13aae6f1c8d166f4928af925f4d79dc3206b7e`

## 输入与数据

`data/render-cell-feature-values.csv` 共 1000 行，每个细胞一行：

| 列 | 含义 |
|---|---|
| `cell` | 细胞标识；同一特征内唯一 |
| `feature` | 特征名；本图 `Sox9` |
| `value` | `data` slot 的 Sox9 表达值 |
| `group` | SubCellType；每个细胞一个值 |
| `feature_order` | 特征面板顺序；本图 1 |
| `group_order` | 山脊线顺序；显式给出 |

`data/density-summary.csv` 是每组 n/min/median/max 的 QA 摘要，仅用于溯源；模板读取细胞级表并计算密度。`data/estimated_data.csv` 是 QA 工具要求的同内容副本；本图数据不是估读值。

## 代码结构

- `original_code/celldensity.R`：上游 `CellDensityPlot()` 的只读摘录；`provenance.json` 记录完整文件哈希与行号。
- `code/scp_cell-density_native.R`：表半 `scp_cell_density_meta()`/`scp_cell_density_values()`，绘图半 `plot_scp_cell_density()`；保留原 ggplot/ggridges 构造。
- `code/core.R`、`code/scp_helpers.R`：本地加载；不依赖安装的 SCP 包或 Wiki 路径。
- `code/render.R`：读取 `data/render-cell-feature-values.csv`，调用原生 core，导出 PNG/PDF/SVG 和 `sizing.json`。
- `code/replica.R`：画廊标准入口。

## 运行

```powershell
cd E:/research-wiki-env/work/scp-native-claude/s3/cell-density/gallery
Rscript --vanilla code/replica.R
```

隔离环境变量：`R_LIBS_USER=E:/research-wiki-env/R-lib-scp/4.5`，`TEMP/TMP=E:/research-wiki-env/tmp`，`PROCESSOR_ARCHITECTURE=AMD64`。

## 产物

- `output/replica.png`：1200×900，与 `source/fig16.png` 同 SHA256
- `output/replica.pdf`、`output/replica.svg`
- `compare/side_by_side.png`、`compare/overlay.png`
- `qa_report.md`

## 验证

- source 与 replica 在 8×6@150 下逐字节一致（SHA256 `72a7a07ac71b45fbe7f5db2e3c13aae6f1c8d166f4928af925f4d79dc3206b7e`）；SVG 一致，PDF 仅尾部流不同。
- 表半 `plot_data` 与上游 `ggplot_build()` 数据在列、行、顺序、分组水平上一致。
- 模板 fixed 回放与 source 一致；adaptive 2 组/12 组、3 特征、长标签、max 拒绝、输入不变、异目录复制通过。
- 未验证：真实 Seurat→CSV→模板流水线、非默认 flip/reverse/x_order、CJK 标签与科学有效性。
