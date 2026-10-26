# Claude Code 实施交接：方法两级分类与灵活输入

用户已授权：先写计划，再Claude编码，Codex独立审查。你是唯一编码者，不启动子代理或调用Codex。完整阅读同目录implementation-plan.md后执行，不停在计划。旧任务已验收部署，本次是新增改造。

先读 E:/research-wiki/知识库/AGENTS.md、E:/research-wiki/README.md、E:/research-wiki/文档/方法家族与LLM-Wiki改造/final-acceptance.md 和本轮维护记录baseline。开发仓库有大量未提交的已部署成果，禁止reset/clean、覆盖或批量提交历史改动。

目标：领域tags→用途purposes两级浏览；多标签多入口但同一id/规范页、去重计数。后端词表/API/校验与前端同源，分类不作为科学推荐硬门槛。保留分析/流程/技术资料区别。

输入分语义要求、实现接受对象、内部表格式三层。外部数据用显式bindings映射文件/列及无聚合长宽表整理，不改原表、不自动补值/换算/统计/训练。render --bindings和可复制纯适配模块须对R/Python真实验证；必需/可选按实现能力，旧标准调用/verify/单panel回放兼容。前端显示语义与适配，技术schema折叠。

按T0–T4测试RED→GREEN，写progress.md。规则同步正式AGENTS、staged/assets/AGENTS、SKILL和references；入库先去重、分类、核对语义再适配，不按文件名/列名/来源重复建方法或接口。verification-matrix.md必须对照前端/后端/CLI/规则/五处skill。文档存在不算实现通过。

wiki/pytest解释器C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe -X utf8；通用脚本D:/anaconda/python.exe -X utf8；分析Python=E:/research-wiki-env/bio-python/Scripts/python.exe；R=D:/R-4.5.0/bin/Rscript.exe，先读E:/research-wiki-env/work/scp-runtime.ps1设置AMD64、R_LIBS_USER和locale。TEMP/TMP/MPLCONFIGDIR使用E:/research-wiki-env/tmp。不安装依赖，不读/调用E:/paper-harness。

代码位置：开发/frontend、开发/staged/research-wiki/rwiki；内容在知识库/methods、interfaces、templates。dotplot真实spec表键dotplot、接口render-dotplot-long；SCP bar表键metadata。不按示例猜其他模板。

保留source/original_code字节、作者user/status/favorite、旧id、真实数据和原图。分类变化只更新必要元数据和笔记验收，不使算法收据失效。示例用已有合成/示例数据，记录hash；不改统计算法。已有函数不改时不重复科学运行。

完成后写 E:/research-wiki/维护记录/2026-10-23-分类与灵活输入/claude-result.md、verification-matrix.md，列修改、实际命令/退出码、R/Python输入绑定前后表/图对照、保护检查、缺项和风险。不要先部署、重启服务或提交开发仓库；知识库写操作走save，尽量批次刷新facts/验收避免每页反复save耗时。Codex审查后部署，审查修复恢复本轮会话。细节选择可做最小实现并记录，但不能减掉R/独立函数/前后端一致性要求。
