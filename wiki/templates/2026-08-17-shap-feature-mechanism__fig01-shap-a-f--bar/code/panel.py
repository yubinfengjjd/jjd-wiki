"""SHAP bar panel with its final colorbar and polar inset geometry."""
import numpy as np
from matplotlib.cm import ScalarMappable
from matplotlib.colors import LinearSegmentedColormap, Normalize
from matplotlib.text import Text
from matplotlib.ticker import AutoMinorLocator, FormatStrFormatter, MaxNLocator


def padded_range(values, include_zero=False):
    low, high = float(min(values)), float(max(values))
    if include_zero:
        low, high = min(low, 0), max(high, 0)
    padding = (high - low) * .06 if high != low else (abs(high) or 1) * .06
    return [low - padding, high + padding]


def bar_palette(values, style):
    anchors = np.asarray(style['palette'])
    positions = np.linspace(0, 1, len(anchors))
    samples = np.column_stack([np.interp(np.linspace(0, 1, len(values)), positions, channel)
                               for channel in anchors.T])
    vmin, vmax = float(min(values)), float(max(values))
    if vmin == vmax:
        return LinearSegmentedColormap.from_list('printed_bars', anchors[::-1], N=4096), padded_range(values)
    stops = sorted(zip((np.asarray(values) - vmin) / (vmax - vmin), samples), key=lambda x: x[0])
    return LinearSegmentedColormap.from_list('printed_bars', stops, N=4096), [vmin, vmax]


def draw(fig, rect, tables, style):
    df = tables['SHAP汇总'].sort_values('shap', ascending=False, kind='stable')
    count = len(df)
    values = df.shap.to_numpy(float)
    cmap, domain = bar_palette(df.shap, style)
    norm = Normalize(*domain)
    colors = cmap(norm(values))
    ax = fig.add_axes(rect)
    ax.barh(np.arange(count), values, color=colors, height=0.67, edgecolor='none')
    ax.set_ylim(count - .05, -1.05)
    xlim = style['xlim']
    if xlim is None:
        high = padded_range(df.shap, include_zero=True)[1]
        xlim = (high, min(0, float(df.shap.min())))
    ticks = style['xticks']
    if ticks is None:
        ax.xaxis.set_major_locator(MaxNLocator(nbins=4))
    else:
        ax.set_xticks(ticks)
        ax.xaxis.set_major_formatter(FormatStrFormatter('%.2f'))
    ax.set_xlim(xlim)
    ax.xaxis.set_minor_locator(AutoMinorLocator(5))
    for which, length, width in (('major', 2, style['major_tick_width']),
                                 ('minor', 1.4, style['minor_tick_width'])):
        ax.tick_params(axis='x', which=which, direction=style['x_tick_direction'],
                       length=length, width=width, labelsize=style['axis_tick_size'], pad=2)
    ax.set_yticks(range(count), df.feature.astype(str).tolist(), weight=style['font_weight'])
    ax.yaxis.tick_right()
    ax.tick_params(axis='y', length=0, pad=7,
                   labelsize=min(style['feature_label_max_size'], style['feature_label_scale'] / count))
    ax.set_xlabel(style['shap_label'], fontsize=style['axis_label_size'],
                  labelpad=1, weight=style['font_weight'])
    for label in ax.get_xticklabels():
        label.set_weight(style['font_weight'])
    for name, spine in ax.spines.items():
        spine.set_linewidth(style['axes_linewidth'])
        spine.set_visible(name not in style['hidden_spines'])
    for axis in (ax.xaxis, ax.yaxis):
        axis.offsetText.set_fontsize(style['axis_offset_size'])
    for y, value in enumerate(values):
        ax.annotate(format(value, '.4f'), (value, y), xytext=(-1, 0),
                    textcoords='offset points', ha='right', va='center',
                    weight=style['font_weight'], fontsize=style['bar_value_size'],
                    bbox={'boxstyle': 'square,pad=0', 'fc': 'white', 'ec': '#bcbcbc',
                          'lw': style['annotation_linewidth']})

    cax = ax.inset_axes((-0.055, 0, 0.02, 1))
    cbar = fig.colorbar(ScalarMappable(norm=norm, cmap=cmap), cax=cax)
    cbar.set_ticks([])
    cbar.outline.set_visible(False)
    cax.text(-0.7, 1, style['high_label'], transform=cax.transAxes,
             ha='right', va='bottom', weight=style['font_weight'], fontsize=style['colorbar_end_size'])
    cax.text(-0.7, 0, style['low_label'], transform=cax.transAxes,
             ha='right', va='top', weight=style['font_weight'], fontsize=style['colorbar_end_size'])
    cax.set_ylabel(style['shap_label'], fontsize=style['colorbar_label_size'],
                   weight=style['font_weight'], labelpad=8)
    cax.yaxis.set_label_position('left')

    inset = ax.inset_axes((-0.01, 0.11, 0.36, 0.4), projection='polar')
    step = 315 / count
    angles = np.deg2rad(45 + np.arange(count) * step)
    heights = np.linspace(1.0, 2.1, count)
    width = np.deg2rad(step * 6 / 7)
    inset.set_theta_zero_location('N')
    inset.set_theta_direction(-1)
    inset.bar(angles, heights, width=width, bottom=0.07, color=colors,
              edgecolor='white', linewidth=style['inset_edge_width'])
    inset.bar(angles, heights * 0.72, width=width, bottom=0.07,
              color='white', alpha=0.85, linewidth=0)
    for angle, height, percent in zip(angles, heights, df.percent.to_numpy(float)):
        inset.text(angle, height + 0.49, f'{percent:.1f}%', ha='center', va='center',
                   fontsize=min(style['inset_label_max_size'], style['inset_label_scale'] / count),
                   weight=style['font_weight'])
    inset.set_ylim(0, 3.15)
    inset.set_axis_off()
    for text in ax.findobj(Text):
        text.set_fontfamily(style['font_family'])
