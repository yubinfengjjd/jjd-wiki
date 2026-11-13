# Reference projection input diagnosis

The reviewed case uses the pinned real `pancreas_sub.rda`, reference cells 1–300, query cells 301–400, and the recorded parameters `ref_pca="PCA"`, `ref_umap="UMAP"`, `ref_group="CellType"`, `ref_dims=1:20`, `projection_method="knn"`, `k=10`, `distance_metric="cosine"`, `vote_fun="mean"`, with seed 11. These choices were preserved.

The original failure was `Argument 'dim.' must be an integer vector of length two`. The actual failure stack is `FindTransferAnchors → ProjectCellEmbeddings.default → rowMeans2(x=reference.data)`, before the later `IntegrateEmbeddings` call.

An isolated diagnostic established:

- Normalized reference and query assay data are `dgCMatrix`, dimensions 15,958×300 and 15,958×100. The hypothesized dense-Matrix dispatch problem is absent.
- `Loadings(ref[["PCA"]])` is an empty 0×0 matrix. The object contains PCA cell embeddings but no feature loadings for anchor projection.
- Seurat's `ProjectCellEmbeddings.default` obtains its projection feature names from those loadings. The feature set is empty; the selected reference/query data become `numeric(0)` with `dim=NULL`, and `rowMeans2` then fails.
- The caller's reference/query objects remained unchanged. No loadings were reconstructed or fabricated.

The raw diagnosis is preserved externally in `<ENV_ROOT>/method-runs/reference-features-5oikou4a/representation.json`; the sanitized diagnosis is in [reference-diagnosis.json](reference-diagnosis.json).

The formal wrapper's preflight now rejects an existing, selected PCA reduction without feature loadings when `reduction_project_method` is `pcaproject` (including its default). An omitted `ref_pca` follows the native selection of the first existing PCA reduction. Inputs with nonempty feature loadings reach the same existing native call; alternate projection methods retain their prior path. No native function, grouping, numerical parameter or projection algorithm was changed. `runtime.json` documents the guard.

The actual public regression first failed because the old wrapper emitted the original dimension error. After adding the guard it passed by observing exactly:

> Reference reduction 'PCA' has no feature loadings; pcaproject requires a fitted reference reduction with feature loadings.

The final [red/green regression](reference-guard-identity-hj5lr7db/summary.json) reuses the actual first-pass serialized input snapshot in two new processes. Both the input-file hash and the serialized input-object hash match across processes; each caller object and every original/copied source/input file remained unchanged. `reference_native.R` is identical before and after. The test's pass means the guard is correct for this invalid input; the scientific case remains `execution_state=not_run`, `algorithm_verification_state=not_run`.

There was no successful valid-loading reference case in this scoped work, because choosing or fitting a replacement reference representation was deferred to the author. No automatic fit or substitute data were used, and historical verification pointers were not promoted.
