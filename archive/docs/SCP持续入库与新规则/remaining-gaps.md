# SCP续整理：核实过的覆盖边界与后续批次

更新：2026-10-25。固定SCP 0.5.6 commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0；不切换新版，不安装依赖。本表是审查记录，不授予方法/模板可用状态。

最新进展：作者随后明确确认点阵图，并重申任务是SCP全部方法和全部可视化入库。点阵已完成正式scaffold/verify/mark-ready，可调用模板为`2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap`；当前SCP示例模板17个。全库任务在`2026-10-25-SCP全库入库`继续，不能把点阵这批当终点；详见full-library-plan.md。旧批次验收记录中的待签核是当时事实，不替代这里的新批准。

## 已有基础与本批

- 当前正式库15个分析家族，其中13个承载SCP来源，另2个来自SHAP和回归评价。不要按软件包或来源重建同义方法。
- 旧S1–S3留下16个SCP示例图模板，覆盖StatPlot的11种形态及Volcano、GroupHeatmap默认、FeatureHeatmap默认、CellCorHeatmap默认、CellDensityPlot默认。这里的“覆盖”只引用各自历史示例收据，不代表本批重跑16个，也不代表同函数所有分支。
- 作者本次指定从GroupHeatmap接着做。本批针对add_dot（单矩阵、reticle、双矩阵）做原生提炼、实际新进程复测和视觉检查；状态以本批最终验收记录为准。新来源的作者签核与软件验证分开。
- 142个NAMESPACE导出已生成一对一机械索引：`维护记录/2026-10-25-SCP续整理/namespace-crosswalk.csv`及JSON。每条含固定源码定义位置和既有页面文字指针；文字命中不等于科学归属、分支覆盖或执行通过。
- Devin首轮160行coverage草稿未获审查接受：存在多个导出合并计数、家族数错误、缺包状态误报和分支范围过宽。该草稿不能作正式覆盖统计或自动推荐依据。

## 尚未完成的图样

| 次序 | 主题 | 需完成的具体工作 | 验收边界 |
|---|---|---|---|
| 1 | GroupHeatmap余项 | add_violin、flip、split.by、feature_split/row_split、cell/feature annotation、enrichment annotation | 逐分支确认真实输入和原生几何；不从add_dot通过推断其余通过 |
| 2 | 降维与特征展示 | CellDimPlot、FeatureDimPlot的contour/标签/feature/lineage/velocity等 | 与现有通用UMAP按结构去重；保留SCP原生主题/色板，不能用相似重画替代 |
| 3 | 特征统计 | FeatureStatPlot、FeatureCorPlot | 具体统计单位、上游计算与绘图层分离；不隐式重新检验 |
| 4 | 富集展示 | EnrichmentPlot各型、GSEAPlot | 先核对真实富集结果；旧enrichment原型中有重画及wordcloud失败，不算原生全覆盖 |
| 5 | 动态/轨迹/速度 | DynamicHeatmap、DynamicPlot、LineagePlot、PAGAPlot、ProjectionPlot、VelocityPlot、GraphPlot | 图形回放不批准轨迹/速度算法；依赖缺失保留精确not_run |
| 6 | 交互/3D | CellDimPlot3D、FeatureDimPlot3D | 保留HTML/交互依赖与可用边界；截图不能冒充交互已支持 |

这些是续做批次，不自动批准整组制图、下载数据、安装包或新增科学算法。旧示例说明与本机真实素材逐项核对；新图样签核走正常流程。

## 分析实现仍需单独核查

- 降维的默认分支通过不代表NMF/其他后端；NMF虽本机存在也不能从“包已安装”升级为已验证。
- scDblFinder、SingleR、monocle、RcppML在本批初始实际包探针中缺失；没有安装。历史not_run、当前缺包和未探测是不同事实。
- RunHarmony2应按批次校正目的复核归属，不能只按文件位置归到降维。
- 多整合后端、参考映射后端、KNN/Scmap注释、GSEA、动态富集及Python轨迹/速度分支不能继承兄弟实现的verified。
- DE options恢复候选出现实际二次调用回归；候选已否决、隔离副本已恢复正式基线，失败证据保留。当前建议独立R进程，不宣称共享会话副作用已修复。

## 与入库无关但已记录的维护问题

现有规则将领域tags限定为规范词表，但API标签写入与lint尚无完整受控词表约束；Codex已在私有夹具真实复现非法标签写入并未报错（`controlled-tags-red2/probe-result.json`）。本批没有改动后端来掩盖此缺口，也未写入正式非法标签。应另列维护修复，不能宣称“规则文字存在”就已经自动阻止。

## 每批完成的判据

原始字节/作者字段保护、真实原生参考、值与比例语义、异目录清单复制、新进程调用、合法换数据、错误拒绝、原输入不变、当前闭包收据、正式CLI/API/浏览器、Wiki判断和来源映射均分别留证。确认队列为空或进程正常退出不代替以上验收。

本批补充审查点：CSV中001/01等身份值必须在读取时保留；factor不能按level code当数值；显示序号须拒绝缺失/无穷/小数/负数和歧义；标签应作为字面数据，不拼入eval(parse)；包若无条件用于导出就不能虚报为可选；点直径与点面积的比例编码要分清；原始摘录的新增说明放provenance而不写进原代码字节。GroupHeatmap点阵本批的软件/草稿入库结果见`维护记录/2026-10-25-SCP续整理/final-acceptance.md`，作者签核尚待。
