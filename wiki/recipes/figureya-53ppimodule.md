---
type: recipe
id: figureya-53ppimodule
title: PPI网络模块挖掘导出
status: draft
source:
  id: figureya
  item: FigureYa53PPImodule
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa53PPImodule.rmd
inputs:
- file: mmc2.xlsx
  note: ''
- file: ppi_gene.csv
  note: ''
- file: ppi_mat.csv
  note: ''
outputs: []
packages:
  cran:
  - Matrix
  - dynamicTreeCut
  - openxlsx
  - stringr
  bioc: []
  github: []
  library:
  - dynamicTreeCut
  - openxlsx
  - stringr
  - Matrix
  - WGCNA
  namespaced:
  - knitr
tags:
- proteomics
keywords:
- STRING
- Uniprot
- WGCNA
- dynamicTreeCut
- openxlsx
- TOM
- Cytoscape
- Matrix
- stringr
chart_types:
- network
summary: 把共表达基因/蛋白列表经Uniprot idmapping映射到STRING PPI，构建0/1邻接矩阵，算TOM后层次聚类+dynamicTreeCut划模块
favorite: false
---
# PPI网络模块挖掘导出

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa53PPImodule` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa53PPImodule.rmd`）
- 依赖：CRAN Matrix, dynamicTreeCut, openxlsx, stringr
- 最近运行：fail（as-is，2026-11-11 06:10 UTC，5.3 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

把共表达基因/蛋白列表经Uniprot idmapping映射到STRING PPI，构建0/1邻接矩阵，算TOM后层次聚类+dynamicTreeCut划模块，导出模块表和cytoscape边/节点文件。

## 适用

想看自己的基因列表（差异基因、共表达蛋白）在PPI网络里聚成哪些功能模块时。

## 不适用

需同时备齐共表达列表xlsx、Uniprot idmapping、STRING protein.actions三个外部文件，物种与版本要对应；ID转换会丢部分蛋白；只产出模块表和cytoscape输入，网络展示须在Cytoscape完成。

## 输入

- `此处用paper附件里的mm2.xlsx`：共表达基因列表，此处用paper附件里的mm2.xlsx
- `MOUSE_10090_idmapping_selected.tab.gz`：Uniprot ID转换文件：<ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/by_organism/MOUSE_10090_idmapping_selected.tab.gz>
- `10090.protein.actions.v10.5.txt.gz`：从STRING数据库下载PPI数据<https://stringdb-static.org/download/protein.actions.v10.5/10090.protein.actions.v10.5.txt.gz>。三个红框表示：数据库版本号，物种搜索框，相互作用数据（包含相互作用类型，如物理相互作用)。注意版本号，以及物种搜索框内为‘Mus musculus’，下载第三个框内文件。
- `mm2.xlsx`：共表达基因列表，此处用paper附件里的mm2.xlsx
- `mmc2.xlsx`：见 Rmd“输入文件”节
- `MOUSE_10090_idmapping_selected.tab`：Uniprot ID转换文件：<ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/idmapping/by_organism/MOUSE_10090_idmapping_selected.tab.gz>
- `10090.protein.actions.v10.5.txt`：从STRING数据库下载PPI数据<https://stringdb-static.org/download/protein.actions.v10.5/10090.protein.actions.v10.5.txt.gz>。三个红框表示：数据库版本号，物种搜索框，相互作用数据（包含相互作用类型，如物理相互作用)。注意版本号，以及物种搜索框内为‘Mus musculus’，下载第三个框内文件。
- `10090.protein.actions.v11.0.txt`：见 Rmd“输入文件”节
- `ppi_gene.csv`：见 Rmd“输入文件”节
- `ppi_mat.csv`：见 Rmd“输入文件”节

演示为小鼠（10090）；idmapping取第1/21列做Uniprot→ENSEMBLPROT映射；STRING文件item_id去物种前缀后与ENSEMBLPROT匹配。

## 怎么用

- 修补执行副本：`repair/`（保留本轮最小修补与补齐输入；偏离与文件哈希见 `repair.json`，运行收据在 `repair-runs/`）。该副本不是上游原字节；标注的合成输入仅用于执行验证，不构成真实数据结论。
- 原样运行（Wiki 专用环境）：`wiki.py run figureya-53ppimodule`
- 用到课题：`wiki.py use figureya-53ppimodule --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：STRING protein.actions解压后约318MB，读入需大内存；idmapping与STRING文件需按物种/版本手动从Uniprot和STRING下载。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
