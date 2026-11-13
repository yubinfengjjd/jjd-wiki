# QA report

2026-10-22T05:40:36.487871Z

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
| original 可打开 | PASS | PNG 1153×2304 px |
| replica 可打开 | PASS | PNG 1152×2304 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×960 px |
| 宽高比 | PASS | 相对误差 0.0867%，阈值 ≤2% |

## 人工视觉 QA（未评定）

| 项目 | PASS/WARN/FAIL（待填） | 理由（待填） |
|---|---|---|
| 画布/宽高比 | PASS | 6×12 in；PNG 1152×2304，与来源 1153×2304 比例一致。 |
| panel 布局与面板标签 | PASS | 单 panel；底部色块为组注释，不另算 panel；无 panel 字母。 |
| 颜色/发散方向 | PASS | 蓝→白→红 Relative Expression，方向与原图一致。 |
| 字体/中文缺字 | PASS | 仅英文基因/细胞类型；family `sans`，未出现缺字。 |
| 坐标轴/刻度 | PASS | x 细胞类型 90°；y 基因斜体；无数字刻度。 |
| 图例/colorbar | PASS | 右侧 Percentage Expressed 大小图例 + Relative Expression colorbar，位置与原图一致。 |
| 数据形状/estimated 不确定项 | WARN | 合成数值；目标类型高、其他类型低；不能当真实 marker 表达或特异性。 |
| 注释 | PASS | 底部 9 个组色块、x/y 标签完整；与来源布局一致。 |
| 导出/矢量文字可编辑 | WARN | PNG/PDF/SVG 已生成；SVG 由 svglite 导出，外部查看器逐字检查未做。 |

作者/签核日期/结论：________

修图以满足检查；不得降低阈值以通过。
