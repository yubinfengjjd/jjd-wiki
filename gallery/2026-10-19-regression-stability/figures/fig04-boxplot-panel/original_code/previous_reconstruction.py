"""Reconstruct the selected source figure from archived graphical estimates.
No training, no original observations, no inference from the displayed metrics.
Run from any directory with the dedicated sci-figure-replica Python.
"""
from pathlib import Path
import json
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import Normalize
from matplotlib.cm import ScalarMappable
from matplotlib import font_manager
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SPEC = json.loads((ROOT/'data/figure_spec.json').read_text(encoding='utf-8'))
plt.rcParams.update({'font.family':'Arial','font.size':7,'axes.linewidth':.65,
                     'pdf.fonttype':42,'ps.fonttype':42,'svg.fonttype':'none',
                     'xtick.major.width':.6,'ytick.major.width':.6})
W,H=SPEC['canvas_px']
fig=plt.figure(figsize=(12,12*H/W),facecolor='white')

def axes_px(box):
    x0,y0,x1,y1=box
    return fig.add_axes([x0/W,1-y1/H,(x1-x0)/W,(y1-y0)/H])

if SPEC['kind']=='density':
    points=pd.read_csv(ROOT/'data/estimated_data.csv')
    hist=pd.read_csv(ROOT/'data/estimated_histograms.csv')
    for p in SPEC['panels']:
        ax=axes_px(p['bbox']); lim=p['limits'];ax.set(xlim=lim[:2],ylim=lim[2:])
        ax.set_facecolor('#f4f7f9');ax.grid(color='#d3dbe1',linestyle=':',linewidth=.65,zorder=0)
        sub=points.loc[points.panel==p['id']]
        rgb=sub[['red','green','blue']].to_numpy()/255
        ax.scatter(sub.x,sub.y,c=rgb,s=2.1,marker='s',linewidths=0,zorder=3)
        line=np.array(lim[:2]);ax.plot(line,line,'--',color='#666666',lw=.75,zorder=2)
        ax.plot(line,p['slope']*line+p['intercept'],color='#008798',lw=1.0,zorder=4)
        ticks=[0,25,50,75,100] if p['id']=='F' else list(range(0,101,20))
        ax.set_xticks(ticks);ax.set_yticks(ticks);ax.tick_params(labelsize=6,pad=2,length=2.3)
        ax.set_xlabel('Observed (SR)',fontsize=6.7,labelpad=1)
        ax.set_ylabel('Predicted (SR)',fontsize=6.7,labelpad=2)
        ann=(f'$y={p["slope"]:.2f}x+{p["intercept"]:.2f}$\n'
             f'$R^2={float(p["R2"]):.2f}\\pm{float(p["R2_sd"]):.2f}$\n'
             f'$RMSE={p["RMSE"]}\\pm{p["RMSE_sd"]}$\n'
             f'$MAE={p["MAE"]}\\pm{p["MAE_sd"]}$\n'
             f'$r={float(p["r"]):.2f}\\pm{float(p["r_sd"]):.2f}$\n'
             '$n_{\\mathrm{split}}=10$')
        ax.text(.04,.96,ann,transform=ax.transAxes,ha='left',va='top',fontsize=6.7,color='#666666',linespacing=1.05)
        ax.text(.55,.10,'Test ('+p['name']+')',transform=ax.transAxes,fontsize=6.2,weight='bold',color='#666666',ha='center')
        cbax=axes_px(p['colorbar_bbox'])
        cb=fig.colorbar(ScalarMappable(norm=Normalize(0,3.1),cmap='RdYlGn_r'),cax=cbax)
        cb.set_ticks([0,1,2,3]);cb.set_ticklabels(['0','1','2','>3']);cb.ax.tick_params(labelsize=4.8,length=1.5,pad=1)
        cb.set_label('Frequency',fontsize=5.4,labelpad=2);cb.outline.set_linewidth(.45)
        for orient,bbox in [('top',p['top_bbox']),('right',p['right_bbox'])]:
            ha=axes_px(bbox);hs=hist.loc[(hist.panel==p['id'])&(hist.orientation==orient)]
            if orient=='top':
                ha.bar(hs.position,hs.height,width=hs.width,color='#b2d3d5',linewidth=0)
                ha.set(xlim=lim[:2],ylim=(0,40));ha.set_yticks([0,20,40]);ha.set_ylabel('Count',fontsize=4.8,labelpad=1)
                ha.set_xticks([]);ha.spines[['top','right','bottom']].set_visible(False)
            else:
                ha.barh(hs.position,hs.height,height=hs.width,color='#b2d3d5',linewidth=0)
                ha.set(ylim=lim[2:],xlim=(0,40));ha.set_xticks([0,20,40]);ha.set_xlabel('Count',fontsize=4.8,labelpad=1)
                ha.set_yticks([]);ha.spines[['top','right','left']].set_visible(False)
            ha.tick_params(labelsize=4.6,length=1.5,pad=1,colors='#888888');ha.spines[['bottom','left']].set_color('#999999')
