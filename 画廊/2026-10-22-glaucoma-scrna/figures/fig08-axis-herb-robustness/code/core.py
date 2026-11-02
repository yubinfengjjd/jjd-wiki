"""Horizontal dot + error-bar chart for robust herb ranking.

Consumes a table with herb, robust and std. The x error is std * 0.5, matching
the source script; it is not a 95% confidence interval. Returns figure/axes.
"""
import matplotlib.pyplot as plt


def plot_herb_robustness(
    df,
    herb_col="herb",
    robust_col="robust",
    std_col="std",
    figsize=(7.6, 5.4),
    xerr_factor=0.5,
    title="",
):
    plot_df = df.sort_values(robust_col, ascending=True).copy()
    fig, ax = plt.subplots(figsize=figsize)
    ax.errorbar(
        plot_df[robust_col],
        plot_df[herb_col],
        xerr=plot_df[std_col] * xerr_factor,
        fmt="o",
        capsize=3,
        linewidth=1.2,
    )
    ax.set_xlabel("Robust score (mean − 0.5 × SD)")
    ax.set_ylabel("Herb")
    if title:
        ax.set_title(title)
    ax.grid(axis="x", alpha=0.20)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    fig.tight_layout()
    return fig, ax
