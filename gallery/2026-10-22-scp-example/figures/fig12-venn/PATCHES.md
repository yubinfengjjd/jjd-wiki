# Compatibility patches — SCP v0.5.6 venn branch

Upstream: SCP v0.5.6, <https://github.com/zhanghao-njmu/scp>, commit
`b9b0eb7a7bf2c2c4b2262e73e09d7ebd515c7da0`, `R/SCP-plot.R`, GPL (>= 3).
`CellStatPlot()` 4463–4490; `StatPlot()` 4564–5159; venn branch 4960–5043.

The same patched core (`code/scp_venn_native.R`) produced `source/fig12.png`,
`output/replica.png` and the template's fixed output. No plotting layer,
colour, label, theme, scale or geometry source was replaced by a custom
ggplot rewrite.

---

## Patch 1 — `check_R()` replaced by `requireNamespace()`

**Upstream (line 4982):**

```r
check_R(c("ggVennDiagram", "sf"))
```

**Reason:** `check_R()` (`R/utils.R`) installs missing packages into
`.libPaths()[1]`. A gallery/template render must not install or modify the R
environment.

**Replacement (in `scp_venn_table()`):**

```r
if (!requireNamespace("ggVennDiagram", quietly = TRUE)) {
  stop("Package 'ggVennDiagram' is required", call. = FALSE)
}
if (!requireNamespace("sf", quietly = TRUE)) stop("Package 'sf' is required", call. = FALSE)
```

**Proof geometry/data unchanged:** package availability is the only behaviour
difference; the Venn construction and all plot lines are unchanged. This patch
never runs when both packages are installed.

---

## Patch 2 — rebuild sf geometry for ggVennDiagram >= 1.4

**Upstream (lines 4981–5043, excerpts):**

```r
dat_venn_region <- ggVennDiagram::venn_region(data)
...
dat_venn_setedge <- ggVennDiagram::venn_setedge(data)
...
dat_title <- as.data.frame(do.call(rbind, dat_venn_setlabel$geometry))
...
dat_stat <- as.data.frame(do.call(rbind, lapply(dat_venn_region$geometry, function(x) sf::st_centroid(x))))
...
p <- ggplot() +
  geom_sf(data = dat_venn_region, aes(fill = colors), alpha = alpha) +
  geom_sf(data = dat_venn_setedge, aes(color = colors), size = 1) +
  ...
```

**Reason:** ggVennDiagram 1.4 removed the `sf` dependency; `VennPlotData` now
stores shape coordinates in ordinary data frames (`NEWS.md`: "remove the
dependency of `sf`... `VennPlotData` now store shape and datasets in ordinary
data.frames"). With 1.5.7, `venn_region()` returns only `id`, `name`, `item`,
`count`; `$geometry` is `NULL`, so the upstream `geom_sf()` layers fail. This
is a package API break, not an SCP plotting choice.

**Replacement:** reconstruct sf objects from the package's own shape
coordinates and keep every downstream line (both `geom_sf()` layers,
`geom_text_repel()` calls, `scale_*_identity()`, theme, `labs()`):

- `scp_venn_region_sf(venn_data, regions)`: one `POLYGON` per region from
  `venn_data$regionEdge` (split by `id`; multiple closed rings become a
  `MULTIPOLYGON`). Attribute table is the upstream region table including
  `colors` and `label`.
- `scp_venn_setedge_sf(venn_data, colors)`: one `LINESTRING` per set from
  `venn_data$setEdge`, plus `name` (Patch 3) and the same
  `colors[name]` lookup.
- `scp_venn_setlabel_sf(venn_data)`: `POINT` geometry from the package's
  `X`/`Y` label coordinates, so the upstream
  `do.call(rbind, dat_venn_setlabel$geometry)` line is preserved.

**Proof that geometry/data are unchanged:**

1. For all 15 regions of the representative call, `sf::st_centroid()` of the
   reconstructed polygons equals `venn_region()`'s own label coordinates
   exactly (max |Δx| = 0, max |Δy| = 0; checked in `src/check_table.R` run).
   This is the strongest available check that the reconstructed polygons are
   the same shapes the package uses for labels.
2. The region table (`id`, `name`, `item`, `count`, `colors`, `label`) is
   `identical()` to the upstream intermediate produced by the verbatim lines
   4961 and 4981–5001.
3. Visual comparison against `man/figures/Example-2.jpg` panel 8: same four
   ellipses, same orientation, same 15 region counts (512/411/77 and 0s), same
   set labels and sizes (488/512/923/77), same Paired colours.
4. `source/fig12.png` and `output/replica.png` are byte-identical
   (SHA256 `a5bf19955f2efc74b28c1133945c886cf8f8370ce179fb2582f530c6d96b6119`).

**Residual risk:** the reconstruction was not run against ggVennDiagram
1.2.x, where the original geometry objects were produced by sf polygon
intersection. The coordinate/centroid equality above makes a geometric
difference in the plotted shapes very unlikely, but it is not a byte-level
cross-version comparison. Recorded as a limitation.

---

## Patch 3 — restore `name` on `venn_setedge()` output

**Upstream (line 5003):**

```r
dat_venn_setedge[["colors"]] <- colors[dat_venn_setedge[["name"]]]
```

**Reason:** ggVennDiagram 1.5.7 `venn_setedge()` returns only `id`, `X`, `Y`.
`dat_venn_setedge[["name"]]` is `NULL`; `colors[NULL]` is `NULL`; assigning
`NULL` removes the column, and the later `geom_sf(..., aes(color = colors))`
fails. The brief's compatibility note correctly identifies this.

**Replacement (inside `scp_venn_setedge_sf()`):**

```r
setlabel <- as.data.frame(ggVennDiagram::venn_setlabel(venn_data), stringsAsFactors = FALSE)
ids <- unique(edge$id)
name <- setlabel$name[match(ids, setlabel$id)]
```

then the upstream lookup `out[["colors"]] <- colors[out[["name"]]]` is applied
unchanged to the one-row-per-set edge table.

**Proof geometry/data unchanged:** `id → name` comes from `venn_setlabel()`,
the same mapping the upstream line intended (`venn_region` names are identical
to `stat.by`); the four edges are Ductal/Endocrine/G1S/G2M and receive the same
four `palette_scp(stat.by, "Paired")` colours used by the region blends. No
coordinate is modified.

---

## Not patched (intentionally)

- `geom_sf(..., size = 1)` triggers ggplot2 3.4+ deprecation advice
  (`linewidth`). It is kept verbatim to preserve the upstream visual mapping;
  changing it would alter the rendering contract.
- `ggrepel` `point.size = NA`, `force = 0`, `max.overlaps = 100` and the
  `set.seed(11)` position are preserved; label positions are part of the
  source image.
- `stat_type` is forcibly set to `"count"` for venn by upstream and the warning
  is kept.
