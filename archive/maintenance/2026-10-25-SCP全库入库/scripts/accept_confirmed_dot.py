"""Assemble the already-reviewed candidate after the user's explicit approval."""
from pathlib import Path
import json,shutil,subprocess,sys,urllib.request,datetime
R=Path('E:/research-wiki');A=R/'维护记录/2026-10-25-SCP全库入库';W=R/'知识库';G=R/'画廊'
S=R/'开发/staged/research-wiki';C=Path('E:/research-wiki-env/work/scp-ingestion-20261025/candidates/group-heatmap-dot')
sys.path.insert(0,str(S))
from rwiki.pages import read_page,write_page,get_block
eid='2026-10-22-scp-example__fig17-group-heatmap-dot';tid=eid+'--heatmap'
page=W/'layouts'/f'{eid}.md';target=W/'templates'/tid
before=A/'before-confirmed-dot';assert not before.exists(),'Inspect previous attempt; never repeat blindly'
before.mkdir();shutil.copy2(page,before/page.name)
gp=G/'2026-10-22-scp-example/figures/fig17-group-heatmap-dot/meta.json';shutil.copy2(gp,before/'gallery-meta.json')
for rel in ('methods/scp-visualization-interface.md','chart-types/heatmap.md','index.md','log.md'):
    dst=before/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(W/rel,dst)
approval={'user_text':'确认。另外我说的是SCP全部可视化已经方法全部入库。不单单是这个图','approved_scope':'Displayed fig17 dot source and assembling its already-reviewed formal callable template; full-library ingestion requested, not blanket author signoff for unreviewed future plots','time':datetime.datetime.now(datetime.timezone.utc).isoformat()}
(A/'author-confirmation.json').write_text(json.dumps(approval,ensure_ascii=False,indent=2),encoding='utf-8')
request=urllib.request.Request(f'http://127.0.0.1:8765/api/layouts/{eid}/signoff',data=b'{}',headers={'Content-Type':'application/json'},method='POST')
with urllib.request.urlopen(request,timeout=240) as response: approved=json.load(response)
assert approved['meta']['status']=='pending_template' and approved['meta']['signedoff_version']==approved['meta']['gallery_version']
py=Path('C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe')
def cli(*args):
    with (A/'logs'/f'confirmed-dot-{args[0]}.log').open('a',encoding='utf-8') as log:
        p=subprocess.run([str(py),'-X','utf8',str(S/'wiki.py'),'--config',str(S/'config.json'),*args],stdout=log,stderr=log)
    if p.returncode:raise RuntimeError(f'CLI failed {args}; read evidence and resume, never mark ready')
