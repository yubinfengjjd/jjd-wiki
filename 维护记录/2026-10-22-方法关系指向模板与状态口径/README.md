# 方法关系指向模板与状态口径

作者看到方法页“方法与图的语义关系”仍显示两张来源 layout 卡（“图页面：待模板化”），而对应模板已 ready；同时“接口结构匹配的模板”为“暂无”。作者确认的处理口径：

1. 模板 ready 后，方法主关系指向模板，来源 layout 只作 evidence/溯源。
2. 关系卡显示目标页的有效 workflow（如“模板已就绪”），不把来源 `pending_template` 当成模板未完成。
3. “接口结构匹配”仍只列真正消费方法声明输出的模板；当没有结构匹配但有 `adaptable` 语义模板时，另列“语义关联的模板（需适配）”。
4. 规则 + lint + 一次性审计，防止再次出现。

## 原因

- 方法原有 4 条关系：2 条 layout、2 条 template。`RelationList` 按原始记录逐条显示，layout 排在前，所以第一眼看到的是来源卡；模板卡其实在下方。
- layout 的持久 `status` 是 `pending_template`（来源本身未做 layout 回放），但 workflow 已是 `complete / 模板已就绪`。`RelationList` 原用原始 `figure_status`，没有用有效 workflow。
- 方法的声明输出是 `regression-fold-metrics`，两个模板实际读取 `render-scatter-rgb`/`render-marginal-bars` 与 `render-category-points`/`render-box-summaries`；没有模板直接消费逐折指标表，所以结构匹配为空是接口契约的真实结果，不是模板缺失。

## 改动

- `rwiki/relations.py`：新增 `_ready_covering_template`；方法关系指向 layout 且存在 ready 覆盖模板时，`relation_errors` 报“关系指向来源 layout，但已有 ready 覆盖模板；请改指模板，layout 放 evidence”。`all_relations` 因此不再把这类 layout 当作可推荐关系。
- 正式 Wiki：`methods/regression-resampling-evaluation.md` 的关系从 4 条迁移为 2 条模板关系；两个 layout 仍在两条模板关系的 `evidence` 中。方法页正文、作者区块、状态、画廊均未改；迁移后重新记录 acceptance。
- `frontend/src/RelationList.tsx`：关系卡按 `pages` 中目标页的 workflow 显示有效状态；layout 目标若有 ready 模板，额外给出“可调用模板”链接。
- `frontend/src/views/PageView.tsx`：结构匹配为空且存在 `adaptable` 模板时，另列“语义关联的模板（需适配）”，给出模板链接和适配动作。
- `frontend/src/relations.ts`：新增 `adaptableTemplateRelations`。
- 链条完整性：`Chain.tsx` 支持在每个模板卡下显示实际读取接口；方法页同时显示“结构匹配模板”和“语义关联的模板（需适配）”两条链。SHAP 页因此显示蜂群图读取 `shap-samples`、条形/环形读取 `shap-summary`；回归页显示 2 个需适配模板及各自读取的 `render-*` 接口，不再只剩“暂无”。
- 方法正文：回归方法的 `输出` 与 `知识关联检查` 写明两个模板实际读取的 `render-*` 接口，修正原先“密度散点读取输入表；箱线图读取输出表”的过度简化。
- `rwiki/lint.py`：对 ready 方法的 `adaptable` 模板关系，检查模板实际读取接口是否在方法正文出现；缺失报 WARN。回归方法的正文已写明 `render-*`，SHAP 的 direct 关系不触发。
- 规则：`知识库/AGENTS.md` 与 `assets/AGENTS.md`（同步）新增“方法关系的模板优先（2026-10-22）”和“链条完整性与读取接口（2026-10-22）”；`SKILL.md`、`references/knowledge-linking.md`、sci-figure-replica SKILL、`文档/当前要求与同步核查.md` 同步。
- 一次性审计：正式库只有 regression 方法存在“layout 主关系 + ready 覆盖模板”；已迁移。SHAP 方法原本就指向模板；两个 archived 方法无 figure_relations。

## 验证

- 后端完整测试（最终）：`pytest-chain.txt` → **387 passed、2 skipped、1 warning**（188.57s）；此前一轮 386 passed（`pytest.txt`）。关系专项 36 passed。新增 `test_method_relation_to_layout_with_ready_template_is_rejected` 与 `test_adaptable_relation_requires_read_interfaces_in_body`，均先失败后通过。
- 前端：`npm test` → 20 checks passed（关系卡有效状态、adaptable 过滤、链条读取接口）；`npm run typecheck`、`npm run build` 成功。
- 正式 Wiki：`lint` → OK；`pending --json` → `[]`；方法 live API 只返回 2 条 template 关系，均为 ready；两个 layout 的 workflow 仍为“模板已就绪”。
- 部署：`.agents`、`.codex`、`.claude` 各 268 个 research-wiki 文件、136 个 sci-figure 文件按 SHA-256 核验；最终 research-wiki 每处 8 个文件更新（关系规则、链条/lint、app 构建），sci-figure 仅 `SKILL.md`；服务已从 `.claude` 重启；`api-verification.json` → 27 页、5 模板 complete、2 方法 complete、5 条关系、agent 队列空、app 与 staged 构建一致。
- 规则提交：`知识库` `18d53bf`（模板优先规则）、`65bf312`（关系迁移）、`f2f3066`/`d02db37`/`217092a`（acceptance）、`b5bac4a`（链条完整性与读取接口规则）；方法正文的“知识关联检查”同步改为模板优先并列出模板读取接口。

## 以后如何避免

- 规则已写入 `知识库/AGENTS.md` 与两个技能：模板 ready 后方法主关系指向模板，来源 layout 只作 evidence；方法页状态取有效 workflow；无结构匹配时另列 adaptable 模板。
- 方法页链条必须同时展示“结构匹配模板”和“语义关联的模板（需适配）”，每个模板标出实际读取接口；适配关系在 `输出`/`知识关联检查` 正文列出接口与准备步骤。不能只显示“暂无”。
- `lint` 检查 adaptable 关系的模板读取接口是否在正文出现；缺失报 WARN。结构匹配只按声明接口计算，需适配模板不能标成 direct。
- 后端 `lint` 对“方法→layout 且存在 ready 覆盖模板”报错；`test_semantic_relations.py` 持续回归。
- 新增/修改方法关系时先跑 `lint`；如出现该错误，把主关系改为对应模板，把 layout 放入 evidence，再 `check-entry --record`。
- 归档/删除模板后重新审计关系；不把 layout 关系恢复为主关系。
