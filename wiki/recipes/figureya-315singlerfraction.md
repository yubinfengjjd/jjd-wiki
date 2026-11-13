---
type: recipe
id: figureya-315singlerfraction
title: SingleR细胞来源占比箱图
status: draft
source:
  id: figureya
  item: FigureYa315SingleRFraction
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa315SingleRFraction.Rmd
inputs:
- file: csv.gz
  note: 原文图中有14个cohort，作者上传到GEO数据库的只有9个，<https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE154763>。我们从Supplementary
    file表格里下载csv.gz文件，放到当前目录下的InputData文件夹。
outputs:
- Proption.pdf
- Proption_plus.pdf
packages:
  cran:
  - Matrix
  - Seurat
  - ggplot2
  - ggpubr
  bioc:
  - SingleR
  github: []
  library:
  - Matrix
  - Seurat
  - SingleR
  - ggplot2
  - ggpubr
  namespaced:
  - knitr
  - data.table
tags:
- single-cell
keywords:
- Seurat
- SingleR
- Matrix
- ggpubr
- GSE154763
- LAMP3
- cDC
chart_types:
- boxplot
- violin
summary: 以参考亚群（cDC1/cDC2）的平均表达作训练集，用SingleR预测目标细胞（LAMP3+ cDC）的来源，按队列×患者统计来源占比并画箱线/小提琴图（Kr
favorite: false
---
# SingleR细胞来源占比箱图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa315SingleRFraction` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa315SingleRFraction.Rmd`）
- 依赖：CRAN Matrix, Seurat, ggplot2, ggpubr；Bioconductor SingleR
- 最近运行：fail（as-is，2026-11-04 11:11 UTC，94.0 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

以参考亚群（cDC1/cDC2）的平均表达作训练集，用SingleR预测目标细胞（LAMP3+ cDC）的来源，按队列×患者统计来源占比并画箱线/小提琴图（Kruskal-Wallis）。

## 适用

已有带亚群注释的Seurat对象或多队列表达+metadata，想量化某细胞亚群源自另一亚群的比例并跨队列比较。

## 不适用

依赖数据中现成的亚群注释列（示例写死MajorCluster及M03/M04/M05类名）与cancer/patient元数据；参考/目标亚群须在数据中存在；患者级占比要求每患者有足够该类细胞。

## 输入

- `csv.gz`：原文图中有14个cohort，作者上传到GEO数据库的只有9个，<https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE154763>。我们从Supplementary file表格里下载csv.gz文件，放到当前目录下的InputData文件夹。

示例读InputData下9个cohort的expression/metadata csv.gz（命名需含expression/metadata）；实际可直接换成自己的Seurat对象。

## 怎么用

- 修补执行副本：`repair/`（保留本轮最小修补与补齐输入；偏离与文件哈希见 `repair.json`，运行收据在 `repair-runs/`）。该副本不是上游原字节；标注的合成输入仅用于执行验证，不构成真实数据结论。预览图：`repair-preview.png`。
- 原样运行（Wiki 专用环境）：`wiki.py run figureya-315singlerfraction`
- 用到课题：`wiki.py use figureya-315singlerfraction --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：示例输入需先从GEO（GSE154763）补充文件手工下载csv.gz放入InputData；多队列稀疏矩阵合并较耗内存。

## 输出

- `Proption.pdf`
- `Proption_plus.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]] · [[templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin|分组小提琴图（含统计标注）]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
