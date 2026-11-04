---
type: source
id: figureya
title: FigureYa 医学科研绘图模块库
url: https://github.com/ying-ge/FigureYa
commit: 8d7a02c7d00467c45471139b63620571afebbeba
license: CC-BY-NC-SA-4.0
license_notice: ''
cite:
- 'Lu X, et al. (2025). FigureYa: A Standardized Visualization Framework for Enhancing
  Biomedical Data Interpretation and Research Efficiency. iMetaMed 1: e70005. https://doi.org/10.1002/imm3.70005'
adapter: figureya
trusted: true
snapshot: figureya
tags: []
keywords: []
summary: ''
---
# FigureYa 医学科研绘图模块库

<!-- facts:start -->
- 上游：https://github.com/ying-ge/FigureYa · commit `8d7a02c7d004`
- 许可证：CC-BY-NC-SA-4.0；白名单：是（按需获取不再询问）
- 适配器：figureya；快照：`<sources_root>/figureya`（不进 Wiki）
- L0 目录：313 项（`sources/figureya/items.jsonl`）；自动领域分布：transcriptomics 217、multi-omics 107、experimental-statistics 101、machine-learning 92、survival-analysis 84、single-cell 46、diagnostic-roc 35、other 12
- L1 配方：50 个：[[recipes/figureya-102multipanelroc|多变量 Logistic 模型训练/测试 ROC]]（ready） · [[recipes/figureya-109subtypegsea-update|多亚型GSEA富集对角热图]]（draft） · [[recipes/figureya-115cofactor|ChIP-seq样本相关性聚类热图]]（draft） · [[recipes/figureya-11bubble|富集分析对角排列气泡图]]（ready） · [[recipes/figureya-132alteration|泛癌通路基因变异扫雷图]]（draft） · [[recipes/figureya-138nicecalibration|Logistic 模型校准曲线与 HL 检验]]（ready） · [[recipes/figureya-13gsea-java-update|Java GSEA 结果多通路美化图]]（ready） · [[recipes/figureya-141risk|风险评分分布与签名基因热图联图]]（ready） · [[recipes/figureya-143survcor-update|相关性散点叠加最佳截断四象限]]（ready） · [[recipes/figureya-149rankheatmap|差异倍数分档注释热图]]（draft） · [[recipes/figureya-153ccgraph|层级关系同心环网络图]]（draft） · [[recipes/figureya-162boxviolin|半小提琴箱线散点组合图]]（ready） · [[recipes/figureya-173fancybar|含亚组的多组均值柱图与比较]]（ready） · [[recipes/figureya-18oncoplot-update|多样本基因突变瀑布图]]（draft） · [[recipes/figureya-193risktable|训练与验证集风险评分多因素森林表]]（ready） · [[recipes/figureya-196panpie|分组临床分期扇形矩阵图]]（ready） · [[recipes/figureya-1survivalcurve-update|多组 KM 生存曲线与风险表]]（ready） · [[recipes/figureya-202consensusgene|双通路基因共识聚类分型]]（draft） · [[recipes/figureya-214kegg-hierarchyv2|KEGG三层层级富集条形图]]（draft） · [[recipes/figureya-227boxdensity|箱线图叠加密度分布图]]（ready） · [[recipes/figureya-228linkcor|相关热图与连线蝴蝶图]]（ready） · [[recipes/figureya-230immunelandscape|多算法免疫浸润组合热图]]（draft） · [[recipes/figureya-236circgroup|分型对应关系圈状热图]]（ready） · [[recipes/figureya-253pangsea|泛癌分组GSEA富集气泡图]]（draft） · [[recipes/figureya-25sankey-update|多层分类流向桑基图]]（ready） · [[recipes/figureya-284pairwiselogrank|三组以上 KM 曲线与两两比较表]]（ready） · [[recipes/figureya-293machinelearning|多算法组合预后模型 C 指数比较]]（draft） · [[recipes/figureya-293plus-binaryclassificationml|多算法二分类模型评估筛选]]（draft） · [[recipes/figureya-307cnvheatmap|基因组拷贝数变异热图]]（draft） · [[recipes/figureya-30nomogram-update|Cox/Logistic 列线图与校准曲线]]（ready） · [[recipes/figureya-318genesetdedotplot|单细胞通路活性差异点图]]（draft） · [[recipes/figureya-31lasso-update|LASSO Cox 系数路径与交叉验证图]]（ready） · [[recipes/figureya-33dca-update|决策曲线与净获益分析]]（ready） · [[recipes/figureya-36nsurvv3|双基因高低分组生存曲线]]（draft） · [[recipes/figureya-37correlationv2-update|圆形布局基因相关连线图]]（ready） · [[recipes/figureya-39bar|分组着色柱图与正负富集柱图]]（ready） · [[recipes/figureya-44profile|基因组区域平均信号曲线]]（draft） · [[recipes/figureya-53ppimodule|PPI网络模块挖掘导出]]（draft） · [[recipes/figureya-59plus-geo2deg|GEO芯片差异表达与火山图]]（draft） · [[recipes/figureya-59volcanov2|差异表达火山图（经典与进阶）]]（ready） · [[recipes/figureya-61gsva|GSVA 通路评分与组间差异]]（draft） · [[recipes/figureya-66univariatecox|批量单基因Cox森林图]]（draft） · [[recipes/figureya-6rhrsv2|临床亚组分析森林图]]（ready） · [[recipes/figureya-73batchcorrelation|目标基因批量相关散点图]]（draft） · [[recipes/figureya-76corrgram|多变量相关矩阵散点热图]]（ready） · [[recipes/figureya-81immune-network|免疫细胞相关预后网络图]]（draft） · [[recipes/figureya-85timeroc|多模型时间依赖 ROC 曲线]]（ready） · [[recipes/figureya-92immune-gene-update|基因与免疫浸润相关性图]]（ready） · [[recipes/figureya-97correlationv3|基因免疫浸润相关热图]]（draft） · [[recipes/figureya-99smoothhrv2|限制性立方样条 HR 曲线]]（ready）
<!-- facts:end -->

## 这是什么

## 怎么用

- 检索：`wiki.py find <关键词>`；L0 条目可直接 `wiki.py use <来源>:<条目> --project <课题>`。
- 升级为 L1 配方：`wiki.py promote figureya <条目>…`，再 `wiki.py run <配方 id>`。

## 许可与引用

## 知识关联检查

<!-- figureya-selection:start -->
## 样式筛选记录

2026-11-02 按作者完成的前端筛选整理：原来源共 313 个模块，其中 182 个移出默认检索和推荐，131 个未移除。

- 对应 15 个已收录配方退出默认推荐；本次未涉及 L2 模板。
- 另一个压缩包增量来源的 33 个版本尚无筛选决定，保持原状。
- 完整来源数量和历史配方状态仍作溯源保存；不应据此绕过作者的样式选择。
- 当前决定以 `sources/figureya-curation.json` 为准，可在前端“已移除”中恢复。未移除不等于作者已验收或已运行。
<!-- figureya-selection:end -->

<!-- user:start -->
<!-- user:end -->
