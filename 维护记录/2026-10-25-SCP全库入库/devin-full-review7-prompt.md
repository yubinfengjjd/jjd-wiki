# SCP全库入库：接替已结束的Devin轮次，修复Codex审查项
你是本任务唯一编码者，模型swe-2-max。此前Devin会话wakeful-ravioli的最后一轮已超过有界等待并结束；它的孤儿check-entry进程也已结束。现在用干净上下文接续同一个磁盘任务，绝不另开子代理/其他编码者。Codex仅审查与独立测试。
工作区B=E:/research-wiki-env/work/scp-full-ingest-20261025；审查证据A=E:/research-wiki/维护记录/2026-10-25-SCP全库入库（可读，不写）。所有代码/数据资产/方法说明只写B。不安装任何依赖，不下载资源，不读/调用paper-harness，不写E:/research-wiki正式库，不碰作者项目。固定SCP0.5.6 commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0，source=E:/research-wiki-env/sources/scp-2026-10-22只读。用户明确要求全部SCP方法+全部可视化入库，不单个图；已选全范围，不需再问优先级。新图不代签，作者已确认的formal fig17由Codex处理，B旧快照不得覆盖正式ready状态。
先读B/full-library-plan.md、B/wiki/AGENTS.md、B/codex-review-pass7-queued.md。旧progress/result等是上一编码者自述，已有错误与回归，不能作为完成事实。不要再盘点一轮或花半轮调已通过的MDS/NMF。

已有什么：142 exports、238原始function/ggproto（Codex独立AST全部一致）、79已组装模块、33个Wiki方法页中的19家族/技术页已接入79个入口；7新页已由官方scaffold创建，但正文还不完整且部分错误。代码生成器scripts/assemble-modules2.py，整合scripts/integrate-wiki.py，正文scripts/fill-pages.py。全部可以修订，无需重新从零造库。现有源码/raw/user/status/id保护；不要rmtree掉任何收据，历史保留coverage/runs。

## 具体执行顺序
1. 先保护与修正数据：用正式rwiki.pages读写(保留原换行)，恢复旧页user区块到formal受保护原始块并断言逐字节不变；status/id/favorite保持原值，formal已批准fig17不覆盖。修正YAML空依赖[]、required vs optional/Python声明一致性、真实来源/cite。停止手写YAML和吞标题regex。只改本次SCP涉及页，不能给shap/回归等追加伪SCP来源。
2. 科学语义与知识编译：按审查纠正RunLargeVis=uwot::lvish、RunFR=力导向布局、CellScoring真实3种method、StatPlot真实11型、RecoverCounts真实Seurat/counts层与估计假设。PAGA/Palantir与既有trajectory-inference去重；WOT按真实时间输运目的明确边界，不用宽泛新合集重复。Integration_SCP回workflow，分析家族登记具体整合后端。为家族写简洁选择表、真实输入/单位/必要参数/输出对象与字段/限制/图关系，为22绘图入口分别写契约与真实签名/最小调用例；不能用“见下方data_contract”循环占位，也不要抄40个美术参数/重复依赖长串。
3. 最小依赖是真目标：当前模块source会asNamespace所有潜在包，普通GroupHeatmap仍加载富集包、Slingshot show_plot=FALSE仍加载plotly/reticulate。按原始NAMESPACE正确provider与AST/显式分派处理私有按需解析/核心-适配-可选图分离；成熟包传递依赖保留；不要仅改optional标签而实际提前加载。既有monocle2/3最小core等优先复用，不倒退大闭包。no-install guard最终绑定锁定；Python发行名/模块名映射准确，解释器必须预先显式存在。公开S3入口、最内层ofile已修好，别再次退回。
4. 冻结最终代码/manifest后真实验证收据：不能复制旧路径receipt或重绑hash伪装运行；算法与portability分开，最终family assets复制清单到异目录新进程，从公开entry调用。NMF的NMF分支与默认RcppML缺包分开明确入口/iid，不能把NMF通过批准默认RcppML；其他具名后端也按真实scope。每次run保存命令/输入输出/代码hash/断言，预期拒绝不算算法passed。纯对象存在不算原版等价。已有13个verified分支、12个ready_for_use家族必须保住（基线见A/codex-method-states-formal-20261026T055632.json）；当前旧证据因新增代码失效，需真实重跑并保留旧记录，不能“正常过期”交付回归，也不能放宽验证器。
5. 可视化交付：现有17个正式SCP模板保持；本轮大量真实native PNG/SVG在A/native-oracles及E:/research-wiki-env/work/codex-scp-native-structures、-trajectory、-graph。用真实输入对照提炼版。能生成的代表单panel图样准备图库来源草稿和真实native代码/来源metadata，通过官方ingest创建layout；原source panel不复制进Wiki。新source未签核不可scaffold模板/mark-ready，集中留作者确认。没有材料的代码契约与准确not_run留清，不把文字目录冒充回放/交互验证。3D静态截图不算HTML交互。
6. 142导出/具名后端与286参数分支的完整映射要与页面/真实入口/当前验证一致，helpers/environment/reexports归属明确不塞analysis。可运行且有真实材料的逐批验证；缺依赖精确not_run，不捏造原数据/归因。原始source字节、旧作者备注与状态保留。各方法/图型/接口知识关系按语义，不凑direct。
7. 最后官方parser、method状态、check-entry/lint/pending、保护检查；先用官方只读entry_errors批量找错，别在每段写完后重复耗时save。最终check-entry --record与save按受影响范围执行一次即可。API/前端新资产可见由Codex审。你不部署、不改正式库、不伪造作者确认。更新四份报告与机器映射，分别计入库实物/已验证/待验证/作者确认，不宣称79模块等于完成。

