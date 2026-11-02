# 单panel：顶刊气泡点图

状态：review，待作者目视签核。机械 QA 0 失败。

## 来源

- 选定代表：`E:\青光眼单细胞\annotation_bubble.pdf`。
- 同源不同样式：`annotation.pdf`（SCpubr 点图）未选入；按作者确认只保留本顶刊气泡样式。
- 选定裁图/完整原图：`source/fig03.png`、`source/full_original.png`。
- SHA-256：`12e88bd5bd8a3704af779facd0f555fdd88e9ad0e5cc80ae4149ab659f69beb1`
- bbox：`[0, 0, 1153, 2304]`。

## 数据

- `data/estimated_data.csv`：52 个 marker × 9 个细胞类型的合成 `avg_expression` / `pct_expressed`；不是原始观测。
- 生成脚本 `data/make_synthetic.R`，随机种子 20261022；目标细胞类型取较高值，其余类型取低值；Astrocyte/Microglia/Macrophage/Endothelial/Fibroblast 无对应注释类型，排在末尾。
- 限制：合成数值只展示颜色/大小编码，不可用于 marker 特异性或表达差异推断。

## 代码与运行

- `code/core.R`：`plot_dotplot_bubble()`，消费 `group, feature, avg_expression, pct_expressed`，返回 ggplot 对象；支持任意合法组数/基因数。
- `code/replica.R`：读取示例表，按目标细胞类型位置排序基因，导出 PNG/PDF/SVG。
- 环境：R 4.3.1；ggplot2 3.5.1、scales、svglite 2.1.3；family `sans`。
- 输出：6×12 in，192 dpi，PNG 1152×2304。

## 保真重点与差异

- 保留：灰底黑框、底部 9 个细胞类型色块、x 标签 90°、y 基因斜体、Relative Expression 渐变、Percentage Expressed 大小图例。
- 差异：合成数值的强弱分布与来源不同；气泡大小/颜色不表示真实 marker 表达。
- 未验证：真实 GSE251716 表达矩阵未在本机回放（Seurat 因 Matrix 版本冲突不可加载）。

## QA

- `qa_report.md`：机械检查 0 失败；人工视觉项见表格。
- 剩余问题：合成数据限制；作者签核待完成。
