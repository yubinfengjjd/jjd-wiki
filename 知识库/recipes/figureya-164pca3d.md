---
type: recipe
id: figureya-164pca3d
title: 三维PCA分组散点图
status: draft
source:
  id: figureya
  item: FigureYa164PCA3D
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa164PCA3D.Rmd
inputs:
- file: CGGA.mRNA_array_301_clinical.20191128.txt
  note: 分组信息，CGGA.mRNA_array_301_clinical.20191128.txt，至少包含CGGA_ID和Grade两列，这里用Grade为LGG和GBM分组。从CGGA下载：[Clinical
    Data](http://www.cgga.org.cn/download?file=download/20191128/CGGA.mRNA_array_301_clinical.201911
- file: IMMUNE_SYSTEM_PROCESS_M13664.txt
  note: '[immune system process, M13664](https://www.gsea-msigdb.org/gsea/msigdb/download_geneset.jsp?geneSetName=IMMUNE_SYSTEM_PROCESS&fileType=txt)基因集合，重命名为"IMMUNE_SYSTEM_PROCESS_M13664.txt"；'
- file: IMMUNE_RESPONSE_M19817.txt
  note: '[immune response, M19817](https://www.gsea-msigdb.org/gsea/msigdb/download_geneset.jsp?geneSetName=IMMUNE_RESPONSE&fileType=txt)基因集合，重命名为"IMMUNE_RESPONSE_M19817.txt"。'
- file: easy_input_expr_all.csv
  note: ''
- file: easy_input_expr.csv
  note: ''
- file: easy_input_group1.txt
  note: ''
- file: easy_input_group2.txt
  note: ''
- file: mypar3d.RData
  note: ''
outputs: []
packages:
  cran:
  - rgl
  bioc: []
  github: []
  library:
  - rgl
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- PCA
- rgl
- CGGA
- MSigDB
- 免疫基因集
chart_types:
- pca
summary: 对表达矩阵做prcomp，用rgl弹出可交互旋转的三维散点图，按两组着色展示样本关系。
favorite: false
---
# 三维PCA分组散点图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa164PCA3D` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa164PCA3D.Rmd`）
- 依赖：CRAN rgl
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

对表达矩阵做prcomp，用rgl弹出可交互旋转的三维散点图，按两组着色展示样本关系。

## 适用

测序数据质控看批次/分组整体差异，或用通路基因集（如免疫相关基因）做PCA展示组间表型差异。

## 不适用

rgl需OpenGL图形窗口，只能手动拖角度后保存PNG，不适合无头服务器批量出图；示例按两组着色，多组需自行扩展配色。

## 输入

- `CGGA.mRNA_array_301_gene_level.20191128.txt`：基因表达矩阵，CGGA.mRNA_array_301_gene_level.20191128.txt，每行一个基因，每列一个sample。从CGGA下载：[Expression Data (gene level)](http://www.cgga.org.cn/download?file=download/20191128/CGGA.mRNA_array_301_gene_level.201911
- `CGGA.mRNA_array_301_gene_level.20191128.txt.zip`：基因表达矩阵，CGGA.mRNA_array_301_gene_level.20191128.txt，每行一个基因，每列一个sample。从CGGA下载：[Expression Data (gene level)](http://www.cgga.org.cn/download?file=download/20191128/CGGA.mRNA_array_301_gene_level.201911
- `CGGA.mRNA_array_301_clinical.20191128.txt`：分组信息，CGGA.mRNA_array_301_clinical.20191128.txt，至少包含CGGA_ID和Grade两列，这里用Grade为LGG和GBM分组。从CGGA下载：[Clinical Data](http://www.cgga.org.cn/download?file=download/20191128/CGGA.mRNA_array_301_clinical.201911
- `CGGA.mRNA_array_301_clinical.20191128.txt.zip`：分组信息，CGGA.mRNA_array_301_clinical.20191128.txt，至少包含CGGA_ID和Grade两列，这里用Grade为LGG和GBM分组。从CGGA下载：[Clinical Data](http://www.cgga.org.cn/download?file=download/20191128/CGGA.mRNA_array_301_clinical.201911
- `IMMUNE_SYSTEM_PROCESS_M13664.txt`：[immune system process, M13664](https://www.gsea-msigdb.org/gsea/msigdb/download_geneset.jsp?geneSetName=IMMUNE_SYSTEM_PROCESS&fileType=txt)基因集合，重命名为"IMMUNE_SYSTEM_PROCESS_M13664.txt"；
- `IMMUNE_RESPONSE_M19817.txt`：[immune response, M19817](https://www.gsea-msigdb.org/gsea/msigdb/download_geneset.jsp?geneSetName=IMMUNE_RESPONSE&fileType=txt)基因集合，重命名为"IMMUNE_RESPONSE_M19817.txt"。
- `easy_input_expr_all.csv`：见 Rmd“输入文件”节
- `easy_input_expr.csv`：见 Rmd“输入文件”节
- `easy_input_group1.txt`：见 Rmd“输入文件”节
- `easy_input_group2.txt`：见 Rmd“输入文件”节
- `mypar3d.RData`：见 Rmd“输入文件”节

表达矩阵行基因列样本；group1/group2文件各存一列样本ID并与矩阵列名一致。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-164pca3d`
- 用到课题：`wiki.py use figureya-164pca3d --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：运行会弹出rgl交互窗口需人工调角度，保存仅支持PNG；示例表达/临床数据与MSigDB基因集均需从CGGA、gsea-msigdb手工下载。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
