"""Resolve the supported development checkouts without creating directories."""
import os
from pathlib import Path

VAULT_LAYOUT = {'知识库': 'wiki', '画廊': 'gallery', '文档': 'archive/docs',
                '维护记录': 'archive/maintenance', 'obsidian-vault': 'integrations/obsidian'}
DEV_LAYOUT = {'staged/research-wiki': 'skills/research-wiki', 'frontend': 'apps/web',
              'staged/integration-patches.md': 'archive/staged/integration-patches.md',
              'obsidian-neural-view': 'plugins/obsidian-neural-view', 'review': 'archive/review',
              'operations': 'archive/operations', 'spec/api.md': 'docs/api.md',
              'spec/scenario_taxonomy.yaml': 'docs/scenario_taxonomy.yaml',
              'spec/2026-10-22-obsidian-neural-view-plan.md': 'archive/spec/2026-10-22-obsidian-neural-view-plan.md',
              'qa': 'tests/e2e', 'replications': 'examples/replications'}


def layout_path(root: Path, name: str, mapping: dict) -> Path:
    """Canonical paths take precedence; absent paths retain legacy fallback."""
    relative = Path(name).as_posix()
    for old, new in sorted(mapping.items(), key=lambda item: -len(item[0])):
        for prefix in (old, new):
            if relative == prefix or relative.startswith(prefix + '/'):
                tail = relative[len(prefix):].lstrip('/')
                canonical = Path(root) / new
                return (canonical if canonical.exists() else Path(root) / old) / tail
    return Path(root) / name


def resolve_skill_root(dev_root: Path) -> Path:
    return layout_path(dev_root, 'staged/research-wiki', DEV_LAYOUT)


def resolve_dev_root(vault_root: Path, override: Path | str | None = None) -> Path:
    """Prefer a valid nested checkout, then the standard sibling checkout."""
    vault_root = Path(vault_root).resolve()
    explicit = override if override is not None else os.environ.get("RWIKI_DEV_ROOT")
    candidates = ([Path(explicit)] if explicit is not None else
                  [vault_root / "开发", vault_root.parent / "jjd-wiki-dev"])
    for candidate in candidates:
        candidate = candidate.expanduser().resolve()
        skill = resolve_skill_root(candidate)
        if all((skill / name).is_file() for name in ("wiki.py", "config.example.json")):
            return candidate
    label = "Invalid development checkout" if explicit is not None else "Development checkout not found"
    raise ValueError(f"{label}: {', '.join(str(p) for p in candidates)}. "
                     "Expected skills/research-wiki (or legacy staged/research-wiki) with wiki.py and config.example.json; "
                     "set --dev-root or RWIKI_DEV_ROOT to an existing checkout.")


def resolve_input_path(vault_root: Path, name: str, dev_root: Path | None = None) -> Path:
    """Keep historical manifest keys portable across nested and sibling layouts."""
    relative = Path(name)
    if relative.parts and relative.parts[0] == "开发":
        return layout_path(dev_root or resolve_dev_root(vault_root), Path(*relative.parts[1:]).as_posix(), DEV_LAYOUT)
    return layout_path(vault_root, name, VAULT_LAYOUT)
