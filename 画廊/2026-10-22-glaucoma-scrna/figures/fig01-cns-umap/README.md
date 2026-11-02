# 单panel：CNS UMAP

状态：review，待作者目视签核。机械 QA 0 失败；视觉 QA 见 `qa_report.md`。

## 来源

- 选定代表：`E:\青光眼单细胞\umap_annotation.pdf`（celltype 着色，9 类）。
- 同款重复：`E:\青光眼单细胞\UMAP.pdf`（cluster 着色，0–17）；同一 CNS UMAP 画法，不作为第二个 panel。
- 选定裁图：`source/fig01.png`，完整原图同文件另存 `source/full_original.png`。
- SHA-256（裁图/完整原图相同）：`c03746544bf0a2a491f7a674c0101dc609eccd1459929e810c812774ab36b39a`
- bbox：`[0, 0, 1728, 1344]`；完整原图与裁图为同一单 panel 页面，未再裁切。
- 原图只读；本条目没有改动原始文件。

## 数据

- `data/estimated_data.csv`：合成 UMAP 坐标，1,804 个细胞，9 个细胞类型；不是 GSE251716 的原始观测。
- 生成脚本 `data/make_synthetic.R`，随机种子 20261022；簇中心按原图大致位置设置，仅用于样式对比。
- 关键限制：合成数据的簇形状、密度和 Bipolar 子簇数量与原图不同；不能据此推断真实细胞数、比例或生物学差异。

## 代码与运行

- `code/core.R`：`plot_cns_umap()`，消费 `cell_id, umap_1, umap_2, group`，返回 ggplot 对象；不读文件、不做分析、不保存。
- `code/replica.R`：读取 `data/estimated_data.csv`，调用核心函数，导出 PNG/PDF/SVG。
- 环境：R 4.3.1；ggplot2 3.5.1、ggunchull 1.0.1、svglite 2.1.3；字体 family `sans`（Windows 映射到 TT Arial）。
- 运行：

```powershell
$py = 'C:\Users\86186\.codex\venvs\sci-figure-replica\Scripts\python.exe'
& $py -X utf8 C:\Users\86186\.claude\skills\sci-figure-replica\scripts\run_code.py `
  --language r --code code/replica.R --cwd . `
  --config E:\research-wiki-env\tmp\replica-config.json
```

## 保真重点与差异

- 保留：点 + 虚线非凸包 + 簇中心标签 + 左下短箭头 UMAP_1/UMAP_2 + 右侧图例；配色和标签顺序按原图。
- 差异：合成簇的密度/形状不同；Bipolar 用 12 个小 blobs 近似原图的多个 Bipolar 簇；Amacrine 等小簇点数按原图视觉比例近似。
- 未验证：真实 GSE251716 数据未在本机回放（Seurat 因 Matrix 版本冲突不可加载）；本条目只验证画法与合成数据可运行。

## 输出与 QA

- `output/replica.png`、`replica.pdf`、`replica.svg`。
- `compare/side_by_side.png`、`compare/overlay.png`。
- `qa_report.md`：机械检查 0 失败；人工视觉项见表格。
- 剩余问题：合成数据不能替代真实数据；作者签核待完成。
