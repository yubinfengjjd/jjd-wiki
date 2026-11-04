---
type: recipe
id: figureya-5bubbles
title: 富集与表达气泡图
status: draft
source:
  id: figureya
  item: FigureYa5bubbles
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa5bubbles.Rmd
inputs:
- file: easy_input.txt
  note: 第一种：把自己的数据整理成easy_input.txt的格式，就可以跳过“输入数据的格式化”，直接进入“开始画图”。第一列是基因名，后面几列依次是各个sample里motif的pvalue，然后是motif的名字，后面是FPKM值。
- file: knownResults.txt
  note: 第二种：motif的pvalue，用homer找motif，产生knownResults.txt，其中包含了在peak（目标基因组区域）中富集的已知motif。一共10个sample，分别保存在10个文件夹里。
- file: GSE66582_stage_FPKM.txt
  note: ''
outputs:
- filtered_motifs.pdf
- filtered_genes.pdf
- paper_motifs.pdf
- paper_gene.pdf
packages:
  cran:
  - data.table
  - ggplot2
  - reshape2
  bioc: []
  github: []
  library:
  - data.table
  - ggplot2
  - reshape2
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- HOMER
- knownResults
- motif
- FPKM
- ggplot2
- reshape2
- data.table
chart_types:
- bubble
summary: 气泡图同时编码motif/通路富集的-logP（点大小）与对应基因表达量（填充色），跨样本对比展示。
favorite: false
---
# 富集与表达气泡图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa5bubbles` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa5bubbles.Rmd`）
- 依赖：CRAN data.table, ggplot2, reshape2
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

气泡图同时编码motif/通路富集的-logP（点大小）与对应基因表达量（填充色），跨样本对比展示。

## 适用

展示各样本中富集且高表达的转录因子，或富集通路的qvalue与基因数/geneRatio。

## 不适用

示例路径依赖Homer输出的knownResults.txt（每样本一份）+FPKM表，须统一基因名大小写；列结构固定，整理成easy_input.txt才能直接画。

## 输入

- `产生knownResults.txt`：第二种：motif的pvalue，用homer找motif，产生knownResults.txt，其中包含了在peak（目标基因组区域）中富集的已知motif。一共10个sample，分别保存在10个文件夹里。
- `easy_input.txt`：第一种：把自己的数据整理成easy_input.txt的格式，就可以跳过“输入数据的格式化”，直接进入“开始画图”。第一列是基因名，后面几列依次是各个sample里motif的pvalue，然后是motif的名字，后面是FPKM值。
- `knownResults.txt`：第二种：motif的pvalue，用homer找motif，产生knownResults.txt，其中包含了在peak（目标基因组区域）中富集的已知motif。一共10个sample，分别保存在10个文件夹里。
- `GSE66582_stage_FPKM.txt`：见 Rmd“输入文件”节

easy_input.txt列序固定：第1列gene、各样本pvalue列、motif名列、各样本FPKM列。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-5bubbles`
- 用到课题：`wiki.py use figureya-5bubbles --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：从原始数据起步需Homer motif结果及终端wget下载GEO FPKM文件；提供easy_input.txt可跳过。

## 输出

- `filtered_motifs.pdf`
- `filtered_genes.pdf`
- `paper_motifs.pdf`
- `paper_gene.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