工具：Python一般D:/anaconda/python.exe -X utf8；Wiki CLI优先C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe -X utf8 B/development/staged/research-wiki/wiki.py --config B/development/staged/research-wiki/config.json。R前source E:/research-wiki-env/work/scp-runtime.ps1；Rscript D:/R-4.5.0/bin/x64/Rscript.exe。图验证用现有环境，缺包不装。
此轮3000秒持续实际修复，阶段性保存，不需要用户再说继续。不要把未完成留给作者猜，也不要只修报告措辞。你是唯一编码者，禁止并发子代理。

以下是具体审查全文（以实际新文件验证为准）：
# 最小依赖仍未满足：不能把整个传递闭包的包都当必需

当前生成物实际声明：
- `groupheatmap/runtime.json`必需包含biomaRt、clusterProfiler、igraph、BiocParallel等；普通分组热图并未启用富集注释，不能要求这些可选分析依赖。
- `runslingshot/runtime.json`必需包含plotly、reticulate、ggforce等；`show_plot=FALSE`分析分支不应加载3D/Python/绘图依赖。
- `runmonocle2/runtime.json`必需包含plotly、reticulate、大量绘图包，但已有Wiki `trajectory-inference/code/monocle2_core.R`等成熟拆分core，应复用已有最小core，不倒退到全图闭包。
- `statplot/runtime.json`必需包含BiocParallel；需核实是否regex扫描注释/字符串造成误判，不把包元数据猜测当必须依赖。

根因：`scan_closure`在所有可选分支函数上regex猜包，`.import_pkg()`又在source时对每个包asNamespace并遍历全部导出。这能去掉SCP包本身，却仍会加载无关功能的依赖，未达到作者“运行一个方法只加载相关最小依赖”的要求。不能把这些模块整体标成最小依赖目标完成。

