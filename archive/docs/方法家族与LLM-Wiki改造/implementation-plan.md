# 方法家族与 LLM Wiki 改造实施计划

> 用户于 2026-10-23 已确认实施。执行方式已由用户改为：Claude Code 负责编码，Codex 负责审查与独立验证；禁止再启动 Codex 子代理。已有成果保留，具体交接见 claude-handoff.md。

**Goal:** 方法库按明确分析问题组织家族；实现可复制、参数显式、验证独立；知识仍以互链 Markdown 为本体。

**Architecture:** 保留现有 type=method 与所有旧 id/资产路径，新增 method_kind=analysis/workflow/technical。默认方法目录只列 analysis；workflow/technical 仍能访问和互链。正文是唯一知识文本，前端不重复拼接概览与完整正文。方法说明完成与具体实现验证分离。

**Spec:** 本次对话已批准的 13 页审计与整改建议；本文件给出字段和执行契约。Karpathy 原文 https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f 是可定制模式，不声称存在认证标准。

## 全局约束

- 不读取或调用 E:\paper-harness。保留全部 source/original_code 字节、现有 id、作者 user 区块、原始画廊与成图。
- 不覆盖未提交改动；基线保存于维护记录/2026-10-23-方法家族与LLM-Wiki/before。
- Python 用 research-wiki 专用解释器运行库与测试；其他脚本 D:\anaconda\python.exe -X utf8。TEMP/TMP/MPLCONFIGDIR 指向 E:\research-wiki-env\tmp。
- 不自动安装依赖；已有代码的参数化/函数化在授权内，缺失算法不凭空实现。没有通过的分支如实记录 not_run，不把加载/假引擎/模拟接口测试当作算法验证。
- 知识库不新增网页执行或环境管理。开发期可在现有隔离环境验证，课题运行仍在课题副本。

## 数据契约（各任务共用）

method frontmatter:
```yaml
method_kind: analysis # analysis | workflow | technical
summary: 一句可用于索引的判断性摘要
data_contract:
  input: 输入对象、粒度和关键条件
  output: 结果对象/表及关键含义
implementations:
  - id: example
    title: 具体实现名
    language: R
    entrypoint: code/analysis.R:run_analysis
    dependencies: [Seurat]
    verification: verification/example.json
```

verification 收据相对于该方法资产目录；缺失表示未验证。JSON 至少含 schema_version=1, implementation（id）, state=passed, scope（非空）, command（非空）, checks（非空列表）, environment（对象）, files（相对资产目录路径到 SHA256 的映射）。files 必须覆盖当前 code/ 下所有源文件，入口必须存在且属于 code/，不允许越界。任一代码改变则回放失效；不把依赖库版本记录当永远兼容。后端派生 implementation_status: {id,title,state: verified|not_run|stale|invalid,scope}，metadata 不持久化派生结果。方法可用推荐要求 analysis、作者 ready、笔记完整、至少一个当前 verified 实现，只返回验证通过分支；其他分支可阅读，不能声称可执行。

## Task 1 — 后端门槛与 Markdown 导航

**Files:** staged/research-wiki/rwiki/{method_implementations,acceptance,methods,workflow,suggest,catalog,server,lint,facts}.py 和相关 tests。

- [x] 先写反例测试：technical/workflow 不参与分析推荐；只有源码或缺收据不能可用；坏收据/越界/代码变化失败；有一个通过分支不批准其他分支。
- [x] 实现上述元数据与收据校验；API 与 CLI 共用有效状态，旧未分类页安全退为待分类而非自动可执行。
- [x] methods 确认只确认知识说明；ready_for_use 另检查实现。workflow 给出笔记/实现进度，流程/技术资料不冒充待分析。
- [x] index 按分析家族/流程/技术资料分组，每页一行 summary；保留图、接口、课题索引。lint 检查类型、重复家族、缺来源/实现和结构；语义矛盾仍交 agent 审查。
- [x] 运行定向 pytest 和全套回归；不得通过放宽新门槛让老测试虚假成功，夹具按新契约更新。

## Task 2 — 前端单一正文和实现状态

**Files:** 开发/frontend/src/{api,markdown,components}.tsx/ts, views/{MethodsView,MethodOverview,PageView}.tsx, tests。

- [x] 为方法筛选与重复正文建立失败测试。
- [x] 默认展示 analysis 家族，包含未实现知识但明确标注；workflow/technical 在辅助资料区访问。
- [x] 方法详情标题/用途只出现一次；输入输出优先 data_contract 的实际对象说明；实现对照显示入口、依赖、分支验证范围。
- [x] 参数、源码、历史和完整关联证据折叠，正文的分析判断可直接读；无配图不阻挡有效方法。
- [x] 测试、typecheck、build；不改变图库单 panel 与已有签核逻辑。

## Task 3 — 科学函数提炼与现有环境验证

**Files:** 知识库/methods/<家族>/code、verification、example；维护记录中的测试与执行日志。

- [x] 保留原语言与统计逻辑，提炼明确输入、参数、结果/诊断的入口，映射到原实现；共享 SCP 源码保留一次，复制依赖方式显式说明。
- [x] 优先运行现有隔离 R/Python 可支持的实现。实际函数调用、输出断言、异目录复制和输入不变检查；验证原版/封装版结果一致。
- [x] 单细胞分析家族：cell-quality-control、doublet-detection、batch-integration、differential-expression、gene-set-enrichment、gene-set-scoring、trajectory-inference、rna-velocity、cell-type-annotation、reference-mapping。每个至少提供现有来源支持的函数，不虚构所有软件已实现。
- [x] SHAP 提炼接收既定模型、background、samples 的函数，训练另作显式示例，不隐式重新划分。回归指标保留 summarize(frame, expected_ids) 独立函数。
- [x] 无可用依赖或上游失败，保留函数、精确失败与 not_run，列入后续动作，不伪造通过。

