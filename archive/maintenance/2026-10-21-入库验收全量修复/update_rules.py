from pathlib import Path

ROOT=Path('E:/research-wiki')
stage=ROOT/'开发/staged/research-wiki'
rules=ROOT/'知识库/AGENTS.md'
note='''

### 入库验收的执行入口（2026-10-21 修复）

- 来源读取版本 `gallery_version` 与作者已签版本 `signedoff_version` 独立。网页签核记录当前来源版本；新版本反复 ingest 都保持待签核，刷新不能代替作者签核。来源在页面读取后又更新时先重新收录核对。历史已确认来源保留其原签核事实，不因迁移虚构新确认。
- `verify-template` 的成功记录绑定当前 code、spec、示例数据、接口列定义和 PNG/PDF/SVG 输出哈希。修改这些输入、替换输出或失败重跑均使旧回放失效，旧记录保留历史。未绑定哈希的旧回放不作为当前执行证据；先用原代码/原示例重新 verify，不改算法或伪造记录。回放环境与范围另记，不能证明所有依赖环境或科学有效。
- `mark-ready` 拒绝只有 preview 的模板；来源可选 ready 也须有效 layout 回放。方法确认核查用途、适用/不适用、输入、怎么做、代码状态、输出和知识关联检查；空骨架/TODO 仍由 agent 完善。有内容的文字方法可无代码/接口，明确无匹配理由即可，不为验收补算法。
- 方法、模板及来源正文都写“知识关联检查”：日期、查过的页面/范围、一方法多图与一图多方法判断、依据/限制、无匹配原因。机器核查该节和其他必需节不是空白/占位，并检查已声明关系结构；科学语义仍由 agent 核查，不把文字存在当成科学验证。
- 公开 `check-entry <id>` 查询当前缺项；核对完成后 `check-entry <id> --record` 保存 `acceptance.json` 和 Git 记录。确认入口也自动保存相同验收记录。记录内容指纹、已检查节及回放范围，不推进作者状态、不证明科学有效。实质更新后重新检查，作者区块、facts、标签/收藏与验收内容分开。
- `pending --json` 与网页共用 workflow，列出所有仍需 agent 的方法/模板/来源动作，包含真实缺项；默认 `pending` 为兼容旧用法仍只列来源 ID。处理待办优先 JSON，不遗漏方法或独立模板，不重复 scaffold、不为清零改签核。已有 ready 条目出现回放或验收内容变动时显示真实待核查动作，原签核事实保留。
- 图库与方法页共用明示覆盖分组：多个来源完整、双向复用同一模板时只显示一个图样，并保留每个来源链接。未知覆盖、非法重复覆盖及不同结构不合并；图样/函数两栏仍可重叠，SHAP 单panel不因整图来源归档而消失。
- 通用表格入口检查文件和必需列，具体函数另查其前提。类型、缺失、单位、实体/配对和科学含义必须由课题 agent 与具体方法核查；列名通过不等于数据有效。不得靠关闭结构检查兼容数据，也不自动转换单位、填补或改统计逻辑。
'''
old=rules.read_text(encoding='utf-8')
assert '### 入库验收的执行入口' not in old
rules.write_text(old+note,encoding='utf-8',newline='\n')
(stage/'assets/AGENTS.md').write_bytes(rules.read_bytes())

skill_note='''

## 当前版本的验收与待办

处理待办用 `pending --json` 查看所有 agent 动作（含方法/独立模板）；默认 `pending` 只列来源 ID。草稿方法必须填完必要说明和“知识关联检查”后才交作者确认；文字笔记可无代码，无关联时说明检查范围和原因，不补算法。`check-entry <id>` 查询缺项，核对后 `check-entry <id> --record` 记录验收；确认入口共用检查并自动记录。

来源签核绑定已签版本，重复 ingest 不批准新版本。回放绑定 code/spec/example/接口与三个输出的哈希；改变输入或失败重跑后重新 verify，不能只凭 preview 标 ready。旧回放先以原代码/示例刷新执行证据，不改历史作者确认或宣称任意 n 迁移。验收指纹变化会提示核查，不能为清零伪造证据。

图库与方法页按同一个明示覆盖规则去重，多个来源完整复用同一模板时保留所有来源链接。通用表格检查只保证文件/必需列，类型、缺失、单位、配对与科学前提另由课题 agent/具体方法核对。完整规则见总库 AGENTS.md“入库验收的执行入口”。
'''
p=stage/'SKILL.md';p.write_text(p.read_text(encoding='utf-8')+skill_note,encoding='utf-8',newline='\n')
p=Path('E:/桌面/ARIS/sci-figure-replica-dev-20261020/staged/sci-figure-replica/SKILL.md')
p.write_text(p.read_text(encoding='utf-8')+'''

### Wiki 入库验收交接

按 research-wiki `check-entry <id>` 核查和记录适用/不适用及知识关联检查；拆出函数后用当前代码/示例完成带输入与输出哈希的 verify-template。只有预览、旧版无哈希记录或修改前回放都不能替代当前验证，仍需作者确认。来源签核绑定版本，重复入库不自动签核新版本。处理待办读 `pending --json`，继续真实缺项，避免遗漏方法或重复新建。

图样/可调用模板是重叠视图；共享同一函数且明示完整覆盖的多个来源可合为一个图样入口并保留来源链接，不靠图型同名合并结构变体。不得为新的验收规则补分析算法、伪造科学关联、改变作者区块或把既有 SHAP 图样隐藏。
''',encoding='utf-8',newline='\n')

