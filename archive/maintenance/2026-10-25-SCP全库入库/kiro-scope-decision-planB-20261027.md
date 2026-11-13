# 范围决定：方案 B（作者 2026-10-27 确认）

- 每个可视化入口只做 1 个代表模板；其余具名形态（plot_type、mark_type、edge_line、color_blend_mode 等）作为参数形态写入技术页，并在去向表 `named_forms` 中逐项记录原生状态。
- 已开发完成且与原生逐像素一致的结构（v2 FeatureStatPlot 5 型 + FeatureCorPlot，v3 CellDimPlot group/mark/hex、FeatureDimPlot single/blend）保留，按流水线入库：开发成本已经付出，入库只是固定的官方流程开销。
- 热图批次（v1）停止：GroupHeatmap 已有 fig08（ht1）、fig17（点阵），FeatureHeatmap 已有 fig14，均为 ready 代表模板；add_violin/flip/split.by/cell_annotation 等记为参数形态。
- 轨迹/网络批次：DynamicPlot、DynamicHeatmap、GraphPlot、LineagePlot、ProjectionPlot 各 1 个；CellDimPlot graph-edges 不做。
- 富集/GSEA：原生材料生成全部 plot_type（用来记录可运行性），模板只做 EnrichmentPlot（bar）和 GSEAPlot（line）。
- 3D 两个仍然建模板，停在 draft。PAGA、Velocity 缺上游结果，不入模板。
