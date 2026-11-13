# Self-review notes (fallback draft; superseded)

The fresh-context reviewer returned after this draft: verdict PASS, 2 Important and 9 Minor. The Important fixes and the final verdict are recorded in `README.md` and `progress.md`; this draft is retained only as a comparison, not as the authoritative review.

Scope: F01–F06 fixes, the shared acceptance layer, the record-use acceptance fix, and the deployment. Read-only pass against `plan.md`, the audit report, `progress.md`, the full suite, and the live API.

## Strengths

- Each finding has a direct regression test that failed before the fix: repeated ingest, preview-only ready, six input/output mutations, failed rerun, blank method, missing relation review, text-only method, and record-use acceptance.
- Acceptance is shared by `mark_ready`, `confirm_method`, `workflow_snapshot`, `lint`, and `suggest*`; there is no second status authority.
- Replay evidence binds code/spec/example/interface hashes and three output hashes; the preview must match the PNG output.
- The frontend dedupe only merges a source with one template that fully covers the same panels; all source links survive; the live shelves are 5/5.
- The record-use fix is precise: only the generated `- YYYY-MM-DD [[projects/...]]` line is ignored, so existing acceptance records stay byte-valid and ordinary note edits still stale them.
- Backend 377 passed/2 skipped, frontend 15 checks, typecheck/build, formal lint OK, pending empty, API 5 templates/2 methods complete, 7 relations, 27/56/7 graph, six global installs verified by manifest.

## Issues

### Critical

None found.

### Important

None found in the six-finding scope.

### Minor

1. `rwiki/templates.py:206` / `rwiki/methods.py:63` — `mark_ready`/`confirm_method` write `status: ready` before `record_acceptance`. If recording fails between the two writes, the page is ready on disk without a receipt. The content and replay gates still pass/fail independently, so this is an audit-transaction edge, not a bypass. A future fix could write the receipt first against the finalized body, then set ready, or revert on failure.
2. `rwiki/acceptance.py:63` — `acceptance_stale` returns `False` when `acceptance.json` is absent, for legacy pages. Deleting a receipt loses the “changed since check” audit but not the content/replay gates. A future migration could mark legacy pages explicitly.
3. `rwiki/workflow.py:10` — for a **ready layout**, the workflow uses coverage rather than `layout_ready_errors`/`acceptance_stale`; a ready layout with a stale layout replay could show `complete` while `lint` reports the stale replay. All current formal layouts are `pending_template`, so there is no live impact; the SHAP/regression templates use the template branch, which is fully gated. This is outside the six-finding scope (templates/methods) but worth a follow-up.
4. `维护记录/.../deploy.py` — the sci-figure report always lists `SKILL.md` as changed on a redeploy even when its hash is unchanged; the manifest hash check is correct. Reporting-only.
5. `tests/test_t3.py::test_record_use_creates_project_links_and_commit` — the fixture intentionally contains a draft and a pending-template page, so lint has WARNs; the test now requires no ERROR and a final OK rather than a bare `OK`. This is documented and matches the new lint design.
6. `rwiki/verification.py:16` — the receipt records the executable/environment but `replay_available` does not bind it; the plan asks to record the environment, not to invalidate on a different Python. Environment changes are out of scope for the input hash by design.

## Recommendations

- Add a follow-up test for the ready-layout workflow branch if a layout is later marked ready.
- Consider making the acceptance record part of the page’s `ready` transition transactionally.
- Keep the `verify/` receipts in a durable backup if the Wiki is cloned without them.

## Assessment

**Ready to merge: Yes** for the six findings and the record-use fix. The minors are audit/edge improvements, not blockers; the full suite, formal lint, live API, and six installs are green.
