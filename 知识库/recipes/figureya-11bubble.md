---
type: recipe
id: figureya-11bubble
title: 富集分析对角排列气泡图
status: ready
source:
  id: figureya
  item: FigureYa11bubble
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa11bubbles.Rmd
inputs:
- file: easy_input.txt
  note: 我们这里都用easy_input.txt文件，实际应用时，替换成你的富集分析结果即可。
outputs:
- dot.pdf
- dot.png
- dot.tiff
- bubbles.pdf
packages:
  cran:
  - cowplot
  - ggplot2
  bioc: []
  github: []
  library:
  - ggplot2
  - cowplot
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- GO
- KEGG
- enrichment bubble
- cowplot
chart_types:
- bubble
- dotplot
summary: 把多组的 GO/KEGG 富集结果画成按对角线排列的气泡图，点大小与颜色表示基因数与显著性。
favorite: false
---
# 富集分析对角排列气泡图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码不进 Git、不推送公开仓库。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa11bubble` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa11bubbles.Rmd`）
- 依赖：CRAN cowplot, ggplot2
- 最近运行：pass（as-is，2026-10-27 12:17 UTC，2.3 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-11bubble/preview.png]]
<!-- facts:end -->

## 用途

把多组的 GO/KEGG 富集结果画成按对角线排列的气泡图，点大小与颜色表示基因数与显著性。

## 适用

已有富集结果表（通路、组别、P 值、基因数或比例）。

## 不适用

还没做富集分析；只有一组结果时对角排列意义不大。

## 输入

- `easy_input.txt`：我们这里都用easy_input.txt文件，实际应用时，替换成你的富集分析结果即可。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-11bubble`
- 用到课题：`wiki.py use figureya-11bubble --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `dot.pdf`
- `dot.png`
- `dot.tiff`
- `bubbles.pdf`

## 知识关联检查

2026-10-27：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot|细胞类型 × 基因气泡点图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
