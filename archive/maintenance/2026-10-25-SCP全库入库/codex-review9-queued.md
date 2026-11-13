# 正在执行review8的补充审查（下一次接续先读；已通过项不重做）

已通过：79清单形式有效；79公开模块source在独立新进程全部loaded；lazy字符串错误已修；MDS/NMF公开入口的原生数值、输入不变、嵌套driver和同环境多模块调用通过；11页user原始字节已恢复，正式源码/原始资产/开发代码无变更。不要重新造AST/加载器或重复盘点。

## 仍需修复/核对

1. **最小调用例会误导甚至语法非法**：Codex只执行fill-pages2.py的3个纯字符串函数，真实结果在A/codex-minimal-example-review.json。RunMDS/NMF/FR均生成`RunMDS(object=srt, ...)；默认方法 RunMDS.default <- function(object=…, ...=…)`。原因sig_of返回解释文字与双签名，required_args把它当单个formals解析。GroupHeatmap最小例只有`GroupHeatmap(srt=srt)`，必然No feature provided。CellDimPlot3D没有reduction导致两维默认失败。别从语法必填参数推断语义必需项，给各入口经过实际调用的短例，文字和可复制R代码分开。源函数signature可以折叠链接资产，不能用假最小例替代。
2. **描述仍有不支持参数**：fill-pages2 ENTRY的CellDimPlot3D写save导出html/png，实际原native save只接受.html；VolcanoPlot写res或srt@tools，原生签名无res，读取srt@tools$DEtest_*。成熟adapter可接受表/结果并构造对象须另说明，不能把它说成原生参数。
3. **旧impl ID冲突**：A/codex-impl-identities-20261026T070940.json中三个旧verified入口被同id新模块替换，旧verification丢失：QC/scp-runcellqc、评分/scp-cellscoring、映射/scp-runseuratmap。旧code/analysis.R都在。integrate-wiki2.py保持当前old.verification并不恢复之前已丢失的formal记录，需从受保护formal旧meta找回；保留旧入口ID，新分派增加能力则新ID。最终family代码冻结后实际重跑旧分支恢复12ready/13verified，不能直接复用旧hash/放宽validator。
4. **search/options状态**：A/codex-module-probe-20261026T070318.json数值全过，但公开调用后search_unchanged=false、options多处变化；入口本身无cleanup。source-only A/codex-module-load-20261026T070334.json中8模块source就变状态（见B/codex-review8-new-evidence.md）。轨迹核心尤其应不source可选绘图ggproto；成熟Monocle core优先复用。成功/错误路径都要在公开entry内恢复用户原状态，harness事后detach不算入口恢复。不能把数值通过当全验收。
5. **证据真实性**：run-iso-case.py凭input_unchanged/search_restored或output_digest就算法passed不够；cs.checks自由文本"compared vs..."实际不执行却复制到收据。GroupHeatmap/Slingshot现有case参数与native控制不同，GraphPlot现case合成4节点，不是现成真实50细胞图。必须同输入同参数、真实数值/结构/图对照，记录比较结果；无比对如实未验证。不要用失败预期拒绝当算法通过。算法/portability/图回放分开。
6. **Seurat对象版本边界不是笼统Seurat都支持**：Codex把真实观测counts做成显式Assay5（不归一化、不新降维），从已拷贝清单快照公开调用CellDensityPlot(...,slot='counts')，实际报no slot of name counts for class Assay5，输入未变。证据E:/research-wiki-env/work/codex-scp-assay5-probe/result.json、脚本A/scripts/codex_assay5_input_probe.R。原生多处直接slot(assay,slot)，新GetAssayData兼容shim并未覆盖。至少准确说明已验证旧Assay与未支持Assay5；如补对象适配只显式选择现有layer，不猜/合并多层，不重算/丢弃数据，须原值/输入不变对照。不能凭SeuratObject5包已安装就声称支持所有Seurat5对象。

