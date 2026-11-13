"""Portable rendering cores. Inputs are already prepared result tables.

No fitting, density estimation, resampling, statistics or implicit file I/O.
Columns may be renamed via style['columns']; all styles are optional visual
parameters. The caller owns figure creation/export and the source annotation.
"""
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


def draw_density(fig, rect, tables, style):
    """Return dict(main, top, right, colorbar, points, fit).

    tables: points(x,y,red,green,blue), histograms(orientation,position,height,
    width). RGB are preassigned 0..255; histograms are precomputed, not inferred
    from potentially incomplete graphical points. Optional fit/annotation are
    explicit source labels, never recomputed here.
    """
    s = dict(style)
    col = dict(x='x', y='y', red='red', green='green', blue='blue',
               orientation='orientation', position='position', height='height', width='width')
    col.update(s.get('columns', {}))
    pts, hist = tables['points'], tables['histograms']
    _require(pts, [col[k] for k in ['x','y','red','green','blue']])
    _require(hist, [col[k] for k in ['orientation','position','height','width']])
    rgb = pts[[col[k] for k in ['red','green','blue']]].to_numpy(float)
    xy = pts[[col['x'], col['y']]].to_numpy(float)
    if not np.isfinite(xy).all() or not np.isfinite(rgb).all() or (rgb < 0).any() or (rgb > 255).any():
        raise ValueError('Points must be finite; RGB must lie in 0..255')
    hvalues = hist[[col[k] for k in ['position','height','width']]].to_numpy(float)
    if not np.isfinite(hvalues).all() or (hvalues[:,1] < 0).any() or (hvalues[:,2] <= 0).any():
        raise ValueError('Finite histogram positions, nonnegative heights and positive widths required')
    canvas = s.get('canvas_px', [1043, 927])
    boxes = s.get('boxes', {'main':[108,170,853,846], 'top':[108,14,853,156],
                           'right':[868,170,1026,846], 'colorbar':[707,515,743,799]})
    handles = {k:_axes(fig,rect,v,canvas) for k,v in boxes.items()}
    ax = handles['main']
    lim = s.get('limits', [-5,109,-5,109])
    ax.set(xlim=lim[:2], ylim=lim[2:], facecolor=s.get('background','#f4f7f9'))
    ax.grid(color='#d3dbe1',linestyle=':',linewidth=.9,zorder=0)
    handles['points'] = ax.scatter(xy[:,0],xy[:,1],c=rgb/255,s=s.get('point_size',12),
                                   marker='s',linewidths=0,zorder=3)
    line = np.array(lim[:2])
    if s.get('identity', True):
        ax.plot(line,line,'--',color='#666666',lw=1,zorder=2)
    if s.get('fit') is not None:
        slope, intercept = s['fit']
        handles['fit'] = ax.plot(line,slope*line+intercept,color=s.get('fit_color','#008798'),lw=1.8,zorder=4)[0]
    ax.set_xticks(s.get('xticks',list(range(0,101,20))))
    ax.set_yticks(s.get('yticks',list(range(0,101,20))))
    ax.tick_params(labelsize=13,pad=4,length=3.5)
    ax.set_xlabel(s.get('xlabel','Observed (SR)'),fontsize=14,labelpad=6)
    ax.set_ylabel(s.get('ylabel','Predicted (SR)'),fontsize=14,labelpad=7)
    if s.get('annotation'):
        ax.text(.04,.95,s['annotation'],transform=ax.transAxes,ha='left',va='top',
                fontsize=13,color='#666666',linespacing=1.02)
    if s.get('label'):
        ax.text(.50,.095,s['label'],transform=ax.transAxes,fontsize=13,weight='bold',
                color='#666666',ha='center')
    cb = fig.colorbar(ScalarMappable(norm=Normalize(*s.get('color_range',[0,3.1])),
                       cmap=s.get('cmap','RdYlGn_r')),cax=handles['colorbar'])
    cb.set_ticks(s.get('color_ticks',[0,1,2,3]))
    cb.set_ticklabels(s.get('color_ticklabels',['0','1','2','>3']))
    cb.ax.tick_params(labelsize=10,length=3,pad=2)
    cb.set_label(s.get('color_label','Frequency'),fontsize=13,labelpad=10)
    cb.outline.set_linewidth(.8)
    for orient in ['top','right']:
        ha = handles[orient]
        sub = hist.loc[hist[col['orientation']] == orient]
        if sub.empty:
            raise ValueError(f'Missing {orient} marginal')
        pos, height, width = [sub[col[k]].to_numpy(float) for k in ['position','height','width']]
        if orient == 'top':
            ha.bar(pos,height,width=width,color=s.get('hist_color','#b2d3d5'),linewidth=0)
            ha.set(xlim=lim[:2],ylim=s.get('top_limits',[0,40]),xticks=[],yticks=s.get('top_ticks',[0,20,40]))
            ha.set_ylabel(s.get('count_label','Count'),fontsize=11,labelpad=3)
            ha.spines[['top','right','bottom']].set_visible(False)
        else:
            ha.barh(pos,height,height=width,color=s.get('hist_color','#b2d3d5'),linewidth=0)
            ha.set(ylim=lim[2:],xlim=s.get('right_limits',[0,40]),yticks=[],xticks=s.get('right_ticks',[0,20,40]))
            ha.set_xlabel(s.get('count_label','Count'),fontsize=11,labelpad=3)
            ha.spines[['top','right','left']].set_visible(False)
        ha.tick_params(labelsize=10,length=3,pad=3,colors='#777777')
        ha.spines[['bottom','left']].set_color('#999999')
    return handles


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
    if summary[col['category']].duplicated().any():
        raise ValueError('One summary row per category required')
    order = list(s.get('order', summary[col['category']].tolist()))
    if not order or len(set(order)) != len(order) or set(pts[col['category']]) != set(order) or set(summary[col['category']]) != set(order):
        raise ValueError('Unique order must cover exactly point and summary categories')
    vals = pts[[col['value'],col['jitter']]].to_numpy(float)
    nums = summary[[col[k] for k in ['q1','median','q3','low','high','mean']]].to_numpy(float)
    if not np.isfinite(vals).all() or not np.isfinite(nums).all():
        raise ValueError('Finite dot and summary values required')
    if not ((nums[:,3] <= nums[:,0]) & (nums[:,0] <= nums[:,1]) & (nums[:,1] <= nums[:,2]) & (nums[:,2] <= nums[:,4])).all():
        raise ValueError('Require low <= q1 <= median <= q3 <= high')
    ax = _axes(fig,rect,s.get('bbox',[134,63,856,638]),s.get('canvas_px',[872,777]))
    ax.set_axisbelow(True)
    if s.get('highlight_first',True):
        ax.axvspan(-.45,.45,color='#eff8f9',zorder=0)
    ax.grid(axis='y',linestyle=(0,(3,3)),color='#d9dfe3',lw=.8)
    palette = s.get('palette',['#60a39f','#a8a8a8','#efb342','#69b5d5','#cb88b2','#a5a5a5'])
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
        color = palette[i % len(palette)]
        boxes['boxes'][i].set(facecolor=color,alpha=.85)
        sub = pts.loc[pts[col['category']] == cat]
        dots.append(ax.scatter(i+sub[col['jitter']],sub[col['value']],s=s.get('point_size',45),c=color,
                               alpha=.95,edgecolor='white',linewidth=.55,zorder=3))
        means.append(ax.scatter(i,lookup.loc[cat,col['mean']],marker='D',s=s.get('mean_size',150),c='white',
                                edgecolor='#303030',linewidth=1.8,zorder=4))
    ax.set(xlim=(-.5,len(order)-.5))
    if 'limits' in s:
        ax.set_ylim(s['limits'])
    if 'ticks' in s:
        ax.set_yticks(s['ticks'])
    if s.get('tick_format'):
        ax.yaxis.set_major_formatter(FormatStrFormatter(s['tick_format']))
    ax.set_title(s.get('title',''),fontsize=20,pad=10)
    ax.set_ylabel(s.get('ylabel',''),fontsize=17,labelpad=10)
    ax.set_xticks(range(len(order)),[str(v) for v in order],rotation=s.get('rotation',45),ha='right',rotation_mode='anchor')
    ax.tick_params(labelsize=14,length=5,pad=5)
    ax.spines[['top','right']].set_visible(False)
    ax.spines[['bottom','left']].set_linewidth(1.4)
    return {'main':ax,'boxes':boxes,'points':dots,'means':means}


def plot_panel(kind, tables, style=None, width=7):
    """Standalone wrapper, sharing the same core as draw adapters."""
    style = {} if style is None else style
    default_canvas = [1043,927] if kind == 'density' else [872,777]
    W,H = style.get('canvas_px',default_canvas)
    fig = plt.figure(figsize=(width,width*H/W),facecolor='white')
    try:
        handles = {'density':draw_density,'boxplot':draw_boxplot}[kind](fig,[0,0,1,1],tables,style)
    except Exception:
        plt.close(fig)
        raise
    return fig, handles
