# RNA velocity execution audit

## Approved execution boundary

This task executes the existing `recorded_velocity` case through `method-replay/replay.py`. It does not edit formal Wiki source, runtime manifests, page status, verification pointers, or historical receipts. It does not install packages or perform an original-versus-wrapper algorithm comparison.

The parent confirmed completion of the shared-library `scrapper` installation and namespace check before this execution started. The prepared Python 3.8 interpreter is selected explicitly with `RETICULATE_PYTHON`; automatic installation remains disabled.

## Fixed existing case

- Input: pinned public `pancreas_sub.rda`, SHA256 `d95f56fc231378ed14e55fafdebfccb6a6bb464a1a9d988f83e7101d92649744`.
- Existing bounded case: the first 80 observed cells, seed 11. No further cell removal, layer synthesis, metadata renaming, or pseudotime/velocity fabrication is permitted.
- Parameters: `assay_X=RNA`, `assay_layers=c(spliced, unspliced)`, `group_by=CellType`, `linear_reduction=PCA`.
- Other parameters: unchanged native defaults, including stochastic mode, `min_shared_counts=30`, `n_pcs=30`, `n_neighbors=30`, `n_jobs=1`, and `show_plot=TRUE`.
- Before-run estimate: approximately 5–15 minutes if conversion and backend execution proceed; startup may fail earlier. Hard child timeout: 1,800 seconds.

## Known closure limitation

`code/velocity_native.R` loads `SCP_analysis` from the installed `SCP` package using `system.file("python", package="SCP")`. Neither that backend nor the R package is declared in the current runtime closure. Installed SCP may provide the backend for this execution audit, but success would not establish standalone portability or algorithm equivalence.

Actual exit status, warnings, input-preservation checks, and output hashes are recorded separately after the process completes. Complete machine-local commands and logs remain outside both repositories under `<ENV_ROOT>/velocity-runs/`.

## Observed result

The first actual run and an authorized same-case diagnostic rerun both failed at scVelo's velocity-graph ragged-array conversion. No final `result.rds` was produced. See `summary.json`, `diagnostic-summary.json`, `diagnostic-context.json`, and `compatibility-proposal.md`. Original/copy source and input-file preservation passed; the failed calls did not reach the existing in-memory input-object assertion. Formal verification and portability states remain unchanged. Shared R library use has ended; no package was installed or changed by this task.
