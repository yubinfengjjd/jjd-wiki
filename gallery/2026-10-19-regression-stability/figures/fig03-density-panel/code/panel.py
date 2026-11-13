"""Compatible panel adapter; shares the standalone drawing core."""
from .panels import draw_density, plot_panel

def draw(fig, rect, tables, style):
    return draw_density(fig, rect, tables, style)
