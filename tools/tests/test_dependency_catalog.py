"""The export must cover real declarations while preserving incompatible source profiles."""
import csv
import hashlib
import importlib.util
import json
import os
import re
import subprocess
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools"))
from machine_paths import resolve_dev_root, resolve_input_path

CATALOG = ROOT / "文档/依赖清单"


def rows(path):
    with path.open(encoding="utf-8") as stream:
        return list(csv.DictReader(stream, delimiter="\t"))


def test_every_runtime_declaration_is_accounted_for():
    actual = {(r["ecosystem"], r["package"]) for r in rows(CATALOG / "packages.tsv")}
    excluded = {r["package"] for r in rows(CATALOG / "excluded-or-built-in.tsv")}
    assert len(actual) == len(rows(CATALOG / "packages.tsv"))
    for path in (ROOT / "知识库").glob("*/*/runtime.json"):
        record = json.loads(path.read_text(encoding="utf-8"))
        for branch in record.get("implementations", [record]):
            for field in ("required_packages", "optional_packages"):
                for language, packages in branch.get(field, {}).items():
                    for package in packages:
                        assert (language, package) in actual or (language == "R" and package in excluded), (path, package)
    assert not ({("R", p) for p in ("p", "org_sp", "idconvert", "blueviolet", "phylum")} & actual)


def test_manifest_binds_current_declarations_and_artifacts():
    manifest = json.loads((CATALOG / "manifest.json").read_text(encoding="utf-8"))
    for field, base in (("inputs_sha256", ROOT), ("artifacts_sha256", CATALOG)):
        for name, expected in manifest[field].items():
            path = resolve_input_path(ROOT, name) if field == "inputs_sha256" else base / name
            assert hashlib.sha256(path.read_bytes()).hexdigest() == expected, name
    assert (CATALOG / "python/wiki.requirements.lock.txt").read_bytes() == (resolve_dev_root(ROOT) / "staged/research-wiki/requirements.lock.txt").read_bytes()


def test_legacy_scp_pins_are_not_combined_with_modern_candidates():
    profiles = json.loads((CATALOG / "python/scp-legacy-profiles.json").read_text(encoding="utf-8"))
    assert profiles["3.8-2"]["python"] == "3.8"
    assert "scanpy==1.9.5" in profiles["3.8-2"]["requirements"]
    assert "scvelo==0.2.5" in profiles["3.8-2"]["requirements"]
    assert profiles["3.11-1"]["python"] == "3.10"  # preserve the upstream inconsistency explicitly
    for name, profile in profiles.items():
        lines = (CATALOG / f"python/scp-legacy-{name}.requirements.txt").read_text(encoding="utf-8").splitlines()
        assert [line for line in lines if line and not line.startswith("#")] == profile["requirements"]
    assert "scvelo==0.2.5" not in (CATALOG / "python/ml.requirements.txt").read_text(encoding="utf-8")


def test_python_declared_distributions_all_have_batch_inputs():
    canonical = lambda name: name.lower().replace("_", "-").replace(".", "-")
    available = set()
    for path in (CATALOG / "python").glob("*.txt"):
        for line in path.read_text(encoding="utf-8").splitlines():
            if line and not line.startswith("#"):
                available.add(canonical(re.split(r"[<>=~!;\[]", line, maxsplit=1)[0]))
    for row in rows(CATALOG / "packages.tsv"):
        if row["ecosystem"] == "Python":
            assert canonical(row["package"]) in available, row["package"]


def test_special_sources_are_pinned_and_unresolved_sources_remain_visible():
    plan = rows(CATALOG / "R/plan.tsv")
    for row in plan:
        if row["installer"] == "github":
            ref = row["spec"].rsplit("@", 1)[-1]
            assert len(ref) == 40 and all(c in "0123456789abcdef" for c in ref)
    unresolved = {row["package"] for row in rows(CATALOG / "R/unresolved.tsv") if row["runtime"] == "1"}
    assert "ggcor" not in unresolved
    ggcor = next(row for row in plan if row["package"] == "ggcor")
    assert ggcor["installer"] == "archive"
    assert "/8d7a02c7d00467c45471139b63620571afebbeba/" in ggcor["spec"]
    snapshot = json.loads((CATALOG / "repository-snapshot.json").read_text(encoding="utf-8"))
    archive = ROOT / "知识库/recipes/figureya-228linkcor/source/ggcor-master.tar.gz"
    assert hashlib.sha256(archive.read_bytes()).hexdigest() == snapshot["packages"]["ggcor"]["archive_sha256"]
    scp = next(row for row in plan if row["package"] == "SCP")
    assert scp["catalog_version"] == "0.5.6"


def test_description_parser_preserves_version_constraints():
    spec = importlib.util.spec_from_file_location("dependency_export", ROOT / "tools/export-dependencies.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    parsed = module.description("Package: demo\nImports:\n    Matrix (>= 1.5),\n    Seurat\nVersion: 1.0\n")
    assert parsed["Imports"] == " Matrix (>= 1.5), Seurat"
    assert parsed["Version"] == "1.0"


@pytest.mark.skipif(os.environ.get("CI") == "true", reason="Local R presence check; no packages installed in CI")
def test_r_presence_check_does_not_install_into_missing_library(tmp_path):
    rscript = Path("D:/R-4.5.0/bin/Rscript.exe")
    if not rscript.is_file():
        pytest.skip("Local Rscript is not available")
    library, report = tmp_path / "not-created", tmp_path / "report"
    helper_path = ROOT / "知识库/methods/local-omics-analysis-guide/code/run_r.py"
    helper_spec = importlib.util.spec_from_file_location("existing_r_child_helper", helper_path)
    helper = importlib.util.module_from_spec(helper_spec)
    helper_spec.loader.exec_module(helper)
    environment = dict(os.environ)
    actual = helper.native_windows_architecture()
    if actual:
        environment["PROCESSOR_ARCHITECTURE"] = actual
    result = subprocess.run([str(rscript), "--vanilla", str(CATALOG / "R/install-batch.R"),
                             "--lib", str(library), "--profile", "pending", "--report", str(report)],
                            env=environment,
                            capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=120)
    assert result.returncode in (0, 2), result.stdout + result.stderr
    assert not library.exists()
    assert (report / "R-pending.tsv").is_file()
