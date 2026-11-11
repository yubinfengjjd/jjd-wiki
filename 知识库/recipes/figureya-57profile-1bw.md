---
type: recipe
id: figureya-57profile-1bw
title: 多基因组区域信号谱线图
status: draft
source:
  id: figureya
  item: FigureYa57profile_1bw
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa57profile_1bw.Rmd
inputs:
- file: mm9_HCP_tss.bed
  note: mm9_HCP_tss.bed, mm9_ICP_tss.bed, mm9_LCP_tss.bed：用来提取bw信号的指定区域。其中第1、2、3、6列必需。
- file: mm9_ICP_tss.bed
  note: mm9_HCP_tss.bed, mm9_ICP_tss.bed, mm9_LCP_tss.bed：用来提取bw信号的指定区域。其中第1、2、3、6列必需。
- file: mm9_LCP_tss.bed
  note: mm9_HCP_tss.bed, mm9_ICP_tss.bed, mm9_LCP_tss.bed：用来提取bw信号的指定区域。其中第1、2、3、6列必需。
- file: average_signal.txt
  note: ''
outputs: []
packages:
  cran:
  - darkorange
  - mm9_HCP_tss.bed
  - mm9_ICP_tss.bed
  - mm9_LCP_tss.bed
  bioc: []
  github: []
  library: []
  namespaced:
  - knitr
tags:
- multi-omics
keywords:
- bigWig
- BED
- ChIP-seq
- rtracklayer
- TSS
- profile
chart_types:
- trend
summary: 从一个bw文件提取多个bed区域集（如HCP/ICP/LCP启动子）上下游窗口的平均信号，画多条信号分布曲线对比。
favorite: false
---
# 多基因组区域信号谱线图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa57profile_1bw` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa57profile_1bw.Rmd`）
- 依赖：CRAN darkorange, mm9_HCP_tss.bed, mm9_ICP_tss.bed, mm9_LCP_tss.bed
- 最近运行：fail（as-is，2026-11-11 07:52 UTC，1200.4 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

从一个bw文件提取多个bed区域集（如HCP/ICP/LCP启动子）上下游窗口的平均信号，画多条信号分布曲线对比。

## 适用

比较同一样本在多套基因组区域的ChIP/ATAC/DNase信号强度与形状；多样品单区域对比请用FigureYa44profile。

## 不适用

只支持一个bw×多个bed的设计；bed文件第1、2、3、6列必需且labels/colors数量须与bed数一致；依赖corelib.R内rtracklayer函数与awk/paste等Unix工具链，Windows不能直接跑。

## 输入

- `8cell.K4me3.bw`：8cell.K4me3.bw：ChIP/DNase/ATAC-seq的bw文件
- `mm9_HCP_tss.bed`：mm9_HCP_tss.bed, mm9_ICP_tss.bed, mm9_LCP_tss.bed：用来提取bw信号的指定区域。其中第1、2、3、6列必需。
- `mm9_ICP_tss.bed`：mm9_HCP_tss.bed, mm9_ICP_tss.bed, mm9_LCP_tss.bed：用来提取bw信号的指定区域。其中第1、2、3、6列必需。
- `mm9_LCP_tss.bed`：mm9_HCP_tss.bed, mm9_ICP_tss.bed, mm9_LCP_tss.bed：用来提取bw信号的指定区域。其中第1、2、3、6列必需。
- `Mm9HCP_tss.bed`：Mm9HCP_tss.bed, mm9_iCP_tss.bed, mm9_LCP_tss.bed: Used to extract the designated area of the BW signal. The first, second, third, and sixth columns are required.
- `mm9_iCP_tss.bed`：Mm9HCP_tss.bed, mm9_iCP_tss.bed, mm9_LCP_tss.bed: Used to extract the designated area of the BW signal. The first, second, third, and sixth columns are required.
- `average_signal.txt`：见 Rmd“输入文件”节

每个bed文件对应图里一条曲线；span须为resolution的整数倍，sampling_number控制抽样加速。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-57profile-1bw`
- 用到课题：`wiki.py use figureya-57profile-1bw --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：corelib.R需rtracklayer（install_dependencies.R未装，需BiocManager补装）且用mcmapply并行+system调awk/paste，仅类Unix环境可用；信号抽取步骤耗时，建议先用抽样。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig05-trend--trend|分组构成趋势图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
