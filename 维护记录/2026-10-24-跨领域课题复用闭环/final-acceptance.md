# 跨领域课题复用闭环：正式交付与独立验收

日期：2026-10-25。Devin CLI（swe-2-max）编码，Codex审查与独立验证；未启用Codex子代理，未安装依赖。本轮基础机制已发布，结论为“限定范围通过，保留具体未验证能力和维护项”，不表示任意领域任意算法已经可运行。

## 本轮产品边界

Research Wiki仍是原始材料、编译知识和规则组成的Markdown知识库。课题agent负责科学判断、复制最小代码和实际执行；网页负责检索和展示，不增加网页分析执行器、数据库或无边界调度器。项目的状态/依赖/授权/运行/经验草稿存于课题目录，不把完整科学对象和课题成图搬入正式Wiki。

通用状态容纳样本、细胞、模型、影像/ROI、分子结构、谱图等原生对象；领域配置用于表达必要证据，非算法能力清单。机会发现与具体实现可执行性分开。新领域词汇、配置通过、一个分支通过，均不批准其他算法。分类是领域tags和用途purposes两个维度，共用规范id与后端事实；未有方法的领域不伪造空壳ready条目。

## 独立软件验证

- 冻结版本完整后端回归：648 passed、3 skipped，保留1个既有Starlette弃用警告；logs/codex-batch2-snapshot-full-rerun.log。先前中断的不完整测试不计通过。
- 后续CLI变更：44 passed、1 skipped；logs/codex-batch2-latest-cli.log。独立不利输入25例、集成15例通过；不将不同范围数字相加。
- 采纳15键领域词表后：38个相关配置/入库/分类测试独立通过。另用本机已有Draft202012Validator核查15个规范键接受、未知键拒绝；schema结构除派生enum外不变。
- 前端相关测试、类型检查/生产构建已通过；实际Chrome点击领域、用途、URL、返回、方法详情和图模板状态文案通过，无该次浏览器错误。证据browser-review/cdp-production-results.json、cdp-method-list-final-results.json及对应截图。冷启动/旧测试驱动超时保留，不冒充产品错误或性能提升。
- 并发、修订冲突、失效传播、样式与计算依赖、恢复隔离、重复运行、原生对象与非包条件、经验草稿去重/重开和仅分析使用登记均有隔离测试/独立探针；不是对应领域的科研实际运行。

## 真实青光眼材料验证

原课题E:/青光眼单细胞只读，新产物位于wiki-use/acceptance-20261024。已有对象为17,918基因×10,100细胞，两个GSM样本。现有细胞类型列、嵌入和打分列存在可核查，但历史上游执行与注释正确性不能据此确证。GEO与脚本疾病标签冲突，按D021只用GSM身份，不反复要求作者解释，不做疾病或供体级推断。

- Codex原生可行性链：复制gene-set-scoring两文件，实际Seurat/AddModuleScore分支，对10,100细胞产生有限分值；显式映射逐项保值；复制原生山脊图闭包生成PNG/PDF/SVG。native-viability-review.md。
- A25首次自然语言消费者glimmer-opossum：实际复用课题聚合代码，生成18行组成表和原生比例图，但错误绑定注释家族、缺少Wiki分析分支实际调用，首次只算partial，未改写成初次通过。
- 同一消费者审查修复：自主选择differential-expression/scp-detest，复制运行清单两文件并实际调用；RGC_like702细胞对其余9398细胞，7,403行marker结果，真实原生火山图PNG/PDF/SVG。既有标签的描述性刻画不构成注释独立验证，也不是疾病差异。
- Codex逐行检查原始→绘图映射：只有pct字段改名和71个下溢校正p值的明确绘图下界；不聚合、不更改原表。实际打开图像确认标题、方向、单位和标注。该原生图横轴diff_pct、颜色log2FC，非通常横轴log2FC的火山图。
- 首次诊断JSON为空，独立复现SerialParam的S4序列化错误。Devin只修验收驱动的保存方式；Codex新进程复核157.003秒、退出0，表与首次逐字节一致；原始诊断RDS和显式S4摘要JSON均保留。新证据也暴露旧模块options未恢复，保持实际false，不宣称完全无副作用；继续限制为独立R进程调用，未静默修改科学模块/收据/作者状态。
- 通过公开update_project修订task-prop-gsm当前family_id为null，移除证据不足的normalized断言，收窄score观察到实际列存在。原任务id、运行收据、旧输出及revision48备份保留。
- 全新消费者relic-sailor实际读取revision50、核对哈希与已有结果，未重算，唯一写入FRESH-SESSION-REVIEW.md；33个受保护课题文件保持原字节。它自行发现未登记的复核结果与clusterProfiler依赖分类错误。Codex随后登记本次复核运行，状态revision54、5次运行、19个产物、3份pending经验草稿；未改旧运行收据。推荐语义另经NEXT-STEPS-REVIEWED.md收窄，不将Slingshot/ORA前提缺口写成已批准执行。

## 确认并恢复的边界事件

第一次消费者调用record-use越过明确的禁止正式回写边界，产生仅5个Wiki文件的5119fa326da1提交。Codex核对范围后仅针对该提交恢复至04c1f767f815，保留追加审计日志，不reset/clean/stash或改写历史。之后试验切换到917文件隔离Wiki和296文件真实试用技能副本，只有试用config有意指向隔离库；正式安装config不变。

