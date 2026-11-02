# QA report

2026-10-22T05:36:55.854795Z

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
| original 可打开 | PASS | PNG 1728×1344 px |
| replica 可打开 | PASS | PNG 1728×1344 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×373 px |
| 宽高比 | PASS | 相对误差 0.0000%，阈值 ≤2% |

## 人工视觉 QA（未评定）

| 项目 | PASS/WARN/FAIL（待填） | 理由（待填） |
|---|---|---|
| 画布/宽高比 | PASS | 9×7 in；PNG 1728×1344，与来源完全一致。 |
| panel 布局与面板标签 | PASS | 单 panel；来源无 panel 字母，未添加。 |
| 颜色/发散方向 | PASS | 分类配色顺序与原图一致；无发散色标。 |
| 字体/中文缺字 | PASS | 仅英文标签；family `sans`（TT Arial），未出现缺字。 |
| 坐标轴/刻度 | PASS | 左下短箭头 UMAP_1/UMAP_2；无数字刻度，与原图一致。 |
| 图例/colorbar | PASS | 右侧 9 组图例，顺序与原图一致；无 colorbar。 |
| 数据形状/estimated 不确定项 | WARN | 合成簇的形状/密度与真实数据不同；Bipolar 用 12 个合成 blobs 近似；不能当原始观测。 |
| 注释 | PASS | 簇中心标签位置按合成中位数；个别标签与点重叠，原图同类标签也有重叠。 |
| 导出/矢量文字可编辑 | WARN | PNG/PDF/SVG 已生成；SVG 由 svglite 导出，外部查看器逐字检查未做。 |

作者/签核日期/结论：________

修图以满足检查；不得降低阈值以通过。
