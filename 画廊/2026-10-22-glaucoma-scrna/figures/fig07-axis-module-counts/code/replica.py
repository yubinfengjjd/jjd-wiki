"""Replay entry for the AxisNet disease-module count panel.

Uses the real project ranking CSV; no synthetic data.
"""
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

from core import plot_module_counts

plt.rcParams["pdf.fonttype"] = 42
plt.rcParams["ps.fonttype"] = 42
plt.rcParams["font.family"] = "DejaVu Sans"

df = pd.read_csv("data/module-counts.csv")
module_order = [
    "TM_IOP",
    "ECM_TGFB_EMT",
    "RGC_NEURODEGENERATION",
    "INFLAMMATION_COMPLEMENT",
    "MITO_FERROPTOSIS",
]
fig, _ = plot_module_counts(df, module_order=module_order)

out = Path("output")
out.mkdir(exist_ok=True)
fig.savefig(out / "replica.png", bbox_inches="tight", dpi=300)
fig.savefig(out / "replica.pdf", bbox_inches="tight")
fig.savefig(out / "replica.svg", bbox_inches="tight")
plt.close(fig)
print("Wrote output/replica.png, replica.pdf, replica.svg")
