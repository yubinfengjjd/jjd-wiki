# 接续SCP全库入库：当前磁盘成果的最终修复与交付

你是本任务唯一编码者，Devin CLI swe-2-max；Codex负责独立审查。前会话pickle-gorgonzola第9轮已因50分钟有界等待结束，ACP29040及相关计算进程已确认不存在。现在以干净上下文接续**同一磁盘任务**，不得另开任何子代理/编码进程。

所有写入仅B=E:/research-wiki-env/work/scp-full-ingest-20261025；A=E:/research-wiki/维护记录/2026-10-25-SCP全库入库只读。固定SCP0.5.6 commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0，原source=E:/research-wiki-env/sources/scp-2026-10-22只读。禁止安装/下载依赖、访问paper-harness、写正式Wiki/画廊、触碰作者项目、伪造作者签核。

先读B/full-library-plan.md与B/wiki/AGENTS.md，**本文件就是当前精确handoff，不要重读历轮几千行日志/思考，不要从零重新盘点或再写v4生成器**。实际读代码/源码按下面具体项。

## 已有什么（保留，不重做）

- 142精确导出、238源码function/ggproto已提取，Codex原始AST全部一致；source/原件字节保护。
- 79自包含模块权威索引coverage/modules-index.json；其余历史目录不是主记录。scripts/assemble-modules3.py已实现私有环境、精确NAMESPACE惰性符号、S3私有分派、最内层ofile、ggproto延迟求值、no-install锁定guard、资源/许可证、Seurat5 GetAssayData兼容、Misc<- setter、invoke字符串调用Seurat RunPCA/SVD/ICA/TSNE导入。
- 32 Wiki方法/技术页，当前已有79左右入口落入家族；PAGA/Palantir/WOT归既有trajectory-inference（WOT明确真实时间输运边界），Integration_SCP归workflow；RecoverCounts真实语义、RunFR图布局、LargeVis R uwot、StatPlot11型、CellScoring3型等已纠正。
- scripts/integrate-wiki2.py、repair-collisions.py保留旧入口、新模块-src ID；第三项runseuratmap也已有修复代码。scripts/fill-pages2.py给真实签名/输入/输出/例；多数错误API已修，后面还有少量核实。
- scripts/run-iso-case.py已能copy manifest到异目录，family receipt files覆盖整个family/code；新增PNG/3D trace/原生RDS对照钩子。scripts/update-cases-native.py对齐原生参数。scripts/run-family-cases.py批量运行；scripts/replay-legacy.py及replay-portable.R用旧baseline result.rds作真实语义比较。
- 11页旧user字节已恢复。正式原件/开发代码未动。旧B早于正式P0：正式fig17 dot已ready，**不能让B旧状态覆盖它**。已有17个正式SCP模板保护，未见新图不代签。
- Codex刚独立证明：MDS/NMF公开入口、嵌套driver、多模块先后加载原生数值全相同；GraphPlot真实50细胞straight/curved逐像素相同；两个3D入口PCA1:3的x/y/z/type/mode/name/text/marker全等，返回后plotly_build与HTML保存已通过，输入不变。证据A/codex-visual-probe-20261026T081424.json、A/codex-module-probe-20261026T081817.json。**别重写这些算法或复活已修lazy错误**。

最新官方状态（不是旧自报13passed）：A/codex-method-states-isolated-20261026T082332.json：32页，7 verified/11 stale/1 invalid/83 not_run，0ready_for_use（笔记验收也未收尾）。目标保住正式基线12ready分析家族/13verified实现，不放宽validator；新缺包分支精确not_run。

## 按顺序完成的有限剩余工作

### 1. 冻结前最后两个加载层bug

1) imports仍parent=globalenv，真实共享会话污染：A/scripts/codex_global_shadow_probe.R及E:/research-wiki-env/work/codex-scp-global-shadow/result.json。相同真实40细胞counts，公开MDS先成功；用户全局有普通变量matrix(dgCMatrix)后失败；删除后成功。修**加载环境解析**（baseenv/受控标准namespace+显式符号），不改原as_matrix算法、不要求用户改变量名、不留全局隐式依赖。只做小改，检查标准包自由符号，不从零造解析器。
2) on.exit只逆序detach固定两次，MDS/NMF后仍多package:generics。按新增依赖重试到清空或无进展并记录剩余，仅处理本次新增包，保留作者原先包。
已有options值在最新独立probe全未改变（options_existing_changed=[]）；首次namespace初始化新增默认项必须如实记录，保留这些必需默认项以免返回plotly对象外部构建再坏掉。**不要再删除datatable.verbose制造verbose错误；也别说零新增选项。**区分namespace初始化默认项与算法自己临时增加/改动的option（如RcppML.verbose/threads）；保护用户既有值。可以记录初始化边界/默认值，显式scope与诊断，不加载无关可选包。

修后少量公开MDS/NMF/Graph/3D回归，确认后**一次**重建+integrate，真正冻结最终所有代码/runtime；后续不再边跑收据边改代码。

