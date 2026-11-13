# Final incremental review

**Verdict: APPROVE, with the display and execution-scope limitations below. No actionable regression was found in the reviewed code changes.**

## Scope and integrity

Reviewed the seven display corrections, all 30 adopted template receipts, the SingleR metadata-alignment change and the RNA-velocity conversion change. Only this final-review directory was written during this review. No scientific method was rerun.

- All 30 current template input sets match their selected replay reports; all 90 PNG/PDF/SVG output hashes match. Every new receipt matches the adoption ledger.
- All 30 pre-change HEAD receipts are retained byte-for-byte by hash in verify/history. The seven-template protected baseline has 79 unchanged files and 38 expected display/adoption changes, with no unexpected changes.
- Original CSV tables, source assets, acceptance records and method verification JSON files were preserved. The dot template changes only its default/example y-axis title, in addition to the approved plotting-code changes.
- Public function signatures and custom xlab/ylab getters remain intact; the dot title is not forcibly overwritten.

## Seven display corrections

| Template | Review result | Evidence |
|---|---|---|
| `2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap` | Outer coordinate-label clipping closed in PNG/PDF. Warning: Point clouds remain very pale in PNG; PDF is more legible. This is retained as a display limitation. | [display-final-01.jpg](display-final-01.jpg) |
| `2026-10-22-scp-example__fig02-ring--ring` | Small/zero percentage labels at the ring top are now separated and readable. | [display-final-02.jpg](display-final-02.jpg) |
| `2026-10-22-scp-example__fig04-rose--rose` | Both outer category labels are complete. Center values are displaced by repel without changing their values. Warning: The origin remains visually dense with leader lines; PNG/PDF have different repel positions. | [display-final-03.jpg](display-final-03.jpg) |
| `2026-10-22-scp-example__fig05-trend--trend` | Zero-count labels are inside the expanded numeric frame rather than cut by its lower border. | [display-final-04.jpg](display-final-04.jpg) |
| `2026-10-22-scp-example__fig06-area--area` | First/last percentage labels and baseline small/zero labels are visible; data and percentages unchanged. | [display-final-05.jpg](display-final-05.jpg) |
| `2026-10-22-scp-example__fig07-dot--dot` | Default/example categorical vertical-axis title is Phase; percentage remains encoded by dot size. Custom ylab getter remains unchanged. | [display-final-06.jpg](display-final-06.jpg) |
| `2026-10-22-scp-example__fig09-bar--bar` | Zero-count labels no longer cross the lower frame border. | [display-final-07.jpg](display-final-07.jpg) |

The 23 other templates retain the prior pass2 visual assessment. The original dense gene-label warnings for the unchanged volcano outputs are preserved. No claim of universally publication-ready figures is made.

## SingleR metadata correction

The two changes remove label-derived names from the already-computed score vectors. Numeric scores, cell order, SingleR parameters and function signatures are unchanged. The cluster expression retains its existing cell-order indexing before unname.

Independent read-only inspection of result.rds and direct-SingleR.rds confirmed 100 cells, identical cell order, identical labels, identical unname-aligned numeric scores and two pruned cells. The reviewed driver and execution report use 300 reference cells and SerialParam. The full unmodified SCP wrapper was not used as a comparator because its deprecated Seurat API fails; direct SingleR and the unchanged upstream score expression are the explicitly stated comparator. The cluster branch was not separately executed by this review.

## RNA-velocity conversion correction

The sole executable change wraps the existing counts matrix in an explicit legacy Assay before CreateSeuratObject. No velocity calculation, preprocessing threshold, inference parameter or display basis is silently changed by the code patch. The reviewed real execution explicitly selects the existing PCA basis and uses the prepared NumPy 1.23.5 environment.

Independent read-only result inspection confirmed 80 cells and nonempty finite stochastic, variance_stochastic, velocity and variance_velocity assays. The executed module matches current code by hash. The separate successful v3-option conversion used a module byte-identical to the old HEAD conversion code, supporting the compatibility rationale.

This establishes actual execution in the reviewed environment. It does not establish full independent original-versus-wrapper velocity equivalence, universal backend portability or a closed standalone Python backend. The installed SCP backend dependency and explicit PCA-basis limitation remain recorded.

## Review artifacts and limitations

- `template-integrity.json`: all 30 template input/output, new receipt and old receipt checks, with replay selections.
- `method-integrity.json`: copied/current code agreement, old verification-file preservation, execution-report hashes and old v3-conversion agreement.
- `review.json`: structured review decision and seven per-template visual findings.
- `display-final-01.jpg` through `display-final-07.jpg`: newly rendered comparisons of the actual adopted PNG/PDF outputs, not intermediate outputs.

Saved RDS objects were inspected without rerunning inference or writing the objects. Package-built-under-newer-R and locale warnings occurred during this read-only inspection; all explicit equality and finiteness assertions passed. SVG files were verified by hash but were not separately rendered. This review does not validate biological conclusions or statistical applicability.
