# Claude Code 单会话实施交接

用户已明确同意最小依赖独立拆解，并要求先写方案，再你执行、Codex 审查。你是唯一编码者。不要启动任何子代理/其他编码器，不停在计划或重复询问实施许可。

完整阅读同目录 design.md、implementation-plan.md、E:/research-wiki/知识库/AGENTS.md、README.md 及两轮旧 final-acceptance。按 T0→T6 执行并更新本轮 progress.md。现有方法分类/灵活输入/作者确认已经交付，不重做。当前开发仓库已有61项dirty，不 reset/clean，不覆盖/批量提交历史改动。

目标是实际独立运行：当前多数分析包装仍依赖完整 SCP-local，必须拆局部调用闭包；16个SCP图模板多数已提取局部核心，要审计验证，不能因含SCP字样盲改。Monocle2/3从当前固定原代码提取到既有trajectory-inference分支，不新写算法。成熟算法调用底层包，必要传递依赖保留；SCP自己的核心/辅助代码原语言保留。source和原图不动。

建立一个方法/模板共享的最小运行清单与后端派生事实，前端按同一事实区分独立声明/独立迁移已验证/整库依赖/未审计，与算法verified/not_run分开。复制指定模块到异目录、新进程、不提供完整SCP路径、只凭必要依赖实际调用才证明独立迁移；假引擎或source通过不算算法验证。

不安装任何R/Python/npm依赖，不读/调用E:/paper-harness，不自动创建Python环境，不换统计默认或用近似画法替换原生图。缺包保持准确not_run。输入保持原样，bindings/旧render/layout/尺寸/单panel/来源回放/领域用途URL不回退。保留作者user/status/favorite、旧id及历史收据，不代签。

工具路径和源码位置见计划。R先应用E:/research-wiki-env/work/scp-runtime.ps1；通用Python D:/anaconda/python.exe -X utf8，wiki/pytest用C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe -X utf8。维护资料都写 E:/research-wiki/维护记录/2026-10-23-最小依赖独立模块/，每个独立阶段更新progress.md，报告必要进度/结果，不在结果里输出凭据或思考过程。

你可直接处理本轮开发代码和知识库内容。规则同步正式AGENTS、staged/assets/AGENTS、SKILL和references，入库八步增加最小闭包/依赖/资源/异目录真实验证。正式页面写操作最终用staged wiki.py save、lint/pending、受影响check-entry --record，不改原始层或作者签核。

到可审查状态写claude-result.md、verification-matrix.md、逐实现/逐模板dependency-inventory与真实证据路径。不要先部署、重启正式服务、提交开发仓库；Codex独立审查，问题在本会话resume修复，审查通过才部署五处。
