# Audit findings

- The knowledge and development repositories are separate sibling checkouts on this machine; both were clean at inspection.
- No .codegraph directory exists at the knowledge repository root.
- The historical migration inventory declares 34 pending implementations and 21 source/theory-only notes. This is a historical starting point, not a fresh full inventory.
- README, launchers, and configure-machine.py assume the old nested development checkout and old interpreter paths. The actual sibling checkout layout needs consideration before configuration changes.
- PATH resolves Python to 3.14; D: conda provides Python 3.12.7 and has yaml/pytest/Pillow/numpy/pandas available. No dedicated Wiki Python has yet been identified.
- PATH Rscript is R 4.3.1. Package metadata lists 913 installed packages including Seurat, SCP, CellChat, harmony, SingleR, monocle/monocle3, singscore, irGSEA, ConsensusClusterPlus and GSVA. Metadata presence is not namespace loading or execution evidence.
- The repository baseline uses R 4.5.x and Python 3.12, with separate legacy SCP Python profiles. Existing package versions and namespace compatibility remain unverified.
- The current migration list includes missing-input/parameter cases as well as dependency failures: CellChat human DB/PPI choice, GSVA parameter objects, UMAP reference projection, PAGA and velocity inputs.
- Fresh frontmatter inventory: 43 method pages declare 85 implementations (51 historical passed receipts, 31 not_run receipts, 3 implementations without a verification pointer), 30 template pages, and 30 recipe pages (27 ready, 3 draft). These are declaration counts; selectable source-function registries are not additional globally validated branches.
- R 4.5.0 was downloaded from the official CRAN cloud mirror, SHA-256 A0EE32E4EACDD003FAADA9D41DCB3264A441B81DB00B0E6BA10F247AB21BB397, valid Authenticode signer Martyn Plummer. Installation succeeded in the isolated environment root.
- A dedicated Python 3.12.7 venv successfully installed all 22 pinned Wiki requirements; pip check reports no broken requirements. The ML environment is separate and dependency installation is in progress.
- Machine-local config was created in the development skill's ignored config.json with explicit sibling-checkout paths and the isolated R/Python paths. No repository source changes were needed for this temporary configuration.

## Evidence references

## Current findings (2026-11-04)

- Current environment availability supersedes the initial inventory above: isolated R 4.5.0, Wiki Python 3.12, scientific Python 3.12 and SCP Python 3.8 are prepared. Namespace/import success is recorded separately from actual analysis execution.
- Template replay reports template-python-replay2.json and template-r-replay2.json bind fresh outputs and unchanged code/example files; all 30 passed software execution checks.
- Recipe output requirements included commented exports and mutually exclusive plot modes. Four metadata-only corrections now match the unchanged upstream default behavior; all four reruns passed.
- The FigureYa293 GSE62254 gzip is truncated upstream as well as locally (matching hashes); its final sample lacks thousands of gene columns. Dropping or imputing that sample requires the author's decision and has not occurred.
- dplyr's removed .dots API and the historical GSVA function signature require an explicit compatibility strategy. The proposed old GSVA release is a candidate, not a proven historical environment.
- Runtime closure hashes bind the complete runtime.json bytes, including evidence pointers. Formal Python evidence adoption therefore preserves those bytes, changes only algorithm pointers in pages and links new portability receipts as supplemental evidence.
- Public pancreas has genuine velocity layers but only one orig.ident level. It supports velocity execution; it does not justify fabricated batch labels for Harmony/integration.
- A source-function registry is not a globally runnable scientific method: missing private data, bindings, gene universe, trajectory roots and model choices remain precise blockers.

- README.md
- 知识库/AGENTS.md
- 文档/Windows迁移与验证-20261102.md
- 文档/迁移验证清单-20261102/unverified-branches.json
- 依赖清单/README.md
- ../jjd-wiki-dev/staged/research-wiki/SKILL.md
- ../jjd-wiki-dev/staged/research-wiki/references/method-families.md
