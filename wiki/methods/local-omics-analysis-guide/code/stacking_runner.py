"""Explicit file/CLI adapter around the unchanged source stacking workflow."""
from pathlib import Path
import subprocess
import sys

def run_stacking_cli(data_path, label_col, gene_list_path, outdir, *, step, n_iter=100, top_k=3, seed=42):
    if step not in {"train", "eval", "explain", "all"}:
        raise ValueError("step must be explicitly selected")
    data_path = Path(data_path).resolve(strict=True)
    gene_list_path = Path(gene_list_path).resolve(strict=True)
    outdir = Path(outdir).resolve()
    script = Path(__file__).with_name("stacking_original.py")
    command = [sys.executable, str(script), "--data", str(data_path), "--label_col", label_col,
               "--gene_list_path", str(gene_list_path), "--outdir", str(outdir), "--step", step,
               "--n_iter", str(n_iter), "--top_k", str(top_k), "--seed", str(seed)]
    return subprocess.run(command, check=True, capture_output=True, text=True, encoding="utf-8")
