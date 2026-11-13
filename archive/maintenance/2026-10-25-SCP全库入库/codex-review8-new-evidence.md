# 第7轮进行中补充的只读证据（不要重复旧盘点）

1. `A/codex-method-states-isolated-20261026T062352.json`为上一轮结束后的独立快照，仍3个ready_for_use家族、4 verified、15 invalid、79 not_run；不是旧06:07的中间状态。机器provider不认可报告声称的“8 passed均有效”。按本轮真实修复再验收。
2. `B/codex-legacy-verified-replay-map.json`已列13个旧verified分支的实际入口/receipt/command/inputs/outputs，便于恢复。运行时须把旧driver适配到隔离资产/复制清单，不能运行formal代码再把结果写成B执行。
3. `A/codex-r-additional-presence.json`补充实查：sva3.56.0在站点库存在，uwot0.2.5在隔离库存在，MASS7.3-65存在；GSVA/MAST/DESeq2/largeVis/RcppML未装。metadata-only，非算法验证。旧报告说sva缺失错误；SCP RunLargeVis实际用uwot::lvish，不能以Python largevis或R largeVis缺失跳过。
4. 旧`coverage/wiki-map.json`中helpers有“归属见consumers”却无consumers字段/源码路径，GeneConvert与PrepareDB两个**函数**被写成“包数据资源随resources携带”，page=null。142行枚举不等于142个真实去向；应区分资源准备函数与数据，给真实source/所属模块/消费者列表或明确排除理由。状态从正式provider派生，不能把旧临时case里的passed数组当当前算法可用。
5. 原生矩阵方向要逐入口写准：RunMDS.default内部t(object)后算距离；RunNMF.default用特征×观测分解；RunLargeVis.default直接uwot::lvish(X=object)，行是观测。不能给这些入口统一写“矩阵”而不说明方向。NMF允许非负连续表达，无需为它先跑RecoverCounts。PAGA/Palantir可用于截面数据，不能笼统写“无时间标注单点数据均不适用”；WOT才依赖真实时间点。
6. 原始source字节保护与提取AST保真是不同证据。Codex证明238个AST相同；若要说逐字节相同，另核对原始函数块与提取文件行尾/编码（Windows写文本可能转换CRLF）。derived code/fns有命名空间/资源等改动，不冒充原件。

这些补充不要求暂停第7轮；优先完成原审查和既有能力恢复。当前不部署，不安装，不伪造签核。

## v3生成器进行中的静态审查点（需真实测试确认）
当前analyze-symbols.R的walk只遍历call的参数e[[2..]]，没有把一般调用的head函数符号加入uses，也没递归处理外层调用的命名空间head。已实测当前fn-ast.json的RunMDS.default.uses不含cmdscale、dist、CreateDimReducObject、as_matrix（源函数明明调用它们）。v3据uses建立bound_syms与调用BFS，会漏掉必要lazy imports和内调用。请先用公开MDS/一个plot实际拷贝调用验证，不因AST存在就声称最小依赖正确；如仍存在则修正walker并重建一次，不需重写算法。原始NAMESPACE映射中CreateDimReducObject已正确指向SeuratObject，不要误改为整个Seurat。

## 06:51 UTC 新鲜独立复现（优先）

普通call head已在14:44版加入uses，不再把这一点当未修。外层`pkg::fn(...)`的head仍需递归审查。

独立命令：`D:/anaconda/python.exe -X utf8 A/scripts/codex_module_probe.py`。证据`A/codex-module-probe-20261026T065106.json`，真实拷贝v3的MDS/NMF清单文件至`E:/research-wiki-env/work/codex-scp-full-probe-20261026T065106`。全部79清单形式有效，但MDS source/default/嵌套driver和NMF公开调用均报`invalid first argument`，input unchanged=true。R进程退出0只是脚本捕获错误，绝不算通过。

定位：生成的`.lazy_sym`执行`delayedAssign(SYM,...)`时用`substitute`将SYM替成as.name(sym)，而`delayedAssign`的第一个参数须为字符串（例如`"cmdscale"`），不是未绑定函数符号。请用真实source公开入口确认并修复此加载层，不改算法。修复后重新运行对应probe/实际case，保留RED证据。

