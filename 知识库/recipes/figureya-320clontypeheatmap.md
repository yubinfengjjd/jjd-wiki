---
type: recipe
id: figureya-320clontypeheatmap
title: 细胞类型间共享克隆热图
status: draft
source:
  id: figureya
  item: FigureYa320ClontypeHeatmap
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa320ClontypeHeatmap.Rmd
inputs:
- file: cell.info.txt
  note: cell.info.txt，应当包含barcode列(barcode)，细胞类型列(celltype)，克隆型列(clonaltype)。
outputs:
- count_heatmap.pdf
packages:
  cran:
  - Treg
  - openxlsx
  bioc:
  - ComplexHeatmap
  github: []
  library:
  - openxlsx
  - ComplexHeatmap
  namespaced:
  - knitr
tags:
- single-cell
keywords:
- ComplexHeatmap
- TCR
- clonotype
- cellranger VDJ
- openxlsx
chart_types:
- heatmap
summary: 统计克隆型在各细胞类型间两两共享的数量，log(1+n)转换后画对称热图，区分同质与异质克隆型分布。
favorite: false
---
# 细胞类型间共享克隆热图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa320ClontypeHeatmap` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa320ClontypeHeatmap.Rmd`）
- 依赖：CRAN Treg, openxlsx；Bioconductor ComplexHeatmap
- 最近运行：fail（as-is，2026-11-04 11:12 UTC，27.0 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

统计克隆型在各细胞类型间两两共享的数量，log(1+n)转换后画对称热图，区分同质与异质克隆型分布。

## 适用

评估TCR/BCR克隆型在细胞亚群间的分布广度与克隆多样性。

## 不适用

默认用户已完成细胞分群注释并获得克隆型（如cellranger VDJ的all_contig_annotations.csv）；细胞类型顺序在plot.order里硬编码需按数据改。

## 输入

- `cell.info.txt`：cell.info.txt，应当包含barcode列(barcode)，细胞类型列(celltype)，克隆型列(clonaltype)。
- `all_contig_annotations.csv`：克隆型可由cellranger VDJ分析模块生成，一般储存在*all_contig_annotations.csv中，克隆型根据使用者的偏好也可由其他软件进行再校准，有较高的自由度，因此本部分假设使用者已从cellranger或其他软件中获得克隆型数据。

cell.info.txt须含barcode/celltype/clonaltype三列；需先剔除celltype为-1/空/Cyto等未定义类。

## 怎么用

- 修补执行副本：`repair/`（保留本轮最小修补与补齐输入；偏离与文件哈希见 `repair.json`，运行收据在 `repair-runs/`）。该副本不是上游原字节；标注的合成输入仅用于执行验证，不构成真实数据结论。预览图：`repair-preview.png`。
- 原样运行（Wiki 专用环境）：`wiki.py run figureya-320clontypeheatmap`
- 用到课题：`wiki.py use figureya-320clontypeheatmap --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- `count_heatmap.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。同图型模板：[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]] · [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]] · [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]] · [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]；画法与输入是否相同未核对，不建立直连关系。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
