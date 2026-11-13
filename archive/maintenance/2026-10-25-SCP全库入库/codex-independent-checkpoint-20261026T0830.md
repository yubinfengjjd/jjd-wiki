# Codex独立审查接续点（2026-10-26 08:30 UTC附近）

用户最新为“继续”，目标仍**SCP全部分析方法和全部可视化按现行规则入库**，非只GroupHeatmap。Devin唯一编码者、Codex独立审查与验证/受控正式整合；无Codex子代理、不装依赖、不触碰paper-harness、原source/作者块/status/旧ID保护。用户只已确认fig17 dot，不代签新图。

## 当前唯一活跃编码轮

- label devin-full-finalize10，session **cuddly-custard**，ACP PID **12796**，统一exec session **47380**；模型swe-2-max；开始08:28 UTC，有界3000秒。先查state/进程，不并发启动新coder。
- prompt A/devin-full-finalize10-prompt.md，B/codex-finalize10-handoff.md。这是干净上下文接续同一磁盘任务；旧pickle-gorgonzola第9轮超时结束，psutil已确认无编码/测试进程后才启动本轮。
- 实时短审查可写B/codex-finalize10-live-review.md，本轮要求每阶段读取它。不要再把十轮完整日志/思考输出给用户。
- A=E:/research-wiki/维护记录/2026-10-25-SCP全库入库；B=E:/research-wiki-env/work/scp-full-ingest-20261025。
- task-state.json已更新此label/session。桥接A/scripts/devin_acp_client.py；凭据只在子进程环境，绝不输出。save_state已加Windows临时锁重试（第7轮曾因此异常结束）；这是审查工具修复，不是产品改动。

## 现在真实状态

- 142导出、238function/ggproto原始AST齐全；79当前模块权威索引B/coverage/modules-index.json。历史其他module目录不计。
- B/32方法/技术页。旧重复trajectory-dynamics已并入规范trajectory-inference，WOT标真实时间输运；Integration_SCP归workflow；Count-recovery独立draft。
- **最新官方独立快照A/codex-method-states-isolated-20261026T082332.json**：7verified、11stale、1invalid、83not_run；0ready_for_use（包含笔记验收未收尾因素）。不要接受13raw passed/79 source作为交付。正式基线12ready分析家族/13verified实现须保住。
- A/codex-impl-identities-20261026T072819.json的多数行仅receipt路径正常变更；QC/评分旧ID当时已恢复，第三项runseuratmap后来修复代码已补，仍须最终核实；integrate-wiki2/repair-collisions现在应幂等。
- 11页user换行已恢复；A/codex-protection-current.json上次独立检查正式源/原始资产/开发代码0变，B作者块0变。正式P0 fig17 dot已ready，B早于P0，不得整体覆盖老状态/索引/log。
- B/gallery仍无本轮新原生来源草稿；B/coverage/wiki-map.json仍14:13旧版。这是实际未完成，不只是测试。

## Codex已实测通过的范围

- A/codex-module-probe-20261026T081817.json：公开MDS、NMF(NMF后端)、嵌套driver、同环境先加载NMF再调用MDS均原生数值相同、输入不变；required79清单形式有效。options_existing_changed=[]，新增namespace默认项明确记录；search仅多package:generics。
- A/codex-visual-probe-20261026T081424.json：两个3D提炼版在PCA1:3的trace字段x/y/z/type/mode/name/text/marker全等，外部plotly_build、HTML保存成功；GraphPlot真实50细胞straight/curved两图与原生逐像素相同，输入不变，三个代码快照当时current=true。最终代码再改需复测，不能重绑旧hash。
- A/codex-graph-visual-review.json：Codex实际看过新curved图，标签/图例未裁切，源默认无轴标题要在课题说明坐标含义；不是科学结论/作者确认。
- A/codex-native-3d-browser-review.json：**原生控制**两HTML实际浏览器渲染，Cell图例Ductal隐藏/恢复已用DOM opacity及点云确认；Feature仅渲染。原生控制相机/hover未测，提炼版浏览器还没验。截图A/native-oracles/3d-feature-browser.png。临时8890服务器/测试tab均已关闭，非正式Wiki服务。
- A/codex-module-load-20261026T070334.json是较早v3：79loaded，8source状态副作用。后续ggproto已延迟，Devin自报79 source零变化，**Codex尚未对最终延迟版全79重测**，最终冻结后跑A/scripts/codex_module_load_audit.py。

## 明确剩余代码/证据项（已写finalize10 prompt）

