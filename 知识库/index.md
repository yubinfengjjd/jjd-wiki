<!-- 由 wiki.py 生成，不要手改 -->

# 目录

检索请用 `catalog.jsonl` 或 `wiki.py find`；本页按类型列出全部页面。

## 场景

- [[scenarios/clinical-prediction-survival|临床预测与生存分析]] — 队列随访或二分类结局：生存曲线、HR 森林图、预后模型构建与评价（区分度、校准、临床获益）。
- [[scenarios/differential-enrichment|差异表达与富集分析]] — 两组或多组的差异基因展示（火山图）与通路层面的结果（GSEA、GSVA、富集气泡/柱图）。
- [[scenarios/model-explanation|模型解释与特征重要性]] — 机器学习模型的特征重要性与 SHAP 解释图，以及特征筛选。
- [[scenarios/correlation|相关性分析]] — 变量两两相关、基因与免疫浸润/通路的相关，以及相关结果的热图、连线、散点展示。
- [[scenarios/composition-flow|组成与流向]] — 分类变量的构成比例、层级之间的流向与分型对应关系。
- [[scenarios/group-comparison|组间比较]] — 两组或多组连续指标的分布与差异展示：箱线、小提琴、密度、均值柱。
- [[scenarios/dimension-reduction-single-cell|降维与单细胞]] — 样本或细胞的降维展示、单细胞注释与 marker、细胞通讯和轨迹。

## 配方

### draft

