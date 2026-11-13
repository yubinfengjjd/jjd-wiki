# Method replay audit, 2026-11-03

This directory covers **43 method pages and 85 declared implementations**. Discovery is read-only. Historical states remain 51 passed, 31 not_run and 3 missing verification pointers. The author-approved public breast-cancer case passed five evaluation branches and ROC rendering. After independent `migration_spec_review` PASS, the primary agent authorized adopting six new algorithm pointers and eighteen new verification files. Runtime manifests and default portability pointers remain unchanged; old/private historical cases are preserved. See `formal-adoption-after-20261104.json` for official parser results and the zero-change comparison of all 79 non-target branches.

The mapping distinguishes:

| Category | Implementations | Meaning |
|---|---:|---|
| public_replay_candidate | 20 | Existing parameters and the pinned public pancreas fixture can be reused by the supplied driver |
| public_input_backend_required | 1 | RNA velocity has real measured inputs; its current source still depends on an undeclared installed SCP Python backend |
| scientific_input_or_choice_required | 8 | Historical input is artificial or a scientific case requires explicit selection |
| author_deferred | 4 | Author deferred Monocle until a biological root group is specified |
| recorded_case_required | 4 | No single portable current case, including three missing verification pointers |
| catalog_only | 1 | 448 registered native R source occurrences; registration is not execution |
| historical_artifact_or_case_required | 33 | Missing historical external validation drivers/configs, private inputs, selected function arguments or dependencies |
| adopted_public_software_case | 6 | The reviewed public software case has been adopted through formal algorithm pointers; historical private evidence remains preserved |
| derived_input_required | 8 | Historical calls need a genuine upstream result, not a fabricated lineage/velocity/enrichment object |

The 20 direct candidates comprise nine analysis/adapter calls and eleven native plot calls. A twenty-first prepared driver invokes real RNA velocity and records its backend-closure limitations. Candidate status does not establish that dependencies are installed, the original function succeeds on this R version, or any scientific conclusion is valid. The discovery has not loaded the installing R package library.

## Files

- `discover.py`: enumerate current frontmatter with the existing Wiki page reader; inspect manifests and receipts without executing methods.
- `replay-map.json`: full discovery output; six actual new public cases are marked `executed_public_case`, while their absent historical private cases remain `historical_case_replay_state=not_run`.
- `coverage.md`: compact full-page/full-implementation coverage and blockers.
- `replay.py`: copy the declared closure and pinned input to a unique external directory, run a new R process without a shell, collect arguments/versions/hashes/logs, and assert that original code, runtime and input files were preserved.
- `driver.R`: validate an existing historical portable result or invoke a recorded native plot case. Plot arguments accept only `@pancreas_sub`; no expression evaluation, synthetic objects, installation or missing-value construction is allowed.
- `test_replay.py`: orchestration tests; these are not method execution evidence.
- `public_python_replay.py`: the approved real public fit, AST reference extraction, five independent evaluation processes and one independent native ROC renderer.
- `public-python-evidence/`, `public-python-results.md`: actual sanitized receipts/comparisons, inspected ROC outputs, hashes and numerical results.
- `receipt-candidates/`: immutable original six algorithm/portability/comparison candidate sets. Reviewed copies were adopted into formal verification with adoption timestamps and independent-review provenance; the originals were not changed.
- `formal-adoption-before-20261104.json`, `formal-adoption-after-20261104.json`: official status, runtime, old evidence, candidate and protected-block preservation checks around authorized adoption. No save/commit was run.

## Public input

`pancreas_sub.rda` is the SCP repository example at commit `b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`:

`https://raw.githubusercontent.com/zhanghao-njmu/SCP/b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0/data/pancreas_sub.rda`

SHA256: `d95f56fc231378ed14e55fafdebfccb6a6bb464a1a9d988f83e7101d92649744`; size: 3,729,904 bytes. This identity matches the historical public fixture. Keep the source repository's license and attribution. Do not substitute a similarly named file.

