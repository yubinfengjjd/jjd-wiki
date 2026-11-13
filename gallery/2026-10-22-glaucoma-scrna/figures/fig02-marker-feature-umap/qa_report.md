# QA report

2026-10-22T05:36:56.012428Z

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
| original 可打开 | PASS | PNG 2113×1920 px |
| replica 可打开 | PASS | PNG 2112×1920 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×436 px |
| 宽高比 | PASS | 相对误差 0.0473%，阈值 ≤2% |

## 人工视觉 QA（未评定）

| 项目 | PASS/WARN/FAIL（待填） | 理由（待填） |
|---|---|---|
| 画布/宽高比 | PASS | 11×10 in；PNG 2112×1920，与来源 2113×1920 的比例一致（相对误差 0.0473%）。 |
| panel 布局与面板标签 | WARN | 3×3 小多图；基因标题和每个 panel 的 colorbar 保留；panel 比来源略小、行间距偏大（cowplot 布局差异），无 panel 字母。 |
| 颜色/发散方向 | PASS | 青绿→米黄表达渐变，方向与原图一致；无发散色标。 |
| 字体/中文缺字 | PASS | 仅英文基因名；family `sans`（TT Arial），未出现缺字。 |
| 坐标轴/刻度 | PASS | 每个 panel 有 UMAP_1/UMAP_2 短箭头；无数字刻度，与原图一致。 |
| 图例/colorbar | PASS | 每个 panel 独立 colorbar，范围按该基因正值 q05/q98；方向与原图一致。 |
| 数据形状/estimated 不确定项 | WARN | 坐标为合成并横向拉伸 1.8×；表达只模拟“目标类型高、其他类型低”；簇形状/密度与真实数据不同。 |
| 注释 | WARN | 基因名以斜体标题保留；标题与 panel 的垂直间距比来源大。 |
| 导出/矢量文字可编辑 | WARN | PNG/PDF/SVG 已生成；SVG 由 svglite 导出，外部查看器逐字检查未做。 |

作者/签核日期/结论：________

修图以满足检查；不得降低阈值以通过。
