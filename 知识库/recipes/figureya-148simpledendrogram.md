---
type: recipe
id: figureya-148simpledendrogram
title: 带注释的样本聚类树状图
status: draft
source:
  id: figureya
  item: FigureYa148SimpleDendrogram
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa148SimpleDendrogram.Rmd
inputs:
- file: easy_input_set1.txt
  note: easy_input_set1.txt，带有淋巴结转移信息的GEO数据表达数据。是否淋巴结转移的信息在sample ID里。
- file: easy_input_set2.txt
  note: easy_input_set2.txt，MSKCC队列的表达矩阵
- file: easy_input_set2_suv.txt
  note: easy_input_set2_suv.txt，MSKCC队列的生存信息
outputs:
- dendrogram for validation 1.pdf
- dendrogram for validation 2.pdf
packages:
  cran:
  - ClassDiscovery
  - dendsort
  - squash
  bioc: []
  github: []
  library:
  - ClassDiscovery
  - dendsort
  - squash
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- ClassDiscovery
- dendsort
- squash
- dendromat
chart_types:
- dendrogram
summary: 对signature基因表达矩阵按Pearson距离+ward.D做样本层次聚类，画dendromat树状图并在叶下方叠加聚类分组与转移/生存状态等注释色条。
favorite: false
---
# 带注释的样本聚类树状图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa148SimpleDendrogram` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa148SimpleDendrogram.Rmd`）
- 依赖：CRAN ClassDiscovery, dendsort, squash
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

对signature基因表达矩阵按Pearson距离+ward.D做样本层次聚类，画dendromat树状图并在叶下方叠加聚类分组与转移/生存状态等注释色条。

## 适用

用训练队列找到的基因signature在外部验证队列上聚类，把已知临床信息画在样本树下直观展示分类验证效果。

## 不适用

表达矩阵应只含signature基因；注释信息需从列名解析或与矩阵列名严格对应；示例cutree只分2类、注释条目与颜色写死需自行修改。

## 输入

- `easy_input_set1.txt`：easy_input_set1.txt，带有淋巴结转移信息的GEO数据表达数据。是否淋巴结转移的信息在sample ID里。
- `easy_input_set2.txt`：easy_input_set2.txt，MSKCC队列的表达矩阵
- `easy_input_set2_suv.txt`：easy_input_set2_suv.txt，MSKCC队列的生存信息

set1的淋巴结转移状态嵌在样本列名中；set2要求表达矩阵列名与生存表行名完全一致（代码有一致性检查）。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-148simpledendrogram`
- 用到课题：`wiki.py use figureya-148simpledendrogram --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `dendrogram for validation 1.pdf`
- `dendrogram for validation 2.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
