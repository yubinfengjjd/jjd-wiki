from pathlib import Path
import sys
root = Path(r'E:\research-wiki\知识库')
stage = Path(r'E:\research-wiki\开发\staged\research-wiki')
replica = Path(r'E:\桌面\ARIS\sci-figure-replica-dev-20261020\staged\sci-figure-replica')
sys.path.insert(0,str(stage))
from rwiki.pages import read_page,write_page,get_block,section_bounds

rules = '''

### 入库与展示验收

新收录或实质更新的知识按以下标准检查；未完成项明确列出，不以入库、代码存在或页面ready代替实际验收。历史单panel模板可以保留，注明历史来源与尚未迁移的能力，不据新标准伪造已完成记录。

| 检查项 | 验收要求 |
|---|---|
| 来源与范围 | 新图样只记录已选定的一个逻辑panel；裁图、完整原图/bbox、数据及代码来源可追溯，估读/合成标注清楚。原图与原生代码只读，关键选择复用作者已给答案。 |
| 图样去重 | 模型/指标/颜色/组数变化不机械新增样式。方法配图只在明示的来源与模板覆盖关系成立时合并视觉入口，保留所有语义关系及来源链接；不同结构变体和不同方法不得因图型同名而误合并。 |
| 两栏数量 | 单panel图样统计来源记录，可调用模板统计函数入口，允许一对多、多对一，数量不要求相等。每个模板要说明来源；历史整图来源归档隐藏时，在对应单panel模板显示历史来源标识及数量说明，不为凑数重新收录整图或虚构来源条目。 |
| 方法家族 | 写清用途、原始具体实现、可推广范围、适用/不适用、输入、输出、代码与未验证分支。原实现保留，方法联想有依据；一方法多图/一图多方法双向检查，不能从通用画法推出无边界的新分析。 |
| 数据与关系 | 按语义、行单位、量纲、配对和研究前提判断。列名/长宽表不一致可在课题副本适配；缺数据或改变统计逻辑先问。关系direct/adaptable/candidate与运行验证分别记录；需适配的图明确写数据来自何处、还缺何种准备，不制造直通流水线。 |
| 代码资产 | 有原生代码则保持原语言与原字节/哈希，原始版/复用版可区分；卡片查看代码真实可用，可复制/下载。无代码的方法如实标文字笔记，不补算法凑齐。绘图与分析分离，函数可复制到课题，任意合法n由实际数据识别并编排。 |
| 方法页可读性 | 以用途、分析输入/输出、去重配图及适配说明为主要入口；像SHAP页一样能辨认方法与结果、图的对应，但不能照抄其直接可接能力。来源、接口结构和完整证据可展开查看，原始Markdown保留完整事实与作者备注。无配图/无直连接口如实解释，不只呈现误导性的空链路。 |
| 状态与队列 | 来源签核、模板回放、作者确认和实际运行验证分开。CLI/网页按同一个workflow判定剩余动作，来源与模板不重复计数；已确认且覆盖完整退出待办，归档/删除/恢复后重算。不为清零改签核状态。 |
| 实际验收 | 检查数据/代码/预览链接与前端实际呈现；模板完成公开verify-template、换数据/规模/可移植检查与作者确认。方法笔记核对边界和代码验证范围后交作者确认；文字笔记不强制具备可执行流水线。机械/示例通过不扩大成统计、真实课题或科学有效性证明。 |
| 交付一致 | 记录检查范围、依据、未通过/未测项；规则变更同步正式Wiki与三处全局安装，共用同一库。更新不改变已确认的数据、算法、来源、作者区块和签核；若需实质改变，单独说明并询问。 |

SHAP和回归评估仅是同一验收标准的不同例子：前者的已声明输出表对应三个历史绘图模板；后者有两个绘图模板，但要另准备同源RGB/边缘表或选定指标与摘要，仍标需要适配。例子的图数、模型名和列名不是后续入库的固定要求。
'''
for path in (stage/'assets/AGENTS.md',root/'AGENTS.md'):
    txt=path.read_text(encoding='utf-8')
    assert '### 入库与展示验收' not in txt
    path.write_text(txt+rules,encoding='utf-8',newline='\n')
assert (stage/'assets/AGENTS.md').read_bytes()==(root/'AGENTS.md').read_bytes()

