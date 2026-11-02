# Python guard的发行包名/导入模块名，以及新的独立证据

源`R/SCP-workflow.R:1600`调用`check_Python('scvi-tools')`，但实际导入模块名是`scvi`；`R/SCP-analysis.R:5910,6172`的`magic-impute`对应`magic`。原check_Python按发行包/conda清单查，你替换成py_module_available却直接使用发行包名，会在未来已经安装正确依赖的课题误报缺包。guard须显式区分发行包名与导入模块名，保留参数版本/声明和no-install边界，不用一条空Python清单忽略它们。请核对源全部check_Python与Python函数内import，记录映射；当前机器缺包无需安装，也不能用假引擎给算法verified。

Codex独立presence-only证据：A/codex-python-presence.json。现有`E:/research-wiki-env/bio-python/Scripts/python.exe`可用numpy/pandas，但anndata、scanpy、scvelo、scvi、scanorama、bbknn、leidenalg、palantir、wot、phate、pacmap、trimap、largevis、scrublet、doubletdetection、magic、cellrank的module spec和对应distribution metadata均不存在。仅该明确环境的依赖缺口，不声称其他环境也缺。它不是实际导入或算法验证；可写精确not_run，不再用unprobed/已装误标。

另一独立证据A/codex-extraction-ast.json：固定源238个函数/ggproto顶层定义与coverage/extracted的238条逐一AST相同，无缺失/额外/截断。这只批准原始提取完整性，不能授予derived模块闭包/算法/模板验证。

本文件不是新暂停点；在完成pass5主要问题和全量Wiki实际入库后复核，避免只调辅助细节又无主体交付。

澄清前轮审查措辞：正式parser确实保留兼容`python: [string]`，所以该字段本身不导致schema invalid。问题是references/minimal-runtime.md第58行明确要求Python依赖纳入required_packages/optional_packages的Python语言键，不另造第二套必需包事实；前端依赖列表与调用条件必须同源显示。请按此实际规则修正，不为Codex前轮“不被parser读取”的错误措辞改解析器。
补充R presence证据A/codex-r-presence.json：当前声明89个包中59在既有隔离R库/站点库有metadata，30缺失；这也仅为presence/version，不是load或算法通过。缺包名单含AUCell/UCell等，全部保持精确not_run，不安装。
最新独立公开入口证据A/codex-module-probe-20261025T163849.json（以实际文件为准）：MDS公开矩阵调用与原生嵌入对照、NMF公开矩阵调用与原生embeddings/loadings对照、嵌套source、加载NMF后再调MDS均通过；输入对象未变。search_unchanged仍False，不能把其写为无副作用/公共会话验收通过。上轮163205快照仍公开调用失败，保留RED。改名/自造topLevelEnvironment并非必要；显式do.call的envir=私有环境解决语言调用问题（独立语言小复现A/scripts/codex_s3_call_review.R，仅解释R分派，不当算法证据）。你当前已实现此修复，不需重复调这个点。

原生数据实查A/codex-fixture-inventory.json：pancreas_sub有RNA/spliced/unspliced和PCA/UMAP，无graphs、无tools；ifnb_sub/panc8_sub无现成reduction/graphs/tools。RNA velocity的输入层并不缺失，缺的是Python后端与尚未生成的velocity结果；GraphPlot的源fixture没有RNA.nn邻接，坏signature和缺上游图要分别写，不能捏造已有结果。

编译笔记要按分支修正文义，而非追加通用参数块。现有dimensionality-reduction的通用输入“标准化、HVF、缩放”适合部分PCA流程，却不能直接当NMF的输入：NMF需要非负矩阵，不能传含负值的z-score。每个具体分支明确输入对象/slot/方向、单位与前提。RecoverCounts是已知归一化机制下的反推，不能泛称恢复真实原始计数；RNA速度、拟时间不能据图形/默认根给生物学方向结论。导入新方法后应更新这些编译判断及实现选择，不堆成一个来源一页。

