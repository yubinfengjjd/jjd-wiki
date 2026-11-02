"""Build the herb robustness table from the real AxisNet cv_results.json.

The CV results are original project output, not synthetic.
"""
import json

import pandas as pd

HERB_NAMES = {
    "HIT2:H0189": "Green tea",
    "HIT2:H0173": "Garlic",
    "HIT2:H0750": "Flaxseed",
    "HIT2:H0462": "Ginkgo leaf",
    "HIT2:H0028": "Danshen",
    "HIT2:H0697": "Juemingzi",
    "HIT2:H1040": "Shanzha",
    "HIT2:H0938": "Huangqi",
    "HIT2:H0631": "Danggui",
    "HIT2:H0366": "Gouqizi",
}

with open("data/cv_results.json", "r", encoding="utf-8") as handle:
    cv = json.load(handle)

rows = []
for item in cv["top10_herbs"]:
    rows.append({
        "rank": item["rank"],
        "herb": HERB_NAMES.get(item["herb"], item["herb"]),
        "herb_id": item["herb"],
        "robust": item["robust"],
        "mean": item["mean"],
        "std": item["std"],
    })

out = pd.DataFrame(rows).sort_values("rank")
out.to_csv("data/herb-robustness.csv", index=False)
# QA-required example filename; this is original project data, not estimated.
out.to_csv("data/estimated_data.csv", index=False)
print(out.to_string(index=False))
