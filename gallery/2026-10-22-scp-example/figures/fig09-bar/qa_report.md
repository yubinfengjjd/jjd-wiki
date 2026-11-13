# QA report

2026-10-22T14:30:00.000000Z

机械检查只核查文件、像素尺寸与宽高比；不判断视觉像不像，不代表作者签核。

| 自动检查 | 状态 | 证据 |
|---|---|---|
| meta.json | PASS | 文件存在且非空；不等于格式或视觉验收 |
| README.md | PASS | 文件存在且非空；不等于格式或视觉验收 |
| data/figure_spec.json | PASS | 文件存在且非空；不等于格式或视觉验收 |
| data/estimated_data.csv | PASS | 文件存在且非空；不等于格式或视觉验收 |
| output/replica.png | PASS | 文件存在且非空；不等于格式或视觉验收 |
| output/replica.pdf | PASS | 文件存在且非空；不等于格式或视觉验收 |
| output/replica.svg | PASS | 文件存在且非空；不等于格式或视觉验收 |
| compare/side_by_side.png | PASS | 文件存在且非空；不等于格式或视觉验收 |
| compare/overlay.png | PASS | 文件存在且非空；不等于格式或视觉验收 |
| thumb.png | PASS | 文件存在且非空；不等于格式或视觉验收 |
| run.log | PASS | 文件存在且非空；不等于格式或视觉验收 |
| 复刻代码 | PASS | code/replica.R 调 code/render.R |
| 原图存档 | PASS | source/fig09.png |
| original 可打开 | PASS | PNG 1200×900 px |
| replica 可打开 | PASS | PNG 1200×900 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×360 px |
| 宽高比 | PASS | 相对误差 0.0000%，阈值 ≤2% |

## 人工视觉 QA（agent 目视，2026-10-22）

| 项目 | PASS/WARN/FAIL | 理由 |
|---|---|---|
| 画布/宽高比 | PASS | 源图与复刻均为 1200×900 px（8×6 in, 150 dpi）。 |
| panel 布局与面板标签 | PASS | 单逻辑 panel；5 个 CellType 分组 × 3 个 Phase 系列的堆叠计数柱，柱内白色数字标签，右侧 `Phase:` 图例。源图无 A/B 标签，复刻也未添加。 |
| 颜色/发散方向 | PASS | 与源图相同调用 `palette_scp(..., palette="Paired")`：G1 浅蓝、S 深蓝、G2M 浅绿；逐字节一致。 |
| 字体/中文缺字 | PASS | 图中仅拉丁字符；无缺字。 |
| 坐标轴/刻度 | PASS | x 轴 CellType 五类、45° 旋转；y 轴 Count 0–400、虚线网格；与源图逐字节一致。 |
| 图例/colorbar | PASS | 图例标题 `Phase:`、类别顺序 G1/S/G2M、色块与黑色描边一致。 |
| 数据形状/estimated 不确定项 | PASS | 数据来自 `pancreas_sub@meta.data` 的 1000 个细胞（精确计数），不是估读；无 estimated 值。合计 1000（Ductal 239、Ngn3 low EP 81、Ngn3 high EP 168、Pre-endocrine 150、Endocrine 362）。 |
| 注释 | PASS | 无额外注释；源图与复刻均无标题/副标题。 |
| 导出/矢量文字可编辑 | PASS | PDF 用 cairo_pdf；SVG 用 svglite，文字为 `<text>` 元素；SVG 与 source 逐字节一致。 |

逐字节对比：`source/fig09.png` SHA256 `d9375658c7c439c9da75cf735d68211c5acb666fd282c2955d33cdc10d58ba71` = `output/replica.png` SHA256 `d9375658c7c439c9da75cf735d68211c5acb666fd282c2955d33cdc10d58ba71`；像素 mad = 0，RMS = 0，max = 0。

保留差异与限制：

- 参考 panel（Example-2.jpg 第 2 格）与本条目记录的 native call 同为 `position = "stack"` 的计数柱；第 1 格是 `position = "dodge"` 的变体，dodge 也已与上游逐字节核对（`../source/variants/compare.csv`），但不作为本 entry 的参考 panel。
- 上游 bar 在 8×6 画布上无可见裁切；标签与图例完整。
- `output/replica.pdf` 与 `source/fig09.pdf` 有 245 字节不同，位于一个尾部压缩流；PNG 与 SVG 均逐字节一致，未观察到页面内容差异。

作者/签核日期/结论：agent 代签（作者 2026-10-22 授权“沿用代签”），2026-10-22；逐字节、表半与六种变体核对通过。

修图以满足检查；不得降低阈值以通过。
