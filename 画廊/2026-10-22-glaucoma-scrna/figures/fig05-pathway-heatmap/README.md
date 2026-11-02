# 单panel：通路热图

状态：review，待作者目视签核。机械 QA 0 失败。

## 来源

- 选定代表：`E:\青光眼单细胞\pathway_heatmap.pdf`。
- 绘图函数来源：`E:\青光眼单细胞\pathway_heatmap_cns_function.R`；实际调用在 `score_pathway_signatures.R`。
- 选定裁图/完整原图：`source/fig05.png`、`source/full_original.png`。
- SHA-256：`c7f9e6925d5de90fcbe5dbe6c7e5013a38888ec41d0d1853fdc4bb9bfdcfbfa6`
- bbox：`[0, 0, 1536, 672]`。

## 数据

- `data/estimated_data.csv`：10 个通路 × 9 个细胞类型 × 2 个条件的合成得分长表。
- `data/estimated_columns.csv`：18 列的 `column_id, celltype, condition` 注释。
- 生成脚本 `data/make_synthetic.R`，随机种子 20261022；细胞类型偏好和 condition 效应按来源图的视觉模式近似。
- 限制：合成得分只展示热图编码；行 z-score 后颜色是相对高低，不是绝对通路活性。

## 代码与运行

- `code/core.R`：`plot_pathway_heatmap_cns()`，消费矩阵 + 命名 celltype/condition 向量；绘制列分割、底部注释、行聚类、图例。
- `code/replica.R`：从长表构建矩阵，调用核心函数，导出 PNG/PDF/SVG。
- 环境：R 4.3.1；ComplexHeatmap、circlize、svglite；字体 `sans`。
- 输出：10×4.4 in，192 dpi，PNG 1920×845。

## 保真重点与差异

- 保留：列按细胞类型分割、每块 Control/Glaucoma、底部 Condition 注释、行聚类树、斜体行名、蓝–白–红 row z-score、左侧图例。
- 差异：合成数据的行聚类顺序与来源不同（来源：Complement classical、Complement total、TNF NFKB…；本图：Inflammation、Reactive glia、Complement total…）；colorbar 刻度 2.28 而非 2.2。
- 未验证：真实 GSE251716 通路得分未在本机重算（Seurat 不可加载）。

## QA

- `qa_report.md`：机械检查 0 失败；人工视觉项见表格。
- 剩余问题：行顺序/刻度差异来自合成数据；作者签核待完成。
