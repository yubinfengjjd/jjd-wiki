---
type: project
slug: 2026-asthma-lactylation-scrna
title: 哮喘气道上皮与巨噬细胞乳酸化单细胞挖掘
playbook: scrna-stepwise-playbook
status: active
templates:
- 2026-10-22-glaucoma-scrna__fig01-cns-umap--umap
- 2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot
- 2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow
- 2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin
- 2026-10-22-scp-example__fig11-chord--chord
methods:
- cell-quality-control
- batch-integration
- cell-type-annotation
- gene-set-scoring
- differential-expression
- trajectory-inference
summary: 哮喘气道单细胞数据集的乳酸化基因集多算法打分、巨噬细胞高活亚群筛选、拟时序轨迹与细胞通讯验证记录。
---
# 哮喘气道上皮与巨噬细胞乳酸化单细胞挖掘

- **所属主线**：[[scenarios/scrna-stepwise-playbook|单细胞转录组步进决策树]] · [[scenarios/geneset-theme-playbook|特定修饰与主题基因集挖掘决策树]]
- **课题来源清单**：[[methods/asthma-lactylation-source-catalog|哮喘乳酸化单细胞来源清单]] · [[methods/asthma-lactylation-workflow|哮喘乳酸化单细胞流程]]

## 步进记录

### Step 1：单细胞质控、去批次整合与细胞类型注释

- **【所用模版】**：[[methods/cell-quality-control]] + [[methods/batch-integration]] + [[methods/cell-type-annotation]] + [[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap]]
- **【观察结果与排坑】**：多样本整合后 UMAP 批间混合良好；结合先验气道上皮与髓系 Marker 气泡图（[[templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot]]）完成主细胞类型注释，发现哮喘组单核/巨噬细胞亚群比例升高。
- **【触发下一步】**：从注释完成节点进入【方向 1：组成比例校验】与【方向 3：乳酸化主题基因集多算法打分】（接口 `scrna-annotated-cells` -> `pathway-score-table`）。

### Step 2：细胞组成比例核查与乳酸化主题多算法活性打分

- **【所用模版】**：[[methods/gene-set-scoring]] + [[templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow]] + [[templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin]]
- **【观察结果与排坑】**：AUCell/UCell/ssGSEA 多算法打分一致显示哮喘组巨噬细胞乳酸化得分最高；打分合并前需核对基因命名一致性并做 Z-score 标准化，避免单算法尺度和偏倚。
- **【触发下一步】**：按乳酸化打分中位数将巨噬细胞划分为 High vs Low 亚群，进入【亚群内 DEG 差异分析】、【拟时序轨迹】与【CellChat 通讯比较】。

### Step 3：高乳酸化巨噬细胞拟时序分化与 CellChat 通讯互作

- **【所用模版】**：[[methods/differential-expression]] + [[methods/trajectory-inference]] + [[recipes/figureya-310cpdbchordgramv2]] + [[templates/2026-10-22-scp-example__fig11-chord--chord]]
- **【观察结果与排坑】**：高乳酸化巨噬细胞富集于炎症激活终末分支，与上皮细胞之间配受体通讯信号增强；提取单核-巨噬谱系单独重降维时去除了跨谱系伪分支干扰。
- **【触发下一步】**：汇总交集候选靶基因表 `candidate-biomarker-list`，准备向外部哮喘 Bulk 队列投射验证。
