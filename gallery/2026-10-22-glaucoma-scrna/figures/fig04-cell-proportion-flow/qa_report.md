# QA report

2026-10-22T05:43:21.774277Z

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
| original 可打开 | PASS | PNG 1056×864 px |
| replica 可打开 | PASS | PNG 1056×864 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×393 px |
| 宽高比 | PASS | 相对误差 0.0000%，阈值 ≤2% |

## 人工视觉 QA（未评定）

| 项目 | PASS/WARN/FAIL（待填） | 理由（待填） |
|---|---|---|
| 画布/宽高比 | PASS | 5.5×4.5 in；PNG 1056×864，与来源一致。 |
| panel 布局与面板标签 | PASS | 单 panel；两根柱 + 一条流带；无 panel 字母。 |
| 颜色/发散方向 | PASS | 9 色 UMAP 调色板与来源一致；图例顺序逆序。 |
| 字体/中文缺字 | PASS | 仅英文；family `sans`，未出现缺字。 |
| 坐标轴/刻度 | PASS | y 0–1，0.25 间隔；x Control/Glaucoma；与原图一致。 |
| 图例/colorbar | PASS | 右侧 Cell type 图例，9 类，顺序与原图一致。 |
| 数据形状/estimated 不确定项 | WARN | 合成比例；只近似来源视觉比例；不能用于真实组间比较。 |
| 注释 | PASS | 图例标题、轴标题完整；流带透明度与原图接近。 |
| 导出/矢量文字可编辑 | WARN | PNG/PDF/SVG 已生成；SVG 外部查看器逐字检查未做。 |

作者/签核日期/结论：________

修图以满足检查；不得降低阈值以通过。
