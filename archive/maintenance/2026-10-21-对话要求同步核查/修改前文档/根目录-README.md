# 科研知识库项目

一个 LLM Wiki + 可复用可视化模板库。知识以互链的 Markdown 页面为本体，脚本与网页只是薄外壳。

## 目录

```text
research-wiki\
  知识库\            正式 LLM Wiki（git 仓库）。页面、模板代码、方法笔记都在这里
     AGENTS.md       规则层：agent 的维护手册
     layouts\        整图版式（签核状态在这里）
     templates\      单图模板（spec.json + code/ + example/）
     methods\        方法笔记（source/ 原代码、code/ 可复用模板）
     interfaces\     数据接口（列的唯一定义）
     chart-types\    图型枢纽
     projects\       课题页（用过什么、图在哪）
  画廊\              原始层，sci-figure-replica 的产物，知识库只读
  开发\              开发过程
     staged\research-wiki\   代码、技能 SKILL.md、前端构建产物
     frontend\               React 源码
     test-gallery\           测试用画廊（测试只用这一份）
     test-gallery-p2\        前端预览用画廊
     test-wiki-r1\           迁移后的测试知识库（预览/联调用）
     任务书：T1–T4、P1、P2、M1–M3、R1*.md
     review\   codex\   qa\   spec\   preview-wiki\
  文档\              requirements / design / handoff / session / features（功能索引）
```

`开发\` 与 `知识库\` 各自是 git 仓库：前者记录代码与测试的每次改动，后者记录知识库的每次写入。

## 双击打开

双击项目根目录的 **`启动知识库.vbs`**：

- 后台起服务，打开一个独立的浏览器应用窗口；
- 关掉这个窗口，服务会自动停止；
- 出错或想查时间线看 `.launcher.log`。

窗口是 Chrome（没有则 Edge）的应用模式，使用临时独立配置，不带你平时的插件与登录。若服务已在终端里跑着，双击只会开窗口，关窗口不会停那个服务。

## 命令行启动

```powershell
$env:TEMP=$env:TMP='E:\research-wiki-env\tmp'; $env:MPLCONFIGDIR='E:\research-wiki-env\tmp\mpl'
$rw = 'C:\Users\86186\.codex\venvs\research-wiki\Scripts\python.exe'
& $rw -X utf8 'C:\Users\86186\.claude\skills\research-wiki\wiki.py' serve
```

浏览器打开 http://127.0.0.1:8765 。

## 技能安装与项目的关系

技能必须放在 Claude / Codex 的固定目录才能被发现，所以这两份是**部署副本**，源在 `开发\staged\research-wiki`：

- `C:\Users\86186\.claude\skills\research-wiki\`
- `C:\Users\86186\.codex\skills\research-wiki\`
- `C:\Users\86186\.claude\skills\sci-figure-replica\`（页面复刻，配置里的画廊路径指向本项目的 `画廊\`）

改代码后同步：

```powershell
foreach ($d in 'C:\Users\86186\.claude\skills\research-wiki', 'C:\Users\86186\.codex\skills\research-wiki') {
  foreach ($i in 'app','assets','rwiki','config.json','SKILL.md','wiki.py') {
    Copy-Item "E:\research-wiki\开发\staged\research-wiki\$i" $d -Recurse -Force
  }
}
```

技能 config.json 里的 `wiki_root`、`gallery_root` 指向本项目的 `知识库\` 与 `画廊\`。

## 不进项目的

- Python 环境：`C:\Users\86186\.codex\venvs\research-wiki`（跑 wiki.py）、`E:\research-wiki-env\bio-python`（本机实验环境，知识库不再管理）
- 临时文件与缓存：`E:\research-wiki-env\tmp`、`E:\research-wiki-env\pip-cache`（C 盘不写）
