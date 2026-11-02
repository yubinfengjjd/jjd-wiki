# 科研知识库项目

一个 LLM Wiki，加上可复用的配方、图模板与方法库。知识以互链的 Markdown 页面为本体，脚本与网页只是薄外壳。

v2（2026-10-27）起：开源库（首个 FigureYa）经来源登记与适配器批量入库，按 L0（来源目录项）/ L1（原样运行的整模块配方）/ L2（可换数据的模板与方法）分级，L2 在课题用到时再提炼；画廊复刻是来源之一，不再是必经入口。任何 agent（Claude Code、Codex、Kiro、opencode）用 `rwiki find / show / use` 找到并调用模板。

当前要求与同步状态见 [当前要求与同步核查](文档/当前要求与同步核查.md)，被取代的旧规则与原因见 [决策记录](文档/决策记录.md)。执行规则见 [知识库 AGENTS.md](知识库/AGENTS.md)；可选的 GitHub 流程见 [GitHub 流程](开发/staged/research-wiki/references/github-workflow.md)。早期设计文档中的旧路径与被替代流程仅作历史记录。

## 两个仓库

| 仓库 | 本地位置 | 内容 | 远程地址 | 默认分支 |
|---|---|---|---|---|
| `jjd-wiki` | `E:\research-wiki`（根仓库） | `知识库/`、`文档/`、`tools/`、`research wiki/`、本 README、`.github/` | https://github.com/yubinfengjjd/jjd-wiki | `main` |
| `jjd-wiki-dev` | `E:\research-wiki\开发`（独立仓库，自带 `.git`） | 代码、测试、技能源 `staged/research-wiki`、前端源码、`.github/` | https://github.com/yubinfengjjd/jjd-wiki-dev | `main` |

两个仓库都是 GitHub 免费账号下的私有仓库，默认分支 `main`，没有远端分支保护（保护 API 返回 403，bootstrap 记为 `protection: local`）。`知识库\` 不是单独的 git 仓库，而是根仓库的子目录；根仓库的 `.gitignore` 忽略 `/开发/`，两者互不跟踪。bootstrap 之前本地分支叫 `master`；bootstrap 把它改名为只留本地的 `legacy/master`，并构造新的 `main`（dev 过滤重放历史，vault 为一次快照）。不要在主检出上检出 `legacy/master`：旧历史跟踪了画廊与维护记录，切过去再切回会把这些文件从磁盘删除。

v2 起知识库写入可在本地 `main` 直接由 `wiki.py save` 提交，开发仓库也可在本地 `main` 提交；Issue / PR / 他人评审改为可选流程（见下文“可选的 GitHub 流程”）。推送由作者决定。

## 目录

```text
research-wiki\                  jjd-wiki 仓库根
  知识库\            正式 LLM Wiki
     AGENTS.md       规则层：agent 的维护手册（v2）
     catalog.jsonl   检索目录：L0+L1+L2+场景一行一条（save 重建，find 读取）
     index.md        生成的页面目录；log.md 只追加的操作日志
     sources\        来源登记页与 L0 目录（sources\<id>\items.jsonl）
     recipes\        L1 配方（source\ 上游原字节、source.json 哈希、runs\ 运行收据、preview.png）
     scenarios\      场景导航页（首选组合）
     templates\      L2 图模板（spec.json + code\ + example\ + verify\ 回放）
     methods\        L2 方法笔记（source\ 原代码、code\ 可复用代码）
     interfaces\     数据接口（列定义 + 一行代表什么、单位与相近接口区别）
     chart-types\    图型概念页（何时选它、与相近图型区别、常见误用）
     layouts\        画廊复刻图样的来源记录（历史状态只读）
     projects\       课题页（用过什么、怎么适配、图在哪）
     .gitignore      敏感文件与本机运行产物排除规则
     .protected-hashes.json   作者 user 块字节基准（gh protect-baseline 生成，CI 核验）
  文档\              requirements / design / handoff / session / features、决策记录、各轮计划与核查
  tools\             launcher.ps1（双击启动）、deploy.py（部署技能副本）与其测试
     bin\            rwiki.cmd（PowerShell / cmd）与 rwiki（Git Bash）：命令入口
  research wiki\     一个 Obsidian vault 的配置与插件（.obsidian\、.claudian\）
  画廊\              原始层，sci-figure-replica 的产物，知识库只读（知识材料默认保存 Git）
  维护记录\          本地验收与部署证据（知识材料默认保存 Git）
  开发\                         jjd-wiki-dev 仓库根（独立仓库）
     staged\research-wiki\   代码、技能 SKILL.md 与 references\、前端构建产物
     frontend\               React 源码
     obsidian-neural-view\   Obsidian 神经图谱插件源码
     ci\config.ci.json       CI 用配置（本机 config.json 不入库）
     review\                 历史评审记录与旧任务书（已迁为 Issue，只读）
     test-gallery\  test-gallery-p2\  test-wiki-r1\  preview-wiki\   本地测试与预览数据（不入库）
     codex\                  Codex 运行记录（不入库）
     qa\   spec\
