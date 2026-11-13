Let me read the newest review tail and the updated 25-case audit file first.Let me see the updated `make_project`/`receipt_path` helpers:All 5 new cases understood. Let me plan the repairs:

1. `_reusable_completed_run`: require `code_refs` for all reuse — `implementation_id` alone is a name, not code identity.
2. `material_state(..., recorded_sha=None)` on an existing file must return `unhashed`, not `current`.
3. `update_project`: back up derived files too — restore summary/cards when the authoritative `project.json` commit fails.
4. `_obs_rank`: demote claims whose `about` target (object/artifact) is stale/missing; verified claims also demote on `unhashed`/`unknown` subjects.
5. Update dedup fixtures to declare real code files; add product regressions.Now the provenance guard — `code_refs` required for all reuse:Now extend `update_project` — back up derived files and restore them on authoritative-commit failure:Add subject freshness to `check_project` observation entries:Now `_obs_rank` — demote claims about stale/missing/unverifiable subjects:Now update the product test fixtures to declare real code files:Run the 25-case audit and the affected product tests:All 25 audit cases pass. Now the targeted product regressions:Check other test files that might exercise dedup/material semantics:All covered tests pass. Check whether the server or other modules call `record_run`/`material_state`:Fix the `subject_material_state` docstring — it can return `'unknown'` beyond the `material_state` vocabulary:Update `project-state.md` for the tightened semantics:One divergence remains: the artifacts loop in `check_project` uses a manual sha check that treats hash-less artifacts as `current` while `material_state` says `unhashed`. Align it:For consistency, `_check_artifacts` should also exclude `unhashed` artifacts (the report path already marks them `unknown`):Re-run the audit and targeted regressions:Check which other test files consume these modules to spot wider impact:All affected surfaces covered (100 tests green). Write the two reports:Review-3 repairs complete. All four remaining causes are fixed and validated.

**Results**
- 25-case audit: **25/25 pass** (was 20 pass / 4 fail + 1 added)
- Targeted state/profile/CLI regressions: **75 passed**; combined run 100 passed
- No other product test files consume the changed modules; frontend untouched (still green)

**Repairs**
- **Code identity**: `implementation_id` no longer satisfies reuse — a bound id is a name, not a hash. `_reusable_completed_run` now requires receipt `code_refs` for every task. Dedup-positive fixtures were rewritten to declare real bounded code files (`file:scripts/qc.R`, `file:analysis.R`), per the fixture-adaptation allowance.
- **`material_state` honesty**: existing file + `recorded_sha=None` → `unhashed`, not `current`. Hashless receipt outputs can never be equivalent; `check_project` reports hashless artifact files as `unknown`, and `_check_artifacts` excludes `unhashed` consistently.
- **Derived-view restore**: `update_project` backs up published `summary.md` + route cards alongside receipts; a failed `project.json` rename restores all of them byte-for-byte — no future-revision handoff survives an old state. The recoverable-derived-gap path still applies only when the commit succeeds.
- **Subject freshness**: new `subject_material_state` resolver — `check_project` reports it per observation and `_obs_rank` uses the same truth. Claims about `stale`/`missing` objects or artifacts lose current proof force for either sign (never inventing false); `verified` additionally requires a verifiable (`current`) subject.

**Reports**: `development/review3-progress.md` and `development/review3-result.md` — including the honest crash-atomicity limit (tested write failures are consistent; mid-commit power loss can leave a recoverable `.tmp` gap, not claimed atomic).

Stopped per scope — Codex runs the final complete regression.