p=stage/'references/knowledge-linking.md'
s=p.read_text(encoding='utf-8').replace('最后 `save`、`lint`。lint 只检查结构/引用，科学含义仍需 agent 审查。',
    '完成正文后 `check-entry <id>` 核查并按需 `--record`，再 `save`、`lint`。确认入口拒绝空白/TODO关联检查；机器只检查内容完整性与关系结构，科学含义仍需 agent 审查。')
p.write_text(s,encoding='utf-8',newline='\n')
p=stage/'references/project-reuse.md'
s=p.read_text(encoding='utf-8').replace('继续通过原有 render 的严格接口检查，不关闭检查以获得兼容。',
    '继续通过 render 的文件/必需列检查，并由课题 agent 和具体函数核对类型、缺失、单位、实体/配对与方法前提；表头通过不是科学有效性证明。不关闭结构检查以获得兼容。')
p.write_text(s,encoding='utf-8',newline='\n')

p=ROOT/'文档/当前要求与同步核查.md'
s=p.read_text(encoding='utf-8')
s=s.replace('| 联想还能用于哪些分析，先写文字笔记 | AGENTS.md 咨询及收录方法条款；methods/ 的迁移笔记；有依据用途和待验证想法区分，无代码不自动补算法 |',
    '| 有边界的方法家族推广，先写文字笔记 | 例如 XGBoost＋SHAP 推广至满足前提的机器学习模型＋SHAP；原实现、限制和未验证分支分别说明。两篇旧宽泛迁移笔记已归档，不再推荐 |')
s=s.replace('历史整图归档隐藏；四个方法有配图，参考图与接口可接模板分别标识',
    '历史整图归档隐藏；有效方法有依据配图，参考、需适配和直接可接分别标识；SHAP 三个单panel同时属于图样与模板')
s=s.replace('- 两个回归代表单 panel 的复刻及便携函数资源已在画廊中，但来源仍待作者签核；没有自动晋升成 ready 可推荐模板。统计方法迁移笔记仍保留其待确认状态。',
    '- 两个回归代表单 panel 来源与两个函数模板已由作者确认；来源可保留 pending_template 而有效覆盖显示完成，不要求额外 layout 回放。旧宽泛迁移笔记继续归档；当前状态查询 workflow，不据本页重建待办。')
s=s.replace('- 前端 7 项及后端 34 项检查的上次证据、正式入口截图见 `维护记录/2026-10-21-前端与知识关联修复/`。本次进行了同步文件比较及文档核查，没有把上次测试写成重新运行。',
    '- 各次维护目录记录当时快照；最新入库修复与验证见 `维护记录/2026-10-21-入库验收全量修复/`。不累计有重叠的测试数，也不把历史完成状态当作当前状态。')
s+='''

## 当前查询与执行入口

动态待办用 `wiki.py pending --json` 或正式 `/api/pages` 的 workflow；图样/模板状态和已验证版本以页面及验收/回放记录为准。本索引不维护另一份固定待办数量。

入库执行标准统一见 `知识库/AGENTS.md`“入库验收的执行入口”：来源版本签核、当前输入/输出回放、方法说明与双向知识关联检查、`check-entry` 验收记录共用检查逻辑。机器验收不是科学适用性或真实课题端到端证明。旧日志保留历史，不再执行其中已被后续决定替代的动作。
'''
p.write_text(s,encoding='utf-8',newline='\n')
print('rules and current index updated; historical reports retained')
