"""Build module counts from the real AxisNet ranking CSV.

The ranking CSV is the original project output; it is not synthetic.
"""
import pandas as pd

MODULE_ORDER = [
    "TM_IOP",
    "ECM_TGFB_EMT",
    "RGC_NEURODEGENERATION",
    "INFLAMMATION_COMPLEMENT",
    "MITO_FERROPTOSIS",
]

rank = pd.read_csv("data/ranking.csv")
rank = rank.sort_values("rank")
counts_all = rank["disease_module"].value_counts().reindex(MODULE_ORDER).fillna(0).astype(int)
counts_top20 = (
    rank.head(20)["disease_module"].value_counts().reindex(MODULE_ORDER).fillna(0).astype(int)
)

out = pd.DataFrame({
    "module": MODULE_ORDER,
    "all_count": counts_all.values,
    "top20_count": counts_top20.values,
})
out.to_csv("data/module-counts.csv", index=False)
# QA-required example filename; this is original project data, not estimated.
out.to_csv("data/estimated_data.csv", index=False)
print(out.to_string(index=False))
