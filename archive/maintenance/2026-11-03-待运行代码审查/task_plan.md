# Pending execution audit plan

## Scope

Audit the knowledge repository, reproduce declared pending implementations with authorized environments and lawful inputs, make focused fixes, preserve original source bytes and historical receipts, and commit/push reviewed changes to GitHub.

## Phases

1. Repository and environment inventory — complete.
2. Confirm environment, input scope, dependency batches, and execution scope with the author — complete.
3. Reproduce pending branches and make focused repairs — in_progress.
4. Record current evidence, rebuild Wiki metadata, and verify software and UI — in_progress.
5. Review diffs, run protected-content and push guards, commit, and push — pending.

## Constraints

- Do not modify source/ originals, gallery originals, author blocks, or historical receipts.
- Do not install scientific packages or choose new data semantics before author confirmation.
- Do not infer scientific validation from imports, package presence, software tests, or synthetic fixtures.
- Keep private inputs, credentials, environments, and temporary outputs outside Git.
- The current machine has no E: drive; the author-approved sibling environment root holds temporary files and caches.

## Author-confirmed decisions

- Prepare separate R 4.5.x and dedicated Wiki environments; restore migration dependency profiles.
- Use repository examples and lawfully available public inputs; retain not_run for missing private inputs.
- Rerun every recipe, template, and declared method implementation, not just the historical 34 pending branches.
- Machine-local environments, downloads, caches and reports are placed in the sibling research-wiki-env directory on D:, since E: does not exist.

## Errors encountered

- R startup locale warnings were caused by inherited C.UTF-8 locale variables; a child-only English UTF-8 locale successfully starts R 4.5.0.
- Initial Git HTTPS failures were transient; the current remote main reference was subsequently readable using the authenticated account.
- Rtools45 installer reached Windows UAC without a visible prompt. The official portable toolchain was prepared instead; a real GCC DLL compilation passed.

## Current execution checkpoint (2026-11-04)

- All 30 templates produced fresh PNG/PDF/SVG outputs in isolated copies and their current receipts were adopted while preserving old receipts. Seven display fixes passed independent PNG/PDF review; readability warnings remain documented.
- All 30 recipes were attempted: 29 passed and recipe 293 remains author-deferred because its fixed upstream data archive is truncated. Nine repaired/compatibility cases also have fresh formal as-is receipts; every pre-existing receipt is retained.
- All 43 method pages / 85 declarations have an explicit coverage classification. The first public R batch now has 19 successful branches out of 20; the remaining reference object lacks PCA feature loadings. Additional safe public thin-call cases are being checked.
- Six approved public Python cases passed original-versus-extracted comparison and separate-process checks. Independent review passed; formal adoption preserves runtime bytes and historical receipts.
- RNA velocity completed genuine public spliced/unspliced inference and returned the full 80-cell Seurat result using the approved isolated NumPy 1.23.5 clone, explicit existing PCA basis and a conversion-boundary compatibility repair. Formal evidence binding is in progress; this is not a claim of full historical numerical equivalence.
- Four Monocle branches remain author_deferred. Missing private cases and missing scientific choices remain not_run.
- Author confirmed: retain recipe 293 as not_run; independent dplyr 1.1.4 / GSVA 1.48.3 profiles; isolated NumPy 1.23.5 clone. These compatibility runs completed. Reference-mapping treatment is awaiting the author's choice; no PCA refitting is performed meanwhile.
- The dev CLI fix is locally committed as 4d15b1e. All six installed skill copies were freshly deployed and hash-verified; no stale installed file was removed. GitHub task creation encountered transient network failures and is being retried.
- Machine migration and CLI lint caching fixes have focused regression coverage. The dependency-catalog hash check is expected to remain stale until final declarations are exported again.
