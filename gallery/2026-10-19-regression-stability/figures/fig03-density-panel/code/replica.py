"""Explicit local example/export; portable functions live in panels.py."""
from pathlib import Path
import json
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import font_manager
import pandas as pd
from PIL import Image
from panels import plot_panel

ROOT=Path(__file__).resolve().parents[1]
spec=json.loads((ROOT/'data/figure_spec.json').read_text(encoding='utf-8'))
tables={'points':pd.read_csv(ROOT/'data/points.csv')}
key='histograms' if spec['kind']=='density' else 'summaries'
tables[key]=pd.read_csv(ROOT/f'data/{key}.csv')
with plt.rc_context({'font.family':'Arial','font.size':12,'mathtext.fontset':'dejavusans',
                     'axes.linewidth':1,'pdf.fonttype':42,'ps.fonttype':42,'svg.fonttype':'none'}):
    fig,handles=plot_panel(spec['kind'],tables,spec['style'])
    out=ROOT/'output';out.mkdir(exist_ok=True)
    for ext in ['png','pdf','svg']:
        fig.savefig(out/f'replica.{ext}',dpi=600,facecolor='white')
    plt.close(fig)
with Image.open(out/'replica.png') as im:
    preview=im.copy();preview.thumbnail((1100,1100));preview.save(out/'review-preview.png')
    im.thumbnail((480,480));im.save(ROOT/'thumb.png')
print(json.dumps({'kind':spec['kind'],'rows':{k:len(v) for k,v in tables.items()},
                  'logical_panels':1,'axes':4 if spec['kind']=='density' else 1,
                  'font':font_manager.findfont('Arial'),'provenance':spec['data_provenance']}))
