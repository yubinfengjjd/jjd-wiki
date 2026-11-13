"""Two selected single panels. Preserve source bytes; adapt rendering only."""
from pathlib import Path
import ast
import copy
import difflib
import hashlib
import json
import shutil
import subprocess
import yaml

TASK=Path(__file__).resolve().parent
WIKI=Path(r'E:\research-wiki\知识库')
GALLERY=Path(r'E:\research-wiki\画廊\2026-10-19-regression-stability\figures')
CLI=Path(r'C:\Users\86186\.agents\skills\research-wiki\wiki.py')
PYTHON=r'C:\Users\86186\.codex\venvs\research-wiki\Scripts\python.exe'
PREFIX='2026-10-19-regression-stability__'

def run(*args):
    result=subprocess.run([PYTHON,'-X','utf8',str(CLI),*map(str,args)],capture_output=True,encoding='utf-8')
    if result.returncode:raise RuntimeError(result.stdout+result.stderr)
    return result.stdout

def read_page(path):
    text=path.read_bytes().decode('utf-8'); header,body=text[4:].split('\n---\n',1)
    return yaml.safe_load(header),body

def block(body,name):return body.split(f'<!-- {name}:start -->',1)[1].split(f'<!-- {name}:end -->',1)[0]
def write_note(path,meta,body):
    oldmeta,oldbody=read_page(path)
    assert oldmeta.get('status')==meta.get('status')
    assert block(oldbody,'user')==block(body,'user')
    path.write_text('---\n'+yaml.safe_dump(meta,sort_keys=False,allow_unicode=True)+'---\n'+body,encoding='utf-8',newline='\n')

interfaces={
 'render-scatter-rgb':('配对数值散点的预设颜色表',{'x':('float','横轴数值；量纲由课题说明'),'y':('float','配对纵轴数值；1:1线仅在同量纲时使用'),
     'red':('int','预先给定的红通道0..255'),'green':('int','预先给定的绿通道0..255'),'blue':('int','预先给定的蓝通道0..255')}),
 'render-marginal-bars':('预计算边缘分布条表',{'orientation':('str','top或right，分别对应横轴或纵轴边缘'),
     'position':('float','条形中心坐标，单位与对应轴一致'),'height':('float','预先计算的非负条高，计数/密度含义由上游声明'),
     'width':('float','预先计算的正条宽，单位与对应轴一致')}),
 'render-category-points':('分组数值与显式抖动表',{'category':('str','类别标识；与摘要表一一对应'),
     'value':('float','逐条结果值；采样单位/量纲由课题说明'),'jitter':('float','显式横向展示偏移，绝对值须小于0.5；不参与统计')}),
 'render-box-summaries':('预计算分组箱线与均值表',{'category':('str','每类恰好一行；不能缺组'),
     'q1':('float','上游给定第一四分位数'),'median':('float','上游给定中位数'),'q3':('float','上游给定第三四分位数'),
     'low':('float','上游给定下须；规则由分析说明'),'high':('float','上游给定上须；规则由分析说明'),
     'mean':('float','上游给定均值；须与真实点使用同一数据来源')})}
for slug,(title,columns) in interfaces.items():
    path=TASK/(slug+'-columns.json')
    path.write_text(json.dumps({key:{'type':value[0],'description':value[1]} for key,value in columns.items()},ensure_ascii=False),encoding='utf-8')
    if not (WIKI/'interfaces'/f'{slug}.md').exists():run('add-interface',slug,'--title',title,'--columns',path)
    page=WIKI/'interfaces'/f'{slug}.md';meta,body=read_page(page)
    info='这是绘图层的已准备表，不是训练数据或通用科学方法接口。不得从估读 RGB/箱体倒推真实频数、分位数或样本量。课题保留原始身份、配对、重复/折与量纲说明；绘图不重算分析。'
    if '## 含义' in body:
        start=body.index('## 含义');end=body.index('<!-- user:start -->',start)
        body=body[:start]+'## 含义\n\n'+info+'\n\n'+body[end:]
    write_note(page,meta,body)

def replace_once(text,old,new):
    assert text.count(old)==1,old[:90]
    return text.replace(old,new,1)

