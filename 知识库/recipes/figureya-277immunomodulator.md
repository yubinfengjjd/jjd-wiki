---
type: recipe
id: figureya-277immunomodulator
title: 免疫调节因子多组学分型热图
status: draft
source:
  id: figureya
  item: FigureYa277Immunomodulator
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa277Immunomodulator.Rmd
inputs:
- file: immunomodulator.txt
  note: ''
- file: easy_input_subtype.txt
  note: ''
- file: easy_input_expr.txt
  note: ''
- file: easy_input_meth.txt
  note: ''
- file: easy_input_cna.txt
  note: ''
outputs:
- complexheatmap of immunomodulator.pdf
packages:
  cran:
  - data.table
  - genefu
  - ChAMPdata
  - ComplexHeatmap
  - circlize
  bioc:
  - genefu
  - ChAMPdata
  - ComplexHeatmap
  - circlize
  github: []
  library:
  - ComplexHeatmap
  - circlize
  - ChAMPdata
  - data.table
  - genefu
  namespaced:
  - knitr
tags:
- multi-omics
keywords:
- PAM50
- genefu
- ChAMPdata
- ComplexHeatmap
- immunomodulator
- TCGA BRCA
- 甲基化
- CNA
- circlize
- data.table
chart_types:
- heatmap
summary: 单癌种内按分子亚型并排画免疫调节因子基因的四联热图：mRNA表达、表达-甲基化相关性、扩增频率差、缺失频率差。
favorite: false
---
# 免疫调节因子多组学分型热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa277Immunomodulator` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa277Immunomodulator.Rmd`）
- 依赖：CRAN data.table, genefu, ChAMPdata, ComplexHeatmap, circlize；Bioconductor genefu, ChAMPdata, ComplexHeatmap, circlize
- 最近运行：pass（as-is，2026-11-11 07:36 UTC，17.0 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `complexheatmap of immunomodulator.pdf` 第 1 页）：

![[recipes/figureya-277immunomodulator/preview.png]]
<!-- facts:end -->

## 用途

单癌种内按分子亚型并排画免疫调节因子基因的四联热图：mRNA表达、表达-甲基化相关性、扩增频率差、缺失频率差。

## 适用

研究肿瘤亚型间免疫调节基因在表达、甲基化、拷贝数三个层面的差异分布；亚型数可改3/4/6类。

## 不适用

需同一队列的表达、甲基化、CNA三套基因×样本矩阵和亚型表（亚型须命名C1…Cn）；甲基化需探针注释把beta值聚合到基因；示例PAM50分型仅适用乳腺癌，其他癌种需换分型来源。

## 输入

- `immunomodulator.txt`：见 Rmd“输入文件”节
- `TCGA.BRCA.sampleMap_HiSeqV2.gz`：见 Rmd“输入文件”节
- `TCGA.BRCA.sampleMap_HumanMethylation450.gz`：见 Rmd“输入文件”节
- `TCGA.BRCA.sampleMap_Gistic2_CopyNumber_Gistic2_all_thresholded.by_genes.gz`：见 Rmd“输入文件”节
- `easy_input_subtype.txt`：见 Rmd“输入文件”节
- `easy_input_expr.txt`：见 Rmd“输入文件”节
- `easy_input_meth.txt`：见 Rmd“输入文件”节
- `easy_input_cna.txt`：见 Rmd“输入文件”节

三套矩阵均取共有样本；CNA矩阵值约定1扩增/-1缺失/0野生（GISTIC阈值化结果），±2会归并到±1。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-277immunomodulator`
- 用到课题：`wiki.py use figureya-277immunomodulator --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：450K甲基化等Xena大文件需手工下载，fread读取占内存大；genefu做PAM50分型依赖完整表达矩阵。

## 输出

- `complexheatmap of immunomodulator.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
