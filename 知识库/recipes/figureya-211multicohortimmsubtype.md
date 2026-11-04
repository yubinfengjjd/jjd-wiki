---
type: recipe
id: figureya-211multicohortimmsubtype
title: 多队列免疫分型热图与生存曲线
status: draft
source:
  id: figureya
  item: FigureYa211multiCohortImmSubtype
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa211multiCohortImmSubtype.Rmd
inputs:
- file: tcga_hnsc.expr.txt
  note: TCGA hnsc的表达数据和生存信息：tcga_hnsc.expr.txt和tcga_hnsc.surv.txt。可以用TCGAbiolinks下载，或从[xena](https://xenabrowser.net/datapages/)下载。
- file: tcga_hnsc.surv.txt
  note: TCGA hnsc的表达数据和生存信息：tcga_hnsc.expr.txt和tcga_hnsc.surv.txt。可以用TCGAbiolinks下载，或从[xena](https://xenabrowser.net/datapages/)下载。
- file: gse41613.expr.txt
  note: 来自GEO的芯片数据和生存信息：gse41613.expr.txt和gse41613.surv.txt，gse65858.expr.txt和gse65858.surv.txt
- file: gse41613.surv.txt
  note: 来自GEO的芯片数据和生存信息：gse41613.expr.txt和gse41613.surv.txt，gse65858.expr.txt和gse65858.surv.txt
- file: gse65858.expr.txt
  note: 来自GEO的芯片数据和生存信息：gse41613.expr.txt和gse41613.surv.txt，gse65858.expr.txt和gse65858.surv.txt
- file: gse65858.surv.txt
  note: 来自GEO的芯片数据和生存信息：gse41613.expr.txt和gse41613.surv.txt，gse65858.expr.txt和gse65858.surv.txt
- file: CIBERSORT result.txt
  note: ''
outputs:
- km curve of ICIcluster.pdf
packages:
  cran:
  - tidyestimate
  - pheatmap
  - survival
  - survminer
  - ggplot2
  - dplyr
  - tidyr
  - ggpubr
  - reshape2
  - tibble
  - readr
  - sva
  - ConsensusClusterPlus
  bioc:
  - sva
  - ConsensusClusterPlus
  - GSVA
  - preprocessCore
  github: []
  library:
  - sva
  - ConsensusClusterPlus
  - survminer
  - survival
  - tidyestimate
  - pheatmap
  namespaced:
  - knitr
  - NMF
tags:
- transcriptomics
- survival-analysis
keywords:
- ComBat
- sva
- ESTIMATE
- tidyestimate
- CIBERSORT
- LM22
- ConsensusClusterPlus
- HNSC
- pheatmap
- survival
- survminer
chart_types:
- heatmap
- km-curve
summary: 合并多平台表达谱并用ComBat去批次，计算ESTIMATE得分与CIBERSORT免疫浸润，共识PAM聚类分免疫亚型，画浸润热图和亚型KM曲线。
favorite: false
---
# 多队列免疫分型热图与生存曲线

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa211multiCohortImmSubtype` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa211multiCohortImmSubtype.Rmd`）
- 依赖：CRAN tidyestimate, pheatmap, survival, survminer, ggplot2, dplyr, tidyr, ggpubr, reshape2, tibble, readr, sva, ConsensusClusterPlus；Bioconductor sva, ConsensusClusterPlus, GSVA, preprocessCore
- 最近运行：pass（as-is，2026-11-04 11:03 UTC，955.3 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-211multicohortimmsubtype/preview.png]]
<!-- facts:end -->

## 用途

合并多平台表达谱并用ComBat去批次，计算ESTIMATE得分与CIBERSORT免疫浸润，共识PAM聚类分免疫亚型，画浸润热图和亚型KM曲线。

## 适用

整合TCGA+GEO等不同平台队列做基于免疫浸润的分子分型，并检验亚型间预后差异。

## 不适用

需每个队列的表达矩阵与生存文件齐全、样本量足够；CIBERSORT需注册下载LM22且运行缓慢，亚型数与聚类参数需手工设定。

## 输入

- `tcga_hnsc.expr.txt和tcga_hnsc.surv.txt`：TCGA hnsc的表达数据和生存信息：tcga_hnsc.expr.txt和tcga_hnsc.surv.txt。可以用TCGAbiolinks下载，或从[xena](https://xenabrowser.net/datapages/)下载。
- `gse41613.expr.txt和gse41613.surv.txt`：来自GEO的芯片数据和生存信息：gse41613.expr.txt和gse41613.surv.txt，gse65858.expr.txt和gse65858.surv.txt
- `gse65858.expr.txt和gse65858.surv.txt`：来自GEO的芯片数据和生存信息：gse41613.expr.txt和gse41613.surv.txt，gse65858.expr.txt和gse65858.surv.txt
- `tcga_hnsc.expr.txt`：TCGA hnsc的表达数据和生存信息：tcga_hnsc.expr.txt和tcga_hnsc.surv.txt。可以用TCGAbiolinks下载，或从[xena](https://xenabrowser.net/datapages/)下载。
- `tcga_hnsc.surv.txt`：TCGA hnsc的表达数据和生存信息：tcga_hnsc.expr.txt和tcga_hnsc.surv.txt。可以用TCGAbiolinks下载，或从[xena](https://xenabrowser.net/datapages/)下载。
- `gse41613.expr.txt`：来自GEO的芯片数据和生存信息：gse41613.expr.txt和gse41613.surv.txt，gse65858.expr.txt和gse65858.surv.txt
- `gse41613.surv.txt`：来自GEO的芯片数据和生存信息：gse41613.expr.txt和gse41613.surv.txt，gse65858.expr.txt和gse65858.surv.txt
- `gse65858.expr.txt`：来自GEO的芯片数据和生存信息：gse41613.expr.txt和gse41613.surv.txt，gse65858.expr.txt和gse65858.surv.txt
- `gse65858.surv.txt`：来自GEO的芯片数据和生存信息：gse41613.expr.txt和gse41613.surv.txt，gse65858.expr.txt和gse65858.surv.txt
- `CIBERSORT result.txt`：见 Rmd“输入文件”节

各队列expr行基因列样本、surv含OS/OS.time且行名样本ID一致（TCGA行名会自动补-01后缀）；CIBERSORT结果以样本为行。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-211multicohortimmsubtype`
- 用到课题：`wiki.py use figureya-211multicohortimmsubtype --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：CIBERSORT代码块默认eval=FALSE，需自备LM22.txt（注册下载）并允许长耗时，或直接读预存的CIBERSORT result.txt；ConsensusClusterPlus千次重抽样约需10分钟。

## 输出

- `km curve of ICIcluster.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]] · [[templates/figureya-1survivalcurve-update--km-curve|KM 生存曲线与风险表]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