else:
    points=pd.read_csv(ROOT/'data/estimated_data.csv')
    palette=['#60a39f','#a8a8a8','#efb342','#69b5d5','#cb88b2','#a5a5a5']
    for p in SPEC['panels']:
        ax=axes_px(p['bbox']);ax.set_axisbelow(True)
        ax.axvspan(-.45,.45,color='#eff8f9',zorder=0)
        ax.grid(axis='y',linestyle=(0,(2,2)),color='#d9dfe3',lw=.55)
        stats=[]
        for i,model in enumerate(p['order']):
            s=p['stats'][model];stats.append(dict(label=model,med=s['med'],q1=s['q1'],q3=s['q3'],whislo=s['lo'],whishi=s['hi'],fliers=[]))
        artists=ax.bxp(stats,positions=np.arange(6),widths=.52,patch_artist=True,showfliers=False,
                       boxprops={'edgecolor':'#888888','linewidth':.8},medianprops={'color':'#2f2f2f','linewidth':1.1},
                       whiskerprops={'color':'#555555','linewidth':.8},capprops={'color':'#555555','linewidth':.8})
        for i,box in enumerate(artists['boxes']):box.set(facecolor=palette[i],alpha=.85)
        for i,model in enumerate(p['order']):
            sub=points[(points.metric==p['metric'])&(points.model==model)]
            ax.scatter(i+sub.jitter,sub.value,s=22,c=palette[i],alpha=.95,edgecolor='white',linewidth=.4,zorder=3)
            ax.scatter(i,p['stats'][model]['mean'],marker='D',s=65,c='white',edgecolor='#303030',linewidth=1.2,zorder=4)
        ax.set(xlim=(-.5,5.5),ylim=p['limits'],yticks=p['ticks'])
        ax.set_title(p['title'],fontsize=12,pad=5)
        ax.set_ylabel(p['ylabel'],fontsize=9.5,labelpad=3)
        ax.set_xticks(range(6),p['order'],rotation=45,ha='right',rotation_mode='anchor')
        ax.tick_params(labelsize=8.0,length=3,pad=2)
        ax.spines[['top','right']].set_visible(False);ax.spines[['bottom','left']].set_linewidth(.9)

output=ROOT/'output';output.mkdir(exist_ok=True)
for ext in ['png','pdf','svg']:
    fig.savefig(output/f'replica.{ext}',dpi=600,facecolor='white')
plt.close(fig)
with Image.open(output/'replica.png') as im:
    im.thumbnail((480,480));im.convert('RGB').save(ROOT/'thumb.png')
print(json.dumps({'figure':SPEC['kind'],'canvas_px_at_600dpi':[round(12*600),round(12*H/W*600)],
                  'font_file':font_manager.findfont('Arial'),'data_provenance':SPEC['data_provenance'],
                  'warning':'Graphical estimates only. Printed source annotations are not recomputed model results.'}))
