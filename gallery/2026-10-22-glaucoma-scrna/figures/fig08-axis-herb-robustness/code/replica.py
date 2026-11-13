"""Replay entry for the AxisNet herb robustness panel.

Uses the real project cv_results.json; no synthetic data.
"""
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

from core import plot_herb_robustness

plt.rcParams["pdf.fonttype"] = 42
plt.rcParams["ps.fonttype"] = 42
plt.rcParams["font.family"] = "DejaVu Sans"

df = pd.read_csv("data/herb-robustness.csv")
fig, _ = plot_herb_robustness(df)

out = Path("output")
out.mkdir(exist_ok=True)
fig.savefig(out / "replica.png", bbox_inches="tight", dpi=300)
fig.savefig(out / "replica.pdf", bbox_inches="tight")
fig.savefig(out / "replica.svg", bbox_inches="tight")
plt.close(fig)
print("Wrote output/replica.png, replica.pdf, replica.svg")
