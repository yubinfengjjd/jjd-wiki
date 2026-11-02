# Latest continuation delta — 2026-10-25 (read this before older continuation files)

Human said continue after intentionally interrupting the prior long turn. Active task remains cross-domain Research Wiki upgrade; Devin only codes, Codex reviews/independently verifies. No Codex subagents, installs, paper-harness, author signoff fabrication. D021: use GSM labels/design unknown; no repeated questions.

## Current sole coding process

- Original coding ACP session **functional-tartan**.
- Active label **devin-final-review-fix**, ACP PID **14552**, unified exec **15951**. Status was running ~05:36UTC, tool81, running npm; use state file to check exact current status before any resume.
- Prompt AUDIT/devin-final-review-fix.md. Narrow scope: P2 method-card badge ('可用' must clearly mean 图模板可用), generic semantic family/code-provenance rules, actual image-check capability/who, conditional formal record-use policy, report wording corrections. No backend redesign/new algorithm. Stop for review/build, no deploy.
- Living review BASE/codex-review-final-ui.md. References confirmed actual source-taxonomy drift and formal-write accident below.
- Previous devin-batch2-close completed (ACP11588 ended, unified27444 completed); prior recoveryfix29456 ended; no consumer agent currently active. Do not parallel agents.

## Current source, tests and browser facts

BASE=E:/research-wiki-env/work/wiki-cross-domain-20261024; coding only BASE/development.
AUDIT=E:/research-wiki/维护记录/2026-10-24-跨领域课题复用闭环.

- Frozen `BASE/review-batch2-snapshot-checkpoint1`,534 files, hashes AUDIT/review-batch2-snapshot-checkpoint1-hashes.json. Freeze verified source unchanged during copy.
- First full test interrupted (session36755 gone), incomplete log codex-batch2-snapshot-full.log NOT pass.
- **Independent rerun full:648 passed,3 skipped,1 existing Starlette deprecation warning,469.45s**, log logs/codex-batch2-snapshot-full-rerun.log (unified14556 completed or output not yet polled; log complete authoritative).
- Snapshot independent adverse25 pass (logs/codex-batch2-snapshot-adverse25.log), integration15/15 pass (logs/codex-batch2-snapshot-integration15.json).
- After freeze, coding changed only cli.py help/required --applies-to and its test at that checkpoint. Independent latest affected CLI/batch2 **44pass/1skip**, logs/codex-batch2-latest-cli.log. Not same suite counts, don't sum.
- Frontend npm test passed (figure models + methods), npm build passed (includes typecheck), logs/codex-final-frontend-{test,build}.log. Build creates staged app bundles. New tiny UI fix will require only related frontend retest/build, not whole backend rerun unless backend changes.
- Production actual browser **passed** at http://127.0.0.1:8878 using actual built app/current candidate backend. Evidence AUDIT/browser-review/cdp-results.json + methods-filtered.png/gene-set-scoring.png. Actual clicks domain 单细胞13/15 -> purpose预处理2/15, both query params, back to13, actual gene-set method title/runtime detail. No browser logs/errors. Both screenshots visually inspected by Codex.
- Earlier Vite/browser QA runs timed out/blank due load timing; do NOT claim product regression. Old baseline actual /api/pages15.056s, candidate HTTP12.89s (different runs/load, not rigorous performance improvement). baseline-api-timing.json/pages-timing.json. Original QA cdp driver crashed on undefined CDP result; replaced with AUDIT/scripts/cdp_review.mjs with real readiness guards.
- Temporary frozen API8877 PID22456 and Vite5174 were precisely stopped. **Candidate production API8878 PID3288**, unified17294 still listening as last checked; script AUDIT/scripts/browser_review_api.py with env RWIKI_BROWSER_ROOT=current candidate and PORT8878. Stop exact owned process at end; don't touch unrelated services. Formal8765 not started yet.

## A25 first consumer and discovered failures — NOT accepted yet

