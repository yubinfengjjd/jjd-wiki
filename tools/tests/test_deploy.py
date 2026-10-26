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
    """开发仓库替身（含 staged/research-wiki）+ --bare 远端 + 5 处技能目录替身。"""
    remote = tmp_path / "dev-remote.git"
    subprocess.run(["git", "init", "-q", "--bare", "-b", "main", str(remote)], check=True)
    dev = tmp_path / "开发"
    skill = dev / "staged" / "research-wiki"
    skill.mkdir(parents=True)
    git(dev, "init", "-q", "-b", "main")
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


def run_main(module, monkeypatch, record):
    monkeypatch.setattr(sys, "argv", ["deploy.py", str(record), "测试部署"])
    module.main()


def test_source_gate_matches_reference(layout, tmp_path, monkeypatch):
    """Feature: github-structured-workflow, Property 13: 部署来源判定"""
    module, dev, skill, home = layout
    base = git(dev, "rev-parse", "HEAD")
    rng = random.Random(SEED)
    for iteration in range(ITERATIONS):
        info = f"seed={SEED} iteration={iteration}"
        git(dev, "checkout", "-q", "--detach", base)
        git(dev, "reset", "-q", "--hard", base)
        on_main = rng.random() < 0.4
        tagged = rng.random() < 0.5
        tag_pushed = tagged and rng.random() < 0.6
        dirty = rng.random() < 0.3
        if on_main:
            git(dev, "checkout", "-q", "main")
            git(dev, "reset", "-q", "--hard", "origin/main")
        else:
            git(dev, "checkout", "-q", "-B", f"work{iteration % 3}", base)
            (skill / "wiki.py").write_text(f"print({iteration})\n", encoding="utf-8")
            git(dev, "commit", "-q", "-am", f"local {iteration}")
        if tagged:
            tag = f"v{iteration}"
            git(dev, "tag", tag)
            if tag_pushed:
                git(dev, "push", "-q", "origin", tag)
        if dirty:
            (skill / "scratch.txt").write_text("未提交\n", encoding="utf-8")
        allowed = not dirty and (on_main or tag_pushed)
        before = snapshot(home)
        record = tmp_path / f"record-{iteration}"
        if allowed:
            gate = module.source_gate()
            assert gate == {"commit": git(dev, "rev-parse", "HEAD"),
                            "tag": None if on_main else f"v{iteration}"}, info
        else:
            with pytest.raises(SystemExit) as stopped:
                run_main(module, monkeypatch, record)
            message = str(stopped.value.code)
            assert git(dev, "rev-parse", "HEAD") in message and "当前分支" in message, info
            assert snapshot(home) == before and not record.exists(), info
        (skill / "scratch.txt").unlink(missing_ok=True)


def test_deploy_from_main_records_source_commit(layout, tmp_path, monkeypatch):
    module, dev, skill, home = layout
    record = tmp_path / "record"
    run_main(module, monkeypatch, record)
    head = git(dev, "rev-parse", "HEAD")
    for host in module.HOSTS:
        manifest = json.loads((home / host / "skills/research-wiki/installation-manifest.json").read_text("utf-8"))
        assert manifest["source_commit"] == head and manifest["source_tag"] is None
        assert (home / host / "skills/research-wiki/wiki.py").read_bytes() == (skill / "wiki.py").read_bytes()
    assert module.verify_only() == 0


def test_verify_only_lists_differences_without_writing(layout, capsys):
    module, dev, skill, home = layout
    (skill / "wiki.py").write_text("print('changed')\n", encoding="utf-8")
    before = snapshot(home)
    assert module.verify_only() == 1
    report = json.loads(capsys.readouterr().out)
    assert report["consistent"] is False
    assert all(entry["missing"] == ["wiki.py"] and entry["different"] == [] for entry in report["hosts"])
    assert snapshot(home) == before
