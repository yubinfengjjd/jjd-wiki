# Breast Cancer Stromal Cell Atlas Analysis

This repository contains the analysis code used to characterize stromal-cell heterogeneity in breast cancer using single-cell RNA sequencing and spatial transcriptomics.

The workflow focuses on three major stromal compartments:

* Cancer-associated fibroblasts (CAFs)
* Endothelial cells (ECs)
* Perivascular cells, including pericytes (PCs) and smooth muscle cells (SMCs)

The analyses include dataset integration, stromal-cell annotation, subcluster identification, differential expression, functional program scoring, tissue distribution, observed-to-expected enrichment analysis, pathway activity analysis, metabolic analysis, pseudotime inference, cell–cell communication analysis, and spatial transcriptomic deconvolution.

---

## Repository overview

The main scripts are:

| Script                                        | Description                                                                                                                                                         |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Fig1_stromal_annotation_and_subset.R`        | Annotates major stromal compartments and extracts CAF, endothelial, and perivascular-cell subsets for downstream analyses.                                          |
| `CAF_scRNA_integration_annotation_pipeline.R` | Performs CAF integration, reclustering, marker identification, functional enrichment, and manual subcluster annotation.                                             |
| `Fig2_CAF_program_distribution_progeny.R`     | Analyzes CAF transcriptional programs, sample-level proportions, tissue distribution, Ro/e enrichment, PROGENy pathway activity, chemokines, and MHC-related genes. |
| `PVL_Analysis_Final.R`                        | Performs integration, reclustering, annotation, differential-expression analysis, pathway analysis, and metabolic analysis of pericytes and smooth muscle cells.    |
| `Endo_Analysis_FullPipeline_Complete.R`       | Performs endothelial-cell integration, subcluster annotation, differential-expression analysis, Tip/Stalk scoring, PROGENy analysis, and metabolic analysis.        |
| `CAF_PVL_Endo_pseudotime.R`                   | Performs Monocle3 pseudotime analysis and imports scTOUR pseudotime results for CAFs, endothelial cells, and perivascular cells.                                    |
| `Cross-talk.R`                                | Prepares CellPhoneDB input files and performs CellChat-based ligand–receptor communication analysis.                                                                |
| `ST_RCTD_CAF_multiSample.R`                   | Performs RCTD deconvolution across multiple spatial transcriptomic samples and maps inferred stromal-cell abundances onto tissue sections.                          |

---

## Analysis workflow

```text
Integrated stromal-cell Seurat object
                  |
                  v
Fig1_stromal_annotation_and_subset.R
                  |
        +---------+---------+
        |         |         |
        v         v         v
       CAF       PVL        EC
        |         |         |
        v         v         v
CAF integration  PVL       Endothelial
and annotation   analysis   analysis
        |         |         |
        +---------+---------+
                  |
        +---------+---------+
        |                   |
        v                   v
Functional and         Pseudotime
distribution analyses  analysis
        |
        v
Cell–cell communication
        |
        v
Spatial RCTD deconvolution
```

---

## Recommended script order

The scripts can be run in the following order:

```bash
Rscript Fig1_stromal_annotation_and_subset.R

Rscript CAF_scRNA_integration_annotation_pipeline.R
Rscript Fig2_CAF_program_distribution_progeny.R

Rscript PVL_Analysis_Final.R
Rscript Endo_Analysis_FullPipeline_Complete.R

Rscript CAF_PVL_Endo_pseudotime.R
Rscript Cross-talk.R
Rscript ST_RCTD_CAF_multiSample.R
```

Not every script must be run in a single workflow. Individual modules can be executed separately when the required input objects are available.

---

## Suggested directory structure

```text
.
├── README.md
├── Fig1_stromal_annotation_and_subset.R
├── CAF_scRNA_integration_annotation_pipeline.R
├── Fig2_CAF_program_distribution_progeny.R
├── PVL_Analysis_Final.R
├── Endo_Analysis_FullPipeline_Complete.R
├── CAF_PVL_Endo_pseudotime.R
├── Cross-talk.R
├── ST_RCTD_CAF_multiSample.R
│
├── code/
│   ├── distribution_Roe.R
│   └── ratio.plot.R
│
├── rawdata/
│   ├── sub_CAF_pre.qs
│   ├── sce-all.qs
│   ├── gene_chemokines.csv
│   ├── gene_MHC.csv
│   ├── RCTD_reference_caf_all.qs
│   └── scTOUR/
│       ├── ptime_metadata_CAF.csv
│       ├── ptime_metadata_PVL.csv
│       └── ptime_metadata_Endo.csv
│
├── metadata.csv
│
└── result/
    ├── fig1/
    ├── fig2_CAF/
    ├── fig3_PVL/
    ├── fig4_Endo/
    ├── fig5/
    ├── fig_ST/
    └── cellphoneDB/