## review8末轮中断后的最新事实（07:28 UTC，覆盖上面的过时中间状态）

Codex为及时处理收据/入口范围及公开entry副作用等审查项，停止了准确ACP18820，bridge25724正常返回ACP stdout closed；停止前psutil确认bridge子树只有该ACP，没有运行中的测试计算子进程。可resume同一pickle-gorgonzola；不是用户取消任务。

- 已有`repair-collisions.py`把QC、评分两项恢复旧入口并给新模块-src ID。**这两项当前不存在旧执行结果绑定新入口的事实，不要再按旧状态改错**。`reference-mapping/scp-runseuratmap`第三项仍未恢复，虽非13个原verified之一也须保留旧ID/入口。integrate-wiki2.py再次运行会重新覆盖冲突，repair脚本对runtime再次运行也可能重复/错改-src ID，要让最终集成幂等并从真实旧meta/runtime恢复，不手写臆造旧来源。
- `coverage/runs/20261026-152256-legacy-replay/summary.json`自报13 passed，原始R确有调用结果，但新`replay-legacy.py`写receipt仅取该impl.files；官方算法收据要求当前family全部code。`A/codex-method-states-isolated-20261026T072802.json`实际2 verified/17 invalid/82 not_run，0ready_for_use（另有笔记验收陈旧，不能误把全部失败归到算法）。别把13个raw called-pass说成13个当前verified。不能直接补哈希伪造新执行；冻结最终代码后copy declared files并执行、对照，采集执行时代码身份、所有要求的文件快照，检测执行后未漂移再写收据。
- `replay-portable.R`是调用+输入不变脚本，不做原生/旧baseline结果比较，却`state='passed'`。这个脚本可作为原始运行记录，不应直接提升为完整算法验证；用对应旧原生参考/已保存真实结果或明确诊断断言作实际比较，不只看执行无异常。scope说copy-manifest，但目前code_dir直接B/wiki/.../code，尚无该轮清单隔离拷贝证据。
- latest身份快照`A/codex-impl-identities-20261026T072819.json`包括仅更新receipt路径的正常变化，按old_entry/new_entry核实，不把所有14行都当身份冲突。保护检查至07:14作者块/正式原件仍全部保持。

后续必须先修**公开入口**source/call的状态恢复和最小核心，修真实最小例，确定final code/runtime，再做一次最终receipt；不要先花时间重跑收据随后重建代码把它们再变陈旧。不要放宽validator或签核。

## 07:39 UTC 新鲜公开绘图对照（本轮每阶段读此段）

Codex脚本`A/scripts/codex_visual_probe.py`复制清单文件到E:/research-wiki-env/work/codex-scp-visual-probe-20261026T073451，新R进程真实公开调用。

- GraphPlot使用真实50细胞图、node_group='group'、edge_line straight/curved、8×6、150dpi，两张与原生control逐像素完全相同，输入不变。证据A/codex-visual-probe-20261026T073451.json，3个snapshot均current=true。这是本分支图形对照成功，非全部22图已验收。
- **两个3D公开入口返回后plotly_build/显示都失败**：`verbose must be TRUE or FALSE`。源对象相同、原生control真实成功，因新cleanup删掉`data.table` .onLoad初始化选项（如datatable.verbose），namespace却仍加载；后续plotly的as.data.table/setalloccol拿到NULL。入口内能返回p不代表外部能渲染/保存。不要只在test harness手动加options或先library(...)后说修好；要让模块给课题的实际调用路径和返回对象正常可用，并检查用户原有选项和包状态成功/错误路径都保护。
- 审查要求里“source必须完全零新增options”需区分：正式AGENTS明确要求**调用**恢复search/options，而真正必要包首次namespace初始化会新增其默认options；之前source审查的重点是算法核心不该强迫source**可选绘图**ggproto。不要为消除一个诊断数字，删除新namespace必需的默认选项而破坏返回对象。若采用显式最小依赖初始化或其他办法，记录初始化范围/新增默认项，保留用户事先设置的值，公开调用后恢复其调用前状态；不能声称不存在这些初始化副作用。不得加载无关可选整库或卸载用户已有包。

