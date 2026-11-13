# Authorized formal adoption of six public Python cases

The primary agent authorized adoption after the independent `migration_spec_review` final report returned PASS. Review provenance is recorded verbatim by task name and final verdict in every newly adopted formal receipt. The source report was supplied in the primary-agent instruction; no report file or URL has been invented.

Changes are limited to:

- `methods/local-omics-analysis-guide.md`: five `implementations[].verification` pointers and one appended public-software-case section.
- `methods/local-omics-visualization-guide.md`: one verification pointer and one appended section.
- Eighteen new JSON files in the two assets' `verification/` directories: algorithm, portability and comparison for each of six actually executed public cases.
- Adoption tooling and evidence in this maintenance directory.

Formal copies retain the executed case, numerical outputs, hashes, environment and execution timestamp. They add `promotion=adopted`, `adopted_at`, `independent_review` and immutable candidate SHA256 provenance. Original candidate files and all old verification evidence remain unchanged.

Both runtime manifests remain byte-identical. Their original `evidence.portability` defaults remain in place. Each method page explicitly links the new supplemental public portability receipts and explains that those supplements do not rewrite the old defaults or reproduce private UC/asthma cases.

## Official checks

`adopt_public_receipts.py` used the dedicated Wiki Python and official `rwiki.method_implementations.implementation_status` before and after adoption for all 85 declarations. It used official `rwiki.runtime_contract._evidence` with the new supplemental pointer and official `closure_hash` to parse each supplement without editing the manifest.

- Six new algorithm pointers: `verified`.
- Six supplemental portability receipts: `verified`, zero parser issues.
- Seventy-nine non-target implementation objects: exactly unchanged, including scope and runtime facts.
- All 85 state labels: unchanged; adoption refreshes six already-verified function cases rather than promoting unrelated branches.
- Target default runtime/portability facts: unchanged.
- Both runtime manifest hashes: unchanged.
- All pre-existing verification file hashes: unchanged.
- All original candidate hashes: unchanged.
- Protected author/generated blocks: byte-identical.
- Parsed frontmatter: only the six requested verification fields changed.

Exact before/after objects and preservation assertions are in `formal-adoption-before-20261104.json` and `formal-adoption-after-20261104.json`. Adoption time is stored as UTC in receipts; the page section date is the local 2026-11-04 date. The original execution time remains 2026-11-03 UTC.

The page diff was reviewed: six pointer replacements and thirty added lines, with no unrelated page edits. `git diff --check` passed. No Wiki save, facts/index regeneration, commit or push was performed; those final integration steps remain owned by the primary agent.
