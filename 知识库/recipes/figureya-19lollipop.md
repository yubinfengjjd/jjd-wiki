---
type: recipe
id: figureya-19lollipop
title: 蛋白结构域突变棒棒糖图
status: draft
source:
  id: figureya
  item: FigureYa19Lollipop
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa19Lollipop.Rmd
inputs:
- file: easy_input.txt
  note: ''
outputs:
- test1.pdf
- test2.pdf
- test3.pdf
- test4.pdf
- test5.pdf
packages:
  cran:
  - RColorBrewer
  - ggplot2
  - grid
  - grDevices
  - trackViewer
  - TCGAbiolinks
  - maftools
  bioc:
  - trackViewer
  - TCGAbiolinks
  - maftools
  github: []
  library:
  - TCGAbiolinks
  - maftools
  - trackViewer
  - RColorBrewer
  namespaced:
  - knitr
tags:
- multi-omics
keywords:
- TCGAbiolinks
- maftools
- trackViewer
- TCGA
- TP53
- 蛋白结构域
- RColorBrewer
chart_types:
- lollipop
summary: 提取目标基因的突变氨基酸位点与maftools内置蛋白结构域注释，用trackViewer画标注突变频率的棒棒糖图。
favorite: false
---
# 蛋白结构域突变棒棒糖图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa19Lollipop` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa19Lollipop.Rmd`）
- 依赖：CRAN RColorBrewer, ggplot2, grid, grDevices, trackViewer, TCGAbiolinks, maftools；Bioconductor trackViewer, TCGAbiolinks, maftools
- 最近运行：fail（as-is，2026-11-11 06:57 UTC，182.0 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

提取目标基因的突变氨基酸位点与maftools内置蛋白结构域注释，用trackViewer画标注突变频率的棒棒糖图。

## 适用

展示基因突变落在哪个功能结构域、位点频次高低，或对比不同癌症/亚型的突变位点分布。

## 不适用

输入必须含RefSeq与HGVSp/HGVSp_Short列，结构域注释仅限maftools内置protein_domains库覆盖的基因；突变点分层着色最多上下两层。

## 输入

- `easy_input.txt`：见 Rmd“输入文件”节

自备输入只需RefSeq、HGVSp、HGVSp_Short三列，MAF其余列非必需。

## 怎么用

- 修补执行副本：`repair/`（保留本轮最小修补与补齐输入；偏离与文件哈希见 `repair.json`，运行收据在 `repair-runs/`）。该副本不是上游原字节；标注的合成输入仅用于执行验证，不构成真实数据结论。预览图：`repair-preview.png`。
- 原样运行（Wiki 专用环境）：`wiki.py run figureya-19lollipop`
- 用到课题：`wiki.py use figureya-19lollipop --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：演示数据用TCGAbiolinks在线查询并下载GDC突变MAF（需联网）；自备easy_input.txt可跳过下载步骤。

## 输出

- `test1.pdf`
- `test2.pdf`
- `test3.pdf`
- `test4.pdf`
- `test5.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