许可证文件随独立复制保留：请把固定源LICENSE.md的正确GPL文本和必要归属纳入各独立模块的清单（可有去重存档，但复制清单自身需要能带走），不要只在JSON写GPL却保留MIT或缺归属。原始函数字节只读；code/fns被命名空间/资源定位改过的文件不能仍以“verbatim copy”冒充原件，要明确derived copy并指向原source hash。
## 本轮首要交付：全量实际入库，不再只有生成器调试
上一轮进程已不在，最后事件16:49:35UTC为后端连接失败。没有返回报告；不重复启动并发者。继续同一个wakeful-ravioli。
先读full-library-plan.md与本审查，恢复实际文件。用户再次“继续”，全部SCP方法及全部可视化范围不变。**B/wiki从初始快照至今所有方法页仍未更新。请本轮先完成整合脚本和真实页面/资产，不要再用一整轮只调S3/一个绘图案例。**公开MDS/NMF和嵌套/双模块已经独立对照通过，不需要继续重新证明这几个点。保留精确未通过的副作用/其他分支，缺包不安装。

### 先纠正语义映射
- coverage/exports.json的RunPAGA、RunPalantir、RunWOT目前canonical_family=rna-velocity，是错误分类。PAGA簇图连通、Palantir扩散拟时间/命运、WOT时间点间最优传输各有真实输入假设，归合适的轨迹/动态家族，RNA velocity保留SCVELO等真实速度推断，不能以都通过Python就混为一类。
- RecoverCounts的canonical_family=cell-quality-control也不对。它是已知归一化模型下的计数反推，按独立分析目的可新建draft count-recovery等规范家族，purpose沿现有预处理与质量控制词表。不是新taxonomy，不把所有归一化矩阵宣称可恢复原始观测。
- compute_velocity_on_grid只是可视化辅助网格计算，随VelocityPlot闭包/技术目录，不记RNA速度分析verified；isOutlier为QC的MAD子步骤，不新造“检验家族”。

### 立即整合到隔离Wiki（本轮前半必须有实物）
1. 查现有规范家族与既有成熟最小core（monocle2/3、ORA、双细胞等已在Wiki，优先复用）。将所有分析导出/具体后端加实际入口/可复制清单/实现选择/参数与输入输出语义/精确当前状态；不同算法独立implementation，不把泛型默认缺包分支继承某个已通过后端。现有source、user、status、id不改。新增code使旧收据stale须诚实保留并后半真实重跑，不篡改收据或验证器。
2. 22可视化入口与具名结构全部有Wiki可发现的真实代码资产和契约。可用一个正式scaffold的technical目录及子模块清单配已有scp-visualization-interface链接，单个孤立coverage路径不够；已有模板链接复用，新图真实native来源可生成画廊draft，未签核不scaffold模板/不ready。没有输入的给完整代码与准确缺口，不用占位骨架。
3. 剩余helper/environment/resource/reexport有真实归属/源码指针和分类理由，不强行变analysis；142导出映射到具体Wiki页/分支/资产/原件/验证。286具名选项给具体运行/未运行范围，不用一例覆盖全部。
4. 使用官方scaffold和隔离config创建新页；编译说明简洁，有选择判断和科学边界。原文件(source/original_code)字节、user/status/id保持；页面不要复制长篇原码或一来源一分析家族。
5. 官方runtime解析/方法implementation状态/CLI check-entry与lint可用，不改parser使错误资产过关。流程/技术资料不冒充分析推荐。模板/关系直接可接有真实接口和证据。

### 后半验证和记录
先完成上面实质入库，再按影响范围补必要真实验证。每次run单独稳定路径保存代码、命令、输入/输出hash、失败证据；不rmtree抹证据、不以不报错/all(empty)授passed。官方算法与portability证据要绑定相应家族路径和entry。
Codex新增原生轨迹参考在E:/research-wiki-env/work/codex-scp-native-trajectory：Slingshot(show_plot=FALSE)在真实pancreas成功输出3个lineages、原输入不变，完整Seurat参考rds已保存；DynamicPlot(Nnat,Lineage1)与DynamicHeatmap(6个真实marker,Lineage1,split_method=hclust)真实参考PNG/SVG成功。CellDimPlot原生lineages叠加在当前环境报grobs list matrix，保持原始失败，不伪造成功/不以任意重画替换。初轮harness result变量作用域错误另留，不当算法失败。可拿这些现成参考做提炼版真实比较。

请同步progress/result/verification-matrix/source-map与机器coverage，明确入库完成/可运行/未验证/作者确认分别计数。不是把首轮盘点再贴一次。只写B，现有formal fig17 ready由Codex拥有，不覆盖。仍不安装、不用任何子代理、不访问paper-harness、不写正式Wiki。2400秒有界持续执行，前半先交付全部实际Wiki资产，Codex独立审查后再正式合并；无需用户再说继续。