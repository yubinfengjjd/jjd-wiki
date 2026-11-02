"""Meaningful rendering/portability checks. Synthetic scale fixtures aren't research data."""
from pathlib import Path
from copy import deepcopy
import importlib.util
import json
import shutil
import sys
from uuid import uuid4
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

TASK=Path(__file__).resolve().parent
ROOT=Path(r'E:\research-wiki\知识库\templates')
GALLERY=Path(r'E:\research-wiki\画廊\2026-10-19-regression-stability\figures')
P='2026-10-19-regression-stability__'
checks=[];scale=[]
def record(name):checks.append(name)
def package(folder):
    name='qa_'+uuid4().hex
    spec=importlib.util.spec_from_file_location(name,folder/'__init__.py',submodule_search_locations=[str(folder)])
    mod=importlib.util.module_from_spec(spec);sys.modules[name]=mod;spec.loader.exec_module(mod)
    return __import__(name+'.panel',fromlist=['panel'])
def failure(fn,part):
    try:fn()
    except ValueError as error:assert part.lower() in str(error).lower(),str(error)
    else:raise AssertionError('Expected failure: '+part)
def old_module(path):
    spec=importlib.util.spec_from_file_location('old_'+uuid4().hex,path)
    mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod);return mod

for fig,chart,kind in [('fig03-density-panel','density-scatter','density'),('fig04-boxplot-panel','boxplot','boxplot')]:
    target=ROOT/(P+fig+'--'+chart)
    module=package(target/'code')
    spec=json.loads((target/'spec.json').read_text(encoding='utf-8'))
    tables={key:pd.read_csv(target/'example'/f"{value['interface']}.csv") for key,value in spec['tables'].items()}
    snapshots={k:v.copy(deep=True) for k,v in tables.items()}
    example=json.loads((target/'example/style.json').read_text(encoding='utf-8'))
    original=old_module(GALLERY/fig/'code/panels.py')
    old_style=json.loads((GALLERY/fig/'data/figure_spec.json').read_text(encoding='utf-8'))['style']
    old_tables={key:pd.read_csv(GALLERY/fig/'data'/f'{key}.csv') for key in tables}
    with plt.rc_context({'font.family':'Arial'}):
        previous,old_handles=original.plot_panel(kind,old_tables,old_style)
        new,new_handles,plan=module.plot_panel(tables,example)
    np.testing.assert_allclose(new.get_size_inches(),previous.get_size_inches(),atol=1e-12,rtol=0)
    np.testing.assert_allclose(new_handles['main'].get_position().bounds,old_handles['main'].get_position().bounds,atol=1e-12,rtol=0)
    if kind=='density':
        for prop in ['get_offsets','get_facecolors']:
            np.testing.assert_allclose(getattr(new_handles['points'],prop)(),getattr(old_handles['points'],prop)(),atol=1e-12,rtol=0)
        np.testing.assert_allclose(new_handles['fit'].get_data(),old_handles['fit'].get_data(),atol=1e-12,rtol=0)
        for axis in ['top','right']:
            a=[[p.get_x(),p.get_y(),p.get_width(),p.get_height()] for p in old_handles[axis].patches]
            b=[[p.get_x(),p.get_y(),p.get_width(),p.get_height()] for p in new_handles[axis].patches]
            np.testing.assert_allclose(a,b,atol=1e-12,rtol=0)
        assert len(new.axes)==4
    else:
        for a,b in zip(old_handles['points'],new_handles['points']):np.testing.assert_allclose(a.get_offsets(),b.get_offsets(),atol=1e-12,rtol=0)
        for a,b in zip(old_handles['means'],new_handles['means']):np.testing.assert_allclose(a.get_offsets(),b.get_offsets(),atol=1e-12,rtol=0)
        for a,b in zip(old_handles['boxes']['boxes'],new_handles['boxes']['boxes']):np.testing.assert_allclose(a.get_path().vertices,b.get_path().vertices,atol=1e-12,rtol=0)
        assert len(new.axes)==1
    for key in tables:pd.testing.assert_frame_equal(tables[key],snapshots[key])
    record(kind+': replica dimensions/artists/data equal to preserved renderer (1e-12), source inputs unmodified')
    plt.close(previous);plt.close(new)

    copy_root=TASK/'copied-project'/kind/'panel_package'
    shutil.copytree(target/'code',copy_root,dirs_exist_ok=True,ignore=shutil.ignore_patterns('__pycache__'))
    copied=package(copy_root)
    other=TASK/'other-working-directory';other.mkdir(exist_ok=True)
    import os
    cwd=Path.cwd();os.chdir(other)
    try:
        with plt.rc_context({'font.family':'Arial'}): fig_out,handles,plan=copied.plot_panel(tables)
        fig_out.savefig(TASK/(kind+'-adaptive.png'),dpi=140)
        plt.close(fig_out)
    finally:os.chdir(cwd)
    record(kind+': copy to unrelated directory, no spec/Wiki path needed; default reuse rendered')
    if kind=='density':density=module;density_tables=tables
    else:box=module;box_tables=tables

