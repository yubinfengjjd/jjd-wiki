# 入库验收全量修复（F01–F06）

作者在 2026-10-21 的 Codex 会话中要求对 `维护记录/2026-10-21-开发日志与入库审查/README.md` 的六项发现“全量修复”。该会话因额度限制在 2026-10-21T15:56Z 中断；作者提供的 `新建 文本文档 (4).txt` 为空，本记录由 Claude Code 从 Codex rollout
`/f/C_move/codex_sessions/2026/10/21/rollout-2026-10-21T14-51-08-01a15d3a-5b6f-7043-a51f-914493f7a970.jsonl`
恢复上下文后，于 2026-10-22 接续完成。原计划见 `plan.md`，进度与裁决见 `progress.md`。

## 修复内容

| 发现 | 主要修复 | 持续回归 |
|---|---|---|
| F01 重复入库绕过签核 | 来源 `gallery_version` 与作者 `signedoff_version` 分离；重复 ingest 同版本幂等，新版本保持 `pending_signoff`；签核只由网页写入当前来源版本 | `tests/test_acceptance_gates.py::test_repeated_ingest_never_signs_new_version` |
| F02 无回放也能 ready | `mark_ready`、`ready_for_use`、workflow、lint、suggest 共用 `entry_errors`；模板必须存在当前输入/输出绑定的成功回放 | `test_preview_without_replay_cannot_become_ready` |
| F03 旧回放不随代码失效 | `verify.json` 升级为 schema 2，记录 `inputs`（code/spec/example/接口列定义）、`outputs`（PNG/PDF/SVG）与运行环境；输入变化、输出替换、失败重跑均使旧回放失效 | `test_replay_is_bound_to_current_inputs_and_outputs`（6 参数）、`test_failed_rerun_invalidates_previous_success` |
| F04 空白方法可确认/推荐 | 方法确认核查 8 个必需节、来源/引用、接口和已声明关系；空骨架/TODO 拒绝；有内容的文字方法允许无代码/无接口 | `test_empty_method_is_agent_work_and_confirmation_is_rejected`、`test_text_only_method_with_review_can_confirm_and_records_acceptance`、`test_missing_relation_review_blocks_method...` |
| F05 跨来源重复图样 | 前端 `figureModels.ts` 只在“单一模板、双向关联、完整覆盖同结构 panel”时合并；保留所有来源链接；未知/不同结构不合并；方法与图库共用分组 | `check_frontend.mjs`、`tests/figure-models.mjs`、live gallery 检查 |
| F06 当前索引过期 | `文档/当前要求与同步核查.md` 更新为 2026-10-22 事实与动态入口；`知识库/AGENTS.md` 增加“入库验收的执行入口”；三处技能同步 | 文档核对 + 部署清单 |

## 追加修复（终审前自检）

`record_use` 会把项目链接写入页面的 `使用记录`；验收快照原先包含该段，导致已验收的 ready 模板/方法在首次使用后变成 `acceptance_stale=True`、`ready_for_use=False`、workflow 待办。现已让 `snapshot()` 只忽略 `record_use` 生成的 `- YYYY-MM-DD [[projects/...]]` 行，其他 `使用记录` 内容仍参与验收。新增 `test_record_use_does_not_invalidate_acceptance`（先失败后通过）；完整回归 `pytest-fifth.txt` → 377 passed、2 skipped。七个既有 acceptance 记录仍有效；正式 `lint` 仍为 OK、`pending --json` 仍为空；已重新部署并重启服务复验 API。

## 终审修复（fresh-context review）

终审 agent 结论为 PASS，同时提出 2 项 Important 和 9 项 Minor。Important 已按 TDD 修复：

- **ready layout 的共享门**：`ready_for_use` 现调用 `layout_ready_errors`，并要求每个关联模板通过自身 `ready_for_use`；`layout_ready_errors` 纳入模板自身的节/回放验收；workflow 对 ready layout 检查覆盖、回放和验收记录；suggest 跳过无法加载模板的 layout。回归覆盖：归档模板、模板节不完整、`mark-ready` 拒绝、验收过期。
- **legacy F01 状态**：移除 `signedoff_version` 的 `gallery_version` 回退；新页面要求显式 `approved_version`。两个历史来源按作者既有确认做一次性迁移（`signedoff_version=1`，状态/正文/模板不变），并新增两项回归。
- 另将“带说明的 TODO 占位”（如 `TODO：补充数据`）判为未完成；`check-entry` 现在报告并可刷新过期验收记录，各加一项回归。

