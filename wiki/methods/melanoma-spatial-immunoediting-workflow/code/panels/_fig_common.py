#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Shared paths, palettes, and figure/panel export helpers for pmc9167783 (Nirmal et al., Cancer Discovery 2022).
All paths default to <sources_root>/papers/pmc9167783 and respect zero-C-drive rules.
"""

import os
import json
from pathlib import Path
from PIL import Image

DEFAULT_PAPER_ROOT = Path(os.environ.get("PAPER_ROOT", "."))


def load_visual_spec(paper_root: Path = DEFAULT_PAPER_ROOT) -> dict:
    spec_path = paper_root / "review" / "palette_and_layout_spec.json"
    if spec_path.exists():
        with open(spec_path, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}


def save_replica_and_compare(
    fig,
    paper_root: Path,
    fig_slug: str,
    orig_filename: str,
    panel_boxes_frac: dict | None = None,
) -> tuple[Path, Path]:
    """
    Save figure replica PNG+PDF to both review/<fig_slug>_replica.* and review/figures/<fig_slug>_replica.*,
    crop individual panel images to review/panels/, and build review/compare/<fig_slug>_side_by_side.png
    (left=original plate, right=replica, height <= 1400 px, < 5 MB).
    """
    review_dir = paper_root / "review"
    figures_dir = review_dir / "figures"
    panels_dir = review_dir / "panels"
    compare_dir = review_dir / "compare"
    for d in (review_dir, figures_dir, panels_dir, compare_dir):
        d.mkdir(parents=True, exist_ok=True)

    out_png = review_dir / f"{fig_slug}_replica.png"
    out_pdf = review_dir / f"{fig_slug}_replica.pdf"
    fig_png = figures_dir / f"{fig_slug}_replica.png"
    fig_pdf = figures_dir / f"{fig_slug}_replica.pdf"

    fig.savefig(out_png, dpi=300, facecolor="white")
    fig.savefig(out_pdf, dpi=300, facecolor="white")
    fig.savefig(fig_png, dpi=300, facecolor="white")
    fig.savefig(fig_pdf, dpi=300, facecolor="white")

    rep_img = Image.open(out_png).convert("RGB")
    w, h = rep_img.size

    if panel_boxes_frac:
        for pname, (x0f, y0f, x1f, y1f) in panel_boxes_frac.items():
            box = (int(w * x0f), int(h * y0f), int(w * x1f), int(h * y1f))
            rep_img.crop(box).save(panels_dir / f"{fig_slug}_panel{pname}.png", format="PNG")

    orig_p = Path(orig_filename)
    orig_path = orig_p if orig_p.is_absolute() else (
        paper_root / orig_filename if (paper_root / orig_filename).exists() else paper_root / "intake" / "supp" / orig_filename
    )
    orig_img = Image.open(orig_path).convert("RGB")
    target_h = min(1300, max(orig_img.height, 960))
    orig_w = int(round(orig_img.width * (target_h / orig_img.height)))
    rep_w = int(round(rep_img.width * (target_h / rep_img.height)))

    orig_res = orig_img.resize((orig_w, target_h), Image.Resampling.LANCZOS)
    rep_res = rep_img.resize((rep_w, target_h), Image.Resampling.LANCZOS)

    gap = 24
    canvas = Image.new("RGB", (orig_w + gap + rep_w, target_h), (255, 255, 255))
    canvas.paste(orig_res, (0, 0))
    canvas.paste(rep_res, (orig_w + gap, 0))
    out_cmp = compare_dir / f"{fig_slug}_side_by_side.png"
    canvas.save(out_cmp, format="PNG", optimize=True)
    return out_png, out_cmp
