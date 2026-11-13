# Completed public breast-cancer software case

All six requested branches actually passed at `2026-11-03T11:46:57Z`. Continuation checked saved results, current source hashes, fitted-model metadata and documentation without repeating training or passed calls. Subsequently, after independent `migration_spec_review` PASS, the primary agent authorized formal adoption: six algorithm pointers and eighteen new verification files were added. Runtime bytes, default portability pointers, old evidence, protected blocks, candidates and all 79 non-target official statuses remained unchanged. No save, commit or push was run.

## Approved input and model

The offline bundled `breast_cancer.csv` contains 569 real samples and 30 features, with SHA256 `ff5fc1f247213db5fd49539610bcd5a98033bbd0307524fde3127251752aa073`. Existing encoding is preserved: 0=malignant, 1=benign, so **benign is the positive class** throughout. No labels or probabilities were reversed.

A stratified seed-11 split produced 426 training samples (159 malignant, 267 benign) and 143 held-out samples (53 malignant, 90 benign), with disjoint indices covering all 569 samples. `StandardScaler` was fitted only on training data; its stored means equal the training-column means exactly. The fitted `LogisticRegression(max_iter=2000, random_state=11)` used 16 iterations. Full resolved model parameters, feature order and unchanged model-object hashes are in `public-python-evidence/fit-audit.json`.

Python was 3.12.7; numpy 2.5.4, scipy 1.18.1, scikit-learn 1.9.1, matplotlib 3.11.2 and joblib 1.6.0. No package was installed by the replay. Production plotting workers used `MPLBACKEND=Agg`.

## Actual calls and comparisons

| Implementation | Actual input/case | Actual result | Original/extracted comparison |
|---|---|---|---|
| `py-eval-binary` | 143 held-out labels/probabilities, fixed threshold 0.5 | AUC 0.9888888888888889; accuracy 0.958041958041958; confusion matrix `[[48,5],[1,89]]` | Entire returned dictionary exactly equal |
| `py-compute-specificity` | Same held-out labels and fixed-threshold predictions | 0.9056603773584735 | Exactly equal |
| `py-youden-threshold` | **Training probabilities only** | Threshold 0.5925652573029451; J 0.9836760652957388 | Exactly equal; not applied as a held-out threshold |
| `py-bootstrap-ci-auc` | Held-out labels/probabilities; original defaults `n_boot=1000, seed=42` | `[0.9720877498286136, 0.9995700788045702]` | Both limits exactly equal |
| `py-get-proba` | The fitted pipeline and 143 held-out feature rows | 143 positive-class probabilities | Array exactly equal; dtype/shape/value hash `2512f6d83b2506bb85cbc9ee35b6a9ddcbe2d33b4efcb7f68dff514905ec4355` |
| `py-roc-render` | Fixed precomputed training/held-out curves and AUCs | Inspected PNG/PDF, two axes | Curve data, native helper AST, RGBA pixels and PNG bytes exactly equal |

These numbers document a bounded software test with one approved public split/model. They do not reproduce UC/asthma private-project results, a full stacking workflow, or a clinical validation claim. Training AUC is 0.999104892469319; it is displayed as training, not an independent cohort. The bootstrap interval is the unchanged source function's fixed-model resampling output, not uncertainty over model training.

The five original functions were selected by AST from preserved `stacking_original.py`, using the last top-level definition for duplicate names. Their ASTs are identical to the extracted functions. The reference process executed only those functions and required imports; unrelated source training, I/O and installation were not executed.

The ROC reference used the original `style_axes`, `draw_auc_strip`, figure/line/label/legend/layout statements from source `d421312f0c2a8f10c25837c95ecf085235d036db2d200dab5b4e8e32a8793fe0.py`. It consumed explicit precomputed curves; source label inference, fitting and score-orientation inversion were excluded from this visual-body comparison, as required by the extracted renderer's contract. Both versions emit the same native `tight_layout` warning; the actual image was inspected and remains readable without clipped title, labels, legend or AUC strip.

## Evidence and review boundary

`public-python-evidence/` contains six separate `audit.json`, `comparison.json` and `result.json` sets, actual plot outputs, source AST provenance, post-run identity checks and fitted-model metadata. Complete unredacted commands, frozen arrays/model and worker logs remain in the external run directory:

`<ENV_ROOT>/public-python-runs/breast-cancer-public-software-case-fifca7no/`

Sanitized archived commands preserve actual argv structure with explicit `<ML_PYTHON>` and `<RUN_ROOT>` substitutions. Original raw external receipt/output hashes and sanitized archived data have different roles; do not reinterpret a redacted JSON's bytes as the raw execution output bytes.

Frozen inputs SHA256: `45f272351ec015a066dd475f5be7cc8025c5791555dd3bc690cd106ca22ac7e5`.

Fitted-model file SHA256: `e056c5af17ef14ed0fd510725256d9561ade6cb3f0436e0c8fa9da34339e73a8`.

Each isolated process received only its runtime-declared closure and frozen public inputs/model; no original-source directory was supplied to it. In-memory arrays/model fingerprints, input/model/code-file hashes, original code trees and output hashes were checked. Additional read-only identity checks verified that isolated input/model bytes equal the reference bytes. A prior driver-startup attempt stopped before fitting because current sklearn reports `dataset.filename` as a basename; resolving the bundled resource with `importlib.resources` fixed only orchestration. The source algorithms were not changed.

`receipt-candidates/` preserves six original algorithm/portability/comparison candidate sets. Raw audits were not installed unchanged: they have an audit-specific kind, argv arrays, check mappings and no closure hash. Candidates use the accepted kind/string/list structure, bind all current `code/` files, list the copied closure separately, and use the official `runtime_contract.closure_hash`. Their historical index still records the pre-adoption `not_run` pointer check and was deliberately preserved. Authorized formal copies now carry `promotion=adopted`, an adoption timestamp and independent-review provenance. Official parsing verifies all six new algorithm pointers and all six supplemental portability receipts; default runtime facts are unchanged. See `formal-adoption-after-20261104.json`. Old private-case receipts remain preserved; final save/commit belongs to the primary agent.

Monocle 2/3 adapters and cores remain **author_deferred** until a biological root group is specified. SHAP has no current runtime manifest, a full stacking CLI is outside this bounded case, and classification probabilities were not presented as regression evidence.

## Reproduction entrypoint

No rerun is required for the completed case. For a deliberately new reproducibility run, use the approved driver with explicit paths and a unique external directory:

```powershell
& '<ENV_ROOT>/ml-python/Scripts/python.exe' -B -X utf8 '<VAULT>/维护记录/2026-11-03-待运行代码审查/method-replay/public_python_replay.py' --vault '<VAULT>' --run-root '<ENV_ROOT>/public-python-runs' --approved-public-case
```

The coordinator performs one approved fit, creates original reference processes and six separate copied-closure workers, and retains every run directory. It does not promote receipts, install packages or modify Wiki sources.
