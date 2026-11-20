"""Multi-gene Kaplan-Meier survival risk grid with 95% CI dotted curves, HR, and Logrank P."""
import matplotlib.patches as mpatches
from matplotlib.gridspec import GridSpecFromSubplotSpec
import numpy as np


def draw(fig, rect, tables, style):
    km_df = tables["km_curves"]
    stats_df = tables["km_stats"]

    col_low = style.get("low_color", "#E29D7A")
    col_high = style.get("high_color", "#284560")
    ncols = int(style.get("ncols", 2))
    genes = list(dict.fromkeys(stats_df["gene"].astype(str).tolist()))
    n_genes = len(genes)
    nrows = int(np.ceil(n_genes / ncols))

    gs_outer = fig.add_gridspec(1, 1, left=rect[0], bottom=rect[1], right=rect[0] + rect[2], top=rect[1] + rect[3])
    sub_gs = GridSpecFromSubplotSpec(
        nrows + 1, ncols, subplot_spec=gs_outer[0, 0],
        height_ratios=[1.0] * nrows + [0.25], hspace=0.42, wspace=0.22,
    )

    axes = []
    for idx, g in enumerate(genes):
        r, c = divmod(idx, ncols)
        ax = fig.add_subplot(sub_gs[r, c])
        axes.append(ax)
        sub_g = km_df[km_df["gene"].astype(str) == g]
        for grp, col in [("Low", col_low), ("High", col_high)]:
            sg = sub_g[sub_g["group"].astype(str) == grp].sort_values("time_years")
            if sg.empty:
                continue
            ax.step(sg["time_years"], sg["surv"], where="post", color=col, lw=1.45)
            if "lower" in sg.columns and "upper" in sg.columns:
                ax.step(sg["time_years"], sg["lower"], where="post", color=col, lw=0.55, ls=":", alpha=0.70)
                ax.step(sg["time_years"], sg["upper"], where="post", color=col, lw=0.55, ls=":", alpha=0.70)
            if "n_censor" in sg.columns:
                cens = sg[sg["n_censor"] > 0]
                if not cens.empty:
                    ax.scatter(cens["time_years"], cens["surv"], marker="+", s=14, color=col, linewidths=0.7)

        st_row = stats_df[stats_df["gene"].astype(str) == g].iloc[0]
        stat_txt = (
            f"Logrank p={float(st_row['logrank_p']):.3g}\n"
            f"HR(high)={float(st_row['cox_hr_high_vs_low']):.2f}\n"
            f"p(HR)={float(st_row['cox_p']):.3g}\n"
            f"n(h)={int(st_row['n_high'])}, n(l)={int(st_row['n_low'])}"
        )
        ax.text(0.96, 0.78, stat_txt, transform=ax.transAxes, ha="right", va="top", fontsize=6.0, color="#222222")
        ax.set_title(g, fontsize=8.8, loc="left", pad=3)
        ax.set_ylim(0, 1.05)
        ax.set_yticks([0.0, 0.5, 1.0])
        ax.set_yticklabels(["0.0", "0.5", "1.0"] if c == 0 else [], fontsize=7.0)
        ax.tick_params(axis="x", labelsize=6.6, length=2.5, pad=1.5)
        ax.spines["top"].set_visible(False)
        ax.spines["right"].set_visible(False)
        ax.spines["left"].set_linewidth(0.75)
        ax.spines["bottom"].set_linewidth(0.75)

    # Shared Y & X labels (0-1 probability axis; optional cohort_label subtitle)
    if axes:
        base_ylabel = str(style.get("ylabel", "Survival probability")).strip() or "Survival probability"
        cohort_lbl = str(style.get("cohort_label", "")).strip()
        ylabel_txt = f"{base_ylabel} ({cohort_lbl})" if (cohort_lbl and cohort_lbl not in base_ylabel) else base_ylabel
        y_mid = 0.5 * (axes[0].get_position().y1 + axes[-1].get_position().y0)
        fig.text(axes[0].get_position().x0 - 0.065, y_mid, ylabel_txt,
                 rotation=90, ha="center", va="center", fontsize=8.5, color="#111111")
        x_mid = 0.5 * (axes[0].get_position().x0 + axes[min(ncols - 1, len(axes) - 1)].get_position().x1)
        fig.text(x_mid, axes[-1].get_position().y0 - 0.032, style.get("xlabel", "Time (years)"),
                 ha="center", va="top", fontsize=8.5, color="#111111")

    ax_leg = fig.add_subplot(sub_gs[nrows, :])
    ax_leg.axis("off")
    handles = [
        mpatches.Patch(facecolor=col_low, label="Low group"),
        mpatches.Patch(facecolor=col_high, label="High group"),
    ]
    ax_leg.legend(handles=handles, loc="center", ncol=2, frameon=False, fontsize=7.8, handlelength=1.1, handleheight=0.9)
    return axes
