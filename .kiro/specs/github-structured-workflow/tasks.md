# Implementation Plan: github-structured-workflow

## Overview

实现语言为 Python（`staged/research-wiki/rwiki/` 与 `tools/deploy.py`），外加 GitHub Actions YAML、Markdown 模板与规则文档。顺序按风险递增：

1. 纯本地、可逆的基础模块与测试（push_guard、writer_lock、ghflow 纯函数、store/config/cli/lint、deploy 门禁、假 gh 夹具）。
2. 仓库文件（`.gitattributes`、`.gitignore`、CI、模板、`local` marker）。
3. ghflow 子命令与 bootstrap 历史构造（全部在假 gh + 临时 git 仓库上测试）。
4. 规则文档同步与 README。
5. V5 分批提交与 `deploy.py --verify-only`（本地 git 操作）。
6. 网络 / 高风险操作（标注【需授权】）：bootstrap --confirm、migrate-legacy、首个真实 PR、从 main 部署。

路径约定：`<skill>` = `E:\research-wiki\开发\staged\research-wiki`；`<dev>` = `E:\research-wiki\开发`；`<vault>` = `E:\research-wiki`。临时文件一律写 `E:\research-wiki-env\tmp`。不安装任何新依赖；属性测试用标准库 `random.Random(seed)`，每个性质 ≥ 100 次迭代，失败信息含 seed，docstring 带 `Feature: github-structured-workflow, Property <n>: <标题>`。

## Tasks

- [x] 1. 基线与测试支撑
  - [x] 1.1 在任何代码改动前记录 V5 基线
    - 写脚本 `E:\research-wiki-env\tmp\v5_baseline.py`：列出 `<dev>` 的 `git status --porcelain -uall -z` 全部未提交文件（`-uall` 展开未跟踪目录），对存在的文件执行 `git hash-object -w` 存入对象库、删除项记为删除，同时记录文件模式，结果写 `E:\research-wiki-env\tmp\v5-baseline.json`（路径 → 状态、blob sha、字节数）
    - 不修改工作区与索引；该基线用于第 13 步把 10-23 至 10-26 的工作与本特性的新改动分开提交
    - _Requirements: 5.1, 5.4_
  - [x] 1.2 建立假 gh 与临时 git 仓库夹具
    - 新增 `<skill>/tests/fake_gh/gh.py` 与 `gh.cmd`：从 `FAKE_GH_STATE` 读场景 JSON（账号、认证态、仓库可见性、Milestone/Issue/PR/checks/reviews/comments、分支保护 API 返回码），每次 argv 追加到 `FAKE_GH_LOG`，按子命令修改状态并输出与真实 gh 相同形状的 JSON
    - 在 `<skill>/tests/conftest.py` 增加 fixture：`fake_gh`（`monkeypatch.setenv("PATH", …)` 置前）、`git_pair`（`tmp_path` 下工作仓库 + `--bare` 远端，`core.autocrlf=true`）、`wiki_repo`（含 `知识库` 子树的最小 vault）
    - _Requirements: 1.1, 1.2, 11.4_

- [x] 2. 实现 rwiki/push_guard.py
  - [x] 2.1 规则加载与单文件分类
    - 实现 `Rules`、`load_rules(cfg, repo)`（默认 5 MB、`**/SCP-local/**`、GPL 标记）、`.push-guard-allow` 解析（只接受 `abs-path`/`size`，其他取值或缺理由抛 `WikiError`）、`ABS_PATH`、`find_abs_paths`、`classify`（gallery、project-data、gpl-path、gpl-header、size、abs-path；`*.lnk` 直接命中，二进制跳过 abs-path）
    - _Requirements: 2.2, 3.2, 15.3_
  - [x]* 2.2 属性测试：规则分类与参考模型一致
    - **Property 2: 规则分类与参考模型一致**
    - 文件 `tests/test_push_guard.py`；随机生成路径/大小/新增行/文件头与 allow 内容，对照测试内参考模型；断言豁免永不去掉 gallery、gpl-*、project-data
    - **Validates: Requirements 3.2, 15.3**
  - [x] 2.3 推送范围扫描与 pre-push 入口
    - 实现 `push_ranges`（远端全 0 时用 `--not --remotes=<remote>`）、`scan`（逐提交 `git log -p -U0 --no-renames` + `git diff-tree` 取 blob 大小，被后续提交删除的违规同样报告）、`pre_push`（拒绝推送 `legacy/*`；本地门禁模式下拒绝更新 `main`/`project/*`/`ingest/*`，新建长期分支且 sha == `origin/main` 除外，`RWIKI_BOOTSTRAP=1` 放行；命中按 `<rule>\t<path>\t<commit>\t<detail>` 打印并返回 1）
    - _Requirements: 3.1, 3.2, 3.3, 10.5_
  - [x]* 2.4 属性测试：推送范围扫描完备
    - **Property 3: 推送范围扫描完备**
    - 文件 `tests/test_push_guard_scan.py`；在 `git_pair` 上随机构造“加入违规 → 改写/删除”的提交序列，断言报告覆盖每个曾加入的违规文件，且经 hook 推送后远端 ref 不变
    - **Validates: Requirements 3.1, 3.2**
  - [x] 2.5 GPL 忽略托管块与作者块基准
    - 实现 `gpl_method_dirs`（读 `methods/*.md` frontmatter `license` 匹配 `^(A|L)?GPL`，推导 `methods/<id>/code/`、`source/`）、`sync_ignore`（重写 `# >>> push-guard gpl` … `# <<< push-guard gpl` 托管块，变化时返回 True，块外字节不动）
    - 实现 `USER_BLOCK`、`user_blocks`、`baseline`（遍历 `git ls-files '*.md'`，按块 SHA-256 含行尾）、`check_baseline`
    - _Requirements: 4.3, 15.3_
  - [x]* 2.6 属性测试：作者块基准只锁作者内容
    - **Property 5: 作者块基准只锁作者内容**
    - 文件 `tests/test_protected.py`；随机页面与随机单字节修改，断言 `check_baseline` 非空当且仅当修改落在作者块内（含 CRLF↔LF 变化）
    - **Validates: Requirements 4.3**
  - [x]* 2.7 push_guard 单元测试
    - 文件 `tests/test_push_guard_hook.py`：`sync_ignore` 幂等且保留块外内容；非法 allow 规则报错；hook 拒绝 `legacy/*`；本地门禁模式拒绝直接推 `main`、放行新建长期分支；Project_Dir 文件被拦截
    - _Requirements: 3.3, 10.5, 15.3_

