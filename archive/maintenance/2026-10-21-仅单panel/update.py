from pathlib import Path
import json, hashlib, shutil, re

ROOT=Path('E:/research-wiki')
OUT=ROOT/'维护记录/2026-10-21-仅单panel'
RW=ROOT/'开发/staged/research-wiki'
REPL=Path('E:/桌面/ARIS/sci-figure-replica-dev-20261020/staged/sci-figure-replica')
INST=[Path('C:/Users/86186')/x/'skills' for x in ['.agents','.codex','.claude']]
changed=[]
def put(p,s):
    p=Path(p)
    if p.exists():
        backup=OUT/'修改前'/hashlib.sha256(str(p).encode()).hexdigest()[:12]/p.name
        backup.parent.mkdir(parents=True,exist_ok=True)
        if not backup.exists(): shutil.copy2(p,backup)
    p.parent.mkdir(parents=True,exist_ok=True)
    p.write_text(s,encoding='utf-8')
    changed.append(str(p))
def read(p): return Path(p).read_text(encoding='utf-8-sig')
def edit(p,pairs):
    s=read(p)
    for a,b in pairs:
        assert a in s,(str(p),a)
        s=s.replace(a,b)
    put(p,s)

# A full baseline protects original gallery evidence and all author blocks.
gallery={str(p.relative_to(ROOT/'画廊')):hashlib.sha256(p.read_bytes()).hexdigest()
         for p in (ROOT/'画廊').rglob('*') if p.is_file()}
users={str(p.relative_to(ROOT/'知识库')):re.findall(r'<!-- user:start -->.*?<!-- user:end -->',read(p),re.S)
       for p in (ROOT/'知识库').rglob('*.md')}
put(OUT/'protected-before.json',json.dumps({'gallery':gallery,'users':users},ensure_ascii=False,indent=2))

rule='复刻与新收录只接受一个逻辑 panel。先识别去重样式，再询问代表单 panel、数据及关键细节并确认计划；完整原图只读保留在画廊用于溯源，不作为 Wiki 条目或复刻交付目标。现有整图来源已归档并在前端隐藏，保留其来源记录及既有单 panel 模板。图库仅保留“单 panel 图样”和“可调用模板”。'
edit(RW/'SKILL.md',[
 ('默认每个选定样式一个代表单 panel','每个选定样式只做一个代表单 panel'),
 ('整组图仍可按作者明确选择制作。','完整整图仅作只读溯源，不复刻整组或收录整图条目。'),
 ('（整张组图用 `render-layout`）',''),
 ('单panel来源与整组来源、可调用模板分开展示','单panel图样与可调用模板分开展示，历史整图来源归档并隐藏'),
])
edit(REPL/'SKILL.md',[
 ('默认制作代表单 panel，也支持明确选定的整组图','只制作确认选定的代表单 panel，整图仅保留作只读溯源'),
 ('及其多面板数据图','；多面板来源先识别去重样式，选代表单 panel'),
 ('默认每个选定样式只做一个代表单 panel；作者明确要整组时支持整组。','每个选定样式只做一个代表单 panel；不提供整组复刻或整图收录选项。'),
 ('单panel来源与整组来源、可调用模板分开展示','单panel图样与可调用模板分开展示，历史整图来源归档并隐藏'),
])
agents=read(RW/'assets/AGENTS.md')
agents=agents.replace('选定来源单位：可为一个逻辑 panel，也可为作者明确选择的整组，记录所含模板及排列。','一个逻辑 panel 来源，记录所含模板；历史整图仅保留归档记录。')
agents=agents.replace('默认每个选定样式只做一个代表单 panel','每个选定样式只做一个代表单 panel')
agents=agents.replace('作者明确要求的整组与旧条目继续支持，不自动迁移历史。','完整整图只在画廊只读保留作溯源，不再复刻整组或新建整图 Wiki 条目。历史整图来源通过 Wiki API 归档并在前端隐藏，保留历史模板的出处。')
agents=agents.replace('内部 layout 页可代表选定单 panel，不要求先重建整组。','新 layout 页只代表一个选定逻辑 panel；收录前核对 panel_map 恰好一项。完整原图不进入新 Wiki 条目。')
agents=agents.replace('图库按单panel图样、整组图版式、可调用模板区分。内部layout同时容纳单panel和整组来源，不等同“整图”；逻辑panel数而非axes数决定来源范围。','图库仅按单panel图样、可调用模板两栏区分。新layout只容纳单panel来源；历史整图归档隐藏。逻辑panel数而非axes数决定来源范围。')
agents=agents.replace('完整组图才核对全组覆盖与整体对比。','不再制作整组回放或要求未选 panel。')
agents=agents.replace('作者要单张图就推荐 panel 模板，要整张组图就推荐版式。','只推荐单 panel 图样或模板，不推荐归档整图版式。')
agents=agents.replace('## 三层','## 当前收录范围\n\n'+rule+'\n\n## 三层',1)
put(RW/'assets/AGENTS.md',agents)
put(ROOT/'知识库/AGENTS.md',agents)
for base in [RW,REPL]:
    p=base/'references/knowledge-linking.md'
    s=read(p).replace('收录单panel/整组来源','收录单panel来源')
    start=s.index('前端分三栏：');end=s.index('\n\n',start)
    s=s[:start]+rule+s[end:]
    put(p,s)

