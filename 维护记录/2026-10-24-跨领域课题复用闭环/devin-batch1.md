# Authorized implementation batch 1: cross-domain Research Wiki reuse loop

You are the sole coding assistant, Devin CLI SWE-2 Max. Codex leads review and independent validation. Do not spawn agents, launch Claude/Codex, install dependencies, use network/cloud services, change user/global config, or read/call E:/paper-harness. Do not read credentials or hidden login/config files. Stay in your isolated copy; do not edit the real Wiki, the original development tree, or original glaucoma files.

## Paths and boundaries

- Your writable development copy: E:/research-wiki-env/work/wiki-cross-domain-20261024/development
- Additional writable scratch/results: E:/research-wiki-env/work/wiki-cross-domain-20261024
- Actual staged skill in the copy: development/staged/research-wiki (rwiki, wiki.py, tests, SKILL.md, assets, references).
- Original development E:/research-wiki/开发 is read-only; its pre-existing dirty changes are copied into your baseline.
- Formal Wiki E:/research-wiki/知识库 and gallery E:/research-wiki/画廊 are read-only for you. Never run a default-config mutation or save against them.
- Real acceptance project E:/青光眼单细胞 is read-only in this batch. Codex separately inventories objects. Do not read its .claude/config or backup/zip folders.
- Read plan: E:/research-wiki/文档/战略盲区咨询/{requirements.md,design.md,cross-domain-contract.md,handoff.md,session.md}. They include the latest user corrections D017/D018/D019/D020.
- Wiki Python: C:/Users/86186/.codex/venvs/research-wiki/Scripts/python.exe -X utf8.
- Generic Python: D:/anaconda/python.exe -X utf8. Never use PATH python (Windows Store stub).
- R, if needed later: D:/R-4.5.0/bin/Rscript.exe; existing R_LIBS_USER=E:/research-wiki-env/R-lib-scp/4.5. No installs.
- Shell is PowerShell. For executable paths use & 'path' followed by arguments.
- A test-only config must point to isolated fixtures before any Wiki write. Existing pytest fixtures are safe. Do not copy study data to the Wiki.

## Product intent

In any research domain, invoking research-wiki in a project should make its agent inspect current evidence, identify appropriate next analyses, retrieve canonical method branches and plot templates, copy the minimal reusable assets into the project, explicitly adapt native inputs, run with the project environment, and produce accurate, beautiful figures plus interpretation. All routine steps should continue under existing authorization; only missing critical information/major scientific choices/budget excess need the author. The project/state layer supports this experience and must remain small.

All bioinformatics, deep learning, radiomics, computational drug design, network pharmacology/toxicology, proteomics, metabolomics and mixed-domain projects must fit the generic design from the start. Single-cell is only the first real execution pilot. Do not require cell_id/Seurat/CSV or hard-code a single-cell stage sequence in the core.

## This batch: T00–T03 plus necessary skill wiring, then stop for review

1. Read the current code and plans. Briefly document reusable pieces and any concrete plan adjustment. Do not spend the whole turn producing another plan; implement.
2. Add a minimal project-state/evidence subsystem with atomic single-writer/revision updates, stable project/run identifiers, scoped native object/entity evidence, selected question/routes, authorization/budget, artifacts and actual dependency/fingerprint records. Keep epistemic status, task completion, artifact freshness, implementation verification and scientific interpretation separate. Preserve legacy wiki-use contexts. State writes are project-local and never call Wiki save.
3. Wire project init/status/check/impact/record-run (or clearly equivalent minimal commands) into existing CLI. No arbitrary shell execution in CLI/server. Check references/paths and evidence; unknown prerequisites stay unknown. Do not let booleans in caller JSON or exit0 alone confer scientific/algorithm verification.
4. Add read-only opportunity discovery that can surface existing canonical analysis notes/unverified branches without weakening existing suggest-methods/ready_for_use or changing default behavior. No archived/source/workflow technical entries silently promoted. Library gaps are non-executable candidates.
5. Define composable cross-domain evidence/prerequisite profiles, with representative full/missing data cases for all named domains. Keep domain current knowledge in canonical Wiki references or clearly labeled specification/fixtures, not a copied mutable availability table. Do not create artificial scientific method pages just to store profiles.
6. Extend the runtime contract compatibly to describe non-R/Python-package conditions: external tools/scripts, weights/reference resources and conditional hardware. Preserve old R/Python manifests and receipt fingerprints when optional new fields are absent. Any new substantive runtime requirement must affect its evidence fingerprint. Do not mark declared tools/hardware verified or install them. API/lint/frontend facts must come from one parser.
7. Update the staged skill/project-reuse references enough to expose this batch truthfully. Preserve source-faithful code, author user/status/id/favorite, taxonomy semantics, original input protection, existing render/bindings and single-panel behavior. Full governance/lesson/plot integration continues in later batches.
8. Add meaningful tests for state conflict/atomic failure, safe paths, partial evidence, actual impact logic, native non-table objects, all-domain profile missing-precondition behavior, discovery ready/not_run separation, and runtime backward compatibility. Use existing environment. Run the new/affected tests and relevant old tests.

Do not build a second execution engine, large framework, blanket preconfigured biological pipeline, database or web task runner. Prefer a few small cohesive modules and explicit errors.

## Reporting and checkpoint

Write progress incrementally to E:/research-wiki-env/work/wiki-cross-domain-20261024/progress.md.
Write final batch report to E:/research-wiki-env/work/wiki-cross-domain-20261024/batch1-result.md:
- actual changed files and implementation decisions;
- exact tested commands, pass/fail/not_run and scope;
- known gaps and next batch items;
- deviations from this prompt/plan and reasons.

Stop after this batch for Codex review. Do not commit, merge, deploy, mark formal Wiki ready, or run full glaucoma analyses yet. A file skeleton or self-reported completion is not acceptance.
