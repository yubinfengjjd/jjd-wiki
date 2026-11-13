---
type: recipe
id: figureya-58lncrnareannotation
title: 芯片探针lncRNA重注释
status: ready
source:
  id: figureya
  item: FigureYa58lncRNAreannotation
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa58lncRNAreannotation.Rmd
inputs:
- file: seqmap_gene.tmp
  note: ''
- file: gplTOgene.csv
  note: ''
- file: easy_input.csv
  note: ''
- file: lncRNA.probes.txt
  note: ''
outputs: []
packages:
  cran:
  - tidyverse
  bioc:
  - GEOquery
  github: []
  library:
  - tidyverse
  - GEOquery
  namespaced:
  - knitr
  - dplyr
tags:
- transcriptomics
keywords:
- GEOquery
- tidyverse
- blast
- seqmap
- GENCODE
- lncRNA
- GPL15314
chart_types:
- table
summary: 把芯片探针序列与GENCODE最新转录本序列比对（blast或seqmap），按biotype规则筛出唯一映射到lncRNA的探针，再从表达矩阵提取lncRNA
favorite: false
---
# 芯片探针lncRNA重注释

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa58lncRNAreannotation` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa58lncRNAreannotation.Rmd`）
- 依赖：CRAN tidyverse；Bioconductor GEOquery
- 最近运行：pass（as-is，2026-11-04 11:15 UTC，61.0 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

把芯片探针序列与GENCODE最新转录本序列比对（blast或seqmap），按biotype规则筛出唯一映射到lncRNA的探针，再从表达矩阵提取lncRNA表达量。

## 适用

GEO老芯片官方注释过时或缺lncRNA注释时，重新注释探针并提取lncRNA（同理mRNA/miRNA）表达矩阵。

## 不适用

需探针序列（GPL含SEQUENCE列或官网下载probeset fasta）与转录组fasta；比对须外部可执行程序；只产表达矩阵不出图；lncRNA的biotype定义与≥4探针阈值需按研究调整。

## 输入

- `gencode.v29.transcripts.fa.gz`：转录本DNA序列。以人为例，从gencode网站下载v29版本的转录本fasta文件：<ftp://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_29/gencode.v29.transcripts.fa.gz>，解压缩到当前文件夹。已包含gene symbol、biotype等信息。
- `HG-U133A_2.target.zip`：例如GPL3921平台，直接到官网找到芯片平台页面：<http://www.affymetrix.com/support/technical/byproduct.affx?product=hgu133-20>，下载probeset的fasta文件：<http://www.affymetrix.com/Auth/analysis/downloads/data/HG-U133A_2.target.zi
- `HuEx-1_0-st-v2.hg18.probeset.fa.zip`：例文用到的GPL5188平台，官网芯片平台页面：<http://www.affymetrix.com/support/technical/byproduct.affx?product=huexon-st>，下载probeset的fasta文件：<http://www.affymetrix.com/Auth/analysis/downloads/data/HuEx-1_0-st-v2.hg18.pr
- `blast_gene.tmp`：见 Rmd“输入文件”节
- `seqmap_gene.tmp`：见 Rmd“输入文件”节
- `gplTOgene.csv`：见 Rmd“输入文件”节
- `easy_input.csv`：见 Rmd“输入文件”节
- `lncRNA.probes.txt`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-58lncrnareannotation`
- 用到课题：`wiki.py use figureya-58lncrnareannotation --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：依赖外部程序seqmap（快照含Linux/Mac二进制，Windows用法见manual4windows.docx）或blast+套件（makeblastdb/blastn需自行下载）；getGEO联网下载GPL soft；需自备GENCODE转录本fa.gz（解压后数GB）；Affymetrix探针序列需官网注册下载。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