## Task 4 — 知识编译、规则与迁移（Claude Code 实施，Codex 审查）

**Files:** 知识库/methods/*.md、AGENTS.md；staged/research-wiki/{SKILL.md,assets/AGENTS.md,references/method-families.md}；文档与本维护记录。

- [x] 按批准审计把旧页归为技术资料或组合流程，保留来源/备注/旧 id，链接到家族；方法家族吸收相应来源判断，不能只改标题。
- [x] 每页保留当前验收必要章节但简洁；正文写研究问题、选择条件、输入输出、步骤、代码入口与限制，原始实现细节用链接。
- [x] 按原始层/编译层/规则层，ingest/query/lint，索引摘要、只追加日志、来源追溯、矛盾与未知项及查询判断回填更新规则。注明原文并落实本地边界。
- [x] 使用 wiki.py save 更新 facts/index/log，不手改用户区/status/facts，不为了验收清零改历史作者确认。
- [x] 跨来源去重按 [追加审查要求](跨来源去重审查要求.md) 执行：青光眼与SCP同义分析汇入同一规范家族；同算法不同包装是实现差异，参数变化不新建方法。交付旧页→家族→实现→来源对照表。
- [x] 将下节“后续入库技能流程”和“来源 panel 存储”同步进正式 AGENTS、staged/assets/AGENTS、SKILL 与相应 references，并以实际流程验收，不只新增文字。

## Task 5 — 联调、部署与独立复核

- [x] 全套 Python 回归、frontend test/typecheck/build、正式库 lint；核对源码哈希与作者备注不变、无断链、索引包含全部资料。
- [x] tools/deploy.py 同步五处安装并验证；已有改动随源部署但不归为本轮新增。
- [x] 正式浏览器检查默认目录、源码本地化不再当分析、家族详情无重复、未验证不显示可执行；记录截图/HTML证据。
- [x] 维护记录写清通过、失败和未运行分支及命令；报告不以结构检查代替科学或真实课题验证。

## 后续入库技能流程（本次对话追加确认）

1. 先读输入资料、明确分析目的/输入/输出/本次提炼范围，复用已确认答案。
2. 必须查现有方法、实现与流程，按研究问题、数据语义、统计单位、估计目标和成立条件做语义去重，不只比标题/函数名/关键词。
3. 同一实现补来源或修订；新算法/实现加入已有家族；多个方法串联记为流程；源码/环境/绘图适配进辅助资料；只有新的分析目的才提议新建家族。
4. 给出具体收录方案（更新页面、增量、函数、验证、材料缺口）；关键选择明确后执行。缺原始数据、改变统计逻辑或补缺失算法先问。
5. 原始代码原语言原字节保存，提炼版独立；显式数据/参数/结果/诊断，说明复制依赖与调用；只在现有环境验证。用户已明确本轮不安装包。
6. 逐实现实际验证原版/提炼版、异目录复制、换合法数据和输入不变；失败/缺依赖/未运行明确，不以加载或一个分支通过批准整个家族。
7. 编译进已有知识：更新实现选择、适用边界、相关方法/流程/接口/图样；来源有冲突则记录并修订旧判断，不做一来源一孤立条目。
8. 检查重复、断链、冗余与证据，更新带摘要索引和只追加日志；分别显示知识整理和实现验证，按正常作者确认流程交付。未验证知识默认可读但明确标注，不能作为可执行推荐。

## 来源 panel 存储（本次对话追加确认）

- 来源 panel、完整原图、original_code 属于画廊等只读原始层；前端通过受控路径读取，不要求复制到知识库。
- Markdown 只保存来源路径、哈希、裁图/bbox与证据链接；新增入库不得重复存放同字节来源图片。
- 模板/方法资产目录可保存可复用代码、示例及真实回放预览。这与来源图片是不同资产角色。
- 没有回放预览时允许显示来源 panel，必须明确“来源参考图／尚无回放”，不能冒充模板运行验证。
- 验收：从画廊读取来源图可展示；Wiki无新增重复来源图；参考图与回放图标识正确；原始哈希不变；不为了满足规则擅删历史资产。

## 夜间监控与交接

- 用户要求定时监控 Claude 完成情况。检查指定会话进程、claude-stream.jsonl、claude-exit.txt、claude-result.md、claude-progress.md；进程退出不等于工作完成。
- 无变化/无须处理时保持安静；完成、失败、持续停滞或需用户输入时通知。不要因用户睡觉跳过审查或把未验证分支标可用。
- Claude 报告返回后，由 Codex 对照本计划和追加要求审查并独立复验；代码修复仍交 Claude，不启动 Codex 子代理。审查未过不部署。


## 独立验收结果（2026-10-23）

已由Codex完成两轮独立审查与修复复核，五处部署和正式8765服务实查通过。可执行实现、文字笔记确认、真实课题科学验证仍是不同状态；13个新增家族保持draft，5个已登记分支not_run，其余未实现算法在来源对照表注明。实际覆盖与限制见同目录final-acceptance.md。浏览器以IAB真实AX证据核对，截图API不可用，未声称完成作者视觉签核。
