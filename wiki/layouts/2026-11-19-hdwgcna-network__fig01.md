---
type: layout
id: 2026-11-19-hdwgcna-network__fig01
title: hdWGCNA 共表达模块球体网络图
status: pending_template
gallery_entry: 2026-11-19-hdwgcna-network/figures/fig01
gallery_version: 1
signedoff_version: 1
language: r
tags:
- 单细胞分析
- 转录组
panels:
  A: network
chart_types:
- network
templates: []
template_panels: {}
favorite: false
keywords:
- hdWGCNA
- coexpression-network
---
# hdWGCNA 共表达模块球体网络图

![[layouts/2026-11-19-hdwgcna-network__fig01/thumb.png]]

<!-- facts:start -->
- 来源：scRNA-hdWGCNA共表达网络分析【2】:富集分析及大型球体网络图构建可视化
- 公众号：KS生信科研课
- 日期：2026-08-10
- URL：https://mp.weixin.qq.com/s/LOpSnqiK3nfG-wVU8urzVw
- 画廊条目：2026-11-19-hdwgcna-network/figures/fig01
- 语言：r
- 数据来源：synthetic
- 代码来源：reconstructed
- 标签：单细胞分析、转录组
- 关键词：hdWGCNA、coexpression-network
- 图型：[[chart-types/network]]
- 面板：尚未拆分（A）

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

单细胞 `hdWGCNA` 或 bulk WGCNA 多模块共表达拓扑球体网络与注释展示；可调用模板已函数化为 [[templates/coexpr-sphere-network]]。

## 不适用

不替代真实 `TOM` 共表达矩阵聚类计算；仅用于展示上游筛选后的模块节点与连边。

## 知识关联检查

2026-11-19：对应可调用 R 原生模板 [[templates/coexpr-sphere-network]] 已 `ready` 并挂载于 [[methods/coexpression-ppi-network]]，本版式仅作单 panel 溯源记录（面板 B 见 [[layouts/2026-11-19-hdwgcna-network__fig02]]）。

## 使用记录

<!-- user:start -->
<!-- user:end -->
