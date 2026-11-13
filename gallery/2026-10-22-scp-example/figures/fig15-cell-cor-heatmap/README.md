# 2026-10-22-scp-example__fig15-cell-cor-heatmap

SCP v0.5.6 原生 `CellCorHeatmap()` 样张，使用 `pancreas_sub` 与 `Standard_SCP`，按 SubCellType 折叠为 8×8 查询-查询相似度热图。来源图由未修改的上游函数在固定设备上生成，不是估读。

## 来源

- 仓库：<https://github.com/zhanghao-njmu/scp>
- commit：`b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`（SCP 0.5.6）
- 原文件：`R/SCP-plot.R` 的 `CellCorHeatmap`（10113–11019 行）
- 许可证：GPL (>= 3)
- 原始调用：

```r
pancreas_sub <- Standard_SCP(pancreas_sub)
ht1 <- CellCorHeatmap(srt_query = pancreas_sub, query_group = "SubCellType")
ht1$plot
# ComplexHeatmap::draw on 8 x 6 in, 150 dpi
```

- 原图：`source/fig15.png`，SHA256 `6f96f3c2d6d42e8e7e1cbe916ee335db8b04a9f9ecee307948eaa779e53f6bf7`

## 输入与数据

`data/render-correlation-heatmap.csv` 共 64 行（8×8），每行一个 row×column 相似度：

| 列 | 含义 |
|---|---|
| `row` | 查询组标签 |
| `column` | 参考组标签 |
| `similarity` | RunKNNPredict 计算的 cosine 相似度；模板不重算 |
| `row_group` / `column_group` | 行列注释分组 |
| `row_order` / `column_order` | 显式顺序 |

`data/correlation-summary.csv` 是每行最相似列的 QA 摘要；模板读取长表并重建矩阵。`data/estimated_data.csv` 是 QA 工具要求的同内容副本；本图数据不是估读值。

## 代码结构

- `original_code/cellcorheatmap.R`：上游 `CellCorHeatmap()` 的只读摘录；`provenance.json` 记录完整文件哈希与行号。
- `code/scp_cell-cor-heatmap_native.R`：表半 `scp_cellcor_simil()`/`scp_cellcor_long_table()`，绘图半 `plot_scp_cellcor_heatmap()`；保留 ComplexHeatmap 构造。
  - P1：`RunKNNPredict()` 写回 per-cell metadata 时加 `unname()`，适配 SeuratObject >= 5.4；相似度矩阵不变。
- `code/core.R`、`code/scp_helpers.R`、`code/sizing.R`：本地加载与尺寸。
- `code/render.R`：读取 `data/render-correlation-heatmap.csv`，重建矩阵并绘制；导出 PNG/PDF/SVG + `sizing.json`。
- `code/replica.R`：画廊标准入口。

## 运行

```powershell
cd E:/research-wiki-env/work/scp-native-claude/s3/cell-cor-heatmap/gallery
Rscript --vanilla code/replica.R
```

隔离环境变量：`R_LIBS_USER=E:/research-wiki-env/R-lib-scp/4.5`，`TEMP/TMP=E:/research-wiki-env/tmp`，`PROCESSOR_ARCHITECTURE=AMD64`。

## 产物

- `output/replica.png`：1200×900，与 `source/fig15.png` 同 SHA256
- `output/replica.pdf`、`output/replica.svg`
- `compare/side_by_side.png`、`compare/overlay.png`
- `qa_report.md`

## 验证

- source 与 replica 在 8×6@150 下逐字节一致（SHA256 `6f96f3c2d6d42e8e7e1cbe916ee335db8b04a9f9ecee307948eaa779e53f6bf7`）。
- 表半 `simil_matrix` 与上游 `identical`；模板 fixed 回放与 source 一致。
- 未验证：真实参考数据集（panc8）、细胞级不折叠、nlabel/label_cutoff 分支、query/ref cell annotation、flip/cluster、真实课题流水线与科学有效性。
