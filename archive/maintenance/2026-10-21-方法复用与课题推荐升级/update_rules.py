from pathlib import Path
import shutil

rw = Path(r'E:\research-wiki\开发\staged\research-wiki')
rep = Path(r'E:\桌面\ARIS\sci-figure-replica-dev-20261020\staged\sci-figure-replica')
family = '方法联想限定为有依据的方法家族推广（如 XGBoost＋SHAP → 满足条件的机器学习模型＋SHAP）：保留原实现，说明适用范围、前提、限制与未实现/未验证分支；不从画法通用性推导宽泛新分析方法。先写文字，有来源代码可按函数契约融入，不自动补算法。'
def edit(path, transform):
    old = path.read_text(encoding='utf-8')
    new = transform(old)
    if old != new:
        path.write_text(new, encoding='utf-8', newline='\n')

def rw_skill(text):
    text = text.replace('数据接口**：方法最后要整理成的表格格式，也就是模板读取的表。', '数据接口**：描述数据含义和执行入口的表格契约。发现阶段不要求列名完全相同；执行前在课题副本适配并检查。')
    text = text.replace('| 要先做分析再出图 |', '| 课题还能做什么分析 | `suggest-methods --q …`，先读课题必要计划、代码、结果和数据说明 |\n| 要先做分析再出图 |')
    text = text.replace('`suggest` 只是初筛：', '两种入口先读 [课题推荐与适配流程](references/project-reuse.md)。优先当前可做项，再列少量补材料候选，说明用途、依据、前提、缺口和代码状态。含义明确可在课题副本映射列名/整理长宽表，含义不清或缺关键数据先问；不自动聚合、填补、换算单位或改变统计逻辑。项目适配先留项目，有通用价值时经作者再次确认才回存。\n\n`suggest` 只是初筛：')
    start = '每种样式除原文用法外，主动考虑还能服务哪些其他分析类型'
    if start in text:
        a = text.index(start); b = text.index('渲染和正式收录', a)
        text = text[:a] + family + text[b:]
    text = text.replace('列名与接口页一致。', '按执行入口在课题副本中适配到接口列名；先核对语义、粒度、量纲与配对关系，记录映射，原表保留。')
    a = text.index('## 每次收录的知识关联')
    text = text[:a] + '''## 每次收录的知识关联与代码

新增或实质更新知识时双向检查“一方法多图／一图多方法”，包括不同来源。核对目的、行单位、语义、量纲、前提和代码能力；有依据在方法侧唯一维护 figure_relations，反向图页和图谱自动派生。分别标“直接可接／需要适配／待核实”及独立验证范围，接口结构匹配不自动等于直接可接。检查记录与未关联原因写正文；不为连通网络硬连。见 [方法家族与关系契约](references/knowledge-linking.md)。

原生代码和复用版附在对应方法/单 panel，保留原语言和源字节，不覆盖原件。网页卡片“查看代码”可在 Wiki 内按版本/文件查看、复制、下载，只读不执行；存在文件不证明可运行或已验证。见 [代码资产](references/code-assets.md)。
'''
    return text
edit(rw/'SKILL.md', rw_skill)

