# Codex 独立审查：第一轮（2026-10-23）

结论：暂不部署，需 Claude 补齐以下已批准需求。Codex不编码、不创建子代理。

## 已独立核对

- 前端 npm test（30+4场景）与 typecheck 实际重跑通过。
- baseline 的全部210个原始source/original_code哈希一致；旧13页user内容及status保持不变。
- 已启动独立全套pytest，日志：维护记录/2026-10-23-方法家族与LLM-Wiki/review-pytest.log；未结束前不可沿用Claude结果当复验。
- 共享SCP bundle由wrapper内固定哈希运行时检查，局部receipt覆盖wrapper源文件；这一机制需正文说明，不宣称receipt主动核对外部已安装依赖。

## 必须修复

1. **跨来源知识仍未充分编译（P1）**：`cell-type-annotation.md`把家族限定为有参考的自动注释，甚至“不适用”排除了无参考情况，遗漏已有青光眼marker手工注释；`doublet-detection.md`没有DoubletFinder实现分支/来源，几乎全为SCP。这不符合把青光眼与SCP汇入同一规范家族。请按源内容补“策略/实现选择”对照，包含已有marker手工注释/DoubletFinder；保留来源链接、输入条件、算法差异和原脚本是否函数化/验证。未提炼代码可明确未实现，不得凭空补算法或伪造验证。类似检查全部15家族，不要求把所有来源算法都在本机运行。
2. **缺少要求的迁移对照表（P1）**：目前报告只列旧/新页面名单，没有旧页→家族→具体实现→原始来源逐项对照。请产出Markdown对照表，对同一算法不同来源包装标明是来源增补/实现差异；参数变化不是新家族。双向链接应能从规范家族追溯原始课题/SCP资料，不能只有来源页单向指向家族。
3. **后续入库skill流程未完整落地（P1）**：重读最新implementation-plan.md的“后续入库技能流程”八步及跨来源去重审查要求.md。当前references/method-families.md主要是字段与当前库存，llm-wiki-mode.md只概括ingest/query/lint；请写成可实际遵循的查库→分类判定→具体收录方案/关键选择→提炼→验证→知识整合→验收/确认的流程，并让SKILL/正式AGENTS明确引用。明确同实现补来源、异算法加分支、组合流程/技术资料分流、确实新分析才scaffold；加入对应行为测试/夹具，不只写“不重复标题”。自动lint不承诺解决语义同义去重。
4. **页面展示顺序与冗余（P2）**：MethodOverview显示输入输出、实现表、配图后才渲染正文用途，研究问题被压到后面；输入/输出又与正文重复。请至少让用途/研究问题在详情首屏、只出现一次；折叠或合并重复输入输出说明，保留完整Markdown作为唯一知识来源。technical/workflow详情无需套分析实现/空配图总览。用真实家族/技术资料数据做SSR或真实浏览器核对，不能只用简短夹具通过。
5. **代码查看器与实现状态（P2）**：报告明确code-files仍显示unknown而方法实现verified。请从同一implementation_status派生逐文件状态/范围；共享文件属于多个分支时列分支，不把一个通过分支推广全部。原始版仍保持来源状态。没有receipt时不提升。相应API/UI测试。

## 交接约束

先确认旧Claude进程已结束，再resume同一会话 efb59f79-e3a4-4f75-a2a6-2944cae907ef。重读计划新增章节、handoff与本审查。只修上述问题及引起的回归，不安装包、不部署、不改status/user/source、不泛化统计算法。完成后写claude-review-round1-result.md，明确哪些测试重跑、哪些科学范围未改。缺依赖保持待验证。