- [x] 3. 实现 rwiki/writer_lock.py
  - [x] 3.1 按 worktree 的写入锁
    - 实现 `lock_path`（`git rev-parse --absolute-git-dir` / `rwiki-writer.lock`）、`acquire`（`O_CREAT|O_EXCL`；同 agent+branch 重入返回原锁；否则抛错并报持有者与分支）、`read_lock`、`require_holder`、`release`；pid 只作信息，不做存活判断
    - _Requirements: 7.4_
  - [x]* 3.2 writer_lock 单元测试
    - 文件 `tests/test_writer_lock.py`：主检出与 `git worktree add` 出的 worktree 锁文件路径不同；重入；他人持有时报错内容；release 后可重新获取
    - _Requirements: 7.4, 7.5_

- [x] 4. 实现 rwiki/ghflow.py 的封装与纯函数
  - [x] 4.1 gh/git 薄封装、命名规则与分支元数据
    - 实现 `gh`、`gh_json`、`git`、`require_gh`（`shutil.which("gh")` + `gh auth status` + `gh api user`；失败消息含 gh 安装页地址与 `gh auth login`，不安装）、`require_private`（`gh repo view --json visibility`，非 PRIVATE 报实际值）、`push`（require_private → `push_guard.scan` → `git push -u origin`）
    - 实现 `STAGE`、`SLUG`（≤ 40 字符）、`long_branch`、`task_branch`、`parse_task_branch`，非法时错误含 `task/scp-wave3-P2-harmony`、`ingest/scp-wave3` 示例
    - 实现 `read_meta`/`write_meta`（`<git-common-dir>/rwiki-branches.json`）
    - _Requirements: 1.1, 1.2, 1.4, 3.1, 6.5_
  - [x]* 4.2 属性测试：分支命名往返与拒绝（纯函数部分）
    - **Property 1: 分支命名往返与拒绝**
    - 文件 `tests/test_ghflow_naming.py`；随机合法 slug/阶段往返；随机非法串（大写、空格、中文、P6、缺段、超长）均抛错且消息含合法示例
    - **Validates: Requirements 6.1, 6.2, 6.5**
  - [x] 4.3 评审、门禁、Issue 正文与迁移标记的纯函数
    - 实现 `render_review`、`parse_review_marker`（`<!-- codex-review: verdict=pass|changes sha=<40位> -->`）、`gate_decision(checks, entries, head)`、`open_issues_blocking`
    - 实现 `render_issue_body`（`rwiki-task` 标记、目标、验收标准、本地证据表只含相对路径与 sha256、验收结论）与 `add_migrated_marker(data: bytes, url) -> bytes`（已有标记时不重复添加，原字节原样保留在标记之后）
    - _Requirements: 6.6, 8.4, 9.2, 9.3, 10.2, 10.3, 13.3, 13.4_
  - [x]* 4.4 属性测试：评审标记往返
    - **Property 11: 评审标记往返**
    - 文件 `tests/test_ghflow_review.py`
    - **Validates: Requirements 9.2**
  - [x]* 4.5 属性测试：合并门禁判定
    - **Property 12: 合并门禁判定**
    - 文件 `tests/test_ghflow_gate.py`；随机 checks（含空列表、pending、fail）、随机 review/comment 序列（含过期 sha、后来的 changes），对照参考判定
    - **Validates: Requirements 9.3, 10.2, 10.3**
  - [x]* 4.6 属性测试：证据只以相对路径与哈希出现
    - **Property 10: 证据只以相对路径与哈希出现**
    - 文件 `tests/test_ghflow_render.py`
    - **Validates: Requirements 8.4, 13.4**
  - [x]* 4.7 属性测试：迁移标记幂等且保留原字节
    - **Property 15: 迁移标记幂等且保留原字节**
    - 文件 `tests/test_ghflow_marker.py`；随机字节（BOM、CRLF、无末尾换行）多次加标记
    - **Validates: Requirements 13.3**
  - [x]* 4.8 gh 前置检查单元测试
    - 文件 `tests/test_ghflow_gh.py`：gh 不存在 / 未认证 / 已认证三态（报告 login）；PUBLIC 与 INTERNAL 拒推且远端 ref 不变
    - _Requirements: 1.1, 1.2, 1.4_

