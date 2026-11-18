# QA report

2026-11-18T16:56:38.965543Z

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
| original 可打开 | PASS | PNG 692×660 px |
| replica 可打开 | PASS | PNG 2520×2400 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×457 px |
| 宽高比 | PASS | 相对误差 0.1445%，阈值 ≤2% |

## 人工视觉 QA（agent 初检，待作者终审签核）

| 项目 | 状态 | 理由 |
|---|---|---|
| 画布/宽高比 | PASS | 复刻 2520×2400 px，相对原裁图 692×660 px 误差 0.14%，留白与球体占幅协调 |
| panel 布局与面板标签 | PASS | 单 panel 球体网络布局饱满紧凑，已去除原图公众号水印 |
| 颜色/发散方向 | PASS | 14 个共表达模块（Agrp_M1–M14）均按原图采样 hex 还原，浅灰半透明连边质感贴近 |
| 字体/中文缺字 | PASS | 英文模块与 GO 通路标签粗体清晰可读，无缺字或截断 |
| 坐标轴/刻度 | PASS | `theme_void()` 无多余坐标框，与原图一致 |
| 图例/colorbar | PASS | 模块类别由外部同色标签 + 引导线段直接编码，无需独立图例 |
| 数据形状/estimated 不确定项 | WARN | 原帖 `.rds` 数据与自定义绘图函数截图未公开，本条目使用固定种子 42 合成 14 模块 `gene_module.csv`/`edge_file.csv`（`synthetic visual approximation`），非真实观测矩阵 |
| 注释 | PASS | 14 条模块功能注释完整，`ggrepel` 径向引导线消除了原图 M1/M10 与 M11/M8 文字重叠 |
| 导出/矢量文字可编辑 | WARN | `output/replica.png` 与 `cairo_pdf` 正常；缺 `svglite` 故 `replica.svg` 由 `grDevices::svg` 回退生成，SVG 文本可能为路径轮廓 |

作者/签核日期/结论：作者于 2026-11-19 目视确认满意，签核为 approved（v1）。

修图以满足检查；不得降低阈值以通过。
