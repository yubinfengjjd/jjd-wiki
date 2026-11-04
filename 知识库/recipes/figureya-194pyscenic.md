---
type: recipe
id: figureya-194pyscenic
title: 单细胞转录调控网络构建
status: draft
source:
  id: figureya
  item: FigureYa194pySCENIC
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa194pySCENIC.Rmd
inputs:
- file: MCA_Figure2batchremoved.txt.tar.gz
  note: 解压`MCA_Figure2batchremoved.txt.tar.gz`重新压缩为gz文件(节省硬盘空间)
- file: MCA_Figure2_Cell.Info.xlsx
  note: '`MCA_Figure2_Cell.Info.xlsx`中有3个sheet，只有前两个对我们有用'
- file: Cell.Info.txt
  note: 将`MCA_Fig2_Cell`中的内容复制到`Cell.Info.txt`文件中
- file: CellType.Info.txt
  note: 将MCA_Fig2_Celltype中的内容复制到`CellType.Info.txt`文件中
outputs: []
packages:
  cran: []
  bioc: []
  github: []
  library: []
  namespaced:
  - knitr
tags:
- single-cell
- transcriptomics
keywords:
- pySCENIC
- SCENIC
- AUCell
- GRNBoost2
- cisTarget
- regulon
- loom
- SEEK
chart_types:
- umap
- heatmap
summary: 以pySCENIC为主（GRNBoost2→cisTarget→AUCell）从单细胞表达矩阵推断TF-regulon活性，复现细胞类型特异regulon、re
favorite: false
---
# 单细胞转录调控网络构建

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa194pySCENIC` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa194pySCENIC.Rmd`）
- 依赖：未声明（见 Rmd library 调用）
- 最近运行：pass（as-is，2026-11-04 11:01 UTC，3.7 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

以pySCENIC为主（GRNBoost2→cisTarget→AUCell）从单细胞表达矩阵推断TF-regulon活性，复现细胞类型特异regulon、regulon module等分析。

## 适用

人/小鼠/果蝇单细胞转录组的转录调控网络构建与cell-state鉴定。

## 不适用

教程仅为导览，全部脚本、loom矩阵、cisTarget数据库需外部获取；流程跨R/Python/shell多语言；只支持三个物种且仅做转录正调控。

## 输入

- `MCA_Figure2batchremoved.txt.tar.gz`：解压`MCA_Figure2batchremoved.txt.tar.gz`重新压缩为gz文件(节省硬盘空间)
- `MCA_Figure2_Cell.Info.xlsx`：`MCA_Figure2_Cell.Info.xlsx`中有3个sheet，只有前两个对我们有用
- `Cell.Info.txt`：将`MCA_Fig2_Cell`中的内容复制到`Cell.Info.txt`文件中
- `CellType.Info.txt`：将MCA_Fig2_Celltype中的内容复制到`CellType.Info.txt`文件中

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-194pyscenic`
- 用到课题：`wiki.py use figureya-194pyscenic --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：需自建pySCENIC Python环境、cisTarget feather数据库与loom文件；MCA表达矩阵（tar.gz需解压重压为gz）与细胞注释xlsx（手工复制成txt）从百度云/figshare下载；regulon验证依赖SEEK在线服务。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap|CNS 细胞类型 UMAP]] · [[templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap|marker 特征 UMAP 小多图]] · [[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