- [x] 5. store / config / cli / lint 改动
  - [x] 5.1 config.py 增加 push_guard、github 与 wiki_root 覆盖
    - `Config` 增加 `push_guard: dict`、`github: dict`（缺省空字典）；`load_config(path, wiki_root=None)` 覆盖顺序 `--wiki-root` > `RWIKI_WIKI_ROOT` > 文件值
    - _Requirements: 7.5_
  - [x] 5.2 store.save 分支策略与 trailer
    - 实现纯函数 `save_policy(branch)` → `refuse-main|refuse-long|task|plain` 与 `trailers(issue, agent, pages)`（超过 20 个页面写 `… (+N)`）
    - `save`：refuse-* 在写 `log.md`、`git add` 之前抛错（提示 `wiki.py gh start-task`）；task 分支调用 `writer_lock.require_holder(root, RWIKI_AGENT, branch)`，Issue 号取自元数据；`git add` 前调用 `push_guard.sync_ignore`；`git diff --cached --name-only --relative -- .` 取页面，提交附 trailer；plain 分支保持原行为，仅在设置 `RWIKI_AGENT` 时附 `Agent`/`Pages`
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 15.2_
  - [x]* 5.3 属性测试：save 分支策略与子树范围
    - **Property 7: save 分支策略与子树范围**
    - 文件 `tests/test_store_branch.py`；随机分支名与 wiki 内外改动，断言拒绝时 HEAD 与 `log.md` 不变，提交只含 wiki 子树
    - **Validates: Requirements 7.1, 7.2, 15.2**
  - [x]* 5.4 属性测试：提交 trailer 往返
    - **Property 8: 提交 trailer 往返**
    - 文件 `tests/test_store_trailers.py`；页面名含中文与空格，用 `git interpret-trailers --parse` 解析
    - **Validates: Requirements 7.3**
  - [x]* 5.5 属性测试：写入锁排他
    - **Property 9: 写入锁排他**
    - 文件 `tests/test_store_lock.py`；随机多 Agent 的 acquire/save 交替序列
    - **Validates: Requirements 7.4**
  - [x] 5.6 cli.py：全局 --wiki-root、lint --ci 参数与 gh 子命令组骨架
    - `parser()` 增加全局 `--wiki-root`、`lint --ci`、`gh` 子命令组；本任务接入 `gh guard [--range] [--pre-push <remote> <url>] [--sync-ignore]` 与 `gh protect-baseline [--check]`（不做 gh 前置检查，D16）；其余子命令在第 10 步各自接入
    - _Requirements: 3.3, 4.3_
  - [x] 5.7 lint.py 增加 --ci 模式
    - 缺失文件若被 vault 忽略（`git check-ignore`：GPL 托管块、`画廊/`、`维护记录/`），输出 `LOCAL-ONLY` 行而非 `ERROR`，不影响退出码；未被忽略的缺失仍报 `ERROR`
    - _Requirements: 11.1, 11.4, 11.5_
  - [x]* 5.8 CLI 单元测试
    - 文件 `tests/test_cli_gh.py`：wiki_root 覆盖顺序；`lint --ci` 对缺失 GPL 目录、维护记录引用不报 ERROR，对未忽略的缺失仍报 ERROR；`gh guard --range` 命中时退出 1；PATH 中无 gh 时 `gh guard`、`gh protect-baseline` 仍正常运行（R1.1 例外）；main 与长期分支上经 `server.py` 写入端点返回“请先 start-task”且页面字节还原
    - _Requirements: 1.1, 3.3, 7.2, 7.6, 11.1, 11.5_

