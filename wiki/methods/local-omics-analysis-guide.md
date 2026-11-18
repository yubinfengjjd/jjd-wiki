---
type: method
id: local-omics-analysis-guide
title: 组学课题方法去重与选择（已归档摘要）
status: archived
archived_from: E:/research-wiki-local-archive/pending-curation/local-omics/local-omics-analysis-guide.md
tags:
- single-cell
- transcriptomics
- multi-omics
inputs: []
outputs: []
source:
  kind: written
license: none
cite:
- 原本地课题 557 个 SHA-256 命名脚本及去重账本已统一迁出至 E:/research-wiki-local-archive/pending-curation/local-omics/
favorite: false
method_kind: technical
summary: 原本地课题 SHA-256 冗余脚本已移至 pending-curation 归档；请直接使用规范方法家族与步进决策树。
data_contract:
  input: 无独立可执行入口；请先从规范分析方法页或步进决策树进入。
  output: 无独立输出；按具体规范方法页与标准中间表接口执行。
implementations: []
---
# 组学课题方法去重与选择（已归档摘要）

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：仅供个人研究参考
- 引用：原本地课题 557 个 SHA-256 命名脚本及去重账本已统一迁出至 E:/research-wiki-local-archive/pending-curation/local-omics/
- 标签：single-cell、transcriptomics、multi-omics
- 输入接口：未声明
- 输出接口：未声明
- 接口结构匹配的图（仅结构候选，未核实语义）：暂无
- 接口结构匹配的下一步方法（仅结构候选，未核实语义）：暂无
- 代码模板：无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 用途

原本地课题中提取的大量 SHA-256 命名 R 脚本与中间索引 JSON 已迁出至 `E:/research-wiki-local-archive/pending-curation/local-omics/` 留待后续人工提炼。当前知识库请直接按规范方法家族与 `wiki/scenarios/` 步进决策树检索复用，不再保留冗余哈希脚本。

## 适用

- 查阅历史本地组学脚本去重归档位置。
- 跳转至规范分析方法（如 [[methods/cell-type-annotation]]、[[methods/differential-expression]]、[[methods/gene-set-scoring]]、[[methods/trajectory-inference]]）。

## 不适用

- 直接作为可执行分析入口运行。

## 输入

无独立数据输入；按具体规范方法页要求准备标准中间表或 Seurat/表达矩阵对象。

## 怎么做

1. 通过 `wiki/scenarios/` 四大生信主线步进决策树定位所需分析步骤。
2. 使用 `rwiki next <method_id>` 或 Web 操控台选择对应分析与可视化模版。
3. 如确需查阅原始课题脚本，请检索本机 `E:/research-wiki-local-archive/pending-curation/local-omics/`。

## 代码

原始 SHA-256 脚本已全部备份并移出 Git 仓库至 `E:/research-wiki-local-archive/pending-curation/local-omics/`。

## 输出

无独立输出。

## 知识关联检查

已与 [[methods/cell-type-annotation]]、[[methods/differential-expression]]、[[methods/gene-set-scoring]]、[[methods/trajectory-inference]] 等规范方法家族对齐，本页仅作归档摘要保留以维持历史引用不断链。

<!-- user:start -->
<!-- user:end -->
