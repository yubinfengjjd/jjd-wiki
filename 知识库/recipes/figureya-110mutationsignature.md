---
type: recipe
id: figureya-110mutationsignature
title: 突变签名NMF聚类热图
status: draft
source:
  id: figureya
  item: FigureYa110mutationSignature
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa110mutationSignature.Rmd
inputs:
- file: blca.mut.maf.txt
  note: blca.mut.maf.txt，基因突变数据。
outputs:
- Cophenetic coefficient for seleting optimal nmf rank.pdf
- consensusmap.pdf
- basismap.pdf
packages:
  cran:
  - tidyverse
  - magrittr
  - readxl
  - stringr
  - forcats
  - NMF
  - BSgenome.Hsapiens.UCSC.hg19
  bioc:
  - BSgenome.Hsapiens.UCSC.hg19
  github: []
  library:
  - tidyverse
  - magrittr
  - readxl
  - stringr
  - forcats
  - BSgenome.Hsapiens.UCSC.hg19
  - NMF
  namespaced:
  - knitr
tags:
- multi-omics
- machine-learning
keywords:
- deconstructSigs
- NMF
- COSMIC
- BSgenome.Hsapiens.UCSC.hg19
- MAF
- NMF consensusmap
- basismap
- forcats
- magrittr
- readxl
- stringr
- tidyverse
chart_types:
- heatmap
summary: 用deconstructSigs把MAF突变记录转成96型三核苷酸突变谱，逐样本分解COSMIC签名权重，再经NMF聚类寻找亚型驱动签名并绘制copheneti
favorite: false
---
# 突变签名NMF聚类热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa110mutationSignature` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa110mutationSignature.Rmd`）
- 依赖：CRAN tidyverse, magrittr, readxl, stringr, forcats, NMF, BSgenome.Hsapiens.UCSC.hg19；Bioconductor BSgenome.Hsapiens.UCSC.hg19
- 最近运行：pass（as-is，2026-11-11 06:34 UTC，541.2 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `Cophenetic coefficient for seleting optimal nmf rank.pdf` 第 1 页）：

![[recipes/figureya-110mutationsignature/preview.png]]
<!-- facts:end -->

## 用途

用deconstructSigs把MAF突变记录转成96型三核苷酸突变谱，逐样本分解COSMIC签名权重，再经NMF聚类寻找亚型驱动签名并绘制cophenetic曲线、consensusmap、basismap等热图。

## 适用

有肿瘤MAF突变数据，想做突变签名分解与样本聚类分型，复现Alexandrov式signature分析。

## 不适用

输入须为含Tumor_Sample_Barcode/Chromosome/Start_Position/Reference_Allele/Tumor_Seq_Allele2列的MAF，且只用SNP；逐样本循环分解签名，样本量大时很慢；基因组坐标固定hg19。

## 输入

- `blca.mut.maf.txt`：blca.mut.maf.txt，基因突变数据。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-110mutationsignature`
- 用到课题：`wiki.py use figureya-110mutationsignature --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：deconstructSigs核心函数以随附R脚本（mut.to.sigs.input.R、whichSignatures.R）本地source提供；需安装大体积Bioconductor基因组包BSgenome.Hsapiens.UCSC.hg19。

## 输出

- `Cophenetic coefficient for seleting optimal nmf rank.pdf`
- `consensusmap.pdf`
- `basismap.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
