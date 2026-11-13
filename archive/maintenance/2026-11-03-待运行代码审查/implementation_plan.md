# Wiki migration and execution implementation plan

> For agentic workers: use subagent-driven-development for isolated implementation tasks; review specification compliance before code quality. Do not commit or push independently; the primary agent coordinates final reviewed commits.

**Goal:** Restore the approved sibling-checkout setup while keeping legacy nested setups usable, and make every declared execution asset auditable on this machine.

**Architecture:** Keep the existing Wiki APIs and scientific algorithms. Resolve repository locations explicitly, generate ignored machine configuration, and run copied scientific assets in separate processes outside the repositories. Preserve source bytes, author blocks and historical receipts. New receipts must state exactly what was run and must not promote package imports or synthetic cases to scientific validation.

**Tech stack:** Python 3.12, PowerShell, R 4.5.0/Bioconductor 3.21, existing rwiki CLI and pytest.

## Task 1: Machine migration entrypoints

Ownership: tools/configure-machine.py, tools/deploy.py, tools/export-dependencies.py, tools/launcher.ps1, tools/bin/rwiki.cmd, tools/bin/rwiki, new tools/machine_paths.py if useful, focused tools/tests migration tests, and related README installation instructions. Do not edit knowledge assets or the development repository.

- [ ] Read each entrypoint and its existing tests, config.example.json and local config semantics.
- [ ] Add failing tests for both nested `vault/开发` and sibling `vault.parent/jjd-wiki-dev` layouts. An explicit override must be validated rather than silently replaced. Default resolution prefers a valid nested checkout and then a valid sibling. A valid checkout contains staged/research-wiki/wiki.py and config.example.json; never create a fake checkout.
- [ ] Reproduce `configure-machine.py` rejecting the current sibling checkout before changing production code. Use temporary files for tests and never invoke recursive deletion or git reset/clean commands.
- [ ] Implement the smallest shared resolver or explicit path support. Keep existing CLI arguments valid. A new optional --dev-root is acceptable; all resolved locations must remain explicit in generated config. Refuse to overwrite existing config.
- [ ] Make launcher and rwiki use machine-local configuration and interpreter discovery/explicit overrides instead of old usernames and drive letters. Keep localhost binding and existing window lifecycle. Missing config/interpreter must yield an actionable error, not arbitrary system-Python fallback.
- [ ] Ensure dependency exports and tests locate the development checkout consistently. Generated knowledge/dependency snapshots must not be regenerated with changed scientific declarations merely to fix paths.
- [ ] Run focused new migration tests and applicable existing non-destructive tests using the dedicated Wiki Python. Do not run test_deploy cases containing forbidden git reset --hard operations. Report those exclusions.
- [ ] Review the diff, list exact commands/results, and return files changed and remaining limits without committing.

## Task 2: Method replay discovery and safe audit tooling

Ownership: new files under 维护记录/2026-11-03-待运行代码审查/method-replay/ only. Do not alter method code/pages, shared planning files, original scripts or historical receipts. Do not install packages or run R against the installation library while restoration is running.

- [ ] Enumerate all current method implementations from frontmatter/runtime manifests and inspect existing historical receipt cases and replay drivers.
- [ ] Classify each existing executable branch by a real replay driver/case, public input requirement, dependency requirement, or exact missing prerequisite. Native registries are catalogs; never claim all registered functions have executed.
- [ ] Build a portable mapping and, where unambiguous, parameterized replay drivers that copy runtime manifest closure to a unique external directory, launch a new process, record hashes/arguments/outputs, and assert input preservation. Existing scientific parameter choices may be reused; new scientific choices must be referred to the primary agent.
- [ ] Prefer the existing public pancreas data and bounded prior cases where available. Do not use synthetic biological data or create pseudotime/velocity values to fill gaps.
- [ ] Any new driver must be parsed/compiled and have tests for its orchestration where useful; do not manufacture scientific pass receipts. Write new receipts only from actual child-process results.
- [ ] Return a compact full-coverage mapping, exact blockers, and instructions to run the reproducible drivers after environment restoration.

## Task 3: Execution and delivery (primary agent)

- [ ] Finish isolated R/Python dependency batches; record actual resolved versions, source mismatches, and any unavailable packages.
- [ ] Copy each of 30 recipes and 30 templates to a unique external run directory. Use public repository examples as supplied, report estimated/synthetic historical plotting examples as such, and preserve original source files.
- [ ] Execute copied recipes and templates; inspect actual outputs and meaningful assertions. Re-run failures only after investigating root causes.
- [ ] Execute method replay cases as dependencies and lawful public inputs permit. Keep exact not_run for missing private inputs, unresolved scientific choices or missing algorithms.
- [ ] Store sanitized environment/input/code/output evidence, update relevant current method pointers only after real validation, and rebuild facts/index/catalog with save.
- [ ] Run focused software checks, lint, protected-author-content verification, actual API/UI checks, and push guards. Review diffs and obtain independent specification and code-quality review.
- [ ] Commit and push reviewed changes using the repository GitHub workflow; attach any created PR. Confirm the remote commit and report material unrun cases explicitly.