- [x] 6. tools/deploy.py 来源门禁
  - [x] 6.1 实现 source_gate、verify_only 与 manifest 字段
    - `source_gate()`：`<dev>` `status --porcelain` 为空；`git fetch origin`；HEAD == `origin/main` 或 HEAD 恰有已推送 tag（`describe --exact-match` + `ls-remote --tags`）；否则 `sys.exit` 报当前分支、HEAD、origin/main
    - `verify_only()`：只比较 staged 与 5 处副本哈希，打印差异清单，不写入、不检查门禁
    - `main()` 先调 `source_gate()`；manifest 增加 `source_commit`、`source_tag`；保留逐文件备份与哈希 `assert`；用法 `deploy.py <record> "<note>"` 或 `deploy.py --verify-only`
    - _Requirements: 5.3, 12.1, 12.2, 12.3_
  - [x]* 6.2 属性测试：部署来源判定
    - **Property 13: 部署来源判定**
    - 文件 `<vault>/tools/tests/test_deploy.py`；随机（干净与否、HEAD、origin/main、tag 是否推送）组合，技能目录用 `tmp_path` 替身，断言拒绝时零写入
    - **Validates: Requirements 12.1, 12.2**

- [x] 7. Checkpoint - 本地基础模块
  - 在 `<skill>` 运行 `pytest -m "not r and not compose"`，在 `<vault>` 运行 `pytest tools/tests`；确保全部通过，有疑问时询问用户。

- [x] 8. 仓库文件
  - [x] 8.1 dev 仓库忽略、属性与配置拆分
    - 新增 `<dev>/.gitattributes`（`* -text`，`*.png *.pdf *.rds binary`）、`<dev>/.push-guard-allow`（仅 abs-path/size，每条带理由）
    - 更新 `<dev>/.gitignore`：`staged/research-wiki/config.json`、`codex/`、画廊图片类、`**/wiki-use/_project/`、`*.lnk`、`.pytest_cache/`；以 `gh guard` 干跑结果为准补齐
    - 新增 `staged/research-wiki/config.example.json`（占位路径）与 `<dev>/ci/config.ci.json`（相对路径，不含 push_guard）
    - 本任务只改工作区文件，不碰 `<dev>` 的索引：`git rm --cached staged/research-wiki/config.json` 推迟到 13.2 的 `chore(repo)` 提交，否则会混进 V5 主题提交
    - _Requirements: 2.2, 4.1, 11.4, 15.1_
  - [x] 8.2 vault 仓库忽略与属性
    - 新增 `<vault>/.gitattributes`（同 8.1）、`<vault>/.push-guard-allow`
    - 更新 `<vault>/.gitignore`：保留 `/开发/`，加入 `/画廊/`、`/维护记录/`、`*.lnk`、`Rplots.pdf`、`**/wiki-use/_project/`、`.codegraph/`、`.omo/`、`.launcher.log`、`.pytest_cache/`；运行 `wiki.py gh guard --sync-ignore` 写入 `知识库/.gitignore` 的 GPL 托管块
    - _Requirements: 2.2, 4.1, 15.1, 15.3_
  - [x] 8.3 pytest `local` marker
    - `<skill>/pytest.ini` 增加 `local: 需要本机路径、真实画廊或本地证据`；按内容给读真实画廊、本机 taxonomy、`E:\research-wiki-env\sources` 的现有测试加 `@pytest.mark.local`，能用 `tmp_path` 替代的改用 `tmp_path`
    - _Requirements: 11.2, 11.4_
  - [x] 8.4 dev CI 工作流
    - `<dev>/.github/workflows/ci.yml`：`pull_request`（全部分支）+ `push: [main]`；`windows-latest`；checkout `fetch-depth: 0` → setup-python → `pip install -r staged/research-wiki/requirements.lock.txt` → `pytest -m "not r and not compose and not local"` → `frontend/` 下 `npm ci && npm test` → `wiki.py --config ci/config.ci.json --wiki-root $RUNNER_TEMP/w init` 后 `lint` → `wiki.py gh guard --range origin/${{ github.base_ref }}..HEAD`
    - _Requirements: 3.4, 11.1, 11.4_
  - [x] 8.5 vault CI 工作流
    - `<vault>/.github/workflows/ci.yml`：检出 vault（`fetch-depth: 0`）与 dev（`ssh-key: ${{ secrets.DEV_DEPLOY_KEY }}`，`ref: main`，放到 `开发/`）→ pip install → `lint --ci` → `gh guard --range …` → `gh protect-baseline --check` → `pytest tools/tests`
    - _Requirements: 3.4, 4.3, 11.1, 11.4, 11.5_
  - [x] 8.6 PR 与 Issue 模板（两个仓库）
    - `.github/pull_request_template.md`：关联 Issue / 改动摘要 / 测试结果（CI）/ 本地专属验证 / 受保护字节核验 / 未完成项
    - `.github/ISSUE_TEMPLATE/task.md`：与 `render_issue_body` 小节一致（目标、验收标准、本地证据表、验收结论）
    - _Requirements: 8.1, 8.3, 8.4_
  - [x] 8.7 生成受保护字节基准
    - 运行 `wiki.py gh protect-baseline` 生成 `<vault>/知识库/.protected-hashes.json`，随后 `--check` 返回空
    - _Requirements: 4.3_
  - [x]* 8.8 属性测试：字节保真
    - **Property 4: 字节保真**
    - 文件 `tests/test_gitattributes.py`；在 `core.autocrlf=true` 仓库中写入本设计的 `.gitattributes`，随机 LF/CRLF/混合/BOM/无末尾换行内容提交后克隆、检出，逐字节比较
    - **Validates: Requirements 4.1, 4.2**
  - [x]* 8.9 仓库文件单元测试
    - 文件 `tests/test_repo_files.py`：PR 模板含 6 个小节；两份 ci.yml 的 pytest 表达式含 `not local`；两仓库 `.gitattributes` 含 `* -text`
    - _Requirements: 4.1, 8.3, 11.1_