修复方向由Devin实施：在全量Wiki实物整合后集中解决，优先复用已有成熟最小core；区分科学核心、对象适配、可选绘图/注释/后端。可用固定源NAMESPACE的准确符号→provider映射与AST调用关系（含必要动态分派），在私有环境按实际使用延迟解析，避免在source时加载整套潜在包；成熟包自身传递依赖仍保留。不同能力的必需/可选清单要真实反映调用契约，不能只把名字移到optional而实现仍提前加载它。

独立验收：新进程、复制清单，选矩阵核心/Seurat适配/普通图/可选图等明确分支，记录调用前后loadedNamespaces/search/options与实际错误。没有启用注释时不直接加载biomaRt/clusterProfiler，不开启3D时不直接加载plotly/reticulate；若它们确为成熟算法包传递依赖，列出真实依赖链，不冒充直接必需。别用假引擎批准算法。资源、Python模块、原始字节、GPL文件和作者状态仍保护。

该项是既定最小依赖目标的验收，不是新范围。不要因此再一整轮只有生成器调试而Wiki无实际入库。

补充分类复核：fix-exports.py把PAGA/Palantir/WOT统一写到新`trajectory-dynamics`，如要新建此家族，必须与已有`trajectory-inference`做语义去重。Palantir拟时间/命运、PAGA轨迹拓扑通常应为既有轨迹家族的不同实现，不因不同包装换一个宽泛新家族重复入库。WOT显式时间点之间的最优传输与单次截面的拟时间估计确有不同输入/估计对象，可作为有明确边界的状态输运分支/家族，但不能把三者又打包成一个模糊合集。不改变原始source/旧id，明确比较后再定。RunDEtest的markers_type="paired"也要明确是两两组比较，不代表配对受试者统计设计；细胞级检验不能冒充生物学重复推断。
## integrate-wiki.py当前代码的具体风险（尚未最终运行验收）
- upsert_impl用read_text普遍换行归一化，再write_text默认Windows换行，会改写受保护user区块的原字节。必须用正式read_page/write_page并保留get_block(user)完全相同；原facts由save刷新，不手写。正式合并也要保护P0后的fig17及技术页当前内容，不能覆盖旧B状态。
- deps把required R与optional R合并；method_implementations.py129–132行要求页面dependencies恰与runtime.required_packages一致。optional会引入dependency_match=false，Python必需包也漏了。空依赖必须[]，不能YAML null。
- 将算法receipt复制后同时当portability指针是错误的；portability应kind=method、对应当前closure_hash、清单路径与当前family入口，有独立拷贝实际调用。原receipt的files是code/module.R，移到family后变code/<mid>/code/module.R，原指纹已不绑定；不能仅搬文件就称verified。旧收据保留，新位置需真实复制测试，不能用覆盖新hash伪装重跑。
- primary=next(iter(receipts))取任意第一个case，会选到bad_method/refused错误case，且掩盖具名后端。NMF默认是缺包的RcppML，NMF后端已通过不能把通用RunNMF默认为verified。canonical应绑定明确的具体后端入口/实现和真实收据；RcppML单独not_run。其他多后端同样处理，不以note弥补机器状态错误。
- Integration_SCP已按来源判定workflow，不能又在batch-integration analysis页登记整条组合流程为一个分析算法impl；放现有scp-integration workflow/技术映射。具体*_integrate后端仍属批次整合家族。
- RunLargeVis.default固定源实际是`uwot::lvish`，不是Python largevis，也不是另一个largeVis R包。uwot在现有环境可用，不能据错误Python缺包标签跳过。RunFR是igraph Fruchterman–Reingold力导向图布局，不是社区检测；CellScoring.method原生只接受Seurat/AUCell/UCell，AddModuleScore是Seurat分支底层操作，不是第四个method值。FindExpressedMarkers有FindMarkers式检验与阈值逻辑，不只是“计数子步骤”。请按真实源码修正文义、依赖、覆盖表。
- 新页--written无cite只是骨架阶段；这些源于固定SCP，不可最终冒充无来源agent原创。原源码来源/commit/GPL与可复用版归属必须完整，raw归档仍只读。source_path/源码hash和derived改动说明不能省略。

