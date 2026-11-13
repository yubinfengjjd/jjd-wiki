# QA report

2026-10-22T11:38:25.948768Z

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
| thumb.png | PASS | 文件存在且非空；不等于格式或视觉验收 |
| run.log | PASS | 文件存在且非空；不等于格式或视觉验收 |
| 复刻代码 | PASS | 需要 replica.py 或 replica.R |
| 原图存档 | PASS | source/figNN.png |
| original 可打开 | PASS | PNG 1200×900 px |
| replica 可打开 | PASS | PNG 1200×900 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×360 px |
| 宽高比 | PASS | 相对误差 0.0000%，阈值 ≤2% |

## 人工视觉 QA（agent 目视，2026-10-22）

| 项目 | PASS/WARN/FAIL | 理由 |
|---|---|---|
| 画布/宽高比 | PASS | 源图与复刻均为 1200×900 px（8×6 in, 150 dpi）。 |
| panel 布局与面板标签 | PASS | 单逻辑 panel；面积图（percent, label=TRUE）：5 个 CellType 的 100% 堆叠面积，标签为百分比。 源图无 A/B 标签，复刻也未添加。 |
| 颜色/发散方向 | PASS | 与源图相同调用 `palette_scp(..., palette="Paired")`；填色逐字节一致。 |
| 字体/中文缺字 | PASS | 图中仅拉丁字符与百分号；无缺字。 |
| 坐标轴/刻度 | PASS | 轴类别、刻度与标签位置逐字节一致。 |
| 图例/colorbar | PASS | 图例标题 `Phase:`、类别顺序 G1/S/G2M、色块与描边一致。 |
| 数据形状/estimated 不确定项 | PASS | 数据来自 `pancreas_sub@meta.data` 的 1000 个细胞（精确计数），不是估读；无 estimated 值。 |
| 注释 | PASS | 无额外注释；源图与复刻均无标题/副标题。 |
| 导出/矢量文字可编辑 | PASS | PDF 用 cairo_pdf；SVG 用 svglite，文字为 `<text>` 元素。 |

逐字节对比：`source/fig06.png` SHA256 `d7428e700a306ff689d04244c19f4b3bdae0dc01259178a5184b7f9ed755fcc9` = `output/replica.png` SHA256 `d7428e700a306ff689d04244c19f4b3bdae0dc01259178a5184b7f9ed755fcc9`；PNG 像素完全一致（mad = 0, RMS = 0）。

保留差异与限制：上游 area 在 8×6 画布上首列百分比标签被 panel 左边界裁切；源图与复刻同样裁切，未改上游 x 轴几何。

作者/签核日期/结论：agent 代签（作者 2026-10-22 授权“沿用代签”），2026-10-22；逐字节与数据核对通过。

修图以满足检查；不得降低阈值以通过。
