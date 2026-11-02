# QA report

2026-10-22T07:59:04.146009Z

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

## 人工视觉 QA（未评定）

| 项目 | PASS/WARN/FAIL（待填） | 理由（待填） |
|---|---|---|
| 画布/宽高比 | PASS | 1400×1200，宽高比一致 |
| panel 布局与面板标签 | PASS | 单 panel；标题 Endocrine 与坐标轴一致 |
| 颜色/发散方向 | PASS | 负值蓝、正值红，方向一致 |
| 字体/中文缺字 | PASS | 纯英文，无缺字 |
| 坐标轴/刻度 | PASS | 轴标题、刻度、signed y 轴一致 |
| 图例/colorbar | WARN | colorbar 刻度密度不同（源 3 档，复刻 5 档）；位置/标题一致 |
| 数据形状/estimated 不确定项 | PASS | 同一 DE 表；DE 计算为 Seurat 替代，已在 README 记录 |
| 注释 | PASS | 标签基因与位置基本一致 |
| 导出/矢量文字可编辑 | PASS | cairo PDF + svglite SVG |

作者/签核日期/结论：待作者目视签核；agent 目视仅作对比记录，不等于作者确认。

修图以满足检查；不得降低阈值以通过。
