# 当前执行接手点（持续任务，不是完成报告）

## 最新覆盖旧接手点（2026-10-24 UTC约12:10）

旧下文的review2已结束，review3也结束。原20用例通过后实际diff又查出implementation_id当代码身份、最终state提交失败未回滚summary、无哈希文件/收据被当current、观察的about对象变版本仍授予证明。已补至25用例并由同会话review3修复。

**基础checkpoint独立验证通过（不是整体交付）**：冻结副本BASE/foundation-snapshot，完整613项收集，611 passed/2 skipped/1普通deprecation warning，293.26秒；25项独立边界测试全部通过；当前前端npm tests/typecheck和条件展示probe通过。证据logs/codex-foundation-full-final.log、codex-foundation-audit-final.log、codex-foundation-frontend-test.log、codex-foundation-typecheck.log，冻结源码hash列表foundation-snapshot-hashes.json。基础第三轮报告development/review3-result.md；没有新安装/合回/部署。

**当前活动已变为devin-batch2**：统一exec session **63947**，同一functional-tartan模型swe-2-max，状态devin-batch2-state.json（PID以该文件最新值为准），超时3600s。提示维护目录/devin-batch2.md，详细隔离根next-batch-outline.md。不要重复启动/发消息；只在原进程结束后按情况resume。batch2尚未审查通过。

本批实现T04–T06/T07/T09范围的课题真实流程集成、变化/恢复、阶段草稿、analysis-only use、正式保存范围保护、native大文件stream hash、规则/skill/分类与前后端同步；仍只改隔离development/BASE，禁止正式Wiki/安装/原课题写入。可在BASE另建isolated pilot，已有真实native-probe可有据复用。**真正A25自然语言skill消费者验收是下一步独立新上下文评估，不能把编程者手写driver算A25。**

其他新重点：原store.save git add-A会提交Wiki父仓库无关dirty，已要求batch2隔离修复并测staged/index保护。现有taxonomy实际指向安装的sci-figure-replica，不可只改断开的dev/spec。受控分类/alias更新若必要先在BASE准备+部署映射，不改安装。G3两个不同非单细胞领域实跑资料可能不足，不能用两个ML算法/结构fixtures凑数。

已宣布并完整读system skill-creator：简洁入口/渐进引用/保持作者意图，quick_validate仅结构，不替代真实行为。新读skill不用Codex子代理；用户禁子代理仍优先。

Devin桥接只读根新增精确skill目录（5宿主的research-wiki/sci-figure-replica及system skill-creator），写仍仅BASE；没有扩大到原课题。后续实际consumer输出若要放原课题的独立acceptance目录，先核查存在/边界，只授权该精确新目录，不能开放整课题写入。

## 授权与边界

用户已授权按战略盲区咨询方案实施，使用E:/青光眼单细胞作实验验收，Devin CLI替代Claude编码，Codex只主导/审查/独立验证。禁止Codex子代理或其他编码子代理；不安装依赖，不读/调用E:/paper-harness/paperflow，不覆盖原课题数据/代码/结果。不因长任务停在派发或自报完成。

最新用户D021：“我不知道，你看着做就可以，反正是跑个实验”。分组设计冲突不再等待回复，软件实验用GSM编号，原标签不改，不作Control/Glaucoma疾病推断，不重复询问。已记入session.md和glaucoma-design-conflict.md。

产品从首轮跨领域：生信、深度学习、影像组学、CADD、网络药理毒理、蛋白组学、代谢组学及组合。单细胞只是首个深度样板。候选、实际可运行、科学判断和作者签核分别表示。主入口是课题agent，Wiki网页不成为执行器。

## 活动进程（不要重复启动）

- 唯一Devin编码会话：functional-tartan，模型swe-2-max。
- 当前轮：devin-review2，统一exec session **31478**，ACP PID **22544**（后续操作前核实实际状态）。
- 命令：scp-runtime.ps1进程配置后用D:/anaconda/python.exe -X utf8运行scripts/devin_acp_client.py，--cwd隔离development，--prompt-file维护目录/devin-review2.md，--label devin-review2 --seconds 2400 --resume functional-tartan。
- 状态/事件/回复：devin-review2-state.json、logs/devin-review2-events.jsonl、devin-review2-result.md。更高层task-state.json记录active_*，不要读旧轮退出/报告当新轮完成。
- 仅原进程结束后resume同会话；别启动并行coder。正常测试有真实子进程解释时不误判停滞。不要输出完整日志、凭据或思考内容。
- 首轮devin-batch1在50分钟客户端等待到期，代码保留但无正式结果报告；原进程及测试进程已核实结束后才resume。
- review1已end_turn，报告在隔离development/review1-result.md，ACP进程3632已结束。没有部署。

