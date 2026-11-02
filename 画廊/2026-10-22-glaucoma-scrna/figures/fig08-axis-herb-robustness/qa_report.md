# QA report

2026-10-22T05:53:11.099400Z

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
| original 可打开 | PASS | PNG 2248×1586 px |
| replica 可打开 | PASS | PNG 2247×1589 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×339 px |
| 宽高比 | PASS | 相对误差 0.2332%，阈值 ≤2% |

## 人工视觉 QA（未评定）

| 项目 | PASS/WARN/FAIL（待填） | 理由（待填） |
|---|---|---|
| 画布/宽高比 | PASS | 7.6×5.4 in；PNG 2247×1589，与来源 2248×1586 基本一致。 |
| panel 布局与面板标签 | PASS | 单 panel；10 个 herb；无 panel 字母。 |
| 颜色/发散方向 | PASS | 单一蓝色点 + 误差棒；无发散色标。 |
| 字体/中文缺字 | PASS | 英文 herb 名；DejaVu Sans；未出现缺字。 |
| 坐标轴/刻度 | PASS | x Robust score 2.01–2.08；y Herb；与来源一致。 |
| 图例/colorbar | PASS | 无图例/colorbar；与来源一致。 |
| 数据形状/estimated 不确定项 | PASS | 真实 cv_results.json；xerr=std*0.5 为来源脚本选择，不是 95% CI。 |
| 注释 | PASS | 轴标题完整；herb 排序与来源一致。 |
| 导出/矢量文字可编辑 | WARN | PNG/PDF/SVG 已生成；SVG 外部查看器逐字检查未做。 |

作者/签核日期/结论：________

修图以满足检查；不得降低阈值以通过。