```

Several scripts contain server-specific absolute paths. These paths must be replaced with local paths before the workflow is run.

Examples include:

```r
"/home/data/caixing/CAF/metadata.csv"
"/home/data/caixing/CAF/result/fig_ST/"
```

For improved portability, users are encouraged to define all input and output paths in a separate configuration file.

---

## Input data

### 1. Integrated single-cell object

The main input is a processed Seurat object containing stromal cells.

The object should contain:

* RNA count and normalized-expression matrices
* Sample identifiers
* Batch information
* Initial cell-type annotations
* Quality-control variables
* Dimensionality-reduction results or sufficient data to rerun dimensionality reduction

Common metadata columns used by the scripts include:

| Metadata column     | Description                                      |
| ------------------- | ------------------------------------------------ |
| `orig.ident`        | Sample identifier                                |
| `sample`            | Sample name                                      |
| `batch`             | Batch variable used for integration              |
| `clusters`          | Major cell-type annotation                       |
| `subclusters`       | Stromal-cell subcluster annotation               |
| `Tissue`            | Tissue type, such as Normal, Tumor, or Lymphnode |
| `Molecular_subtype` | Breast cancer molecular subtype                  |
| `GSE_number`        | Dataset or GEO accession                         |
| `nCount_RNA`        | RNA count per cell                               |
| `percent_mito`      | Percentage of mitochondrial transcripts          |

### 2. Sample metadata

The sample metadata file should contain one row per sample and should include `orig.ident` as the matching field.

Example:

```text
orig.ident,Tissue,Molecular_subtype,GSE_number
Sample_01,Tumor,HER2,GSEXXXXXX
Sample_02,Normal,Normal,GSEXXXXXX
```

### 3. Gene-set files

The following files are used for chemokine and MHC-related analyses:

```text
rawdata/gene_chemokines.csv
rawdata/gene_MHC.csv
```

Each file should contain a column named `gene`.

Example:

```text
gene
CXCL8
CXCL10
CCL19
CCL21
```

### 4. scTOUR pseudotime files

The scTOUR output files should contain cell identifiers and pseudotime values.

Required columns:

```text
index,ptime
cell_barcode_1,0.012
cell_barcode_2,0.037
```

The values in the `index` column must match the cell names in the corresponding Seurat object.

### 5. Spatial transcriptomic data

The RCTD workflow requires:

* A Seurat object for each spatial transcriptomic sample
* Raw counts stored in the `Spatial` assay
* Spatial coordinates accessible through `GetTissueCoordinates()`
* A previously generated RCTD reference object
* Consistent gene identifiers between the spatial data and reference data

The default sample identifiers used in the script are:

```text
CAA_ST
CAB_ST
CAC_ST
CAD_ST
LNA_ST
LNB_ST
LNC_ST
LND_ST
```

---

## Software requirements

The workflow was developed in R and requires packages from CRAN, Bioconductor, and GitHub.

### Core single-cell analysis

```r
Seurat
SCP
harmony
qs
dplyr
tidyverse
ggplot2
ggpubr
patchwork
scCustomize
```

### Heatmaps and visualization

```r
ComplexHeatmap
circlize
pheatmap
RColorBrewer
cowplot
viridis
grid
```

### Differential expression and functional analysis

```r
BiocParallel
scProgram
progeny
scMetabolism
limma
vegan
philentropy
matrixStats
scater
```

### Trajectory analysis

```r
monocle3
```

scTOUR must be run separately before importing its pseudotime results into R.

### Cell–cell communication

```r
CellChat
AnnoProbe
psych
qgraph
igraph
svglite
```

CellPhoneDB is a separate Python-based program. The R script prepares the required input files, but CellPhoneDB must be installed and executed independently.

### Spatial transcriptomic analysis

```r
RCTD
```

Depending on the installed version, RCTD may be distributed through the `spacexr` package ecosystem.

### Additional packages

```r
openxlsx
readxl
data.table
dendextend
rsvd
```

---

## Main analysis modules

## 1. Stromal-cell annotation and subset extraction

Script:

```text
Fig1_stromal_annotation_and_subset.R
```

This script:

1. Loads the integrated stromal-cell Seurat object.
2. Adds sample-level metadata.
3. Displays dataset composition on UMAP.
4. Examines canonical stromal-cell marker genes.
5. Separates CAF, endothelial, and perivascular-cell populations.
6. Saves lineage-specific Seurat objects for downstream analyses.

Representative markers include:

* Fibroblasts: `COL1A1`, `COL1A2`, and `DCN`
* Endothelial cells: `PECAM1`, `VWF`, and `CD34`
* Perivascular cells: `ACTA2`, `PDGFRB`, and `MCAM`

---

## 2. CAF integration and annotation

Script:

```text
CAF_scRNA_integration_annotation_pipeline.R
```

This script performs:

* fastMNN integration
* Harmony integration
* Graph-based clustering
* Marker-gene identification
* KEGG and Hallmark enrichment
* Manual CAF-subcluster annotation
* Subcluster-level differential-expression analysis

Fourteen CAF subclusters are defined in the current workflow:

```text
C1_Fib_ACTA2
C2_Fib_HSPA6
C3_Fib_PLA2G2A
C4_Fib_BNC2
C5_Fib_CXCL8
C6_Fib_NFKB1
C7_Fib_APOD
C8_Fib_CCL19
C9_Fib_COL12A1
C10_Fib_ABCA8
C11_Fib_ENO1
C12_Fib_CD74
C13_Fib_LUM
C14_Fib_A2M
```

The numerical cluster-to-subtype mapping is specific to the current dataset and clustering parameters. The annotations should be reevaluated if the input object, integration method, or clustering resolution is changed.

---

## 3. CAF functional programs and tissue distribution

Script:

```text
Fig2_CAF_program_distribution_progeny.R
```

This script evaluates several CAF-related transcriptional programs, including:

* Resting CAF program
* Inflammatory CAF program
* Matrix CAF program
* Tumor-like or hypoxia-associated CAF program
* Proliferating CAF program
* Interferon-associated CAF program
* Antigen-presenting CAF program
* Vascular-associated CAF program
* Lipid-associated CAF program

The script also performs:

* CAF-subcluster proportion analysis
* Tissue-distribution analysis
* Molecular-subtype distribution analysis
* Ro/e enrichment analysis
* PROGENy pathway analysis
* Chemokine-expression analysis
* MHC-related gene-expression analysis

### Ro/e analysis

The Ro/e index is calculated as the ratio between the observed and expected numbers of cells.

Interpretation:

```text
Ro/e > 1: relative enrichment
Ro/e < 1: relative depletion
Ro/e = 1: close to the expected distribution
```

Ro/e is used as a descriptive measure of tissue or molecular-subtype preference.

---

## 4. Perivascular-cell analysis

Script:

```text
PVL_Analysis_Final.R
```

This script analyzes perivascular cells, including pericytes and smooth muscle cells.

The workflow includes:

* fastMNN integration
* Harmony integration
* Reclustering
* Differential-expression analysis
* Marker-based annotation
* Chemokine-expression analysis
* Metabolic-pathway scoring
* limma-based pathway comparison

The current workflow identifies three smooth muscle cell subclusters and seven pericyte subclusters.

Smooth muscle cell subclusters:

```text
C1_MLY9+SMC
C2_FN1+SMC
C3_MYH11+SMC
```

Pericyte subclusters:

```text
C1_COL3A1+PC
C2_CCL19+PC
C3_CD74+PC
C4_SEPT7+PC
C5_PRKG1+PC
C6_CXCL8+PC
C7_GJA5+PC
```

The label `C1_MLY9+SMC` is retained to remain consistent with the existing analysis object. Users should verify whether this label was intended to refer to the marker gene `MYL9`.

---

## 5. Endothelial-cell analysis

Script:

```text
Endo_Analysis_FullPipeline_Complete.R
```

This script performs:

* fastMNN integration
* Endothelial-cell reclustering
* Marker-based subcluster annotation
* Tip- and Stalk-cell program scoring
* Differential-expression analysis
* Functional enrichment
* PROGENy pathway analysis
* Chemokine-expression analysis
* Metabolic-pathway analysis

The current workflow identifies 12 endothelial subclusters:

```text
C1_ArtECs_SEMA3G+
C2_ArtECs_DLL4+
C3_CapECs_CD36+
C4_tips_PGF+
C5_VenECs_HIF1A+
C6_VenECs_CD74+
C7_tECs_DOCK4+
C8_emtECs_CD24+
C9_emtECs_COL1A1+
C10_nECs_IL6+
C11_nECs_HMOX1+
C12_LECs_CCL21+
```

These subtypes include arterial, capillary, tip-like, venous, tumor-associated, endothelial-to-mesenchymal-like, inflammatory or stress-associated, and lymphatic endothelial states.

---

## 6. Pseudotime analysis

Script:

```text
CAF_PVL_Endo_pseudotime.R
```

This script performs Monocle3 pseudotime analysis for CAF, perivascular, and endothelial populations.

The workflow:

1. Converts the Seurat object into a Monocle3 `cell_data_set`.
2. Performs dimensionality reduction.
3. Replaces the Monocle3 UMAP coordinates with the selected Seurat embedding.
4. Learns the principal trajectory graph.
5. Calculates Monocle3 pseudotime.
6. Adds pseudotime values to the Seurat metadata.
7. Imports scTOUR pseudotime values when available.
8. Saves the updated Seurat object and Monocle3 object.

For reproducible noninteractive analysis, root cells or root principal nodes should be specified explicitly when ordering cells.

---

## 7. Cell–cell communication analysis

Script:

```text
Cross-talk.R
```

This script supports CellPhoneDB and CellChat analyses.

### CellPhoneDB input preparation

The script downsamples cells within each subcluster and generates:

```text
result/cellphoneDB/test_counts.txt
result/cellphoneDB/test_meta.txt
```

CellPhoneDB must then be run externally.

The CellPhoneDB output file, such as `means.txt`, can subsequently be imported into R for heatmap visualization.

### CellChat analysis

The CellChat workflow includes:

* Identification of overexpressed genes
* Identification of overexpressed ligand–receptor interactions
* Communication-probability calculation
* Pathway-level communication analysis
* Network aggregation
* Pairwise communication plots
* Pathway-specific communication plots

The numerical `sources` and `targets` used in CellChat depend on the factor-level order of `cellchat@idents`. These indices must be checked before the script is applied to a different object.

---

## 8. Spatial transcriptomic deconvolution

Script:

```text
ST_RCTD_CAF_multiSample.R
```

The script performs RCTD deconvolution for multiple spatial transcriptomic samples.

For each sample, the workflow:

1. Loads the spatial Seurat object.
2. Extracts the spatial count matrix.
3. Extracts tissue coordinates.
4. Creates a `SpatialRNA` object.
5. Runs RCTD in doublet mode.
6. Adds first- and second-cell-type assignments to the Seurat metadata.
7. Runs RCTD in full mode.
8. Adds continuous cell-type weights to the spatial Seurat object.
9. Generates spatial feature plots.
10. Saves the RCTD object and updated Seurat object.

The metadata column range used for spatial plotting is specific to the current reference object. If the reference-cell composition changes, the plotted cell-type columns should be selected explicitly rather than by fixed column numbers.

---

## Main outputs

Representative outputs include:

```text
result/fig1/
├── allcelltype_GSE_number.pdf
├── all_DotPlot.pdf
├── featureplot3.pdf
└── caf-pvl-edno_FeatureDimPlot.pdf