- [[recipes/figureya-115cofactor|ChIP-seq样本相关性聚类热图]] — 对多个ChIP-seq样品的peak重叠矩阵算两两相关（pearson）并聚类，用corrplot或pheatmap重画相关性热图。
- [[recipes/figureya-59plus-geo2deg|GEO芯片差异表达与火山图]] — getGEO下载GEO芯片表达矩阵与GPL平台注释，探针转symbol、log2+分位数标准化、去离群样本后limma差异分析，输出easy_input_lim
- [[recipes/figureya-61gsva|GSVA 通路评分与组间差异]] — 把“样本×基因”表达矩阵用 GSVA 转成“样本×通路”评分，用 limma 找组间差异通路，结果可接 FigureYa39bar 画图。
- [[recipes/figureya-214kegg-hierarchyv2|KEGG三层层级富集条形图]] — 把KEGG富集结果按level1/level2/level3三层归类，画Detected/Enriched对数条形图加三层级文字标注的组合图。
- [[recipes/figureya-38pca|PCA降维置信椭圆图]] — 对表达矩阵做prcomp降维并画PCA散点，按分组着色，叠加95%/98%置信椭圆或Top贡献基因载荷箭头。
- [[recipes/figureya-53ppimodule|PPI网络模块挖掘导出]] — 把共表达基因/蛋白列表经Uniprot idmapping映射到STRING PPI，构建0/1邻接矩阵，算TOM后层次聚类+dynamicTreeCut划模块
- [[recipes/figureya-81immune-network|免疫细胞相关预后网络图]] — 由免疫细胞（或基因）矩阵算spearman相关与P值，聚类分4簇，igraph画圆形网络：点色=簇、点大小=logrank P、边色=相关正负、边粗=-log1
- [[recipes/figureya-194pyscenic|单细胞转录调控网络构建]] — 以pySCENIC为主（GRNBoost2→cisTarget→AUCell）从单细胞表达矩阵推断TF-regulon活性，复现细胞类型特异regulon、re
- [[recipes/figureya-231scscore|单细胞通路得分降维图]] — 标准Seurat流程跑t-SNE后，用Single-Cell Signature Explorer计算各细胞GO通路得分，并在降维图上按分组着色或渐变色展示通路
- [[recipes/figureya-318genesetdedotplot|单细胞通路活性差异点图]] — 用AUCell给每个细胞算通路活性得分，在各细胞类型内做两组间limma差异分析，画“通路×细胞类型”点图（颜色=logFC、大小=FDR档），顶部拼通路分类条
- [[recipes/figureya-36nsurvv3|双基因高低分组生存曲线]] — 按两个基因各自的高/低表达把样本分成4组，画KM生存曲线，图例标注各组HR（coxph）和两两logrank的显著P值。
- [[recipes/figureya-202consensusgene|双通路基因共识聚类分型]] — 对两个通路的基因做基因维度共识聚类筛出共表达基因，再按两通路中位表达把样本分四类，画共识矩阵热图+四象限散点+分型表达热图。
- [[recipes/figureya-97correlationv3|基因免疫浸润相关热图]] — 批量算基因列表中每个基因与免疫细胞矩阵的spearman相关和P值，ggplot2 geom_tile画相关热图，格内打*/**标显著性。
- [[recipes/figureya-67phastcons|基因组区域保守性曲线]] — 提取bed区域中心±5kb的phastCons bigWig信号（调Python脚本与awk汇总），画多组区域的平均保守性profile曲线。
- [[recipes/figureya-44profile|基因组区域平均信号曲线]] — 从bigWig提取信号，画两类profile：基因体统一缩放+TSS/TTS两侧flank的平均信号曲线，以及指定bed区域（如CpGi）中心两侧的信号曲线，支
- [[recipes/figureya-307cnvheatmap|基因组拷贝数变异热图]] — 读GISTIC的all_thresholded.by_genes输出，按染色体位置排布基因画CNV增益/缺失热图，列按分子亚型分块、行按染色体分块，叠加临床注释
- [[recipes/figureya-74omiccircos|基因组环状热图连线图]] — 用OmicCircos在环形染色体图上叠加多组样本信号热图轨道，并按颜色绘制基因间连线（同色互连）。
- [[recipes/figureya-83enrichment|基因集富集耦合热图]] — 对基因集两两做Fisher精确/超几何检验算富集odds ratio与FDR，取上三角画耦合热图并用符号标显著性层级。
- [[recipes/figureya-109subtypegsea-update|多亚型GSEA富集对角热图]] — 对每个亚型做“一组vs其余组”的差异分析，分别跑clusterProfiler的GSEA并挑各组top通路，再用GSVA打分画带亚型注释的对角式热图。
- [[recipes/figureya-118multiclassdeseq2|多亚型差异表达分析]] — 用DESeq2对read count矩阵做"每一亚型 vs 其余样本"的配对差异表达分析，输出各亚型差异基因表供下游富集/marker分析。
- [[recipes/figureya-18oncoplot-update|多样本基因突变瀑布图]] — 用TCGAbiolinks在线下载TCGA突变maf和临床信息，maftools::oncoplot画带临床注释的突变瀑布图，支持topN、自定义基因列表和按分
- [[recipes/figureya-293plus-binaryclassificationml|多算法二分类模型评估筛选]] — 在训练集上跑10种分类算法，再叠加RF/Lasso/Boruta特征选择、投票集成与参数调优共100+组合，在多个验证集上算AUC/准确率等指标并可视化，挑最优
- [[recipes/figureya-230immunelandscape|多算法免疫浸润组合热图]] — 把多种免疫浸润算法（TIMER/CIBERSORT/xCELL等）的得分按算法分块画成热图并纵向拼接，样本按risk score排序并加分组注释；提供pheat
- [[recipes/figureya-293machinelearning|多算法组合预后模型 C 指数比较]] — 用 10 种生存机器学习算法及其组合在训练集建模，在多个验证集计算 C 指数，画模型比较热图与条形图。
- [[recipes/figureya-45v2|多组学整合聚类分型]] — 用iClusterBayes对突变/CNV/表达等多类型组学矩阵做联合潜变量聚类，按BIC与偏差比选K，输出样本分型与特征基因供画亚型热图。
- [[recipes/figureya-14circos|多轨道基因组环形圈图]] — 用Circos（Perl程序）在环形基因组图上叠加GC含量、基因密度、表达量、SNP等多轨道及连线。
- [[recipes/figureya-5bubbles|富集与表达气泡图]] — 气泡图同时编码motif/通路富集的-logP（点大小）与对应基因表达量（填充色），跨样本对比展示。
- [[recipes/figureya-153ccgraph|层级关系同心环网络图]] — 用“圆环套圆环”的布局展示层级结构，例如基因—突变、调控因子—靶基因或物种分类丰度。
- [[recipes/figureya-149rankheatmap|差异倍数分档注释热图]] — 把logFC（或相关系数）按阈值切成5档、P≥0.05归入第6档，用ComplexHeatmap画分类热图并在格内标数值，左侧可加分组注释。
- [[recipes/figureya-66univariatecox|批量单基因Cox森林图]] — 对表达矩阵逐列特征跑单因素Cox回归，导出含HR/z/P/95%CI的cox_output.csv，再画HR=1虚线、点染P值的森林图（三种配色可选）。
- [[recipes/figureya-10chromosomev2-update|染色体特征分布图]] — 用RIdeogram在直线型染色体（核型Ideogram）上叠加数值热图轨道和形状标记，展示基因组特征分布。
- [[recipes/figureya-9heatmap|样本相关聚类热图]] — 用pheatmap画样本间相关系数热图（可加数字、分组注释色条）和基因表达双向聚类热图。
- [[recipes/figureya-253pangsea|泛癌分组GSEA富集气泡图]] — 按基因集ssGSEA得分（或单基因表达）把每个癌种样本分高/低30%两组，limma差异分析后clusterProfiler跑GSEA，画“癌种×通路”的NES
- [[recipes/figureya-55pancancer-violinv2|泛癌分裂小提琴图]] — 合并TCGA肿瘤与TCGA+GTEx正常组织，用分裂小提琴图对比某基因在各组织肿瘤vs正常的TPM分布。
- [[recipes/figureya-139tmb-titv|泛癌突变负荷与碱基谱图]] — 用base plot拼图：上层按癌种中位TMB排序的逐样本突变频率散点（含中位线），下层每样本6种碱基替换（Ti/Tv）比例条。
- [[recipes/figureya-132alteration|泛癌通路基因变异扫雷图]] — 按“基因×癌症亚型”统计各类型基因组变异（突变/扩增/缺失/融合等）的样本数，画中央色块矩阵加顶部、右侧变异类型频率条的扫雷图。
- [[recipes/figureya-215dnaage|甲基化年龄加速分析]] — 由甲基化芯片beta值经ChAMP过滤+BMIQ标准化后用wateRmelon::agep算DNA甲基化年龄，与真实年龄求差划分加速/减速组并画双向柱图。
- [[recipes/figureya-73batchcorrelation|目标基因批量相关散点图]] — 批量算一个目标基因与其余全部基因的pearson/spearman相关及P值，取正/负相关各topN，样本按目标基因表达排序后按bin取中位数画带回归线的散点小
- [[recipes/figureya-320clontypeheatmap|细胞类型间共享克隆热图]] — 统计克隆型在各细胞类型间两两共享的数量，log(1+n)转换后画对称热图，区分同质与异质克隆型分布。
- [[recipes/figureya-255time|肿瘤免疫微环境热图]] — 由5个甲基化探针PCA算MeTIL得分、tidyestimate算免疫/基质得分、GSVA算24种免疫细胞富集，拼三张注释热图展示亚型免疫景观。
- [[recipes/figureya-294hccdrug|药物靶点相关性火山图]] — 算基因集评分（示例PPS）与临床蛋白组、细胞系CRISPR CERES得分的Spearman相关，火山图筛显著靶点加散点图展示相关细节。
- [[recipes/figureya-308ihs|蛋白活性异质性评分图]] — 用weighted VIPER推断蛋白活性后，以nlme与层次聚类两种方法各算患者内异质性得分，几何平均得IHS并画排序点图。
- [[recipes/figureya-203combat|跨平台表达谱批次校正]] — 合并TCGA RNA-seq与多套GEO芯片表达矩阵，log转换统一量级后用sva::ComBat去批次效应，PCA图对比校正前后。

### ready

- [[recipes/figureya-30nomogram-update|Cox/Logistic 列线图与校准曲线]] — 把 Cox 或 Logistic 回归结果画成经典列线图和 regplot 交互式列线图，并画 5 年/8 年校准曲线与比较图。
- [[recipes/figureya-13gsea-java-update|Java GSEA 结果多通路美化图]] — 读取 Java 版 GSEA 的输出，把多个通路画进一张图：点图+条码、线图+条码、条码+热图三种样式。
- [[recipes/figureya-31lasso-update|LASSO Cox 系数路径与交叉验证图]] — 用 LASSO Cox 从候选基因中筛选预后签名，画系数路径图（标注基因顺序）和交叉验证曲线，并合成一个签名变量。
- [[recipes/figureya-138nicecalibration|Logistic 模型校准曲线与 HL 检验]] — 为二分类 Logistic 诊断模型画校准曲线，并给出 Hosmer-Lemeshow 拟合优度检验。
- [[recipes/figureya-284pairwiselogrank|三组以上 KM 曲线与两两比较表]] — 对 3 个及以上亚组画 KM 曲线，并在图中嵌入两两 log-rank 比较的 P 值表。
- [[recipes/figureya-6rhrsv2|临床亚组分析森林图]] — 把已经算好的各亚组 HR 与 95% CI（及例数、P 值）画成带表格列的临床亚组森林图。
- [[recipes/figureya-33dca-update|决策曲线与净获益分析]] — 画二分类或生存结局的决策曲线（net benefit）和 net reduction 曲线，比较多个模型的临床获益。
- [[recipes/figureya-236circgroup|分型对应关系圈状热图]] — 把多个分型（或分类变量）之间的对应关系画成圈状热图注释，直观看一致性。
- [[recipes/figureya-196panpie|分组临床分期扇形矩阵图]] — 用扇形矩阵展示不同分组在临床分期等分类变量上的构成差异。
- [[recipes/figureya-39bar|分组着色柱图与正负富集柱图]] — 场景一：各肿瘤（或样本）某指标的瀑布式排序柱图，按类别着色；场景二：GO/KEGG/GSVA 结果正负方向左右分开的发散柱图，不显著显示灰色。
- [[recipes/figureya-162boxviolin|半小提琴箱线散点组合图]] — 比较两组或多组的一个连续变量，把原始数据点、箱线统计量和小提琴密度画在一起。
- [[recipes/figureya-173fancybar|含亚组的多组均值柱图与比较]] — 画多组柱状图（mean ± se），部分大组含同色系亚组，同时做组间与亚组内比较标注。
- [[recipes/figureya-37correlationv2-update|圆形布局基因相关连线图]] — 把基因放在圆周上，两两之间用连线表示相关，连线颜色和宽度代表相关系数。
- [[recipes/figureya-92immune-gene-update|基因与免疫浸润相关性图]] — 计算一个基因与各免疫细胞浸润评分的相关，画汇总点图和单个细胞的散点图（带边缘分布）。
- [[recipes/figureya-102multipanelroc|多变量 Logistic 模型训练/测试 ROC]] — 用训练集构建多变量二分类 Logistic 模型，应用到测试集，并把训练、测试的 ROC 画在一起。
- [[recipes/figureya-76corrgram|多变量相关矩阵散点热图]] — 一张图里同时展示多变量两两相关：下三角散点+拟合线，上三角相关系数热图，对角线为变量名。
- [[recipes/figureya-25sankey-update|多层分类流向桑基图]] — 展示多层分类属性之间的交叉与流向，例如高频突变基因所属的分组，或 miRNA—靶基因关系。
- [[recipes/figureya-85timeroc|多模型时间依赖 ROC 曲线]] — 对不同拟合模型（或评分）计算并画指定时间点的时间依赖 ROC 曲线与 AUC。
- [[recipes/figureya-1survivalcurve-update|多组 KM 生存曲线与风险表]] — 用自己的生存数据画两组或多组 Kaplan-Meier 曲线，附 log-rank P 值与 number-at-risk 风险表。
- [[recipes/figureya-11bubble|富集分析对角排列气泡图]] — 把多组的 GO/KEGG 富集结果画成按对角线排列的气泡图，点大小与颜色表示基因数与显著性。
- [[recipes/figureya-59volcanov2|差异表达火山图（经典与进阶）]] — 用 limma 差异结果画经典火山图和标注选定基因的进阶火山图。
- [[recipes/figureya-143survcor-update|相关性散点叠加最佳截断四象限]] — 在两基因表达散点图上同时展示相关系数、按 log-rank 统计找到的最佳截断、四象限分组占比和 MSI/MSS 状态。
- [[recipes/figureya-228linkcor|相关热图与连线蝴蝶图]] — 用三角热图展示两组通路各自的自相关，再用连线展示一个基因与这些通路的相关（实线正、虚线负、颜色为 P 值），拼成蝴蝶图。
- [[recipes/figureya-227boxdensity|箱线图叠加密度分布图]] — 比较两组的连续指标（如药物敏感性 IC50），箱线图与密度分布叠加展示。
- [[recipes/figureya-193risktable|训练与验证集风险评分多因素森林表]] — 在训练集（TCGA）构建 riskscore，并在 GEO 验证集验证，用多因素 Cox 检验预后独立性，画上下两段的森林表。
- [[recipes/figureya-99smoothhrv2|限制性立方样条 HR 曲线]] — 用限制性立方样条（RCS）展示连续变量与风险比的非线性关系，以参考点为基线画 HR 及置信带。
- [[recipes/figureya-141risk|风险评分分布与签名基因热图联图]] — 按风险评分排序样本，联合展示评分分布、生存状态和签名基因表达热图，用竖线分高低风险组。

### archived


## 模板

### draft


### ready

- [[templates/2026-10-22-glaucoma-scrna__fig01-cns-umap--umap|CNS 细胞类型 UMAP]]
- [[templates/figureya-1survivalcurve-update--km-curve|KM 生存曲线与风险表]]
- [[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar|SHAP 条形图（含环形 inset）]]
- [[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--radial-bar|SHAP 环形贡献图]]
- [[templates/2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm|SHAP 蜂群图]]
- [[templates/figureya-59volcanov2--volcano|bulk 差异火山图（分级着色）]]
- [[templates/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap|marker 特征 UMAP 小多图]]
- [[templates/figureya-6rhrsv2--forest|亚组分析森林图]]
- [[templates/2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin|分组小提琴图（含统计标注）]]
- [[templates/2026-10-22-scp-example__fig02-ring--ring|分组构成同心环图]]
- [[templates/2026-10-22-scp-example__fig07-dot--dot|分组构成点图]]
- [[templates/2026-10-22-scp-example__fig04-rose--rose|分组构成玫瑰图]]
- [[templates/2026-10-22-scp-example__fig05-trend--trend|分组构成趋势图]]
- [[templates/2026-10-22-scp-example__fig06-area--area|分组构成面积图]]
- [[templates/2026-10-22-scp-example__fig03-pie--pie|分组构成饼图]]
- [[templates/2026-10-22-scp-example__fig11-chord--chord|分组流向和弦图]]
- [[templates/2026-10-22-scp-example__fig10-sankey--sankey|分组流向桑基图]]
- [[templates/2026-10-22-scp-example__fig08-group-heatmap--heatmap|分组热图（多分组注释）]]
- [[templates/2026-10-22-scp-example__fig16-cell-density--ridge|分组表达密度图]]
- [[templates/2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap|分组表达点阵热图]]
- [[templates/2026-10-22-scp-example__fig09-bar--bar|分组计数柱图]]
- [[templates/2026-10-22-scp-example__fig13-upset--upset|多集合交集 UpSet 图]]
- [[templates/2026-10-22-scp-example__fig12-venn--venn|多集合交集维恩图]]
- [[templates/2026-10-19-regression-stability__fig03-density-panel--density-scatter|密度散点与边缘分布]]
- [[templates/2026-10-22-scp-example__fig01-volcano--volcano|差异表达火山图]]
- [[templates/2026-10-22-scp-example__fig14-feature-heatmap--heatmap|特征表达热图]]
- [[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]]
- [[templates/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow|细胞比例堆叠流带图]]
- [[templates/2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap|细胞相似度热图]]
- [[templates/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot|细胞类型 × 基因气泡点图]]

### archived


## 分析家族

### ready

- [[methods/rna-velocity|RNA 速度分析]] — 利用 spliced/unspliced 计数推断转录动态方向；scVelo 分支在批准的隔离 NumPy 1.23.5 环境完成真实推断，全量 SCP 算法等价未验证。
- [[methods/batch-integration|单细胞批次整合]] — 在保留生物差异的前提下对齐样本/技术批次，产出整合嵌入与聚类，供跨样本比较。
- [[methods/cell-clustering|单细胞聚类分析]] — 在低维嵌入上构建邻居图并划分 cluster；cluster 是分析单位，不是细胞类型。
- [[methods/cell-quality-control|单细胞质量控制]] — 按显式阈值计算逐细胞 UMI、基因数与线粒体/核糖体比例，标记 Pass/Fail，不把 QC 指标当生物学分组。
- [[methods/dimensionality-reduction|单细胞降维分析]] — 在标准化/缩放后的表达上计算 PCA 与 UMAP，为聚类、可视化和轨迹提供低维表示。
- [[methods/reference-mapping|参考图谱映射]] — 把查询细胞映射到参考标签并返回预测分数；Seurat 标签转移已验证，UMAP 投影分支未通过。
- [[methods/doublet-detection|双细胞检测]] — 按样本识别双细胞；scDblFinder 分支在批准公开用例与直接 scDblFinder 结果一致（非全量 SCP 等价），DoubletFinder 等其他分支未运行。
- [[methods/regression-resampling-evaluation|回归模型的重采样评估与折外预测]] — 汇总已有折外回归预测，计算逐折 RMSE/MAE/R2/r；不训练模型、不生成重采样。
- [[methods/shap-explanation|基于 SHAP 的模型解释]] — 对既定模型输出作 SHAP 归因，输出汇总表和逐样本贡献表；不训练、不划分数据。
- [[methods/gene-set-scoring|基因集与通路签名打分]] — 按命名基因集给每个细胞打相对签名分数，用于描述状态差异；分数不是通路活性或富集显著性。
- [[methods/gene-set-enrichment|基因集富集分析]] — 用显式基因列表和背景检验基因集过代表（ORA），GO/KEGG 是资源，GSEA 是另一种策略且本页未实现。
- [[methods/differential-expression|差异表达分析]] — 在明确对比组之间检验基因表达差异，输出效应量、p 值与阳性比例；细胞级 p 值不等于样本级推断。
- [[methods/trajectory-inference|拟时序与轨迹推断]] — 在低维嵌入上连接细胞群，推断 lineage 与 pseudotime；轨迹是模型假设，不是真实时间。
- [[methods/dynamic-feature-analysis|拟时序动态特征分析]] — 沿 pseudotime 拟合每个特征的平滑趋势，输出变化显著性、解释度和峰/谷时间。
- [[methods/cell-type-annotation|细胞类型注释]] — 综合参考标签与 marker 集合给细胞分配类型；SingleR 分支在批准公开用例与直接 SingleR 结果一致（非全量 SCP 等价），青光眼 marker 手工注释尚未函数化。

## 组合流程

### ready

- [[methods/asthma-lactylation-workflow|乳酸化与代谢研究分析流程]] — 保留来源步骤、参数与分组差异的研究流程；共同分析引用现有家族，所有来源分支未重跑。
- [[methods/uc-ptm-workflow|修饰分型与模型分析流程]] — 保留来源步骤、参数与分组差异的研究流程；共同分析引用现有家族，所有来源分支未重跑。
- [[methods/scop-workflows|单细胞与空间组学工作流]] — 12 份固定版本上游 Rmd 流程的输入、执行边界和方法链；未 Knit，未作为 L1 配方运行。
- [[methods/scp-standard-workflow|单细胞标准预处理、降维与聚类]] — SCP 标准预处理、降维与聚类的组合流程记录；单步方法见质量控制、降维、聚类和整合家族。
- [[methods/scrna-preprocess-doublet-qc-harmony|单细胞预处理、批次校正与聚类]] — 青光眼课题的预处理、QC、双细胞与 Harmony 组合流程记录；单步方法见对应家族。
- [[methods/uc-spatial-workflows|空间转录组分支与推断边界]] — 区分原空间探索、整理版主线、历史 CellTrek/伪超分辨与 RCTD+CellChat 最终来源及其后处理，保留算法替代的真实含义。

## 技术资料

### ready

- [[methods/scp-local-source|SCP 源码本地化]] — SCP v0.5.6 源码本地化与加载器资料；不是可执行分析，也不是独立方法家族。
- [[methods/scp-visualization-interface|SCP 绘图函数与图接口映射]] — SCP 绘图函数到 Wiki 图表接口的映射与适配资料；不是分析方法。
- [[methods/asthma-lactylation-source-catalog|乳酸化研究脚本来源索引]] — 159 份研究代码、154 个不同字节版本的来源及去重索引；只编译知识，未运行。
- [[methods/figureya-multilanguage-assets|交互绘图与多语言工具索引]] — 登记 FigureYa 压缩包中 10 个非 Rmd 工具的原始入口、输入与未运行边界；另提示 R/Python 混合模块，不能作为可执行分析推荐。
- [[methods/uc-ptm-source-catalog|修饰研究脚本来源索引]] — 132 份研究代码、90 个不同字节版本的来源及去重索引；只编译知识，未运行。
- [[methods/scp-cellqc-doublet|单细胞 QC 与双细胞检测]] — SCP QC 与双细胞检测的原始脚本和作者实现记录；分析问题见质量控制与双细胞检测家族。
- [[methods/scop-analysis-guide|单细胞与空间分析方法导航]] — 将 scop 候选实现映射到既有 13 个规范家族，并整理通信、调控、空间、ATAC、反卷积等新增领域；本机未运行。
- [[methods/scop-source-catalog|单细胞与空间组学来源索引]] — 固定 scop 0.9.2：362 个导出、81 个绘图入口与 12 个上游流程；完整来源导航，本机未运行。
- [[methods/scop-visualization-guide|单细胞与空间绘图入口导航]] — 81 个 scop 原生绘图入口的图形类别、声明输入与上游结果边界；全部本机未运行，不继承 SCP 图样或回放。
- [[methods/scp-source-catalog|单细胞全库来源与入口索引]] — 142 个导出及 238 个源码定义的逐项来源核对；链接规范家族与原生绘图入口，区分来源归档、实现运行和资料确认。
- [[methods/scp-integration|单细胞多样本整合]] — SCP 单细胞多样本整合的原始脚本与作者实现记录；分析问题见批次整合家族。
- [[methods/scp-de-enrichment-dynamic|单细胞差异表达、基因集富集与动态特征]] — SCP 差异表达、富集和动态特征的原始脚本与作者实现记录；分析问题见四个对应家族。
- [[methods/scrna-marker-annotation|单细胞标记基因注释与聚类检查]] — 青光眼 scRNA 课题的 marker 注释与聚类检查实现记录；分析问题见细胞类型注释与聚类家族。
- [[methods/scp-viz-statplots|单细胞统计与相关绘图入口]] — SCP 原生绘图实现的对象输入、上游链路、独立闭包及逐形态证据；资料确认不授予额外分支验证，不作为新分析家族。
- [[methods/scp-annotation-projection|单细胞自动注释与参考投影]] — SCP 自动注释与参考投影的原始脚本和作者实现记录；分析问题见细胞类型注释与参考映射家族。
- [[methods/scp-viz-heatmaps|单细胞表达与动态热图入口]] — SCP 原生绘图实现的对象输入、上游链路、独立闭包及逐形态证据；资料确认不授予额外分支验证，不作为新分析家族。
- [[methods/scp-trajectory-velocity|单细胞轨迹推断与 RNA 速度]] — SCP 轨迹与 RNA 速度的原始脚本和作者实现记录；分析问题见轨迹、速度和动态特征家族。
- [[methods/scrna-pathway-signature-ensemble|单细胞通路签名打分与组间比较]] — 青光眼课题的通路签名打分与组间比较实现记录；五种分数相加是课题特定组合，不是通用标准。
- [[methods/scp-viz-dimplots|单细胞降维与表达绘图入口]] — SCP 原生绘图实现的对象输入、上游链路、独立闭包及逐形态证据；资料确认不授予额外分支验证，不作为新分析家族。
- [[methods/local-omics-analysis-guide|组学课题方法去重与选择]] — 按方法理论关联原语言复用代码：自定义 DotPlotScores/动态曲线、模型评价和依赖适配；验证限定到具体分支。
- [[methods/local-omics-visualization-guide|课题绘图依赖与自定义改造]] — 依赖原生图、自定义函数与预计算 ROC 分流；复用已有 SCP 闭包，逐分支保留依赖和验证边界。
- [[methods/scp-viz-model-overlays|轨迹富集与网络绘图入口]] — SCP 原生绘图实现的对象输入、上游链路、独立闭包及逐形态证据；资料确认不授予额外分支验证，不作为新分析家族。

## 待分类方法

## 来源

- [[sources/figureya|FigureYa 医学科研绘图模块库]]
- [[sources/figureya-archive-20251223|压缩包可视化模块增量来源]] — 本地压缩包330项盘点：286项复用旧入口，33项新增或差异Rmd，10项多语言工具，1项贡献模板。

## 接口

- [[interfaces/shap-summary|SHAP 特征贡献汇总表]]
- [[interfaces/shap-samples|SHAP 逐样本值表]]
- [[interfaces/render-umap-groups|UMAP 坐标与分组表]]
- [[interfaces/render-umap-feature-long|UMAP 坐标与特征长表]]
- [[interfaces/bulk-de-table|bulk 差异表达结果表]]
- [[interfaces/survival-time-event-group|个体随访生存表]]
- [[interfaces/subgroup-effect-table|亚组效应量汇总表]]
- [[interfaces/render-category-points|分组数值与显式抖动表]]
- [[interfaces/render-group-heatmap|分组热图长表]]
- [[interfaces/render-grouped-values|分组细胞级数值表]]
- [[interfaces/regression-fold-metrics|回归模型逐折评估指标表]]
- [[interfaces/regression-predictions|回归模型逐样本验证预测表]]
- [[interfaces/render-de-results|差异表达结果表]]
- [[interfaces/highlight-gene-sets|待标注基因与所属基因集]]
- [[interfaces/render-feature-heatmap|特征×细胞表达矩阵长表]]
- [[interfaces/render-correlation-heatmap|相似度矩阵长表]]
- [[interfaces/render-dotplot-long|细胞类型 × 基因点图表]]
- [[interfaces/render-cell-proportions|细胞类型比例表]]
- [[interfaces/render-cell-metadata|细胞级分组元数据表]]
- [[interfaces/render-cell-linkage|细胞级多维流向长表]]
- [[interfaces/render-cell-feature-values|细胞级特征值长表]]
- [[interfaces/render-cell-membership|细胞级集合成员表]]
- [[interfaces/render-scatter-rgb|配对数值散点的预设颜色表]]
- [[interfaces/render-group-summaries|预计算分组分布摘要表]]
- [[interfaces/render-box-summaries|预计算分组箱线与均值表]]
- [[interfaces/render-marginal-bars|预计算边缘分布条表]]

## 图型

- [[chart-types/area|area]]
- [[chart-types/bar|bar]]
- [[chart-types/beeswarm|beeswarm]]
- [[chart-types/boxplot|boxplot]]
- [[chart-types/bubble|bubble]]
- [[chart-types/calibration|calibration]]
- [[chart-types/chord|chord]]
- [[chart-types/circos|circos]]
- [[chart-types/decision-curve|decision-curve]]
- [[chart-types/deg-table|deg-table]]
- [[chart-types/density|density]]
- [[chart-types/density-scatter|density-scatter]]
- [[chart-types/dot|dot]]
- [[chart-types/dotplot|dotplot]]
- [[chart-types/errorbar|errorbar]]
- [[chart-types/forest|forest]]
- [[chart-types/gsea-curve|gsea-curve]]
- [[chart-types/heatmap|heatmap]]
- [[chart-types/ideogram|ideogram]]
- [[chart-types/km-curve|km-curve]]
- [[chart-types/lasso-path|lasso-path]]
- [[chart-types/network|network]]
- [[chart-types/nomogram|nomogram]]
- [[chart-types/pca|pca]]
- [[chart-types/pie|pie]]
- [[chart-types/radial|radial]]
- [[chart-types/radial-bar|radial-bar]]
- [[chart-types/ridge|ridge]]
- [[chart-types/ring|ring]]
- [[chart-types/risk-plot|risk-plot]]
- [[chart-types/roc|roc]]
- [[chart-types/rose|rose]]
- [[chart-types/sankey|sankey]]
- [[chart-types/scatter|scatter]]
- [[chart-types/spline-hr|spline-hr]]
- [[chart-types/stacked-bar-flow|stacked-bar-flow]]
- [[chart-types/trend|trend]]
- [[chart-types/umap|umap]]
- [[chart-types/upset|upset]]
- [[chart-types/venn|venn]]
- [[chart-types/violin|violin]]
- [[chart-types/volcano|volcano]]
- [[chart-types/waterfall|waterfall]]

## 课题


## 版式

### pending_signoff


### pending_template

- [[layouts/2026-10-22-glaucoma-scrna__fig01-cns-umap|CNS 细胞类型 UMAP（GSE251716）]]
- [[layouts/2026-10-22-scp-example__fig08-group-heatmap|GroupHeatmap (CellType / SubCellType)]]
- [[layouts/2026-10-22-glaucoma-scrna__fig02-marker-feature-umap|marker 特征 UMAP 小多图（GSE251716）]]
- [[layouts/2026-10-19-regression-stability__fig03-density-panel|六模型验证预测：密度散点与边缘分布]]
- [[layouts/2026-10-22-glaucoma-scrna__fig06-pathway-violin|分组小提琴与统计标注（GSE251716）]]
- [[layouts/2026-10-22-scp-example__fig11-chord|分组流向和弦图]]
- [[layouts/2026-10-22-scp-example__fig10-sankey|分组流向桑基图]]
- [[layouts/2026-10-22-scp-example__fig16-cell-density|分组表达密度图]]
- [[layouts/2026-10-22-scp-example__fig17-group-heatmap-dot|分组表达点阵热图]]
- [[layouts/2026-10-22-scp-example__fig09-bar|分组计数柱图]]
- [[layouts/2026-10-19-regression-stability__fig04-boxplot-panel|多模型逐折指标：箱线、散点与均值]]
- [[layouts/2026-10-22-scp-example__fig13-upset|多集合交集 UpSet 图]]
- [[layouts/2026-10-22-scp-example__fig12-venn|多集合交集维恩图]]
- [[layouts/2026-10-22-scp-example__fig01-volcano|火山图：Endocrine vs 其余细胞（SCP 示例）]]
- [[layouts/2026-10-22-scp-example__fig14-feature-heatmap|特征表达热图]]
- [[layouts/2026-10-22-scp-example__fig04-rose|玫瑰图组成：计数 dodge（SCP 示例）]]
- [[layouts/2026-10-22-scp-example__fig02-ring|环形组成图（SCP 示例）]]
- [[layouts/2026-10-22-scp-example__fig07-dot|组成点阵图（SCP 示例）]]
- [[layouts/2026-10-22-scp-example__fig05-trend|组成趋势图：计数（SCP 示例）]]
- [[layouts/2026-10-22-scp-example__fig06-area|组成面积图：百分比（SCP 示例）]]
- [[layouts/2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow|细胞比例堆叠与流带（GSE251716）]]
- [[layouts/2026-10-22-scp-example__fig15-cell-cor-heatmap|细胞相似度热图]]
- [[layouts/2026-10-22-glaucoma-scrna__fig03-topjournal-bubble|顶刊样式气泡点图（GSE251716）]]
- [[layouts/2026-10-22-scp-example__fig03-pie|饼图组成（SCP 示例）]]

### ready


### archived

- [[layouts/2026-10-19-regression-stability__fig01-density-grid|六模型验证预测密度散点组图（整图存档）]]
- [[layouts/2026-08-17-shap-feature-mechanism__fig01-shap-a-f|双模型 SHAP 特征贡献组图]]
- [[layouts/2026-10-19-regression-stability__fig02-metric-boxplots|多模型 RMSE、R² 与 MAE 箱线组图（整图存档）]]
