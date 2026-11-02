# 2026-10-22 S2：CellStatPlot 其余五形态

本记录覆盖 SCP v0.5.6 `CellStatPlot` / `StatPlot` 的 bar、sankey、chord、venn、upset 五个 `plot_type` 的原生复刻、画廊条目、模板、接口与方法关系。工作区：`E:/research-wiki-env/work/scp-native-claude/s2/<type>/`。

## 1. 画廊与来源

五个原生 source 均由未修改的上游调用在固定设备上生成；sankey/venn 因当前依赖 API 变化使用了记录在各自画廊 `PATCHES.md` 的兼容补丁，几何不变。

| 条目 | 原生调用 | source SHA256 | 参考 panel |
|---|---|---|---|
| `fig09-bar` | `CellStatPlot(pancreas_sub, stat.by="Phase", group.by="CellType", stat_type="count", plot_type="bar", label=TRUE)` | `d9375658…` | Example-2 第 2 格（stack；第 1 格是 dodge 变体） |
| `fig10-sankey` | `CellStatPlot(pancreas_sub, stat.by=c("CellType","Phase"), plot_type="sankey")` | `7b16c620…` | 第 12 格 |
| `fig11-chord` | `CellStatPlot(pancreas_sub, stat.by=c("CellType","Phase"), plot_type="chord")` | `6674db75…` | 第 4 格 |
| `fig12-venn` | `CellStatPlot(pancreas_sub, stat.by=c("Ductal","Endocrine","G1S","G2M"), plot_type="venn", stat_level="TRUE")` | `a5bf1995…` | 第 8 格 |
| `fig13-upset` | 同上，`plot_type="upset"` | `b2f0322d…` | 第 7 格 |

四个集合由 CellType/Phase 派生：Ductal = Ductal + Ngn3 low/high EP（488）；Endocrine = Pre-endocrine + Endocrine（512）；G1S = G1 + S（923）；G2M = G2M（77）。

## 2. 表半与绘图半

- bar：`scp_stat_table()` 的 15 行计数表与上游 `p0$data` 在列、因子水平、行序、数值上一致；仅多 5 个 provenance 属性。
- sankey：`make_long()`/`dat_use`、图例水平与上游一致；绘图保留 `geom_sankey()`、两个维度图例和 `patchwork` 组合。
- chord：`scp_chord_table()` 的 `table(useNA="ifany")` 矩阵与上游 identical；绘图保留 `circlize::chordDiagram()` 与 `recordPlot()`。
- venn：区域/集合表与上游一致；绘图保留 ggVennDiagram 区域/边/标签、`geom_text_repel` 和主题。
- upset：交集对象与上游 `p$data` 一致；绘图保留 `scale_x_upset(n_intersections=20)`、条形、标签和 `theme_combmatrix`。

## 3. 依赖兼容补丁（记录在各画廊 `PATCHES.md`）

- sankey（P1–P3）：
  - `do.call(cbind/rbind, legend_list)` → 先 `as_gtable()`，避免 gtable 0.3.6 拒绝 list matrix。
  - `wrap_plots(gtable)` → `wrap_plots(list(gtable))`，避免 patchwork 1.3.1 把 gtable 当 list matrix。
  - `get_legend()` 跳过 zeroGrob guide-box，取第一个非空图例；否则 ggplot2 3.5.2 下两个图例都为空。
  - 证明：三个阶段的图片 md5 对照，节点/流量几何不变。
- venn（P1–P3）：
  - `check_R()` → `requireNamespace()`。
  - ggVennDiagram >= 1.4 移除 sf 几何后，从 `process_data()$regionEdge/$setEdge/$setLabel` 坐标重建区域/边/标签。
  - 1.5.7 `venn_setedge()` 无 `name`，从 `venn_setlabel()` 按 id 补 name 后再取颜色。
  - 未与 1.2.x 逐字节交叉验证；区域/集合表与坐标一致。