## 位置

- 原开发：E:/research-wiki/开发，nested Git master原有约90项dirty；原HEAD 2bbe879922d9f93b3af0f5053e04cd23c1b6ad5f，未reset/clean/commit。
- 唯一编码副本：E:/research-wiki-env/work/wiki-cross-domain-20261024/development（普通快照，不是Git worktree）。
- 不可变before：维护目录/before/development。
- 计划：E:/research-wiki/文档/战略盲区咨询/{session,requirements,design,cross-domain-contract,handoff}.md，D019真实青光眼替代必需公开癌症样板；D020 Devin；D021软件实验继续。计划中G2/T07/A16已统一纠偏。
- 已备后续批次提纲：隔离根/next-batch-outline.md。尚未派发，不能当实施完成。
- 隔离frontend/node_modules是到原开发现有node_modules的junction；未安装。
- 全局research-wiki可被Devin CLI skills show识别（.agents共享目录）；**尚未做真正A25自然语言skill消费闭环**。

## 当前实现/审查

首批实现：project_state.py、domain_profiles.py/yaml、discovery.py、project CLI命令、只读discover API、runtime v2工具/资源/硬件声明、前端运行条件基础展示、部分staged SKILL/reference。正式Wiki/安装尚未变。

review1原13个独立失败用例已通过，但泛化同类需求仍有7个失败，且条件依赖前端隐藏。review2专门修这些，不扩产品阶段。详见隔离根/codex-review-batch1.md（活文档末尾已补充泛化/前端问题）、维护目录/devin-review2.md。

20例独立测试：scripts/codex_batch1_adversarial.py，review1返回代码的最终结果13 pass/7 fail，logs/codex-review1-final-audit.log：
1. 观察证据文件变字节仍满足verified；
2. unknown when被当成not_applicable；
3. 同命令但无真实代码/资源身份仍错误去重变动后的代码；
4. 合法JSON空收据{}可复用；
5. 显式stale但字节匹配仍可复用；
6. file:产物路径消费者未传播上游stale（artifact:引用已修）；
7. summary rename失败会留下新state+回滚旧receipt的不一致。

前端脚本scripts/check_condition_display.mjs：后端新tools[].condition/hardware.condition未进TS类型/formatter，实际输出“工具 vina;硬件 加速 gpu”，丢失docking_only/training_only。红证据logs/codex-review1-final-conditions.log。要求修实际格式化/视图并覆盖测试。

不要只让有限用例绿，审查相关freshness/alias/receipt事务语义。可以要求一个同源判定路径，避免check/evaluate/impact/dedup分别维护不一致逻辑。缺完整代码身份时自动复用保守，不能靠shell字符串猜全部依赖。

## 已有测试证据（范围不能混）

- 原基线：缺fixture失败保留；补fixture后506 pass/7 R中文locale失败/2 skip，读取现有scp-runtime.ps1后针对8个R绑定测试通过。不能称单次完整全绿。
- Codex首批独立全套：563 pass/5 fail/2 skip，5项因隔离副本缺历史codex/R1-migrate.py；只复制该精确原文件后5项定向全通过。没有因此改产品代码。
- Codex首批选定新/相关测试108 pass；前端原测试（30图型检查+methods检查）和typecheck通过。
- Devin review1自报完整594 pass/2 skip，非Codex独立最终验收。
- Codex实际比较当前库34个已有manifest实现的旧/新closure hash，无回退（复核过review1）。
- Codex真实app/API：负limit最初500→review1修后422；正常发现/分类/方法详情200，15 analysis候选和11上下文条目，未提升not_run。

## 真实课题独立可行性（不是A25/整体验收）

详见native-viability-review.md和native-viability-hashes.json。

