# QA report

2026-10-22T09:18:00.762280Z

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
| panel 布局与面板标签 | PASS | 单逻辑 panel；源图无 A/B 标签，复刻也未添加。环形面板、右侧图例位置一致。 |
| 颜色/发散方向 | PASS | 与源图相同调用 `palette_scp(..., palette="Paired")`，G1/S/G2M 填色逐层相等。 |
| 字体/中文缺字 | PASS | 图中仅拉丁字符与百分号；无缺字。 |
| 坐标轴/刻度 | PASS | 25%/50%/75% 环刻度位置一致；顶部 0%/100% 端点合并显示一致。 |
| 图例/colorbar | PASS | 标题 `Phase:`、G1/S/G2M 顺序、色块与黑色描边一致。 |
| 数据形状/estimated 不确定项 | PASS | 数据来自 `pancreas_sub` 元数据的精确计数（239/240/... 细胞），不是估读；无 estimated 值。 |
| 注释 | PASS | 无额外注释；源图与复刻均无标题/副标题。 |
| 导出/矢量文字可编辑 | PASS | SVG 含 271 个 `<text>` 元素（文字可编辑）；PDF 用 cairo_pdf 生成。 |

机械对比：源图与复刻 PNG 均为 1200×900；逐像素平均绝对差 1.17e-05，RMS 0.0036，差异 bbox (566,466)-(600,489)，仅环中心极小区域（抗锯齿/端点标签重绘），外周环、标签、图例无可测差异。

作者/签核日期/结论：________（本表为 agent 目视记录，不等于作者签核）

修图以满足检查；不得降低阈值以通过。
