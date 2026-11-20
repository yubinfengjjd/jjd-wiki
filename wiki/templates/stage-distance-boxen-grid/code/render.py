"""Standalone panel entry for Python template."""
import argparse
import importlib.util
import json
import sys
from pathlib import Path
from uuid import uuid4

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd


def main():
    parser = argparse.ArgumentParser()
    for flag in ("data", "out"):
        parser.add_argument("--" + flag, type=Path, required=True)
    parser.add_argument("--style", type=Path)
    args = parser.parse_args()

    target = Path(__file__).resolve().parents[1]
    spec = json.loads((target / "spec.json").read_text(encoding="utf-8"))
    style = dict(spec.get("style", {}))
    if args.style and args.style.exists():
        override = json.loads(args.style.read_text(encoding="utf-8"))
        for k, v in override.items():
            if v is not None:
                style[k] = v

    name = "panel_" + uuid4().hex
    pkg_spec = importlib.util.spec_from_file_location(
        name, target / "code/__init__.py", submodule_search_locations=[str(target / "code")]
    )
    pkg = importlib.util.module_from_spec(pkg_spec)
    sys.modules[name] = pkg
    pkg_spec.loader.exec_module(pkg)

    panel_spec = importlib.util.spec_from_file_location(name + ".panel", target / "code/panel.py")
    panel = importlib.util.module_from_spec(panel_spec)
    sys.modules[name + ".panel"] = panel
    panel_spec.loader.exec_module(panel)

    tables = {}
    for key, tmeta in spec["tables"].items():
        fname = tmeta.get("filename") or f"{tmeta['interface']}.csv"
        fpath = args.data / fname
        if fpath.exists():
            tables[key] = pd.read_csv(fpath)

    matplotlib.rcParams.update({"pdf.fonttype": 42, "svg.fonttype": "none", "font.family": "DejaVu Sans"})
    fig = plt.figure(figsize=(style["width_in"], style["height_in"]), dpi=style["dpi"], facecolor="white")
    panel.draw(fig, style.get("rect", [0.06, 0.08, 0.88, 0.84]), tables, style)

    args.out.mkdir(parents=True, exist_ok=True)
    for ext in ("png", "pdf", "svg"):
        fig.savefig(args.out / f"figure.{ext}", format=ext, dpi=style["dpi"], facecolor="white")
    plt.close(fig)


if __name__ == "__main__":
    main()
