Closing the batch. First, re-read the latest review checkpoint and check current state:Checkpoint confirms 15/15 pass — no code changes needed. Verifying docs vs actual CLI now:Real CLI/doc mismatches found — fixing the misleading help text (delete→quarantine, scope claims, applies-to required):Now check `project-state.md` vs actual CLI (the review flagged stale flags there):`project-state.md` is already aligned. Checking the SKILL.md universal-CSV sentence and taxonomy v2 aliases:Docs are already aligned (SKILL.md:49 has the native-results sentence, v2 has all requested aliases, project-state.md flags match). Checking `record-run --check`/`--in` flags + AGENTS.md sync state + G3 inventory:Docs synced. Now read the A01–A25/G-matrix definitions for the verification matrix:Now read the G3 inventory docs for honest gap reporting:G3 gap confirmed. Gathering the changed-file inventory and test logs for the reports:Quick check whether `knowledge-linking.md`/`method-families.md`/`minimal-runtime.md` have stale batch-2 claims:All references synced. My CLI help-text edits count as code changes — running affected regressions:All green. Writing the three closing reports now — progress first:Now the verification matrix:Final sanity checks — stray pilot file, doc flag consistency:One gap: `project-reuse.md` doesn't mention `--applies-to` (now required). Fixing:Batch closed. Summary for Codex review:

**This turn's changes**
- `rwiki/cli.py`: `recover` help now states quarantine (not delete), current-state orphan scope, dead-verified lock release; `--applies-to` now argparse-required to match the API contract.
- `tests/test_batch2.py`: assertion updated for the argparse rejection path.
- `references/project-reuse.md`: documents required `--applies-to`.
- Regression after these edits: **`test_cli_project.py + test_batch2.py` → 44 passed, 1 skipped**.

**Verified already-aligned (no edits needed)**
- `project-state.md` flags match real CLI (`--id --claim --evidence --applies-to --link`, `_quarantine`, `project.lock`, `--decision`).
- `SKILL.md:49` keeps native structured results ("不要求每个分析都出 CSV").
- `scenario_taxonomy.v2.proposed.yaml` contains all requested Chinese aliases （计算机药物设计， 蛋白组学， 代谢组学， 网络药理毒理学， 网络毒理学， 网络毒理）; sha `802e3c1d…` recorded in `maintenance/taxonomy-sync-map.md`. Installed copy untouched.
- `AGENTS.md`, `llm-wiki-mode.md`, `minimal-runtime.md`, `method-families.md` consistent with implementation.

**Reports written (cwd `development/`)**
- `batch2-progress.md` — milestone log, commands, honest test numbers (44/117/125 are different subsets, not one suite)
- `batch2-result.md` — capability table, full changed-file list, evidence, limitations, author decisions
- `verification-matrix.md` — per-item A01–A25 + G0–G3 mapping with evidence grades

**Pending integration steps for Codex**
1. Final independent full-suite run on frozen snapshot (prior run was interrupted — not a pass).
2. Taxonomy v2 adoption decision → deployment sync of installed copy (not executed).
3. G3 second-domain real material — inventory gap documented; needs author data or accepts partial.
4. A25 fresh natural-language consumer session on stable code.
5. Any formal Wiki write/install/deploy remains blocked pending review.

Stopped at review.