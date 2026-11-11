# Requirements Document

## Introduction

让 agent 用 GitHub 结构化管理 research-wiki 项目：新课题或新代码库入库时，自动开长期分支（`project/<课题>`、`ingest/<批次>`）与短期子任务分支（`task/<批次>-<阶段>-<主题>`），任务、评审与验收结论全部迁到 GitHub Issues / PR / Milestone，停止维护文件任务书。agent 在 CI 与 Codex 评审均通过后自主合并（含合并到 main），用户只看结果。部署到 5 处技能目录只能来自已合并的 main 或 tag。

现状（作为约束输入）：
- 本地有两个仓库：根仓库 `E:\research-wiki`（知识库以 subtree 合入，根 `.gitignore` 排除 `/开发/`）与 `E:\research-wiki\开发`（仅 master，6 次提交，最后一次 10-22）。README 仍称 `知识库\` 是独立仓库，已过时。
- `wiki.py save` 目前把每次知识库写入自动提交到 master（作者 `research-wiki@localhost`）。
- `开发` 中 10-23 至 10-26 的工作（方法族、最小运行闭包、taxonomy/输入绑定、课题状态层）未提交，但已部署到 5 处技能目录。
- gh CLI 的安装与认证状态、GitHub 账号/组织均未核实。

假设与默认：
- 远程仓库一律为 GitHub 私有仓库；用一个还是两个私有仓库由设计阶段决定，需求只规定推送范围。
- 首次创建远程仓库与首次推送属于高风险网络操作，需要用户一次性明确授权；此后的常规推送、开 Issue/PR、合并在授权范围内自主执行。
- 不经批准不安装任何依赖（含 gh CLI）；不触碰 `E:/paper-harness`；临时文件写 E 盘；知识库写入只经 `wiki.py save`；部署只经 `tools/deploy.py` 并按哈希核验。

## Glossary

- **Agent**: 执行本工作流的 AI 代理（Codex、Claude、Devin 等）。
- **Wiki_CLI**: 技能目录中的 `wiki.py` 及其 `rwiki/` 模块。
- **GH_Wrapper**: Wiki_CLI 新增的 `wiki.py gh` 子命令组（`start-batch`、`start-task`、`finish-task`、`close-batch` 等），是 git 与 gh CLI 的薄封装。
- **Push_Guard**: 推送前执行的防泄漏检查。
- **CI_Pipeline**: GitHub Actions 上运行的持续集成工作流。
- **Merge_Gate**: 合并前必须满足的条件集合（CI 通过 + Codex 评审通过 + 分支保护规则）。
- **Deploy_Tool**: `tools/deploy.py`，同步 research-wiki 技能到 5 处安装目录。
- **Long_Branch**: 长期分支，`project/<课题>` 或 `ingest/<批次>`，对应一个 Milestone。
- **Task_Branch**: 短期子任务分支，命名 `task/<批次>-<阶段>-<主题>`（阶段对应 P0–P5、T 系列），对应一个 Issue，合并回所属 Long_Branch。
- **Main_Branch**: 仓库的主分支 `main`。
- **Codex_Review**: Codex 对 PR 的评审，结论以 PR 评论或 review 形式回帖。
- **Excluded_Content**: 不得推送的内容：`画廊\`（受版权的论文图）、`维护记录` 中的大体量证据、课题数据、含本机绝对路径的内容、GPL 授权的 SCP 源码。
- **Protected_Bytes**: 作者 user block 与需保持原始字节的文件（含行尾），git 不得改写。
- **Legacy_Taskbooks**: 现有文件任务书 T1–T7、P1、P2、M1–M3、R1，以及 `文档/SCP持续入库与新规则/remaining-gaps.md`。
- **Rule_Docs**: `知识库/AGENTS.md`、staged `assets/AGENTS.md`、`SKILL.md` 及其 `references/`。
- **Project_Dir**: 课题自身目录，课题数据存于 `<课题>/wiki-use/_project/`。

## Requirements

### Requirement 1: 前置检查与首次授权

**User Story:** 作为用户，我希望 agent 在任何网络操作前先确认 gh 可用并取得我的一次性授权，以便不会在未知账号下误建仓库或误推送。

#### Acceptance Criteria

1. WHEN GH_Wrapper 的任一访问 GitHub 的子命令启动, THE GH_Wrapper SHALL 检查 gh CLI 是否可执行、是否已认证，并报告当前认证账号。纯本地子命令 `guard` 与 `protect-baseline`（在 pre-push hook 与 CI 中离线运行）例外，不做该检查。
2. IF 访问 GitHub 的子命令启动时 gh CLI 不可执行或未认证, THEN THE GH_Wrapper SHALL 停止执行，并输出安装与 `gh auth login` 的操作说明，且不自动安装。
3. WHEN Agent 准备首次创建远程仓库或首次推送, THE Agent SHALL 向用户列出目标账号/组织、仓库名、可见性（private）与待推送提交范围，并在收到用户明确授权后执行。
4. IF 目标远程仓库的可见性不是 private, THEN THE GH_Wrapper SHALL 拒绝推送并报告该仓库的实际可见性。

### Requirement 2: 仓库布局与推送范围

**User Story:** 作为用户，我希望只有代码（开发）与知识库被推到私有仓库，以便版权图、课题数据与大体量证据只留在本地。

#### Acceptance Criteria

1. THE Agent SHALL 将 `开发\` 与 `知识库\` 的内容托管到 GitHub 私有仓库，仓库数量与对应关系以设计文档的决定为准。
2. THE Agent SHALL 在每个被推送仓库的 `.gitignore` 中排除 Excluded_Content 中可按路径识别的全部类别（画廊、维护记录、GPL 源码目录、课题数据）；按内容识别的类别（本机绝对路径、GPL 许可头）由 Push_Guard 拦截。
3. WHEN 仓库布局确定, THE Agent SHALL 更新根目录 README 中关于 git 仓库结构的描述，使其与实际布局一致。
4. THE Agent SHALL 在 README 中记录每个本地仓库对应的远程地址与默认分支。

### Requirement 3: 推送前防泄漏检查

**User Story:** 作为用户，我希望每次推送前自动检查泄漏，以便被忽略的内容不会因误操作进入 GitHub。

#### Acceptance Criteria

1. WHEN Agent 或 GH_Wrapper 执行推送, THE Push_Guard SHALL 检查待推送提交中的全部文件路径与新增内容。
2. IF 待推送内容包含画廊图片、GPL SCP 源码、超过设计文档规定大小阈值的证据文件或本机绝对路径字符串, THEN THE Push_Guard SHALL 中止推送并列出命中文件与命中规则。
3. THE Push_Guard SHALL 以本地 git hook 与 GH_Wrapper 内置检查两种方式生效，任一方式均可独立拦截推送。
4. THE CI_Pipeline SHALL 对每个 PR 重复执行 Push_Guard 的检查规则，命中时将该 PR 的检查状态标为失败。

### Requirement 4: 受保护字节与行尾

**User Story:** 作为知识库作者，我希望 git 不改写我的 user block 与原始字节，以便提交、检出、推送前后文件逐字节一致。

#### Acceptance Criteria

1. THE Agent SHALL 在每个仓库中提供 `.gitattributes`，为 Protected_Bytes 所在路径关闭行尾转换与文本规范化。
2. WHEN 一个仓库完成克隆或检出, THE Protected_Bytes 文件 SHALL 与提交时的字节内容一致。
3. THE CI_Pipeline SHALL 校验 Protected_Bytes 文件的哈希，与仓库内记录的基准哈希不一致时将检查状态标为失败。

### Requirement 5: 未提交工作的分批入库（V5）

**User Story:** 作为用户，我希望 10-23 至 10-26 已部署但未提交的工作先按主题分批提交，以便首次推送前历史清晰可追溯。

#### Acceptance Criteria

1. WHEN Agent 准备首次推送 `开发` 仓库, THE Agent SHALL 先将未提交改动按主题（方法族、最小运行闭包、taxonomy/输入绑定、课题状态层）分批提交到本地。
2. THE Agent SHALL 在每个分批提交的说明中写明主题与涉及的主要文件。
3. WHEN 分批提交完成, THE Agent SHALL 核对 staged 目录内容与 5 处技能目录部署副本的哈希，并报告一致或差异清单。
4. IF 存在无法归入任一主题的未提交改动, THEN THE Agent SHALL 列出这些文件并暂停首次推送，等待用户决定。

### Requirement 6: 分支树的创建与收尾

**User Story:** 作为用户，我希望新课题或新入库批次一启动就有长期分支与子任务分支，以便工作按 GitHub 方式分层管理。

#### Acceptance Criteria

1. WHEN Agent 执行 `wiki.py gh start-batch <类型> <名称>`, THE GH_Wrapper SHALL 从 Main_Branch 创建 `project/<名称>` 或 `ingest/<名称>` 的 Long_Branch，并创建同名 Milestone。
2. WHEN Agent 执行 `wiki.py gh start-task <批次> <阶段> <主题>`, THE GH_Wrapper SHALL 从对应 Long_Branch 创建 `task/<批次>-<阶段>-<主题>` 的 Task_Branch，并在该 Milestone 下创建 Issue。
3. WHEN Agent 执行 `wiki.py gh finish-task`, THE GH_Wrapper SHALL 推送当前 Task_Branch，并创建以所属 Long_Branch 为目标、关联对应 Issue 的 PR。
4. WHEN Agent 执行 `wiki.py gh close-batch <批次>`, THE GH_Wrapper SHALL 在该 Milestone 下全部 Issue 关闭后，创建从 Long_Branch 到 Main_Branch 的 PR。
5. IF 分支名或阶段不符合命名规则, THEN THE GH_Wrapper SHALL 拒绝执行并输出合法命名示例。
6. IF `close-batch` 执行时该 Milestone 仍有未关闭 Issue, THEN THE GH_Wrapper SHALL 拒绝创建 PR 并列出未关闭 Issue。

### Requirement 7: 知识库写入落到任务分支

**User Story:** 作为用户，我希望 `wiki.py save` 把写入提交到当前任务分支而不是 main，以便每次知识库改动都经过 PR 与评审。

#### Acceptance Criteria

1. WHEN `wiki.py save` 完成一次写入, THE Wiki_CLI SHALL 将该写入提交到知识库仓库的当前分支。
2. IF 知识库仓库的当前分支是 Main_Branch 或 Long_Branch, THEN THE Wiki_CLI SHALL 拒绝写入、还原本次已写页面，并提示先执行 `start-task`。
3. THE Wiki_CLI SHALL 在提交说明中记录写入的页面路径、所属 Issue 编号与执行写入的 Agent 名称。
4. WHILE 某个工作树已被一个 Agent 登记为活动写入者, THE Wiki_CLI SHALL 拒绝其他 Agent 在该工作树中的写入，并报告当前持有者与其分支。
5. WHERE 多个 Agent 并行工作, THE GH_Wrapper SHALL 为每个 Agent 提供独立的 git worktree，每个 worktree 对应一个 Task_Branch。
6. IF 前端经 `server.py` 写入端点发起写入且 server 所指检出的当前分支是 Main_Branch 或 Long_Branch, THEN THE Wiki_CLI SHALL 拒绝写入、不留下页面改动，并向页面返回"请先 start-task"的错误信息。
7. WHERE 写入在 `--worktree` 创建的工作树中进行, THE GH_Wrapper SHALL 让被 git 忽略的 GPL 源码目录在该工作树中可读（目录联接指回主检出），且移除工作树时不得删除联接目标的内容。

### Requirement 8: Issue、Milestone、Label 与 PR 模板

**User Story:** 作为用户，我希望任务、评审、验收都在 GitHub 上有统一结构，以便不再维护文件任务书。

#### Acceptance Criteria

1. THE Agent SHALL 以 Milestone 表示一个课题或入库批次，以 Issue 表示一个子任务。
2. THE Agent SHALL 在每个仓库中维护一套 Label 方案，至少覆盖类型（project/ingest）、阶段（P0–P5、T 系列）、状态（待评审、需修改、已验收）与阻塞原因。
3. THE Agent SHALL 在每个仓库中提供 PR 模板，包含关联 Issue、改动摘要、测试结果、本地专属验证结果、受保护字节核验与未完成项。
4. THE Agent SHALL 在 Issue 中记录验收结论，并在本地大体量证据存在时写明其本地相对路径与哈希，证据文件本身保留在本地。

### Requirement 9: Codex 评审结论回帖

**User Story:** 作为用户，我希望 Codex 的评审结论直接出现在 PR 上，以便合并决策有可见依据。

#### Acceptance Criteria

1. WHEN 一个 PR 被创建或更新, THE Agent SHALL 发起 Codex_Review 并将结论以 PR review 形式回帖。
2. THE Codex_Review 回帖 SHALL 包含结论（通过 / 需修改）、发现的问题列表与所评审的提交 SHA。
3. IF PR 在 Codex_Review 之后新增提交, THEN THE Merge_Gate SHALL 将先前的评审结论视为失效，直到针对最新提交的 Codex_Review 回帖。

### Requirement 10: 合并门禁与分支保护

**User Story:** 作为用户，我希望 agent 在门禁通过后自主合并，以便我只看结果，同时 main 不会被直接改动。

#### Acceptance Criteria

1. THE Agent SHALL 为 Main_Branch 与每个 Long_Branch 配置分支保护，禁止直接推送，要求经 PR 合并。
2. WHEN 一个 PR 的 CI_Pipeline 全部通过且最新提交的 Codex_Review 结论为通过, THE Agent SHALL 合并该 PR，目标分支包括 Main_Branch。
3. IF CI_Pipeline 失败或 Codex_Review 结论为需修改, THEN THE Agent SHALL 保持 PR 未合并，并在 PR 中记录失败原因与修复计划。
4. WHEN 一个 PR 合并完成, THE Agent SHALL 关闭关联 Issue 并删除已合并的 Task_Branch。
5. IF GitHub 私有仓库所在的账号套餐不支持分支保护, THEN THE GH_Wrapper SHALL 在本地执行等价的门禁检查，并在 README 中记录该替代方式。

### Requirement 11: 持续集成

**User Story:** 作为开发者，我希望 CI 自动跑能在云端跑的测试，并明确哪些只能本地跑，以便门禁可信且不误报。

#### Acceptance Criteria

1. WHEN 一个 PR 被创建或更新, THE CI_Pipeline SHALL 运行 pytest、前端 `npm test` 与 `wiki.py lint`。
2. THE Agent SHALL 在设计文档中列出仅能本地运行的检查（依赖 Windows 路径、本机 R 环境或本地证据的检查）。
3. WHEN 一个 PR 涉及仅能本地运行的检查, THE Agent SHALL 在本地运行这些检查，并将结果摘要写入 PR 模板的本地专属验证一栏。
4. THE CI_Pipeline SHALL 使用仓库内的测试夹具运行，不读取 Excluded_Content。
5. WHEN CI_Pipeline 对 vault 运行 `wiki.py lint`, THE Wiki_CLI SHALL 以 `--ci` 模式把因被 git 忽略（GPL 源码目录、画廊、维护记录）而缺失的引用报告为 `LOCAL-ONLY`，不计为错误；其他缺失仍报错误。

### Requirement 12: 部署来源限制

**User Story:** 作为用户，我希望技能部署只来自已合并的 main 或 tag，以便 5 处安装副本始终对应经过评审的代码。

#### Acceptance Criteria

1. WHEN Deploy_Tool 启动, THE Deploy_Tool SHALL 核对 `开发` 仓库当前检出等于远端 Main_Branch 的最新提交或恰为一个已推送 tag，且工作区无未提交改动。
2. IF 当前检出既不等于远端 Main_Branch 最新提交也不是已推送 tag, THEN THE Deploy_Tool SHALL 中止部署并报告当前分支与提交。
3. THE Deploy_Tool SHALL 在 manifest 中记录部署所用的提交 SHA 或 tag，并保留现有的逐文件备份与哈希核验。

### Requirement 13: 旧任务书迁移

**User Story:** 作为用户，我希望现有任务书与遗留缺口迁到 GitHub，以便历史任务与未完成项在一个地方可查。

#### Acceptance Criteria

1. WHEN 首次推送完成, THE Agent SHALL 为 Legacy_Taskbooks 中每份任务书创建一个 Issue，已完成的标为关闭并附验收结论，未完成的保持打开。
2. THE Agent SHALL 将 `remaining-gaps.md` 中每个未完成缺口转为一个打开的 Issue，并归入对应 Milestone。
3. WHEN 迁移完成, THE Agent SHALL 在每份原任务书文件顶部写明对应 Issue 链接与"已迁移，停止维护"的标记。
4. IF 原任务书引用的证据属于 Excluded_Content, THEN THE Agent SHALL 在 Issue 中只记录该证据的本地相对路径与哈希。

### Requirement 14: 规则文档同步

**User Story:** 作为 agent 使用者，我希望规则文档描述 GitHub 工作流，以便任何 agent 读规则就能按同一方式操作。

#### Acceptance Criteria

1. THE Rule_Docs SHALL 描述分支命名、Milestone/Issue/Label 用法、PR 模板、Codex_Review 回帖、Merge_Gate、部署来源限制，以及主检出停在 Main_Branch 时前端写入被拒、需经 `RWIKI_WIKI_ROOT` 让 server 指向任务分支检出的用法。
2. THE Rule_Docs SHALL 列出 GH_Wrapper 各子命令的用途、参数与前置条件。
3. THE Rule_Docs SHALL 删除或改写关于维护文件任务书与 `save` 提交到 master 的旧描述。
4. WHEN Rule_Docs 更新, THE Agent SHALL 经 Deploy_Tool 将更新同步到 5 处技能目录并完成哈希核验。

### Requirement 15: 课题数据边界

**User Story:** 作为课题使用者，我希望课题数据留在课题自身目录，以便知识库仓库的 project 分支只承载知识库侧改动。

#### Acceptance Criteria

1. THE Agent SHALL 将课题数据保存在 Project_Dir 的 `wiki-use/_project/` 下，不提交到知识库仓库或 `开发` 仓库。
2. WHILE 工作在 `project/<课题>` Long_Branch 或其 Task_Branch 上, THE Wiki_CLI SHALL 只提交知识库侧改动（record-use 记录与经验回写）。
3. IF 一次提交包含 Project_Dir 内的文件, THEN THE Push_Guard SHALL 中止推送并列出这些文件。