终审的 9 项 Minor 中，带说明的 TODO 占位、`check-entry` 过期报告和文档措辞已修复；其余历史/边缘/报告类 Minor 列在 `progress.md` 的 Final review 段，不阻塞本次交付。终审修复后的完整回归：`pytest-sixth.txt` → **385 passed、2 skipped**（176.13s）。

## 验证证据

- 后端完整测试（最终）：`pytest-sixth.txt` → **385 passed、2 skipped、1 warning**（Starlette 弃用警告），176.13s。两项 skip 为本机符号链接权限。此前几轮：377 passed（`pytest-fifth.txt`，record-use 修复后）、376 passed（`pytest-fourth.txt`，终审前）。
- 审计专项回归：`target2.txt` → 76 passed；`check_frontend.mjs` → passed；`live-gallery.json` → 单 panel 图样 5、可调用模板 5，fig03/fig04 保留 1 个来源链接。
- 前端：`npm test` → 15 checks passed（`frontend-tests.txt`）；`npm run typecheck` → 0；`npm run build` → 成功，产物 `app/assets/index-Ct2Y9w1S.js`、`index-Dae4LbsR.css`。
- 正式 Wiki：五个既有模板已用当前代码/示例重新 `verify-template`（schema 2）；七个 ready 条目（5 模板 + 2 方法）已 `check-entry --record`；`lint` → OK；`pending --json` → `[]`。
- 正式 API（重启后）：`api-verification.json` → 27 页、5 模板 complete、2 个 ready 方法 complete、agent 队列空、7 条关系、服务端 app 与 staged 构建一致；`/api/graph` → 27 节点、56 条边、7 条语义关系边。
- 部署：`deployment-verification.json`（最新一次）→ `.agents`、`.codex`、`.claude` 三处各 268 个 research-wiki 文件、136 个 sci-figure-replica 文件核验通过。首次部署每处 research-wiki 31 个文件更新；record-use 修复后 2 个；终审 Important/Minor 修复后 8 个（`rwiki/acceptance.py`、`ingest.py`、`templates.py`、`workflow.py`、`suggest.py`、`cli.py` 及 `tests/test_acceptance_gates.py`、`tests/test_t3.py`）；sci-figure 仅 `SKILL.md`，后续内容已相同。改动前文件保存在本目录 `backup/<host>/`。

## 部署与运行

- 源：`E:\research-wiki\开发\staged\research-wiki`；构建产物 `app/` 同目录。
- 三处安装：`C:\Users\86186\{.agents,.codex,.claude}\skills\research-wiki` 与 `...\sci-figure-replica`。
- 正式服务已从 `C:\Users\86186\.claude\skills\research-wiki\wiki.py` 重启，端口 8765。
- 重跑：`python -X utf8 维护记录/2026-10-21-入库验收全量修复/deploy.py`；重启用 `restart_server.ps1`；API 核验用 `verify_api.py`。

## 剩余限制

- `verify/` 回执被 Wiki 的 `.gitignore` 排除；克隆/迁移后需在原环境重新 `verify-template`。已提交的 `acceptance.json` 证明当时的结构与笔记验收，不随 Git 携带执行回执。
- 机器验收只证明结构、笔记完整性和当前回放，不证明科学有效性、统计前提或真实课题端到端；真实课题仍需课题 agent 核对。
- 两个正式来源仍为 `pending_template`（模板覆盖完整，显示“模板已就绪”）；这是作者已确认的口径，不要求额外 layout 回放。若作者要求来源本身 `ready`，仍需 `layout.json` + `verify-layout`。
- `reproduce.py` 是审查时的隔离复现证据；修复后其“bug_reproduced”断言会失败，属预期。持续回归以 `test_acceptance_gates.py` 为准。
- 本地化 Windows 输出（`netstat`、`mklink`）在测试中改用 `errors="replace"` 解码；这是测试基础设施适配，不改变产品行为。
- 三处全局安装与正式服务已部署；`开发` 仓库的代码改动仍未提交（按作者指示不主动 commit）。