- upset（P1–P7）：`check_R()`、交集表拆分、palette/alpha/show.legend 参数化、本地 helpers；默认值保持上游，固定 PNG 逐字节一致。
- bar（P1–P7）：单组合 hoist、`value` 列名、title/xlab 默认、namespace 限定；bar 分支几何不变，六个变体逐字节一致。

## 4. 模板与接口

| 模板 | 标题 | 接口 | 固定 SHA256 |
|---|---|---|---|
| `2026-10-22-scp-example__fig09-bar--bar` | 分组计数柱图 | `render-cell-metadata` | `d9375658…` |
| `2026-10-22-scp-example__fig10-sankey--sankey` | 分组流向桑基图 | `render-cell-linkage` | `7b16c620…` |
| `2026-10-22-scp-example__fig11-chord--chord` | 分组流向和弦图 | `render-cell-linkage` | `6674db75…` |
| `2026-10-22-scp-example__fig12-venn--venn` | 多集合交集维恩图 | `render-cell-membership` | `a5bf1995…` |
| `2026-10-22-scp-example__fig13-upset--upset` | 多集合交集 UpSet 图 | `render-cell-membership` | `b2f0322d…` |

- 新接口：
  - `render-cell-linkage`：`cell, dimension, category, dimension_order`；每细胞每维度一行。
  - `render-cell-membership`：`cell, set, member`；每细胞每集合一行，`member` 只取 0/1。
- 集成归一化：
  - bar 的 staged example 使用上游列名 `CellType/Phase`，集成时改为接口列 `group/stat`，spec 的 `group_col/stat_col` 同步；固定输出仍与 source 一致。
  - venn 的 staged example 是宽表；集成时改为 `cell,set,member` 长表，`panel.R` 增加 `venn_long_to_wide()`，`render.R` 在读表后透视；固定输出仍与 source 一致。
- 每模板 `verify-template` exit 0，`mark-ready`，`check-entry --record` 通过。

## 5. 知识关联

- 五个模板均登记到 `methods/scp-visualization-interface`，`compatibility: adaptable`，`verification.state: example`。
- 方法页新增 5 条 figure_relations；接口页 facts 自动列出读取模板；五个 layout 页补全适用/不适用/知识关联检查/使用记录。
- 新增图型页：`sankey`、`chord`、`venn`、`upset`（五节齐全）；`bar` 页增加 SCP 模板并修正“唯一模板”旧说法。

## 6. 验证

- 五模板固定 8×6@150 与各自画廊 source 逐字节一致。
- adaptive：bar 2×2→6.4×5.1、12×5→15.5×5.85；其余按各自参数增长；max 超限正确报错。
- 输入 CSV 运行前后哈希不变；模板复制到异目录仍可运行；template 代码无 `E:/research-wiki`、`SCP::`、`pancreas_sub` 依赖。
- `wiki.py lint` OK；`pending --json` 为空；方法页 `check-entry --record` 通过。
- 独立 verifier：sankey/chord/venn/upset 四项通过；bar 的 staging 版本被指出两个问题——example 使用上游列名 `CellType/Phase`（接口要求 `group/stat`）与参考 panel 选错（source 是 stack，参考却指第 1 格 dodge）。集成时已把 wiki example 归一化为 `group/stat`，并把画廊参考 panel 改为 Example-2 第 2 格（stack），重新 ingest 为 gallery v2；wiki 端 fixed 回放仍与 source 逐字节一致。verifier 未再重跑，但对应检查已由 `verify-template` 与上面的画廊更正覆盖。
- 未验证：真实 Seurat→CSV→模板流水线；sankey/chord 多 split；chord 第三维度；venn 与 ggVennDiagram 1.2.x 交叉验证；upset >20 交集截断；科学有效性。

## 7. 剩余

- S3：FeatureHeatmap、CellCorHeatmap、CellDensityPlot。
- S4：CellDimPlot / FeatureDimPlot 原生视觉。
- S5：FeatureStatPlot 各形态。
- S6：EnrichmentPlot / GSEAPlot。
- S7：Dynamic/Lineage/PAGA/Velocity/3D/Python 后端。
- S8：每批更新 STATUS/SOURCE_TO_OUTPUT/REPORT/manifest。