1. imports仍parent=globalenv：A/scripts/codex_global_shadow_probe.R、E:/research-wiki-env/work/codex-scp-global-shadow/result.json中，真实counts公开MDS干净成功，作者全局matrix变量(dgCMatrix)存在则失败，删除恢复。修受控base/namespace解析，不改原as_matrix算法、不让作者改变量名。
2. on.exit逆序detach固定两轮留下package:generics；按新增依赖重试到清空/无进展，保留原先包。旧cleanup删除namespace新增默认选项导致3D返回后data.table verbose错误，已修通过。保留必要初始化默认值并如实记录、恢复调用前已有options；算法临时新增项要与namespace默认区分，不能一概保留说完全恢复。
3. run-iso-case.py的algorithm-state旧fallback仍只看通用checks/output_digest就passed，必须有真实结果/原生对照断言；仅执行成功另记，不授予算法verified。family receipt全code哈希必须实际本轮运行采集且未漂移，不补绑旧产物；选择当前有效scope，NMF只NMF后端不批准默认RcppML。
4. replay-legacy.py/R已加旧baseline语义比较与family全code hash，但需最终冻结后重跑恢复有效；Python环境不得写成R4.5。未改且旧receipt仍有效的SHAP/回归可保持原证据，不必反复动。
5. 文档S3语法、NMF等API大多已修。A/codex-doc-calls-20261026T075321.json；RunWOT还漏group_by，FindExpressedMarkers group_by须核实...语义，某些大小写CALLS别名并非真实导出不要机械改。缺包例只是声明，不写已运行。Assay5直接slot失败已实测，保留旧Assay范围/明确未支持Assay5，不隐式merge层。
6. 完成真实来源草稿/官方ingest、全部142真映射（helper消费者/源码路径/当前官方状态）、知识编译、正常check-entry--record/lint/pending。新图仍待作者确认，不scaffold/ready。

## 现成原生控制材料（勿重复生成）

- A/native-oracles：MDS/NMF/2D/stat/correlation及真实counts60基因×40观察。
- E:/research-wiki-env/work/codex-scp-native-structures：GroupHeatmap5结构，CellDimPlot4圈选PNG/SVG；8×6,150dpi,13个真实marker，精确参数见A/scripts/codex_native_structural_oracles.R。
- .../codex-scp-native-trajectory：Slingshot(SubCellType,UMAP,seed11,show_plotFALSE,无start/prefix)3lineage真实对象，DynamicPlot/Heatmap；原生CellDimPlot lineages叠加grobs list-matrix失败，不重画掩盖。
- .../codex-scp-native-graph：显式Seurat FindNeighbors(PCA1:10,k20,computeSNNTRUE)，真实50细胞184非零权重node/edge、straight/curved图。不是原示例已有graph，也不是合成4节点。
- .../codex-scp-native-3d：原生Cell/Feature(PCA1:3,1000cells,900×650)、HTML依赖文件、tracesRDS。截图不是完整交互验收。
- .../codex-scp-native-largevis：原RunLargeVis.default真实uwot::lvish成功，40观察×60基因，perplexity3/neighbors10/epochs100/threads1/seed11。
- .../codex-scp-native-fr：原RunFR.default成功，50细胞SNN as.Graph+assay.usedRNA，ndim2,niter100,seed11。普通matrix会@assay.used失败，不能泛称任意矩阵。

## 独立工具与命令

- 通用D:/anaconda/python.exe -X utf8；Wiki C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe -X utf8；R source E:/research-wiki-env/work/scp-runtime.ps1 后D:/R-4.5.0/bin/x64/Rscript.exe --vanilla。AMD64、R_LIBS_USER=E:/research-wiki-env/R-lib-scp/4.5，清LANG/LC_*。
- A/scripts/codex_module_probe.py、codex_visual_probe.py、codex_module_load_audit.py、codex_method_state_audit.py isolated|formal、codex_protection_audit.py、codex_impl_identity_audit.py、codex_doc_calls_audit.py。均为Codex审查/测试，不是产品编码。新时间戳输出，不以R进程exit0替代脚本捕获的真实错误。
- doc_calls_audit的074604正则版曾误报嵌套list(S1=...)；已改用真正R parse，**只用074713及以后**。
- Windows Get-CimInstance/Get-NetTCPConnection本轮会漏真实进程/端口；进程用psutil精确命令行/树核对，HTTP用本地urllib核对。不凭空启动重复服务。
- 正式服务8765上次父43040子5392，先实查再复用/准确重启。API /api/page?path=methods/foo.md；SPA /#/page/templates/id.md，非/api/templates/id。

## 后续行为

先看finalize10活跃态，别重复启动。冻结后按变化范围独立验、检查实际diff和所有保护，未过回Devin修；通过后受控合并已审增量，B旧fig17/索引/log不覆盖，官方save/验收、API/浏览器实查。仅内容改动无需五处技能部署；若规则/产品变更才按计划备份同步。不要在所有未完成项仍存在时宣称全库完成，也不要停在已绿几个module。

已使用memory：MEMORY.md:45-49（SCP独立运行与证据边界），rollout_id 01a16c0f-933a-7460-b3da-f78c0558976d，最终回复最后须一个规范memory citation块。没有用户明确要求，不更新C盘memory。