- [x] 9. Checkpoint - 仓库文件
  - 运行完整本地 pytest（`<skill>` 不加 marker 过滤、`<vault>/tools/tests`），以及 `wiki.py gh guard --range` 针对两仓库当前 HEAD 的干跑；确保全部通过，有疑问时询问用户。

- [x] 10. ghflow 子命令与 bootstrap
  - [x] 10.1 preflight
    - 输出 JSON：gh 路径/版本、认证账号、owner、两仓库存在性与可见性、分支保护探测（403 → `local`）、两个本地仓库当前分支与未提交数、待推送范围（dev 重放提交列表、vault 快照文件数与总大小）、guard 干跑结果、`DEV_DEPLOY_KEY` 是否已设置；有阻断项退出 1；在 cli.py 注册 `gh preflight`
    - _Requirements: 1.1, 1.2, 1.3, 10.5_
  - [x] 10.2 start-batch 与 start-task
    - `start-batch <project|ingest> <名称> --title --repo dev|vault`：从 `origin/main` 建长期分支 → 按标题查重后建 Milestone → `push`（经 guard）→ 写元数据
    - `start-task <批次> <阶段> <主题> --title [--worktree]`：要求 `RWIKI_AGENT`；按 `rwiki-task` 标记查重后建 Issue（Milestone、`type:*`、`stage:*`、`status:进行中`）；主检出模式 `git switch -c`，仅允许 `知识库/` 内未提交改动随行，其他已跟踪改动拒绝并列出；`--worktree` 在 `worktree_root` 下 `git worktree add` 并为 GPL 托管块目录建 `mklink /J` 联接，输出 `RWIKI_WIKI_ROOT`；写元数据并 `writer_lock.acquire`；在 cli.py 注册两个子命令
    - _Requirements: 6.1, 6.2, 6.5, 7.4, 7.5, 7.7, 8.1_
  - [x]* 10.3 属性测试：分支命名拒绝不产生任何对象
    - **Property 1: 分支命名往返与拒绝**
    - 文件 `tests/test_ghflow_branching.py`；随机非法输入调用 start-batch/start-task，断言本地分支、`FAKE_GH_LOG` 中无写操作；合法输入时长期分支名等于 Milestone 标题
    - **Validates: Requirements 6.1, 6.2, 6.5**
  - [x]* 10.4 start-task 单元测试
    - 文件 `tests/test_ghflow_start_task.py`：两个 Agent 各自 `--worktree` 得到不同 worktree 与锁；随行规则；中途失败后重跑不重复建 Issue；worktree 内 GPL 联接可读且 `git status` 不显示它们；在 worktree 中运行 `lint`（非 `--ci`）不因 GPL 目录缺失报错
    - _Requirements: 6.2, 7.4, 7.5, 7.7_
  - [x] 10.5 finish-task 与 review
    - `finish-task [--local-report]`：拒绝未提交的已跟踪改动 → `push` → 按 `--head` 查重后 `gh pr create --base <长期分支>`，正文填 PR 模板（`Refs #n`、本地专属验证、`protect-baseline --check` 结果）→ Issue 标签 `status:待评审`
    - `review <pr> --verdict pass|changes --findings <文件>`：取 `headRefOid` → `gh pr review --comment --body render_review(...)` → 更新状态标签；在 cli.py 注册两个子命令
    - _Requirements: 6.3, 8.3, 9.1, 9.2, 11.3_
  - [x] 10.6 merge 与 close-batch
    - `merge <pr> [--plan]`：`gh pr checks` + `gh pr view` → `gate_decision`；不通过回帖 `<!-- rwiki-gate: blocked sha=<head> -->` + 原因 + 计划（缺省“待补”）并退出 1；通过 `gh pr merge --merge --match-head-commit <head> --delete-branch`；task PR 合并后关闭 Issue（附 PR 与合并 SHA）、`status:已验收`、释放锁、先逐个 `rmdir` GPL 联接（确认是 reparse 点、不带 `/s`）再 `git worktree remove`（不加 `--force`）、删本地分支、主检出切回 `main` 并 `pull --ff-only`；长期分支 PR 合并后关闭 Milestone 并删除长期分支；PR 已合并时直接执行合并后步骤
    - `close-batch <批次>`：有未关闭 Issue 时拒绝并列出；否则建 `--base main` 的 PR，正文列出 Milestone 内全部 Issue；在 cli.py 注册两个子命令
    - _Requirements: 6.4, 6.6, 9.3, 10.2, 10.3, 10.4_
  - [x]* 10.7 属性测试：close-batch 只在全部关闭时开 PR
    - **Property 6: close-batch 只在全部关闭时开 PR**
    - 文件 `tests/test_ghflow_close_batch.py`
    - **Validates: Requirements 6.4, 6.6**
  - [x]* 10.8 merge 单元测试
    - 文件 `tests/test_ghflow_merge.py`：门禁不通过时无 `gh pr merge` 调用且有阻断回帖；通过后的清理序列；移除 `--worktree` 后联接目标目录的文件数与哈希不变；长期分支 PR 合并关闭 Milestone；重跑幂等
    - _Requirements: 7.7, 10.2, 10.3, 10.4_
  - [x] 10.9 migrate-legacy
    - `migrate-legacy --map <legacy-map.json> [--dry-run]`：按 `<!-- rwiki-legacy: id=… -->` 查重；任务书 Issue 建在 dev，状态与映射一致，已完成的附结论后关闭；缺口按 `repo` 字段建打开的 Issue 并归入 `legacy/<来源目录名>` Milestone；证据只写相对路径与 sha256；非 dry-run 时对原文件调用 `add_migrated_marker`；在 cli.py 注册子命令
    - _Requirements: 13.1, 13.2, 13.3, 13.4_
  - [x]* 10.10 属性测试：遗留迁移幂等
    - **Property 14: 遗留迁移幂等**
    - 文件 `tests/test_ghflow_migrate.py`；随机映射连续执行两次
    - **Validates: Requirements 13.1, 13.2**
  - [x] 10.11 历史构造：replay_filtered、snapshot_orphan、install_hook
    - `replay_filtered`：用临时 `GIT_INDEX_FILE` + `commit-tree` 逐个重放 `master` 提交，去掉被忽略路径，保留作者、时间与说明，加 `Legacy-Commit: <sha>` trailer
    - `snapshot_orphan`：把过滤后的当前工作区写成单个无父提交
    - 切换到新 `main` 时只移动 HEAD 与索引（`git symbolic-ref HEAD refs/heads/main` + `git read-tree main`），不用 `git switch`/`checkout`，避免把旧 `master` 跟踪而新 `main` 未跟踪的 `画廊/`、`维护记录/`、`config.json`、`codex/` 从磁盘删除
    - `install_hook`：写 `.git/hooks/pre-push`，调用 `sys.executable` + 本 `wiki.py` 绝对路径的 `gh guard --pre-push`（hook 不入库）
    - _Requirements: 2.1, 3.3, 5.1, 5.2_
  - [x] 10.12 bootstrap 编排
    - 无 `--confirm`：等同 preflight 并输出授权摘要（账号/组织、仓库名、private、待推送范围），不发任何网络写
    - `--confirm`：preflight 无阻断 → 校验仓库文件（第 8 步产出）已存在并会进入新 `main`，缺失即中止 → `master` 改名 `legacy/master` → 构造 `main`（dev 重放、vault 快照）→ `symbolic-ref` + `read-tree` 切到 `main`（10.11），核对原跟踪的忽略目录文件数不变 → `install_hook` → `gh repo create --private` → `remote add` → `RWIKI_BOOTSTRAP=1` 下 `push main` → `gh label create --force` 全套 Label → ed25519 密钥写 `E:\research-wiki-env\tmp`，公钥 `deploy-key add --read-only` 到 dev，私钥 `secret set DEV_DEPLOY_KEY` 到 vault，删除临时密钥 → 探测/配置分支保护 → 元数据记 `protection: github|local`；每步先查后建；在 cli.py 注册子命令
    - _Requirements: 1.3, 1.4, 2.1, 8.2, 10.1, 10.5_
  - [x]* 10.13 历史构造单元测试
    - 文件 `tests/test_ghflow_history.py`：重放后每个提交都不含被忽略路径、作者与时间保留、trailer 指向原 sha；快照只有一个提交；切到 `main` 后原先被跟踪的忽略目录仍在磁盘；hook 拒绝推 `legacy/*`
    - _Requirements: 2.1, 3.3, 5.2_
  - [x]* 10.14 bootstrap 单元测试
    - 文件 `tests/test_ghflow_bootstrap.py`：无 `--confirm` 时 `FAKE_GH_LOG` 只有只读调用；保护 API 403 进入本地门禁模式；可见性非 PRIVATE 时不推送
    - _Requirements: 1.3, 1.4, 10.5_

