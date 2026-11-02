# 2026-10-22-scp-example__fig14-feature-heatmap

SCP v0.5.6 原生 `FeatureHeatmap()` 样张，使用 `pancreas_sub` 与 `RunDEtest` 的 20 个差异基因。来源图由未修改的上游函数在固定设备上生成，不是估读。

## 来源

- 仓库：<https://github.com/zhanghao-njmu/scp>
- commit：`b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`（SCP 0.5.6）
- 原文件：`R/SCP-plot.R` 的 `FeatureHeatmap`（9114–9979 行）
- 许可证：GPL (>= 3)
- 原始调用：

```r
pancreas_sub <- RunDEtest(pancreas_sub, group_by = "CellType")
de_filter <- filter(pancreas_sub@tools$DEtest_CellType$AllMarkers_wilcox,
                    p_val_adj < 0.05 & avg_log2FC > 1)
FeatureHeatmap(srt = pancreas_sub, features = head(de_filter$gene, 20),
               group.by = "CellType")
# ComplexHeatmap::draw on 8 x 6 in, 150 dpi
```

- 原图：`source/fig14.png`，SHA256 `6a614cfd99a27c4828b7e94c682789a0f42e6bd52b2af37c8d782b479fedc518`

## 输入与数据

`data/render-feature-heatmap.csv` 是 matrix × feature × cell 的长表：

| 列 | 含义 |
|---|---|
| `matrix` | 矩阵/分组变量名；本图 `CellType` |
| `feature` | 20 个 DE 基因 |
| `cell` | 细胞标识；每个细胞每个特征一行 |
| `group` | CellType 注释 |
| `value` | zscore(normalized counts)；上游变换，模板不重算 |
| `matrix_order` | 矩阵顺序；本图 1 |
| `feature_order` | 特征行顺序 |
| `cell_order` | 细胞列顺序 |
| `group_order` | 分组图例/注释顺序 |

`data/feature-group-summary.csv` 是 feature × group 的 n/mean 摘要，仅用于 QA；模板读取细胞级长表并重建矩阵。`data/estimated_data.csv` 是 QA 工具要求的同内容副本；本图数据不是估读值。

## 代码结构

- `original_code/featureheatmap.R`：上游 `FeatureHeatmap()` 的只读摘录；`provenance.json` 记录完整文件哈希与行号。
- `code/scp_feature_heatmap_native.R`：表半/绘图半拆分；保留 ComplexHeatmap 的矩阵、注释、图例和 `heatmap_rendersize` 尺寸计算。
- `code/core.R`、`code/scp_helpers.R`、`code/sizing.R`：本地加载与尺寸。
- `code/render.R`：读取 `data/render-feature-heatmap.csv`，调用原生 core，导出 PNG/PDF/SVG 与 `sizing.json`。
- `code/replica.R`：画廊标准入口。

## 运行

```powershell
cd E:/research-wiki-env/work/scp-native-claude/s3/feature-heatmap/gallery
Rscript --vanilla code/replica.R
```

隔离环境变量：`R_LIBS_USER=E:/research-wiki-env/R-lib-scp/4.5`，`TEMP/TMP=E:/research-wiki-env/tmp`，`PROCESSOR_ARCHITECTURE=AMD64`。

## 产物

- `output/replica.png`：1200×900，与 `source/fig14.png` 同 SHA256
- `output/replica.pdf`、`output/replica.svg`
- `compare/side_by_side.png`、`compare/overlay.png`
- `qa_report.md`

## 验证

- source 与 replica 在 8×6@150 下逐字节一致（SHA256 `6a614cfd99a27c4828b7e94c682789a0f42e6bd52b2af37c8d782b479fedc518`）。
- 表半矩阵/注释与上游绘制对象一致；模板 fixed 回放与 source 一致。
- 未验证：完整 DE 基因集（本图用 head(20)）、split.by、add_dot/add_violin/feature_split/annotation 分支、真实 Seurat→CSV→模板流水线与科学有效性。
