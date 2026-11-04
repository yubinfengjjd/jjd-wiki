# Approved public Python software case

Status: the author approved the bounded fit and public software scope; **all five evaluation branches and ROC rendering actually passed on 2026-11-03**. The 2026-11-04 continuation verified the existing evidence and unchanged code rather than rerunning passed calls. See `public-python-evidence/summary.json` and `public-python-results.md`.

The installed ML Python includes `sklearn/datasets/data/breast_cancer.csv` (120,483 bytes). Scikit-learn's official [`load_breast_cancer` documentation](https://scikit-learn.org/stable/modules/generated/sklearn.datasets.load_breast_cancer.html) describes 569 real samples with 30 numeric features and target names `malignant`, `benign`. The library's existing encoding is 0=malignant and 1=benign. Retaining that encoding makes benign the explicit positive class; do not silently invert labels or probabilities to improve a result.

Read-only local inspection confirmed 569 data rows, 31 fields per row (30 features and one observed target), header `569,30,malignant,benign`, and targets `{0,1}`. Bundled CSV SHA256: `ff5fc1f247213db5fd49539610bcd5a98033bbd0307524fde3127251752aa073`. This inspection used Python's standard CSV reader and did not fit a model or import sklearn.

The data contain observed features and outcomes, not saved predictions. `get_proba`, `eval_binary`, `compute_specificity`, `youden_threshold` and `bootstrap_ci_auc` cannot all be exercised with meaningful probabilities without either a lawful existing model/prediction artifact or a new bounded fit. Passing the target itself as a perfect prediction would manufacture prediction evidence and is excluded.

Case identifier: `breast-cancer-public-software-case`. Its purpose is original/extracted function equality, input preservation, and isolated copied-closure invocation. It does not reproduce the private UC model, the stacking workflow, or a clinical validation study.

Approved choices actually executed:

1. Load the bundled dataset offline, preserve feature order and its existing label encoding, record sklearn/data-file versions and hashes.
2. One stratified `train_test_split(test_size=0.25, random_state=11)`. Persist original row indices so samples cannot be accidentally interchanged.
3. Fit `StandardScaler` on training features only, followed by `LogisticRegression(max_iter=2000, random_state=11)` with other sklearn defaults recorded. This supplies actual fitted-model probabilities for a software test; it is new bounded training, not an added library implementation.
4. Use the original `get_proba` definition on the fitted pipeline. Evaluate held-out predictions at fixed threshold 0.5 using the unchanged functions. Exercise `youden_threshold` only on training probabilities, and report it as a training-derived software output rather than a held-out performance optimization. Keep bootstrap defaults `n_boot=1000, seed=42` from the original function.
5. Build an original reference by AST-selecting the five original function definitions from the preserved `stacking_original.py`, choosing the last top-level occurrence for duplicated names exactly as normal Python definition semantics do. Load only the exact required imports; never execute unrelated top-level I/O, installation or training from the full original file. Record source/function AST hashes and compare original versus extracted ASTs before execution.
6. Save baseline expected outputs, frozen input arrays/model and dataset-row identities outside the repositories. Then start a separate process containing only declared runtime closure files and the real inputs. The production process receives no original-source code directory.
7. Assert exact original/extracted numerical equality under the same actual package versions, sample order and unchanged input/model; write individual evidence for each called implementation. Do not grant a family-wide pass, promote the missing private case, or imply unbiased generalization from this test.

The author also approved the separate `py-roc-render` public case. It consumed precomputed training and held-out ROC arrays and passed exact original/native visual-body versus extracted RGBA/PNG and line-data comparisons. The plot was visually inspected. No additional model or private cohort was introduced.