- 原课题annotated RDS真实17,918基因x10,100细胞，缓存6个AP1基因；独立复制scoring runtime清单2个R文件，在新进程、无SCP bundle/root下实际调用Seurat分支两次seed11/SerialParam/classification FALSE/name Audit。
- 两次分数相同，10100个有限值，输入对象/counts/meta/cell ids不变，search恢复；不是历史五分支复合分数、不是疾病/注释正确性验证。
- scripts/check_glaucoma_scoring.R，日志logs/codex-glaucoma-scoring.log；最初audit driver错误使用sys.source缺ofile，已改为文档source并保留redloader失败，不为此改产品源码。
- scripts/check_glaucoma_plot.py按显式bindings逐项保留细胞/分组/分数值，选择runtime确有声明的SCP CellDensity ridge模板，复制清单6文件及spec/runtime控制元数据。生成真实PNG/PDF/SVG/sizing。
- 产物：E:/research-wiki-env/work/wiki-cross-domain-20261024/native-probe/（out/verification.json、plot-mapping-verification.json、figure/figure.png等）。目前仅隔离核验产物，未写课题或正式Wiki。
- 已打开PNG，9类、轴/图例/标题与描述性任意单位完整。第一条脊线贴边，但ggplot build峰顶=上界9.5118、超界点0，未证实裁切；不要继续报为已证实裁切故障。
- 旧青光眼UMAP/violin模板**无runtime.json**，别猜清单或假标独立；本次用了具有真实清单的原生ridge模板，未改正式配图关系/收据状态。
- 用户原项目根25文件哈希无变化；GSM7986397官方为LXB4而旧脚本映射Glaucoma，软件用GSM，设计未知。热图脚本有rnorm Demo，不能凭PDF存在认定真实完成，也未证明PDF一定来自Demo。

## 保护与发布

- scripts/check_protection.py：原开发329、Wiki来源36、原课题25、画廊原码/元数据146、101个user-marker片段/字段（真实区块100，另1规则示例）全部独立核验未变，证据logs/codex-protection-during-review1.json。
- 之后按文件合回审查通过的diff，不能覆盖原dirty。scripts/list_changes.py可给隔离变化清单，但新增logs/临时报告/fixture不应部署。
- 特别注意原store.save会git add -A（Wiki Git根E:/research-wiki，还包含计划/维护记录dirty），不能无审查调用而误提交全部历史。T06正式回写/规则同步前须解决提交范围，不要重置用户index/工作区，也不要伪签核。
- 正式部署入口E:/research-wiki/tools/deploy.py（不是开发/tools）；备份同步5处技能/逐hash。审查未过不得合回/部署。服务变更时准确匹配正式服务再重启，不广泛kill。

## 还必须做

1. 等review2返回/失败，读actual diff+报告；独立20例/前端条件probe、相关回归；必要时同会话继续修，别信end_turn/594测试自报。
2. 通过foundation后才派发隔离根next-batch-outline.md：T04–T06/T07/T09及发布准备，补真实工作流程/阶段草稿/分析独立记录/正式与staged AGENTS、SKILL和各reference同步，真实页面核对。
3. 真实自然语言skill消费A25不能用Codex开发者手工跑CLI冒充。可有据复用上述隔离真实结果，但必须实际agent加载技能→接手状态/证据→查库决策→复制/映射/运行或有据复用→真实图→变更/恢复→经验草稿。常规授权内连续做，科学重大取舍保留作者。
4. G3至少两个非单细胞领域具体实跑；当前库主要single-cell及ML，两个ML分支不等于两个领域。资料/现有依赖不足则如实部分完成，不安装/新写算法凑覆盖/伪装native支持。G0配置fixture不能替代G3。
5. 最终审查全部通过后才按计划合回、备份部署、服务/API/JS/CSS、作者/来源保护、最终验收与限制。未完成不能报全交付。

## 环境/工具约束

- Wiki Python：C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe -X utf8；通用D:/anaconda/python.exe -X utf8；不用商店python。
- Rscript：D:/R-4.5.0/bin/Rscript.exe；每个新shell用现有E:/research-wiki-env/work/scp-runtime.ps1，避免继承C.UTF-8中文路径乱码；缺harmony/SingleR/scDblFinder/monocle/AUCell/UCell/GSVA/singscore，不安装，缺项not_run。
- 桥接脚本只把已登录凭据放ACP子进程env，不输出/保存；已验证读写/执行/resume能力，非仅DEVIN_OK。不要输出思想/全stream。
- functions.exec只能串行调用，但内部独立tools可Promise.allSettled；等待单次<60秒并保持有意义进度说明。
- 已用memory：MEMORY.md 22–29和extensions/ad_hoc/notes/20261024T004040+0800-local-devin-acp.md。最终必须追加一个准确memory citation block；用户没要求更新记忆，禁止写memory更新。
