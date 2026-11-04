---
type: recipe
id: figureya-113mutsigcv
title: MutSigCV显著突变基因瀑布图
status: draft
source:
  id: figureya
  item: FigureYa113MutSigCV
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa113MutSigCV.Rmd
inputs:
- file: easy_input_meta.local mutation.full.txt
  note: easy_input_meta.local mutation.full.txt，MAF文件，用于推断SVG。从TCGA下载MAF文件的方法可参考FigureYa19Lollipop。
- file: easy_input_meta.mut.txt
  note: ''
- file: easy_input_local.mut.txt
  note: ''
- file: meta.local mutation.full_MutSig_output.sig_genes.txt
  note: ''
outputs:
- oncoprint_mutsigcv_detailed_variationtype.pdf
packages:
  cran:
  - RColorBrewer
  - forcats
  - magrittr
  - readxl
  - stringr
  - tidyverse
  bioc:
  - ComplexHeatmap
  github: []
  library:
  - tidyverse
  - magrittr
  - readxl
  - stringr
  - forcats
  - ComplexHeatmap
  - RColorBrewer
  namespaced:
  - knitr
tags:
- multi-omics
keywords:
- MutSigCV
- MATLAB
- MAF
- SMG
- ComplexHeatmap
- TCGA
- RColorBrewer
- forcats
- magrittr
- readxl
- stringr
- tidyverse
chart_types:
- oncoprint
summary: 在R里把MAF整理成MutSigCV输入格式，调用MATLAB版MutSigCV推断显著突变基因（q<0.05），再用ComplexHeatmap画分组的突变类
favorite: false
---
# MutSigCV显著突变基因瀑布图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa113MutSigCV` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa113MutSigCV.Rmd`）
- 依赖：CRAN RColorBrewer, forcats, magrittr, readxl, stringr, tidyverse；Bioconductor ComplexHeatmap
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

在R里把MAF整理成MutSigCV输入格式，调用MATLAB版MutSigCV推断显著突变基因（q<0.05），再用ComplexHeatmap画分组的突变类型瀑布图。

## 适用

画基因突变瀑布图时想只展示统计显著的驱动突变基因，或需对比两组（如原发/转移）样本的SMG分布。

## 不适用

依赖外部MATLAB环境运行MutSigCV.m及Broad参考文件；MAF列结构、Variant_Classification命名必须与突变字典严格一致，无沉默突变或沉默突变过少时算法无法运行。

## 输入

- `mutation.full.txt`：easy_input_meta.local mutation.full.txt，MAF文件，用于推断SVG。从TCGA下载MAF文件的方法可参考FigureYa19Lollipop。
- `meta.mut.rda和local.mut.rda`：meta.mut.rda和local.mut.rda，用于画图时展示两组，非必需。里面分别保存了两组样品名称（字符串）。此处只是为了重现原图，实际使用时请选用自己不同亚型的样本。
- `Meta.mut.rda`：Meta.mut.rda and local.mut.rda are used to display two sets during drawing and are not mandatory. There are two sets of sample names (strings) saved inside. This is only for reproducing the original i
- `local.mut.rda`：meta.mut.rda和local.mut.rda，用于画图时展示两组，非必需。里面分别保存了两组样品名称（字符串）。此处只是为了重现原图，实际使用时请选用自己不同亚型的样本。
- `mutation.full_for_MutSig_input.txt`：把MAF文件整理成MutSigCV所需的输入文件的格式，生成文件：meta.local mutation.full_for_MutSig_input.txt
- `easy_input_meta.local mutation.full.txt`：easy_input_meta.local mutation.full.txt，MAF文件，用于推断SVG。从TCGA下载MAF文件的方法可参考FigureYa19Lollipop。
- `easy_input_meta.mut.txt`：见 Rmd“输入文件”节
- `easy_input_local.mut.txt`：见 Rmd“输入文件”节
- `meta.local mutation.full_MutSig_output.sig_genes.txt`：见 Rmd“输入文件”节

MAF需含Hugo_Symbol/Tumor_Sample_Barcode/Variant_Classification等列且Tumor_Seq_Allele1须与Allele2一致；两组样本名文件（meta/local.mut）仅用于分面展示、可省略。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-113mutsigcv`
- 用到课题：`wiki.py use figureya-113mutsigcv --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：需安装MATLAB并手工放置MutSigCV.m；hg19注释、coverage、突变字典等参考文件需从Broad网站注册下载解压；sig_genes结果文件由MATLAB生成后再回R画图。

## 输出

- `oncoprint_mutsigcv_detailed_variationtype.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
