# Obsidian 辅助窗口与神经图谱

用户授权：以正式 `知识库/` 为 vault，接入指定视频同源视觉作为辅助窗口，不迁移页面、不重做业务功能。

## 边界

- Vault：`E:\research-wiki\知识库`。旧欢迎 vault 保留，未删除或移动。
- 原网页/CLI：签核、待办、确认、状态、删除、代码业务查看及模板执行入口维持现状。
- Obsidian：原生阅读、搜索、反向链接，以及只读科研神经图谱。作者备注仅在 user 标记之间编辑。
- 不从图谱线条、页面 raw status 或已存在文件推导有效 workflow、方法语义兼容或科学验证。
- 不同步/公开笔记，不安装旧 vault 的 obsidian-git 或 AI 插件。

## 变更与备份

`before.json` 记录全部原 Markdown 的 SHA-256、配置/规则备份位置。`before/` 保留修改前文件。配置脚本为 `E:\research-wiki\tools\configure-obsidian-auxiliary.py`，它是防重复的一次性配置，不应直接重复运行。

- `.gitignore` 增加 `.obsidian/`；没有排除 verify 证据。
- `.obsidian/app.json`：关闭自动更新链接、新链接根目录绝对路径、双链、属性源码显示、默认阅读模式、过程目录检索排除。
- `.obsidian/core-plugins.json`：启用本地阅读/搜索相关核心插件，未启用同步/发布。
- 正式 AGENTS、staged 规则源、三处安装 assets/AGENTS 同步；staged 与三处 SKILL 追加辅助窗口边界。
- 应用全局登记增加正式 vault，保留其他 vault 登记。

## 来源

视频作者公布：[neural-creator-dashboard](https://github.com/luoluo-121/neural-creator-dashboard)。固定版本 `769d690fa1c06d985926d8f16772d15514b718e1`。当前许可及历史例外以插件目录内保存的 LICENSE/NOTICE 为准。

## 验收

- 基础配置后 Wiki lint：OK。
- Git check-ignore 确认 app.json 与插件路径被忽略。
- 五份 AGENTS 文件 SHA-256 一致。
- 构建与自检：`npm run verify` 通过（源码测试 11 项、构建后测试 3 项），覆盖“条目删除或改名后点击旧卡片不创建空笔记”和只读边界。
- 安装：`dist/` 同步至 `知识库/.obsidian/plugins/research-wiki-neural-view/`，`main.js` SHA-256 `B449588875419925B09C739EA3A802AF96E0BF8AA09FDA78BDF25AC18E8FF881`，安装目录与 `dist/` 无差异。
- 真实 Obsidian 读取：22 条正式笔记、37 条连线、28 条双向引用、2 条未解析引用；五模块计数为图样 5、模板 5、方法 4、接口 8、课题 0。
- 模块展开：点击“方法”水母后扇形展开 4 条笔记（`native-methods-expanded.png`）。
- 详情：`methods/regression-resampling-evaluation.md` 显示标题、路径、原始 `status: ready`、显式页面引用与反向链接；未解析的代码路径以禁用文本显示。
- 原生打开：详情“打开原生笔记”在相邻标签打开 `regression-resampling-evaluation`，图谱标签保留；未出现新增空笔记。
- 刷新：工具栏“刷新”后计数保持 22/37，无错误提示。
- 返回：详情→模块→首页的面包屑返回和 Escape 逐层返回均正常。
- 旧卡片边界：临时探针 `methods/__neural_view_probe__.md` 打开详情后删除文件，再点“打开原生笔记”，仅出现“笔记已删除、移动或暂不可用，请刷新图谱。”；没有新建标签页或空笔记，图谱自动回到 22 条。探针已删除。
- 停用/启用：停用后图谱视图移除且无错误；重新启用并打开后回到首页，计数正常。
- 文件完整性：知识库 Markdown 除已提交的规则更新（`AGENTS.md`、`log.md`，提交 `d3926d1`）外无改动；`git status` 干净。截图 `native-home-after-fix.png`、`native-methods-expanded.png`、`native-methods-detail.png` 保存在本目录。
