---
type: recipe
id: figureya-60gsea-clusterprofilerv2
title: 多通路GSEA富集曲线组图
status: draft
source:
  id: figureya
  item: FigureYa60GSEA_clusterProfilerV2
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa60GSEA_clusterProfilerV2.Rmd
inputs:
- file: easy_input_rnk.txt
  note: ''
outputs:
- GSEA_multi_pathways.pdf
- GSEA_multi_groups.pdf
packages:
  cran:
  - RColorBrewer
  - blueviolet
  - chocolate4
  - cowplot
  - ggplot2
  - ggrepel
  - gridExtra
  - hsa03030
  - hsa03050
  - plyr
  bioc:
  - clusterProfiler
  - enrichplot
  - org.Hs.eg.db
  github: []
  library:
  - clusterProfiler
  - enrichplot
  - plyr
  - ggrepel
  - ggplot2
  - RColorBrewer
  - gridExtra
  - cowplot
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- clusterProfiler
- enrichplot
- gseKEGG
- GSEA
- cowplot
- org.Hs.eg.db
- KEGG
- RColorBrewer
- ggrepel
- gridExtra
- plyr
chart_types:
- gsea-curve
summary: 用clusterProfiler跑gseKEGG后，把多条通路的running ES曲线、基因位置rank条和ranked metric条形图纵排成一张图；也支
favorite: false
---
# 多通路GSEA富集曲线组图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa60GSEA_clusterProfilerV2` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa60GSEA_clusterProfilerV2.Rmd`）
- 依赖：CRAN RColorBrewer, blueviolet, chocolate4, cowplot, ggplot2, ggrepel, gridExtra, hsa03030, hsa03050, plyr；Bioconductor clusterProfiler, enrichplot, org.Hs.eg.db
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用clusterProfiler跑gseKEGG后，把多条通路的running ES曲线、基因位置rank条和ranked metric条形图纵排成一张图；也支持把两个比较的同一通路叠画对比。

## 适用

已用clusterProfiler做了富集分析，想DIY论文式GSEA结果图，或对比A:B与C:D两个比较中的同一通路。

## 不适用

输入为SYMBOL+logFC两列rnk文件，示例只做人类ENTREZID转换；多组对比模式需分两轮运行先各自生成gsea_genelist_*_group*.csv。

## 输入

- `easy_input_rnk.txt`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-60gsea-clusterprofilerv2`
- 用到课题：`wiki.py use figureya-60gsea-clusterprofilerv2 --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：gseKEGG需联网访问KEGG；代码调用enrichplot非导出函数gsInfo，包版本升级后可能要改写法。

## 输出

- `GSEA_multi_pathways.pdf`
- `GSEA_multi_groups.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
