---
type: interface
slug: render-cell-metadata
title: 细胞级分组元数据表
columns:
  cell:
    type: str
    description: 细胞标识；同一图内唯一
    required: false
  group:
    type: str
    description: 分组或条件；每个细胞一个值；x 轴
  stat:
    type: str
    description: 被统计的类别；每个细胞一个值；堆叠/扇区系列
---
# 细胞级分组元数据表

<!-- facts:start -->
| 列 | 类型 | 必需 | 含义 |
|---|---|---|---|
| cell | str | 可选 | 细胞标识；同一图内唯一 |
| group | str | 必需 | 分组或条件；每个细胞一个值；x 轴 |
| stat | str | 必需 | 被统计的类别；每个细胞一个值；堆叠/扇区系列 |

- 产出方法：无
- 读取方法：无
- 使用的模板：[[templates/2026-10-22-scp-example__fig03-pie--pie|分组构成饼图]] · [[templates/2026-10-22-scp-example__fig04-rose--rose|分组构成玫瑰图]] · [[templates/2026-10-22-scp-example__fig05-trend--trend|分组构成趋势图]] · [[templates/2026-10-22-scp-example__fig06-area--area|分组构成面积图]] · [[templates/2026-10-22-scp-example__fig07-dot--dot|分组构成点图]] · [[templates/2026-10-22-scp-example__fig09-bar--bar|分组计数柱图]]
<!-- facts:end -->

## 含义

这是逐细胞的分类标签表：每个细胞恰好一行，`cell` 是可选唯一键（required:false）；提供时模板会拒绝重复 id，省略时模板只按 `group`/`stat` 计数、无法再做逐细胞去重，因此省略前必须确认每行仍是一个独立细胞。每行只带该细胞的一个 `group` 与一个 `stat`；表内没有数值列，同一份表可驱动 bar/pie/rose/trend/area/dot 六种组成编码。计数和组内比例不是上游给定，而是模板内部按原 StatPlot 的 xtabs 步骤从行数计算：count 等于每个 group×stat 的行数，percent 在内部是 0–1（Freq/该组总行数）、显示时转成百分比，饼图按 group 分环、各环各自归一到 1，因此得不到全表口径的比例；`stat_type` 由 style 指定（示例里 pie/area/dot 用 percent，rose/trend 用 count），`group`/`stat` 的 NA 不当作真实类别；当前 SCP 适配函数与模板的 levels 检查会在计数前拒绝 NA，不能靠 `NA_stat` 保留 NA 水平（模板页如写可保留，应以代码为准并修正）。最容易出错的前提是同一细胞出现在多行——cell×condition 长表，或把多个 stat 列并排展开，都会把对应格子的计数成倍放大，`render.R` 在数据含 `cell` 列时会因重复 id 直接报错；group/stat 的默认顺序是输入中的出现次序（不是数值或时间排序），显式给的 `group_levels`/`celltype_levels` 漏掉任一观察值都会报错，所以按发育/时间排序必须显式给 levels。与 `render-cell-proportions` 的关键区别是聚合责任：那个接口存的是已按组归一化到 1 的 group×celltype×proportion（上游给定、模板不重算），供 ring 与 stacked-bar-flow 读取；只有逐细胞元数据、要画 bar/pie/rose/trend/area/dot 时用本接口，已有比例表或要画 ring 时用前者。还要与 `render-dotplot-long` 区分：后者是基因×细胞类型的表达点图，`avg_expression` 与 0–100 的 `pct_expressed` 由上游算好，不是这里的组成点图。

<!-- user:start -->
<!-- user:end -->
