# 实施与验收报告（2026-11-13）

状态：统一检索、轻量获取和开发库规范化已实现；主库除 `知识库 → wiki` 外的目录迁移已应用。该最后一步被 Codex app-server 持有的 methods 目录句柄阻止，保留旧目录可用，不强制关闭应用或文件句柄。尚未推送 GitHub。

## 需求对应结果

| 需求 | 实现与证据 |
|---|---|
| LLM Wiki 主干与 agent 科学判断 | 保留知识正文、稳定 ID、作者区块、来源和运行收据；没有自动合并方法或修改统计逻辑 |
| 默认全文检索 | 章节 BM25、中英文术语、二字片段、有界精确短语；按页面合并，返回章节、片段、原因；布局仅作参考 |
| 多入口一致 | CLI/API 共用核心；静态入口使用同源导出和相同排名规则；16 项完整结果对照及真实四问前三入口前五对照通过 |
| 状态与来源边界 | 每次返回重新核对当前证据；L0 检查实际上游条目；available/not_downloaded/missing 分开；移除与归档内容在知识、源码范围均屏蔽 |
| 下载与维护边界 | Git 部分克隆与稀疏检出；显式 fetch/use 补齐闭包；GET 不下载、不执行；轻量拒绝正式写入，full 才维护 |
| 两库目录 | 开发库规范目录已落地，主库 gallery/archive/integrations 已落地；旧入口为仅本地忽略的联接，不在 Git 保留重复文件树 |
| 可回退迁移 | 预检、脏文件与冲突拒绝、逐文件前后哈希、配置与 Git 元数据备份、意外中断恢复、回退前拒绝覆盖用户新修改 |
| 文档 | 本目录需求、设计、任务交接、进度、验收；两个 README 分工与相互链接，历史归档首页提供版本和后继入口 |

## 检索基准

冻结 40 个问题：15 个方法、10 个模板、10 个理论/接口、5 个限制条件。未改标签，也未增加针对某个问题的别名。

| 指标 | 原检索 | index v5 |
|---|---:|---:|
| Recall@3 | 85.0% | 97.5% |
| Recall@5 | 85.0% | 97.5% |
| Recall@10 | 95.0% | 100.0% |
| MRR@10 | 0.7484 | 0.9036 |

达到 Recall@5 ≥90% 目标。差异表达问法第 7→3；“给细胞做注释”第 1→3，虽然仍达到前三，排名确有退步；“判断每个细胞属于什么类型”第 20→1。SHAP 背景分布和输出单位仍为唯一前五缺口，理论页第 2→7，保留记录。

数据与重现脚本在开发库 `archive/review/search-benchmark/`。这只评价发现能力，不证明方法适用于某个研究，也不是科研验证。

## 验证与保护

- 工具与迁移测试：76 passed，含双同级 light/full 获取、冲突/脏文件、中断/回退、路径与风险规则、部署备份核验。
- 最终检索/资产/API/代码/分类/规范文档回归：110 passed，2 skipped，1 local deselected；有一条既有 Starlette/AnyIO 弃用警告，没有安装或升级依赖。
- 前端既有 SSR 检查通过，26 项 Node 检索与路径测试通过，TypeScript 和 Vite 生产构建通过。独立审查确认三项 Important 均已修复，无新增 Critical/Important。
- 其他末段回归曾为 50 passed、2 failed；两项是 canonical 路径与已更新文档的旧断言，已修复并单独复测 34 passed、1 local deselected。Git 保存的 100 轮属性测试在该末段回归通过。
- 非 R/非 compose/非 local 全库长跑在约 92% 时遇 Windows 原生 access violation，不能宣称该次全量通过。未处理科研分支或安装科研依赖。
- 单独执行 local 规则一致性检查仍有一项既有失败：总库 AGENTS 与技能模板在 tags 规则一句上不同；基线两个提交已存在该差异，本轮保留知识原件，没有以消除告警为由覆盖它。
- 主库原有 10,661 个受保护的已跟踪知识/画廊/历史文件，迁移路径映射后 Git 内容对象一致，缺失与变化均为 0。281 个作者区块、1,439 个收据/来源契约哈希无变化。开发库 64 个既有历史/示例文件迁移后内容一致。
- 静态语料含 316 个知识页与 33 个 L0 条目，18 个排除、0 个无法读取；无原始源码文档，131 条来源标识均无本机绝对路径或越界路径。

字节基线、逐项校验、测试日志和迁移记录位于本机外部审计目录 `E:\research-wiki-env\work\modernization-v3`；不将本机 Git 元数据备份或部署配置提交公开仓库。

## 实际界面

Chrome 实际检查桌面与 390px 手机宽度的搜索、章节跳转、静态入口、代码弹窗和下载。搜索/阅读页面暂停持续背景动画，避免软件渲染竞争 CPU；详情只读取所需证据，不为它同时重算全库关系。修复了原始预览图与长内容撑宽手机页面、代码文件列表被挤压的问题。

代码下载为 14,257 bytes，SHA-256 与弹窗一致：`2ee92ab2df8949403c66b30a9e1337eb780a86fd637f29fcf3e968494540ac13`。手机代码弹窗 document/client/viewport 宽度均为 390px。静态页面明确显示导出时间及源码范围未包含；不会伪称已检索未下载代码。

截图：[搜索](screenshots/search-desktop.png)、[手机搜索](screenshots/search-mobile.png)、[命中章节](screenshots/chapter-detail.png)、[静态入口](screenshots/static-desktop.png)、[代码](screenshots/code-desktop.png)、[手机代码](screenshots/code-mobile.png)。界面检查与科学验证分开报告。

## 待完成的本机目录改名

关闭 Codex 后，在独立 PowerShell 运行下面的收尾入口。记录目录须为全新目录；脚本先拒绝脏工作区，再调用相同迁移器，按原先已跟踪清单强制保留被新忽略规则排除的原件，校验内容后提交目录改名，并按既有来源门禁同步六处配置与技能。它不推送 Git、不装包、不运行科研代码。

```powershell
Set-Location E:\research-wiki
D:\anaconda\python.exe -X utf8 tools/finish-layout.py --record E:\research-wiki-env\work\modernization-v3\layout-finish-after-codex
```

若仍受占用会停止并留下审计记录，不覆盖目录。回退使用记录里的 `layout` 子目录调用 `tools/migrate-layout.py --rollback`；回退不重写 Git 历史，已提交的目录改名需另行审查反向提交。旧课题副本及提交永久链接继续保留。

六处技能已部署自开发库本地 main `c0b983b`；每处 365 个文件，verify-only 的 missing/different/extra 均为空。部署前备份及 manifest 位于外部审计目录的 `deployment-v3`，未推送远端。

最终仍需完成此处物理目录改名后才可把全部迁移阶段标为完成。收尾脚本成功后会提交不含本机绝对路径的 `docs/modernization/layout-completion.json`；本报告的目录待办是执行收尾前的时间快照，后继完成标记为准。