def rules(text):
    a = text.index('对每种选定样式，关联方法先写文字笔记：')
    b = text.index('\n\n', a)
    text = text[:a] + family + text[b:]
    text = text.replace('页面关系靠正文链接表达。', '来源/互补关系靠正文链接表达；方法—图语义关系在方法侧 figure_relations 唯一维护，反向自动派生。')
    text = text.replace('一个方法讲一步分析，按实际数据条件和实现边界说明工具/模型适用性；', '一个方法页可表达有边界的方法家族；写清核心目的、来源具体实现、成立条件、已有代码分支、限制与未验证分支。按实际数据条件和实现边界说明工具/模型适用性；')
    a = text.index('每次新复刻/新模板/新方法必须检查')
    b = text.index('\n\n', a)
    text = text[:a] + '新增/实质更新方法或图样后，双向检查“一方法多图／一图多方法”，包括不同来源。核对目的、语义、行单位、量纲、前提与代码状态，有依据才写 figure_relations（方法侧唯一记录）。状态为 direct/adaptable/candidate，分别为直接可接/需要适配/待核实，另写 verification 的状态、范围、证据。来源图样不能 direct；接口 feeds 只表示结构匹配。方法页/图页/图谱从同一记录派生；归档不再推荐，删除清理关系并审计。正文记录检查范围、依据和未关联原因。详见 research-wiki 的 references/knowledge-linking.md。' + text[b:]
    a = text.index('### 查询与推荐（query）')
    b = text.index('### 体检（lint）', a)
    text = text[:a] + '''### 查询与推荐（query）

1. 先读当前课题必要计划、数据说明、代码、结果表头与运行证据，明确研究目的、样本/行单位、验证设计、当前阶段及未知项。代码存在不证明已跑完；缺目的或关键条件先问作者。不由网页服务器扫描任意课题目录。
2. “课题还能做什么分析”：用 suggest-methods 查 ready 方法，不限是否已有配图；优先少量当前可做项，再给少量有价值且能说明缺哪些材料的候选。说明用途、项目依据、前提、缺口、代码存在/验证范围、可配图样。无合适库存就如实说明。
3. “分析已跑完选图”：先核对结果语义/粒度/量纲/重复层级，再 suggest 查单 panel/模板；不必新增方法。接口/列名不同不能是发现的唯一排除条件，同名也不证明直接适用。suggest-pipeline 结合关系提供候选，agent 仍须读正文。
4. 有现成选择与计划就复用，否则等作者选定。含义清楚且不改分析逻辑时，课题副本可映射列名、列顺序、文件名和长宽表；原表不改，继续通过执行入口的严格检查。核对源哈希、主键、值、实体、单位与转换可还原；不能要求长宽转换总行数相同。
5. 未知单位/指标定义、重复身份不清、缺关键材料，或涉及聚合/删行/填补/补样本/重算统计量/单位换算/阈值或验证设计改变，说明具体差异先问作者。缺包也先问，不在 Wiki 装包或换 Wiki 环境代跑课题。
6. 选定后复制代码到课题，用课题环境运行、检查前提/诊断、出图并 record-use。无算法的文字笔记不授权补算法。方法/图关联直接可接不证明当前课题统计有效。
7. 复用课题已有记录；无约定则用 <课题>/wiki-use/<本次标识>/ 记录 context、recommendations、mapping、实际调用与检查。项目映射先留课题；有通用价值时提出回存内容和证据，作者再次确认才入库，不覆盖原版或污染全库接口。详细模板见 research-wiki 的 references/project-reuse.md。

### 原生代码与网页查看

原生 source/ 与复用 code/ 分开，语言/字节/来源/许可证/哈希保留；原文片段不能标成完整原版。方法、单 panel 图样、模板卡片的“查看代码”在 Wiki 内显示版本和文件，支持复制/下载，仅只读查看。未知编码或二进制原字节下载，不运行网页代码或 Notebook 输出，不增独立代码分类。枚举真实文件，无代码如实说明。代码存在、页面 ready、关系兼容与实际验证范围独立。详见 research-wiki 的 references/code-assets.md。

''' + text[b:]
    return text
edit(rw/'assets'/'AGENTS.md', rules)

def rep_skill(text):
    a = text.index('对每种样式，除原文用法外主动考虑其他可服务的分析类型')
    b = text.index('见 [实施流程]', a)
    return text[:a] + family + text[b:]
edit(rep/'SKILL.md', rep_skill)
def handling(text):
    a = text.index('对每种选定样式，除原文用法外主动考虑还能服务的其他分析类型')
    b = text.index('\n\n', a)
    return text[:a] + family + '家族适用、代码已支持、实际验证三个维度分开，原始版与复用版可在 Wiki 卡片查看，运行在课题环境。' + text[b:]
edit(rep/'references'/'code-handling.md', handling)
edit(rep/'references'/'replication-workflow.md', lambda t:t.replace('方法联想先做有依据的文字笔记；', '方法联想限定有依据的家族推广，保留具体来源实现并列前提/限制/未验证分支，不由图形通用性创建宽泛新方法；'))
for name in ['knowledge-linking.md','project-reuse.md','code-assets.md']:
    shutil.copy2(rw/'references'/name, rep/'references'/name)
print('Updated two source skill guides and packaged Wiki rules; formal Wiki/deploy remain pending tests.')
