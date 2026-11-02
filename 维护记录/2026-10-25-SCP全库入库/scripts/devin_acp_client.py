"""Bounded local Devin ACP bridge. Credentials stay in the child environment."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import queue
import re
import shutil
import sqlite3
import subprocess
import threading
import time

EXE = Path("D:/Devin/resources/app/extensions/windsurf/devin/bin/devin.exe")
AUTH = Path("C:/Users/86186/AppData/Roaming/Devin/User/globalStorage/state.vscdb")
BASE = Path("E:/research-wiki-env/work/scp-full-ingest-20261025")
RECORD = Path("E:/research-wiki/维护记录/2026-10-25-SCP全库入库")

class Bridge:
    def __init__(self, cwd, label, pilot_root=None):
        self.cwd = Path(cwd).resolve()
        self.label = label
        self.pilot_mode = pilot_root is not None
        self.write_roots = [BASE.resolve()]
        self.no_write_roots = []
        if pilot_root is not None:
            pilot = Path(pilot_root).resolve()
            permitted = Path("E:/青光眼单细胞/wiki-use").resolve()
            if not pilot.is_relative_to(permitted) or pilot == permitted:
                raise ValueError("Pilot writes must stay in the named project wiki-use child directory")
            if not self.cwd.is_relative_to(pilot):
                raise ValueError("Pilot cwd must be inside the exact pilot output directory")
            self.write_roots = [pilot, (BASE / "pilot-evidence").resolve()]
            self.no_write_roots = [(pilot / '.agents/skills/research-wiki').resolve()]
        self.log = RECORD / "logs" / (label + "-events.jsonl")
        self.result_file = RECORD / (label + "-result.md")
        self.state_file = RECORD / (label + "-state.json")
        self.key = ""
        with sqlite3.connect(AUTH.as_uri() + "?mode=ro", uri=True) as conn:
            item = conn.execute("SELECT value FROM ItemTable WHERE key=?", ("windsurfAuthStatus",)).fetchone()
        if not item:
            raise RuntimeError("Desktop login record unavailable")
        self.key = json.loads(item[0]).get("apiKey", "")
        if not self.key:
            raise RuntimeError("Desktop login credential unavailable")
        child_env = os.environ.copy()
        child_env["WINDSURF_API_KEY"] = self.key
        child_env["RUST_LOG"] = "warn"
        self.proc = subprocess.Popen([str(EXE), "--permission-mode", "auto", "acp", "--model", "swe-2-max"],
                                     cwd=self.cwd, env=child_env, stdin=subprocess.PIPE,
                                     stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                     text=True, encoding="utf-8", errors="replace", bufsize=1)
        self.incoming = queue.Queue()
        self.lock = threading.Lock()
        self.log_lock = threading.Lock()
        self.next_id = 1
        self.responses = {}
        self.terminals = {}
        self.messages = []
        self.session_id = None
        self.state = {"label": label, "pid": self.proc.pid, "cwd": str(self.cwd),
                      "status": "initializing", "tool_events": 0, "message_chars": 0}
        threading.Thread(target=self.reader, args=(self.proc.stdout,), daemon=True).start()
        threading.Thread(target=self.stderr_reader, daemon=True).start()
        self.save_state()

    def redact(self, value):
        text = str(value).replace(self.key, "<redacted>") if self.key else str(value)
        return re.sub(r"(?i)(Bearer\s+)[A-Za-z0-9._-]+", r"\1<redacted>", text)

    def save_state(self):
        self.state["updated_at"] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
        temp = self.state_file.with_suffix(".tmp")
        temp.write_text(json.dumps(self.state, ensure_ascii=False, indent=2), encoding="utf-8")
        # Windows readers/antivirus can briefly deny an otherwise atomic
        # replace. Monitoring must not abort the coding session on that race.
        for attempt in range(16):
            try:
                temp.replace(self.state_file)
                return
            except PermissionError:
                if attempt < 15:
                    time.sleep(0.1)
        self.event("state_write_deferred", reason="transient Windows file lock", file=self.state_file.name)

    def event(self, kind, **values):
        entry = {"time": time.time(), "kind": kind, **values}
        clean = self.redact(json.dumps(entry, ensure_ascii=False))
        with self.log_lock:
            with self.log.open("a", encoding="utf-8") as stream:
                stream.write(clean + "\n")

    def reader(self, stream):
        for line in stream:
            try:
                self.incoming.put(json.loads(line))
            except ValueError:
                self.event("non_json_stdout", text=self.redact(line[:800]))
        self.incoming.put({"_eof": True})

    def stderr_reader(self):
        for line in self.proc.stderr:
            if line.strip():
                self.event("stderr", text=self.redact(line[:1200]))

    def send(self, obj):
        with self.lock:
            self.proc.stdin.write(json.dumps(obj, ensure_ascii=False) + "\n")
            self.proc.stdin.flush()

    def request(self, method, params):
        rid = self.next_id
        self.next_id += 1
        self.send({"jsonrpc": "2.0", "id": rid, "method": method, "params": params})
        return rid

    def resolve_path(self, value):
        path = Path(value)
        return path.resolve() if path.is_absolute() else (self.cwd / path).resolve()

    def allowed_path(self, value, write=False):
        path = self.resolve_path(value)
        normalized = str(path).replace("\\", "/").casefold()
        if "paper-harness" in normalized or any(p in normalized for p in
                ["/state.vscdb", "/.env", "/.ssh/", "/.aws/", "/.azure/"]):
            return False
        if write:
            if any(path.is_relative_to(root) for root in self.no_write_roots):
                return False
            return any(path.is_relative_to(root) for root in self.write_roots)
        roots = [BASE, Path("E:/research-wiki"), Path("E:/青光眼单细胞"),
                 Path("E:/research-wiki-env"), Path("D:/Devin/resources/app/extensions/windsurf/devin/share/devin/docs")]
        roots.append(Path("C:/Users/86186/.codex/skills/.system/skill-creator"))
        for host in (".agents", ".codex", ".claude", ".cc-switch", ".config/opencode"):
            roots.extend(Path("C:/Users/86186") / host / "skills" / name
                         for name in ("research-wiki", "sci-figure-replica"))
        return any(path.is_relative_to(root.resolve()) for root in roots)

    def allowed_command(self, command, args):
        value = " ".join([str(command), *map(str, args)]).casefold()
        # Consumer tests may read/execute stock analysis and maintain local
        # project state, but never administer/record use in a formal library.
        # The test's copied skill also defaults to an isolated Wiki replica.
        # This guards known CLI operations; it is not an OS filesystem sandbox.
        if getattr(self, "pilot_mode", False) and re.search(
                r"\b(?:record-use|record-method-use|scaffold-method|scaffold-template|"
                r"mark-ready|signoff|ingest-entry|ingest-figure)\b", value):
            return False
        prohibited = [
            r"paper[-_]harness", r"\bpaperflow\b", r"\b(?:pip|pip3|uv|conda|mamba)\s+(?:install|add|create)",
            r"\bnpm\s+(?:install|i\s|ci\b)", r"install\.packages", r"biocmanager\s*::\s*install",
            r"\bgit\s+(?:reset|clean|checkout|switch|commit|push|merge|rebase)\b",
            r"\b(?:remove-item|rmdir|del\s|rm\s+-|format-volume|stop-process|taskkill)\b",
            r"\b(?:curl|wget|invoke-webrequest|invoke-restmethod)\b",
            r"state\.vscdb", r"windsurf_api_key", r"\bdevin(?:\.exe)?\s+",
            r"\bclaude(?:\.exe)?\s+", r"\bcodex(?:\.exe)?\s+(?:exec|run)"
        ]
        return not any(re.search(pattern, value) for pattern in prohibited)

    def permission(self, params):
        if self.label.startswith("devin-probe"):
            self.event("permission_probe_shape", payload=self.redact(json.dumps(params, ensure_ascii=False))[:6000])
        call = params.get("toolCall", {})
        raw = call.get("rawInput") or {}
        kind = call.get("kind", "")
        title = call.get("title", "")
        metadata = call.get("_meta") or {}
        editable_command = metadata.get("cognition.ai/editableCommand")
        if not kind and str(call.get("toolCallId", "")).startswith("exec:") and editable_command:
            kind = "execute"
            title = editable_command
            raw = {"command": editable_command}
        allowed = kind in {"read", "search", "think", "other", "edit", "execute"}
        if isinstance(raw, dict):
            for key in ["file_path", "path", "filePath", "directory", "cwd"]:
                if isinstance(raw.get(key), str):
                    allowed = allowed and self.allowed_path(raw[key], write=(kind == "edit"))
            command = raw.get("command") or raw.get("cmd")
            if command:
                allowed = allowed and self.allowed_command(command, raw.get("args") or [])
        for location in call.get("locations") or []:
            if location.get("path"):
                allowed = allowed and self.allowed_path(location["path"], write=(kind == "edit"))
        if "paper-harness" in title.casefold():
            allowed = False
        options = params.get("options") or []
        desired = "allow_once" if allowed else "reject_once"
        option = next((item for item in options if item.get("kind") == desired), None)
        self.event("permission", title=title[:350], tool_kind=kind, allowed=bool(allowed and option))
        if not option:
            return {"outcome": {"outcome": "cancelled"}}
        return {"outcome": {"outcome": "selected", "optionId": option["optionId"]}}

    def callback(self, message):
        rid, method, params = message["id"], message["method"], message.get("params") or {}
        try:
            if method == "session/request_permission":
                result = self.permission(params)
            elif method == "fs/read_text_file":
                if not self.allowed_path(params["path"]):
                    raise PermissionError("Read outside authorized roots")
                lines = self.resolve_path(params["path"]).read_text(encoding="utf-8").splitlines(keepends=True)
                start = max(0, params.get("line", 1) - 1)
                result = {"content": "".join(lines[start:start + params.get("limit", len(lines))])}
            elif method == "fs/write_text_file":
                if not self.allowed_path(params["path"], write=True):
                    raise PermissionError("Write outside isolated workspace")
                target = self.resolve_path(params["path"])
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_text(params["content"], encoding="utf-8")
                result = {}
                self.event("file_write", path=str(target), sha256=hashlib.sha256(target.read_bytes()).hexdigest())
            elif method == "terminal/create":
                if self.label.startswith("devin-probe"):
                    self.event("terminal_probe_shape", command=params.get("command"), args=params.get("args"), cwd=params.get("cwd"))
                cwd = str(self.resolve_path(params.get("cwd") or str(self.cwd)))
                if not self.allowed_path(cwd, write=True) or not self.allowed_command(params["command"], params.get("args", [])):
                    raise PermissionError("Terminal command outside authorized scope")
                env = os.environ.copy()
                for item in params.get("env", []):
                    env[item["name"]] = item["value"]
                terminal_args = params.get("args")
                if terminal_args is None:
                    shell = shutil.which("pwsh") or str(Path(os.environ["SystemRoot"]) / "System32/WindowsPowerShell/v1.0/powershell.exe")
                    argv = [shell, "-NoLogo", "-NoProfile", "-NonInteractive", "-Command", params["command"]]
                else:
                    argv = [params["command"], *terminal_args]
                proc = subprocess.Popen(argv, cwd=cwd, env=env,
                                        stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                        text=True, encoding="utf-8", errors="replace")
                tid = str(proc.pid)
                entry = {"process": proc, "output": "", "truncated": False}
                self.terminals[tid] = entry
                self.state.setdefault("owned_terminal_pids", []).append(proc.pid)
                self.save_state()
                def output_reader():
                    for line in proc.stdout:
                        entry["output"] += self.redact(line)
                        if len(entry["output"]) > 500000:
                            entry["output"] = entry["output"][-500000:]
                            entry["truncated"] = True
                threading.Thread(target=output_reader, daemon=True).start()
                self.event("terminal", terminalId=tid, program=Path(params["command"]).name)
                result = {"terminalId": tid}
            elif method.startswith("terminal/"):
                entry = self.terminals[params["terminalId"]]
                proc = entry["process"]
                if method == "terminal/wait_for_exit":
                    result = {"exitCode": proc.wait()}
                elif method in {"terminal/kill", "terminal/release"}:
                    if proc.poll() is None:
                        proc.terminate()
                    result = {}
                elif method == "terminal/output":
                    result = {"output": entry["output"], "truncated": entry["truncated"]}
                    if proc.poll() is not None:
                        result["exitStatus"] = {"exitCode": proc.returncode}
                else:
                    raise NotImplementedError(method)
            else:
                raise NotImplementedError(method)
            self.send({"jsonrpc": "2.0", "id": rid, "result": result})
        except Exception as error:
            self.event("callback_rejected", method=method, error=self.redact(error))
            self.send({"jsonrpc": "2.0", "id": rid, "error": {"code": -32603, "message": self.redact(error)}})

    def wait(self, rid, seconds):
        deadline = time.monotonic() + seconds
        while time.monotonic() < deadline:
            if rid in self.responses:
                result = self.responses.pop(rid)
                if "error" in result:
                    raise RuntimeError(self.redact(json.dumps(result["error"])))
                return result.get("result", {})
            try:
                message = self.incoming.get(timeout=min(1, max(.01, deadline - time.monotonic())))
            except queue.Empty:
                if self.proc.poll() is not None:
                    raise RuntimeError("ACP process exited: " + str(self.proc.returncode))
                continue
            if message.get("_eof"):
                raise RuntimeError("ACP stdout closed")
            if "id" in message and "method" in message:
                threading.Thread(target=self.callback, args=(message,), daemon=True).start()
            elif "id" in message:
                self.responses[message["id"]] = message
            elif message.get("method") == "session/update":
                update = (message.get("params") or {}).get("update") or {}
                kind = update.get("sessionUpdate")
                if kind == "agent_message_chunk":
                    chunk = (update.get("content") or {}).get("text", "")
                    self.messages.append(self.redact(chunk))
                    self.state["message_chars"] += len(chunk)
                elif kind in {"tool_call", "tool_call_update"}:
                    self.state["tool_events"] += 1
                    if update.get("title"):
                        self.state["last_tool"] = str(update["title"])[:250]
                    self.event(kind, title=str(update.get("title", ""))[:350],
                               status=update.get("status"), toolCallId=update.get("toolCallId"))
                # Agent thought chunks are intentionally neither persisted nor displayed.
                if kind in {"tool_call", "tool_call_update", "agent_message_chunk"}:
                    self.save_state()
        raise TimeoutError("ACP request exceeded bounded wait")

    def run(self, prompt, seconds, resume=None):
        init = self.wait(self.request("initialize", {"protocolVersion": 1,
            "clientCapabilities": {"fs": {"readTextFile": True, "writeTextFile": True}, "terminal": True},
            "clientInfo": {"name": "research-wiki-bounded-review-client", "version": "1"}}), 35)
        capabilities = init.get("agentCapabilities") or {}
        self.state["load_session_supported"] = bool(capabilities.get("loadSession"))
        if resume:
            if not capabilities.get("loadSession"):
                raise RuntimeError("ACP resume unsupported; will not start a duplicate session")
            session = self.wait(self.request("session/load", {"sessionId": resume, "cwd": str(self.cwd), "mcpServers": []}), 35)
            self.session_id = resume
        else:
            session = self.wait(self.request("session/new", {"cwd": str(self.cwd), "mcpServers": []}), 35)
            self.session_id = session["sessionId"]
        modes = session.get("modes") or {}
        self.state["session_id"] = self.session_id
        self.state["modes"] = [{"id": m.get("id"), "name": m.get("name")} for m in modes.get("availableModes", [])]
        for option in session.get("configOptions", []):
            if option.get("id") == "model":
                self.state["model"] = option.get("currentValue")
        mode = next((m["id"] for m in self.state["modes"] if m.get("id") in {"normal", "code", "agent"}), None)
        if mode and modes.get("currentModeId") != mode:
            self.wait(self.request("session/set_mode", {"sessionId": self.session_id, "modeId": mode}), 20)
        self.state["status"] = "running"
        self.messages = []
        self.state["message_chars"] = 0
        self.state["tool_events"] = 0
        self.save_state()
        reply = self.wait(self.request("session/prompt", {"sessionId": self.session_id,
                          "prompt": [{"type": "text", "text": prompt}]}), seconds)
        self.state["status"] = "returned"
        self.state["stop_reason"] = reply.get("stopReason")
        self.result_file.write_text("".join(self.messages), encoding="utf-8")
        self.save_state()
        print(json.dumps({"session_id": self.session_id, "model": self.state.get("model"),
                          "modes": self.state.get("modes"), "stop_reason": self.state["stop_reason"],
                          "tool_events": self.state["tool_events"], "result_file": str(self.result_file)},
                         ensure_ascii=False))

    def close(self):
        for entry in self.terminals.values():
            if entry["process"].poll() is None:
                entry["process"].terminate()
        if self.proc.poll() is None:
            self.proc.terminate()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--cwd", required=True)
    parser.add_argument("--prompt-file", required=True)
    parser.add_argument("--label", required=True)
    parser.add_argument("--seconds", type=int, default=1800)
    parser.add_argument("--resume")
    parser.add_argument("--pilot-root", help="Exact authorized output directory for an isolated consumer test")
    args = parser.parse_args()
    bridge = Bridge(args.cwd, args.label, args.pilot_root)
    try:
        bridge.run(Path(args.prompt_file).read_text(encoding="utf-8"), args.seconds, args.resume)
    except Exception as error:
        bridge.state.update(status="failed", error=bridge.redact(error))
        if bridge.messages:
            partial = bridge.result_file.with_name(bridge.result_file.stem + "-partial.md")
            partial.write_text("Incomplete ACP turn; not a completion report.\n\n" +
                               "".join(bridge.messages), encoding="utf-8")
            bridge.state["partial_result"] = str(partial)
        bridge.save_state()
        print(json.dumps({"status": "failed", "error": bridge.redact(error),
                          "session_id": bridge.session_id}, ensure_ascii=False))
        raise SystemExit(1)
    finally:
        bridge.close()

if __name__ == "__main__":
    main()
