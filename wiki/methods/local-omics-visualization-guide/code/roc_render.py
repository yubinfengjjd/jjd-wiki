"""Source ROC styling with explicitly supplied precomputed curves/AUCs. No fitting, label guessing or direction inversion."""
from __future__ import annotations
from typing import Dict
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from mpl_toolkits.axes_grid1.inset_locator import inset_axes

def style_axes(ax):
    """Apply standard clean styling to matplotlib axes."""
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_color('#333333')
    ax.spines['bottom'].set_color('#333333')
    ax.tick_params(colors='#333333')
    ax.xaxis.label.set_color('#333333')
    ax.yaxis.label.set_color('#333333')
    ax.title.set_color('#111111')
    ax.grid(True, linestyle='--', alpha=0.3, color='#cccccc')
    ax.set_facecolor('white')


def draw_auc_strip(ax_parent, auc_dict: Dict[str, float], cohort_colors: Dict[str, str]):
    """Draws a vertical strip of colored boxes containing AUC text on the right side of the plot."""
    items = sorted(auc_dict.items(), key=lambda x: x[1], reverse=True)
    n = len(items)
    # Widened width to 40% and bbox_to_anchor to 0.4 as per requested styling
    ax_strip = inset_axes(
        ax_parent,
        width="40%",
        height="100%",
        loc="lower left",
        bbox_to_anchor=(1.02, 0.0, 0.4, 1.0),
        bbox_transform=ax_parent.transAxes,
        borderpad=0
    )
    ax_strip.set_xlim(0, 1)
    ax_strip.set_ylim(0, n)
    ax_strip.axis("off")

    for i, (cohort_name, aucv) in enumerate(items):
        y0 = n - i - 1
        color = cohort_colors.get(cohort_name, '#333333')
        rect = patches.Rectangle((0.0, y0), 1.0, 1.0, facecolor=color, edgecolor="white", linewidth=0.8)
        ax_strip.add_patch(rect)
        ax_strip.text(0.5, y0 + 0.5, f"{aucv:.3f}", ha="center", va="center", fontsize=10, color="white", fontweight='bold')
    return ax_strip


def render_roc_curves(curves, aucs, cohort_colors, title, figsize=(5.0, 4.5)):
    """curves[name]=(fpr,tpr); aucs[name]=upstream AUC. Return figure and axes without saving files."""
    if not curves or set(curves) != set(aucs):
        raise ValueError("curves and aucs must have the same nonempty cohort keys")
    fig, ax = plt.subplots(figsize=figsize)
    ax.plot([0, 1], [0, 1], linestyle="--", linewidth=1.0, color="black")
    for name, (fpr, tpr) in curves.items():
        ax.plot(fpr, tpr, linewidth=1.6, label=name, color=cohort_colors.get(name, "#333333"))
    ax.set_title(title, fontsize=12, fontweight="bold")
    ax.set_xlabel("False Positive Rate (1 - Specificity)", fontsize=10)
    ax.set_ylabel("True Positive Rate (Sensitivity)", fontsize=10)
    style_axes(ax)
    ax.legend(loc="lower right", fontsize=8, frameon=True, framealpha=0.9)
    draw_auc_strip(ax, aucs, cohort_colors)
    fig.tight_layout()
    return fig, ax