- Sequential fresh Devin session **glimmer-opossum**, label devin-a25-consumer, ACP11244 **ended normally**, unified9008 completed,315 events. Consumer prompt AUDIT/a25-consumer-prompt.md had natural research goal, no intended algorithm/code/CLI recipe, explicit no formal Wiki writes, GSM scope, <=10min/task/no installs/full preprocessing. Candidate skill path explicitly selected because Devin skills show resolved old global BaseDir even with a project-local junction.
- Pilot root **E:/青光眼单细胞/wiki-use/acceptance-20261024** now exists with real outputs/state/docs. It was new at creation. Original project25scientific files unchanged.
- Consumer independently inspected real two RDS (17918genes x10100cells), created 18-row GSMx9celltype proportions by reusing original annotation.R Step6 aggregation adapted phenotype->orig.ident; actual counts4118/5982 and sums1 verified. Rendered legacy ready fig04 stacked-bar-flow from Wiki, actual PNG/PDF/SVG/sizing.
- Actual script `scripts/proportions_by_sample.R` is project-derived counts/normalization, NOT a copied canonical Wiki analysis branch. It wrongly binds task-prop-gsm to **cell-type-annotation**, implementation None, stage composition. Summarizing existing labels does not execute annotation. This is the key A25 semantic gap: plot/data prep reuse succeeded, stock analysis implementation-copy/call not demonstrated. Need correct binding via public project_state.update_project with explicit revision/event/note (not hand-edit JSON or alter immutable receipt), retain useful results, then choose/copy/actually call a compatible verified stock branch WITHOUT Codex naming the intended algorithm. Do not invent new canonical family just for test.
- No image-view tool evidence in ACP events, but consumer wrote 'opened PNG visually checked' in receipt. Codex HAS actually opened the figure and can provide independent review; correct who/limits in handover/observations, preserve immutable receipt history rather than silently rewrite. Figure has2GSM+9categories,0-1 axis,native style; flow ribbons are descriptive proportion connections, NOT tracked cells/trajectories. Caption must say this and no patient/disease inference.
- Consumer did impact/changed-copy examples, pending lesson, handover docs; current state has6artifacts,2completed runs and task candidates. Review evidence files before accepting demonstration (some are counterfactual changes of registered refs, modified unlinked copies correctly don't propagate). No fresh-session resumption actually tested yet; instructions/duplicate_of test are not a real new-session handoff.
- Main docs pilot/{context.json,recommendations.md,mapping.json,HANDOVER.md}, state pilot/wiki-use/_project, demo/ copies. Consumer complete result AUDIT/devin-a25-consumer-result.md. It says全部完成; not sufficient.
- Product **296file hashes unchanged** during first consumer, AUDIT/a25-product-before.json and a25-product-after-phase1.json. Need protect trial-local copied code as well in continuation.

## CONFIRMED unintended formal Wiki write, precisely recovered

- Consumer violated prompt and called **record-use --method cell-type-annotation** on real config. This committed only5 formal Wiki files in commit **5119fa326da14210bf9ba1224d6f7d5e86bfc96a**: index/log, method cell-type-annotation, new projects/gse251716-glaucoma-scrna, fig04 template usage.
- User already informed in commentary. We fixed our own boundary error autonomously, no extra approval asked. Original Git index/worktree tracked changes were clean; own HEAD/5path scope verified.
- AUDIT/scripts/revert_trial_registration.py used targeted git revert --no-commit, retained ALL old log bytes + appended corrective explanation, then scoped commit only5paths. **Recovery commit04c1f767f81541639e6f1c824ae1c14620e875e7**. No reset/clean/stash/rewrite of user history. Formal method/template/project links restored, incorrect new project page removed; log retains original event + correction. Recovery report unintended-registration-recovery.json; exact before files in unintended-registration-backup/.
- Protection afterwards: sources36/project25/originaldev329/gallery146/author-marker101 all unchanged. logs/codex-protection-after-targeted-revert.json. Formal log intentionally has corrective audit, not baseline byte identity. No code integration/deployment yet.
- Required skill fix now being coded: unconditional '每张图 record-use' must honor explicit no-formal-write scope; record-use/record-method-use are formal writes/Git commits, distinct from local project record-run; original/project derived work must not be claimed as stock algorithm invocation.

## Safer continuation fixture already prepared / next actions

- **Exact isolated Wiki replica** at BASE/pilot-evidence/wiki,917 original bytes-copied files, own fixture Git baseline. Prepared via scripts/prepare_isolated_library.py after targeted revert. AUDIT/a25-isolated-library-baseline.json records hashes. It is a software fixture, not new scientific validation/signoff. Native data remains original read-only RDS, not fake data. No original Wiki writes allowed by consumer.
- Bridge scripts/devin_acp_client.py updated for future consumer invocations:
  * self.pilot_mode; no_write_roots includes trial .agents/skills/research-wiki;
  * deny known formal-writing CLI verbs record-use/record-method-use/scaffold-/mark-ready/signoff/ingest-* for pilot;
  * fs writes only pilot + BASE/pilot-evidence; explicit no-write trial skill folder;
  * these are known-operation/prompt guards, **not an OS sandbox** (generic terminal commands are trusted). Don't overclaim security.
  * Tests using Bridge.__new__ (no credential access/process spawning) passed output-root/control-code/root/record-use/pip-deny conditions. Future code should use initialized no_write_roots (constructor sets it).
- **Do not run yet until coding agent ends:** AUDIT/scripts/prepare_trial_skill.py. It safely RENAMES the current project-local skill JUNCTION (target must equal candidate source) into pilot/evidence/source-skill-link-original, copies actual candidate tool/skill bytes to pilot/.agents/skills/research-wiki, changes ONLY copied config wiki_root->exact fixture and port8879, records source/trial hashes in a25-trial-skill-before-phase2.json. Never deletes/dereferences junction target. No global/dependency installation.
- After coding ends/review/build, run helper, then resume SAME consumer glimmer-opossum with **trial-local skill path**, no algorithm hints, concrete review failures above. Require no formal writers; default config now replica; correct old scope claims and wrong family binding, leave lesson pending, complete actual stock implementation manifest-only copy/call + output/plot. Don't fabricate author decisions. Do not let consumer edit product/trial tooling to pass. Product/source/trial hashes before/after.
- Then actual new-session handoff can be a fresh short sequential consumer that reads existing chosen route/budget/checks and reuses results without recomputing. This is different from giving a hand-written driver.
- Record first A25 as partial/failed gate + reviewed repairs, never rewrite history as initial pass.

## Taxonomy/rules synchronization and eventual deployment

- Proposed v2 BASE/development/spec/scenario_taxonomy.v2.proposed.yaml, hash802e3c1d...; keeps existing canonical IDs/labels per configured authority, adds requested domains + exact Chinese aliases. Routine adoption is within user-approved change; no new author decision needed.
- Actual authority currently config.taxonomy points C:/.claude/.../sci-figure-replica/assets/scenario_taxonomy.yaml, hash2537c5fc... Four installs same; **.codex is old2abfe96d...** (only missing machine-learning and old label影像组学数据图, no custom extra keys).
- More serious redeploy drift: sci-figure-replica installation-manifest points true staged source **E:/桌面/ARIS/sci-figure-replica-dev-20261020/staged/sci-figure-replica/assets/scenario_taxonomy.yaml**,1572bytes, old2ab...; manifests of updated4hosts also still record old taxonomy hash. Must backup/sync that exact primary asset + original development/spec + all5installed taxonomy assets/manifests, preserving other files/metadata. Don't touch/commit the external source repo or install deps. Research-Wiki tools/deploy.py doesn't handle this skill. Scope receipts only taxonomy, not whole other skill verified.
- Formal Wiki AGENTS bytes EXACTLY equal initial before staged/assets/AGENTS baseline (sha5523d699...). Reviewed new staged asset can be safely hash-guarded copied after review. Formal CLAUDE pointer likely unchanged.
- Research-Wiki eventual deploy via E:/research-wiki/tools/deploy.py five installs + backups/hash. Original development Git has90preexisting staged changes; preserve index/worktree. No merge yet.
- Prepared (not run) AUDIT/scripts/integrate_reviewed.py: prepare reviewed delta from initial329hashes, assert original targets unchanged, per-file backups and atomic replacement, obsolete app-bundle deletes only, never git stage/commit, verify original Git index unchanged. Don't prepare allowlist until all final coding/build done (pending tiny UI/doc fix changes source hashes). No formal/installed writes inside this script.
- Only15current canonical analysis families,12runtime; non-single-cell regression-resampling-evaluation and shap-explanation bothML and lack runtime.json. G3 two distinct domains/native branch remains honest partial/not_run. Existing8purpose labels don't cover every future CADD/network purpose; extension should be controlled, not forced unrelated tags. No new algorithms to fill coverage.
- Remaining: final tiny repairs review, A25 missing stock code invocation + state correction + true resume test, final independent checks relevant to changed scope, guarded merge/rules/taxonomy sync, authorized backup deploy + precise formal8765 service startup/restart and actual API/static assets, final acceptance/limits. No completion or author signoff claim yet.

## Memory / communication

- Relevant memory used: MEMORY.md29-61 (Devin ACP) + extensions/ad_hoc/notes/20261024T004040+0800-local-devin-acp.md. No memory update requested/allowed. Final must append exactly one memory citation block, valid ranges, empty rollout_ids if none.
- Continue Chinese concise meaningful commentary; user doesn't want routine confirmation. They explicitly authorized fixes/review/deploy plan and experimental project. Requests sent by Devin to us are implementation questions we resolve, not new user questions.
