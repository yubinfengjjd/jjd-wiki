# QA report

2026-10-22T14:45:00.000000Z

机械检查只核查文件、像素尺寸与宽高比；不判断视觉像不像，不代表作者签核。

| 自动检查 | 状态 | 证据 |
|---|---|---|
| meta.json | PASS | 文件存在且非空；不等于格式或视觉验收 |
| README.md | PASS | 文件存在且非空；不等于格式或视觉验收 |
| PATCHES.md | PASS | 三条兼容补丁及几何不变证明 |
| data/figure_spec.json | PASS | 文件存在且非空；不等于格式或视觉验收 |
| data/estimated_data.csv | PASS | 文件存在且非空；不等于格式或视觉验收 |
| data/render-cell-linkage.csv | PASS | 2000 行 = 1000 细胞 × 2 维度；cell × dimension 唯一 |
| data/celltype_phase_counts.csv | PASS | 15 行聚合计数 + 组内比例；合计 1000 |
| output/replica.png | PASS | 文件存在且非空 |
| output/replica.pdf | PASS | 文件存在且非空 |
| output/replica.svg | PASS | 文件存在且非空 |
| compare/side_by_side.png | PASS | 文件存在且非空 |
| compare/overlay.png | PASS | 文件存在且非空 |
| thumb.png | PASS | 文件存在且非空 |
| run.log | PASS | 文件存在且非空 |
| 复刻代码 | PASS | code/replica.R + code/render.R + 原生 core |
| 原图存档 | PASS | source/fig10.png |
| original 可打开 | PASS | PNG 1200×900 px |
| replica 可打开 | PASS | PNG 1200×900 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×360 px |
| 宽高比 | PASS | 相对误差 0.0000%，阈值 ≤2% |

## 人工视觉 QA（agent 目视，2026-10-22）

| 项目 | PASS/WARN/FAIL | 理由 |
|---|---|---|
| 画布/宽高比 | PASS | 源图与复刻均为 1200×900 px（8×6 in, 150 dpi）。 |
| panel 布局与面板标签 | PASS | 单逻辑 panel；左侧 CellType 节点、右侧 Phase 节点、中间流向；x 轴类别标签 `CellType`、`Phase`。源图无 A/B 标签，复刻也未添加。 |
| 颜色/发散方向 | PASS | 与源图相同调用 `palette_scp(..., palette="Paired")`；节点与流向填色逐字节一致。 |
| 字体/中文缺字 | PASS | 图中仅拉丁字符；无缺字。 |
| 坐标轴/刻度 | PASS | `theme_void()` + `axis.text.x` 仅显示维度名；位置逐字节一致。 |
| 图例/colorbar | PASS | 右侧两个图例均存在且可读：CellType（Ductal、Ngn3 low EP、Ngn3 high EP、Pre-endocrine、Endocrine）与 Phase（G1、S、G2M），色块与黑色描边一致。 |
| 数据形状/estimated 不确定项 | PASS | 数据来自 `pancreas_sub@meta.data` 的 1000 个细胞（精确计数），不是估读；无 estimated 值。 |
| 注释 | PASS | 无额外标题/副标题；源图与复刻均无注释。 |
| 导出/矢量文字可编辑 | PASS | PDF 用 cairo_pdf；SVG 用 svglite，文字为 `<text>` 元素。 |

逐字节对比：`source/fig10.png` SHA256 `7b16c62001e6780ff1c4fd2bee40eb230127704717bc37b4a792afc675fcbf95` = `output/replica.png` SHA256 `7b16c62001e6780ff1c4fd2bee40eb230127704717bc37b4a792afc675fcbf95`；PNG 像素完全一致（mad = 0, RMS = 0）。

表半核对：`make_long()`、`dat_use`、`colors`、图例 levels 均 `identical()` TRUE；node 矩形与 flow 几何对照 `ggplot_build()` 完全一致；flow 计数与 `table(CellType, Phase)` 一致（12 条非零流向，合计 1000）。

保留差异与限制：参考 panel 12 的图例按字母序（Ductal、Endocrine、Ngn3 high EP、Ngn3 low EP、Pre-endocrine；G1、G2M、S），当前上游函数按 factor level 顺序（Ductal、Ngn3 low EP、Ngn3 high EP、Pre-endocrine、Endocrine；G1、S、G2M）。本条目保留上游顺序。sankey 分支忽略 `group.by`、强制 count；只实现默认单 split；未验证 NA 类别、>100 levels、其他 palette 与多 split。

作者/签核日期/结论：agent 代签（作者 2026-10-22 授权“沿用代签”），2026-10-22；逐字节、表半与数据核对通过。

修图以满足检查；不得降低阈值以通过。
