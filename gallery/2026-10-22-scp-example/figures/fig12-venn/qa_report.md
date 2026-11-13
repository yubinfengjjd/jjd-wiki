# QA report

2026-10-22T14:40:19Z

机械检查只核查文件、像素尺寸与宽高比；不判断视觉像不像，不代表作者签核。

| 自动检查 | 状态 | 证据 |
|---|---|---|
| meta.json | PASS | 文件存在且非空；不等于格式或视觉验收 |
| README.md | PASS | 文件存在且非空；不等于格式或视觉验收 |
| PATCHES.md | PASS | 文件存在且非空；记录 ggVennDiagram 兼容补丁与证明 |
| data/figure_spec.json | PASS | 文件存在且非空；不等于格式或视觉验收 |
| data/render-cell-membership.csv | PASS | 1000 行 × 5 列；cell 唯一 |
| data/venn_intersections.csv | PASS | 15 行交集区域表；count 合计 1000 |
| data/estimated_data.csv | PASS | 与交集表同内容副本；本图数据不是估读 |
| output/replica.png | PASS | 文件存在且非空；1200×900 |
| output/replica.pdf | PASS | 文件存在且非空；约 31.5 KB |
| output/replica.svg | PASS | 文件存在且非空；646 个 `<text>` 元素 |
| compare/side_by_side.png | PASS | 2424×960（source + replica + 标签） |
| compare/overlay.png | PASS | 1200×900，50/50 blend |
| thumb.png | PASS | PNG 480×360 |
| run.log | PASS | 文件存在且非空 |
| 复刻代码 | PASS | code/replica.R |
| 原图存档 | PASS | source/fig12.png |
| original 可打开 | PASS | PNG 1200×900 px |
| replica 可打开 | PASS | PNG 1200×900 px |
| PNG 格式 | PASS | 要求 PNG |
| 宽高比 | PASS | 相对误差 0.0000%，阈值 ≤2% |
| 逐字节同哈希 | PASS | source/replica SHA256 均为 `a5bf19955f2efc74b28c1133945c886cf8f8370ce179fb2582f530c6d96b6119` |
| 表半 identical | PASS | 15 行区域 id/name/item/count/colors/label 与上游中间结果 `identical: TRUE` |
| 模板固定输出同哈希 | PASS | `template` 固定 8×6@150 输出 SHA256 同上 |

## 人工视觉 QA（agent 目视，2026-10-22）

| 项目 | PASS/WARN/FAIL | 理由 |
|---|---|---|
| 画布/宽高比 | PASS | 源图与复刻均为 1200×900 px（8×6 in, 150 dpi）。 |
| panel 布局与面板标签 | PASS | 单逻辑 panel；四个椭圆的维恩图；源图无 A/B 标签，复刻也未添加。 |
| 颜色/发散方向 | PASS | 相同调用 `palette_scp(..., palette="Paired")`：Ductal 浅蓝、Endocrine 深蓝、G1S 浅绿、G2M 深绿；区域为集合并集混合色。 |
| 字体/中文缺字 | PASS | 图中仅拉丁字符、数字与百分号；无缺字。 |
| 坐标轴/刻度 | PASS | 无坐标轴文字（上游 theme 清空 axis text/ticks）；集合标签与区域标签位置逐字节一致。 |
| 图例/colorbar | PASS | venn 分支使用 identity scales，无图例；与源图一致。 |
| 数据形状/estimated 不确定项 | PASS | 数据来自 `pancreas_sub@meta.data` 的 1000 个细胞（精确计数），不是估读；无 estimated 值。 |
| 注释 | PASS | 无标题/副标题；集合标签为 `名称\n(集合大小)`，区域标签为 `count\n百分比`，与上游一致。 |
| 导出/矢量文字可编辑 | PASS | PDF 用 cairo_pdf；SVG 用 svglite，文字为 `<text>` 元素。 |
| 参考 panel 对照 | PASS | 与 `Example-2.jpg` 第 8 格：四椭圆方向、15 个区域计数（512/411/77 与 0）、集合标签与大小一致；参考裁图左侧 `Ductal` 标签被原版面裁切，不做像素级比对。 |

逐字节对比：`source/fig12.png` SHA256 `a5bf19955f2efc74b28c1133945c886cf8f8370ce179fb2582f530c6d96b6119` = `output/replica.png` SHA256 `a5bf19955f2efc74b28c1133945c886cf8f8370ce179fb2582f530c6d96b6119`；PNG 像素 mad = 0、RMS = 0。

保留差异与限制：ggVennDiagram 1.5.7 不再返回 sf 几何，区域/集合边界由包自身坐标重建（见 `PATCHES.md`）；未在 1.2.x 环境做跨版本逐字节对照。仅支持 2–7 个集合、单一 split（单 panel）、拉丁字符标签。

作者/签核日期/结论：agent 代签（沿用作者 2026-10-22 “你代签”授权，记录于工作区 `STATUS.md`），2026-10-22；逐字节、表半与数据核对通过。

修图以满足检查；不得降低阈值以通过。
