# v2 部署与入口（P7）报告

日期：2026-10-27。成员：部署与入口。未执行真实部署；未 git commit；未改开发仓库文件。

## 1. 改动摘要

### tools/deploy.py

- `HOSTS` 加 `.kiro`，共 6 处：`.agents`、`.codex`、`.claude`、`.cc-switch`、`.config/opencode`、`.kiro`。
- 来源门禁（治理 v2）：工作区必须干净；然后依次认
  1. HEAD = 本地 `refs/heads/main`：不 fetch，直接放行（离线也可），`source_ref = "main"`；
  2. 否则 `git fetch origin`；fetch 失败（离线）即拒绝，提示“此时只允许 HEAD 等于本地 main”；
  3. HEAD = fetch 后的 `origin/main`：`source_ref = "origin/main"`；
  4. HEAD 恰为已推送 tag：`source_ref = source_tag = <tag>`。
  拒绝信息都带当前分支、HEAD、本地 main、origin/main。manifest 新增 `source_ref`，保留 `source_commit`、`source_tag`（只在按 tag 部署时非空）。
- `--sync-config`：不加时，6 处 config.json 必须与 staged 字节相同，否则中止（零写入、不建维护记录目录），列出不同或缺失的文件，并提示加 `--sync-config`。加上后，原 config.json 先备份到 `<record>/backup/<host>/research-wiki/config.json`，再写入 staged 版本（走同一套逐文件备份 + 复制，记进 `changed`）。
- 旧文件清理扩展到整个技能目录：已安装、staged 没有的文件先备份再删除，再逐级删掉因此变空的目录；跳过根目录 config.json、installation-manifest.json、`__pycache__`、`.pytest_cache`、`.git`、`node_modules`、`*.pyc/*.pyo`。结果写进 `stale_removed`。清理放在复制前，这样 Windows 上只改了大小写的文件会按 staged 的新名字重写，不会被误删。
- `--verify-only` 覆盖 6 处，按 `missing / different / extra` 分列；“extra” 用的过滤规则与部署清理相同，verify-only 列出的 extra 就是部署时会删的文件。
- 命令行：位置参数里出现未知的 `--xxx` 时只打印用法，避免把拼错的参数当成维护记录目录名。

### tools/tests/test_deploy.py（9 个测试）

- `test_source_gate_matches_reference`：属性测试，100 轮，固定 seed，分 4 种 HEAD 状态（main / 本地 main 领先 origin / 停在 origin/main 而本地 main 已前进 / 其他分支），再随机组合是否打 tag、是否推送、工作区脏不脏，与参考模型比对；凡是拒绝都断言零写入。
- `test_hosts_include_kiro`：检查 HOSTS 恰为 6 处，含 `.kiro`。
- `test_deploy_from_main_records_source_commit`：从本地 main 部署，manifest 的 commit、ref、tag 三项都对，部署后 verify-only 一致。
- `test_local_main_ahead_of_origin_deploys_even_offline`：本地 main 有未推送提交、远端不可达，仍能部署，`source_ref = main`。
- `test_uncommitted_changes_rejected`：有未提交改动时拒绝。
- `test_head_off_main_rejected`：feature 分支拒绝；离线时 HEAD 等于 origin/main（本地 main 已前进）也拒绝，提示 fetch 失败。
- `test_sync_config_backs_up_then_copies`：config 不同时，不加参数则拒绝并列出 6 个文件；加 `--sync-config` 后先备份原文件再复制。
- `test_stale_files_removed_anywhere_with_backup`：`app/`、`references/`、`rwiki/legacy/` 和根目录下的旧文件都被删除并有备份，变空的目录被清掉，缓存文件、`*.pyc` 保留，旧 manifest 有备份。
- `test_verify_only_classifies_differences_without_writing`：经 `main()` 走 `--verify-only`，退出码 1，6 处的 missing / different / extra 分类正确，忽略 pyc，不写入。

### tools/bin/（新建，均为纯 ASCII）

