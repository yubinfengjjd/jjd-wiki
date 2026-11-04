---
type: recipe
id: figureya-74omiccircos
title: 基因组环状热图连线图
status: draft
source:
  id: figureya
  item: FigureYa74OmicCircos
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa74OmicCircos.Rmd
inputs:
- file: gene.location.csv
  note: gene.location.csv，基因在染色体上的位置。至少包括基因所在的染色体、起始位置、基因 ID（例如ensembl ID、ENTREZ ID、gene
    symbol）。此处以人为例，对应hg19版本，来自TCGAbiolinks。
- file: signal.csv
  note: signal.csv，图中基因的信号值。第一列是gene ID，跟gene.location.csv里的一种基因ID一致，此处是gene symbol；第二列是图中基因名及其连线的颜色，红色连红色，蓝色连蓝色，你也可以写成其他颜色；第三列之后是三组样品的signal，第一组有两个，第二组有三个，第三组有三个。可以是RNA-seq、ChIP-seq、ATAC-seq、CNV、DNA甲基化等信息。用感
- file: easy_input.csv
  note: 如果你的数据已经保存为easy_input.csv格式，就可以跳过这步，进入“开始画图”
- file: hg19.chrom.sizes.txt
  note: ''
outputs:
- OmicCircos.pdf
- OmicCircos_plus.pdf
packages:
  cran:
  - tidyverse
  bioc:
  - OmicCircos
  - S4Vectors
  github: []
  library:
  - S4Vectors
  - tidyverse
  - OmicCircos
  namespaced:
  - knitr
tags:
- transcriptomics
- multi-omics
keywords:
- OmicCircos
- hg19
- S4Vectors
- tidyverse
chart_types:
- circos
summary: 用OmicCircos在环形染色体图上叠加多组样本信号热图轨道，并按颜色绘制基因间连线（同色互连）。
favorite: false
---
# 基因组环状热图连线图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa74OmicCircos` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa74OmicCircos.Rmd`）
- 依赖：CRAN tidyverse；Bioconductor OmicCircos, S4Vectors
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用OmicCircos在环形染色体图上叠加多组样本信号热图轨道，并按颜色绘制基因间连线（同色互连）。

## 适用

展示一组基因/区段在基因组上的多组信号（表达、CNV、甲基化等）及互相关联。

## 不适用

仅支持内置hg18/hg19/mm9/mm10核型；signal.csv分组列顺序写死在代码里需按数据改列号；染色体名和样本标注常需Illustrator后修。

## 输入

- `gene.location.csv`：gene.location.csv，基因在染色体上的位置。至少包括基因所在的染色体、起始位置、基因 ID（例如ensembl ID、ENTREZ ID、gene symbol）。此处以人为例，对应hg19版本，来自TCGAbiolinks。
- `signal.csv`：signal.csv，图中基因的信号值。第一列是gene ID，跟gene.location.csv里的一种基因ID一致，此处是gene symbol；第二列是图中基因名及其连线的颜色，红色连红色，蓝色连蓝色，你也可以写成其他颜色；第三列之后是三组样品的signal，第一组有两个，第二组有三个，第三组有三个。可以是RNA-seq、ChIP-seq、ATAC-seq、CNV、DNA甲基化等信息。用感
- `easy_input.csv`：如果你的数据已经保存为easy_input.csv格式，就可以跳过这步，进入“开始画图”
- `hg19.chrom.sizes.txt`：见 Rmd“输入文件”节

signal.csv第1列gene ID（须与gene.location.csv中ID一致）、第2列连线颜色、其后为按组排列的信号列；各组列数可不同。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-74omiccircos`
- 用到课题：`wiki.py use figureya-74omiccircos --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `OmicCircos.pdf`
- `OmicCircos_plus.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
