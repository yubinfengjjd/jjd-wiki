---
type: recipe
id: figureya-14circos
title: 多轨道基因组环形圈图
status: draft
source:
  id: figureya
  item: FigureYa14circos
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa14circos.Rmd
inputs:
- file: karyotype.species.txt
  note: Mydata文件夹放在Circos主目录下，跟circos-0.69-6/Mydata/etc/文件夹里的三个conf、以及karyotype.species.txt文件是一套的。
outputs: []
packages:
  cran: []
  bioc: []
  github: []
  library: []
  namespaced: []
tags:
- multi-omics
keywords:
- Circos
- Perl
- karyotype
chart_types:
- circos
summary: 用Circos（Perl程序）在环形基因组图上叠加GC含量、基因密度、表达量、SNP等多轨道及连线。
favorite: false
---
# 多轨道基因组环形圈图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa14circos` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa14circos.Rmd`）
- 依赖：未声明（见 Rmd library 调用）
- 最近运行：fail（as-is，2026-11-04 11:01 UTC，4.3 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

用Circos（Perl程序）在环形基因组图上叠加GC含量、基因密度、表达量、SNP等多轨道及连线。

## 适用

展示多条/单条染色体或多基因上的基因组特征；把segment换成细胞系、人群等对象还可画非染色体圈图。

## 不适用

不在R内运行，需终端调用Circos；要手工编写conf配置文件和karyotype文件，无图形界面参数，上手成本高。

## 输入

- `karyotype.species.txt`：Mydata文件夹放在Circos主目录下，跟circos-0.69-6/Mydata/etc/文件夹里的三个conf、以及karyotype.species.txt文件是一套的。

数据文件放circos主目录Mydata/data下，每文件四列（片段ID/起/止/信号值），track类型与文件由etc/circos.conf指定。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-14circos`
- 用到课题：`wiki.py use figureya-14circos --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：需先安装Perl（Windows装ActivePerl）、Circos及缺失的Perl模块（含GD），全程命令行操作。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
