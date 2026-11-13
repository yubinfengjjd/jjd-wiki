# Template visual QA: pass 2

Reviewed 30 template outputs (60 visible renderings: PNG plus PDF rasterization). All 90 PNG/PDF/SVG hashes match the two replay2 reports. No empty plots were found. Results: 21 pass, 5 warning, 4 fail.

This is presentation QA of isolated public examples. It does not validate scientific conclusions, statistical calculations or biological interpretation. Sources, input tables, original replay outputs and receipts were not changed. SVG was checked by hash only.

## Required presentation corrections

- Case 07: clipped outer coordinate labels and very low point contrast in the feature-UMAP grid.
- Case 14: clipped polar category names and overlapping central values in the rose plot.
- Case 16: clipped edge and baseline percentage annotations in the area plot.
- Case 17: categorical phase axis mislabeled as Percentage in the dot plot.

## Per-template visual record

| # | Template ID | Result | Contact sheet | Observations |
|---|---|---|---|---|
| 01 | `2026-08-17-shap-feature-mechanism__fig01-shap-a-f--bar` | PASS | [contact-01.jpg](contact-01.jpg) | Horizontal bars, values, feature labels and color scale are complete; inverted numeric direction is displayed explicitly. |
| 02 | `2026-08-17-shap-feature-mechanism__fig01-shap-a-f--beeswarm` | PASS | [contact-01.jpg](contact-01.jpg) | Beeswarm marks, zero reference, feature labels and feature-value color scale are visible without clipping. |
| 03 | `2026-08-17-shap-feature-mechanism__fig01-shap-a-f--radial-bar` | PASS | [contact-01.jpg](contact-01.jpg) | Radial bars, outer feature labels and inner color scale are complete; small labels require the full-size export. |
| 04 | `2026-10-19-regression-stability__fig03-density-panel--density-scatter` | PASS | [contact-02.jpg](contact-02.jpg) | Scatter, both marginal histograms, reference/fit lines and numeric color scale are visible. Metric annotations are example content and were not recomputed. |
| 05 | `2026-10-19-regression-stability__fig04-boxplot-panel--boxplot` | PASS | [contact-02.jpg](contact-02.jpg) | All six boxes, individual points, mean diamonds and model labels are visible; no obvious clipping. |
| 06 | `2026-10-22-glaucoma-scrna__fig01-cns-umap--umap` | PASS | [contact-02.jpg](contact-02.jpg) | UMAP point groups, region labels, coordinate arrows and legend are present; no obvious clipping. |
| 07 | `2026-10-22-glaucoma-scrna__fig02-marker-feature-umap--umap` | FAIL | [contact-03.jpg](contact-03.jpg) | Left-column UMAP_2 text and bottom-row UMAP_1 text touch or cross the image boundary and are clipped. Point clouds have very low contrast in the full-size PNG; the PDF rendering is somewhat stronger. Not an empty plot. |
| 08 | `2026-10-22-glaucoma-scrna__fig03-topjournal-bubble--dotplot` | PASS | [contact-03.jpg](contact-03.jpg) | All marker rows, cell-type columns, continuous color key and size legend are present. Dense text is legible in the full-size export, not at thumbnail scale. |
| 09 | `2026-10-22-glaucoma-scrna__fig04-cell-proportion-flow--stacked-bar-flow` | PASS | [contact-03.jpg](contact-03.jpg) | Both stacked bars, connecting bands, 0..1 proportion scale and cell-type legend are complete. |
| 10 | `2026-10-22-glaucoma-scrna__fig06-pathway-violin--violin` | PASS | [contact-04.jpg](contact-04.jpg) | Nine paired groups, violins, summary annotations, title and legend are present. Statistical annotations were not verified. |
| 11 | `2026-10-22-scp-example__fig01-volcano--volcano` | WARNING | [contact-04.jpg](contact-04.jpg) | Non-empty signed volcano-style plot with readable numeric axes and color key. Several gene labels in the upper-right are crowded, with different repel placement across PNG/PDF. Signed significance-axis semantics were not scientifically validated. |
| 12 | `2026-10-22-scp-example__fig02-ring--ring` | WARNING | [contact-04.jpg](contact-04.jpg) | Concentric proportions and phase legend are present. Small/zero proportion labels overlap near the top of the rings; the merged 0%/100% endpoint label itself is visible. |
| 13 | `2026-10-22-scp-example__fig03-pie--pie` | PASS | [contact-05.jpg](contact-05.jpg) | Concentric pie sectors, categorical labels, endpoint tick and phase legend are complete; no value-label collision because value annotations are not shown. |
| 14 | `2026-10-22-scp-example__fig04-rose--rose` | FAIL | [contact-05.jpg](contact-05.jpg) | Pre-endocrine on the left and Ngn3 low EP on the right are truncated at the polar panel border. Multiple small-count annotations overlap at the center. Confirmed in full-size PNG and PDF contact sheet. |
| 15 | `2026-10-22-scp-example__fig05-trend--trend` | WARNING | [contact-05.jpg](contact-05.jpg) | Trend/stacked counts and phase legend are complete, but zero-count annotations for Pre-endocrine and Endocrine are cut by the bottom panel border. |
| 16 | `2026-10-22-scp-example__fig06-area--area` | FAIL | [contact-06.jpg](contact-06.jpg) | Percentage annotations at the first and final category are clipped horizontally; zero/small annotations also intersect the lower panel border. The chart is populated and the 0..100% axis itself is visible. |
| 17 | `2026-10-22-scp-example__fig07-dot--dot` | FAIL | [contact-06.jpg](contact-06.jpg) | The vertical tick categories are G1/S/G2M but the vertical axis title is Percentage. Percent is already encoded by point size. This is an axis-label mismatch, not a failed numerical calculation. |
| 18 | `2026-10-22-scp-example__fig08-group-heatmap--heatmap` | PASS | [contact-06.jpg](contact-06.jpg) | Both grouped heatmaps, row labels, categorical annotation keys and numeric z-score legend are complete. |
| 19 | `2026-10-22-scp-example__fig09-bar--bar` | WARNING | [contact-07.jpg](contact-07.jpg) | Stacked count bars and phase legend are complete, but zero-count labels at Pre-endocrine/Endocrine are clipped by the lower panel border. |
| 20 | `2026-10-22-scp-example__fig10-sankey--sankey` | PASS | [contact-07.jpg](contact-07.jpg) | Both Sankey sides, connecting flows and both category legends are visible; no clipping or empty bands. |
| 21 | `2026-10-22-scp-example__fig11-chord--chord` | PASS | [contact-07.jpg](contact-07.jpg) | Chord arcs, ribbons, category names and count ticks are visible; no obvious crop. |
| 22 | `2026-10-22-scp-example__fig12-venn--venn` | PASS | [contact-08.jpg](contact-08.jpg) | Four-set Venn sectors, set totals and intersection labels are visible. Set/intersection arithmetic was not revalidated. |
| 23 | `2026-10-22-scp-example__fig13-upset--upset` | PASS | [contact-08.jpg](contact-08.jpg) | Intersection bars, counts, set matrix and category labels are complete and aligned visually. |
| 24 | `2026-10-22-scp-example__fig14-feature-heatmap--heatmap` | PASS | [contact-08.jpg](contact-08.jpg) | Feature heatmap, row labels, cell-type annotation bar, z-score scale and legend are complete. |
| 25 | `2026-10-22-scp-example__fig15-cell-cor-heatmap--heatmap` | PASS | [contact-09.jpg](contact-09.jpg) | Similarity matrix, row/column annotation bars, categorical legend and cosine-similarity color scale are complete. |
| 26 | `2026-10-22-scp-example__fig16-cell-density--ridge` | PASS | [contact-09.jpg](contact-09.jpg) | All eight density ridges, subgroup labels, x-axis and category legend are visible; no empty plot. |
| 27 | `2026-10-22-scp-example__fig17-group-heatmap-dot--heatmap` | PASS | [contact-09.jpg](contact-09.jpg) | Grouped dot heatmap, gene labels, categorical bar, z-score scale and percent-size key are visible. |
| 28 | `figureya-1survivalcurve-update--km-curve` | PASS | [contact-10.jpg](contact-10.jpg) | Survival curves, censor marks, interval bands, legend and all three risk-table rows are complete. Survival estimates, p value and risk-table arithmetic were not revalidated. |
| 29 | `figureya-59volcanov2--volcano` | WARNING | [contact-10.jpg](contact-10.jpg) | Volcano axes, thresholds and pathway labels are visible. Selected-gene labels in the upper-right are crowded and overlap each other/points; use the full-size vector export for review. |
| 30 | `figureya-6rhrsv2--forest` | PASS | [contact-10.jpg](contact-10.jpg) | Forest confidence-interval marks, reference line, subgroup table, HR/CI text, p-value column and direction labels are visible. Numerical/statistical consistency was not revalidated. |

## Evidence and reproducibility

- `output_inventory.json`: output dimensions, non-white occupancy, extracted PDF text, replay-report links and all 90 output hashes. Occupancy is only a blank-image heuristic, not an analysis check.
- `review-pass2.json`: per-template manual review, exact output hash binding and limitations.
- `build_contact_sheets.py`: builds only this directory’s QA products from existing outputs; it does not run analysis or edit source images.
- `contact-01.jpg` through `contact-10.jpg`: labeled PNG/PDF comparisons, three template IDs per sheet.

```powershell
& '<bundled-document-python>' '维护记录/2026-11-03-待运行代码审查/visual-qa/build_contact_sheets.py' --env-root '<external-environment-root>'
```

The pass2 finding is preserved as an audit snapshot. Any corrected replays require a new hash-bound visual check before the presentation failures can be closed.
