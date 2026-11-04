---
type: recipe
id: figureya-7psm
title: 病例对照倾向得分匹配
status: draft
source:
  id: figureya
  item: FigureYa7PSM
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa7PSM.Rmd
inputs:
- file: easy_input.txt
  note: 如果你自己有数据，保存成easy_input.txt那样的格式，就可以跳过“生成输入数据”这步，直接进入“倾向得分匹配”；
outputs: []
packages:
  cran:
  - MatchIt
  - wakefield
  bioc: []
  github: []
  library:
  - wakefield
  - MatchIt
  namespaced:
  - knitr
tags:
- experimental-statistics
keywords:
- MatchIt
- wakefield
- PSM
chart_types:
- scatter
summary: 用MatchIt把病例组与对照组按协变量（年龄、性别）做1:1最近邻倾向得分匹配，导出配对信息表并附匹配jitter诊断图。
favorite: false
---
# 病例对照倾向得分匹配

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa7PSM` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa7PSM.Rmd`）
- 依赖：CRAN MatchIt, wakefield
- 最近运行：pass（as-is，2026-11-04 11:19 UTC，6.2 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，自动截取最后一张图）：

![[recipes/figureya-7psm/preview.png]]
<!-- facts:end -->

## 用途

用MatchIt把病例组与对照组按协变量（年龄、性别）做1:1最近邻倾向得分匹配，导出配对信息表并附匹配jitter诊断图。

## 适用

病例-对照或患者-人群比较前需按基线特征匹配消除混杂，例如把患者问卷得分与常模人群比较。

## 不适用

匹配变量与公式（Group~Age+Sex、ratio=1、不放回最近邻）写死需改；Group须为逻辑型；只产匹配表和诊断图，不做后续效应检验；示例人群为wakefield模拟数据。

## 输入

- `easy_input.txt`：如果你自己有数据，保存成easy_input.txt那样的格式，就可以跳过“生成输入数据”这步，直接进入“倾向得分匹配”；

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-7psm`
- 用到课题：`wiki.py use figureya-7psm --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