## 新增原生实际对照，可复用而非再造数据

- `E:/research-wiki-env/work/codex-scp-native-largevis/largevis-native.rds`及json：原RunLargeVis.default、uwot0.2.5；40观察×60真实基因，perplexity3/neighbors10/epochs100/n_threads1/n_sgd_threads1/seed11，真实数值结果和输入不变通过。输入是A/native-oracles/real-counts-subset.rds转置（uwot行=观察）。只是原生软件参考，尚不批准提炼入口。
- `E:/research-wiki-env/work/codex-scp-native-fr/fr-native.rds`及json：原RunFR.default、igraph2.1.4；显式FindNeighbors生成的50细胞真实SNN邻接，经SeuratObject::as.Graph并设assay.used='RNA'，ndim2/niter100/seed11通过，图权重不变。普通matrix同入口会在object@assay.used报错；因此不能泛称default支持任意邻接矩阵。该函数是Fruchterman-Reingold力导向图布局，不是社区检测。对应A/scripts/codex_native_fr_oracle.R为只读测试，不是生产实现。

## 07:04 UTC 修后复测与尚存证据问题

新版lazy字符串修复后，Codex重跑公开MDS/NMF、嵌套driver、同环境先后加载均已数值通过（A/codex-module-probe-20261026T070318.json）。input_unchanged=true。**search_unchanged仍false，多项package .onLoad options改变**。这是新鲜结果，不是旧v2结论。现entry没有在成功/异常退出恢复调用前search/options；必须满足正式AGENTS与minimal-runtime明确要求。独立性和算法数值成功不授予无副作用结论。测试harness在调用后detach不等于入口自身恢复；要用公开模块不包额外cleanup独立验证。

`scripts/run-iso-case.py`的alg_state判定仍可仅凭input_unchanged/search_restored等通用true就passed；无checks时甚至有output_digest就passed，注释反而声称空检查永不通过。普通对象存在/哈希不是原生算法或可视化对照。`coverage/cases/GroupHeatmap.json`的checks中"compared vs ..."只是自由文本，driver并无相应比较实现，却被复制成成功收据的checks。没有真的做过的视觉/数值比对不可写成已比较；需实际oracle比较及结果，或准确改为未运行/待目视。纯绘图只能记录绘图/回放范围，不冒充分析算法。

修后第二次source-only独立审查：`A/codex-module-load-20261026T070334.json`，79/79 loaded、0陈旧快照。仅source就改变search或options的8模块为cellcorheatmap/celldimplot/cellstatplot/groupheatmap/runmonocle2/runmonocle3/runslingshot/statplot。这尤其说明轨迹**算法核心**仍在source时求值可选plot闭包的ggproto等，延迟导入符号仍不足以实现核心/图分离。纯source通过不等于算法或独立性验收，报告应分开。

现有可视化case与原生reference常不是同参数：GroupHeatmap的13基因/nlabel0/8×6原生结构控制 vs case的2基因/默认label/9×7，不能写成已完成等价比较。GraphPlot当前case是手造4节点，而已有真实50细胞184权重图控制。合成小图可用于工程冒烟，但必须标清，不能说用了真实原始图数据。RunSlingshot case设置start=Alpha/prefix=Lineage，而原生control未设置start/prefix；需同参数重跑原生或匹配现有控制，不能拿3lineage数相等替代数值/成员/拟时对照。

07:09 UTC真实旧ID审查：`A/codex-impl-identities-20261026T070940.json`。三个旧verified实现被同名新模块upsert覆盖入口并移除了verification：QC/scp-runcellqc（旧code/analysis.R:run_cell_quality_control）、评分/scp-cellscoring（旧code/analysis.R:run_gene_set_scoring）、映射/scp-runseuratmap（旧code/analysis.R:run_reference_mapping）。旧代码实际还存在。保留成熟旧入口/ID/receipt，新的广泛原生分派另加无冲突ID（若确实增加能力），不要让同名模块覆盖旧verified能力。即便额外代码使旧family收据过期，仍需最终资产真实重跑恢复，不允许删旧验证引用后说无回归。
