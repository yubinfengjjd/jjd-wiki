# 兼容补丁（PATCHES）

上游：SCP v0.5.6，`R/SCP-plot.R`，commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`，GPL (>= 3)。
复用副本：`code/scp_upset_native.R`。原始只读摘录：`original_code/cellstat.R`。

所有补丁只改函数来源与命名空间，不改统计、数据与图层几何。默认参数下的 PNG 与上游调用逐字节一致
（SHA256 `b2f0322d…8a71190a`，像素差 0），并单独记录了表半 `identical()` 证明。

## P1. `check_R()` → `requireNamespace()`

- 上游行：5045
  ```r
  check_R("ggupset")
  ```
- 原因：`check_R()`（`R/utils.R`）在缺包时会尝试 BiocManager/install.packages/devtools 安装并加载依赖；模板不得安装包，也不应依赖 SCP 的包加载器。
- 替换：`code/scp_upset_native.R` 的 `plot_scp_upset()`
  ```r
  if (!requireNamespace("ggupset", quietly = TRUE)) {
    stop("Package 'ggupset' is required for plot_type = 'upset'.", call. = FALSE)
  }
  ```
- 几何/数据不变证明：`ggupset` 0.4.1 已安装，两版都直接调用 `ggupset::scale_x_upset()` 与 `ggupset::theme_combmatrix()`；固定 8×6@150 输出的 SHA256 与上游相同（`b2f0322d…`），像素差 0。

## P2. 表半拆出：`intersection` 构造与过滤移入 `scp_upset_table()`

- 上游行：5046–5049
  ```r
  for (n in seq_len(nrow(dat_use))) {
    dat_use[["intersection"]][n] <- list(stat.by[unlist(dat_use[n, stat.by])])
  }
  dat_use <- dat_use[sapply(dat_use[["intersection"]], length) > 0, , drop = FALSE]
  ```
- 原因：函数化要求表半/绘图半分离；绘图半只消费已构造好的数据框。
- 替换：同一段代码原样放在 `scp_upset_table()` 内，`plot_scp_upset()` 从 5050 行的 `p <- ggplot(...)` 开始。
- 几何/数据不变证明：`identical(scp_upset_table(wide, sets), ggplot2::ggplot_build 前上游 plot$data)` 为 `TRUE`（1000 行 × 6 列，含 `Ductal/Endocrine/G1S/G2M` logical 列、`All.groups` 单水平 factor、`intersection` list 列与 cell 行名）。计数表 `512/411/77` 与 `ggplot_build()` 的柱高一致。

## P3. 硬编码填色 `"material-indigo"` → `fill_palette` 参数

- 上游行：5061
  ```r
  scale_fill_gradientn(colors = palette_scp(palette = "material-indigo")) +
  ```
- 原因：`CellStatPlot(palette = ...)` 在 upset 分支不参与填色，上游把渐变调色板写死；模板需要一个显式、可覆盖的参数。
- 替换：
  ```r
  scale_fill_gradientn(colors = palette_scp(palette = fill_palette)) +
  ```
  `fill_palette = "material-indigo"` 为默认值。
- 几何/数据不变证明：默认值与原字符串相同，模板固定模式输出与 source 同哈希。

## P4. `alpha` 参数接到柱层

- 上游行：5051
  ```r
  geom_bar(aes(fill = after_stat(count)), color = "black", width = 0.5, show.legend = FALSE) +
  ```
- 原因：`CellStatPlot(alpha = 1)` 在 upset 分支被接受但不使用；模板按 spec.style 暴露 `alpha`。
- 替换：
  ```r
  geom_bar(aes(fill = after_stat(count)), color = "black", width = 0.5, alpha = alpha, show.legend = show.legend) +
  ```
- 几何/数据不变证明：`alpha = 1`、`show.legend = FALSE`（默认）时输出 SHA256 与上游一致；专门实验 `alpha = 1` 与不写 alpha 的 PNG 哈希相同（`b2f0322d…`）。

## P5. `show.legend` 参数接到柱层

- 上游行：5051 的 `show.legend = FALSE`。
- 原因：spec.style 记录图例开关；上游抑制了 count 填充图例。
- 替换：`show.legend = show.legend`，默认 `FALSE`。
- 几何/数据不变证明：默认 `FALSE` 与原值相同；逐字节一致。

## P6. 本地 helpers 替代 SCP 包函数

- 上游行：5061 的 `palette_scp()`、5062–5065 的 `theme_scp()`，以及 4961 的 `palette_scp(stat.by, ...)`（upset 分支未使用）。
- 原因：模板不能依赖已安装的 SCP 包。
- 替换：`code/scp_helpers.R` 中 `theme_scp()` 与 `palette_scp()` 的函数体逐行复制；唯一改动是 `palette_scp()` 从本地 `code/data/palette_list.rda` 读取 `palette_list`，而不是 `SCP::palette_list`。`palette_list.rda` 与上游 `data/palette_list.rda` 同哈希（`4ab688fd…`）。
- 几何/数据不变证明：`theme_scp` 与 `SCP-plot.R` 16–66 行一致；固定输出的 `theme` 对象、`aes` 与图层类相同；PNG 逐字节一致。

## P7. 命名空间限定

- 上游 SCP 函数通过 `@importFrom` 与包命名空间解析 `ggplot`、`geom_bar`、`geom_text_repel`、`labs`、`scale_fill_gradientn`、`after_stat`、`element_line`、`element_text`。
- 替换：`code/core.R` 显式 `library(ggplot2)`、`library(ggrepel)`、`library(rlang)`、`library(dplyr)`；`ggupset::` 前缀与上游一致。
- 几何/数据不变证明：同名函数、同版本（ggplot2 3.5.2、ggrepel 0.9.6）；输出逐字节一致。

## 未改动的上游常量

以下值原样保留，模板不参数化：`aspect.ratio = 0.6`、`combmatrix.label.text = element_text(size = 12, color = "black")`、`combmatrix.label.extra_spacing = 6`、`n_intersections = 20`、`width = 0.5`、`y = "Intersection size"`、`x = sp`（默认 split 水平为空字符串）。
