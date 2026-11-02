# Python guard的发行包名/导入模块名，以及新的独立证据

源`R/SCP-workflow.R:1600`调用`check_Python('scvi-tools')`，但实际导入模块名是`scvi`；`R/SCP-analysis.R:5910,6172`的`magic-impute`对应`magic`。原check_Python按发行包/conda清单查，你替换成py_module_available却直接使用发行包名，会在未来已经安装正确依赖的课题误报缺包。guard须显式区分发行包名与导入模块名，保留参数版本/声明和no-install边界，不用一条空Python清单忽略它们。请核对源全部check_Python与Python函数内import，记录映射；当前机器缺包无需安装，也不能用假引擎给算法verified。

Codex独立presence-only证据：A/codex-python-presence.json。现有`E:/research-wiki-env/bio-python/Scripts/python.exe`可用numpy/pandas，但anndata、scanpy、scvelo、scvi、scanorama、bbknn、leidenalg、palantir、wot、phate、pacmap、trimap、largevis、scrublet、doubletdetection、magic、cellrank的module spec和对应distribution metadata均不存在。仅该明确环境的依赖缺口，不声称其他环境也缺。它不是实际导入或算法验证；可写精确not_run，不再用unprobed/已装误标。

另一独立证据A/codex-extraction-ast.json：固定源238个函数/ggproto顶层定义与coverage/extracted的238条逐一AST相同，无缺失/额外/截断。这只批准原始提取完整性，不能授予derived模块闭包/算法/模板验证。

本文件不是新暂停点；在完成pass5主要问题和全量Wiki实际入库后复核，避免只调辅助细节又无主体交付。

澄清前轮审查措辞：正式parser确实保留兼容`python: [string]`，所以该字段本身不导致schema invalid。问题是references/minimal-runtime.md第58行明确要求Python依赖纳入required_packages/optional_packages的Python语言键，不另造第二套必需包事实；前端依赖列表与调用条件必须同源显示。请按此实际规则修正，不为Codex前轮“不被parser读取”的错误措辞改解析器。
补充R presence证据A/codex-r-presence.json：当前声明89个包中59在既有隔离R库/站点库有metadata，30缺失；这也仅为presence/version，不是load或算法通过。缺包名单含AUCell/UCell等，全部保持精确not_run，不安装。
最新独立公开入口证据A/codex-module-probe-20261025T163911.json（以实际文件为准）：MDS公开矩阵调用与原生嵌入对照、NMF公开矩阵调用与原生embeddings/loadings对照、嵌套source、加载NMF后再调MDS均通过；输入对象未变。search_unchanged仍False，不能把其写为无副作用/公共会话验收通过。上轮163205快照仍公开调用失败，保留RED。改名/自造topLevelEnvironment并非必要；显式do.call的envir=私有环境解决语言调用问题（独立语言小复现A/scripts/codex_s3_call_review.R，仅解释R分派，不当算法证据）。你当前已实现此修复，不需重复调这个点。

原生数据实查A/codex-fixture-inventory.json：pancreas_sub有RNA/spliced/unspliced和PCA/UMAP，无graphs、无tools；ifnb_sub/panc8_sub无现成reduction/graphs/tools。RNA velocity的输入层并不缺失，缺的是Python后端与尚未生成的velocity结果；GraphPlot的源fixture没有RNA.nn邻接，坏signature和缺上游图要分别写，不能捏造已有结果。

编译笔记要按分支修正文义，而非追加通用参数块。现有dimensionality-reduction的通用输入“标准化、HVF、缩放”适合部分PCA流程，却不能直接当NMF的输入：NMF需要非负矩阵，不能传含负值的z-score。每个具体分支明确输入对象/slot/方向、单位与前提。RecoverCounts是已知归一化机制下的反推，不能泛称恢复真实原始计数；RNA速度、拟时间不能据图形/默认根给生物学方向结论。导入新方法后应更新这些编译判断及实现选择，不堆成一个来源一页。

许可证文件随独立复制保留：请把固定源LICENSE.md的正确GPL文本和必要归属纳入各独立模块的清单（可有去重存档，但复制清单自身需要能带走），不要只在JSON写GPL却保留MIT或缺归属。原始函数字节只读；code/fns被命名空间/资源定位改过的文件不能仍以“verbatim copy”冒充原件，要明确derived copy并指向原source hash。