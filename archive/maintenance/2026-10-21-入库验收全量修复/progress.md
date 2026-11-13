# SDD ledger — plan: E:\research-wiki\维护记录\2026-10-21-入库验收全量修复\plan.md

Resumed 2026-10-22 by Claude Code after the Codex session `01a15d3a-5b6f-7043-a51f-914493f7a970` hit its quota at 2026-10-21T15:56Z. The author's `E:\桌面\新建 文本文档 (4).txt` is empty; the session was recovered from `/f/C_move/codex_sessions/2026/10/21/rollout-2026-10-21T14-51-08-01a15d3a-5b6f-7043-a51f-914493f7a970.jsonl`.

Plan authority: `plan.md` (6 steps). Review authority: `E:\research-wiki\维护记录\2026-10-21-开发日志与入库审查\README.md` (F01–F06).

Pre-flight: the six findings share the acceptance/ingest/verification interfaces; the plan's steps already order them. No conflicting interface contract found.

Ruling: work directly in the existing `E:\research-wiki\开发` working tree, not a new git worktree — the baseline commit predates all resumed work and a worktree would omit the uncommitted staged/frontend changes the plan depends on; no commits are made unless the author asks (global instruction). Cost if wrong: changes stay uncommitted and must be reviewed/committed later.

Ruling: the plan's step 6 already authorizes syncing the three global installs and restarting the formal service; continue without re-asking. Cost if wrong: global skills briefly carry the new rules before the author inspects the final diff.

Ruling: `verify-template` and `check-entry --record` use the wiki's own `save`, which commits the refresh/acceptance records to the `知识库` git repo; this is the product's audit model required by the plan's step 5. The dev repo stays uncommitted. Cost if wrong: the author may prefer different commit messages or a single squashed commit; the commits are local and reversible.

Task 1: close the 5 remaining regression failures (test expectations vs intentional new gates)
Task 2: re-verify F01–F05 with targeted regression tests
Task 3: update F06 current-requirements index and sync rules to Wiki + two skills
Task 4: refresh existing template replays and acceptance evidence for the 7 ready entries
Task 5: full backend + frontend + isolated integration verification
Task 6: deploy three global installs and verify the formal API/gallery/code entry points
Task 7: fresh-context final review

## Task 1

- Five old expectations updated for intentional new gates: method fixture completed + citation; gallery `approved_version`; replay receipt schema 2; lint warnings on intentionally incomplete fixture; targeted 10/10 pass.
- Two test-infrastructure decode fixes: localized `netstat` and `mklink` output now use `errors="replace"`; the failing `test_cli_serve_loopback` and two code-asset thread warnings pass 3/3.
- Ruling: the lint warnings in `test_record_use...` are intended findings for incomplete draft/pending pages (see `test_empty_applicability_and_stale_index_warn`); the test now requires no ERROR and a final OK rather than zero WARN. Cost if wrong: warnings could be ignored in that fixture.

## Task 4

- Five existing template replays refreshed with current code/example (`verify-template`), all five `check-entry` pass.
- Three SHAP template pages lacked `知识关联检查`; added factual review text referencing the existing method relations; no new relations invented.
- All seven ready entries recorded `acceptance.json`; formal `lint` returns OK, `pending --json` returns `[]`.

## Task 1: complete

Backend full suite command: `python -X utf8 -m pytest -q --basetemp E:\research-wiki-env\tmp\all-fourth` → 376 passed, 2 skipped, 1 external Starlette deprecation warning, 223.29s. The two skips are host symlink-privilege skips.

Ruling: `test_cli_serve_loopback` and the two code-asset thread warnings were test-infrastructure decode failures on localized Windows output (`netstat`, `mklink`), not product defects; the tests now decode with `errors="replace"`. Cost if wrong: localized output is garbled in diagnostics, but ASCII address/state parsing is unaffected.

## Task 2: complete

Targeted audit regressions `tests/test_acceptance_gates.py` → 76 passed (see `target2.txt`); F05 `check_frontend.mjs` → passed; full suite includes both. The historical `reproduce.py` is retained as audit evidence but now intentionally fails its "bug reproduced" assertions because the bugs are fixed; the maintained regression is `test_acceptance_gates.py`.

## Task 3: complete

Current index `文档/当前要求与同步核查.md` updated (2026-10-22 section; stale pending-signoff and broad-migration claims already replaced by `update_rules.py`). `知识库/AGENTS.md` and `staged/research-wiki/assets/AGENTS.md` are byte-identical; staged research-wiki `SKILL.md`, `references/knowledge-linking.md`, `references/project-reuse.md` carry the new acceptance rules; staged sci-figure-replica `SKILL.md` carries the handoff section.

## Task 4: complete

Five `verify-template` runs exit 0 with schema-2 receipts; seven `check-entry --record` runs pass (five templates, two methods); formal `lint` OK; `pending --json` `[]`; the three SHAP template pages gained factual `知识关联检查` sections without inventing relations.

## Task 5: complete

