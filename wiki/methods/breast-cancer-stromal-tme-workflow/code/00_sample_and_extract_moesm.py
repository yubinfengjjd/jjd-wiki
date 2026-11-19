"""00_sample_and_extract_moesm.py
Extract MOESM2..MOESM8 official Supplementary Excel tables into standardized CSVs
under data_small/moesm/ for deterministic downstream R/Python analysis and plotting.
"""
from __future__ import annotations

import csv
import json
from pathlib import Path
import openpyxl

PAPER_DIR = Path(r"E:\research-wiki-env\sources\papers\2026-cai-stromal-tme")
SUPP_DIR = PAPER_DIR / "intake" / "supp"
OUT_DIR = PAPER_DIR / "data_small" / "moesm"
OUT_DIR.mkdir(parents=True, exist_ok=True)

SHEET_MAP = {
    "41698_2026_1718_MOESM2_ESM.xlsx": {"Supplementary Table 1": "supp1_clinical.csv"},
    "41698_2026_1718_MOESM3_ESM.xlsx": {
        "Fib": "deg_fib.csv",
        "EC": "deg_ec.csv",
        "Mural cell": "deg_mural.csv",
    },
    "41698_2026_1718_MOESM4_ESM.xlsx": {
        "Fib": "taxonomy_fib.csv",
        "EC": "taxonomy_ec.csv",
        "Mural cell": "taxonomy_mural.csv",
    },
    "41698_2026_1718_MOESM5_ESM.xlsx": {
        "TCGA_datasets": "cox_tcga.csv",
        "inhouse_datasets": "cox_inhouse.csv",
    },
    "41698_2026_1718_MOESM6_ESM.xlsx": {
        "Fib": "enrich_fib.csv",
        "EC": "enrich_ec.csv",
        "Mural cell": "enrich_mural.csv",
    },
    "41698_2026_1718_MOESM7_ESM.xlsx": {
        "Bulk": "corr_bulk.csv",
        "ST": "corr_st.csv",
    },
    "41698_2026_1718_MOESM8_ESM.xlsx": {
        "cellchat": "cellchat_edges.csv",
        "cellphone-pvalue": "cellphone_pvalue.csv",
        "cellphone-count": "cellphone_count.csv",
    },
}


def main() -> None:
    manifest = {}
    for fname, sheets in SHEET_MAP.items():
        xlsx_path = SUPP_DIR / fname
        wb = openpyxl.load_workbook(xlsx_path, read_only=True, data_only=True)
        for sheet_name, out_name in sheets.items():
            ws = wb[sheet_name]
            out_csv = OUT_DIR / out_name
            row_count = 0
            headers = None
            with open(out_csv, "w", newline="", encoding="utf-8") as fh:
                writer = csv.writer(fh)
                for idx, row in enumerate(ws.iter_rows(values_only=True)):
                    if idx == 0:
                        headers = [str(c) if c is not None else f"col_{j}" for j, c in enumerate(row)]
                        # Drop trailing empty unnamed columns
                        while headers and headers[-1].startswith("col_"):
                            headers.pop()
                        writer.writerow(headers)
                        continue
                    vals = list(row[: len(headers)])
                    if all(v is None for v in vals):
                        continue
                    writer.writerow(["" if v is None else v for v in vals])
                    row_count += 1
            manifest[out_name] = {"source": f"{fname}::{sheet_name}", "rows": row_count, "cols": len(headers or [])}
        wb.close()
    (OUT_DIR / "manifest.json").write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(json.dumps(manifest, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
