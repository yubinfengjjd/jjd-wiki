# Three FigureYa recipe failure investigations

Date: 2026-11-04. Scope: read-only source, dependency, receipt, and input-integrity investigation. No source changes, dependency installation, training, sample removal, imputation, or new pass receipt were performed. This report does not establish successful execution.

All recipe source paths below are relative to `知识库/recipes/`. The upstream snapshot is FigureYa commit `8d7a02c7d00467c45471139b63620571afebbeba`. Original `source/` files remain unchanged.

## figureya-153ccgraph

The Rmd loads the original helpers at `source/FigureYa153ccgraph.Rmd:89–90`, then calls `gather_graph_node()` and `gather_graph_edge()` at lines 239–240. Deprecated `.dots` grouping occurs in two places:

- `source/gather_graph_node.R:22`: `group_by(.dots=dots)` inside the loop over hierarchy levels.
- `source/gather_graph_edge.R:40`: `group_by(.dots=index[[1]])` when adding root edges.

Historical receipt `runs/20261027T123715Z.json:45` records dplyr **1.2.1**. Its error at line 173 begins `The .dots argument of group_by() was deprecated in dplyr 1.0.0 and`. The historical error string is truncated, so it should not be presented as a complete traceback or complete defunct-message quotation.

The old-machine inventory `依赖清单/R/observed-versions.tsv:80–81` records **dplyr 1.1.4 in R-base** and **1.2.1 in wiki-r-0**. Therefore 1.1.4 is an observed old-machine version, not an invented compatibility pin. It is not a historical successful run of this recipe: the available recipe receipt used 1.2.1 and failed.

The minimal faithful execution candidate is a recipe-specific library profile selecting the observed dplyr 1.1.4 before other libraries, in a fresh process, with unchanged source and recorded resolved dependency versions. It requires a new verification run before any pass claim. Do not downgrade the shared library, patch the original helpers, or represent the old inventory as a complete lockfile. This investigation did not create or activate that profile.

## figureya-61gsva

`source/FigureYa61GSVA.Rmd:160–167` calls the old API:

```r
GSVA::gsva(
  expr = expr_matrix,
  gset.idx.list = gs,
  method = "gsva",
  verbose = FALSE,
  kcdf = "Gaussian",
  parallel.sz = 1
)
```

Receipt `runs/20261027T124626Z.json:61` records **GSVA 2.2.0**, and line 147 records `unable to find an inherited method for function 'gsva' for signature 'param = "missing"'`. The API now dispatches on a parameter object, which this call does not supply. The earlier receipt `runs/20261027T123714Z.json` stopped first at a Zenodo HTTP 504 while obtaining the gene-set data; that network failure and the later API failure are separate blockers.

The old-machine inventory and the searched recipe receipts contain GSVA 2.2.0 only. **No successfully used legacy GSVA version was established.** Official Bioconductor `RELEASE_3_17` source identifies **GSVA 1.48.3** and implements the matrix/list API used here. It is an evidence-based archived compatibility candidate, not a recovered old working environment:

