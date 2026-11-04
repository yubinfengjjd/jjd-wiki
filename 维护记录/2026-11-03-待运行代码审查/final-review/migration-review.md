# Machine migration and CLI read-session final review

**Verdict: APPROVE. No actionable regression remains in the reviewed current files.**

The reviewed file hashes and repository HEADs are recorded in `migration-review.json`. This assessment covers the two development-repository files and the vault machine migration scope listed there; later PR review must confirm that the PR head contains the same reviewed changes.

## CLI lint cache

The implementation imports the existing `read_session` and wraps only one invocation of `lint`. It does not modify validation rules, output, CI flags or the CLI exit decision. The existing context manager resets the ContextVar in `finally`; page/relation consumers retain their defensive-copy behavior. The new test compares diagnostics with uncached lint and counts relation reconstruction across two CLI invocations for both CI modes.

A read-only in-memory probe exercised four actual `cli.main` calls (CI false twice, then true twice), checking reuse within each call, a fresh build on the next call, unchanged WARN/OK output and a reset context after every call. All assertions passed. No full Wiki lint was run.

## Machine migration

Reviewed nested/sibling checkout selection, strict explicit invalid overrides, config output handling, the distinct Wiki/scientific interpreter roles, deploy argument parsing and existing source gate, dependency logical manifest keys, wrapper quoting and launcher configuration/lifecycle changes. No new actionable issue was found.

The previous argument-loss and interactive-input regressions are closed. Current real PowerShell 5 transport code passed a probe preserving empty arguments, quotes, whitespace, trailing backslashes, shell metacharacters and Chinese/newline text. The same probe passed 300 KB stdin with EOF, 70 KB stderr, exit status 9 and a Chinese line delivered while upstream stdin stayed open. The async bridge performs ordered WriteAsync/FlushAsync in one task and closes child stdin on EOF. The spaced-interpreter regression fixture now creates a standard-library venv without pip rather than assuming the parent interpreter has pyvenv.cfg.

Both PowerShell scripts parsed without errors, and all scoped Python sources passed AST parsing. These checks do not substitute for the orchestrator's full fixture/integration test run. No deployed skill, real server or browser was started; no packages were installed and no product source was changed by this review.
