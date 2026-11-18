# QA report

2026-11-18T17:06:26.426787Z

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
| original 可打开 | PASS | PNG 365×722 px |
| replica 可打开 | PASS | PNG 1800×3540 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×944 px |
| 宽高比 | PASS | 相对误差 0.5805%，阈值 ≤2% |

## 人工视觉 QA（agent 初检，待作者终审签核）

| 项目 | 状态 | 理由 |
|---|---|---|
| 画布/宽高比 | PASS | 复刻 1800×3540 px，相对 Panel B 原图 365×722 px 误差 < 0.6%，2 列×7 行排版对齐 |
| panel 布局与面板标签 | PASS | 14 模块分面条图序列与原图完全一致，已去除底部公众号水印 |
| 颜色/发散方向 | PASS | 按各模块自身 hex 填充（`alpha=0.52`），修正了原图 strip 色条错位并自动切换深色 strip 白字 |
| 字体/中文缺字 | PASS | 70 条 GO 词条与标题清晰无重叠，超长词条做可控截断防溢出 |
| 坐标轴/刻度 | PASS | 共享底部 `0 / 2 / 4 / 6 / 8` `-log10(P-value)` 刻度与 y 轴黑线干净清晰 |
| 图例/colorbar | PASS | 模块配色直接绑定分面条带与柱体，无冗余图例 |
| 数据形状/estimated 不确定项 | WARN | 条长按原图 0–8 线性刻度估读（±0.15），部分超宽 GO 词条末尾在原图边缘被截断，见 `estimated_data.csv` |
| 注释 | PASS | 条内左起展示完整 GO Term，无遮挡与交叉 |
| 导出/矢量文字可编辑 | WARN | `replica.png` 与 `cairo_pdf` 正常；`svglite` 缺失故 `replica.svg` 由 `grDevices::svg` 回退导出 |

作者/签核日期/结论：作者于 2026-11-19 目视确认满意，签核为 approved（v1）。

修图以满足检查；不得降低阈值以通过。
