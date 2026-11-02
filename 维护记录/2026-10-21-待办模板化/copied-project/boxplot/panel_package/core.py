"""Rendering-only derivative of the preserved source/panels.py. No analysis or file I/O."""
import numpy as np

import matplotlib.pyplot as plt

from matplotlib.colors import Normalize

from matplotlib.cm import ScalarMappable

from matplotlib.ticker import FormatStrFormatter

def _axes(fig, rect, box, canvas):
    x, y, w, h = rect
    a, b, c, d = box
    W, H = canvas
    return fig.add_axes([x + w*a/W, y + h*(1-d/H), w*(c-a)/W, h*(d-b)/H])

def _require(table, names):
    missing = set(names) - set(table.columns)
    if missing:
        raise ValueError(f'Missing columns: {sorted(missing)}')
    if table.empty:
        raise ValueError('Input table must contain rows')

def draw_boxplot(fig, rect, tables, style):
    """Draw independently provided dots and summaries; return axes/artists.

    points(category,value,jitter), summaries(category,q1,median,q3,low,high,mean).
    Jitter is explicit input, not generated here. Summary values are never
    recomputed from dots; this supports reconstruction and external analysis.
    """
    s = dict(style)
    col = {k:k for k in ['category','value','jitter','q1','median','q3','low','high','mean']}
    col.update(s.get('columns', {}))
    pts, summary = tables['points'], tables['summaries']
    _require(pts, [col[k] for k in ['category','value','jitter']])
    _require(summary, [col[k] for k in ['category','q1','median','q3','low','high','mean']])
    if pts[col['category']].isna().any() or summary[col['category']].isna().any():
        raise ValueError('Category must not be missing')
    if summary[col['category']].duplicated().any():
        raise ValueError('One summary row per category required')
    order = list(s.get('order') or summary[col['category']].tolist())
    if not order or len(set(order)) != len(order) or set(pts[col['category']]) != set(order) or set(summary[col['category']]) != set(order):
        raise ValueError('Unique order must cover exactly point and summary categories')
    vals = pts[[col['value'],col['jitter']]].to_numpy(float)
    nums = summary[[col[k] for k in ['q1','median','q3','low','high','mean']]].to_numpy(float)
    if not np.isfinite(vals).all() or not np.isfinite(nums).all():
        raise ValueError('Finite dot and summary values required')
    if not ((nums[:,3] <= nums[:,0]) & (nums[:,0] <= nums[:,1]) & (nums[:,1] <= nums[:,2]) & (nums[:,2] <= nums[:,4])).all():
        raise ValueError('Require low <= q1 <= median <= q3 <= high')
    if np.abs(vals[:,1]).max() >= .5:
        raise ValueError('Jitter must stay within its category: abs(jitter) < 0.5')
    ax = (_axes(fig,rect,s.get('bbox',[134,63,856,638]),s.get('canvas_px',[872,777]))
          if s['sizing']['mode'] in ('fixed','replica') else fig.add_axes(rect))
    ax.set_axisbelow(True)
    if s.get('highlight_first',True):
        ax.axvspan(-.45,.45,color='#eff8f9',zorder=0)
    ax.grid(axis='y',linestyle=(0,(3,3)),color='#d9dfe3',lw=.8)
    palette = s.get('palette')
    if palette is None:
        defaults = ['#60a39f','#a8a8a8','#efb342','#69b5d5','#cb88b2','#a5a5a5']
        if len(order) <= len(defaults):
            palette = defaults[:len(order)]
        else:
            from colorsys import hls_to_rgb
            palette = [hls_to_rgb(i/len(order), .58, .48) for i in range(len(order))]
    if isinstance(palette,str) or len(palette) < len(order):
        raise ValueError('Provide at least one explicit color per category; colors are never cycled')
    lookup = summary.set_index(col['category'])
    stats = []
    for cat in order:
        row = lookup.loc[cat]
        stats.append(dict(label=str(cat),med=row[col['median']],q1=row[col['q1']],q3=row[col['q3']],
                          whislo=row[col['low']],whishi=row[col['high']],fliers=[]))
    boxes = ax.bxp(stats,positions=np.arange(len(order)),widths=s.get('box_width',.52),patch_artist=True,showfliers=False,
                  boxprops={'edgecolor':'#888888','linewidth':1.3},medianprops={'color':'#2f2f2f','linewidth':1.8},
                  whiskerprops={'color':'#555555','linewidth':1.3},capprops={'color':'#555555','linewidth':1.3})
    dots, means = [], []
    for i,cat in enumerate(order):
        color = palette[i]
        boxes['boxes'][i].set(facecolor=color,alpha=.85)
        sub = pts.loc[pts[col['category']] == cat]
        dots.append(ax.scatter(i+sub[col['jitter']],sub[col['value']],s=s.get('point_size',45),color=color,
                               alpha=.95,edgecolor='white',linewidth=.55,zorder=3))
        means.append(ax.scatter(i,lookup.loc[cat,col['mean']],marker='D',s=s.get('mean_size',150),c='white',
                                edgecolor='#303030',linewidth=1.8,zorder=4))
    ax.set(xlim=(-.5,len(order)-.5))
    if s.get('limits') is not None:
        ax.set_ylim(s['limits'])
    if s.get('ticks') is not None:
        ax.set_yticks(s['ticks'])
    if s.get('tick_format'):
        ax.yaxis.set_major_formatter(FormatStrFormatter(s['tick_format']))
    ax.set_title(s.get('title',''),fontsize=s['title_size'],pad=10)
    ax.set_ylabel(s.get('ylabel',''),fontsize=s['label_size'],labelpad=10)
    ax.set_xticks(range(len(order)),[str(v) for v in order],rotation=s['sizing']['label_rotation'],ha='right',rotation_mode='anchor')
    ax.tick_params(labelsize=s['sizing']['label_fontsize'],length=5,pad=5)
    ax.spines[['top','right']].set_visible(False)
    ax.spines[['bottom','left']].set_linewidth(1.4)
    return {'main':ax,'boxes':boxes,'points':dots,'means':means}
