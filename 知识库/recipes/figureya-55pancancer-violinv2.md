---
type: recipe
id: figureya-55pancancer-violinv2
title: 泛癌分裂小提琴图
status: draft
source:
  id: figureya
  item: FigureYa55panCancer_violinV2
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa55panCancer_violinV2.Rmd
inputs:
- file: easy_input.csv
  note: 如果你的数据已经整理成easy_input.csv的格式，就可以跳过这步，直接进入“输入数据预处理”。
- file: samplepair.txt
  note: ''
- file: GTEX_phenotype.gz
  note: ''
outputs: []
packages:
  cran:
  - RColorBrewer
  - dplyr
  - ggplot2
  - stringr
  bioc: []
  github: []
  library:
  - stringr
  - dplyr
  - ggplot2
  - RColorBrewer
  namespaced: []
tags:
- transcriptomics
keywords:
- GTEx
- TCGA
- Toil
- RSEM
- TPM
- geom_split_violin
- RColorBrewer
- stringr
chart_types:
- violin
summary: 合并TCGA肿瘤与TCGA+GTEx正常组织，用分裂小提琴图对比某基因在各组织肿瘤vs正常的TPM分布。
favorite: false
---
# 泛癌分裂小提琴图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa55panCancer_violinV2` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa55panCancer_violinV2.Rmd`）
- 依赖：CRAN RColorBrewer, dplyr, ggplot2, stringr
- 最近运行：fail（as-is，2026-11-11 05:31 UTC，1.9 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

合并TCGA肿瘤与TCGA+GTEx正常组织，用分裂小提琴图对比某基因在各组织肿瘤vs正常的TPM分布。

## 适用

泛癌尺度展示单个基因在肿瘤与配对正常组织间的表达差异。

## 不适用

一次只画一个基因；组织配对依赖samplepair.txt（参照GEPIA整理）；MESO、UVM等无正常组织的癌种只能画单侧；用Toil的log2TPM口径。

## 输入

- `easy_input.csv`：如果你的数据已经整理成easy_input.csv的格式，就可以跳过这步，直接进入“输入数据预处理”。
- `samplepair.txt`：见 Rmd“输入文件”节
- `GTEX_phenotype.gz`：见 Rmd“输入文件”节
- `TCGA_phenotype_denseDataOnlyDownload.tsv.gz`：见 Rmd“输入文件”节
- `gtex_RSEM_gene_tpm.gz`：见 Rmd“输入文件”节
- `tcga_RSEM_gene_tpm.gz`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-55pancancer-violinv2`
- 用到课题：`wiki.py use figureya-55pancancer-violinv2 --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：从头整理需从UCSC Xena手工下载Toil TPM大文件（tcga/gtex_RSEM_gene_tpm.gz为GB级）及phenotype/probeMap；有easy_input.csv可跳过；按行读数据靠本地read_part.R。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin|分组小提琴图（含统计标注）]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