for fig,chart,kind in [('fig03-density-panel','density-scatter','density'),('fig04-boxplot-panel','boxplot','boxplot')]:
    source=GALLERY/fig
    tid=PREFIX+fig+'--'+chart
    target=WIKI/'templates'/tid
    source_code=(source/'code/panels.py').read_text(encoding='utf-8')
    tree=ast.parse(source_code)
    keep={'_axes','_require','draw_density' if kind=='density' else 'draw_boxplot'}
    selected=[]
    for node in tree.body:
        if isinstance(node,(ast.Import,ast.ImportFrom)) or isinstance(node,ast.FunctionDef) and node.name in keep:
            selected.append(ast.get_source_segment(source_code,node))
    core='"""Rendering-only derivative of the preserved source/panels.py. No analysis or file I/O."""\n'+'\n\n'.join(selected)+'\n'
    if kind=='boxplot':
        core=replace_once(core,"order = list(s.get('order', summary[col['category']].tolist()))","order = list(s.get('order') or summary[col['category']].tolist())")
        core=replace_once(core,"    if summary[col['category']].duplicated().any():","    if pts[col['category']].isna().any() or summary[col['category']].isna().any():\n        raise ValueError('Category must not be missing')\n    if summary[col['category']].duplicated().any():")
        core=replace_once(core,"    ax = _axes(fig,rect,s.get('bbox',[134,63,856,638]),s.get('canvas_px',[872,777]))", "    if np.abs(vals[:,1]).max() >= .5:\n        raise ValueError('Jitter must stay within its category: abs(jitter) < 0.5')\n    ax = (_axes(fig,rect,s.get('bbox',[134,63,856,638]),s.get('canvas_px',[872,777]))\n          if s['sizing']['mode'] in ('fixed','replica') else fig.add_axes(rect))")
        core=replace_once(core,"    palette = s.get('palette',['#60a39f','#a8a8a8','#efb342','#69b5d5','#cb88b2','#a5a5a5'])", "    palette = s.get('palette')\n    if palette is None:\n        defaults = ['#60a39f','#a8a8a8','#efb342','#69b5d5','#cb88b2','#a5a5a5']\n        if len(order) <= len(defaults):\n            palette = defaults[:len(order)]\n        else:\n            from colorsys import hls_to_rgb\n            palette = [hls_to_rgb(i/len(order), .58, .48) for i in range(len(order))]\n    if isinstance(palette,str) or len(palette) < len(order):\n        raise ValueError('Provide at least one explicit color per category; colors are never cycled')")
        core=replace_once(core,"color = palette[i % len(palette)]","color = palette[i]")
        core=replace_once(core,"if 'limits' in s:","if s.get('limits') is not None:")
        core=replace_once(core,"if 'ticks' in s:","if s.get('ticks') is not None:")
        core=core.replace("fontsize=20,pad=10", "fontsize=s['title_size'],pad=10").replace("fontsize=17,labelpad=10","fontsize=s['label_size'],labelpad=10")
        core=core.replace("rotation=s.get('rotation',45)","rotation=s['sizing']['label_rotation']")
        core=core.replace("labelsize=14,length=5,pad=5","labelsize=s['sizing']['label_fontsize'],length=5,pad=5")
        tables={'points':{'interface':'render-category-points','description':'每条数值和显式抖动，不在绘图内生成'},
                'summaries':{'interface':'render-box-summaries','description':'独立提供的预计算摘要；真实数据必须与点同源'}}
        files={'points':'render-category-points.csv','summaries':'render-box-summaries.csv'}
    else:
        core=replace_once(core,"    handles = {k:_axes(fig,rect,v,canvas) for k,v in boxes.items()}","    if not s.get('show_colorbar',False):\n        boxes = {k:v for k,v in boxes.items() if k != 'colorbar'}\n    handles = {k:_axes(fig,rect,v,canvas) for k,v in boxes.items()}")
        core=replace_once(core,"    lim = s.get('limits', [-5,109,-5,109])", "    lim = s.get('limits')\n    if lim is None:\n        lo,hi = xy.min(axis=0),xy.max(axis=0)\n        pad = np.where(hi>lo, (hi-lo)*.05, 1.0)\n        lim = [lo[0]-pad[0],hi[0]+pad[0],lo[1]-pad[1],hi[1]+pad[1]]\n    if len(lim)!=4 or not np.isfinite(lim).all() or lim[0]>=lim[1] or lim[2]>=lim[3]:\n        raise ValueError('Explicit limits must be increasing finite x/y pairs')")
        core=core.replace("ax.set_xticks(s.get('xticks',list(range(0,101,20))))", "if s.get('xticks') is not None: ax.set_xticks(s['xticks'])")
        core=core.replace("ax.set_yticks(s.get('yticks',list(range(0,101,20))))", "if s.get('yticks') is not None: ax.set_yticks(s['yticks'])")
        start=core.index("    cb = fig.colorbar("); end=core.index("    for orient in ['top','right']:",start)
        cb=core[start:end]
        core=core[:start]+"    if s.get('show_colorbar',False):\n        if s.get('color_range') is None or not s.get('color_label'):\n            raise ValueError('Colorbar requires an explicit range and meaning; do not infer density from RGB')\n        cr = s['color_range']\n        if len(cr)!=2 or not np.isfinite(cr).all() or cr[0]>=cr[1]:\n            raise ValueError('Colorbar range must be an increasing finite pair')\n"+''.join('    '+line+'\n' for line in cb.rstrip().splitlines())+core[end:]
        core=replace_once(core,"    canvas = s.get('canvas_px', [1043, 927])", "    if not set(hist[col['orientation']]) <= {'top','right'}:\n        raise ValueError('Marginal orientation must be top or right')\n    canvas = s.get('canvas_px', [1043, 927])")
        core=core.replace("ha.set(xlim=lim[:2],ylim=s.get('top_limits',[0,40]),xticks=[],yticks=s.get('top_ticks',[0,20,40]))", "ha.set(xlim=lim[:2],xticks=[])\n            if s.get('top_limits') is not None: ha.set_ylim(s['top_limits'])\n            if s.get('top_ticks') is not None: ha.set_yticks(s['top_ticks'])")
        core=core.replace("ha.set(ylim=lim[2:],xlim=s.get('right_limits',[0,40]),yticks=[],xticks=s.get('right_ticks',[0,20,40]))", "ha.set(ylim=lim[2:],yticks=[])\n            if s.get('right_limits') is not None: ha.set_xlim(s['right_limits'])\n            if s.get('right_ticks') is not None: ha.set_xticks(s['right_ticks'])")
        tables={'points':{'interface':'render-scatter-rgb','description':'配对坐标与预设RGB；不从颜色反推密度'},
                'histograms':{'interface':'render-marginal-bars','description':'由上游提供的边缘条；不从估读散点重算'}}
        files={'points':'render-scatter-rgb.csv','histograms':'render-marginal-bars.csv'}
    ast.parse(core)
    (target/'source').mkdir(exist_ok=True)
    shutil.copy2(source/'code/panels.py',target/'source/panels.py')
    (target/'code/core.py').write_text(core,encoding='utf-8',newline='\n')
    (TASK/(kind+'-core.diff')).write_text(''.join(difflib.unified_diff(source_code.splitlines(True),core.splitlines(True),fromfile='source/panels.py',tofile='code/core.py')),encoding='utf-8')
    spec=json.loads((target/'spec.json').read_text(encoding='utf-8'))
    sizing=spec['style']['sizing'];sizing.update(profile='categorical_x' if kind=='boxplot' else 'fixed',table='points' if kind=='boxplot' else None,x='category' if kind=='boxplot' else None)
    if kind=='density':sizing.update(width_in=7,height_in=7*927/1043,margins_in=[0,0,0,0])
    style={'font_family':'Arial','dpi':300,'sizing':sizing,'columns':{},'limits':None}
    if kind=='boxplot':
        style.update(order=None,palette=None,ticks=None,tick_format=None,title='',ylabel='Value',
                     title_size=16,label_size=13,highlight_first=False,point_size=45,mean_size=150,box_width=.52)
    else:
        style.update(canvas_px=[1043,927],boxes={'main':[108,170,853,846],'top':[108,14,853,156],'right':[868,170,1026,846],'colorbar':[707,515,743,799]},
                     identity=True,fit=None,annotation=None,label=None,xlabel='Observed',ylabel='Predicted',
                     xticks=None,yticks=None,show_colorbar=False,color_range=None,color_label=None,cmap='RdYlGn_r',
                     color_ticks=[0,1,2,3],color_ticklabels=['0','1','2','>3'],top_limits=None,right_limits=None,
                     top_ticks=None,right_ticks=None,count_label='Supplied marginal',hist_color='#b2d3d5',
                     background='#f4f7f9',point_size=12,fit_color='#008798')
    spec.update(tables=tables,style=style)
    (target/'spec.json').write_text(json.dumps(spec,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    (target/'code/defaults.py').write_text('"""Template-local defaults; no filesystem dependency."""\nDEFAULT_STYLE = '+repr(style)+'\n',encoding='utf-8')
    fn='draw_boxplot' if kind=='boxplot' else 'draw_density'
    panel='''"""Single-panel callable; all inputs/visual settings explicit, no implicit I/O."""
from copy import deepcopy
from .defaults import DEFAULT_STYLE
from .sizing import check_region, draw_figure
from .core import DRAW_FUNCTION

def resolved_style(style=None):
    result=deepcopy(DEFAULT_STYLE)
    for key,value in (style or {}).items():
        if key not in result:
            raise ValueError('Unknown visual setting: '+key)
        result[key] = result[key] | value if key in ('sizing','columns') and isinstance(value,dict) else deepcopy(value)
    return result

def draw(fig, rect, tables, style):
    s=resolved_style(style)
    check_region(fig,rect,tables,s)
    return DRAW_FUNCTION(fig,rect,tables,s)

def plot_panel(tables, style=None):
    """Return (figure, handles, sizing_plan). Caller exports; tables stay unchanged."""
    s=resolved_style(style)
    return draw_figure(draw,tables,s)
'''.replace('DRAW_FUNCTION',fn)
    (target/'code/panel.py').write_text(panel,encoding='utf-8',newline='\n')
    for key,file in files.items():
        raw=(source/'data'/f'{key}.csv').read_text(encoding='utf-8')
        if kind=='boxplot':
            lines=raw.splitlines(True); headers=lines[0].strip().split(',')
            headers=['category' if x=='model' else x for x in headers];lines[0]=','.join(headers)+'\n';raw=''.join(lines)
        (target/'example'/file).write_text(raw,encoding='utf-8',newline='\n')
    # Keep old copied CSVs out of the executable input directory, without deleting evidence.
    keep=set(files.values())|{'style.json'}
    legacy=target/'source/copied-example';legacy.mkdir(exist_ok=True)
    for p in (target/'example').glob('*.csv'):
        if p.name not in keep:shutil.move(str(p),str(legacy/p.name))
    example=json.loads((source/'data/figure_spec.json').read_text(encoding='utf-8'))['style']
    example.update(dpi=300,sizing={'mode':'replica','profile':'fixed','width_in':7,
                                 'height_in':7*(777/872 if kind=='boxplot' else 927/1043),
                                 'margins_in':[0,0,0,0],'label_fontsize':14,'label_rotation':45})
    if kind=='density':
        example.update(show_colorbar=True,color_range=[0,3.1],color_label='Frequency',count_label='Count',
                       xlabel='Observed (SR)',ylabel='Predicted (SR)',xticks=list(range(0,101,20)),yticks=list(range(0,101,20)),
                       top_limits=[0,40],top_ticks=[0,20,40])
    else:
        example.update(columns={},title_size=20,label_size=17,highlight_first=True)
    (target/'example/style.json').write_text(json.dumps(example,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    manifest=[]
    for p in [target/'source/panels.py',*sorted((target/'code').glob('*.py'))]:
        manifest.append({'variant':'original' if p.parent.name=='source' else 'reusable',
                         'path':p.relative_to(target).as_posix(),
                         'source':'保留的旧重建绘图源码，非原作者完整函数。' if p.parent.name=='source' else '基于旧重建代码参数化的单 panel；不含分析算法。',
                         'verification':{'state':'not_run','scope':'本轮待回放与可移植性检查','evidence':[]}})
    (target/'code-manifest.json').write_text(json.dumps({'files':manifest},ensure_ascii=False,indent=2),encoding='utf-8')
    source_hash=hashlib.sha256((source/'code/panels.py').read_bytes()).hexdigest()
    (target/'source/provenance.json').write_text(json.dumps({'path':str(source/'code/panels.py'),'sha256':source_hash,
        'code_provenance':'reconstructed','data':'graphically estimated; synthetic horizontal jitter in boxplot',
        'changes':'format/size/style/palette validation only; no new fitting/statistics'},ensure_ascii=False,indent=2),encoding='utf-8')
print('Prepared two draw-only templates, four explicit render interfaces, preserved source, and separate replica style.')