- [x] 11. Checkpoint - ghflow
  - 运行完整本地 pytest（含 `local` 标记）；确保全部通过，有疑问时询问用户。

- [x] 12. 规则文档与 README
  - [x] 12.1 更新 `<vault>/知识库/AGENTS.md`
    - 描述分支命名、Milestone/Issue/Label、PR 模板、Codex 评审回帖格式、Merge_Gate、部署来源限制、main 与长期分支上 save 及前端（`server.py`）写入被拒、经 launcher 设置 `RWIKI_WIKI_ROOT` 让 UI 写到任务分支检出；GitHub 上 vault 不含 GPL 源码目录，完整 lint 与复核只在主检出或带联接的 worktree 运行；删除维护文件任务书与 save 提交到 master 的旧描述
    - _Requirements: 7.6, 11.5, 14.1, 14.2, 14.3_
  - [x] 12.2 更新 staged 规则文档
    - `<skill>/assets/AGENTS.md`、`<skill>/SKILL.md`，新增 `<skill>/references/github-workflow.md`：各 `gh` 子命令的用途、参数、前置条件（同设计表），以及仅本地运行的检查清单与 `--local-report` 用法；写明 `guard`/`protect-baseline` 不需要 gh、前端写入在 main 上被拒与 `RWIKI_WIKI_ROOT` 用法、`lint --ci` 的 `LOCAL-ONLY` 含义、worktree 联接及“不要在主检出检出 `legacy/master`”；同步删改旧描述
    - _Requirements: 1.1, 7.6, 11.2, 11.3, 11.5, 14.1, 14.2, 14.3_
  - [x] 12.3 修正根 README 的仓库结构
    - 改写 `<vault>/README.md`：两个仓库的实际布局（`知识库/` 属于根仓库，`开发/` 为独立仓库）、远程地址与默认分支 `main`（地址先写占位，在 15.4 填实）、本地门禁替代方式、不推送内容清单
    - _Requirements: 2.3, 2.4, 10.5_
  - [x] 12.4 launcher 传递 RWIKI_WIKI_ROOT
    - `tools/launcher.ps1`：环境中已设 `RWIKI_WIKI_ROOT` 时传给 server，使 UI 写入落到任务分支检出
    - _Requirements: 7.2, 7.5_
  - [x]* 12.5 规则文档单元测试
    - 文件 `tests/test_rule_docs.py`：规则文档包含全部 `gh` 子命令名；不再出现“提交到 master”与维护任务书的旧表述
    - _Requirements: 14.2, 14.3_

