# 方法分类与灵活输入改造：最终验收

日期：2026-10-23。实施：Claude Code；独立审查、复测与部署：Codex。**本轮软件改造已完成并部署；未代替作者签核或真实课题科学验证。**

| 用户要求 | 结果 | 证据 |
|---|---|---|
| 先按研究领域、再按分析用途浏览 | 完成：15个规范家族，后端单一用途词表/API，前端交集筛选、去重计数、搜索、URL保留与重置 | formal-service-check.json；formal-browser-after.txt；formal-methods.png |
| 数据接口可显式适配 | 完成：单模板render --bindings；文件/列映射、无聚合melt/pivot、真实可选列；R/Python可复制helper；报告不冒充语义有效性检查 | codex-real-validation/summary.json；codex-binding-review2.log |
| 前后端与入库规则/skill同步 | 完成：正式/staged AGENTS一致，SKILL及references同步；八步流程加入语义去重、分类、映射与验证依据 | codex-integrity.json；deployment/deployment-verification.json |
| 审查、修复与独立验证 | 完成：两轮审查关闭路由、源覆盖、有效映射冲突、R主键损坏、报告遗漏及无fs硬链接风险 | codex-review-round1/round2/accepted.md；保留全部RED日志 |
| 五处安装与正式服务同步 | 完成：五处各282文件SHA256一致；备份旧文件与旧app包；精确重启8765正式服务；API与入口资源逐字节匹配staged | deployment/；formal-service-check.json |
| 保护原始资料与作者状态 | 完成：210源码文件哈希不变；78页id/status/favorite/archived_from/user区块保持；没有代签13个草稿方法 | codex-integrity.json；正式API |

维护记录根：`E:/research-wiki/维护记录/2026-10-23-分类与灵活输入/`。五处安装为 `.agents`、`.codex`、`.claude`、`.cc-switch`、`.config/opencode` 下的 research-wiki；共用原配置和同一正式Wiki。

## 验证结果

- 独立全套489 passed / 2 skipped；后续只修改R helper及对应测试，独立绑定/spec定向71 passed。Claude最终全套490/2作为补充证据，不混写为独立结果。
- 独立前端24项方法检查、30项图库检查与typecheck通过；前端构建已同步。实际浏览器验证领域、用途、搜索、清除、刷新、切换重置与详情；部署后再次点击单细胞13→轨迹3成功。
- 独立重跑3个真实模板（R点图、R柱图、Python SHAP）共5个绑定场景：四个像素MAD=0；省略点图target_group按既有排序回退，MAD=8.005185978。1个缺必需项负例拒绝且无图。标准example和外部author输入前后哈希不变。
- R重复调用、semantics非空、无fs硬链接源保护均独立复测通过。
- 部署版lint exit0，无ERROR；仅5个既有not_run警告。pending --json exit0，agent待处理0；作者待确认13，原确认2。

## 保留的限制与作者事项

1. `render-layout`组合入口仍按标准表，当前不支持bindings。真实演示覆盖可选列；可选表只有软件夹具证据。
2. R未安装openssl时SHA256字段为NA；CLI始终有SHA256。无fs时不能提前识别所有链接，但安全替换方式已验证不写穿源文件。
3. 单位、统计粒度、配对与科学适用性仍须在课题中核查；不自动聚合、插补、换算或重训。点图省略target_group会改变排序，应按课题需要保留该列。
4. 13个方法家族仍待作者正常确认；Harmony、SingleR、scDblFinder、RunSeuratMap投影与scVelo的既有未运行分支保持not_run。未安装依赖，未扩大验证范围。
5. 来源panel仍在只读画廊，Wiki保存引用/哈希与编译知识；原始/编译/规则分层、索引及追加日志保持。开发仓库保留既有dirty tree，没有批量提交历史改动；正式知识库工作区干净。

本轮监控完成后删除，后续变更重新按入库八步与验证边界执行。

## 后续作者确认（2026-10-23）

作者在本聊天明确确认上述13篇笔记，已通过正式mark-ready登记；全库15个分析家族笔记现均为ready。原验收时13篇待确认的记载保留作为历史状态。3项缺依赖的实现继续待验证，未安装包或扩大验证范围。另补齐动态特征/轨迹两篇笔记的绘图摘要表说明并重录验收。详见维护记录/2026-10-23-待办复核/确认处理结果.md。
