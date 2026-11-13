# 方法家族与 LLM Wiki 改造：Codex 最终独立验收

日期：2026-10-23。Claude Code 编码，Codex审查与独立运行验证；未再创建Codex子代理、未安装依赖。

## 交付与范围

- 15个分析家族、2个组合流程、9个技术资料；青光眼/SCP归入同一规范家族，不再按来源重复方法卡片。
- 15页来源/实现对照和双向追溯，旧13页去向见维护记录/migration-map.md。保留所有旧id、status、作者user区块及210个原始source/original_code SHA256。
- SKILL/正式AGENTS/staged规则/reference已落地八步入库、语义去重、原始/编译/规则层、ingest/query/lint、带摘要索引与追加日志。
- 页面用途在首屏且只呈现一次；技术/流程详情不再套用分析总览；面包屑/反向链接/图谱按method_kind标识。代码查看器逐分支验证，不以一个成功分支批准所有分支。
- 来源panel留在只读画廊，Wiki记录引用/哈希。此次没有新增PNG/JPG/TIF副本。参考与回放标识沿用通过的预览测试，实际IAB方法页能读取回放引用。

## Codex实际独立复验

- 修复后全套后端：435 passed / 2 skipped，退出0；review-round1-pytest.log。
- 最终前端：30图库 + 10方法检查、typecheck、build，全部通过；review-final-build.log。
- R实际分析：32 PASS / 0 failure / 5预期not_run，退出0；review-scientific-R.log。与原实现等价、参数/输入保护等覆盖以脚本具体断言为准，不扩大为科学有效性。
- Python实际分析：解析线性SHAP和回归手算指标检查通过。
- Codex完整性检查：review-final-integrity.json；全部原始哈希/user/status一致，所有26页检查通过，ready验收指纹未过期，正式/staged AGENTS相同。
- 正式库lint：仅5条已明确not_run WARN，无ERROR。
- 真浏览器IAB在独立8786审查服务检查目录15/辅助11、用途顺序、整合verified/not_run双分支、源码页“技术资料”和历史日期；AX文本已保存。截图API失败，未提供伪造截图或声称作者视觉认可。

## 部署

- tools/deploy.py已同步.agents/.codex/.claude/.cc-switch/.config/opencode五处，每处274文件SHA256核验通过；逐文件旧版备份与deployment-verification.json留在维护记录/deployment/。
- 正式8765服务已按精确wiki.py进程验证后重启。HTTP首页/API实查15 analysis、9 technical、2 workflow；整合分支仍为verified/not_run混合。证据formal-service-check.json。
- 正式服务保持运行；独立8786审查服务结束。开发仓库未替用户提交既有dirty tree。

## 待作者确认与未验证边界

- 新13家族保持draft，供作者阅读确认；并未代签。当前可推荐的已确认家族仍仅SHAP和回归指标；代码verified不等于作者确认。
- 12家族至少一个实现通过；doublet、cell-type-annotation、RNA velocity无已验证实现。另Harmony和SCP RunSeuratMap投影分支仍not_run（共5个登记分支）。
- 原有青光眼DoubletFinder/手工marker等未函数化来源、Monocle2/3/PAGA/GSEA及在线GO/KEGG等未实现/未运行分支明确列出；不因家族收录就声称已提供所有算法函数。
- 不运行真实青光眼课题，不提供真实数据、科学或临床有效性保证。后续有依赖/源代码材料时按已更新skill流程补实现与验证。

结论：本轮改造、独立验收与部署完成；作者确认和明确未实现/未运行分支作为可见待办保留，不通过改状态清零。