- `rwiki.cmd`（CRLF）：`setlocal` 后设 `TEMP`、`TMP` = `E:\research-wiki-env\tmp`，`MPLCONFIGDIR` = `E:\research-wiki-env\tmp\mpl`；未设 `RWIKI_HOME` 时默认 `%USERPROFILE%\.agents\skills\research-wiki`；然后调用 `"C:\Users\86186\.codex\venvs\research-wiki\Scripts\python.exe" -X utf8 "%RWIKI_HOME%\wiki.py" %*`，用 `exit /b %ERRORLEVEL%` 传回退出码。
- `rwiki`（LF，`#!/bin/sh`）：设同样的环境变量，`RWIKI_HOME` 同样有默认值，最后 `exec '/c/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe' -X utf8 "$RWIKI_HOME/wiki.py" "$@"`。

### 用户级 PATH

- 原值（REG_EXPAND_SZ，未含 `%变量%`）先写入 `E:\research-wiki-env\skill-backup\global-20261027\user-path.txt`（226 字节，与原值相同）。
- 用 `[Environment]::SetEnvironmentVariable('Path', …, 'User')` 在末尾追加 `E:\research-wiki\tools\bin`（追加前查过不存在，不会重复）。这个 API 把值类型改成了 REG_SZ，已按原内容改回 ExpandString。系统级 PATH 未改，其中也没有这一项。

### 全局指路块

每个文件只有一个 `<!-- research-wiki:start -->` … `<!-- research-wiki:end -->` 块，算上两行标记共 6 行。重跑时整体替换这个块，原有内容不动。

| 文件 | 处理 | 行尾 |
|---|---|---|
| `C:\Users\86186\.claude\CLAUDE.md` | 空一行后追加；原字节完整保留为前缀 | CRLF（同原文件） |
| `C:\Users\86186\.codex\AGENTS.md` | 同上 | CRLF |
| `C:\Users\86186\.config\opencode\AGENTS.md` | 原来没有，新建，只含该块 | LF |
| `C:\Users\86186\.kiro\steering\research-wiki.md` | 原来没有，新建：frontmatter `inclusion: always` 加该块 | LF |

文件写入后，Kiro 当前会话就已把它当作全局规则载入。

## 2. pytest

`cd E:\research-wiki; & $py -X utf8 -m pytest tools/tests -q`（`$env:TEMP=$env:TMP='E:\research-wiki-env\tmp'`）：

- 改前基线：`3 passed in 59.84s`
- 改后：`9 passed in 56.20s`，9 个测试全部 PASSED

## 3. `python tools\deploy.py --verify-only`（2026-10-27 19:07，退出码 1）

| host | missing | different | extra |
|---|---|---|---|
| .agents | 7 | 16 | 2 |
| .codex | 7 | 16 | 0 |
| .claude | 7 | 16 | 2 |
| .cc-switch | 7 | 16 | 2 |
| .config/opencode | 7 | 16 | 2 |
| .kiro | 41 | 20 | 2 |

- 5 处共同的 missing：`assets/rmd_knit_runner.R`、`references/sources-and-recipes.md`、`rwiki/{adapters,finder,recipes,sources}.py`、`tests/test_v2_sources_recipes.py`。这些是其他成员在 staged 里新增、尚未提交的 v2 文件。
- 5 处共同的 different：`SKILL.md`、`assets/AGENTS.md`、`config.json`，以及 13 个 `rwiki/*.py`（acceptance、catalog、cli、config、facts、lint、pages、process、push_guard、server、store、templates、workflow）。
- extra：`references/tag-taxonomy.md`、`rwiki/categories.py`。`.codex` 没有这两个，其余 5 处都有。下次部署会先备份再删除。
- `.kiro` 另外缺 GitHub 工作流那一批文件（`config.example.json`、`references/github-workflow.md`、`rwiki/ghflow.py`、`push_guard.py`、`writer_lock.py`、`tests/fake_gh/*` 和 27 个测试文件）；`pytest.ini`、`tests/conftest.py` 和 3 个测试与 staged 不同。原因是它复制自 10-25 的旧版 `.claude`。
- config.json：5 处只缺 staged 新增的 `sources_root`、`work_root`、`r_libs`、`cran_mirror`。`.kiro` 还缺 `github`、`push_guard`，`taxonomy` 指向 `.kiro\skills\sci-figure-replica\...`；staged 指向 `.claude\...`，两个文件都存在且哈希相同。因此正式部署必须加 `--sync-config`。