先做完整实际资产，再把这些具体项一并修正；不部署、不放宽验证器、不把临时骨架算完成。
## 独立实际检查点（当前结果不准部署）
- `A/codex-method-states-formal-20261026T055632.json`：正式库12个ready_for_use家族、13 verified实现，metadata无错。
- `A/codex-method-states-isolated-20261026T060722.json`：隔离库只剩3个ready_for_use家族、4 verified，15 invalid，79 not_run；cell-quality-control metadata无效。必须补回原有能力，不能用“旧证据过期属正常”把回归交付给作者。
- `A/codex-protection-current.json`：正式库原件/代码保护未变，只有已批准fig17状态变化；隔离11个旧方法页user区块字节变动（换行），需从受保护正式页原块恢复并后续逐字节断言。Git会转换行尾，不能从git show的LF猜原块；从正式受保护页取原始get_block。

## 编译说明远未完成，不以占位句过check-entry当全量入库
实际新页中“输入见下方签名与data_contract”，但sig_of()查错路径（实际extracted/<module>/<function>.R），下方没有签名/必要参数解释；输出、适用/不适用/知识关联原为空，后来补的通用句仍不能让agent判断具体如何做。`body_fill`用`\s*\n`吞空标题，且read_text→write_text反复造成CRCRLF。请用正式section/helper保留作者块，并为每家族和每入口写有依据的选择判断/真实对象或表的行单位/必选参数/返回字段/边界/具体图接口关联；无需复制所有40个美术参数或重复依赖列表。不得把“有目录和runtime”称方法笔记已完成。
具体错例：
1. scp-viz-statplots写StatPlot支持box/violin/upsert，实际StatPlot只bar/rose/ring/pie/trend/area/dot/sankey/chord/venn/upset；box/violin是FeatureStatPlot，upsert不是图型。
2. scp-viz-heatmaps把返回值笼统写Heatmap/HTList，但原生GroupHeatmap等例子明确是结果list、通过`out$plot`显示，不能让作者对整个list调用draw。query/ref应核对共有features与细胞身份，不能写“构建可重叠细胞”又因重叠拒绝。
3. count-recovery输入实际是Seurat对象counts层中放置待反推归一化值；函数按trans/min_count/tolerance/sf尝试推断，并更新counts与nCount，不是任意矩阵逐元素expm1×sf。NMF可接非负连续表达，不需要为NMF捏造恢复计数这一步。未知归一化不可凭结果整数就冒充真实观测。
4. 新技术页仍只有函数名和包名，没有22入口的实际输入/输出/关键控制/具名结构/已有图样与缺口；新图原生参考有真实文件却未进入可发现的图库来源草稿/页面。当前B/gallery无本轮新来源，不能说“全部可视化已入库交付”。实际有图的准备待确认单panel图样及native code/元数据；没有图的完整代码契约+明确缺口，不伪造模板签核。
5. fill-pages最后遍历所有含runtime的method目录，将非SCP的shap-explanation/回归等也追加“SCP原生模块”是假来源，范围应限本次确属SCP的家族。正式合并不得覆盖无关页面或其acceptance。
6. Python必需后端（PAGA/SCVELO等）的scanpy/anndata等不能全部写optional，mandatory/optional按实际调用能力判断；RunDimReduction这类多后端再条件化。

可直接复用的新真实GraphPlot参考：`E:/research-wiki-env/work/codex-scp-native-graph/graph-real-neighbours.rds` + straight/curved PNG/SVG + references.json。由真实pancreas已有PCA显式FindNeighbors(dims1:10,k20)得到RNA_snn，取50个真实细胞，原UMAP坐标/CellType标签不改，184个非零权重。该图是明确准备的真实派生输入，不声称fixture原有graph，不是虚构边/节点。两种原生GraphPlot已运行；只作native reference，不授予提炼版/科学验证。