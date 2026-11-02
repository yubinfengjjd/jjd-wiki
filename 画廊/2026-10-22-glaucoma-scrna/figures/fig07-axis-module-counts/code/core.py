"""Grouped bar chart for disease-module axis counts.

Consumes a table with module, all_count and top20_count. Returns a matplotlib
figure and axes; it does not read files or save output.
"""
import textwrap

import numpy as np
import matplotlib.pyplot as plt


MODULE_LABELS = {
    "TM_IOP": "TM / IOP",
    "ECM_TGFB_EMT": "ECM / TGFβ / EMT",
    "RGC_NEURODEGENERATION": "RGC neurodegeneration",
    "INFLAMMATION_COMPLEMENT": "Inflammation / Complement",
    "MITO_FERROPTOSIS": "Mitochondria / Ferroptosis",
}


def wrap_text(value, width=16):
    return "\n".join(textwrap.wrap(str(value), width=width, break_long_words=False))


def plot_module_counts(
    df,
    module_order=None,
    module_labels=None,
    figsize=(7.4, 5.2),
    width=0.38,
    title="",
):
    if module_order is None:
        module_order = df["module"].tolist()
    if module_labels is None:
        module_labels = MODULE_LABELS

    indexed = df.set_index("module").reindex(module_order)
    x = np.arange(len(module_order))

    fig, ax = plt.subplots(figsize=figsize)
    ax.bar(
        x - width / 2,
        indexed["all_count"].values,
        width,
        label="All ranked axes",
        edgecolor="black",
        linewidth=0.5,
    )
    ax.bar(
        x + width / 2,
        indexed["top20_count"].values,
        width,
        label="Top 20 axes",
        edgecolor="black",
        linewidth=0.5,
    )
    ax.set_xticks(x)
    ax.set_xticklabels([wrap_text(module_labels.get(m, m), 16) for m in module_order])
    ax.set_xlabel("Disease module")
    ax.set_ylabel("Number of axes")
    if title:
        ax.set_title(title)
    ax.legend(frameon=False)
    ax.grid(axis="y", alpha=0.20)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    fig.tight_layout()
    return fig, ax
