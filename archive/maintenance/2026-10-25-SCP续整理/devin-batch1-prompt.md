用户当前授权：“之前SCP库的入库整理还没有完成，请按照当前新规则与Devin合作进行入库”。你是本次唯一Devin CLI编码/内容整理者，模型swe-2-max；Codex审查与独立验证。不开任何子代理（包括Devin/Codex/Claude子代理），不安装/下载依赖，不访问E:/paper-harness，不在正式库/画廊/开发仓库或全局安装目录写入，不提交/部署/代作者签核。只能写E:/research-wiki-env/work/scp-ingestion-20261025。

先完整读取该工作区wiki/AGENTS.md、development/staged/research-wiki/SKILL.md及references/{minimal-runtime,method-families,project-reuse}.md，并读正式计划E:/research-wiki/文档/SCP持续入库与新规则/implementation-plan.md（只读）。旧STATUS/SOURCE_TO_OUTPUT位于E:/research-wiki-env/work/scp-native-claude，仅只读参照历史，不以旧文件“已签核”替本轮签核。权威SCP源码固定E:/research-wiki-env/sources/scp-2026-10-22，commit b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0，全部只读；实际环境读E:/research-wiki-env/work/scp-runtime.ps1，R=D:/R-4.5.0/bin/x64/Rscript.exe；Wiki Python=C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe -X utf8。不要用PATH商店Python。

本轮第一批必须实际完成两类工作，然后停到Codex审查（不将这些当全库完成）：

1. **完整可追踪盘点**：读固定源码NAMESPACE/必要R/文档/本地示例，交叉查本工作区wiki methods及implementation/runtime/verification、templates和旧S1-S3映射。产出coverage.csv+coverage.json+coverage-summary.md，至少逐公开入口/重要分支列：来源入口/位置、分析或绘图/技术分类、真实分析目的与单位、现有规范家族/实现/模板id、代码/算法/独立性/回放/签核各自现行状态、重复/已覆盖/部分/未覆盖/辅助排除理由、精确缺材料/依赖（本次未查就unknown）、下一动作与优先级。不要把Run入口/纯绘图/环境helper都做analysis方法，不从函数名/图型/同列名强套家族；新目的先提归属方案。不只抄旧STATUS，不以pending为空代表完成。未有算法/新数据就不自动补造或联网。

2. **已知具体缺陷修复 + 方法正文增量**：scp-detest wrapper在真实GSE251716数据上的实际诊断为search_restored=true、options_restored=false（闭包自身也false）。证据只读E:/research-wiki/维护记录/2026-10-24-跨领域课题复用闭环/native-reviewed-independent-check.json，以及E:/青光眼单细胞/wiki-use/acceptance-20261024/analysis/de-rgclike-reviewed/{diagnostics.json,process-checks.json}。仅修改本工作区wiki/methods/differential-expression/code/analysis.R的生命周期/诊断：保留完整统计调用/参数/返回结果，保留原有options值，移除本次新增options，恢复search；成功与抛错路径实际检查，不能预先写none/true。注意requireNamespace/library加载时点，包初始化新增options也需要归因与恢复；不能detach作者原有package或unload namespaces。 source/native原件不改。对照旧代码和修订代码，用现有真实pancreas_sub.rda等合适材料做实际DE调用/原版数值比较、输入不变；另做正常/异常、原有option/新增option、已attach包保护、嵌套source及两个模块同环境互不污染的边界。必须做manifest-only异目录复制、新进程实际调用，不提供SCP包路径；单个实际计算<=10min，不要在青光眼原课题再重跑8min。只有当前实际代码/数据/命令/输出的结果才能登记新算法/独立性收据；旧收据与错误证据保留，不做旧输出重绑新hash。改动将旧证据置过期，按当前工具重新生成真正验证的分支证据；其他not_run分支不升格。

   相应方法正文只补简洁复用判断、参数/原生输入输出、最小依赖/新诊断边界及实现证据指针；不要大段重复技术说明。禁止手改facts、作者user/status/favorite/id。源版本、GPL和对应入口保留。不新增SCP总包“方法”。有其他可根据本地源码补齐的现有方法说明缺口可列明建议，不扩大代码修复到全库所有helper以免一次性使全部收据失效。

绘图侧本轮只准备去重样式提案：列S4+及旧分支缺口的代表原生panel/本地来源路径、现有模板是否同结构可复用、数据有无/是否实际生成、依赖、最小闭包候选、哪些需要作者选代表。可整理真实已存在的来源联系图和样式卡；不得合成“原图”、自动选择未确认新样式、重画整组、给新画廊条目签approved或模板ready。没有真实图像读取能力要如实标视觉核查待Codex，不虚称已看图。Codex会基于实际图像和既有授权处理必要选择，再续同一会话。不要自动批量创建新来源/模板/方法骨架凑数量。

所有CLI必须使用本批development/staged/research-wiki/wiki.py，它的config已指本批wiki/gallery/8880；禁止用全局wiki.py默认正式配置，也禁止运行正式record-use/record-method-use或mark-ready/signoff。scaffold/结构check/save若必要只能针对隔离库。测试证据写工作区evidence/，报告progress.md、result.md、verification-matrix.md。先写progress说明当前阶段，完成后写精确变动、执行命令/退出码、逐项通过/缺口、待作者选择范围；结果self-report不等于验收，不部署。不要输出凭据或思考内容。
