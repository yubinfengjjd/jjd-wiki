# 审查问题修复（2026-10-22）

依据全面审查结果修复 P0/P1 问题；未做真实课题端到端验收，未改任何模板算法、统计逻辑或作者区块。

## 修复清单

| 问题 | 修复 |
|---|---|
| 双击启动失效（快捷方式指向不存在的 `.vbs`） | 新增 `tools/启动知识库.vbs`（ASCII，按自身目录定位 `launcher.ps1`），快捷方式改指它；实测起服务、开窗口、关窗口停服务 |
| 任意网页可写本地服务（CSRF/DNS rebinding） | `server.py` 增加中间件：Host 必须为本机名；写请求拒绝跨站 `Origin`、`Origin: null` 与 `Sec-Fetch-Site: cross-site` |
| `/files/wiki/.git/...` 可下载 | `safe_file` 拒绝任何点目录/点文件；实测 `.git/config` 返回 404 |
| 写操作半成功（先写页面/gallery，再 save 失败） | 新增 `store.guarded`；所有网页写路径与 CLI `mark-ready` 在失败时还原页面、`acceptance.json`、gallery meta、`index.md`、`log.md` |
| 一个坏页拖垮 `/api/pages`、`save`、facts | `readable_pages` 跳过不可读页；`refresh_facts` 先全量计算再写，跳过坏页；`declarations` 跳过坏方法/模板；`workflow` 与列表同口径 |
| `spec.entry/panel` 可逃出模板目录；layout 表文件名可穿越 | `load_spec` 要求两者在模板目录内；`load_layout` 只接受数据目录内的普通文件名 |
| `template_panels` 缺键抛裸 KeyError | 改为 `WikiError`（“归属不一致”），lint 不再崩溃 |
| `mark_ready` 重复插入 preview 嵌入 | 嵌入已存在则不插入；正式库两处重复已清掉并重新记录验收 |
| ready 页无回执仍算有效；先写 ready 后记回执 | `acceptance_stale` 缺回执即过期；`mark_ready`/`confirm_method` 先记回执再写 ready |
| 回放证据不入库 | `verify/` 移出 `.gitignore`；`store.init` 新库也不再忽略；正式库已提交 37 个回放文件 |
| D044 未拦截无来源模板 | `metadata_errors`：template 的 `layouts` 必须是非空字符串列表（ERROR） |
| `direct` 可指向 draft/接口不匹配模板 | `relations`：要求目标非 draft，且模板读取接口全部在方法 `outputs` 中，否则提示改 `adaptable` |
| “无图原因”只写在规则里 | `lint` 对“有输出但无结构/语义模板”的 ready 方法报 WARN，正文写“无图原因：…”即消除 |
| 删除模板唯一来源会留下无来源模板 | `deletion.prepare` 拒绝删除“某未归档模板的唯一来源”，提示先处理模板 |
| 图谱/徽章/统计/筛选用原始 status | 新增 `effectiveStatus` + `stageStatus`；卡片、方法页、关系卡、图谱、图库 census/筛选、方法库统一用 workflow 阶段 |
| 归档整图来源在归档区完全不可见 | `App` 保留 `hiddenPages`；待办“已归档”只读列出它们，可查看删除范围并永久删除，不提供打开/恢复 |
| 删除确认范围不全 | 弹窗显示移除的关系总数、每页移除数、会被改写/删除的 `layout.json` |
| 写失败仍关闭表单；删除成功却报失败 | `run()` 返回布尔值；标签/退回收据只在成功后关闭；删除提交与刷新分段处理 |
| `LayoutImages` 归档后下标越界 | 改按 tab 标签保存选中项；视图外层加 ErrorBoundary；路由解码失败回退图库 |
| 旧回放冒充当前回放 | 预览新增 `stale` 类型，显示“旧回放 · 当前版本尚未重新回放” |
| 外链无协议白名单 | 帖子 URL 与 repo URL 仅 `http/https` 可点，其余按文本显示 |
| 图谱 reduced-motion 下筛选不重绘 | `refreshEmphasis` 每次刷新置 `dirty` |
| WebGL 资源未释放 | `ForceGraph`/`Lattice` dispose 时释放链路材质并 `forceContextLoss` |
| 搜索命中已隐藏/已过滤节点 | 图谱查找遵守类型与归档过滤；计数同步 |
| 死样式/无用导出 | 删除 `.method-figures`、`.examples`、`.csv*`、`.facts.report`、`SingleImage`、`renderText` |
| 没有统一部署入口 | 新增 `tools/deploy.py`（逐文件备份、清理旧 app 资源、manifest、哈希核验） |

## 验证

- 后端：`399 passed, 2 skipped`（新增 `tests/test_hardening.py` 12 项；2 skipped 为本机无法创建文件/目录链接）。
- 前端：`tsc --noEmit` 通过；`npm test` → 30 checks passed；`npm run build` 成功。
- 构建拆分：入口 `index-ltR9IyzT.js`（849 KB）+ 按需 `GraphView-nEIgvTv4.js`（69 KB）。
- 部署：`tools/deploy.py` 同步 `.agents`/`.codex`/`.claude`，每处 270 个文件按 SHA-256 核验；三处 app 与 staged 构建一致。
- 正式库：`lint` → OK；`pending --json` → `[]`；7 个 ready 条目 `check-entry` 全部 passed；规则 `AGENTS.md` 与技能副本一致；5 个模板各只有 1 个 preview 嵌入。
- 正式服务实测：27 页、5 个模板预览均为 `replay`、待办 0；`.git/config` 404；跨站归档 403；伪造 Host 403；SHAP 整图来源删除计划 409（唯一出处），回归整图来源 200。
- 正式库提交：`2b717d1`、`6706008`（去重后重新验收）、`83d3cb1`、`d3926d1`（规则同步）；更早的 `aa61cf7`、`bb718df` 为同一轮验收记录。开发仓库最终提交 `2bbe879`。
- 并行会话新增的 Obsidian 辅助规则（`SKILL.md`、`AGENTS.md` 的只读阅读/备注边界）随同一部署同步到三处安装；提交 `826b6bf`（开发）、`60fbfbc`（知识库）。本记录不改变其口径。

## 仍未闭环

- 真实课题端到端验收（D024/D027）：正式库 `projects/` 为空，仍只有隔离夹具。
- 一键回退（D020）：只有 git 提交与手工 revert，没有 CLI/网页入口。
- 规模性能（D016）：无 50–300 页实测；`/api/pages` 已改为一次计算 relations，但仍是全量读页。
- 字体子集化（产物约 8 MB / 199 个字体文件）未做；图谱已拆包，其余路由仍静态加载。
- `.agents` 中 medfig-render / medpaper-pipeline 不含 research-wiki 入口条款（这两项不属本项目维护）。

## 复核入口

- `deployment-verification.json`：三处安装变更清单与哈希。
- 后端测试：`开发/staged/research-wiki/tests/test_hardening.py`；前端：`开发/frontend/tests/figure-models.mjs`。
- 部署：`python tools/deploy.py <维护记录目录> "<说明>"`。
