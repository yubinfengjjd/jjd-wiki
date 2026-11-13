---
type: recipe
id: figureya-43manhattanv2
title: 带基因标注的曼哈顿图
status: ready
source:
  id: figureya
  item: FigureYa43ManhattanV2
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa43ManhattanV2.Rmd
inputs:
- file: easy_input.csv
  note: easy_input.csv，包括染色体名字、SNP编号、在染色体上的位置（第几个碱基）、pvalue、类型type、基因名gene。
- file: Karyotype.txt
  note: Karyotype.txt，如果你自己提供染色体长度文件，就运行下面这段
outputs:
- Manhattan.pdf
packages:
  cran:
  - dplyr
  - ggplot2
  - ggrepel
  bioc: []
  github: []
  library:
  - dplyr
  - ggplot2
  - ggrepel
  namespaced:
  - knitr
tags:
- other
keywords:
- ggrepel
- GWAS
- Manhattan
chart_types:
- manhattan
summary: 用ggplot2画GWAS曼哈顿图：染色体分色、type分形、超阈值点加大，并用ggrepel给显著位点加带箭头或边框的基因标签。
favorite: false
---
# 带基因标注的曼哈顿图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa43ManhattanV2` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa43ManhattanV2.Rmd`）
- 依赖：CRAN dplyr, ggplot2, ggrepel
- 最近运行：pass（as-is，2026-11-04 11:14 UTC，27.7 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-43manhattanv2/preview.png]]
<!-- facts:end -->

## 用途

用ggplot2画GWAS曼哈顿图：染色体分色、type分形、超阈值点加大，并用ggrepel给显著位点加带箭头或边框的基因标签。

## 适用

展示全基因组SNP关联p值沿染色体的分布并突出显著位点，常作外显子组/GWAS文章首图。

## 不适用

输入需含CHR/SNP/POS/P_value列，type与gene可选；染色体水平写死1-18加X/Y；不给染色体长度文件时用SNP最大位置近似；只处理单套p值。

## 输入

- `easy_input.csv`：easy_input.csv，包括染色体名字、SNP编号、在染色体上的位置（第几个碱基）、pvalue、类型type、基因名gene。
- `Karyotype.txt`：Karyotype.txt，如果你自己提供染色体长度文件，就运行下面这段

可选Karyotype.txt提供真实染色体长度；easy_input.csv列结构固定。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-43manhattanv2`
- 用到课题：`wiki.py use figureya-43manhattanv2 --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `Manhattan.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
