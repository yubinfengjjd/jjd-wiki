"""Resolve the supported development checkouts without creating directories."""
import os
from pathlib import Path


def resolve_dev_root(vault_root: Path, override: Path | str | None = None) -> Path:
    """Prefer a valid nested checkout, then the standard sibling checkout."""
    vault_root = Path(vault_root).resolve()
    explicit = override if override is not None else os.environ.get("RWIKI_DEV_ROOT")
    candidates = ([Path(explicit)] if explicit is not None else
                  [vault_root / "开发", vault_root.parent / "jjd-wiki-dev"])
    for candidate in candidates:
        candidate = candidate.expanduser().resolve()
        skill = candidate / "staged/research-wiki"
        if all((skill / name).is_file() for name in ("wiki.py", "config.example.json")):
            return candidate
    label = "Invalid development checkout" if explicit is not None else "Development checkout not found"
    raise ValueError(f"{label}: {', '.join(str(p) for p in candidates)}. "
                     "Expected staged/research-wiki/wiki.py and config.example.json; "
                     "set --dev-root or RWIKI_DEV_ROOT to an existing checkout.")


def resolve_input_path(vault_root: Path, name: str, dev_root: Path | None = None) -> Path:
    """Keep historical manifest keys portable across nested and sibling layouts."""
    relative = Path(name)
    if relative.parts and relative.parts[0] == "开发":
        return (dev_root or resolve_dev_root(vault_root)).joinpath(*relative.parts[1:])
    return vault_root / relative
