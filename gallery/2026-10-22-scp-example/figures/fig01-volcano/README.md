# 2026-10-22-scp-example__fig01-volcano

SCP v0.5.6 原生 `VolcanoPlot()` 单 panel 样张，使用 `pancreas_sub` 示例数据。版本 2 为原生重做；v1（自定义 ggplot 重写）保存在 `history/20261022T092250265933Z/`，未沿用旧签核。

## 来源

- 仓库：<https://github.com/zhanghao-njmu/scp>
- commit：`b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`（SCP 0.5.6）
- 原文件：`R/SCP-plot.R` 的 `VolcanoPlot()`（7088–7194 行）
- 许可证：GPL (>= 3)；原文件 SHA256 `03a0b55f...caca3a02`
- 原图：`source/fig01.png`，SHA256 `2b22c692...12308dd`

原图就是未修改的 `VolcanoPlot()` 在 7×6 in、200 dpi、`set.seed(1)` 下的输出；本条目复刻 PNG 与它**逐字节相同**（同一 SHA256）。

## 范围与数据

单逻辑 panel：`Endocrine` 对其余细胞的火山图。SCP `VolcanoPlot()` 会按 `group1` 分面；这里只保留一个 facet，未存多组图。

- x：`diff_pct = pct.1 - pct.2`
- y：带符号的 `-log10(p_val_adj)`；负 log2FC 侧取负值，轴标签用 `abs`（SCP 原设计）
- 颜色：`avg_log2FC`，`RdBu` 渐变
- 高亮点：`avg_log2FC > 0 & p_val_adj < 0.05`（SCP 默认阈值）
- 标签：上下各 8 个距离最大的基因（`nlabel = 8`）

`data/de_endocrine_vs_rest.csv` 有 7343 行。DE 表由 Seurat 5.6.0
`FindMarkers(ident.1 = "Endocrine", only.pos = FALSE, logfc.threshold = 0, min.pct = 0.1)`
对 `pancreas_sub` 计算一次，**不是 SCP `RunDEtest()` 的输出**；SCP 0.5.6 的
`RunDEtest()` 在 SeuratObject 5.6 下仍使用已废弃的 `slot` / `Assays(object, assay)`
接口，未在本轮修复。因此本图验证的是**原生绘图函数**，不是原生 DE 统计。
`data/estimated_data.csv` 是 QA 工具要求的同内容副本；数据不是估读值。

## 代码结构

- `original_code/volcano.R`：上游 `VolcanoPlot()` 只读摘录；`provenance.json` 记录完整文件哈希和行号。
- `code/scp_volcano_native.R`：
  - `scp_volcano_table()`：只做 `VolcanoPlot()` 内部的数据准备——`diff_pct`、`-log10padj`、DE 标记、1%/99% 分位截断、带符号 y、排序、distance。
  - `plot_scp_volcano()`：逐行保留上游 ggplot 构造（6 个点层、阈值线、`geom_text_repel`、色标、facet、`theme_scp`）。
  - `scp_volcano_meta()`：从 `srt@tools[[DEtest_<group_by>]]` 读取 `AllMarkers_<test.use>` 的便捷入口。
- `code/render.R`：读 CSV → `scp_volcano_table()` → `set.seed(1)` → `plot_scp_volcano()` → PNG/PDF/SVG。
- `code/replica.R`：画廊标准入口，转调 `render.R`。

SCP-local 加载器：`E:/research-wiki/知识库/methods/scp-local-source/code/SCP-local`，可用 `SCP_LOCAL_ROOT` 覆盖。

## 运行

```powershell
cd E:/research-wiki/画廊/2026-10-22-scp-example/figures/fig01-volcano
Rscript --vanilla code/replica.R
```

隔离环境变量见 `run.log`。`code/replica.R` 从条目录和外目录运行均 exit 0。

## 产物

- `output/replica.png`：1400×1200，SHA256 与 source 相同
- `output/replica.pdf`、`output/replica.svg`
- `compare/side_by_side.png`、`compare/overlay.png`
- `qa_report.md`：机械检查 + agent 目视记录

## 验证

- 像素：源图与复刻 PNG **0 差异**（mean 0，RMS 0，bbox `None`），SHA256 相同。
- 图层：相同 DE 表下，原 `VolcanoPlot()` 与函数化路径的 9 个 built layers 的 `x`/`y` 全部相等。
- 规模/结构：3 组不同样本量、逆序 group 水平、`combine=FALSE` 每组图层点数相等；任意分组列名可生成 facet；`x_metric="avg_log2FC"` 图层相等；自定义 DE 阈值计数正确。
- 输入不被修改；缺列、非法阈值、非表输入均报错。
- 契约测试 37 PASS / 0 FAIL，日志 `logs/test_volcano_contract.log`。

## 保留差异与限制

- DE 统计不是 SCP `RunDEtest()`；p 值与 log2FC 不可与 SCP 原生 DE 结果逐值比较。
- `VolcanoPlot()` 本身不设随机种子；标签布局依赖调用前 RNG。`render.R` 固定 `set.seed(1)` 才得到源图布局。
- 标签/点重叠布局依赖 `ggrepel` 和 ggplot2 版本；本机 ggplot2 3.5.2、ggrepel 版本见 `output/sessionInfo.txt`。
- 多组 DE 表会生成多 facet；按 Wiki 单 panel 规则，本条目只保存一个 facet，未验证多 facet 的排版美观性，只验证了图层结构。
- 字体仅拉丁字符；未验证中文标签。

## 状态

`draft`（v2）。机械检查全 PASS；像素与图层验证完成；作者签核未进行。
