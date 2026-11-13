---
type: recipe
id: figureya-8radar
title: 组分比例花瓣雷达图
status: ready
source:
  id: figureya
  item: FigureYa8radar
  commit: 8d7a02c7d00467c45471139b63620571afebbeba
  url: https://github.com/ying-ge/FigureYa
license: CC-BY-NC-SA-4.0
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
language: r
runner: rmd-knit
entry: source/FigureYa8radarChart.Rmd
inputs:
- file: easy_input.txt
  note: ''
outputs: []
packages:
  cran:
  - rsvg
  bioc: []
  github: []
  library:
  - rsvg
  namespaced:
  - knitr
tags:
- other
keywords:
- rsvg
- SVG
- radar chart
chart_types:
- radial
summary: 用R手工拼接SVG语句生成花瓣式雷达占比图（圆环刻度+贝塞尔花瓣+环绕文字），再用rsvg把svg转成pdf矢量图。
favorite: false
---
# 组分比例花瓣雷达图

> CC BY-NC-SA 4.0：仅限非商业使用；使用时署名并引用来源文献；改编后的代码须以相同许可共享；源码与派生代码默认保存 Git；保留原许可、署名与用途限制，私有数据、密码和私钥不进 Git。

<!-- facts:start -->
- 来源：[[sources/figureya|FigureYa 医学科研绘图模块库]] · 条目 `FigureYa8radar` · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；引用：Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005
- 语言 / 运行：r · knitr 原样运行（入口 `source/FigureYa8radarChart.Rmd`）
- 依赖：CRAN rsvg
- 最近运行：pass（as-is，2026-11-04 11:20 UTC，5.6 秒）
- 派生模板（L2）：暂无
- 运行预览（最近一次通过的原样运行，取自 `radar.pdf` 第 1 页）：

![[recipes/figureya-8radar/preview.png]]
<!-- facts:end -->

## 用途

用R手工拼接SVG语句生成花瓣式雷达占比图（圆环刻度+贝塞尔花瓣+环绕文字），再用rsvg把svg转成pdf矢量图。

## 适用

展示一个总体各组分的比例构成或同一衡量体系下的多项指标，追求美观的圆形花瓣布局。

## 不适用

输入五列表头（Name/ratio/fill/text_size/text_color）不可改名；花瓣控制点等参数按条目数调试，改结构需谨慎；不含常规统计图层。

## 输入

- `easy_input.txt`：见 Rmd“输入文件”节

## 怎么用

- 原样运行（Wiki 专用环境）：`wiki.py run figureya-8radar`
- 用到课题：`wiki.py use figureya-8radar --project <课题目录>`，按“输入”替换同名文件（列格式保持一致），参数在 Rmd 的“参数设置”段改；然后 `wiki.py run --dir <副本目录>`。
- 改统计逻辑、阈值含义或分组定义前先问作者。
- 运行提示：产物为.svg文件，转pdf依赖rsvg包（Linux需系统装librsvg2开发库）。

## 输出

- 见 Rmd（适配器未识别出输出文件名）。

## 知识关联检查

2026-11-04：查了同图型模板与方法页。库内暂无同图型模板。L1 配方按整模块原样运行，figure_relations 在升级为 L2 模板/方法时再核对。

## 使用记录

<!-- user:start -->
<!-- user:end -->
