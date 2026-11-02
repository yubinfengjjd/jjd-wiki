# QA report

2026-10-22T18:30:00.000000Z

机械检查只核查文件、像素尺寸与宽高比；不判断视觉像不像，不代表作者签核。

| 自动检查 | 状态 | 证据 |
|---|---|---|
| meta.json | PASS | 文件存在且非空；不等于格式或视觉验收 |
| README.md | PASS | 文件存在且非空；不等于格式或视觉验收 |
| PATCHES.md | PASS | 文件存在且非空；记录兼容补丁 |
| data/figure_spec.json | PASS | 文件存在且非空；不等于格式或视觉验收 |
| data/estimated_data.csv | PASS | 文件存在且非空；本图不是估读数据，见 README |
| data/render-cell-membership.csv | PASS | 4000 行 = 1000 cells × 4 sets；集合顺序 Ductal / Endocrine / G1S / G2M |
| data/upset-intersection-counts.csv | PASS | 3 个交集，合计 1000 个细胞 |
| output/replica.png | PASS | 文件存在且非空；1200×900 |
| output/replica.pdf | PASS | 文件存在且非空；cairo_pdf 内嵌创建时间戳，PDF 哈希随运行变化（本次 `09d8d080fad4e4bcd4e0269d85edb028d7f65b41722c7cfb11aba24f45496c25`），不作逐字节依据 |
| output/replica.svg | PASS | 文件存在且非空；SHA256 `c90a1ad4079fd7bb0639031af874b2a976466cfce47cd8270ca34c963f102ea7` |
| compare/side_by_side.png | PASS | 文件存在且非空 |
| compare/overlay.png | PASS | 文件存在且非空 |
| thumb.png | PASS | PNG 480×360 px |
| run.log | PASS | 文件存在且非空 |
| 复刻代码 | PASS | code/replica.R 转调 code/render.R |
| 原图存档 | PASS | source/fig13.png |
| original 可打开 | PASS | PNG 1200×900 px |
| replica 可打开 | PASS | PNG 1200×900 px |
| PNG 格式 | PASS | 要求 PNG |
| thumbnail 可打开 | PASS | PNG 480×360 px |
| 宽高比 | PASS | 相对误差 0.0000%，阈值 ≤2% |
| 逐字节对比 | PASS | source SHA256 `b2f0322dfa77068b0e7d5aacd72475b0a8b6ab084ca0ae0b27fe7e3f8a71190a` = replica SHA256 `b2f0322dfa77068b0e7d5aacd72475b0a8b6ab084ca0ae0b27fe7e3f8a71190a` |

## 人工视觉 QA（agent 目视，2026-10-22）

| 项目 | PASS/WARN/FAIL | 理由 |
|---|---|---|
| 画布/宽高比 | PASS | 源图与复刻均为 1200×900 px（8×6 in, 150 dpi）。 |
| panel 布局与面板标签 | PASS | 单逻辑 panel；上为交集大小柱、下为 Ductal/Endocrine/G1S/G2M 的 combmatrix；源图无 A/B 标签，复刻也未添加。 |
| 颜色/发散方向 | PASS | 与源图相同 `scale_fill_gradientn(colors = palette_scp(palette = "material-indigo"))`；柱色 512 = #1A237E、411 = #303FA0、77 = #E8EAF6，逐字节一致。 |
| 字体/中文缺字 | PASS | 图中仅拉丁字符；无缺字。 |
| 坐标轴/刻度 | PASS | y 轴标题 `Intersection size`、刻度 0/100–500 与源图一致；x 轴标签为空（上游 split 水平为 ""）。 |
| 图例/colorbar | PASS | 上游 `show.legend = FALSE`，无图例；复刻相同。 |
| 数据形状/estimated 不确定项 | PASS | 1000 个细胞的精确成员关系，不是估读；交集 512/411/77 与 `scp_upset_counts()`、`ggplot_build()` 计数一致。 |
| 注释 | PASS | 无标题/副标题；源图与复刻均无。 |
| 导出/矢量文字可编辑 | PASS | PDF 用 cairo_pdf；SVG 用 svglite，文字为 `<text>` 元素。 |

逐字节对比：`source/fig13.png` SHA256 `b2f0322dfa77068b0e7d5aacd72475b0a8b6ab084ca0ae0b27fe7e3f8a71190a` = `output/replica.png` SHA256 `b2f0322dfa77068b0e7d5aacd72475b0a8b6ab084ca0ae0b27fe7e3f8a71190a`；像素差异 bbox = None，改变像素 = 0，最大通道差 = 0。

参考 panel：Example-2.jpg 第 7 格（bbox [950, 330, 1400, 680]），柱值 512/411/77 与本图一致；参考裁图左侧带少量相邻 panel 图例残影，仅作溯源。

保留差异与限制：无额外裁切；上游固定 `aspect.ratio = 0.6` 与 combmatrix 字号 12/间距 6 原样保留。未验证中文标签、超过 20 个交集时的上游截断显示、以及非二值成员输入（接口只接受 0/1）。

作者/签核日期/结论：agent 代签（作者 2026-10-22 授权“沿用代签”），2026-10-22；逐字节、表格与数据核对通过。

修图以满足检查；不得降低阈值以通过。
