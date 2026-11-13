"""Launch R with the real Windows architecture when the parent environment omitted it."""
from pathlib import Path
import ctypes
import os
import subprocess

def native_windows_architecture():
    if os.name != "nt":
        return None
    info = ctypes.create_string_buffer(64)
    get_info = ctypes.windll.kernel32.GetNativeSystemInfo
    get_info.argtypes = [ctypes.c_void_p]
    get_info.restype = None
    get_info(ctypes.byref(info))
    code = int.from_bytes(info.raw[:2], "little")
    names = {0: "x86", 9: "AMD64", 12: "ARM64"}
    if code not in names:
        raise RuntimeError(f"Unrecognized real Windows architecture: {code}")
    return names[code]

def run_r_script(rscript, script, arguments=(), *, extra_env=None, cwd=None, timeout=None):
    rscript = Path(rscript).resolve(strict=True)
    script = Path(script).resolve(strict=True)
    env = os.environ.copy()
    if extra_env:
        env.update({str(k): str(v) for k, v in extra_env.items()})
    actual = native_windows_architecture()
    applied = {}
    if actual and not env.get("PROCESSOR_ARCHITECTURE"):
        env["PROCESSOR_ARCHITECTURE"] = actual
        applied["PROCESSOR_ARCHITECTURE"] = actual
    command = [str(rscript), "--vanilla", str(script), *map(str, arguments)]
    result = subprocess.run(command, env=env, cwd=cwd, timeout=timeout,
                            capture_output=True, text=True, encoding="utf-8", errors="replace",
                            creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
    return {"returncode": result.returncode, "stdout": result.stdout, "stderr": result.stderr,
            "command": command, "environment_applied": applied, "actual_architecture": actual}