The primary task actually inspected the R object: 1,000 cells; `RNA`, `spliced` and `unspliced` assays; `PCA` and `UMAP` reductions. `orig.ident` has the single observed value `SeuratProject`. The initial discovery's statement that real spliced/unspliced input was absent was incorrect and has been corrected. RNA velocity's remaining issue is the compatible backend and its incomplete declared closure; velocity plots/grid routines require the actual computed result.

## Run after environment restoration

The main task owns dependencies and execution. Wait until all installation batches have stopped mutating the dedicated R library. `--environment-restored` is an explicit operator assertion of that condition; the tool does not inspect or repair installation state.

Use explicit paths in PowerShell. `$vault`, `$dev`, `$envRoot` and `$audit` are task variables; no system environment variables are repurposed.

```powershell
$vault = (Resolve-Path '.').Path  # Run from the knowledge repository root.
$dev = Join-Path (Split-Path $vault -Parent) 'jjd-wiki-dev'
$envRoot = Join-Path (Split-Path $vault -Parent) 'research-wiki-env'
$audit = Join-Path $vault '维护记录/2026-11-03-待运行代码审查/method-replay'
$python = Join-Path $envRoot 'wiki-python/Scripts/python.exe'
$rscript = Join-Path $envRoot 'R-4.5.0/bin/x64/Rscript.exe'
$rLibs = Join-Path $envRoot 'R-lib-4.5-3.21'
$fixture = Join-Path $envRoot 'public-data/pancreas_sub.rda'
$runRoot = Join-Path $envRoot 'method-runs'
New-Item -ItemType Directory -Force -Path $runRoot | Out-Null

& $python -B -X utf8 "$audit/discover.py" --vault $vault --dev $dev --public-data "$envRoot/public-data" --out "$audit/replay-map.json"
& $python -B -X utf8 "$audit/test_replay.py"

& $python -B -X utf8 "$audit/replay.py" --vault $vault --dev $dev --method cell-quality-control --implementation scp-runcellqc --fixture $fixture --run-root $runRoot --rscript $rscript --r-libs $rLibs --environment-restored
```

To run all reviewed candidates sequentially after restoration, without changing parameters:

```powershell
$mapping = Get-Content -LiteralPath "$audit/replay-map.json" -Raw | ConvertFrom-Json
foreach ($branch in $mapping.implementations) {
    if ($null -eq $branch.driver) { continue }
    & $python -B -X utf8 "$audit/replay.py" --vault $vault --dev $dev --method $branch.method --implementation $branch.implementation --fixture $fixture --run-root $runRoot --rscript $rscript --r-libs $rLibs --reticulate-python "$envRoot/scp-legacy/python.exe" --environment-restored
}
```

The same command can target `--method rna-velocity --implementation scp-scvelo` once the compatible Python environment is ready. It reuses the historical first 80 real cells, observed identifiers, seed 11, `assay_X=RNA`, real `spliced/unspliced` assays, `CellType` and `PCA`; it does not invent a batch, pseudotime or velocity field. `SCP_TEST_RENAME` remains disabled because no evidence supports renaming observed barcodes. The actual full returned Seurat object is saved for subsequent velocity plotting/grid cases.

The current `velocity_native.R` still uses `system.file('python', package='SCP', mustWork=TRUE)` to locate `SCP_analysis`. Its `runtime.json` omits that Python backend. The prepared driver does not patch this scientific source, redirect package paths, or install SCP; it records the precise failure if the backend cannot be resolved. Even a successful call through an installed SCP package does not establish standalone portability. The primary task must audit the pinned Python closure and explicitly declare/bridge its local path before granting independent runtime validation.

Each call leaves a unique external directory containing copied bytes, `case.json`, actual `argv`, complete logs, package versions, outputs, and `execution-audit.json`. No result is written to method pages or historical receipts. A failed call leaves its exact error and `not_run`; investigate before retrying. Do not modify or overwrite a prior run directory.

## Evidence limits and promotion