### 2. 补完例子与收据真实性（非大重构）

- fill-pages2.py：RunWOT新例仍漏源码显式要求的group_by（真实time_field，而非time.by）；FindExpressedMarkers group_by是否真实被...转交须读源码核实，不机械套RunDEtest；无关大小写别名CALLS不一定是导出，清理/核实。RunMonocle2加载包名monocle，不是monocle2；未实际执行例别写actually-invoked。原生Volcano没有res参数，3D native save只.html，已改不得退回。Assay5直接slot访问已复现不支持，应保留精确已验证旧Assay/待适配Assay5边界，不隐式合并layer。
- run-iso-case.py的algorithm state旧fallback仍仅凭input_unchanged/search_restored全true或output_digest就passed，必须落实修复：有真实算法/原生绘图比较或明确结果断言才算法passed；仅执行成功记验证未完成(not_run并executed=true/原因)，portability另记。cs.checks自由文本不是已执行比较。已有MDS/NMF/Graph/3D等真比较保持。
- family receipts必须绑定本次实际拷贝与执行代码、真实输入/参数/输出hash、比较断言；当前family全code hash按官方要求且检查运行期间未漂移。不要补hash给旧产物。选择当前通过且scope正确的receipt，不扫历史第一个passed就挂指针；NMF仅nmf.method=NMF被批准，默认RcppML缺包不能继承。
- replay-legacy.py环境字段别把实际Python SHAP/回归写成languageR/R4.5；未改代码且旧receipt仍有效的无关分支可保留原有效receipt，不必反复更动。R旧baseline对照真实执行保留，13raw调用通过不等于13当前verified。

### 3. 真正交付全部内容（不要只跑几个测试就返回）

- 现有case已覆盖很多可运行入口，用最终family asset运行，不仅coverage/modules；可用环境逐项真实跑/比较，缺包或原生缺材料/失败准确not_run，不伪造数据，不改统计。额外的286参数分支如实逐项去向/范围，不继承兄弟分支verified。
- **图库仍没新增本轮原生来源草稿，这是必须补的实物**：用以下现成真实PNG/SVG/HTML和对应原生代码/精确调用准备未覆盖的代表单panel来源，查询既有17模板避免同结构重复，按真实gallery schema/官方ingest-figure创建来源页。作者未签核不得scaffold-template/mark-ready。只做代码目录/文字目录不算可视化入库。
- 原生材料全部已有，不再生成一轮同控制：A/native-oracles；E:/research-wiki-env/work/codex-scp-native-structures（GroupHeatmap5结构/CellDimPlot4圈选）；-trajectory（Slingshot对象、DynamicPlot/Heatmap）；-graph（真实50细胞、straight/curved）；-3d（cell/feature HTML、trace RDS）；-largevis；-fr。具体params/hashes见各references.json/native.json及A/scripts/codex_native_*.R。原生3D浏览器控制已实际渲染、图例隐藏/恢复验证，提炼版浏览器仍由Codex后续验，截图不算完整交互。新图片只是软件夹具原生输出，不能写成已发表/原始科研结论或作者批准。
- **coverage/wiki-map.json仍是14:13旧文件，必须更新完整142唯一导出映射**：真实规范页/实现/源文件/资源或helper的消费者列表、排除理由、官方当前状态；GeneConvert/PrepareDB是函数不是包数据。helpers/环境/reexports不塞analysis。导出原始层与编译知识层来源链可追踪，不拿142行数量冒充有去向。
- 真正简洁编译的选择/输入方向/必要参数/输出/限制/知识关联；不保留循环“见data_contract”占位。只改SCP相关页，不给SHAP/回归塞SCP内容。来源panel仍在gallery只读层，Wiki仅指针/代码/回放，来源/回放不混称。

### 4. 收尾

先用官方read_manifest/implementation_status/entry_errors找错，按受影响页正常check-entry --record与save/lint/pending一次，恢复12ready/13verified基线；status/user/id/原source不手改，不代作者签核。更新progress.md、result/verification-matrix及机器映射，分别数源覆盖/实际入库/source-only/数值或绘图对照/独立性/作者待确认。保留旧失败与原始收据。你不部署，Codex审查通过后控制合入正式。

工具：通用D:/anaconda/python.exe -X utf8；Wiki C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe -X utf8 B/development/staged/research-wiki/wiki.py --config B/development/staged/research-wiki/config.json；R先source E:/research-wiki-env/work/scp-runtime.ps1，再D:/R-4.5.0/bin/x64/Rscript.exe --vanilla。缺依赖不安装。Codex脚本会写A，不直接运行它们越出写边界；你可在B做等价复现，独立验证由Codex执行。

每完成一个阶段读取B/codex-finalize10-live-review.md（若存在）接收新的短审查。不读完整stream/思考内容，不反复盘点、不反复造生成器。持续完成上述已授权实物与验收，不在单个helper/source-smoke/raw receipt阶段宣称交付。