- [x] 13. V5 分批提交（本地）
  - [x] 13.1 生成 V5 分组计划
    - 以 1.1 的基线为准，写 `E:\research-wiki-env\tmp\v5-plan.json`：四个主题（方法族、最小运行闭包、taxonomy/输入绑定、课题状态层）+ `unassigned`；本特性产生的新改动单独归入 `github-workflow` 组，不算 unassigned
    - `unassigned` 非空时列出文件并暂停，等待用户决定；为空则继续
    - _Requirements: 5.1, 5.4_
  - [x] 13.2 按主题提交
    - 四个主题依次提交：用基线 blob（`git update-index --cacheinfo`）暂存，保证主题提交只含 10-23 至 10-26 的内容；说明格式 `feat(<主题>): <摘要>`，正文列主要文件
    - 每次提交前确认 `git diff --cached --name-only` 恰为该组文件
    - 再提交 `feat(github-workflow)`（本特性代码、测试、规则文档、`review/legacy-map.json`）与 `chore(repo)`（`.gitattributes`、`.gitignore`、`.push-guard-allow`、`git rm --cached staged/research-wiki/config.json`、`config.example.json`、`ci/config.ci.json`、CI、模板）
    - 提交后运行 `gh guard` 干跑整个待重放范围：历史中 6 个测试/QA 文件的绝对路径要么写进 `.push-guard-allow`（带理由），要么记入重放改写清单，不得留到 bootstrap 才发现
    - _Requirements: 5.1, 5.2_
  - [x] 13.3 部署副本核对
    - 运行 `python tools/deploy.py --verify-only`，报告一致或差异清单；预期差异应只来自 `github-workflow` 组文件，其他差异列出说明
    - _Requirements: 5.3_
  - [x] 13.4 编写遗留映射
    - 写 `<dev>/review/legacy-map.json`：T1–T7、P1、P2、M1–M3、R1 各一项（状态、结论、证据相对路径与 sha256），`remaining-gaps.md` 每个未完成缺口一项（`repo`、`milestone`）
    - _Requirements: 13.1, 13.2, 13.4_

- [x] 14. Checkpoint - 首推前
  - 运行完整本地 pytest；`wiki.py gh preflight` 干跑并检查待推送范围与 guard 结果；确保全部通过，有疑问时询问用户。

