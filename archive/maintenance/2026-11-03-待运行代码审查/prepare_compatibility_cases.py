"""Prepare author-approved, separate compatibility cases without changing source."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import zipfile


def main():
    audit = Path(__file__).resolve().parent
    vault = audit.parents[1]
    root = vault.parent / "research-wiki-env"
    code = 'import importlib.metadata as m,json; print(json.dumps({d.metadata["Name"].lower():d.version for d in m.distributions()},sort_keys=True))'
    versions = {}
    for profile in ("scp-legacy", "scp-velocity-numpy123"):
        versions[profile] = json.loads(subprocess.check_output(
            [str(root / profile / "python.exe"), "-c", code], text=True, encoding="utf-8"))
    before, after = versions.values()
    delta = {name: [before.get(name), after.get(name)] for name in before.keys() | after.keys()
             if before.get(name) != after.get(name)}
    assert delta == {"numpy": ["1.24.4", "1.23.5"]}, delta
    record = {"author_approved": True, "copy_method": "conda --clone --offline",
              "package_versions": versions, "changed_packages": delta,
              "pip_check": "No broken requirements found",
              "wheel_sha256": "ca51fcfcc5f9354c45f400059e88bc09215fb71a48d3768fb80e357f3b457e1e"}
    (audit / "velocity-execution/compatibility-environment.json").write_text(
        json.dumps(record, indent=2) + "\n", encoding="utf-8")
    mapping = json.loads((audit / "method-replay/replay-map.json").read_text(encoding="utf-8"))
    branch = next(item for item in mapping["implementations"] if item["method"] == "rna-velocity")
    branch["runtime"] = json.loads((vault / "知识库/methods/rna-velocity/runtime.json").read_text(encoding="utf-8"))["implementations"][0]
    branch["driver"]["case"]["parameters"]["basis"] = "PCA"
    branch["driver"]["case"]["display_note"] = (
        "Explicit existing PCA embedding bypasses the upstream broken default 'basis' alias; "
        "velocity inference parameters and observed coordinates are unchanged.")
    target = root / "profiles/velocity-pca-case.json"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(mapping, ensure_ascii=False, indent=2), encoding="utf-8")
    config_path = root / "profiles/recipe61/config.json"
    config = json.loads(config_path.read_text(encoding="utf-8"))
    config["env"]["vars"]["R_USER_CACHE_DIR"] = str(root / "profiles/recipe61/cache")
    config_path.write_text(json.dumps(config, ensure_ascii=False, indent=2), encoding="utf-8")
    environment = {**os.environ, "R_USER_CACHE_DIR": config["env"]["vars"]["R_USER_CACHE_DIR"],
                   "LC_ALL": "", "LC_CTYPE": "", "LANG": "English_United States.utf8"}
    cache = Path(subprocess.check_output([str(root / "R-4.5.0/bin/x64/Rscript.exe"), "--vanilla", "-e",
                 'cat(tools::R_user_dir("msigdbr","cache"))'], env=environment, text=True).strip())
    cache.mkdir(parents=True, exist_ok=True)
    archive = root / "downloads/msigdb.2026.1.zip"
    assert hashlib.md5(archive.read_bytes()).hexdigest() == "512ba99c6827141a9d471972b812d4ac"
    shutil.copy2(archive, cache / archive.name)
    with zipfile.ZipFile(archive) as document:
        assert all((cache / item.filename).resolve().is_relative_to(cache.resolve()) for item in document.infolist())
        document.extractall(cache)
    data_record = {"url": "https://zenodo.org/records/18968178/files/msigdb.2026.1.zip?download=1",
                   "version": "2026.1", "md5": "512ba99c6827141a9d471972b812d4ac",
                   "sha256": hashlib.sha256(archive.read_bytes()).hexdigest(),
                   "bytes": archive.stat().st_size,
                   "scope": "Exact current msigdbr package archive; no replacement gene sets or shipped-snapshot substitution."}
    (audit / "remaining-recipes/msigdbr-cache.json").write_text(json.dumps(data_record, indent=2) + "\n", encoding="utf-8")
    print("Only NumPy version differs; exact official MSigDB archive cached; explicit PCA display case prepared")


if __name__ == "__main__":
    main()
