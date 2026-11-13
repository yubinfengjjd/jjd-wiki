# QA report

2026-10-22T09:25:53.695193Z

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
| original 可打开 | PASS | PNG 1400×1200 px |
| replica 可打开 | PASS | PNG 1400×1200 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×411 px |
| 宽高比 | PASS | 相对误差 0.0000%，阈值 ≤2% |

## 人工视觉 QA（agent 目视，2026-10-22）

| 项目 | PASS/WARN/FAIL | 理由 |
|---|---|---|
| 画布/宽高比 | PASS | 源图与复刻均 1400×1200 px（7×6 in, 200 dpi）。 |
| panel 布局与面板标签 | PASS | 单 facet，顶部 `Endocrine`；无 A/B 标签，复刻一致。 |
| 颜色/发散方向 | PASS | `RdBu` 渐变，蓝负红正；色标 -5/0/5 与源图一致。 |
| 字体/中文缺字 | PASS | 图中仅拉丁字符；无缺字。 |
| 坐标轴/刻度 | PASS | x `diff_pct` -0.5/0.0/0.5；y 标签取绝对值，上下两侧 50/100 一致。 |
| 图例/colorbar | PASS | `log2FC` 色条位置、边框、刻度标签一致。 |
| 数据形状/estimated 不确定项 | PASS | 7343 个基因的 DE 表（FindMarkers 计算），点云、边界抖动与高亮层一致；无估读值。 |
| 注释 | PASS | 上下各 8 个标签、灰色引导线、阈值线均一致。 |
| 导出/矢量文字可编辑 | PASS | SVG 含 287 个 `<text>` 元素；PDF 用 cairo_pdf 生成。 |

像素对比：源图与复刻 PNG **完全相同**（mean abs diff 0，RMS 0，bbox `None`），SHA256 均为 `2b22c692...12308dd`。

作者/签核日期/结论：________（本表为 agent 目视记录，不等于作者签核）

修图以满足检查；不得降低阈值以通过。