for path, text in [
    (stage/'SKILL.md', '\n\n## 入库验收\n\n按正式Wiki AGENTS.md“入库与展示验收”逐项核查：来源/单panel范围、明示覆盖关系下的配图去重、两栏数量口径、方法家族边界、多对多关系与适配、代码资产、前端实查和队列交接。两栏统计来源记录与函数入口，数量不要求相等；历史整图来源已归档的单panel模板需显式标识。方法页优先用途、输入/输出、去重配图与适配要求，完整证据可展开；不照抄示例的图数或direct能力，不改完整Markdown事实/作者备注。未完成验收项如实记录，不补算法或凑来源。\n'),
    (replica/'SKILL.md', '\n\n## 交接 Wiki 的验收\n\n正式收录与实质更新同时遵守research-wiki读取的正式库AGENTS.md“入库与展示验收”：来源/单panel范围、覆盖关系下的配图去重、方法家族与双向关联、数据适配、原生/复用代码、前端实查及状态交接。来源图样数与函数模板数不要求相等；历史整图只保留溯源，单panel模板须显式说明历史来源，不为凑数重建整图或虚构来源。方法页面先呈现用途、输入/输出、配图和适配要求；不得借画法相似把需要适配改成直接可接。\n')]:
    txt=path.read_text(encoding='utf-8')
    assert text.strip() not in txt
    path.write_text(txt+text,encoding='utf-8',newline='\n')

path=root/'methods/regression-resampling-evaluation.md'
meta,body=read_page(path)
author=get_block(body,'user')
original_para='本页依据原帖主题及官方文档重新编写，不代表原帖的缺失函数已恢复，也不复现其数值。原帖明确使用模拟数据；文献的重复随机划分与帖子改用的 K 折是两种设计，必须分别记录。'
assert original_para in body
body=body.replace(original_para, '## 原始实现与家族范围\n\n'+original_para+'\n\n家族限定为连续结局预测模型的验证评估：可对不同模型沿用相同预测/指标定义，但训练、调参与验证划分仍在课题中实现。现有 `code/summarize_predictions.py` 只汇总已有验证预测，不包含原帖缺失的模型训练函数；其他模型或重采样分支不因写入家族说明就视为已实现或验证。',1)
start,end=section_bounds(body,'知识关联检查')
# Replace only agent-authored trailing history, leaving facts and author bytes in place.
user_start=body.index('<!-- user:start -->')
body=body[:start]+'''
本方法对应两种单panel画法；来源与对应函数在前端合并展示，关系记录分别保留。数据来源与准备步骤不同，不把两张图都误写为直接读取逐折指标。

| 图模板 | 对应数据 | 仍需适配 |
|---|---|---|
| [[templates/2026-10-19-regression-stability__fig03-density-panel--density-scatter|密度散点与边缘分布]] | 方法输入中的逐样本真实值/验证预测 | 明确颜色密度含义与算法、边缘分布及真实注释后准备绘图表；不得沿用估读颜色推断真实频数。 |
| [[templates/2026-10-19-regression-stability__fig04-boxplot-panel--boxplot|箱线、散点与均值]] | 方法输出中的逐折指标，选择一个实际指标 | 核对验证单位和折间相关性；明确箱体/须规则，准备同源点和摘要，抖动只作展示。 |

两张绘图模板已由作者确认可用，估读/合成示例仅说明画法；真实方法→准备表→绘图的课题流水线尚未联调。可查看模板代码并复制到课题，缺上游算法仍需先与作者确认，不能以格式适配名义补写。

已双向核查现存方法、来源、模板及接口。与 [[methods/shap-explanation|机器学习模型 + SHAP 解释]] 互补：本方法评估预测表现，SHAP解释既定模型的特征归因。预测/指标表不包含SHAP所需模型、特征与背景，因此不新增虚假的数据流连接；SHAP三图也不据此被标成性能评估图。

两篇旧宽泛迁移笔记 [[methods/paired-reference-visual-comparison|配对值迁移（已归档）]]、[[methods/repeated-benchmark-distribution|基准分布迁移（已归档）]] 保留历史且不再推荐。有依据内容限定在本家族：配对与量纲一致、重复/折身份可追踪、点与摘要同源。方法家族不推广成参考解、耗时/内存等其他分析。

'''+body[user_start:]
assert get_block(body,'user')==author
assert meta['status']=='ready'
write_page(path,meta,body)
print('Rules and regression method organization aligned; states/relations/author block retained.')
