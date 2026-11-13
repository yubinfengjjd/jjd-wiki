"""Single-panel callable; all inputs/visual settings explicit, no implicit I/O."""
from copy import deepcopy
import matplotlib.pyplot as plt
from .defaults import DEFAULT_STYLE
from .sizing import check_region, draw_figure
from .core import draw_boxplot

def resolved_style(style=None):
    result=deepcopy(DEFAULT_STYLE)
    for key,value in (style or {}).items():
        if key not in result:
            raise ValueError('Unknown visual setting: '+key)
        result[key] = result[key] | value if key in ('sizing','columns') and isinstance(value,dict) else deepcopy(value)
    return result

def draw(fig, rect, tables, style):
    s=resolved_style(style)
    check_region(fig,rect,tables,s)
    with plt.rc_context({'font.family':s['font_family']}):
        return draw_boxplot(fig,rect,tables,s)

def plot_panel(tables, style=None):
    """Return (figure, handles, sizing_plan). Caller exports; tables stay unchanged."""
    s=resolved_style(style)
    with plt.rc_context({'font.family':s['font_family'],'pdf.fonttype':42,'svg.fonttype':'none'}):
        return draw_figure(draw,tables,s)
