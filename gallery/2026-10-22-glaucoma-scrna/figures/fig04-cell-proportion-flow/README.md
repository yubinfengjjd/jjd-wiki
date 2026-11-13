# 单panel：细胞比例堆叠与流带

状态：review，待作者目视签核。机械 QA 0 失败。

## 来源

- 选定代表：`E:\青光眼单细胞\cell_proportion_flow.pdf`。
- 选定裁图/完整原图：`source/fig04.png`、`source/full_original.png`。
- SHA-256：`08a1bb5dc82dce225bc3be15e6f873e88ada9da32fe4a2cc38306491719c56d3`
- bbox：`[0, 0, 1056, 864]`。

## 数据

- `data/estimated_data.csv`：Control/Glaucoma × 9 个细胞类型的合成比例，每组归一化到 1；不是原始观测。
- 生成脚本 `data/make_synthetic.R`；比例按来源图的视觉比例近似。
- 限制：流带是相邻柱之间的视觉插值，不是统计估计；合成比例不能用于真实组间比较。

## 代码与运行

- `code/core.R`：`plot_cellprop_flow()`，消费 `group, celltype, proportion`，返回 ggplot 对象；支持任意合法组数/细胞类型数。
- `code/replica.R`：读取示例表，使用来源图的 9 色 UMAP 调色板，导出 PNG/PDF/SVG。
- 环境：R 4.3.1；ggplot2 3.5.1、dplyr、svglite 2.1.3；family `sans`。
- 输出：5.5×4.5 in，192 dpi，PNG 1056×864。

## 保真重点与差异

- 保留：两组堆叠柱、相邻组流带、右侧 Cell type 图例（逆序）、y 轴 0–1、配色与来源一致。
- 差异：合成比例与来源不同；柱宽/间距略有差异。
- 未验证：真实 GSE251716 比例未在本机重算（Seurat 不可加载）。

## QA

- `qa_report.md`：机械检查 0 失败；人工视觉项见表格。
- 剩余问题：合成数据限制；作者签核待完成。