cli('scaffold-template',eid,'--chart-type','heatmap','--panels','A','--title','分组表达点阵热图')
shutil.copytree(C/'code',target/'code',dirs_exist_ok=True)
placeholder=target/'code/__init__.py'
if placeholder.is_file() and placeholder.read_bytes()==b'':placeholder.unlink()
shutil.copytree(C/'example',target/'example',dirs_exist_ok=True)
for name in ('spec.json','runtime.json','README.md'):shutil.copy2(C/name,target/name)
(target/'verify').mkdir(exist_ok=True)
for name in ('runtime-portability.json','comparison.md'):shutil.copy2(C/'verify'/name,target/'verify'/name)
shutil.copy2(R/'维护记录/2026-10-25-SCP续整理/codex-artifacts.json',target/'verify/native-comparison.json')
tp=target.with_suffix('.md');m,b=read_page(tp)
body=f'''# 分组表达点阵热图

<!-- facts:start -->
<!-- facts:end -->

## 适用

按特征×分组展示聚合表达及阈值阳性细胞比例；可将多个分组变量的矩阵并排，保留共同行顺序。来自SCP 0.5.6 GroupHeatmap(add_dot=TRUE)原生几何，背景白；点颜色是变换表达，点直径是0–1比例，顶部色条仅标识分组。支持reticle。

## 不适用

不从聚合均值推算逐细胞比例，不重算聚合、标准化或统计检验。输入不是Seurat对象。add_violin、flip、split、复杂注释未包含；R共享会话会附加依赖包，建议新进程调用。不将示例回放扩大为所有课题科学有效。

## 知识关联检查

2026-10-25核对[[layouts/{eid}]]、既有ht1模板、[[interfaces/render-group-heatmap]]、[[chart-types/heatmap]]和[[methods/scp-visualization-interface]]。点大小额外编码比例，故与ht1保留不同结构入口；同样使用已有长表接口。技术页只作来源映射，不建新分析家族。细胞注释、差异表达和轨迹输出不会自动含本图逐细胞阈值比例，因此未建立direct关系。

## 数据要求

读取render-group-heatmap.csv：一行=matrix×feature×group。value为上游给定的变换表达；percent为逐细胞表达按声明的lib_normalize处理后、聚合/zscore前超过阈值的比例，范围0–1。三种order是显式正整数并与身份一一对应；跨矩阵feature轴一致。CSV身份按字符读取，001/01不丢前导零；factor不冒充数值。原表不改，不补值、聚合或换算。

## 使用记录

2026-10-25作者明确确认后按正常流程组装；代码与已独立核验候选同源。三张PNG、两张SVG匹配独立重跑原函数；1m/2m PDF栅格一致。异目录清单复制、新进程、换合法规模/标签/数字身份、输入不变及异常拒绝均留证。当前正式verify另记录本次真实运行，未验证分支不继承。runtime.json声明只复制本图所需文件和资源，绘图不加载SCP或Seurat。

<!-- user:start -->
<!-- user:end -->
'''
write_page(tp,m,body)
cli('verify-template',tid)
cli('check-entry',tid,'--record')
cli('mark-ready',tid)
# Recompile agent prose; retain the real source's API-managed status/user block.
lm,lb=read_page(page);author=get_block(lb,'user')
start=lb.index('## 知识关联检查');end=lb.index('<!-- user:start -->')
lb=lb[:start]+f'''## 知识关联检查

2026-10-25已核对原生GroupHeatmap点阵与ht1：点颜色表示聚合变换表达、点直径表示逐细胞阈值比例，保留不同结构来源。可调用入口现为[[templates/{tid}|分组表达点阵热图]]；原生代码与来源panel仍在画廊，只读溯源。本来源不代替分析方法，也不自动授予其他GroupHeatmap分支可用。

## 使用记录

2026-10-25作者明确确认后正常签核来源并组装、真实verify和确认模板；独立对照及保护记录见维护记录/2026-10-25-SCP全库入库。源码与既有作者备注保留。

'''+lb[end:]
assert get_block(lb,'user')==author;write_page(page,lm,lb)
for rel in ('methods/scp-visualization-interface.md','chart-types/heatmap.md'):
    p=W/rel;text=p.read_text(encoding='utf-8')
    text=text.replace(f'[[layouts/{eid}|分组表达点阵热图]]',f'[[templates/{tid}|分组表达点阵热图]]')
    text=text.replace('新点阵来源尚待作者签核，未成为正式模板。','点阵来源现已获作者确认并完成正式模板回放，未覆盖分支仍单列。')
    text=text.replace('新增','新增',1)
    text=text.replace('原生提炼候选，来源待签核；','原生正式模板，作者已确认；')
    text=text.replace('新增分析家族','新增分析家族')
    text=text.replace('来源候选待签核：','正式模板已确认：')
    text=text.replace('图样候选不代表模板已就绪。','该确认只覆盖点阵分支。')
    p.write_text(text,encoding='utf-8')
cli('check-entry',eid,'--record');cli('check-entry','scp-visualization-interface','--record')
cli('save','按作者确认完成GroupHeatmap点阵正式模板；继续SCP全库入库')
cli('lint')
tm,_=read_page(tp);assert tm['status']=='ready'
(A/'confirmed-dot-result.json').write_text(json.dumps({'id':tid,'status':tm['status'],'author_confirmation':True,'source_signedoff_version':lm['signedoff_version'],'candidate_closure':'c474e19d0f9c45a8202e9b710fd0cd04f5566b0ddee2cdc18d595f5c5b15a5a4','software_scope':'dot / reticle / multi-matrix only','full_library_task_continues':True},ensure_ascii=False,indent=2),encoding='utf-8')
print('Confirmed dot is ready. Full SCP task continues.')
