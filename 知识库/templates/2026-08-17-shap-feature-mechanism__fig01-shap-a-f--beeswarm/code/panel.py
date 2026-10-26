"""SHAP beeswarm panel; the seed and original density jitter are unchanged."""
import matplotlib
import numpy as np
from matplotlib.cm import ScalarMappable
from matplotlib.colors import Normalize
from matplotlib.text import Text
from matplotlib.ticker import AutoMinorLocator, MaxNLocator


def padded_range(values, include_zero=False):
    low, high = float(min(values)), float(max(values))
    if include_zero:
        low, high = min(low, 0), max(high, 0)
    padding = (high - low) * .06 if high != low else (abs(high) or 1) * .06
    return [low - padding, high + padding]


def draw(fig, rect, tables, style):
    df = tables['SHAP逐样本值']
    order = style['feature_order']
    if order is None:
        order = df.assign(importance=df.shap.abs()).groupby('feature', sort=False).importance.mean().sort_values(ascending=False, kind='stable').index.tolist()
    count = len(order)
    cmap = matplotlib.colormaps[style['cmap']]
    xlim = style['xlim']
    if xlim is None:
        xlim = padded_range(df.shap, include_zero=True)
    clim = style['clim']
    if clim is None:
        clim = padded_range(df.feature_value)
    norm = Normalize(*clim)
    rng = np.random.default_rng(20261020)
    ax = fig.add_axes(rect)
    for row, feature in enumerate(order):
        points = df.loc[df['feature'] == feature]
        xs = points['shap'].to_numpy(float)
        if len(xs):
            bins = np.floor(xs / max((xlim[1] - xlim[0]) / 180, 0.05)).astype(int)
            _, inverse, counts = np.unique(bins, return_inverse=True, return_counts=True)
            amplitude = np.minimum(1, np.sqrt(counts[inverse] / 7)) * 0.24
            ys = row + rng.uniform(-1, 1, len(xs)) * amplitude
            ax.scatter(xs, ys, c=points['feature_value'], cmap=cmap, norm=norm,
                       s=4.5, linewidths=0, zorder=3)
    ax.set_ylim(count - .05, -1.05)
    if style['xticks'] is None:
        ax.xaxis.set_major_locator(MaxNLocator(nbins=4))
    else:
        ax.set_xticks(style['xticks'])
    ax.set_xlim(xlim)
    ax.xaxis.set_minor_locator(AutoMinorLocator(5))
    for which, length, width in (('major', 2, style['major_tick_width']),
                                 ('minor', 1.4, style['minor_tick_width'])):
        ax.tick_params(axis='x', which=which, direction=style['x_tick_direction'],
                       labelsize=style['axis_tick_size'], pad=2, length=length, width=width)
    ax.set_yticks(range(count), order)
    ax.tick_params(axis='y', left=False, right=False, labelright=False,
                   labelleft=style['show_feature_labels'], length=0,
                   labelsize=style['feature_label_size'])
    ax.set_xlabel(style['shap_label'], fontsize=style['axis_label_size'],
                  weight=style['font_weight'], labelpad=1)
    for label in ax.get_xticklabels():
        label.set_weight(style['font_weight'])
    for name, spine in ax.spines.items():
        spine.set_linewidth(style['axes_linewidth'])
        spine.set_visible(name not in style['hidden_spines'])
    for axis in (ax.xaxis, ax.yaxis):
        axis.offsetText.set_fontsize(style['axis_offset_size'])
    ax.axvline(0, color=style['zero_line_color'], linewidth=style['zero_line_width'], zorder=1)
    ax.grid(axis='y', color='#d5d5d5', linestyle=(0, (1, 4)),
             linewidth=style['grid_line_width'], zorder=0)

    cax = ax.inset_axes((1.067, 0, 0.014, 1))
    cbar = fig.colorbar(ScalarMappable(norm=norm, cmap=cmap), cax=cax)
    cbar.set_ticks(clim, labels=[style['low_label'], style['high_label']])
    cbar.ax.tick_params(length=0, labelsize=style['colorbar_tick_size'], pad=1)
    cbar.set_label(style['feature_value_label'], fontsize=style['colorbar_label_size'], labelpad=-7)
    cbar.outline.set_visible(False)
    for text in ax.findobj(Text):
        text.set_fontfamily(style['font_family'])
