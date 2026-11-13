---
type: recipe
id: figureya-314singlerscore
title: 细胞亚群签名得分散点图
status: draft
source:
  id: figureya
  item: FigureYa314SingleRScore
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa314SingleRScore.Rmd
inputs:
- file: csv.gz
  note: 原文作者已把数据上传到GEO数据库 <https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE154763>。我们从Supplementary
    file表格里下载csv.gz文件，放到当前目录下的InputData文件夹。
outputs:
- ScoreVisual.pdf
packages:
  cran:
  - Matrix
  - Seurat
  - ggplot2
  bioc: []
  github: []
  library:
  - Matrix
  - Seurat
  - ggplot2
  namespaced:
  - knitr
  - data.table
tags:
- single-cell
keywords:
- Seurat
- FindAllMarkers
- AUCell
- SingleR
- signature score
- LAMP3+ cDC
- GSE154763
- Matrix
chart_types:
- scatter
summary: 对各细胞亚群跑FindAllMarkers得签名基因，再按自定义公式（或AUCell）给每个细胞打签名得分，画得分差值散点图做细胞分层。
favorite: false
---
# 细胞亚群签名得分散点图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa314SingleRScore` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa314SingleRScore.Rmd`）
- 依赖：CRAN Matrix, Seurat, ggplot2
- 最近运行：fail（as-is，2026-11-04 11:10 UTC，37.5 秒）
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

对各细胞亚群跑FindAllMarkers得签名基因，再按自定义公式（或AUCell）给每个细胞打签名得分，画得分差值散点图做细胞分层。

## 适用

验证某细胞亚群是否兼具两个潜在来源的特征（如LAMP3+ cDC源于cDC1/cDC2），做细胞起源/命运分层分析。

## 不适用

需单细胞表达矩阵加含亚群注释的meta数据；得分为自定义启发式公式，用对数归一化数据与原文count口径会有数值偏差；AUCell方案在代码中被注释需自装。

## 输入

- `csv.gz`：原文作者已把数据上传到GEO数据库 <https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE154763>。我们从Supplementary file表格里下载csv.gz文件，放到当前目录下的InputData文件夹。

InputData文件夹按癌种成对放置expression csv.gz（行细胞列基因、首列index）与metadata csv；可单癌种跑或merge多癌种。

## 怎么用

- 修补执行副本：`repair/`（保留本轮最小修补与补齐输入；偏离与文件哈希见 `repair.json`，运行收据在 `repair-runs/`）。该副本不是上游原字节；标注的合成输入仅用于执行验证，不构成真实数据结论。预览图：`repair-preview.png`。
- 原样运行（Wiki 专用环境）：`wiki.py run figureya-314singlerscore`
- 用到课题：`wiki.py use figureya-314singlerscore --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：输入需手工从GEO（GSE154763）Supplementary下载csv.gz；细胞量大时Seurat差异分析较耗时。

## 输出

- `ScoreVisual.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
