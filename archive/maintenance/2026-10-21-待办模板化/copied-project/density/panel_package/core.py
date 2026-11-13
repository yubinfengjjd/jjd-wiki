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
    if not set(hist[col['orientation']]) <= {'top','right'}:
        raise ValueError('Marginal orientation must be top or right')
    canvas = s.get('canvas_px', [1043, 927])
    boxes = s.get('boxes', {'main':[108,170,853,846], 'top':[108,14,853,156],
                           'right':[868,170,1026,846], 'colorbar':[707,515,743,799]})
    if not s.get('show_colorbar',False):
        boxes = {k:v for k,v in boxes.items() if k != 'colorbar'}
    handles = {k:_axes(fig,rect,v,canvas) for k,v in boxes.items()}
    ax = handles['main']
    lim = s.get('limits')
    if lim is None:
        lo,hi = xy.min(axis=0),xy.max(axis=0)
        pad = np.where(hi>lo, (hi-lo)*.05, 1.0)
        lim = [lo[0]-pad[0],hi[0]+pad[0],lo[1]-pad[1],hi[1]+pad[1]]
    if len(lim)!=4 or not np.isfinite(lim).all() or lim[0]>=lim[1] or lim[2]>=lim[3]:
        raise ValueError('Explicit limits must be increasing finite x/y pairs')
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
    if s.get('xticks') is not None: ax.set_xticks(s['xticks'])
    if s.get('yticks') is not None: ax.set_yticks(s['yticks'])
    ax.tick_params(labelsize=13,pad=4,length=3.5)
    ax.set_xlabel(s.get('xlabel','Observed (SR)'),fontsize=14,labelpad=6)
    ax.set_ylabel(s.get('ylabel','Predicted (SR)'),fontsize=14,labelpad=7)
    if s.get('annotation'):
        ax.text(.04,.95,s['annotation'],transform=ax.transAxes,ha='left',va='top',
                fontsize=13,color='#666666',linespacing=1.02)
    if s.get('label'):
        ax.text(.50,.095,s['label'],transform=ax.transAxes,fontsize=13,weight='bold',
                color='#666666',ha='center')
    if s.get('show_colorbar',False):
        if s.get('color_range') is None or not s.get('color_label'):
            raise ValueError('Colorbar requires an explicit range and meaning; do not infer density from RGB')
        cr = s['color_range']
        if len(cr)!=2 or not np.isfinite(cr).all() or cr[0]>=cr[1]:
            raise ValueError('Colorbar range must be an increasing finite pair')
        cb = fig.colorbar(ScalarMappable(norm=Normalize(*s.get('color_range',[0,3.1])),
                           cmap=s.get('cmap','RdYlGn_r')),cax=handles['colorbar'])
        if s.get('color_ticks') is not None: cb.set_ticks(s['color_ticks'])
        if s.get('color_ticklabels') is not None: cb.set_ticklabels(s['color_ticklabels'])
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
            ha.set(xlim=lim[:2],xticks=[])
            if s.get('top_limits') is not None: ha.set_ylim(s['top_limits'])
            if s.get('top_ticks') is not None: ha.set_yticks(s['top_ticks'])
            ha.set_ylabel(s.get('count_label','Count'),fontsize=11,labelpad=3)
            ha.spines[['top','right','bottom']].set_visible(False)
        else:
            ha.barh(pos,height,height=width,color=s.get('hist_color','#b2d3d5'),linewidth=0)
            ha.set(ylim=lim[2:],yticks=[])
            if s.get('right_limits') is not None: ha.set_xlim(s['right_limits'])
            if s.get('right_ticks') is not None: ha.set_xticks(s['right_ticks'])
            ha.set_xlabel(s.get('count_label','Count'),fontsize=11,labelpad=3)
            ha.spines[['top','right','left']].set_visible(False)
        ha.tick_params(labelsize=10,length=3,pad=3,colors='#777777')
        ha.spines[['bottom','left']].set_color('#999999')
    return handles
