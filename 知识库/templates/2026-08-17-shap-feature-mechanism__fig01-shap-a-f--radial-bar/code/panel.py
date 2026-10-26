"""SHAP radial bars with final label offset, alignment and colorbar styling."""
import matplotlib
import numpy as np
from matplotlib.cm import ScalarMappable
from matplotlib.colors import Normalize
from matplotlib.text import Text
from matplotlib.ticker import FormatStrFormatter, MaxNLocator


def padded_range(values):
    low, high = float(min(values)), float(max(values))
    padding = (high - low) * .06 if high != low else (abs(high) or 1) * .06
    return [low - padding, high + padding]


def draw(fig, rect, tables, style):
    df = tables['SHAP汇总']
    order = style['feature_order']
    if order is None:
        order = df.sort_values('shap', ascending=False, kind='stable').feature.tolist()
    df = df.set_index('feature').loc[order].reset_index()
    count = len(order)
    values = df.shap.to_numpy(float)
    clim = style['clim']
    if clim is None:
        clim = padded_range(df.shap)
    cmap = matplotlib.colormaps[style['cmap']]
    norm = Normalize(*clim)
    inner, base_height, height_scale = 2.1, 0.08, 1.5
    heights = base_height + height_scale * values / clim[1]
    theta = np.arange(count) * 2 * np.pi / count
    ax = fig.add_axes(rect, projection='polar')
    ax.set_theta_offset(np.pi / 2 - np.pi / count)
    ax.set_theta_direction(-1)
    ax.bar(theta, heights, width=2 * np.pi / count * 0.93, bottom=inner,
            color=cmap(norm(values)), edgecolor='#777777', linewidth=style['bar_edge_width'])
    circle = np.linspace(0, 2 * np.pi, 400)
    ax.plot(circle, np.full_like(circle, inner - 0.09), color='#777777',
             linewidth=style['ring_edge_width'])
    for angle, height, label, percent, value in zip(theta, heights, df.feature, df.percent.to_numpy(float), values):
        degrees = np.degrees(angle) + 180 / count
        rotation = 90 - degrees
        left = degrees > 180
        if left:
            rotation += 180
        # Preserve the original additions/subtraction order for identical pixels.
        radius = inner + height + 0.52 - 0.29
        ax.text(angle, radius, f'{label}\n{percent:.1f}%', rotation=rotation,
                 rotation_mode='anchor', ha='right' if left else 'left', va='center',
                 fontsize=min(style['feature_label_max_size'], style['feature_label_scale'] / count),
                 weight=style['font_weight'], color='#262626', clip_on=False)
        text_rotation = (-np.degrees(angle) + 90) % 180 - 90
        ax.text(angle, inner + height / 2, f'{value:.3f}', color='white',
                 fontsize=min(style['bar_value_max_size'], style['bar_value_scale'] / count),
                 weight=style['font_weight'], ha='center', va='center', rotation=text_rotation)
    ax.set_ylim(0, inner + base_height + height_scale + style['radial_outer_padding'])
    ax.set_axis_off()

    cax = ax.inset_axes((0.47, 0.38, 0.028, style['colorbar_height']))
    cbar = fig.colorbar(ScalarMappable(norm=norm, cmap=cmap), cax=cax)
    cbar.outline.set_linewidth(style['axes_linewidth'])
    ticks = style['ticks']
    if ticks is None:
        cbar.locator = MaxNLocator(nbins=4)
        cbar.update_ticks()
    else:
        cbar.set_ticks(ticks)
        cax.yaxis.set_major_formatter(FormatStrFormatter('%.3f'))
    cax.set_ylim(cbar.norm.vmin, cbar.norm.vmax)
    cax.tick_params(axis='both', which='both', direction=style['tick_direction'])
    cax.tick_params(labelsize=style['colorbar_tick_size'], length=1, pad=1,
                    width=style['colorbar_tick_width'])
    cax.set_title(style['absolute_shap_label'], fontsize=style['colorbar_title_size'],
                   pad=3, weight=style['font_weight'])
    for text in ax.findobj(Text):
        text.set_fontfamily(style['font_family'])
