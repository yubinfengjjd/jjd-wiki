---
type: recipe
id: figureya-114ternarycluster
title: 通路基因三态表达聚类热图
status: draft
source:
  id: figureya
  item: FigureYa114ternaryCluster
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa114ternaryCluster.Rmd
inputs:
- file: easy_input_expr.csv
  note: easy_input_expr.csv，文章作者提供的32189*197基因表达矩阵(FPKM)，前147列来自肿瘤样本，后面是50个正常对照的表达谱。
- file: easy_input_signatures.csv
  note: easy_input_signatures.csv，某一通路基因列表，此处是TGFbeta。
outputs: []
packages:
  cran:
  - gplots
  - pheatmap
  - magick
  bioc:
  - GSVA
  - SpatialExperiment
  github: []
  library:
  - GSVA
  - pheatmap
  - gplots
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- GSVA
- pheatmap
- gplots
- ssGSEA
chart_types:
- heatmap
summary: 针对单一通路基因集，把每个肿瘤样本中各基因的表达相对正常样本分位数判为高/低/不变三态，层次聚类成三态热图，并用GSVA得分做亚组间Kruskal-Wallis
favorite: false
---
# 通路基因三态表达聚类热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa114ternaryCluster` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa114ternaryCluster.Rmd`）
- 依赖：CRAN gplots, pheatmap, magick；Bioconductor GSVA, SpatialExperiment
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

针对单一通路基因集，把每个肿瘤样本中各基因的表达相对正常样本分位数判为高/低/不变三态，层次聚类成三态热图，并用GSVA得分做亚组间Kruskal-Wallis检验。

## 适用

想展示某基因集在样本间的表达异质性并据其表达模式给样本分型，再关联通路得分或临床指标时。

## 不适用

需要同一份表达矩阵同时含肿瘤列和正常对照列，且按位置写死两类样本列数；只支持单个基因集三态划分，分组数与分位数阈值需自行调整。

## 输入

- `easy_input_expr.csv`：easy_input_expr.csv，文章作者提供的32189*197基因表达矩阵(FPKM)，前147列来自肿瘤样本，后面是50个正常对照的表达谱。
- `easy_input_signatures.csv`：easy_input_signatures.csv，某一通路基因列表，此处是TGFbeta。

easy_input_expr.csv前tumornumber列为肿瘤、后normalnumber列为正常样本；easy_input_signatures.csv为单列基因列表，基因名需与矩阵行名一致。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-114ternarycluster`
- 用到课题：`wiki.py use figureya-114ternarycluster --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
