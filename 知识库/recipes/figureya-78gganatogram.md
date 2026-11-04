---
type: recipe
id: figureya-78gganatogram
title: 基因表达器官解剖着色图
status: draft
source:
  id: figureya
  item: FigureYa78gganatogram
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa78gganatogram.Rmd
inputs:
- file: easy_input.csv
  note: 如果你的数据已经整理成very_easy_input.csv的格式，就可以跳过这步，进入“开始画图”。
- file: TCGA_organ.txt
  note: 参照GEPIA help的Differential analysis：<http://gepia.cancer-pku.cn/help.html>，在此基础上添加gganatogram包的organ，整理成TCGA_organ.txt文件，欢迎来小Ying画图群里探讨这些对应关系。
- file: very_easy_input_Female.csv
  note: ''
- file: very_easy_input_Male.csv
  note: ''
outputs:
- gganatogram.pdf
packages:
  cran:
  - stringr
  - gridExtra
  - gganatogram
  bioc: []
  github: []
  library:
  - gganatogram
  - stringr
  - gridExtra
  namespaced:
  - knitr
tags:
- transcriptomics
keywords:
- gganatogram
- TCGA
- GTEx
- TPM
- anatogram
- gridExtra
- stringr
chart_types:
- anatogram
summary: 把基因在各组织器官的中位表达值映射到gganatogram男/女人体解剖轮廓上着色，按tumor/normal分面对比。
favorite: false
---
# 基因表达器官解剖着色图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa78gganatogram` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa78gganatogram.Rmd`）
- 依赖：CRAN stringr, gridExtra, gganatogram
- 最近运行：尚无当前原字节的运行收据
- 派生模板（L2）：暂无
<!-- facts:end -->

## 用途

把基因在各组织器官的中位表达值映射到gganatogram男/女人体解剖轮廓上着色，按tumor/normal分面对比。

## 适用

直观展示目标基因在人体各器官、癌种正常与肿瘤组织中的表达分布差异。

## 不适用

器官名必须与包内置organ列表完全一致，需TCGA_organ.txt之类的癌种→器官映射表；只能按器官汇总，器官会被遮挡的小结构看不清，也无法显示器官内异质性。

## 输入

- `easy_input.csv`：如果你的数据已经整理成very_easy_input.csv的格式，就可以跳过这步，进入“开始画图”。
- `TCGA_organ.txt`：参照GEPIA help的Differential analysis：<http://gepia.cancer-pku.cn/help.html>，在此基础上添加gganatogram包的organ，整理成TCGA_organ.txt文件，欢迎来小Ying画图群里探讨这些对应关系。
- `very_easy_input_Female.csv`：见 Rmd“输入文件”节
- `very_easy_input_Male.csv`：见 Rmd“输入文件”节

very_easy_input首列organ名（必需，须匹配包内器官表）、第四列value数值（必需），可加color列直接指定填充色；facet分组变量须命名type。

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-78gganatogram`
- 用到课题：`wiki.py use figureya-78gganatogram --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：gganatogram不在CRAN，install脚本先试devtools::install_github，失败再下GitHub tar.gz源码包装，均需联网。

## 输出

- `gganatogram.pdf`

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