result/fig2_CAF/
├── CAF_UMAP.pdf
├── CAF_maker.pdf
├── CAF_genesets.pdf
├── CAF_cluters_barplot.pdf
├── subclusters_Poe.pdf
├── progeny.pdf
├── CAF_chemokines.pdf
├── CAF-DEGs.csv
└── sub_CAF_maker_subclusters.qs

result/fig3_PVL/
├── sub_PVL_maker.pdf
├── PVL_chemokines_heatmap.pdf
├── sub_PVL_re_analysis.qs
└── metabolism/

result/fig4_Endo/
├── Endo_subclusters_UMAP.pdf
├── FeatureHeatmap_DEGs.pdf
├── progeny.pdf
├── Chemokine_Heatmap.pdf
├── sub_Endo_final.qs
└── metabolism/

result/fig5/
├── cellchat/
├── cellchat_str/
└── cellchat_pathways/

result/fig_ST/
├── sample-caf-RCTDfull.pdf
├── sample-caf-RCTD-full.qs
└── sample.qs
```

---

## Important notes

### File-name consistency

Some scripts were generated at different stages of the analysis and may use different file names for related objects.

Examples include:

```text
sub_PVL.qs
sub_PVL_umap.qs
sub_PVL_re_analysis.qs

sub_Endo.qs
sub_Endo_pro.qs
sub_Endo_final.qs
```

Before running the workflow, confirm that each script points to the intended input object.

---

### Seurat version compatibility

Some functions differ between Seurat versions.

For example:

```r
GetAssayData(object, slot = "counts")
```

may need to be replaced with:

```r
GetAssayData(object, layer = "counts")
```

when using Seurat v5.

---

### Manual annotation

The cluster-to-subtype mappings are manually defined using marker-gene expression and differential-expression results.

These mappings should not be transferred directly to a new dataset without reevaluating:

* Marker-gene expression
* Differential-expression results
* Cluster stability
* Batch composition
* Biological interpretation

---

### Parallel computing

Several scripts use parallel processing.

Examples include:

```r
MulticoreParam(workers = 8)
future::plan("multisession", workers = 14)
create.RCTD(..., max_cores = 8)
```

The number of workers should be adjusted according to the available computing resources.

---

### Random sampling

The workflow includes cell downsampling and reference-cell sampling.

A fixed random seed should be set before sampling:

```r
set.seed(123)
```

This improves reproducibility.

---

### Output directories

Some scripts create their output directories automatically, whereas others assume that the required directories already exist.

Before running the complete workflow, users should create the following directories:

```r
dir.create("result/fig1", recursive = TRUE, showWarnings = FALSE)
dir.create("result/fig2_CAF", recursive = TRUE, showWarnings = FALSE)
dir.create("result/fig3_PVL", recursive = TRUE, showWarnings = FALSE)
dir.create("result/fig4_Endo", recursive = TRUE, showWarnings = FALSE)
dir.create("result/fig5", recursive = TRUE, showWarnings = FALSE)
dir.create("result/fig_ST", recursive = TRUE, showWarnings = FALSE)
dir.create("result/cellphoneDB", recursive = TRUE, showWarnings = FALSE)
```

---

## Reproducibility

The following information should be recorded when reproducing the analyses:

```r
sessionInfo()
```

The use of `renv` is recommended for dependency management:

```r
install.packages("renv")
renv::init()
renv::snapshot()
```

A complete reproducible release should ideally include:

* `renv.lock`
* R version
* Package versions
* Sample metadata template
* Dataset accession numbers
* Random seeds
* Input-file descriptions
* Centralized path configuration
* Session information

---

## Data availability

Large Seurat objects, processed expression matrices, spatial transcriptomic objects, and clinical data are not included in this repository.

Public datasets should be downloaded from the accession numbers reported in the associated manuscript and converted into the input formats described above.

Controlled-access or institutional datasets should be obtained under the relevant data-use and ethical approvals.

---

## Citation

When using this repository, please cite the associated manuscript and the relevant software packages.

The manuscript citation can be added after publication:

```text
Author(s). Article title. Journal. Year. DOI.
```

Relevant methods include:

* Seurat
* Harmony
* fastMNN
* SCP
* Monocle3
* scTOUR
* CellChat
* CellPhoneDB
* PROGENy
* scMetabolism
* RCTD

---

## License

A license has not yet been specified.

Before public release, please add a `LICENSE` file. Common choices include:

* MIT License
* GNU General Public License v3.0
* Apache License 2.0

The selected license should be consistent with institutional requirements and third-party software dependencies.

---

## Contact

For questions regarding the analysis workflow, please open an issue in this GitHub repository or contact the corresponding author of the associated manuscript.
