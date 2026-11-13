# Confirmed backend compatibility failure and uninstalled candidate

## Actual runs

The unchanged recorded 80-cell case exited 1 after 89.140809 seconds. The same-case diagnostic rerun exited 1 after 55.394459 seconds. Only the maintenance driver's error handling changed for the second run; copied coordinator, algorithm, package, fixture and case parameters were unchanged.

Both runs reached real neighbor, moment and stochastic-velocity calculation, then failed while computing the velocity graph. Neither returned a final Seurat object or wrote `result.rds`. The replay assessment therefore remains `not_run`, with no algorithm-equivalence or standalone-portability verification.

Original source files, manifest, public fixture and copied closure bytes passed post-run preservation checks. The existing driver tests in-memory input-object preservation only after a successful function return; that assertion was not reached and is not claimed to pass.

## Captured failure

The diagnostic rerun captured this complete Python call path:

```text
SCP/python/SCP_analysis.py:167, SCVELO
  scv.tl.velocity_graph(...)
scvelo/tools/velocity_graph.py:363, velocity_graph
  vgraph.compute_cosines(...)
scvelo/tools/velocity_graph.py:175, compute_cosines
  res = parallelize(...)()
scvelo/core/_parallelize.py:138, wrapper
  res = np.array(res) if as_array else res
ValueError: setting an array element with a sequence.
The detected shape was (1, 4) + inhomogeneous part.
```

`diagnostic-context.json` preserves the full Python traceback and symbolic R stack. The complete deparsed R calls include expanded public input objects and remain outside Git; their external file hash and size are recorded. All emitted stdout/stderr messages are archived. The native SCP backend suppresses Python UserWarning, FutureWarning and DeprecationWarning; those filters were not changed, so suppressed warnings are not represented as captured messages.

## Candidate for author review; not installed

The installed profile uses Python 3.8.20, scVelo 0.2.5, NumPy 1.24.4 and Numba 0.58.1. NumPy documents that release 1.24 turns implicit ragged-array creation into a ValueError. This matches the captured failing conversion. See the [official NumPy 1.24 release notes](https://numpy.org/doc/2.3/release/1.24.0-notes.html).

A narrowly scoped candidate is **NumPy 1.23.5**, keeping every other resolved package version, source algorithm, observed cell, fixture and statistical parameter unchanged. This is an explicit compatibility deviation from the original `numpy==1.24.4` profile, not a claim of reproducing its exact environment. No package has been changed by this audit.

Read-only installed-metadata checks show that 1.23.5 satisfies all 16 active NumPy requirement declarations, including Numba 0.58.1's `numpy>=1.22,<1.27`. Exact checks are in `numpy-candidate-metadata.json`. Satisfying package metadata does not prove binary compatibility or successful method execution.

The official [NumPy 1.23.5 PyPI file list](https://pypi.org/project/numpy/1.23.5/) provides `numpy-1.23.5-cp38-cp38-win_amd64.whl`, SHA256 `ca51fcfcc5f9354c45f400059e88bc09215fb71a48d3768fb80e357f3b457e1e`. This permits a binary-only Windows/Python 3.8 candidate without source compilation.

If the author approves the compatibility candidate, preserve the failed-run evidence and original resolved profile, change only NumPy in an isolated backend environment, verify actual versions/imports and `pip check`, then rerun the identical 80-cell case. Remaining downstream failures must be reported as observed. Even a successful execution would still require a separate audit of the undeclared installed SCP Python backend before claiming standalone portability, and a genuine original-versus-wrapper comparison before algorithm verification.
