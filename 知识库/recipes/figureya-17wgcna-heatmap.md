---
type: recipe
id: figureya-17wgcna-heatmap
title: WGCNA模块基因表达热图
status: draft
source:
  id: figureya
  item: FigureYa17WGCNA_heatmap
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa17WGCNA_heatmap.Rmd
inputs:
- file: easy_input.txt
  note: ''
outputs: []
packages:
  cran:
  - pheatmap
  - plyr
  bioc: []
  github: []
  library:
  - plyr
  - pheatmap
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- WGCNA
- pheatmap
- plyr
chart_types:
- heatmap
summary: 把WGCNA各module基因的表达谱合并、按模块大小排序，不聚类直接画带样本分组和module注释的行标准化热图。
favorite: false
---
# WGCNA模块基因表达热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa17WGCNA_heatmap` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa17WGCNA_heatmap.Rmd`）
- 依赖：CRAN pheatmap, plyr
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

把WGCNA各module基因的表达谱合并、按模块大小排序，不聚类直接画带样本分组和module注释的行标准化热图。

## 适用

已完成WGCNA并拿到各module基因表达量（如FigureYa15WGCNA_module输出的每模块csv），复现文献式module表达谱总览热图。

## 不适用

不做聚类，基因顺序完全由模块决定；样本品系/处理注释在代码里写死（5×4×2结构），换数据需重写annotation_col；输入需含X/module列加固定数量样本列。

## 输入

- `easy_input.txt`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-17wgcna-heatmap`
- 用到课题：`wiki.py use figureya-17wgcna-heatmap --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
