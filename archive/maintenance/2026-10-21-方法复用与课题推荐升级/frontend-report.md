# T06 前端交付

日期：2026-10-21。实现位置：`E:\research-wiki\开发\frontend`。本报告仅覆盖前端软件行为，不代表真实方法科学有效或 R/Python 分析已运行。

## 实现

- 方法卡、单 panel 卡、模板卡及条目详情均有独立“查看代码”。按钮位于卡片导航链接之外，保留翻面、归档删除及来源预览行为。
- Wiki 内只读弹窗按实际清单切换原始版／复用版与文件，显示语言、来源、重建／片段提示、验证范围与 SHA-256；复制当前文件文本，下载端点提供原文件。
- React 以纯文本逐行显示代码；不执行 HTML、Markdown、Notebook 输出或代码。加载、空清单、错误和无法解码文件均有明示。
- 弹窗请求可取消，并按当前条目／版本／文件标识隔离响应；支持 Esc、焦点约束与关闭后恢复焦点。
- 方法与图详情使用同一关系组件显示兼容状态、理由、前提、适配动作、关系证据、页面状态与运行验证范围。来源图样明确尚待模板化，inactive 关系保留追溯并显示已停用。
- 方法配图优先语义关系，再来源参考，最后接口结构匹配；归档或整图来源继续过滤。
- 关系图增加独立语义边颜色与图例，选择节点显示兼容与验证范围；原有 Flow 仍只消费 feeds，界面称“接口结构匹配”。

## 本次修改的前端文件

新增：`src/CodeViewer.tsx`、`src/RelationList.tsx`、`src/relations.ts`。

修改：`src/api.ts`、`src/components.tsx`、`src/figureModels.ts`、`src/palette.ts`、`src/graph/ForceGraph.ts`、`src/styles.css`、`src/views/PageView.tsx`、`src/views/ItemPanel.tsx`、`src/views/MethodsView.tsx`、`src/views/GraphView.tsx`。

其余前端 dirty 文件为交付前基线；没有重置或提交。未修改后端、Wiki、技能或安装包依赖。

## 验证

全部通过：

- `C:\Program Files\nodejs\node.exe node_modules/typescript/bin/tsc --noEmit`。
- `frontend-check.mjs`：28 项 SSR/helper 检查。覆盖语义优先、双端关系语义一致、Flow feeds 隔离、单 panel／归档过滤、卡片按钮非嵌套、代码转义和下载 URL 编码。
- `frontend-browser-check.mjs`：17 项隔离 headless Chrome 检查。覆盖复制文本、实际下载原字节 SHA-256、文件／版本切换、片段与重建来源、二进制、HTML／Notebook 转义、慢响应隔离、跨条目隔离、Esc／焦点及 390px 布局。0 个浏览器运行异常。
- `C:\Program Files\nodejs\node.exe node_modules/vite/bin/vite.js build`：400 模块，构建成功。
- `git diff --check`：无空白错误；存在仓库已有 LF/CRLF 规范提示。

浏览器报告：`frontend-browser-check.json`。截图：`frontend-code-desktop.png` 与 `frontend-code-mobile.png`，已视觉检查。浏览器仅连接本次隔离夹具，无正式 API 调用，无分析执行。

构建已写入 `E:\research-wiki\开发\staged\research-wiki\app`：

- JS：`index-DWgJb30t.js`。
- CSS：`index-D-bYY6BE.css`。
- `app/index.html` SHA-256：`24DF010C04BDC2E6D27BA0148E21499D4292541CFD26E4629A293C626FE1AC32`。

## 集成边界

前端依赖主任务给定的 `code-files`、`code`、`code-download` 只读 API、PageSummary/PageDetail `relations` 与 graph `kind: relation` 契约。代码来源可为字符串或对象，均按文本显示；建议 source 明确含 author original、snippet/fragment 或 generated/replica/reconstructed，便于提示。

正式库真实关系、代码清单补齐、三处安装同步、正式端口前后端连通及最终回归由主任务继续。隔离 R 文本仅验证浏览与字节保存，没有执行 R 算法。没有操作正式浏览器状态或页面签核、归档、删除。
