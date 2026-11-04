---
type: recipe
id: figureya-202consensusgene
title: 双通路基因共识聚类分型
status: draft
source:
  id: figureya
  item: FigureYa202consensusGene
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa202consensusGene.Rmd
inputs:
- file: tcga.expr.simplified.txt
  note: tcga.expr.simplified.txt，表达矩阵。
- file: REACTOME_GLYCOLYSIS.txt
  note: REACTOME_GLYCOLYSIS.txt和REACTOME_CHOLESTEROL_BIOSYNTHESIS.txt，参与这两个通路的基因。
- file: REACTOME_CHOLESTEROL_BIOSYNTHESIS.txt
  note: REACTOME_GLYCOLYSIS.txt和REACTOME_CHOLESTEROL_BIOSYNTHESIS.txt，参与这两个通路的基因。
outputs: []
packages:
  cran:
  - dendsort
  - pheatmap
  bioc:
  - ConsensusClusterPlus
  github: []
  library:
  - ConsensusClusterPlus
  - pheatmap
  - dendsort
  namespaced:
  - knitr
tags:
- transcriptomics
- machine-learning
keywords:
- ConsensusClusterPlus
- dendsort
- pheatmap
- REACTOME
chart_types:
- heatmap
- scatter
summary: 对两个通路的基因做基因维度共识聚类筛出共表达基因，再按两通路中位表达把样本分四类，画共识矩阵热图+四象限散点+分型表达热图。
favorite: false
---
# 双通路基因共识聚类分型

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa202consensusGene` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa202consensusGene.Rmd`）
- 依赖：CRAN dendsort, pheatmap；Bioconductor ConsensusClusterPlus
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

对两个通路的基因做基因维度共识聚类筛出共表达基因，再按两通路中位表达把样本分四类，画共识矩阵热图+四象限散点+分型表达热图。

## 适用

想从候选通路基因集中提炼共表达模块，并据此给样本分型（如代谢亚型）时。

## 不适用

聚类簇编号（C1/C2/C3）需人工对照热图回填才能取出基因集，非全自动；肿瘤样本按TCGA条码“01A”筛，非TCGA命名需改；输入需两个单独的通路基因列表。

## 输入

- `tcga.expr.simplified.txt`：tcga.expr.simplified.txt，表达矩阵。
- `REACTOME_GLYCOLYSIS.txt和REACTOME_CHOLESTEROL_BIOSYNTHESIS.txt`：REACTOME_GLYCOLYSIS.txt和REACTOME_CHOLESTEROL_BIOSYNTHESIS.txt，参与这两个通路的基因。
- `REACTOME_GLYCOLYSIS.txt`：REACTOME_GLYCOLYSIS.txt和REACTOME_CHOLESTEROL_BIOSYNTHESIS.txt，参与这两个通路的基因。
- `REACTOME_CHOLESTEROL_BIOSYNTHESIS.txt`：REACTOME_GLYCOLYSIS.txt和REACTOME_CHOLESTEROL_BIOSYNTHESIS.txt，参与这两个通路的基因。

tcga.expr.simplified.txt行=基因列=样本；两个REACTOME文件各含一条通路的基因名（header行即通路名）。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-202consensusgene`
- 用到课题：`wiki.py use figureya-202consensusgene --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：ConsensusClusterPlus reps=100重抽样，基因/样本量大时耗时较长。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
