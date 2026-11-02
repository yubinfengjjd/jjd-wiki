# QA report

2026-10-22T05:47:01.093204Z

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
| original 可打开 | PASS | PNG 1536×672 px |
| replica 可打开 | PASS | PNG 1920×844 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×211 px |
| 宽高比 | PASS | 相对误差 0.4739%，阈值 ≤2% |

## 人工视觉 QA（未评定）

| 项目 | PASS/WARN/FAIL（待填） | 理由（待填） |
|---|---|---|
| 画布/宽高比 | PASS | 10×4.4 in；PNG 1920×845，与来源 1536×672 比例接近（约 0.7% 差异）。 |
| panel 布局与面板标签 | PASS | 单 panel；无 panel 字母（来源也没有）。 |
| 颜色/发散方向 | PASS | 蓝（低）→白（0）→红（高），方向与来源一致。 |
| 字体/中文缺字 | PASS | 仅英文；family `sans`，行名斜体，未出现缺字。 |
| 坐标轴/刻度 | PASS | 无 x/y 数字刻度；列标题 45°，与来源一致。 |
| 图例/colorbar | PASS | 左侧 Condition 图例 + Mean score colorbar；位置、方向一致。 |
| 数据形状/estimated 不确定项 | WARN | 合成得分；行聚类顺序与来源不同；colorbar 范围 2.28 vs 来源 2.2。 |
| 注释 | PASS | 列分割标题、底部 condition 条、斜体行名完整。 |
| 导出/矢量文字可编辑 | WARN | PNG/PDF/SVG 已生成；SVG 外部查看器逐字检查未做。 |

作者/签核日期/结论：________

修图以满足检查；不得降低阈值以通过。
