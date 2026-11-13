# QA report

2026-10-22T14:49:11.849390Z

机械检查只核查文件、像素尺寸、哈希与行数；不判断视觉像不像，不代表科学有效。

| 自动检查 | 状态 | 证据 |
|---|---|---|
| meta.json | PASS | 文件存在且为合法 JSON |
| README.md | PASS | 文件存在且非空 |
| PATCHES.md | PASS | 文件存在且非空 |
| data/figure_spec.json | PASS | 文件存在且为合法 JSON |
| data/render-cell-linkage.csv | PASS | 2000 行（1000 细胞 × 2 维度） |
| data/chord-count-matrix.csv | PASS | 15 行聚合计数 |
| data/estimated_data.csv | PASS | 文件存在且非空；本图数据不是估读值 |
| source/fig11.png | PASS | PNG 1200×900 px |
| output/replica.png | PASS | PNG 1200×900 px |
| output/replica.pdf | PASS | 文件存在且非空 |
| output/replica.svg | PASS | 文件存在且非空 |
| compare/side_by_side.png | PASS | 2424×960 px |
| compare/overlay.png | PASS | 1200×900 px |
| thumb.png | PASS | PNG 480×360 px |
| original_code/cellstat.R | PASS | 上游 4463–5678 行摘录 + 2 行来源头 |
| original_code/provenance.json | PASS | 完整文件与摘录 SHA256 一致 |
| code/replica.R | PASS | 画廊入口存在 |
| code/scp_chord_native.R | PASS | 原生表半/绘图半存在 |
| code/scp_helpers.R | PASS | 仅 palette_scp + palette_list |
| code/data/palette_list.rda | PASS | 模板本地 palette 数据 |
| 宽高比 | PASS | source 与 replica 均为 1200×900，相对误差 0.0000% |

## 人工视觉 QA（agent 目视，2026-10-22）

| 项目 | PASS/WARN/FAIL | 理由 |
|---|---|---|
| 画布/宽高比 | PASS | source 与 replica 均为 1200×900 px（8×6 in, 150 dpi）。 |
| panel 布局与面板标签 | PASS | 单逻辑 panel；和弦图按 CellType（5 扇区）与 Phase（3 扇区）环绕排布。源图无 A/B 标签，复刻也未添加。 |
| 颜色/发散方向 | PASS | 与上游相同 `palette_scp(..., palette = "Paired")`；8 个扇区颜色与捕获的 `grid.col` 完全一致，链接透明度 0.2。 |
| 字体/中文缺字 | PASS | 图中仅拉丁字符；无缺字。 |
| 扇区/刻度 | PASS | 扇区顺序、角度刻度、类别标签与 source 逐字节一致。 |
| 图例/colorbar | PASS | 上游 chord 分支不画 ggplot 图例；复刻同样没有图例。 |
| 数据形状/estimated 不确定项 | PASS | 数据来自 `pancreas_sub@meta.data` 的 1000 个细胞；矩阵 5×3 与上游 `table(useNA = "ifany")` 完全一致，无 estimated 值。 |
| 注释 | PASS | 无额外标题/副标题/注释。 |
| 导出/矢量文字可编辑 | PASS | PDF 用 cairo_pdf；SVG 用 svglite，文字为 `<text>` 元素。 |

逐字节对比：`source/fig11.png` SHA256 `6674db75622654c4da8e7a96250d264fb0be29720f380889c2ee78e9dcd36de6` = `output/replica.png` SHA256 `6674db75622654c4da8e7a96250d264fb0be29720f380889c2ee78e9dcd36de6`；像素 mad = 0、RMS = 0、max = 0。

表半对比：上游 `chordDiagram()` 实参矩阵与 `scp_chord_table()` 输出 `identical()` 为 `TRUE`（5×3，dimnames `CellType × Phase` 一致）；颜色向量 `identical()` 为 `TRUE`。矩阵同时等于按上游 5117–5119 行独立重建的结果。

模板回归：固定 8×6@150 输出 SHA256 `6674db75622654c4da8e7a96250d264fb0be29720f380889c2ee78e9dcd36de6`，与画廊 source 相同；adaptive small 6.4×5 in、large 11.83×8.8725 in；`max_width_in = 6` 时以清晰错误拒绝；输入 CSV 运行前后同哈希；异目录复制运行输出同哈希；列名改映射（cid/dim/cat/ord）后输出同哈希；显式反序维度（Phase 先）正常出图且哈希不同。

保留差异与限制：

- 参考 panel 是 Example-2.jpg 第 4 格的下采样拼图切片，底部标签在原图中被边界裁切；它是结构/颜色参考，不是像素目标。独立 8×6 source 的圆环留白与标签完整显示与参考 tile 不同。
- 上游 chord 只支持两个 `stat.by` 且忽略 `group.by`；`split.by` 多 panel 与 `combine = FALSE` 未实现。
- 上游强制 `stat_type = "count"`，chord 不显示比例；`alpha`/`label`/`legend` 在该分支无效。
- 逐字节一致依赖 R 4.5.0 + cairo png 与相同设备参数；PDF 含创建时间，跨次不可逐字节比较。
- 字体仅拉丁字符，未验证中文标签。

作者/签核日期/结论：沿用作者 2026-10-22“代签”授权；逐字节、表半、模板回归与视觉检查通过，2026-10-22。

修图以满足检查；不得降低阈值以通过。
