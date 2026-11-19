---
type: template
id: spatial-feature-grid
title: 空间转录组特征分布网格
status: draft
layouts: []
sources:
- methods/spatial-transcriptomics-microenvironment
panels: []
language: r
primary_method: spatial-transcriptomics-microenvironment
tags:
- single-cell
- transcriptomics
chart_types:
- spatial-map
keywords: []
favorite: false
---
# 空间转录组特征分布网格

<!-- facts:start -->
- 来源：[[methods/spatial-transcriptomics-microenvironment|空间转录组空间域识别、微生态定位与微环境解析]]
- 语言：r
- 标签：single-cell、transcriptomics
- 图型：[[chart-types/spatial-map]]
- 输入接口：未声明
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

在同一组织切片的 spot 坐标上并排展示连续基因表达、签名分数或反卷积值。对应 Cai 等主图 2J、6D–G 及附图 3、6 的空间分布展示。

## 不适用

输入只有亚群汇总、缺少空间坐标，或需要叠加 H&E、做空间插值、在多切片之间配准时，应使用相应的上游工具。

## 知识关联检查

2026-11-19：新建模板主归属方法 [[methods/spatial-transcriptomics-microenvironment]]。

## 数据要求

`spatial_spots_long.csv` 每行是一个 spot × 特征观测，含同一切片坐标系的数值列 `x`、`y`、特征名 `feature` 和连续值 `value`。可选 `sample` 用于记录切片，当前渲染按特征分图，多切片须先分开调用。各特征独立着色，色深仅供同一特征内比较。

## 使用记录

<!-- user:start -->
<!-- user:end -->
