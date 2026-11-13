"""Compatible panel adapter; shares the standalone drawing core."""
from .panels import draw_boxplot, plot_panel

def draw(fig, rect, tables, style):
    return draw_boxplot(fig, rect, tables, style)