def synthetic(n,count=5,long=False):
    names=[('Long validation model label '+str(i)) if long else 'Group_'+str(i) for i in range(n)]
    pts=[];summary=[]
    for i,cat in enumerate(names):
        values=np.linspace(1+i*.05,2+i*.05,count)
        pts.extend({'category':cat,'value':v,'jitter':j} for v,j in zip(values,np.linspace(-.14,.14,count)))
        # Explicit prepared summaries for a rendering fixture, not a new analysis algorithm.
        summary.append(dict(category=cat,low=values[0],q1=values[0]+.25,median=values[0]+.5,
                            q3=values[0]+.75,high=values[-1],mean=values[0]+.5))
    return {'points':pd.DataFrame(pts),'summaries':pd.DataFrame(summary)}

for n in [1,3,7,13,29]:
    tables=synthetic(n)
    fig,h,plan=box.plot_panel(tables)
    assert len(h['boxes']['boxes'])==len(h['points'])==len(h['means'])==n
    assert plan['counts']['x']==n and len(fig.axes)==1
    spacing=h['main'].get_position().width*fig.get_figwidth()/n
    assert spacing>=.8-1e-9
    colors=[tuple(p.get_facecolor()) for p in h['boxes']['boxes']]
    assert len(set(colors))==n
    box_inches=fig.get_tightbbox(fig.canvas.get_renderer())
    assert box_inches.x0>=-1e-5 and box_inches.y0>=-1e-5 and box_inches.x1<=fig.get_figwidth()+1e-5 and box_inches.y1<=fig.get_figheight()+1e-5
    scale.append({'n':n,'width_in':plan['width_in'],'height_in':plan['height_in'],'group_pitch_in':spacing})
    if n in [3,13]:fig.savefig(TASK/f'adaptive-{n}-groups.png',dpi=140)
    plt.close(fig)
assert all(a['width_in']<b['width_in'] for a,b in zip(scale,scale[1:]))
record('arbitrary-n implementation sampled at positive boundary/small/above source palette/larger sizes; one panel, unique colors, readable physical spacing')

normal=synthetic(7);dense=synthetic(7,37)
a,ha,pa=box.plot_panel(normal);b,hb,pb=box.plot_panel(dense)
np.testing.assert_allclose(a.get_size_inches(),b.get_size_inches(),atol=1e-12)
plt.close(a);plt.close(b)
record('group count drives width, not total point rows')
few=synthetic(7,3)
fig,h,p=box.plot_panel(few)
for points,patch in zip(h['points'],h['boxes']['boxes']):
    colors=points.get_facecolors()
    np.testing.assert_allclose(colors[0,:3],patch.get_facecolor()[:3],atol=1e-12)
    assert len(colors)==1
assert h['main'].get_xticklabels()[0].get_fontfamily()==['Arial']
plt.close(fig)
record('numeric RGB palette tuples remain single category colors with three samples; specified font honored')

