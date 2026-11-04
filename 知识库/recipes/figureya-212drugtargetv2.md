---
type: recipe
id: figureya-212drugtargetv2
title: 亚组药敏预测候选药物图
status: draft
source:
  id: figureya
  item: FigureYa212drugTargetV2
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa212drugTargetV2.Rmd
inputs:
- file: LIHC.TPM.txt
  note: LIHC.TPM.txt，基因表达矩阵。计算PPS得分和药敏预测，都基于这个表达矩阵。实际应用时把这个表达矩阵替换成你自己的数据。
- file: data_mutations_mskcc.txt
  note: data_mutations_mskcc.txt，maf突变数据，用于提取癌症亚型，例文提取的是TP53-mutant patients。
- file: 17gene.txt
  note: 17gene.txt，用于计算PPS得分。17-gene set in the model with the largest C-index value
    was considered as PPS. Table S3.
- file: CTRP_AUC_raw.txt
  note: 'CTRP_AUC_raw.txt，用于制作CTRP AUC矩阵. To generate the CTRP AUC matrix. Source:
    Correlating chemical sensitivity and basal gene expression reveals mechanism of
    action，2016 Nature Chemical Biology，Supplement'
- file: CTRP_ccl_anno.txt
  note: CTRP_ccl_anno.txt，CTRP_cpd_anno.txt, from Supplementary Data Set 1，Supplementary
    Data Set 2
- file: CTRP_cpd_anno.txt
  note: CTRP_ccl_anno.txt，CTRP_cpd_anno.txt, from Supplementary Data Set 1，Supplementary
    Data Set 2
- file: PRISM_AUC.txt
  note: PRISM_AUC.txt，from <https://depmap.org/portal/download/> Drug sensitivity
    AUC (PRISM Repurposing Secondary Screen) 19Q4
- file: CTRP_AUC.txt
  note: ''
- file: overlapTable27.txt
  note: ''
outputs:
- drug target.pdf
packages:
  cran:
  - tidyverse
  - ISOpureR
  - SimDesign
  - cowplot
  - ridge
  - car
  bioc:
  - impute
  - sva
  github: []
  library:
  - ridge
  - tidyverse
  - ISOpureR
  - impute
  - SimDesign
  - ggplot2
  - cowplot
  namespaced:
  - knitr
  - forcats
tags:
- computational-drug-design
- transcriptomics
keywords:
- ISOpureR
- ridge
- pRRophetic
- calcPhenotype
- CCLE
- CTRP
- PRISM
- impute
- SimDesign
- cowplot
- PPS
- tidyverse
chart_types:
- dotplot
- boxplot
summary: 以CCLE表达谱+CTRP/PRISM药敏AUC为训练集，用pRRophetic式岭回归预测TCGA亚组样本药敏；再用Spearman相关点线图与高/低PPS组
favorite: false
---
# 亚组药敏预测候选药物图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa212drugTargetV2` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa212drugTargetV2.Rmd`）
- 依赖：CRAN tidyverse, ISOpureR, SimDesign, cowplot, ridge, car；Bioconductor impute, sva
- 最近运行：not_run（as-is，2026-11-04 17:48 UTC，1.8 秒）；缺包 ISOpureR
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

以CCLE表达谱+CTRP/PRISM药敏AUC为训练集，用pRRophetic式岭回归预测TCGA亚组样本药敏；再用Spearman相关点线图与高/低PPS组箱线图筛候选药物。

## 适用

想基于细胞系药敏数据库预测肿瘤队列（某突变亚组或高低评分组）潜在敏感药物，复现Figure5F/G式组合图。

## 不适用

流程针对TCGA-LIHC+TP53亚组写死（样本码按barcode第11-12位解析肿瘤/正常）；需CTRP/PRISM/CCLE三套外部数据及17基因PPS签名系数；只做in silico预测不验证药效；细胞系/药物名匹配步骤繁琐易丢。

## 输入

- `LIHC.TPM.txt`：LIHC.TPM.txt，基因表达矩阵。计算PPS得分和药敏预测，都基于这个表达矩阵。实际应用时把这个表达矩阵替换成你自己的数据。
- `data_mutations_mskcc.txt`：data_mutations_mskcc.txt，maf突变数据，用于提取癌症亚型，例文提取的是TP53-mutant patients。
- `17gene.txt`：17gene.txt，用于计算PPS得分。17-gene set in the model with the largest C-index value was considered as PPS. Table S3.
- `CTRP_AUC_raw.txt`：CTRP_AUC_raw.txt，用于制作CTRP AUC矩阵. To generate the CTRP AUC matrix. Source: Correlating chemical sensitivity and basal gene expression reveals mechanism of action，2016 Nature Chemical Biology，Supplement
- `CTRP_ccl_anno.txt`：CTRP_ccl_anno.txt，CTRP_cpd_anno.txt, from Supplementary Data Set 1，Supplementary Data Set 2
- `CTRP_cpd_anno.txt`：CTRP_ccl_anno.txt，CTRP_cpd_anno.txt, from Supplementary Data Set 1，Supplementary Data Set 2
- `PRISM_AUC.txt`：PRISM_AUC.txt，from <https://depmap.org/portal/download/> Drug sensitivity AUC (PRISM Repurposing Secondary Screen) 19Q4
- `CCLE_RNAseq_rsem_genes_tpm_20180929.txt`：CCLE_RNAseq_rsem_genes_tpm_20180929.txt，细胞系表达谱，作为药敏预测时的训练集。Cell line expression profile, as train dataset for drug sensitivity prediction, from <https://portals.broadinstitute.org/ccle/data>.
- `CTRP_AUC.txt`：见 Rmd“输入文件”节
- `overlapTable27.txt`：见 Rmd“输入文件”节

LIHC.TPM.txt为表达矩阵（列名含TCGA型别码）；maf为cBioPortal格式；PRISM_AUC前5列为细胞系注释；17gene.txt需含Coefficient列。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-212drugtargetv2`
- 用到课题：`wiki.py use figureya-212drugtargetv2 --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：需附带脚本predict_from_cgp.R（取自pRRophetic）；逐药岭回归循环很慢（数百药物×细胞系）；ISOpure纯化默认runpure=F跳过，开启约需一周；CCLE表达谱为gz大文件。

## 输出

- `drug target.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]] · [[templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot|细胞类型 × 基因气泡点图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
