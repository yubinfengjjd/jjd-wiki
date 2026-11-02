import os
import argparse
from pathlib import Path
from typing import List, Dict

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from mpl_toolkits.axes_grid1.inset_locator import inset_axes
from sklearn.metrics import roc_curve, roc_auc_score

# Cohort colors matching the style requested
COHORT_COLORS = {
    'GSE38713': '#2874C5',      # Blue from previous R script
    'Combined_data': '#d62728', # Red (similar to Bayes-CatBoost)
    'GSE47908': '#EABF00'       # Yellow from previous R script
}

def style_axes(ax):
    """Apply standard clean styling to matplotlib axes."""
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['left'].set_color('#333333')
    ax.spines['bottom'].set_color('#333333')
    ax.tick_params(colors='#333333')
    ax.xaxis.label.set_color('#333333')
    ax.yaxis.label.set_color('#333333')
    ax.title.set_color('#111111')
    ax.grid(True, linestyle='--', alpha=0.3, color='#cccccc')
    ax.set_facecolor('white')

def draw_auc_strip(ax_parent, auc_dict: Dict[str, float], cohort_colors: Dict[str, str]):
    """Draws a vertical strip of colored boxes containing AUC text on the right side of the plot."""
    items = sorted(auc_dict.items(), key=lambda x: x[1], reverse=True)
    n = len(items)
    # Widened width to 40% and bbox_to_anchor to 0.4 as per requested styling
    ax_strip = inset_axes(
        ax_parent,
        width="40%",
        height="100%",
        loc="lower left",
        bbox_to_anchor=(1.02, 0.0, 0.4, 1.0),
        bbox_transform=ax_parent.transAxes,
        borderpad=0
    )
    ax_strip.set_xlim(0, 1)
    ax_strip.set_ylim(0, n)
    ax_strip.axis("off")

    for i, (cohort_name, aucv) in enumerate(items):
        y0 = n - i - 1
        color = cohort_colors.get(cohort_name, '#333333')
        rect = patches.Rectangle((0.0, y0), 1.0, 1.0, facecolor=color, edgecolor="white", linewidth=0.8)
        ax_strip.add_patch(rect)
        ax_strip.text(0.5, y0 + 0.5, f"{aucv:.3f}", ha="center", va="center", fontsize=10, color="white", fontweight='bold')
    return ax_strip

def read_gene_list(filepath: str) -> List[str]:
    """Read a list of gene symbols from a text file, skipping headers."""
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.read().splitlines()
    genes = [line.strip() for line in lines if line.strip() and line.strip().lower() != 'x']
    return genes

def load_cohort_data(filepath: str) -> pd.DataFrame:
    """Read gene expression matrix (assumes genes on rows, samples on cols)."""
    df = pd.read_csv(filepath, sep='\t', index_col=0)
    # Transpose so samples are rows and genes are columns
    df = df.T
    
    # Infer labels from sample names (_control vs _treat)
    labels = []
    for idx_name in df.index:
        name = str(idx_name).lower()
        if name.endswith("_control"):
            labels.append(0)
        elif name.endswith("_treat"):
            labels.append(1)
        else:
            labels.append(np.nan)
            
    df['Label'] = labels
    df = df.dropna(subset=['Label'])
    df['Label'] = df['Label'].astype(int)
    
    return df

def main():
    parser = argparse.ArgumentParser(description="Multi-cohort Gene ROC plotting")
    parser.add_argument("--genes", type=str, default="intersectGenes.txt", help="Path to text list of target genes")
    parser.add_argument("--outdir", type=str, default="ROC_python", help="Output directory for plots")
    args = parser.parse_args()

    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)
    
    genes_to_plot = read_gene_list(args.genes)
    if not genes_to_plot:
        print(f"[WARN] No valid genes found in {args.genes}")
        return
        
    print(f"[INFO] Target genes: {genes_to_plot}")

    cohorts = {
        'GSE38713': 'nor/GSE38713.normalize.txt',
        'Combined_data': 'nor/merge.normalize.txt',
        'GSE47908': 'nor/GSE47908.normalize.txt'
    }

    # Load all cohort data into a dictionary of DataFrames
    data_dict = {}
    for c_name, c_path in cohorts.items():
        if os.path.exists(c_path):
            print(f"[INFO] Loading {c_name} from {c_path}")
            data_dict[c_name] = load_cohort_data(c_path)
        else:
            print(f"[WARN] File not found: {c_path}")

    if not data_dict:
        print("[ERROR] No cohort data files could be loaded.")
        return

    for gene in genes_to_plot:
        print(f"[INFO] Evaluating gene: {gene}")
        
        fig, ax = plt.subplots(figsize=(5.0, 4.5))
        ax.plot([0, 1], [0, 1], linestyle='--', linewidth=1.0, color='black')
        
        aucs = {}
        for c_name, c_df in data_dict.items():
            if gene not in c_df.columns:
                print(f"[WARN] {gene} not found in {c_name}")
                continue
                
            y_true = c_df['Label'].values
            y_score = c_df[gene].values
            
            # Use raw expression values as probability scores for ROC
            # Some genes might be negatively correlated (lower expression = disease), 
            # so we check both orientations and take the one > 0.5 AUC if we assume 
            # the biomarker should be predictive. For consistency with previous pipeline, 
            # we just take the raw direction, or enforce >0.5.
            
            try:
                auc_val_direct = roc_auc_score(y_true, y_score)
                # If AUC is less than 0.5, inverted prediction (1 - y_score) is better.
                # Usually we just plot what the score gives, but to avoid visual clutter below diagonal,
                # let's map it. 
                # (Optional: If requested just plot raw)
                if auc_val_direct < 0.5:
                    y_score = -y_score  # Invert for ROC calculation
                    auc_val = roc_auc_score(y_true, y_score)
                else:
                    auc_val = auc_val_direct
                    
                fpr, tpr, _ = roc_curve(y_true, y_score)
                aucs[c_name] = auc_val
                
                color = COHORT_COLORS.get(c_name, '#333333')
                ax.plot(fpr, tpr, linewidth=1.6, label=c_name, color=color)
            except Exception as e:
                print(f"[WARN] Failed to compute ROC for {gene} in {c_name}: {e}")

        if not aucs:
            print(f"[WARN] No valid data plotted for {gene}, skipping.")
            plt.close(fig)
            continue
            
        ax.set_title(f"ROC: {gene}", fontsize=12, fontweight='bold')
        ax.set_xlabel('False Positive Rate (1 - Specificity)', fontsize=10)
        ax.set_ylabel('True Positive Rate (Sensitivity)', fontsize=10)
        style_axes(ax)
        ax.legend(loc='lower right', fontsize=8, frameon=True, framealpha=0.9)
        
        # AUC Strip
        draw_auc_strip(ax, aucs, cohort_colors=COHORT_COLORS)
        
        fig.tight_layout()
        
        # Save plots
        out_pdf = outdir / f"ROC_multi_cohort_{gene}.pdf"
        out_png = outdir / f"ROC_multi_cohort_{gene}.png"
        
        fig.savefig(out_pdf, bbox_inches='tight', dpi=300)
        fig.savefig(out_png, bbox_inches='tight', dpi=300)
        plt.close(fig)
        
        print(f"[INFO] Saved {out_pdf}")

if __name__ == "__main__":
    main()
