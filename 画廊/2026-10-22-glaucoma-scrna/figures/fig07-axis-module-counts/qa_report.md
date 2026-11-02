# QA report

2026-10-22T05:50:58.370534Z

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
| original 可打开 | PASS | PNG 2189×1523 px |
| replica 可打开 | PASS | PNG 2189×1527 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×335 px |
| 宽高比 | PASS | 相对误差 0.2620%，阈值 ≤2% |

## 人工视觉 QA（未评定）

| 项目 | PASS/WARN/FAIL（待填） | 理由（待填） |
|---|---|---|
| 画布/宽高比 | PASS | 7.4×5.2 in；PNG 2189×1527，与来源 2189×1523 基本一致（4 px 舍入）。 |
| panel 布局与面板标签 | PASS | 单 panel；5 个模块；无 panel 字母。 |
| 颜色/发散方向 | PASS | 蓝/橙双系列，与来源一致；无发散色标。 |
| 字体/中文缺字 | PASS | 英文标签；DejaVu Sans；β 字符正常显示。 |
| 坐标轴/刻度 | PASS | y 轴 Number of axes，0–500；x 标签换行；与来源一致。 |
| 图例/colorbar | PASS | 右上角 All ranked axes / Top 20 axes 图例，无边框；与来源一致。 |
| 数据形状/estimated 不确定项 | PASS | 真实 ranking CSV 计数；top20 为前 20 行；非合成。 |
| 注释 | PASS | 模块标签、轴标题完整；计数与来源一致。 |
| 导出/矢量文字可编辑 | WARN | PNG/PDF/SVG 已生成；SVG 外部查看器逐字检查未做。 |

作者/签核日期/结论：________

修图以满足检查；不得降低阈值以通过。