- [Official archived DESCRIPTION](https://raw.githubusercontent.com/bioc/GSVA/RELEASE_3_17/DESCRIPTION).
- [Official archived implementation, matrix/list method at lines 527–539](https://raw.githubusercontent.com/bioc/GSVA/RELEASE_3_17/R/gsva.R).

Two possible execution routes require separate labeling and verification:

1. An isolated archived-dependency profile, with a solved and recorded dependency closure. Installing the old GSVA package alone does not demonstrate compatibility with the current Bioconductor/Matrix-related dependency stack. The Rmd can remain byte-identical, but the profile is newly constructed and unverified.
2. A separately named compatibility implementation using `gsvaParam()` followed by `gsva()`, retaining the original source as provenance. This is adapted execution and cannot be reported as the unmodified L1 recipe passing. Matching parameter names does not establish numerical equivalence between implementations.

Any adaptation must preserve the following scientific choices:

- Rmd 116–124: human Hallmark sets, gene-symbol identifiers.
- Rmd 126–135: remove within-set duplicates; remove every gene present in two or more pathways; remove empty pathways. Do not weaken this filtering.
- Rmd 151–157: expression rows are genes and columns are samples; numeric dense matrix, without adding expression transformations.
- Rmd 163–166: GSVA method, explicit Gaussian kernel, one worker, suppressed progress output. Do not replace this with ssGSEA or the modern automatic kernel default.
- Legacy GSVA defaults verified in the official source: `min.sz=1`, `max.sz=Inf`, `tau=1`, `mx.diff=TRUE`, `abs.ranking=FALSE`. The corresponding parameter-object settings are `minSize=1`, `maxSize=Inf`, `tau=1`, `maxDiff=TRUE`, `absRanking=FALSE`; serial execution should be explicit. See the [official parameter-object constructor](https://raw.githubusercontent.com/bioc/GSVA/RELEASE_3_21/R/gsvaParam.R). That release branch currently identifies 2.2.1, so it is supporting API documentation, not evidence that the installed 2.2.0 was executed successfully.
- Rmd 188–204: first three samples in group a, next three in b; design without intercept; contrast b minus a; limma empirical Bayes; BH correction; all pathways returned and sorted by P value.
- Rmd 210–213 and 231–244: plot limma t statistics, with display cutoffs at -1 and +1. These display cutoffs are not an FDR threshold.

Gene-set provenance is an additional reproducibility boundary. Rmd 116–141 calls `msigdbr()` and overwrites `hallmark.gs.RData` before loading it at line 148. The original source hash is `686b79535d996ee24e4e9a1acda6237b7c485fd7457504ef0bbd6fcfd1c6853b`; the later failed receipt records a regenerated output hash `f5f3e0984b4a07f6f3c0ceeb1e117eae333084d1ca9c3b9947e1787319957c14`. Reusing the shipped snapshot or regenerating a contemporary annotation can produce different gene sets. Neither choice should be silently substituted for the other.

Pending choice to put to the user: **“GSVA 配方是保留原样并另建隔离旧依赖环境，还是新增明确标注的现代 API 适配分支？用于复现的 Hallmark 集合是否固定为随源码保存的快照，而不重新获取当前注释？”** No choice has been implemented.

## figureya-293machinelearning

The decisive input-integrity finding is upstream truncation, not a random train/test split.

`source/FigureYa293machineLearning.Rmd:133–135` reads the three inputs. Lines 144–146 standardize expression within each dataset. Lines 152–160 use all TCGA rows for estimation and put **TCGA plus both GEO datasets** into the evaluation list, selecting the training gene columns. There is no random sample split in this path.

The first RSF fit is at lines 177–183. The first operation capable of producing the observed row-count error is line 184, which binds all outcome rows to `predict(fit, newdata=x)$predicted`. Subsequent models reuse this pattern. Historical receipt `runs/20261027T132357Z.json:221` records `arguments imply differing number of rows: 269, 268`, but does not retain a full stack trace; assigning its exact executed frame to line 184 remains a well-supported inference rather than a recorded traceback.

The installed randomForestSRC 3.9.0 namespace was inspected without fitting a model. `rfsrc()` and `predict.rfsrc()` default to `na.action="na.omit"`; internal `finalizeData()` applies `na.omit()` to the required columns when missing data are present. A 269-row input containing one missing selected gene can therefore yield 268 predictions, which cannot be positionally bound to all 269 outcomes.

### Input evidence

The compressed source file is:

```text
GSE62254.txt.gz
size:   49,934,991 bytes
SHA256: ada9d7d27c61408336b1ed951ef74aeebedc9e2436e9e51002b90dd97e2e28af
Git blob SHA1: a118e6ca9670282df0cb932cedacf06d3ce9f8f4
```

Its SHA256 matches `source.json` and historical receipt `runs/20261027T132357Z.json:196`. Python zlib inspection reports that the gzip end-of-stream marker is absent, and standard gzip iteration raises `EOFError`. The partial decompressed text does not end with a newline.

The decompressed header has **24,445 columns**. There are **268 complete sample rows and one incomplete sample row**, giving 269 visible rows. The final sample is **GSM1524038**, with **19,192 columns**, so **5,253 gene fields are absent**. Of the 26 predictor genes selected from TCGA, the missing field is **SNHG5**. The final row retains `OS=1` and `OS.time=0.719444444444444`.

This is byte-level truncation; it must not be described as an ordinary biological missing observation. TCGA has 296 rows and GSE57303 has 68 rows; their selected outcome/predictor columns contain no missing or nonfinite values, duplicate sample IDs, or nonpositive survival times in the performed audit.

The exact upstream file at the fixed commit was streamed to memory and independently hashed, without overwriting the local source:

[Fixed-commit original GSE62254 input](https://raw.githubusercontent.com/ying-ge/FigureYa/8d7a02c7d00467c45471139b63620571afebbeba/FigureYa293machineLearning/GSE62254.txt.gz)

It has the same **49,934,991 bytes and SHA256**. Thus this truncation already exists in the upstream snapshot. A fresh download of that same object will not repair it. No complete equivalent processed input was obtained.

### GEO alignment and unresolved reconstruction

[Official GEO series](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE62254) lists 300 samples. The [machine-readable series metadata](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE62254&targ=self&form=text&view=full) was read and compared by accession: all 269 local sample IDs belong to that series; 31 series IDs are absent locally. These are GSM1523926, GSM1523942, GSM1524039–GSM1524062, and GSM1524068–GSM1524072. Their absence does not by itself establish whether they were excluded before truncation or lost through truncation.

[Official GSM1524038 record](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSM1524038) identifies sample T57, patient 57, and reports 54,675 probe rows with log10-transformed RMA values. The archived recipe input instead has gene-symbol columns. The Rmd does not provide the exact probe annotation, duplicate-probe aggregation, expression preprocessing, or sample-inclusion procedure that created this processed table. GEO accession alignment is verified; numerical equivalence of a reconstructed gene matrix is not verified.

Consequently, none of the following is a faithful repair without further evidence and a user decision: discard the last row, truncate the outcome table to 268 rows, impute SNHG5, remove SNHG5 from all models, reconstruct gene expression using an assumed probe-aggregation rule, or expand the cohort to all 300 GEO samples. Reordering or binding only by vector length can also misalign outcomes and predictions.

Pending question to put to the user: **“这个归档输入在上游就已截断。是否先保留该配方为失败、等待同一预处理版本的完整 GSE62254 输入；如果你希望重建数据，请明确批准按 GEO 原始数据另建重建分支，并确认探针到基因的注释/聚合规则与样本纳入标准？”** No sample deletion, missing-value policy, predictor change, or cohort reconstruction has been authorized or implemented.

## Verification limits and delivery state

This investigation used original-source reads, historical receipts, dependency inventories, gzip/CSV integrity checks, an in-memory fixed-commit hash comparison, official GSVA source inspection, and GEO accession alignment. It did not run the full recipe, train an RSF or another survival model, create an archived dependency profile, or manufacture outputs. An initial full-width R data read was stopped after the equivalent structural integrity checks were completed with Python; it is not counted as a completed R verification.

Only this report was added. The two unresolved GSVA/ML choices above remain for the user; no successful-reproduction claim follows from this investigation.
