import importlib.util
import json
import random
import subprocess
import sys
from pathlib import Path

import pytest

TOOLS = Path(__file__).resolve().parents[1]
SEED = 20261107
ITERATIONS = 100


def load_deploy():
    spec = importlib.util.spec_from_file_location("deploy_under_test", TOOLS / "deploy.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def git(repo, *args):
    return subprocess.run(["git", "-C", str(repo), *args], check=True, capture_output=True,
                          text=True, encoding="utf-8").stdout.strip()


@pytest.fixture
def layout(tmp_path):
    """开发仓库替身（含 staged/research-wiki）+ --bare 远端 + 6 处技能目录替身。"""
    remote = tmp_path / "dev-remote.git"
    # git < 2.28 lacks ``init -b``; init + symbolic-ref is equivalent.
    subprocess.run(["git", "init", "-q", "--bare", str(remote)], check=True)
    subprocess.run(["git", "-C", str(remote), "symbolic-ref", "HEAD", "refs/heads/main"], check=True)
    dev = tmp_path / "开发"
    skill = dev / "staged" / "research-wiki"
    skill.mkdir(parents=True)
    git(dev, "init", "-q")
    git(dev, "symbolic-ref", "HEAD", "refs/heads/main")
    for key, value in (("user.name", "tester"), ("user.email", "t@localhost"), ("core.autocrlf", "true")):
        git(dev, "config", key, value)
    (skill / "wiki.py").write_text("print('wiki')\n", encoding="utf-8")
    (skill / "config.json").write_text("{}\n", encoding="utf-8")
    git(dev, "add", "-A")
    git(dev, "commit", "-q", "-m", "init")
    git(dev, "remote", "add", "origin", str(remote))
    git(dev, "push", "-q", "-u", "origin", "main")
    home = tmp_path / "home"
    module = load_deploy()
    module.HOME, module.SOURCE, module.DEV = home, skill, dev
    for host in module.HOSTS:
        target = home / host / "skills" / "research-wiki"
        target.mkdir(parents=True)
        (target / "config.json").write_text("{}\n", encoding="utf-8")
    return module, dev, skill, home


def snapshot(home: Path) -> dict:
    return {p.relative_to(home).as_posix(): p.read_bytes() for p in sorted(home.rglob("*")) if p.is_file()}


def run_main(module, monkeypatch, record, *extra):
    monkeypatch.setattr(sys, "argv", ["deploy.py", str(record), "测试部署", *extra])
    module.main()


def rejected(module, monkeypatch, record, home) -> str:
    """部署被拒：返回中止信息，并确认技能目录零写入、维护记录目录未创建。"""
    before = snapshot(home)
    with pytest.raises(SystemExit) as stopped:
        run_main(module, monkeypatch, record)
    assert snapshot(home) == before and not record.exists()
    return str(stopped.value.code)


def test_source_gate_matches_reference(layout, tmp_path, monkeypatch):
    """Feature: github-structured-workflow, Property 13: 部署来源判定（治理 v2：本地 main 也可部署）"""
    module, dev, skill, home = layout
    base = git(dev, "rev-parse", "HEAD")
    rng = random.Random(SEED)
    for iteration in range(ITERATIONS):
        info = f"seed={SEED} iteration={iteration}"
        git(dev, "checkout", "-q", "--detach", base)
        git(dev, "reset", "-q", "--hard", base)
        # main: HEAD=本地 main=origin/main；main-ahead: 本地 main 有未推送提交；
        # origin: HEAD=origin/main 而本地 main 已前进；branch: 其他分支上的新提交
        mode = rng.choice(("main", "main-ahead", "origin", "branch"))
        tagged = rng.random() < 0.5
        tag_pushed = tagged and rng.random() < 0.6
        dirty = rng.random() < 0.3
        if mode == "branch":
            git(dev, "checkout", "-q", "-B", f"work{iteration % 3}", base)
        else:
            git(dev, "checkout", "-q", "main")
            git(dev, "reset", "-q", "--hard", "origin/main")
        if mode != "main":
            (skill / "wiki.py").write_text(f"print({iteration})\n", encoding="utf-8")
            git(dev, "commit", "-q", "-am", f"local {iteration}")
        if mode == "origin":
            git(dev, "checkout", "-q", "--detach", "origin/main")
        if tagged:
            tag = f"v{iteration}"
            git(dev, "tag", tag)
            if tag_pushed:
                git(dev, "push", "-q", "origin", tag)
        if dirty:
            (skill / "scratch.txt").write_text("未提交\n", encoding="utf-8")
        ref = {"main": "main", "main-ahead": "main", "origin": "origin/main"}.get(mode)
        if mode == "branch" and tag_pushed:
            ref = f"v{iteration}"
        record = tmp_path / f"record-{iteration}"
        if not dirty and ref:
            gate = module.source_gate()
            assert gate == {"commit": git(dev, "rev-parse", "HEAD"), "ref": ref,
                            "tag": ref if mode == "branch" else None}, info
        else:
            message = rejected(module, monkeypatch, record, home)
            assert git(dev, "rev-parse", "HEAD") in message and "当前分支" in message, info
        (skill / "scratch.txt").unlink(missing_ok=True)


def test_hosts_include_kiro():
    assert load_deploy().HOSTS == (".agents", ".codex", ".claude", ".cc-switch", ".config/opencode", ".kiro")


def test_deploy_from_main_records_source_commit(layout, tmp_path, monkeypatch):
    module, dev, skill, home = layout
    record = tmp_path / "record"
    run_main(module, monkeypatch, record)
    head = git(dev, "rev-parse", "HEAD")
    for host in module.HOSTS:
        manifest = json.loads((home / host / "skills/research-wiki/installation-manifest.json").read_text("utf-8"))
        assert (manifest["source_commit"], manifest["source_ref"], manifest["source_tag"]) == (head, "main", None)
        assert (home / host / "skills/research-wiki/wiki.py").read_bytes() == (skill / "wiki.py").read_bytes()
    assert module.verify_only() == 0


def test_local_main_ahead_of_origin_deploys_even_offline(layout, tmp_path, monkeypatch):
    """治理 v2：本地 main 的未推送提交可以部署；fetch 失败（离线）不影响。"""
    module, dev, skill, home = layout
    (skill / "wiki.py").write_text("print('local main')\n", encoding="utf-8")
    git(dev, "commit", "-q", "-am", "local only")
    git(dev, "remote", "set-url", "origin", str(tmp_path / "offline.git"))
    record = tmp_path / "record"
    run_main(module, monkeypatch, record)
    head = git(dev, "rev-parse", "HEAD")
    assert head != git(dev, "rev-parse", "origin/main")
    for host in module.HOSTS:
        target = home / host / "skills/research-wiki"
        manifest = json.loads((target / "installation-manifest.json").read_text("utf-8"))
        assert (manifest["source_commit"], manifest["source_ref"], manifest["source_tag"]) == (head, "main", None)
        assert (target / "wiki.py").read_bytes() == (skill / "wiki.py").read_bytes()


def test_uncommitted_changes_rejected(layout, tmp_path, monkeypatch):
    module, dev, skill, home = layout
    (skill / "wiki.py").write_text("print('uncommitted')\n", encoding="utf-8")
    message = rejected(module, monkeypatch, tmp_path / "record", home)
    assert "未提交改动" in message and git(dev, "rev-parse", "HEAD") in message


def test_head_off_main_rejected(layout, tmp_path, monkeypatch):
    module, dev, skill, home = layout
    git(dev, "checkout", "-q", "-b", "feature")
    (skill / "wiki.py").write_text("print('feature')\n", encoding="utf-8")
    git(dev, "commit", "-q", "-am", "feature work")
    message = rejected(module, monkeypatch, tmp_path / "record", home)
    assert "当前分支: feature" in message and git(dev, "rev-parse", "HEAD") in message
    # 离线时 origin/main（本地 main 已前进）也不认
    git(dev, "checkout", "-q", "main")
    git(dev, "merge", "-q", "--ff-only", "feature")
    git(dev, "checkout", "-q", "--detach", "origin/main")
    git(dev, "remote", "set-url", "origin", str(tmp_path / "offline.git"))
    message = rejected(module, monkeypatch, tmp_path / "record", home)
    assert "fetch origin 失败" in message and git(dev, "rev-parse", "HEAD") in message


def test_sync_config_backs_up_then_copies(layout, tmp_path, monkeypatch):
    module, dev, skill, home = layout
    old = {}
    for index, host in enumerate(module.HOSTS):
        config = home / host / "skills/research-wiki/config.json"
        config.write_text(f'{{"host": {index}}}\n', encoding="utf-8")
        old[host] = config.read_bytes()
    record = tmp_path / "record"
    message = rejected(module, monkeypatch, record, home)
    assert "--sync-config" in message
    assert all(str(home / host / "skills/research-wiki/config.json") in message for host in module.HOSTS)
    run_main(module, monkeypatch, record, "--sync-config")
    report = json.loads((record / "deployment-verification.json").read_text("utf-8"))
    for host, entry in zip(module.HOSTS, report):
        target = home / host / "skills/research-wiki"
        assert (target / "config.json").read_bytes() == (skill / "config.json").read_bytes()
        assert (record / "backup" / host / "research-wiki/config.json").read_bytes() == old[host]
        assert "config.json" in entry["changed"]
    assert module.verify_only() == 0


def test_stale_files_removed_anywhere_with_backup(layout, tmp_path, monkeypatch):
    module, dev, skill, home = layout
    stale = {"app/assets/index-old.js": b"js\n", "notes.txt": b"n\n",
             "references/old-contract.md": b"old\n", "rwiki/legacy/mod.py": b"x = 1\n"}
    kept = ("__pycache__/wiki.cpython-312.pyc", "rwiki/__pycache__/cli.cpython-312.pyc",
            ".pytest_cache/v/cache/lastfailed", "stray.pyc")
    for host in module.HOSTS:
        target = home / host / "skills/research-wiki"
        for name, data in [*stale.items(), *((name, b"keep") for name in kept), (module.MANIFEST, b"{}")]:
            (target / name).parent.mkdir(parents=True, exist_ok=True)
            (target / name).write_bytes(data)
    record = tmp_path / "record"
    run_main(module, monkeypatch, record)
    report = json.loads((record / "deployment-verification.json").read_text("utf-8"))
    assert [entry["stale_removed"] for entry in report] == [sorted(stale)] * len(module.HOSTS)
    for host in module.HOSTS:
        target = home / host / "skills/research-wiki"
        backup = record / "backup" / host / "research-wiki"
        for name, data in stale.items():
            assert not (target / name).exists() and (backup / name).read_bytes() == data
        assert not any((target / name).exists() for name in ("app", "references", "rwiki/legacy"))
        assert all((target / name).read_bytes() == b"keep" for name in kept)
        assert (target / "config.json").is_file() and (backup / module.MANIFEST).read_bytes() == b"{}"
    assert module.verify_only() == 0


def test_verify_only_classifies_differences_without_writing(layout, tmp_path, monkeypatch, capsys):
    module, dev, skill, home = layout
    run_main(module, monkeypatch, tmp_path / "record")
    capsys.readouterr()
    (skill / "wiki.py").write_text("print('changed')\n", encoding="utf-8")
    (skill / "references").mkdir()
    (skill / "references/new.md").write_text("new\n", encoding="utf-8")
    kiro = home / ".kiro/skills/research-wiki"
    (kiro / "references").mkdir()
    (kiro / "references/old.md").write_text("old\n", encoding="utf-8")
    (kiro / "__pycache__").mkdir()
    (kiro / "__pycache__/wiki.cpython-312.pyc").write_bytes(b"pyc")
    before = snapshot(home)
    monkeypatch.setattr(sys, "argv", ["deploy.py", "--verify-only"])
    with pytest.raises(SystemExit) as stopped:
        module.main()
    assert stopped.value.code == 1
    report = json.loads(capsys.readouterr().out)
    assert report["consistent"] is False
    assert [entry["host"] for entry in report["hosts"]] == list(module.HOSTS)
    for entry in report["hosts"]:
        assert entry["missing"] == ["references/new.md"] and entry["different"] == ["wiki.py"]
        assert entry["extra"] == (["references/old.md"] if entry["host"] == ".kiro" else [])
    assert snapshot(home) == before
