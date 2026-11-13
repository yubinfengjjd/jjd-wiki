---
type: recipe
id: figureya-44profile
title: 基因组区域平均信号曲线
status: ready
source:
  id: figureya
  item: FigureYa44profile
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa44profile.Rmd
inputs:
- file: easy_input.txt
  note: easy_input.txt：想要查看的基因的位置信息，至少包含4列：染色体、正负链、起始位点、终止位点。作者用的是refGene里所有经过验证的编码RNA（NM开头），此处考虑到运行时间，从中随机抽取5000个基因。
- file: cxxc1.bw
  note: cxxc1.bw和control.bw：ChIP-seq样品及其contorl的bw文件。在生成bw时做过normalization。
- file: control.bw
  note: cxxc1.bw和control.bw：ChIP-seq样品及其contorl的bw文件。在生成bw时做过normalization。
- file: zv9_CpG_islands.bed
  note: zv9_CpG_islands.bed：想要查看的基因/功能区域的bed文件，此处是15000个CpGi。
- file: gene_average_signal.txt
  note: ''
- file: site_average_signal.txt
  note: ''
outputs: []
packages:
  cran:
  - Cxxc1
  - Input
  - control.bw
  - cxxc1.bw
  - firebrick
  bioc:
  - rtracklayer
  github: []
  library: []
  namespaced:
  - knitr
tags:
- other
keywords:
- rtracklayer
- bigWig
- ChIP-seq
- corelib.R
chart_types:
- trend
summary: 从bigWig提取信号，画两类profile：基因体统一缩放+TSS/TTS两侧flank的平均信号曲线，以及指定bed区域（如CpGi）中心两侧的信号曲线，支
favorite: false
---
# 基因组区域平均信号曲线

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa44profile` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa44profile.Rmd`）
- 依赖：CRAN Cxxc1, Input, control.bw, cxxc1.bw, firebrick；Bioconductor rtracklayer
- 最近运行：pass（as-is，2026-11-04 11:14 UTC，19.3 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-44profile/preview.png]]
<!-- facts:end -->

## 用途

从bigWig提取信号，画两类profile：基因体统一缩放+TSS/TTS两侧flank的平均信号曲线，以及指定bed区域（如CpGi）中心两侧的信号曲线，支持多个bw样品叠加对比。

## 适用

比较ChIP-seq/ATAC-seq/DNase-seq样品与input对照在基因体或功能区域上的信号分布。

## 不适用

输入须为已归一化的bw文件+基因坐标表（≥4列）或bed区域文件；信号提取函数在本地corelib.R且Rmd中该段不是执行块，需手动跑且较慢；只画均值曲线不画单区域热图；resolution与span需整数倍。

## 输入

- `cxxc1.bw和control.bw`：cxxc1.bw和control.bw：ChIP-seq样品及其contorl的bw文件。在生成bw时做过normalization。
- `easy_input.txt`：easy_input.txt：想要查看的基因的位置信息，至少包含4列：染色体、正负链、起始位点、终止位点。作者用的是refGene里所有经过验证的编码RNA（NM开头），此处考虑到运行时间，从中随机抽取5000个基因。
- `cxxc1.bw`：cxxc1.bw和control.bw：ChIP-seq样品及其contorl的bw文件。在生成bw时做过normalization。
- `control.bw`：cxxc1.bw和control.bw：ChIP-seq样品及其contorl的bw文件。在生成bw时做过normalization。
- `zv9_CpG_islands.bed`：zv9_CpG_islands.bed：想要查看的基因/功能区域的bed文件，此处是15000个CpGi。
- `gene_average_signal.txt`：见 Rmd“输入文件”节
- `site_average_signal.txt`：见 Rmd“输入文件”节

easy_input.txt至少含染色体/链/起点/终点4列；区域图输入为bed文件；bw文件生成时须已做测序深度归一化。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-44profile`
- 用到课题：`wiki.py use figureya-44profile --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：信号提取逐bw扫描数千基因/区域，单个约10分钟（detectCores()-1并行）；重建easy_input.txt需先下载UCSC refGene.gz。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig05-trend--trend|分组构成趋势图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