处理后用同一个独立visual probe或等价原生trace/外部build验证，不能只调用函数就写3D通过。A/codex-native-3d-browser-review.json仅原生control，提炼版浏览器仍待验。

## 07:47 UTC 文档修后的第二层API审查

S3中文注释污染语法已有改进，但新CALLS表仍有凭常识猜的API。独立R parse（不执行示例）+真实原始formals联合审查见`A/codex-doc-calls-20261026T074713.json`。前一个074604正则版把嵌套list(S1=...)误算成顶层参数，已修审查脚本；只看074713这版，CellScoring的S1是合法嵌套名字。

- RunNMF示例`method='NMF', nmf.method='nsNMF', rank=10`是错的：原SCP只有nmf.method='RcppML'或'NMF'两个if分支；传nsNMF会feature.loadings等未定义，原包装排名参数是nbes，不是rank。用已经真正成功的`RunNMF(mat, assay='RNA', nbes=3, nmf.method='NMF', verbose=FALSE, seed.use=11)`，mat为特征×观察非负真实矩阵；不要把NMF包API当SCP API。
- RunMonocle2没有gene_notes，也没有...，示例必报unused argument；RunWOT没有time.by且没有...，真实time_field，并且**group_by语义必需**，不能只传时间列就宣称可调用。代码/包名monocle不是monocle2。
- RunMDS示例dims/reduction_use不在公开/各S3原始签名，不能凭...就视为支持；RunFR应reduction不是reduction_use，或用真实已测试的Graph输入。RunLargeVis/RunDM/RunUMAP2同样不要用通用reduction_use臆造参数。FindExpressedMarkers的group_by、ZINBWaVE_integrate/scanorama_integrate的batch等须按原签名核实。
- ...允许明确转交某些backend合法参数，所以静态unknown列表是审查线索，不要求机械删除所有unknown；实际转交必须有原代码依据和真实调用证据。不要在没执行的例子上标“actually-invoked forms”。已运行case优先直接转写实际args；缺包分支给源码可证的声明调用并标未执行。

源码在coverage/extracted与SF映射里都已齐，修文档前逐入口读真实formals和参数用途，不能再次从函数名字/其他包记忆生成API。整体范围仍全部SCP，不缩成单图。

07:53复核更新：`A/codex-doc-calls-20261026T075321.json`显示RunNMF/MDS/FR等上述多数参数已纠正，不要再按旧表返工。仍需注意RunWOT新例只有time_field/time_from/time_to，漏了源码显式is.null(group_by)就stop的**group_by**；把时间字段改名并未满足语义前提。静态unknown里某些函数可能是CALLS中没被实际使用的大小写别名，先核对是否真实导出再处理，别机械改正常函数。FindExpressedMarkers的group_by不在自身签名但有...，需要按其真实FindMarkers转交参数核实，不能自动把家族RunDEtest参数照搬过去。

07:57核对：`run-iso-case.py`的`algorithm state`代码段仍保留“只要checks全true即passed”及“空checks有output_digest也passed”的原fallback，虽已增加oracle_png/trace逻辑。请落实原审查：没有真实算法/原生图对照或明确结果断言的case，只能记执行/独立调用成功，不能算法verified；执行成功但算法验证未做可在验证receipt记not_run并解释executed=true、verification_checks_not_run，portability另按实际证据记录。不能靠input_unchanged/search_restored的通用true混入算法通过。已有确实oracle比较的case不受影响，不要全部降掉。

## 08:04 UTC 真实课题共享会话污染复现（冻结代码前修）

