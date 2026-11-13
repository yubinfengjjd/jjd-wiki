from pathlib import Path
root=Path(r'E:\research-wiki\知识库')
stage=Path(r'E:\research-wiki\开发\staged\research-wiki')
replica=Path(r'E:\桌面\ARIS\sci-figure-replica-dev-20261020\staged\sci-figure-replica')
old='单panel图样统计来源记录，可调用模板统计函数入口，允许一对多、多对一，数量不要求相等。每个模板要说明来源；历史整图来源归档隐藏时，在对应单panel模板显示历史来源标识及数量说明，不为凑数重新收录整图或虚构来源条目。'
new='单panel图样按逻辑图形样式浏览，包含已有单panel函数模板；可调用模板按函数入口浏览，同一记录可同时出现在两栏。图样依据明示来源覆盖去重，不能按页面存储类型把模板排除。历史整图来源归档只隐藏整图，不隐藏已拆出的单panel图样；保留出处与能力限制，不新增伪来源或待办。两栏允许一对多、多对一，数量不要求强行相等。'
extra='\n\n单panel图样与可调用模板是可重叠的浏览视图，不是互斥的页面类型。已拆出的SHAP条形、蜂群、环形等合法单panel模板也属于图样；不能因其仍追溯到归档整图而遗漏。已有对应单panel来源时按明示覆盖只展示一次，缺独立来源页时直接链接现有模板记录，不为前端展示重新入库或生成待办。\n'
for path in (root/'AGENTS.md',stage/'assets/AGENTS.md'):
    text=path.read_text(encoding='utf-8')
    assert old in text
    text=text.replace(old,new)
    text=text.replace('图库仅保留“单 panel 图样”和“可调用模板”。','图库保留“单 panel 图样”和“可调用模板”两个可重叠浏览入口。',1)
    text=text.replace('图片、状态和范围都需在前端实查。','图片、状态和范围都需在前端实查，逐一检查已有单panel函数模板能在图样入口找到。',1)
    text+=extra
    path.write_text(text,encoding='utf-8',newline='\n')
assert (root/'AGENTS.md').read_bytes()==(stage/'assets/AGENTS.md').read_bytes()
path=stage/'SKILL.md'
text=path.read_text(encoding='utf-8')
old='两栏统计来源记录与函数入口，数量不要求相等；历史整图来源已归档的单panel模板需显式标识。'
new='图样栏按逻辑样式浏览，包含已有单panel函数模板；模板栏按函数入口浏览，同一记录可在两栏出现。按明示来源覆盖去重，不能用存储页面类型排除模板；历史整图归档不隐藏已拆出的单panel图样，不为补展示而重新入库或新增待办。'
assert old in text
path.write_text(text.replace(old,new),encoding='utf-8',newline='\n')
path=replica/'SKILL.md'
text=path.read_text(encoding='utf-8')
old='来源图样数与函数模板数不要求相等；历史整图只保留溯源，单panel模板须显式说明历史来源，不为凑数重建整图或虚构来源。'
new='单panel图样包含已有单panel函数模板，两栏可重叠；按明示覆盖去重，不按页面存储类型排除。历史整图只保留溯源，但已拆出的单panel必须在图样入口可见；使用既有记录，不重复入库、虚构来源或新增待办。'
assert old in text
path.write_text(text.replace(old,new),encoding='utf-8',newline='\n')
print('Wiki and both skills now require callable single-panel templates to remain visible as styles.')
