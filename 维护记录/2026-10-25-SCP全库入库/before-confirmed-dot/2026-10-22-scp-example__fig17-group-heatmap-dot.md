---
type: layout
id: 2026-10-22-scp-example__fig17-group-heatmap-dot
title: 分组表达点阵热图
status: pending_signoff
gallery_entry: 2026-10-22-scp-example/figures/fig17-group-heatmap-dot
gallery_version: 1
signedoff_version: null
language: r
tags:
- 单细胞分析
panels:
  A: heatmap
chart_types:
- heatmap
templates: []
template_panels: {}
favorite: false
keywords:
- SCP
- pancreas_sub
- GroupHeatmap
- add_dot
- percent-size
---
# 分组表达点阵热图

![[layouts/2026-10-22-scp-example__fig17-group-heatmap-dot/thumb.png]]

<!-- facts:start -->
- 来源：SCP v0.5.6 示例数据图型
- 公众号：SCP
- 日期：2026-10-22
- URL：https://github.com/zhanghao-njmu/scp
- 画廊条目：2026-10-22-scp-example/figures/fig17-group-heatmap-dot
- 语言：r
- 数据来源：original
- 代码来源：adapted
- 标签：单细胞分析
- 关键词：SCP、pancreas_sub、GroupHeatmap、add_dot、percent-size
- 图型：[[chart-types/heatmap]]
- 面板：尚未拆分（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

单细胞 marker 基因在一个分组变量（CellType）上的聚合表达热图，并在每格叠加"阈值阳性细胞比例"点：行是 12 个 marker，列是 5 个细胞类型；每格底色为白，格内圆点 **fill 颜色**映射 zscore 聚合值（RdBu 双向色标），圆点**直径**为 `percent`（0–1，原式 `size = dot_size * perc`，按直径线性缩放非面积正比，点图例 20%–100%），列顶色条仅标识分组身份 + 行侧 marker 标注。适合同时检查 marker 的平均表达强度与表达普及度，比纯色块热图多一层比例信息。

来源是 SCP v0.5.6 `GroupHeatmap(add_dot=TRUE)` 在 `pancreas_sub` 上本次实跑的原生输出（8×6 in、150 dpi），未改绘图几何；是 `add_dot` 分支的单 panel。

## 不适用

- 不覆盖同函数其他分支：`add_violin`、`flip`、`split.by` 多列切分、`feature_split`、`n_split`、cell/feature annotation 均未实现（候选代码显式拒绝）。
- `percent` 只能来自逐细胞表达（经原调用声明的 lib_normalize 后、聚合/zscore 前）`> exp_cutoff` 比例的预计算结果，不能对聚合 value 列再取阈值得到；模板不重算、不补 pct、不隐式聚合。
- 输入不是 Seurat 对象；候选读取已聚合的 `render-group-heatmap` 长表。
- percent 是描述性比例，不是统计显著性；示例数据非病例/对照设计，不能据此作生物学结论。
- 不能替代差异检验、富集或细胞类型注释。

## 知识关联检查

日期 2026-10-25；查过 [[layouts/2026-10-22-scp-example__fig08-group-heatmap]]、[[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]]、[[methods/scp-visualization-interface]] 与 heatmap 图型页。

- 同函数分支关系：本页 A panel 与 fig08 ht1 是 `GroupHeatmap()` 的两个视觉分支（`add_dot=TRUE` vs 默认纯色块）；结构实质不同（点层 + Percent 图例），分属不同代表条目，不是同义模板。
- 模板状态：来源待签核，尚无正式模板。候选与运行说明在 `E:/research-wiki-env/work/scp-ingestion-20261025/candidates/group-heatmap-dot/README.md`；画廊代码在 `E:/research-wiki/画廊/2026-10-22-scp-example/figures/fig17-group-heatmap-dot/code/`，可从“查看代码”读取。
- 复用边界：仅复制runtime清单的绘图文件与资源，新R进程可运行，不依赖SCP或Seurat。官方独立性校验verified（当前闭包`c474e19d…`）；直接API返回原生对象，无区域draw适配，不声称共享R会话零副作用。
- 方法关系：[[methods/scp-visualization-interface]] 是技术来源资料，本次只补溯源链接，不新建分析家族或在该技术页维护分析配图主关系。细胞注释、差异表达、轨迹等家族的输出并不自动包含本图需要的逐细胞阈值比例，未建立direct关系。
- 与 `render-dotplot-long` 类普通气泡图接口的区别：本图是热图矩阵 + 点大小叠加 + 分组色条注释的复合结构，不是独立的特征×分组气泡散点；接口形似但图型语义不同，不互换代用。
- 验证范围：原函数独立重跑后，矩阵值/比例一致；三分支PNG、两分支SVG字节一致，1m/2m的PDF栅格相同。嵌套加载、重复调用、异常拒绝和`001`/`01`身份保真已实测，原输入不变。固定图和长标签已由Codex目检；这些是软件/图形验收，不是课题科学结论或作者签核。

## 使用记录

2026-10-25 从 SCP v0.5.6 `GroupHeatmap(add_dot=TRUE)` 本次实跑原生输出入库（gallery fig17-group-heatmap-dot，draft）；候选模板资产在 `E:/research-wiki-env/work/scp-ingestion-20261025/candidates/group-heatmap-dot`；回放/对照/加载边界/契约/独立性证据在 `E:/research-wiki-env/work/scp-ingestion-20261025/evidence/groupheatmap-dot/` 与候选 `verify/`。同日经 Codex 两轮复核后修复并重验：R1–R5（加载闭包私有化、输入/顺序契约收紧、draw 声明移除、官方 runtime_facts=verified）+ 第二轮（序号正整数与键列字符串契约、eval(parse)→闭包的字面量安全、svglite 改 required、文义校正、ht1 基线收据保全于 `wiki/templates/…fig08…/verify/history/`）；等待作者签核后再走 `scaffold-template`。

<!-- user:start -->
<!-- user:end -->
