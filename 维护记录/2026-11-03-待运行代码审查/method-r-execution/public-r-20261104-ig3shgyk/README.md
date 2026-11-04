# Public pancreas R execution audit, 2026-11-04

Completed: 20; executed: 17; not_run: 3; algorithm verified: 0.

Each case used the recorded parameters, an isolated runtime closure, the pinned public pancreas fixture, and a fresh R process. No packages were installed during this batch. Original source, runtime and fixture copies match after execution. Original receipts and Wiki pages were not modified.

These are execution audits only. No independent original-source comparison was performed. Plot visual review remains pending. Existing reference-map cases reuse subsets of the same public fixture and do not establish external generalization.

| Method | Implementation | Execution | Seconds | Error |
|---|---|---|---:|---|
| cell-quality-control | scp-runcellqc | executed | 21.64 |  |
| cell-type-annotation | scp-singler | not_run | 45.5 | there is no package called 'scrapper' |
| differential-expression | scp-detest | executed | 76.45 |  |
| dimensionality-reduction | scp-dimreduction | executed | 23.42 |  |
| doublet-detection | scp-rundoublet | not_run | 34.08 | Historical invocation did not complete: unused argument (seed = 11) |
| gene-set-scoring | scp-cellscoring | executed | 21.2 |  |
| reference-mapping | seurat-label-transfer | executed | 26.42 |  |
| reference-mapping | scp-runseuratmap | not_run | 23.72 | Historical invocation did not complete: Argument 'dim.' must be an integer vector of length two |
| scp-viz-dimplots | scp-celldensityplot | executed | 27.39 |  |
| scp-viz-dimplots | scp-celldimplot | executed | 27.72 |  |
| scp-viz-dimplots | scp-celldimplot3d | executed | 15.19 |  |
| scp-viz-dimplots | scp-featuredimplot | executed | 55.11 |  |
| scp-viz-dimplots | scp-featuredimplot3d | executed | 15.12 |  |
| scp-viz-heatmaps | scp-featureheatmap | executed | 23.58 |  |
| scp-viz-heatmaps | scp-groupheatmap | executed | 26.94 |  |
| scp-viz-model-overlays | scp-projectionplot | executed | 16.27 |  |
| scp-viz-statplots | scp-cellstatplot | executed | 49.11 |  |
| scp-viz-statplots | scp-featurecorplot | executed | 17.91 |  |
| scp-viz-statplots | scp-featurestatplot | executed | 53.78 |  |
| trajectory-inference | scp-slingshot | executed | 35.22 |  |

Full sanitized receipts, package versions and log tails are in the numbered JSON files. Raw logs, results and exact process arguments remain in the external batch directory recorded in collected-summary.json.

The first SingleR failure exposed the replay orchestrator's assumption that R `checks` is always a JSON object. R emitted an empty array on failure. Its original failure evidence is preserved and separately recovered from child/result sidecars; it was not rerun in this batch.