这个快照会随其他成员继续修改 staged 而变化。

## 4. rwiki 验证

在新开的进程里先从注册表重读 PATH：`$env:Path = User + ';' + Machine`。

- pwsh 7：`Get-Command rwiki` 解析到 `E:\research-wiki\tools\bin\rwiki.cmd`；`rwiki --help` 退出码 0，共 18 行，首行 `usage: wiki.py [-h] [--config CONFIG] [--wiki-root WIKI_ROOT]`。
- Windows PowerShell 5.1：结果同上。
- cmd.exe：`cmd /d /c "rwiki --help"` 退出码 0。
- Git Bash（`"C:\Program Files\Git\bin\bash.exe" -lc ...`）：`command -v rwiki` 得到 `/e/research-wiki/tools/bin/rwiki`；`rwiki --help` 退出码 0，共 18 行，首行同上。
- 退出码传递：`rwiki no-such-command` 退出码 2；用临时探针 `wiki.py`（`raise SystemExit(3)`）测试，cmd 和 bash 都返回 3。
- 环境变量：两种入口下子进程看到的 `TEMP`、`TMP` 都是 `E:\research-wiki-env\tmp`，`MPLCONFIGDIR` 是 `E:\research-wiki-env\tmp\mpl`，`tempfile.gettempdir()` 也是 `E:\research-wiki-env\tmp`。带空格的参数 `"two words"` 原样传到 argv。探针已删除。
- `RWIKI_HOME=E:\research-wiki\开发\staged\research-wiki` 时，`rwiki find --help` 在 pwsh 和 bash 下退出码都是 0。默认的 `.agents` 副本还是旧版，`rwiki find` 报 invalid choice（退出码 2），要等正式部署后才能用。

## 5. 备份位置

`E:\research-wiki-env\skill-backup\global-20261027\`

- `user-path.txt`：原用户 PATH
- `.claude\CLAUDE.md`：原文件，3452 字节
- `.codex\AGENTS.md`：原文件，3215 字节
- opencode 的 `AGENTS.md` 和 Kiro 的 `steering\research-wiki.md` 原来不存在，不需要备份

## 6. 未完成项与注意

1. 未做真实部署（按要求）。条件：P2 合并进本地 main 且开发仓库工作区干净。届时运行 `python tools\deploy.py <维护记录目录> "<说明>" --sync-config`。目前开发仓库停在 `v2-simplify`，HEAD 等于本地 main（d7c9a7d），工作区有其他成员的改动，门禁会拒绝，这是预期的。本地 main 比 origin/main（7a002c6）少 3 个提交，只改了 `review/github-structured-workflow-delivery.md`，不影响技能内容。
2. 部署后在新终端运行 `rwiki find …` 做 P7 验收。
3. 已在运行的 Claude Code、Codex、opencode、Kiro 和终端要重启后才能读到新的用户 PATH（WM_SETTINGCHANGE 已广播，只影响之后新开的进程）。
4. `README.md` 第 108 行和 `文档/features.md` 还写着“五处 / 三处、只认 origin/main 或 tag”，不在我的文件范围内，请负责规则文档的成员改。
5. `.cmd` 包装的固有限制：Ctrl+C 会出现 “Terminate batch job (Y/N)?”；参数里的 `& | ^ %` 可能被 cmd 改写；在 PowerShell 里把 `rwiki` 输出管道给 `Select-Object -First N` 会因上述提示而挂起（测试时遇到过），应先收集完整输出再截取。Git Bash 走 sh 脚本，不受影响。
6. 两个入口里的解释器路径按要求写死为 `C:\Users\86186\.codex\venvs\research-wiki\Scripts\python.exe`。