# Replace operational exceptions rather than merely adding a conflicting notice.
replacements={
 'replication-workflow.md':[
  ('# 按选定样式执行、组合布局与签核','# 按代表单 panel 执行与签核'),
  ('默认一个代表单 panel 一个条目，结构变体另建条目 id；明确选整组才按整组建条目。','一个代表单 panel 一个条目，结构变体另建条目 id；整图仅作只读来源，不建立整图条目。'),
  ('多面板可用 patchwork。先验证选定单 panel；作者要求整组时再用同一绘图核心拼装。','仅复刻选定的单 panel。'),
  ('仅在选定完整组图时，`examples/post01-fig4` 的历史 T3 六面板经验适用；它不要求单 panel 任务重建全组：','`examples/post01-fig4` 仅为历史归档经验，不是本流程的复刻或收录选项；从中识别单 panel 的附属元素时可参考：'),
  ('整组回放仅在已选范围是整组时要求，不能把未选 panel 加进覆盖门槛。','不再提供整组回放选项，不能把未选 panel 加进覆盖门槛。')],
 'image-analysis.md':[
  ('作者明确选择整组时再按整组规划。','多 panel 原图只作溯源，识别去重后询问代表单 panel，不规划整组复刻。'),
  ('整组才记录完整行列与排列。','完整行列仅在原图溯源记录中保留，不作为交付范围。')],
 'visual-qa.md':[
  ('默认对作者选定的代表单 panel 验收','只对作者选定的代表单 panel 验收'),
  ('整组只有明确选定时才做完整行列和整体覆盖。','整图仅作只读溯源，不作为本轮验收目标。')],
 'gallery-layout.md':[
  ('选定裁图；整组任务为选定整图','选定的单 panel 裁图；完整整图另存只读溯源'),
  ('默认一个去重样式的代表单 panel 对应一个条目，实质结构变体用不同条目 id；作者明确要求的整组和历史整组条目继续保留。','一个去重样式的代表单 panel 对应一个条目，实质结构变体用不同条目 id；历史整组条目仅作溯源保留，不再新增整组或收录进 Wiki。'),
  ('整图条目继续按整图去重。','历史整图条目仅保留旧记录，不再新增。')]
}
for rel,pairs in replacements.items(): edit(REPL/'references'/rel,pairs)

# Enforce the local scope at intake, while retaining the historical engine/schema.
edit(RW/'rwiki/config.py',[
 ('    function_defaults: dict = field(default_factory=dict)','    function_defaults: dict = field(default_factory=dict)\n    single_panel_only: bool = False'),
 ('    defaults = values.get("function_defaults", {})','    single_only = values.get("single_panel_only", False)\n    if not isinstance(single_only, bool):\n        raise WikiError("single_panel_only 必须是布尔值")\n    defaults = values.get("function_defaults", {})'),
 ('function_defaults=defaults)','function_defaults=defaults, single_panel_only=single_only)')])
edit(RW/'rwiki/ingest.py',[
 ('    relative_entry = entry.relative_to(config.gallery_root).as_posix()',
  '    if config.single_panel_only and len(panel_map) != 1:\n        # Existing historical records remain untouched, never reactivated by ingest --all.\n        if path.exists() and read_page(path)[0]["status"] == "archived":\n            return\n        raise WikiError("仅收录一个逻辑 panel；请先识别样式、确认代表裁图。整图只保留作溯源。")\n    relative_entry = entry.relative_to(config.gallery_root).as_posix()'),
 ('            ingest_entry(config, path.parent, expected_id, taxonomy)',
  '            if config.single_panel_only and len(read_json(path)["figure"].get("panel_map", {})) > 1:\n                continue\n            ingest_entry(config, path.parent, expected_id, taxonomy)')])
