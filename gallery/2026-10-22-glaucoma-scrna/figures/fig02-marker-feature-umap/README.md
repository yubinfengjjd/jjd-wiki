# 单panel：marker 特征 UMAP 网格

状态：review，待作者目视签核。机械 QA 0 失败；视觉 QA 见 `qa_report.md`。

## 来源

- 选定代表：`E:\青光眼单细胞\marker_feature_umap.pdf`，3×3 marker 特征 UMAP；九个 axes 属于一个逻辑 panel。
- 选定裁图/完整原图：`source/fig02.png`、`source/full_original.png`（同一单 panel 页面）。
- SHA-256：`642d17e831d389bcb5e1cd19e7480c6043614711210dab7bf1d4cdeb7705438c`
- bbox：`[0, 0, 2113, 1920]`。

## 数据

- `data/estimated_coordinates.csv`：1,804 个合成细胞，9 个细胞类型。
- `data/estimated_expression.csv`：9 个基因 × 1,804 个细胞的合成长表。
- `data/estimated_data.csv`：合并后的长表（`cell_id, umap_1, umap_2, group, feature, value`），供 QA 和复用示例。
- 生成脚本 `data/make_synthetic.R`，随机种子 20261022；x 坐标乘 1.8 仅为让 3×3 网格在 11×10 画布上更易读，不是原始 UMAP 几何。
- 关键限制：合成表达只模拟“目标细胞类型高、其他类型低”的样式；不能用于真实 marker 特异性、细胞数或生物学差异推断。

## 代码与运行

- `code/core.R`：`plot_feature_umap_grid()`，消费坐标表 + 表达长表 + 基因→目标细胞类型映射，返回 patchwork 或 ggplot 列表；不读文件、不做分析、不保存。
- `code/replica.R`：读取示例表，使用 `cowplot::plot_grid` 排列 3×3，导出 PNG/PDF/SVG。
- 环境：R 4.3.1；ggplot2 3.5.1、ggunchull 1.0.1、cowplot、svglite 2.1.3；family `sans`。
- 运行：

```powershell
$py = 'C:\Users\86186\.codex\venvs\sci-figure-replica\Scripts\python.exe'
& $py -X utf8 C:\Users\86186\.claude\skills\sci-figure-replica\scripts\run_code.py `
  --language r --code code/replica.R --cwd . `
  --config E:\research-wiki-env\tmp\replica-config.json
```

## 保真重点与差异

- 保留：3×3 网格、灰色背景点、表达渐变、目标细胞类型虚线轮廓、每个 panel 的 colorbar、左下短箭头、斜体基因名。
- 差异：合成数据的簇形状和密度不同；`cowplot` 布局下 panel 比来源略小、标题与 panel 间距偏大；每个 panel 的 colorbar 独立，未共用。
- 未验证：真实 GSE251716 数据未在本机回放（Seurat 因 Matrix 版本冲突不可加载）。

## 输出与 QA

- `output/replica.png`（11×10 in，192 dpi，2112×1920）、`replica.pdf`、`replica.svg`。
- `compare/side_by_side.png`、`compare/overlay.png`。
- `qa_report.md`：机械检查 0 失败；人工视觉项见表格。
- 剩余问题：panel 尺寸/间距为 WARN；合成数据不能替代真实数据；作者签核待完成。
