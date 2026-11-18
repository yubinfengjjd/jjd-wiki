---
type: method
id: local-omics-visualization-guide
title: 课题绘图依赖与自定义改造（已归档摘要）
status: archived
archived_from: E:/research-wiki-local-archive/pending-curation/local-omics/local-omics-visualization-guide.md
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
- 原本地课题绘图包装脚本与验证账本已统一迁出至 E:/research-wiki-local-archive/pending-curation/local-omics/
favorite: false
method_kind: technical
summary: 原本地课题依赖绘图脚本已移至 pending-curation 归档；请直接使用 L2 可视化模板与 Template Studio。
data_contract:
  input: 无独立可执行入口；请直接使用标准中间表接口与 L2 模板。
  output: 无独立输出；通过 Template Studio 或 rwiki render 生成规范图件。
implementations: []
---
# 课题绘图依赖与自定义改造（已归档摘要）

<!-- facts:start -->
- 来源：依据文献 / 官方文档编写
- 许可证：仅供个人研究参考
- 引用：原本地课题绘图包装脚本与验证账本已统一迁出至 E:/research-wiki-local-archive/pending-curation/local-omics/
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

原本地课题的绘图依赖包装脚本及历史验证 JSON 已迁出至 `E:/research-wiki-local-archive/pending-curation/local-omics/` 留待后续人工提炼。当前请直接通过独立 Web 操控台（Template Studio）或 `wiki/templates/` L2 参数化模板完成列名映射、顶刊配色调参与出图。

## 适用

- 查阅历史本地组学绘图包装脚本的归档位置。
- 跳转至规范可视化模板库（`wiki/templates/`）与原生绘图入口（如 [[methods/scp-viz-dimplots]]、[[methods/scp-viz-statplots]]）。

## 不适用

- 直接作为当前可执行绘图入口运行。

## 输入

无独立数据输入；请按标准中间表（`wiki/interfaces/`）准备长表/统计表后进入 Template Studio。

## 怎么做

1. 根据分析阶段输出的标准中间表（如 `deg-result-table`、`pathway-score-table`）选择兼容的 L2 模板。
2. 在 Template Studio 完成表头嗅探、列绑定与参数调整后实时生成并运行代码。
3. 如确需检索原始课题脚本，请查阅本机 `E:/research-wiki-local-archive/pending-curation/local-omics/`。

## 代码

原始脚本与验证收据已全部备份并移出 Git 仓库至 `E:/research-wiki-local-archive/pending-curation/local-omics/`。

## 输出

无独立输出。

## 知识关联检查

已与 `wiki/templates/` 规范可视化模板及 [[methods/scp-viz-dimplots]] 等入口对齐，本页仅作归档摘要保留以维持历史引用不断链。

<!-- user:start -->
<!-- user:end -->
