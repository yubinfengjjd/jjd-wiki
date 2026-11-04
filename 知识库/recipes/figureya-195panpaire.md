---
type: recipe
id: figureya-195panpaire
title: 泛癌配对样本通路得分连线图
status: draft
source:
  id: figureya
  item: FigureYa195PanPaire
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa195PanPaire.Rmd
inputs:
- file: easy_input_gene.txt
  note: easy_input_gene.txt，代谢基因，来自例文补充材料41388_2019_1026_MOESM2_ESM.xlsx中Table S1。不局限于通路，还可以是某一群基因，例如前期研究筛选出的signature等。
- file: easy_input_pair.txt
  note: easy_input_pair.txt，配对样本信息。
- file: 41388_2019_1026_MOESM2_ESM.xlsx
  note: easy_input_gene.txt，代谢基因，来自例文补充材料41388_2019_1026_MOESM2_ESM.xlsx中Table S1。不局限于通路，还可以是某一群基因，例如前期研究筛选出的signature等。
- file: GDC-PANCAN.basic_phenotype.tsv
  note: ''
outputs:
- Metabolic landscape of tcga paired sample.pdf
packages:
  cran:
  - data.table
  bioc:
  - GSVA
  github: []
  library:
  - data.table
  - GSVA
  namespaced:
  - knitr
tags:
- transcriptomics
- experimental-statistics
keywords:
- GSVA
- ssGSEA
- TCGA
- paired samples
- PanCanAtlas
- XENA
- GDC-PANCAN
- data.table
chart_types:
- dotplot
summary: 按TCGA barcode提取泛癌配对肿瘤/癌旁样本，对给定基因集算ssGSEA得分，跨癌种画肿瘤-正常配对点与连线并做配对wilcoxon检验。
favorite: false
---
# 泛癌配对样本通路得分连线图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa195PanPaire` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa195PanPaire.Rmd`）
- 依赖：CRAN data.table；Bioconductor GSVA
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

按TCGA barcode提取泛癌配对肿瘤/癌旁样本，对给定基因集算ssGSEA得分，跨癌种画肿瘤-正常配对点与连线并做配对wilcoxon检验。

## 适用

想比较同一患者肿瘤与正常组织间某通路或signature的富集得分；barcode配对方法同样适用甲基化等其他TCGA数据。

## 不适用

仅限同时存在-01A肿瘤与-11A正常样本的患者；基因集需自备（示例取自原文补充表）；22癌种的layout小多图布局为硬编码。

## 输入

- `easy_input_gene.txt`：easy_input_gene.txt，代谢基因，来自例文补充材料41388_2019_1026_MOESM2_ESM.xlsx中Table S1。不局限于通路，还可以是某一群基因，例如前期研究筛选出的signature等。
- `easy_input_pair.txt`：easy_input_pair.txt，配对样本信息。
- `easy_input_expr.RDS`：easy_input_expr.RDS，配对样本的表达矩阵。
- `41388_2019_1026_MOESM2_ESM.xlsx`：easy_input_gene.txt，代谢基因，来自例文补充材料41388_2019_1026_MOESM2_ESM.xlsx中Table S1。不局限于通路，还可以是某一群基因，例如前期研究筛选出的signature等。
- `GDC-PANCAN.basic_phenotype.tsv`：见 Rmd“输入文件”节
- `EBPlusPlusAdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.tsv`：见 Rmd“输入文件”节

easy_input_pair.txt含samID/tissue（paired.tumor|paired.normal）/project三列；easy_input_expr.RDS列名须为samID；easy_input_gene.txt为单列基因名。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-195panpaire`
- 用到课题：`wiki.py use figureya-195panpaire --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：从头建配对矩阵需另下载XENA表型和PanCanAtlas表达大文件（该步骤eval=FALSE，可直接用随附easy_input文件跳过）。

## 输出

- `Metabolic landscape of tcga paired sample.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot|细胞类型 × 基因气泡点图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
