# Verification

日期 2026-10-23；环境 Windows 11，R 4.5.0。

命令：

```powershell
cd 知识库/methods/scp-visualization-interface/code
Rscript --vanilla test_scp_tables.R
```

结果：**25 PASS，0 FAIL**。覆盖：

- `scp_umap_groups()` 列名、顺序、group 值、重复坐标/缺失元数据报错。
- `scp_umap_feature_long()` 宽表和长表输入一致、列名、行数、未知 feature 报错。
- `scp_dotplot_long()` 列名、0–100 范围、target_group 映射、fraction→percent 显式转换、未声明 `pct_scale` 报错、>100 报错。
- `scp_grouped_values()` 列名和值。
- `scp_cell_proportions()` 列名、每组和=1、NA 分组报错。
- `scp_cell_metadata()` 列名、每细胞一行、重复细胞/NA 分组报错。
- `scp_write_interface()` 写 CSV 并读回列名。

未覆盖：

- SCP 绘图函数（`CellDimPlot`、`FeatureDimPlot`、`CellStatPlot`、`FeatureStatPlot`、`GroupHeatmap` 等）未运行；Seurat/ComplexHeatmap 等依赖缺失。
- SCP 图与 Wiki 模板的视觉等价、颜色/布局/字体/尺寸未对照。
- 模板 `render` 未用这些合成表完整跑通。曾用 `scp_umap_groups()` 生成 `render-umap-groups.csv` 并调用 fig01：模板能读取 CSV；固定 `group_levels` 不匹配时需在 style 中处理（传 `{"group_levels": null}` 可让模板从数据推导，但会失去显式顺序控制）；随后因当前 R 环境缺少 `ggunchull` 停止，未完成端到端渲染。
- 真实 SCP 输出（Seurat 对象/tools 槽）到 CSV 的完整导出未联调。

结论：适配层只证明“给定列名正确的表，能产生接口要求的列和值”；不证明 SCP 图可复现、模板可直接套用或统计有效。
