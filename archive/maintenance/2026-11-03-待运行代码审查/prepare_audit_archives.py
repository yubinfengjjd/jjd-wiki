"""Tokenize local paths and omit expanded object dumps from new audit copies.

Raw execution records stay outside the repositories. Historical Wiki receipts,
source originals and candidate records without local paths are left untouched.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--env-root", type=Path, required=True)
    parser.add_argument("--skill", type=Path, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parent
    vault = root.parents[1]
    roots = [(args.env_root.resolve(), "<ENV_ROOT>"),
             (args.skill.resolve(), "<SKILL>"), (vault, "<VAULT>"),
             (Path.home(), "<HOME>")]

    def transform(value):
        if isinstance(value, dict):
            result = {}
            for key, item in value.items():
                if key == "error_calls" and isinstance(item, list):
                    result["error_call_symbols"] = [str(call).split("(", 1)[0][:120] for call in item]
                    result["error_calls_archive_note"] = "Expanded public objects omitted; raw calls retained in the external execution audit."
                else:
                    result[transform(key)] = transform(item)
            return result
        if isinstance(value, list):
            return [transform(item) for item in value]
        if isinstance(value, str):
            for path, token in roots:
                for separator in ("/", "\\", "\\\\", "\\\\\\\\"):
                    value = value.replace(str(path).replace("\\", "/").replace("/", separator), token)
            return value
        return value

    changed = []
    for path in root.rglob("*.json"):
        before = path.read_text(encoding="utf-8")
        value = json.loads(before)
        after = transform(value)
        if after != value:
            if isinstance(value, dict) and "execution_audit" in value:
                audit = value["execution_audit"]
                argv = audit.get("argv", [])
                if len(argv) > 2 and "<ENV_ROOT>" in argv[2]:
                    run = args.env_root / argv[2].split("<ENV_ROOT>", 1)[1].lstrip("/\\")
                    raw = run.parent / "execution-audit.json"
                    if raw.is_file():
                        after["raw_external_audit"] = {
                            "path": transform(str(raw)), "bytes": raw.stat().st_size,
                            "sha256": hashlib.sha256(raw.read_bytes()).hexdigest()}
            writable = Path("\\\\?\\" + str(path)) if os.name == "nt" else path
            writable.write_text(json.dumps(after, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            changed.append(path.relative_to(root).as_posix())
    print(json.dumps({"updated_archive_copies": changed}, ensure_ascii=False))


if __name__ == "__main__":
    main()