`execution_state=executed` requires a zero child exit code, actual invocation, a nonempty method result or rendered plot, object input preservation, and unchanged original source/input files. An import, source, package presence or zero exit alone cannot pass. Figures require separate visual review; it is recorded as pending.

The R execution-only `replay.py` always emits `algorithm_verification_state=not_run`; it does not perform a new independent original-versus-wrapper comparison. Those execution-only audits must **not** be copied into `verification/` as `passed`. The separate `public_python_replay.py` has now actually performed such comparisons for six approved public cases; its results and review-only receipt candidates are documented in `public-python-results.md`. The primary task must review the exact scope, source comparison, hashes and visual checks before any formal adoption. Original source code must not be supplied to the isolated production call. Full current `code/` hash coverage may be larger than the selected runtime closure and is bound separately from the actually copied closure.

## Blockers that cannot be resolved by package installation

- Historical batch-integration assigns `A/B` by row position; use observed batch labels only after an explicit case is selected.
- `fixture_time` from ranked PCA is not an actual trajectory. Do not invent pseudotime to rerun dynamic analysis.
- The custom ORA test used hand-built T1/T2 gene sets; select a legitimate gene-set input and universe before a scientific rerun.
- Monocle is **author-deferred** until the author specifies a biological root group. Historical core tests used `seq_len` matrices; adapter tests chose state 1 / the first cell. Do not run those synthetic/arbitrary-root cases as a substitute or silently choose a biological root or partition policy.
- SHAP, regression summary and SCP table-adapter historical tests are numerical/schema contracts using artificial rows. Keep that scope separate from real-data validation.
- Missing `CellCorHeatmap`, `PAGAPlot` and `compute_velocity_on_grid` pointers are not passed branches. Select a real case and give it a declared independent closure/evidence path through the primary task.
- Old local-omics validators (`validate_r.R`, `validate_graphics.R`, `validate_python_portable.py`, `validate_dynamic.R`, `validate_seurat.R`, `validate_spatial.R`, `validate_runner.py`), portable configuration JSONs and runner probe live under the old external `$OLD_ENV/work/rwiki/local-omics-reuse-20261102*` cache. Exact command suffixes are retained in the mapping. No such cache is silently reconstructed.
- Private `monocle.Rdata`, `processed_samples_final.RData`, `data.train.txt`, `data.test.txt`, models/probabilities/ROC data are not supplied by public pancreas. Their recorded basenames and available SHA256 identities are retained without copying the private data or private project roots. Missing inputs remain `not_run`.
- `slingshot-pancreas-native.rds`, `srt-enrichment.rds`, `srt-gsea.rds`, `graph-real-neighbours.rds` and `pancreas-de.rds` are derived artifacts from the old external cache. Their generators and exact arguments must be restored/audited; do not manufacture substitute tool slots.
- RNA velocity's real spliced/unspliced measurements are present in public pancreas. It needs a compatible Python environment and resolution of the undeclared SCP Python backend. `VelocityPlot` and `compute_velocity_on_grid` must consume a genuine computed result. Native plotting/CellChat/GSVA/irGSEA cases still require their explicit data, database, model or parameter selections.
- The author-approved public breast-cancer fit has completed all five evaluation functions and ROC rendering with exact reference comparisons; see `public-python-results.md`. It cannot restore or replace the private UC/asthma validation case. Already passed calls were not repeated during continuation.

## Verification performed for this tooling

Eight orchestration tests passed using the dedicated Wiki Python: unsafe path rejection, invalid closure rejection, zero-exit guard, mutation/nonzero-exit guard, excluded artificial cases, plot-token restriction, inventory coverage, and the corrected real velocity input classification. All replay-tool Python files compiled from source. `driver.R` parsed successfully using base R only. Windows R inherited an unsupported `C.UTF-8` locale on the initial parse attempt; the successful parse used `English_United States.utf8`, which the runner now sets for its Windows child. No package-heavy R method was executed while installation was active. Actual Python branch evidence is separate from these orchestration checks.
