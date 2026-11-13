# QA report

2026-10-22T08:27:08.849436Z

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
| original 可打开 | PASS | PNG 1200×900 px |
| replica 可打开 | PASS | PNG 1600×1200 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×360 px |
| 宽高比 | PASS | 相对误差 0.0000%，阈值 ≤2% |

## 人工视觉 QA（未评定）

| 项目 | PASS/WARN/FAIL（待填） | 理由（待填） |
|---|---|---|
| 画布/宽高比 | PASS | 4:3；源 1200×900，复刻 1600×1200 |
| panel 布局与面板标签 | PASS | 单 ring panel；group 标签、CellType/Percentage 轴标题齐全 |
| 颜色/发散方向 | PASS | G1 浅蓝、S 深蓝、G2M 绿，顺序一致 |
| 字体/中文缺字 | PASS | 纯英文，无缺字 |
| 坐标轴/刻度 | PASS | 0/25/50/75/100 参考标签与组标签刻度一致 |
| 图例/colorbar | PASS | Phase 图例一致 |
| 数据形状/estimated 不确定项 | PASS | 同一 proportions 表，每组和=1；数据为示例元数据精确比例 |
| 注释 | WARN | 小扇区标签（44.4%/21.3%）略重叠；100%/99.3% 间距偏紧 |
| 导出/矢量文字可编辑 | PASS | PNG/PDF/SVG 均生成；cairo PDF + svglite SVG |

注：R 进程在写出 PNG/PDF/SVG 后以 `3221225477`（0xC0000005）退出；输出文件均非空且可打开，属于 Codex shell 的 locale/字体引擎 shutdown 问题，不是绘图失败。机械 QA 两次均 0 failure。

作者/签核日期/结论：待审签；agent 目视仅作对比记录，不等于作者确认。

修图以满足检查；不得降低阈值以通过。