新审查`A/scripts/codex_global_shadow_probe.R`、`E:/research-wiki-env/work/codex-scp-global-shadow/result.json`：同一真实40细胞counts矩阵，公开MDS先成功40×3；用户GlobalEnv里放一个普通`matrix`变量（dgCMatrix）后，相同调用报对matrix不能用@；删除用户变量后又成功，输入不变。原因模块`imports <- new.env(parent = globalenv())`仍使私有函数的自由符号从作者全局查找，原as_matrix里的`inherits(matrix, ...)`读到用户变量；这与正常base::matrix绑定的干净调用不同。

修加载环境隔离，不改原始as_matrix统计算法，也不要求用户删除/重命名自己的变量：私有imports应从受控基础/namespace环境解析（例如baseenv并显式绑定真正用到的标准包符号），保留NAMESPACE导入/内部函数私有绑定，不让第三层祖先GlobalEnv成为隐式依赖。修后跑该复现及公开MDS/NMF/绘图少量回归；再冻结最终代码并出receipts。不另造新生成器，不扩大重构。

## 08:18 UTC 修后绘图复测及剩余search诊断

`A/codex-visual-probe-20261026T081424.json`：两个3D提炼版的原生trace字段x/y/z/type/mode/name/text/marker（颜色/点径等）全相等，外部plotly_build和HTML保存通过，GraphPlot两种真实图仍逐像素相同，输入不变、代码快照current=true。之前verbose缺选项故障已解决，不重修。

`A/codex-module-probe-20261026T081817.json`：公开MDS/NMF/嵌套driver/同环境多模块仍数值通过，**调用前已有options的值全部不变**（options_existing_changed=[]），新增namespace默认选项明确列options_added；不能称完全零新增options。search仅剩一个新增`package:generics`。当前on.exit逆序detach只固定重试两轮，依赖链大于两层会留下根包；按剩余依赖重试到清空或无进展且记录具体失败，仍只处理本次新增包，不能detach作者原先包。不要在harness外清掉后冒充entry已恢复。全局matrix变量污染问题仍要修，08:13生成module imports仍parent=globalenv。

另：replay-legacy.py/write_receipt曾把Python SHAP/回归的environment写language=R,R4.5（即使实际测试通过，这个环境也不真实）；按kind采集真实解释器/版本，或保留未改代码且仍有效的正式原receipt，避免给无关分支反复改元数据。全部code hash要求须按官方规则，不靠重绑旧输出。

## 新增可直接使用的实际原生材料

- LargeVis：E:/research-wiki-env/work/codex-scp-native-largevis/{largevis-native.rds,largevis-native.json}，原uwot::lvish成功、40观察×60真实基因、参数与输入hash完整。sva也实际存在，别沿用缺包错误。
- FR：E:/research-wiki-env/work/codex-scp-native-fr/{fr-native.rds,fr-native.json}，原RunFR.default成功，真实50细胞SNN经as.Graph和assay.used=RNA；普通matrix会因@assay.used失败。它是图布局，非聚类。
- 3D：E:/research-wiki-env/work/codex-scp-native-3d/{cell.html,feature.html,cell-traces.rds,feature-traces.rds,references.json}。原两个3D入口在既有PCA1:3上成功、1000真实细胞、对象不变，无新降维/合成坐标。Codex浏览器实际渲染两图，Cell图例隐藏/恢复Ductal已观察DOM opacity及点云消失。证据A/codex-native-3d-browser-review.json与A/native-oracles/3d-feature-browser.png。**只是原生参考，不是提炼入口/完整3D交互/作者确认通过**；可匹配参数用于新模块trace数值对照，再分别记录剩余交互边界。

其余原review7/8范围继续，不缩成一个图：22绘图入口真实契约+原生代码+已有模板/新来源草稿去向；142真映射；helpers消费者；当前可运行的逐项真实验证；最后官方验收。所有新作者确认仍保持待确认。修复均由Devin执行。
