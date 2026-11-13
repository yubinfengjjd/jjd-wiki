# 单panel：分组小提琴与统计标注

状态：review，待作者目视签核。机械 QA 0 失败。

## 来源

- 选定代表：`E:\青光眼单细胞\complement_violin.pdf`。
- 代码来源：`E:\青光眼单细胞\score_pathway_signatures.R`（补体通路小提琴段）。
- 选定裁图/完整原图：`source/fig06.png`、`source/full_original.png`。
- SHA-256：`f785723ef86aa6b0248fdda88a0325b32150c09e945b24f430a530248b71472b`
- bbox：`[0, 0, 2304, 1248]`。

## 数据

- `data/estimated_data.csv`：9 个细胞类型 × 2 组的合成细胞级通路得分。
- `data/estimated_summaries.csv`：每个细胞类型/组的 mean、SD、p 值、p 标签、mean/SD 标签和标注位置。
- 生成脚本 `data/make_synthetic.R`，随机种子 20261022；均值/SD 按来源图的视觉值近似。
- 关键限制：p 值来自细胞水平 Wilcoxon，细胞不独立，且每组只有 1 个样本；本图只作描述性展示，不能当组间推断。原脚本把非显著 p 也标成 `*P = ...`，本复刻改为明确的 `P = ...` / `P < 0.001`。

## 代码与运行

- `code/core.R`：`plot_grouped_violin()`，消费细胞级值 + 预计算摘要；不运行检验、不生成抖动以外的统计量。
- `code/replica.R`：读取示例表，导出 PNG/PDF/SVG。
- 环境：R 4.3.1；ggplot2 3.5.1、svglite 2.1.3；family `sans`。
- 输出：12×6.5 in，192 dpi，PNG 2304×1248。

## 保真重点与差异

- 保留：9 组小提琴 + 箱线 + 抖动、Control/Glaucoma 双色、每个细胞类型的 p 标签、Mean/SD 标签、顶部图例、标题。
- 差异：合成分布；p 标签格式由 `*P` 改为 `P`；部分 Mean/SD 标签重叠（来源也重叠）。
- 未验证：真实补体通路得分与检验未在本机重跑（Seurat 不可加载）。

## QA

- `qa_report.md`：机械检查 0 失败；人工视觉项见表格。
- 剩余问题：细胞水平 p 值的统计局限；作者签核待完成。
