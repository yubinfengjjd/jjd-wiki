"""Functional acceptance, with isolated replay of the actual old renderer."""
from pathlib import Path
import json, hashlib, shutil, runpy, importlib.util, os, sys
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

WORK=Path(__file__).resolve().parent
ROOT=Path('E:/research-wiki/画廊/2026-10-19-regression-stability/figures')
results=[]
def passed(name): results.append({'check':name,'status':'PASS'})
def eq(a,b): np.testing.assert_allclose(np.asarray(a,float),np.asarray(b,float),rtol=0,atol=1e-12)
for kind,old,new in [('density','fig01-density-grid','fig03-density-panel'),('boxplot','fig02-metric-boxplots','fig04-boxplot-panel')]:
    entry=ROOT/new
    reference=WORK/'reference-replay'/kind
    (reference/'code').mkdir(parents=True,exist_ok=True)
    shutil.copytree(ROOT/old/'data',reference/'data',dirs_exist_ok=True)
    shutil.copy2(ROOT/old/'code/replica.py',reference/'code/replica.py')
    # Run unchanged source in isolation: original entry and outputs untouched.
    namespace=runpy.run_path(str(reference/'code/replica.py'))
    oldfig=namespace['fig'];oldax=oldfig.axes[0]
    pkg=WORK/'copied-project'/f'{kind}_panel'
    shutil.copytree(entry/'code',pkg,dirs_exist_ok=True)
    sys.path.insert(0,str(pkg.parent))
    adapter=__import__(f'{kind}_panel.panel',fromlist=['draw'])
    core=__import__(f'{kind}_panel.panels',fromlist=['plot_panel'])
    style=json.loads((entry/'data/figure_spec.json').read_text(encoding='utf-8'))['style']
    key='histograms' if kind=='density' else 'summaries'
    tables={k:pd.read_csv(entry/f'data/{k}.csv') for k in ['points',key]}
    before={k:v.copy(deep=True) for k,v in tables.items()}
    os.chdir(WORK)  # Neither source gallery nor copied package as current directory.
    fig,h=core.plot_panel(kind,tables,style)
    if kind=='density':
        eq(oldax.collections[0].get_offsets(),h['points'].get_offsets())
        eq(oldax.collections[0].get_facecolors(),h['points'].get_facecolors())
        eq(oldax.lines[1].get_xydata(),h['fit'].get_xydata())
        # old figure axes are main, colorbar, top, right.
        for oldha,name in [(oldfig.axes[2],'top'),(oldfig.axes[3],'right')]:
            eq([[p.get_x(),p.get_y(),p.get_width(),p.get_height()] for p in oldha.patches],
               [[p.get_x(),p.get_y(),p.get_width(),p.get_height()] for p in h[name].patches])
        assert len(fig.axes)==4
    else:
        for i in range(6):
            eq(oldax.collections[i*2].get_offsets(),h['points'][i].get_offsets())
            eq(oldax.collections[i*2+1].get_offsets(),h['means'][i].get_offsets())
            eq(oldax.patches[i+1].get_path().vertices,h['boxes']['boxes'][i].get_path().vertices)
        assert len(fig.axes)==1
    passed(kind+': actual old renderer vs functions, coordinates/RGB/fit/histograms or dots/jitter/means/boxes equivalent within 1e-12')
    for k,v in before.items(): pd.testing.assert_frame_equal(v,tables[k])
    passed(kind+': no input mutation; copied package works from unrelated cwd')
    composition=plt.figure(figsize=(10,8))
    hd=adapter.draw(composition,[.1,.1,.8,.8],tables,style)
    if kind=='density': eq(h['points'].get_offsets(),hd['points'].get_offsets())
    else:
        for a,b in zip(h['points'],hd['points']):eq(a.get_offsets(),b.get_offsets())
    # Explicit renamed columns across all tables, compared against same draw.
    rename={c:'custom_'+c for table in tables.values() for c in table.columns}
    renamed={k:v.rename(columns=rename) for k,v in tables.items()}
    keys=['x','y','red','green','blue','orientation','position','height','width'] if kind=='density' else ['category','value','jitter','q1','median','q3','low','high','mean']
    custom=dict(style,columns={k:rename[style.get('columns',{}).get(k,k)] for k in keys})
    fr,hr=core.plot_panel(kind,renamed,custom)
    if kind=='density':eq(h['points'].get_offsets(),hr['points'].get_offsets())
    else:
        for a,b in zip(h['points'],hr['points']):eq(a.get_offsets(),b.get_offsets())
    passed(kind+': renamed columns and draw adapter preserve graphical values')
    # A genuinely different input size/range, purely an API test, never results.
    if kind=='density':
        changed={k:v.copy() for k,v in tables.items()}
        changed['points']=changed['points'].iloc[:17].copy()
        changed['points']['y']=changed['points']['y']*.5
        fs,hs=core.plot_panel(kind,changed,dict(style,annotation='',fit=None,label='API test only'))
        assert len(hs['points'].get_offsets())==17
        eq(hs['points'].get_offsets()[:,1],changed['points']['y'])
    else:
        names=['New B','New A']; changed={k:v.loc[v.model.isin(['ET','RF'])].copy() for k,v in tables.items()}
        for v in changed.values():v['model']=v['model'].replace({'ET':'New A','RF':'New B'})
        changed['points']['value']*=2
        for c in ['q1','median','q3','low','high','mean']:changed['summaries'][c]*=2
        fs,hs=core.plot_panel(kind,changed,dict(style,order=names,limits=[10,28],title='API test only',ylabel='New unit'))
        assert len(hs['points'])==2
        eq(hs['points'][0].get_offsets()[:,1],changed['points'].loc[changed['points'].model=='New B','value'])
    fs.savefig(WORK/f'{kind}-different-data-test.png',dpi=120)
    passed(kind+': different data size/categories/range accepted, output inspected by numeric artists')
    bad={k:v.copy() for k,v in tables.items()}
    bad['points']=bad['points'].drop(columns=['x' if kind=='density' else 'jitter'])
    try:core.plot_panel(kind,bad,style)
    except ValueError:pass
    else:raise AssertionError('Missing required column silently accepted')
    bad={k:v.copy() for k,v in tables.items()}
    bad['points'].iloc[0,bad['points'].columns.get_loc('x' if kind=='density' else 'value')]=np.nan
    try:core.plot_panel(kind,bad,style)
    except ValueError:pass
    else:raise AssertionError('Non-finite data silently accepted')
    passed(kind+': missing columns and nonfinite values rejected explicitly')
    plt.close('all')

baseline=json.loads((WORK/'old-entry-baseline.json').read_text(encoding='utf-8'))
for p,digest in baseline.items():assert hashlib.sha256(Path(p).read_bytes()).hexdigest()==digest,p
passed('Old two entries unchanged byte-for-byte (all baseline files)')
report={'checks':results,'summary':{'passed':len(results),'failed':0},
        'scope':'Graphical equivalence and portable Python API only. No original-data, model, OOF, statistical or clinical validation. Actual wiki render pending author signoff; draw adapter tested directly.',
        'deliberate_visual_changes':'Single-panel canvas and larger fonts/marks; density y max109 vs old group110; right count axis old0..40 retained vs standalone source0..20; data values unchanged.'}
(WORK/'verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
for name in ['fig03-density-panel','fig04-boxplot-panel']:
    shutil.copy2(WORK/'verification.json',ROOT/name/'compare/function-verification.json')
    shutil.copy2(__file__,ROOT/name/'compare/verification-script.py')
print(json.dumps(report,ensure_ascii=False,indent=2))