edit(RW/'rwiki/suggest.py',[
 ('        target = path.with_suffix("")','        if config.single_panel_only and meta["type"] == "layout" and len(meta["panels"]) != 1:\n            continue\n        target = path.with_suffix("")')])
cfg=json.loads(read(RW/'config.json'));cfg['single_panel_only']=True
put(RW/'config.json',json.dumps(cfg,ensure_ascii=False,indent=2)+'\n')

# Filter whole sources once, before cards, graph, search, queue, and hero receive data.
edit(ROOT/'开发/frontend/src/figureModels.ts',[
 ("export type FigureShelf = 'single' | 'group' | 'template';","export type FigureShelf = 'single' | 'template';\n\nexport function isWholeSource(meta: PageSummary['meta']): boolean {\n  return meta.type === 'layout' && Object.keys(meta.panels).length !== 1;\n}\n\nexport function singlePanelKnowledge(pages: PageSummary[], graph: GraphData) {\n  const hidden = new Set(pages.filter((p) => isWholeSource(p.meta)).map((p) => p.path));\n  return {\n    pages: pages.filter((p) => !hidden.has(p.path)),\n    graph: { nodes: graph.nodes.filter((n) => !hidden.has(n.id)),\n      links: graph.links.filter((e) => !hidden.has(e.source) && !hidden.has(e.target)) },\n  };\n}"),
 ("return count === 1 ? 'single' : count > 1 ? 'group' : null;","return count === 1 ? 'single' : null;"),
 ("return { single: '单 panel 图样', group: '整组图版式', template: '可调用模板' }[shelfOf(meta) ?? 'group'];","return meta.type === 'template' ? '可调用模板' : '单 panel 图样';"),
 ("page.meta.status === 'archived') continue;","page.meta.status === 'archived' || isWholeSource(page.meta)) continue;")])
edit(ROOT/'开发/frontend/src/App.tsx',[
 ("import { Flow } from './flow';","import { Flow } from './flow';\nimport { singlePanelKnowledge } from './figureModels';"),
 ('    setPages(p);\n    setGraph(g);','    const visible = singlePanelKnowledge(p, g);\n    setPages(visible.pages);\n    setGraph(visible.graph);')])
edit(ROOT/'开发/frontend/src/views/Gallery.tsx',[
 ("  group: ['pending_signoff', 'pending_template', 'ready'],\n",''),
 ("  ['group', '整组图版式'],\n",''),
 ('按实际范围查看单 panel 图样与整组图版式，或选择已拆出的可调用模板。来源图样可以独立签核，无须先复刻整组。','这里只收录单 panel 图样与可调用模板。先识别去重样式，再确认代表单 panel、数据和复刻细节；完整原图仅保留作溯源。'),
 ('本栏尚无来源图样。用 sci-figure-replica 复刻后，按实际 panel 范围归入对应栏。','本栏尚无单 panel 图样。确认样式与细节后，用 sci-figure-replica 复刻代表单 panel。')])
edit(ROOT/'开发/frontend/src/views/QueueView.tsx',[
 ('按已签核的单 panel 或整组范围制作函数模板并回放','按已签核的单 panel 制作函数模板并回放')])
edit(ROOT/'开发/frontend/src/views/PageView.tsx',[
 ('figureLabel, methodFigures, MethodFigure','figureLabel, isWholeSource, methodFigures, MethodFigure'),
 ('  const { meta } = page;','  const { meta } = page;\n  if (isWholeSource(meta)) return <p className="notice">整图来源已归档并隐藏。请从图库选择单 panel 图样或可调用模板；完整原图保留在画廊作溯源。</p>;')])

# Refresh all installed copies of exactly the changed files; preserve other work.
rw_rels=['SKILL.md','assets/AGENTS.md','references/knowledge-linking.md','config.json','rwiki/config.py','rwiki/ingest.py','rwiki/suggest.py']
rep_rels=['SKILL.md','references/knowledge-linking.md']+['references/'+x for x in replacements]
for skill,source,rels in [('research-wiki',RW,rw_rels),('sci-figure-replica',REPL,rep_rels)]:
    for base in INST:
        for rel in rels: put(base/skill/rel,read(source/rel))
put(OUT/'changed-files.json',json.dumps(changed,ensure_ascii=False,indent=2))
print('Updated source, frontend, scope configuration and all six skill installations. Archive pending API step.')