已同步到待发布规则的修正：record-use/record-method-use是正式写入，不因图完成而自动获得授权；项目内record-run与正式回写分开。消费已有标签/预测/结构不等于运行生产它们的算法；没有匹配家族时不绑定、不为验收造新家族。检查必须记录实际检查者。客户端文字过滤器拒绝命令不代表用户拒绝。

## 门槛结论与限制

| 门槛 | 当前有据结论 |
|---|---|
| G0跨领域契约 | 通过结构/规则验证，非各领域算法实跑 |
| G1单细胞工程链 | 真实评分/表图链已通过；DE追加新运行结果一致，options恢复仍有明确限制 |
| G2真实课题适用性 | GSM口径的阶段识别、前提区分、描述性复用已有实证；不确认疾病解释、历史打分执行或注释正确性 |
| G3跨域真实分支 | partial/not_run：现库两个非单细胞家族同属机器学习且均缺runtime清单，不能充当两个不同领域；未安装或新造算法凑数 |
| A25自然语言复用 | 首次partial，审查后真实分析/出图链已补齐；实际新会话接手已核查且未重算；保留推荐内容需独立审查的边界 |
| 作者签核/科研价值 | 经验草稿pending；不代签，不编节省比例或把工程演示当论文价值证据 |

后续优先维护项：旧科学模块options恢复、ML真实运行闭包与第二领域材料、推荐前提逐项复核、真实日常任务的人力/等待/维护成本测量。它们不因通用内核或分类上线而消失。


## 正式同步与服务验收

- 35项经审查的开发源文件增删改已按清单整合；原开发Git暂存区哈希不变，未stage/commit/reset/clean/stash已有工作。
- 使用tools/deploy.py完成.agents/.codex/.claude/.cc-switch/.config/opencode五处安装。每处296个文件与正式staged源逐文件SHA-256一致，旧bundle各清理2项并有备份。正式config仍指E:/research-wiki/知识库，未部署隔离试用config。
- 精确同步20项规则/分类资产：sci-figure-replica实际主源和五处副本的taxonomy、派生metadata schema、分类reference，另同步开发spec和正式AGENTS。五份安装manifest只更新对应资产记录并追加范围说明。798个其他外部skill文件核对未变，未整包覆盖该技能。领域词表15键、证据profile8类；不表示15种领域已实际跑过算法。
- 正式服务http://127.0.0.1:8765启动于已核对的全局.agents技能；API首页、分类和方法发现返回200，当前生产bundle可达。实际Chrome完成领域→用途筛选、计数/URL/返回、方法详情和最小运行事实查看，无该次浏览器错误；methods-filtered.png已独立打开核查。临时8878测试服务已准确关闭。
- 正式lint无ERROR，18项WARN均为已有具体实现not_run/独立性未运行；pending仍为细胞类型注释、双细胞检测、RNA velocity的待验证实现，不清零、不标可用。正式检查发现注释页旧结构验收过期，核对完整正文及现有分支限制后仅刷新acceptance.json；SingleR仍not_run，作者状态与备注未改。
- Wiki规则/结构验收保存于cfcd426；追加交付审计日志保存于4712202。原错误登记及精确恢复的历史保留。最终原始source36、原课题25、画廊来源/元数据146、100个真实作者区块及状态字段核对通过；不得把101个含规则示例的标记片段误计为101作者区块。

## 使用与后续维护

在课题会话中调用research-wiki，让agent先核查当前材料与证据，再列主线/探索/缺材料候选；沿已有授权复制具体分支的最小闭包，显式适配输入、实际运行/出图并检查。没有约定的执行范围/预算不能当无限授权；缺依赖不安装；正式知识回写与作者签核仍分开。原生对象不必全转CSV，表格接口只在确实需要的绘图边界派生。

本轮实测的是显式定位试用技能的Devin自然语言流程、独立新会话接手，以及正式部署后的CLI/API/浏览器；五处文件同源不等于每个宿主的原生自动发现、Claude执行或所有领域算法已另行实测。

已排定的后续维护范围：
1. P1：scp-detest的R options恢复。修复应保留source原始字节、修正正常/异常路径的新增options清理及真实诊断，按分支重做原版/修订版输出与副作用比较；代码变化须生成新证据，禁止把旧算法/独立性收据重绑新哈希。本轮仅以独立R进程隔离，不宣称该缺陷已修。
2. G3：已有ML分支补齐有依据的运行闭包与独立验证，再选择第二领域真实材料。缺资料/依赖的具体分支继续not_run，不新造算法凑数量。
3. 候选推荐继续核对研究问题/谱系、背景基因集、单位和实际入口；来源日志/列存在不证明历史算法已运行。作者3份经验草稿保持pending，真实日常收益需另测，不编节省百分比。

备份/逐文件依据：reviewed-integration-plan.json、integration-backup/、integration-verification.json、governance-sync-plan.json、governance-sync-backup/、governance-sync-verification.json、deployment/backup/、deployment/deployment-verification.json、five-host-independent-hashes.json、final-protection-verification.json、formal-api-smoke.json、formal-browser-review/、fresh-handoff-independent-check.json、native-reviewed-independent-check.json。
