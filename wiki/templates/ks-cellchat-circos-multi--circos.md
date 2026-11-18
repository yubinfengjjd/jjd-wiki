---
type: template
id: ks-cellchat-circos-multi--circos
title: 细胞通讯多轨环形图（配受体互作+表达热图+柱状轨）
status: draft
sources:
- sources/ks-wechat
layouts: []
panels: []
language: r
license: MIT
tags:
- 单细胞分析
chart_types:
- circos
keywords:
- CellChat
- CellPhoneDB
- circlize
- pyCirclize
- 细胞通讯
- 受配体
- 环形热图
- KS科研
favorite: false
---
# 细胞通讯多轨环形图（配受体互作+表达热图+柱状轨）

<!-- facts:start -->
- 来源：[[sources/ks-wechat|KS生信科研课（公众号 / KS-account-codes）]]
- 语言：r
- 许可证：MIT
- 标签：单细胞分析
- 图型：[[chart-types/circos]]
- 输入接口：[[interfaces/cellchat-lr-table|细胞通讯配受体互作表]] · [[interfaces/celltype-gene-expression|细胞类型×基因平均表达表]]
- 接口结构匹配的分析方法（仅结构候选，未核实语义）：暂无

- 方法配图关系（语义审查）：
  - 暂无已记录关系；接口或标签相同不代表语义已核实。
<!-- facts:end -->

## 适用

参考微信公众号《KS科研分享与服务》（`https://mp.weixin.qq.com/s/bF8f_hoVPwbCdKGPCGJ5Ng`，作者 TS的美梦）推文展示的多轨单细胞通讯环形图，基于 R `circlize` + `ComplexHeatmap` 独立复刻并参数化为单 panel 可调用模板。一张图同时呈现四层信息：

1. **外圈扇区弧与基因角色标签**：按细胞亚群（如 `ECs`、`Tcell`、`SMCs`、`Mon`、`Kers`、`Fibs`、`Mast`、`lang`、`Men`）分扇区；基因标签斜体展示并按功能区分颜色（绿色 `ligand` 配体 vs 粉红色 `receptor` 受体）。
2. **外环表达量热图轨（Track 1）**：展示每个配体/受体基因在所有细胞亚群中的标准化表达强弱（蓝-白-红 Z-score 色阶）。
3. **中环强度柱状轨（Track 2）**：统计并展示各基因在当前细胞亚群中的累积互作强度（`0–100` 归一化刻度）。
4. **内环弦图连线（Track 3）**：按 `Interaction Score`（黄-绿-蓝-紫 `YlGnBu` 渐变）连接发送方配体与接收方受体，并可加粗高亮 Top N 关键受配体通路。

## 不适用

- 仅作可视化呈现：模板读取上游 CellChat / CellPhoneDB 导出的配受体互作表（`cellchat-lr-table`）及可选表达表（`celltype-gene-expression`），不重算通讯概率 `prob` 或置换检验 `pval`。
- 当细胞亚群数量过多（> 18 个）或基因总数超过 120 个时，外圈扇区标签容易拥挤，建议在输入表阶段先按 `prob` 与 `pval` 过滤出核心受配体对，或在操控台增大画布宽高（`width` / `height`）。
- 若未提供表达量表（`celltype-gene-expression.csv`），热图轨会退化为基于互作参与度的示意强度，不能当真实表达量解释。

## 知识关联检查

- 上游标准接口：主要消费 [[interfaces/cellchat-lr-table|细胞通讯配受体互作表]]（必需），可选配合 [[interfaces/celltype-gene-expression|细胞类型×基因平均表达表]]。
- 与 [[templates/2026-10-22-scp-example__fig11-chord--chord|分组流向和弦图]] 的区别：后者统计单细胞二维计数矩阵，本模板专为细胞通讯的“配受体基因级连线 + 表达热图 + 强度柱状轨”设计，不互相替代。

## 数据要求

模板化后生成。

## 使用记录

2026-11-18：根据《KS科研分享与服务》公众号文章（`https://mp.weixin.qq.com/s/bF8f_hoVPwbCdKGPCGJ5Ng`）与作者提供的目标效果图，在本地 R 4.5.0（`circlize` + `ComplexHeatmap`）中完成多轨环形图复刻与参数 Schema 接入。

<!-- user:start -->
<!-- user:end -->