Frontend `npm test` → 15 checks passed; `npm run typecheck` → 0; `npm run build` → success (staged app `index-Ct2Y9w1S.js`, `index-Dae4LbsR.css`); live gallery check → single shelf 5, template shelf 5, fig03/fig04 source links preserved. Backend 376/376 passed (2 skipped).

## Task 6: complete

Deployment `deploy.py` → each host (`.agents`, `.codex`, `.claude`): research-wiki 268 files verified, 31 changed; sci-figure-replica 136 files verified, 1 changed (`SKILL.md`). Server restarted from `.claude`; `verify_api.py` → 27 pages, 5 templates complete, 2 ready methods complete, agent queue empty, 7 relations, served app equals staged build. See `deployment-verification.json`, `api-verification.json`, `live-gallery.json`.

## Task 7

Fresh-context reviewer dispatched; awaiting result.

Self-found and fixed: `record_use` appended a project link to `使用记录`, which the acceptance snapshot included, so an accepted ready template/method became `acceptance_stale=True` / `ready_for_use=False` / workflow agent after first use. Reproduced in `check_usage_acceptance.py`; added `test_record_use_does_not_invalidate_acceptance` and watched it fail, then made `snapshot()` ignore only the exact `- YYYY-MM-DD [[projects/...]]` line `record_use` appends. The seven existing acceptance records remain byte-valid (`check-entry` all pass), formal `lint` OK, `pending --json` `[]`; redeployed (2 changed files per host) and restarted the service. Cost if wrong: a manually written project-link line in `使用记录` will not stale acceptance, but it is still a usage log, not note content.

Ruling: the `使用记录` section is an append-only log; only the generated project-link line is ignored, not other notes. Cost if wrong: a substantive edit written in that section without a project link would still stale acceptance (correct), while a manually written project link would not (acceptable).

Final: fixed record-use invalidating acceptance — `test_record_use_does_not_invalidate_acceptance` RED→GREEN, full suite `pytest-fifth.txt` 377 passed / 2 skipped (170.42s); seven existing acceptance records re-checked; formal lint OK; API re-verified.

## Final review

Fresh-context reviewer verdict: **PASS**, with 2 Important findings and 9 Minor findings. Both Important findings were fixed in the one fix pass:

1. Shared gate for ready layouts (`rwiki/acceptance.py`, `rwiki/templates.py`, `rwiki/workflow.py`, `rwiki/suggest.py`): `ready_for_use` now calls `layout_ready_errors`, `layout_ready_errors` includes each ready template's own `entry_errors`, workflow checks ready-layout coverage/replay/acceptance, and suggest skips a layout whose template cannot be loaded. Regression: `test_ready_layout_with_archived_template_is_agent`, `test_ready_layout_with_incomplete_template_is_agent`, `test_mark_ready_rejects_layout_with_incomplete_template`, `test_ready_layout_stale_acceptance_is_agent`.
2. Legacy F01 bypass (`rwiki/ingest.py`): removed the `gallery_version` fallback and the missing-`approved_version` default; a one-time migration recorded the existing author confirmation for the two formal legacy sources (`signedoff_version=1`). Regression: `test_legacy_pending_template_without_signed_version_requires_signoff`, `test_new_page_from_legacy_approved_gallery_requires_signoff`.
3. Re-graded to Important and fixed: a section whose first line is `TODO：补充数据` now counts as a placeholder (`test_placeholder_with_explanation_is_rejected`); `check-entry` reports and can refresh a stale acceptance record (`test_check_entry_reports_and_refreshes_stale_acceptance`).

Deferred minors (from the reviewer; not fixed in this pass):
- `_without_usage_links` breaks on a project title containing `]`; use a greedy end-of-line match or validate the title.
- `record_acceptance` records `replay: not_required` for layouts even though a ready layout requires a replay.
- `layout_ready_errors`/`load_layout` do not compare `layout.json` panel letters with all `meta['panels']`; a ready layout could replay a subset.
- `methodDisplayFigures` always prefers the template as the merged representative, which can hide semantic metadata declared on a source layout.
- Remaining test gaps: method-page `record-use`, bracketed title, substantive note in `使用记录`, subset `layout.json`, and a stale `check-entry` on a layout.
- Acceptance snapshot normalization changed without a schema bump; pre-fix records that already contained a generated usage link would stale once. The seven formal records remain valid.

Reviewer's “Declined to judge” list (accepted as out of scope, no action): scientific/statistical validity and real-project end-to-end; R arbitrary-n parity; unrelated UI work; archived whole-source hiding; `verify/` being gitignored; symlink-test skips; localized `netstat`/`mklink` decode; gallery approval semantics; interface title changes; `replica.png` hashing; legacy pages without `使用记录`; nondeterministic render output; manual `acceptance.json` edits; two serve processes; UI historical-source wording.

Documentation wording “六个全局技能” corrected to “六份全局安装”. Final full suite after these fixes: `pytest-sixth.txt` → 385 passed, 2 skipped, 1 external warning, 176.13s.