```

## 命令入口 rwiki

`tools\bin\rwiki.cmd`（PowerShell / cmd）与 `tools\bin\rwiki`（Git Bash）加入用户 PATH 后，任意终端直接 `rwiki <命令>`；它们用 research-wiki 专用 Python 调用 `C:\Users\86186\.agents\skills\research-wiki\wiki.py`，参数与 `wiki.py` 相同。

```powershell
rwiki find 生存曲线 风险表          # 读 catalog.jsonl，场景首选排前，每条给下一步命令
rwiki show <id>                    # 用途、适用/不适用、输入、许可、最近运行
rwiki use <id> --project <课题目录>  # 复制到 <课题>\wiki-use\<名>\，按 RWIKI-USE.md 换数据
rwiki run --dir <副本>              # 配方副本原地运行；模板用 rwiki render
```

各 agent 的全局说明（Claude Code、Codex、Kiro、opencode）都指向这几条命令；命令细节见技能 `SKILL.md`。

## 可选的 GitHub 流程

- 日常收录与按批次入库在本地 `main` 提交即可。开发代码大改、需要 CI 与评审记录时，用 `wiki.py gh start-task` → `finish-task` → `review` → `merge`；评审由非编码 agent 回帖，`gh merge` 按门禁合并并关闭 Issue、释放写入锁、清理 worktree。
- pre-push hook 只拒绝 `legacy/*`，并对每次推送运行 `gh guard` 内容扫描（私有数据、课题数据、密码/令牌/私钥、超限文件、本机绝对路径）。
- hook 不入库：新克隆或新机器先运行 `wiki.py gh install-hook --repo dev` 与 `wiki.py gh install-hook --repo vault`。

## Git 保存规则（作者 2026-11-02 修订）

所有知识默认保存 Git：方法理论、源码、复用代码、公开示例、配色等必要资源、模板、画廊知识及验证材料。保留原许可证、署名与来源，限制性许可不会因保存 Git 而改变。旧的“GPL/CC 源码只留本机”规则已取消。

不推送私有数据、密码、令牌或私钥。环境、缓存、浏览器会话、重复备份与运行噪音属于非知识产物，继续排除；公开示例与知识代码不能因此漏传。单文件大小与本机路径检查继续保留，已审查的知识资源用精确豁免保存。`legacy/*` 历史仍不推送。

换电脑继续见 [Windows 下载与待运行验证交接](文档/Windows迁移与验证-20261102.md)。

## 双击打开

双击项目根目录的 **`启动知识库 - 快捷方式.lnk`**（启动脚本位于 `tools/`）：

- 后台起服务，打开一个独立的浏览器应用窗口；
- 关掉这个窗口，服务会自动停止；
- 出错或想查时间线看 `.launcher.log`。

窗口是 Chrome（没有则 Edge）的应用模式，使用临时独立配置，不带你平时的插件与登录。若服务已在终端里跑着，双击只会开窗口，关窗口不会停那个服务。

主检出停在 `main` 时，网页写入（签核、确认、改标签等）直接提交到 `main`。要让网页写入落到任务分支：先 `wiki.py gh start-task … --worktree`，按输出设置 `$env:RWIKI_WIKI_ROOT` 后在同一终端运行 `tools\launcher.ps1`，launcher 会把它以 `--wiki-root` 传给 server。

## 命令行启动

```powershell
$env:TEMP=$env:TMP='E:\research-wiki-env\tmp'; $env:MPLCONFIGDIR='E:\research-wiki-env\tmp\mpl'
$rw = 'C:\Users\86186\.codex\venvs\research-wiki\Scripts\python.exe'
& $rw -X utf8 'C:\Users\86186\.claude\skills\research-wiki\wiki.py' serve
```

浏览器打开 http://127.0.0.1:8765 。写入任务分支检出时加全局参数 `--wiki-root <检出>\知识库`（放在 `serve` 之前）。`rwiki` 在 PATH 上时也可直接 `rwiki serve`。

## 技能安装与项目的关系

技能必须放在各 agent 的固定目录才能被发现，所以这些是**部署副本**，源在 `开发\staged\research-wiki`，共 6 处：

- `C:\Users\86186\.agents\skills\research-wiki\`
- `C:\Users\86186\.claude\skills\research-wiki\`
- `C:\Users\86186\.codex\skills\research-wiki\`
- `C:\Users\86186\.cc-switch\skills\research-wiki\`
- `C:\Users\86186\.config\opencode\skills\research-wiki\`
- `C:\Users\86186\.kiro\skills\research-wiki\`
- `sci-figure-replica` 另安装于 `.agents`、`.codex`、`.claude` 三处，其配置的画廊路径指向本项目的 `画廊\`。

research-wiki 用 `python tools\deploy.py <维护记录目录> "<说明>" [--sync-config]` 同步 6 处（逐文件备份、清理旧文件、写 manifest 并按哈希核验）；部署只在 `开发` 工作区干净且 HEAD 等于本地 `main`、`origin/main` 或恰为已推送 tag 时进行，manifest 记录 `source_commit`、`source_ref` 与 `source_tag`。`python tools\deploy.py --verify-only` 只比较 6 处副本与 staged 的哈希，不写入。sci-figure-replica 的源不在本项目，沿用其维护记录中的部署。

技能 config.json（本机文件，不入库；模板见 `config.example.json`）里的 `wiki_root`、`gallery_root` 指向本项目的 `知识库\` 与 `画廊\`，`github` 段记录 owner、两个仓库名与本地路径；v2 新增 `sources_root`（上游快照）、`work_root`（运行副本）、`r_libs`（Wiki 专用 R 库，第一个为装包目标）与 `cran_mirror`。

## 不进项目的

- Python 环境：`C:\Users\86186\.codex\venvs\research-wiki`（跑 wiki.py）、`E:\research-wiki-env\bio-python`（本机实验环境，知识库不再管理）
- Wiki 专用 R 库：`E:\research-wiki-env\R-lib\figureya`（`deps --install` 的唯一安装目标，作者按批次批准后才装）、`E:\research-wiki-env\R-lib-scp\4.5`（只加入运行库路径，不往里装）
- 上游来源快照：`E:\research-wiki-env\sources`（`source fetch` 的部分克隆与稀疏检出）
- 配方运行副本与装包日志：`E:\research-wiki-env\work\rwiki`
- 临时文件与缓存：`E:\research-wiki-env\tmp`、`E:\research-wiki-env\pip-cache`（C 盘不写）
- 并行任务的 worktree：`E:\research-wiki-env\worktrees`（`start-task --worktree` 创建，合并后自动移除）

运行依赖与独立性口径见 `开发/staged/research-wiki/references/minimal-runtime.md`；配方、收据与装包审批见 `开发/staged/research-wiki/references/sources-and-recipes.md`。