- [ ] 15. 网络 / 高风险操作（按顺序执行，前一步失败即停）
  - [ ] 15.1 preflight 通过
    - 运行 `wiki.py gh preflight`；gh 不可用或未认证时停止并把安装与 `gh auth login` 说明交给用户，不自动安装；账号、owner 写入本机 `config.json` 的 `github`
    - _Requirements: 1.1, 1.2_
  - [ ] 15.2 【需授权】bootstrap --confirm 创建私有仓库并首推
    - 先运行无 `--confirm` 的 bootstrap，把账号/组织、仓库名、private、待推送提交范围呈给用户并取得一次性明确授权（R1.3；用户已给予广泛自主权，但 GitHub 账号与 gh 认证尚未核实，授权以 preflight 结果为准）
    - 依次对 dev、vault 执行 `bootstrap --confirm`：建私有仓库、推送 `main`、Label、deploy key 与 secret、分支保护探测；完成后核对两仓库可见性为 PRIVATE、主检出位于 `main`、被忽略目录仍在磁盘
    - _Requirements: 1.3, 1.4, 2.1, 8.2, 10.1, 10.5_
  - [ ] 15.3 【需授权】migrate-legacy
    - 先 `--dry-run` 核对计划，再正式执行；重跑一次确认无重复 Issue
    - _Requirements: 13.1, 13.2, 13.4_
  - [ ] 15.4 【需授权】首个真实 PR 并观察 CI
    - dev：经 `start-batch`/`start-task` 提交 15.3 产生的任务书迁移标记；vault：同样流程把 README 的远程地址与保护模式填实
    - 两个 PR 都走 `finish-task` → CI → `review` → `merge` → `close-batch` → 合并到 `main`；记录 CI 实际检查项
    - _Requirements: 2.4, 3.4, 6.3, 6.4, 9.1, 10.2, 10.4, 11.1, 13.3_
  - [ ]* 15.5 【需授权】CI 拦截验证 PR
    - 在临时 task 分支加入含合成假路径（如 `Z:\fake\x`）的测试文件，不含任何真实受限内容；需绕过本地 hook 才能推送，执行前单独征得用户确认；确认 CI 的 guard 检查失败后关闭 PR 并删除分支
    - _Requirements: 3.4_
  - [ ] 15.6 【需授权】从 main 部署
    - `<dev>` 检出已推送的 `main`，运行 `python tools/deploy.py <record> "<note>"`；确认来源门禁通过、manifest 含 `source_commit`、5 处副本哈希核验一致（含更新后的规则文档）
    - _Requirements: 12.1, 12.3, 14.4_

- [ ] 16. Final checkpoint
  - 运行完整本地 pytest 与 `deploy.py --verify-only`；确认两仓库 CI 在 `main` 上为绿；确保全部通过，有疑问时询问用户。

## Notes

- 标 `*` 的子任务是可选测试，可跳过以加快进度；核心实现任务不可跳过。
- 第 1–14 步全部是本地、可逆操作（含 13.2 的本地提交）；第 15 步的网络操作必须先通过 15.1，再按 15.2 取得授权。
- 10.11 有意不用 `git switch` 切换到新 `main`：旧 `master` 跟踪了 `画廊/`、`维护记录/`（vault）与 `config.json`、`codex/`（dev），普通检出会把这些文件从磁盘删掉。此后也不要在主检出上检出 `legacy/master`。
- 1.1 必须在任何代码改动之前执行，13.2 的主题提交依赖它区分新旧改动。
- 每个任务引用具体验收条目以便追溯；属性测试按设计文档的 Property 编号标注。

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["1.2", "2.1", "3.1", "4.1", "5.1", "6.1"] },
    { "id": 2, "tasks": ["2.2", "2.3", "3.2", "4.2", "4.3", "4.8", "6.2"] },
    { "id": 3, "tasks": ["2.4", "2.5", "4.4", "4.5", "4.6", "4.7"] },
    { "id": 4, "tasks": ["2.6", "2.7", "5.2", "5.6", "5.7"] },
    { "id": 5, "tasks": ["5.3", "5.4", "5.5", "5.8", "8.1", "8.2", "8.3", "8.4", "8.5", "8.6"] },
    { "id": 6, "tasks": ["8.7", "8.8", "8.9", "10.1"] },
    { "id": 7, "tasks": ["10.2"] },
    { "id": 8, "tasks": ["10.3", "10.4", "10.5"] },
    { "id": 9, "tasks": ["10.6"] },
    { "id": 10, "tasks": ["10.7", "10.8", "10.9"] },
    { "id": 11, "tasks": ["10.10", "10.11"] },
    { "id": 12, "tasks": ["10.12"] },
    { "id": 13, "tasks": ["10.13", "10.14", "12.1", "12.2", "12.3", "12.4"] },
    { "id": 14, "tasks": ["12.5", "13.4"] },
    { "id": 15, "tasks": ["13.1"] },
    { "id": 16, "tasks": ["13.2"] },
    { "id": 17, "tasks": ["13.3"] },
    { "id": 18, "tasks": ["15.1"] },
    { "id": 19, "tasks": ["15.2"] },
    { "id": 20, "tasks": ["15.3"] },
    { "id": 21, "tasks": ["15.4"] },
    { "id": 22, "tasks": ["15.5"] },
    { "id": 23, "tasks": ["15.6"] }
  ]
}
```