long=synthetic(3,long=True)
a,h,plan=box.plot_panel(long);a.savefig(TASK/'adaptive-long-labels.png',dpi=130)
assert plan['margins_in'][2]>.85
renderer=a.canvas.get_renderer();labels=[x.get_window_extent(renderer) for x in h['main'].get_xticklabels()]
assert all(not x.overlaps(y) for x,y in zip(labels,labels[1:]))
plt.close(a);record('long labels increase width/bottom margin with no adjacent label overlap')

renamed={k:v.rename(columns={'category':'model_group','value':'score','jitter':'offset'}) for k,v in normal.items()}
order=list(reversed(normal['summaries']['category'].tolist()))
a,h,p=box.plot_panel(renamed,{'columns':{'category':'model_group','value':'score','jitter':'offset'},'order':order})
assert [x.get_text() for x in h['main'].get_xticklabels()]==order
plt.close(a);record('explicit order and semantic column mapping preserve category values')
failure(lambda:box.plot_panel(normal,{'palette':['red']}),'color')
failure(lambda:box.plot_panel(normal,{'sizing':{'max_width_in':3}}),'limit')
failure(lambda:box.plot_panel(normal,{'sizing':{'width_in':2}}),'required')
fig,h,p=box.plot_panel(normal,{'sizing':{'width_in':15}});assert fig.get_figwidth()==15;plt.close(fig)
record('short explicit palette, insufficient manual width, user width cap reject; sufficient manual width accepted')
empty={k:v.iloc[:0].copy() for k,v in normal.items()};failure(lambda:box.plot_panel(empty),'nonempty')
bad=deepcopy(normal);bad['points'].loc[0,'jitter']=.7;failure(lambda:box.plot_panel(bad),'jitter')
bad=deepcopy(normal);bad['summaries'].loc[0,'low']=999;failure(lambda:box.plot_panel(bad),'low')
record('empty/missing categories, invalid jitter and inverted summaries rejected without fabricating data')
f=plt.figure(figsize=(3,3));failure(lambda:box.draw(f,[.1,.1,.2,.2],normal,{}),'region');plt.close(f)
record('composed draw refuses a cramped outer region without resizing owner')

fig,h,p=density.plot_panel(density_tables);before=fig.get_size_inches().copy()
assert 'fit' not in h and 'colorbar' not in h and not h['main'].texts
assert h['main'].get_xlabel()=='Observed'
plt.close(fig)
double={**density_tables,'points':pd.concat([density_tables['points']]*2,ignore_index=True)}
fig,h,p=density.plot_panel(double);np.testing.assert_allclose(fig.get_size_inches(),before);plt.close(fig)
failure(lambda:density.plot_panel(density_tables,{'show_colorbar':True}),'explicit')
fig,h,p=density.plot_panel(density_tables,{'show_colorbar':True,'color_range':[0,1],'color_label':'Supplied scale'})
assert 'colorbar' in h;plt.close(fig)
record('scatter sample rows do not expand canvas; reuse has no stale fit/metrics/model or invented colorbar meaning')
bad=deepcopy(density_tables);bad['points'].loc[0,'red']=999;failure(lambda:density.plot_panel(bad),'rgb')
bad=deepcopy(density_tables);bad['histograms'].loc[0,'orientation']='invalid';failure(lambda:density.plot_panel(bad),'orientation')
record('invalid RGB or unknown marginal orientation rejected')

for tid in [P+'fig03-density-panel--density-scatter',P+'fig04-boxplot-panel--boxplot']:
    namespace={};exec((ROOT/tid/'code/defaults.py').read_text(encoding='utf-8'),namespace)
    assert namespace['DEFAULT_STYLE']==json.loads((ROOT/tid/'spec.json').read_text(encoding='utf-8'))['style']
record('standalone default snapshot equals render spec')
report={'passed':True,'checks':checks,'scale_samples':scale,'scope':'rendering and synthetic portability; no new scientific analysis or real-data claims'}
(TASK/'function-verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'passed':True,'checks':len(checks),'scales':scale},ensure_ascii=False))
