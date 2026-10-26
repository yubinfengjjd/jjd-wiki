# Claude Code 实施交接（2026-10-23）

> 后续对话已追加进 implementation-plan.md：跨来源语义去重、完整八步入库技能流程、来源panel留在只读画廊（Wiki只存引用/哈希）、默认可读但未验证不可执行。继续或恢复此会话时先重读完整计划与跨来源去重审查要求.md。原交接中的13家族列表是知识覆盖清单，不授权按来源新增同义方法；重复步骤必须汇入规范家族。

用户明确要求：改由 Claude Code 编码，Codex 仅负责审查和独立验证，不再启动 Codex 子代理。用户已批准 implementation-plan.md 的改造；缺依赖只标待验证，明确禁止安装包。

请先读同目录 implementation-plan.md、E:/research-wiki/知识库/AGENTS.md、E:/research-wiki/README.md。你是唯一编码者，不调用 Codex，不创建其他编码子代理。不要停在计划，要继续完成实现、联调、内容迁移、必要测试与报告。Codex 会独立审查。

## 已有工作，必须先盘点再续做

- 开发仓库原先有未提交改动，本轮基线在维护记录/2026-10-23-方法家族与LLM-Wiki，包含 development-baseline-status.txt、before/、source-hashes-before.json。禁止 reset/clean/覆盖原有工作。
- 后端新实现位于 staged/research-wiki/rwiki/method_implementations.py 等；新增方法门槛测试第一轮 23 fail→23 pass（来自先前执行者报告，尚未独立复验）。全套回归未确认结束。API 的 implementation_status 是页面列表/详情顶层字段。
- 前端已有家族分类、实现状态与去重正文；30旧测试+4新SSR场景报告通过，typecheck报告通过。需要你复核并完成 build。禁止把报告当作完成证据。
- 知识库13个新家族骨架的 scaffold 正在/已经完成；先检查文件存在。它们大多仍是空骨架，必须写实质知识，不可直接宣布迁移完成。已创建的旧13页尚未改造。
- scientific_functions 任务被中断，现有维护记录 create_scientific_assets.py、test_scientific_python.py、test_scientific_R.R 是未完工资产，请审读再使用。SHAP 新 code/explain_model.py 已写，旧 shap_explain.py 未改；其余是否落盘须核对。function-inventory.json 尚未保证存在。
- 原有三个 Codex 执行者均已停止，不能再调用它们。

## 内容迁移必须做到

全库原13页全为ready、9页无独立code/。SCP源码本地化与绘图接口映射属于 technical；标准预处理和青光眼预处理属于 workflow。其他旧SCP/课题实现页保留旧id、原代码与作者备注，改为来源/实现资料，并链接方法家族，不再出现在默认分析方法卡片。旧状态不可手改；新家族由 scaffold-method 建立，正常流程确认；不能伪造作者科学签核。

新家族13项：cell-quality-control、doublet-detection、batch-integration、differential-expression、gene-set-enrichment、gene-set-scoring、trajectory-inference、rna-velocity、cell-type-annotation、reference-mapping、dimensionality-reduction、cell-clustering、dynamic-feature-analysis；加原有 shap-explanation、regression-resampling-evaluation，共15个分析家族。不要为了凑数量虚构能力：没有来源的分支只文字说明待实现。

每页写用途/原理与选择/适用/不适用/输入/怎么做/代码/输出/知识关联检查；内容简洁、研究问题优先，依赖/来源/验证状态只维护一次。GO、KEGG是资源，ORA/GSEA是策略；Monocle2/Monocle3/Slingshot是拟时序实现。RNA速度、参考映射和注释须区分。原始五种通路分数相加的脚本不得冒充通用标准实现。回归代码只汇总已有预测，不声称包括模型训练/重采样。

语义关系迁往真正分析家族，原来源页清除作为主记录的figure_relations但保留文字证据链接。不要把结构相同当科学直连。inputs/outputs可为空接口列表，但data_contract必须说明真实对象/矩阵/模型与结果含义；不强制所有分析输出CSV。真实配图不存在不阻挡有效方法。

## 函数与验证

保留全部 source/original_code 字节。使用既有代码做显式参数化，不改变统计逻辑、不补新算法。共享SCP-local只保留一份，课题复制依赖说明明确；wrapper不得写死知识库路径。原始自动安装助手必须在临时引擎中阻止，不能触发安装。加载、假引擎单元测试不等于真实分析通过。

现有 R 隔离库 E:/research-wiki-env/R-lib-scp/4.5，Rscript D:/R-4.5.0/bin/Rscript.exe。执行前 source E:/research-wiki-env/work/scp-runtime.ps1（AMD64/locale修复）；Python E:/research-wiki-env/bio-python/Scripts/python.exe。已发现 Seurat5.6.0、SeuratObject5.4.0、slingshot2.16.0、clusterProfiler4.16.0存在；harmony、SingleR、scDblFinder、scanpy、scvelo、anndata缺失。用户明确不要安装，保留函数和精确 not_run 原因。其他现有环境能力继续查证。

verification收据字段严格按计划，覆盖所有code源文件hash。只给实际分析调用、原版封装等价、异目录复制和输入检查通过的分支写passed。未跑通保存错误，不伪造。不能因一个实现通过批准整个家族。

## Karpathy模式落地

原文：https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f 。这是可定制模式，不是认证标准。保留不可变原始来源、编译Markdown、schema规则三层；执行 ingest/query/lint；新增来源更新已有知识而非一来源一方法；记录矛盾、未知、来源；index有逐页摘要；log只追加；查询产生的可复用判断回填。无需数据库/向量库/网页执行器。同步正式AGENTS、staged/assets/AGENTS、SKILL与references，删除“知识库永不验证方法”等与开发期验证相冲突的过时要求（网页不代跑课题仍保留）。

## 收尾和交付

运行后端全套pytest、前端npm test/typecheck/build、正式库lint；检查原始哈希/作者备注/链接/默认方法分类/重复标题与验证状态。所有缺项记录，不以清零为目标。用wiki.py save重建facts/index/log；不手改facts/user/status。先不要部署五处全局技能，不重启正式服务，留给Codex审查后完成。

将完成报告写入维护记录/2026-10-23-方法家族与LLM-Wiki/claude-result.md，列修改文件、实际命令与结果、各实现验证状态、失败/未跑项、需要Codex审查的风险。请完成编码和本地验证后停止，保持可审查工作树，不提交开发仓库，不删除历史证据。

禁止读取/调用/引用E:/paper-harness。除wiki专用解释器外Python脚本用D:/anaconda/python.exe -X utf8；TEMP/TMP/MPLCONFIGDIR使用E:/research-wiki-env/tmp。用户只授权本次改造，不授权向外发送、安装依赖或永久删除。
