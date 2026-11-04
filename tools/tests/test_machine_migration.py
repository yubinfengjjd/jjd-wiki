"""Machine entrypoints support real sibling and legacy nested checkout layouts."""
import importlib.util
import json
import os
import queue
import shlex
import shutil
import subprocess
import sys
import threading
from pathlib import Path

import pytest

TOOLS = Path(__file__).resolve().parents[1]


def checkout(path):
    skill = path / "staged/research-wiki"
    (skill / "assets").mkdir(parents=True)
    (skill / "wiki.py").write_text(
        "import json, os, sys\n"
        "print(json.dumps({'args': sys.argv[1:], 'temp': os.environ.get('TEMP')}))\n",
        encoding="utf-8",
    )
    (skill / "config.example.json").write_text('{"port": 8765}\n', encoding="utf-8")
    (skill / "assets/scenario_taxonomy.json").write_text("{}", encoding="utf-8")
    return skill


def copy_tools(vault):
    destination = vault / "tools"
    destination.mkdir(parents=True)
    for name in ("configure-machine.py", "deploy.py", "machine_paths.py", "machine-paths.ps1", "launcher.ps1"):
        source = TOOLS / name
        if source.is_file():
            shutil.copy2(source, destination / name)
    (destination / "bin").mkdir()
    shutil.copy2(TOOLS / "bin/rwiki.cmd", destination / "bin/rwiki.cmd")
    shutil.copy2(TOOLS / "bin/rwiki", destination / "bin/rwiki")
    return destination


def configure(tools, tmp_path, *arguments):
    rscript = tmp_path / "Rscript.exe"
    rscript.touch()
    return subprocess.run(
        [sys.executable, "-X", "utf8", str(tools / "configure-machine.py"), "--python-exe", sys.executable,
         "--rscript-exe", str(rscript), "--env-root", str(tmp_path / "environment"), *arguments],
        capture_output=True, text=True, encoding="utf-8",
    )


@pytest.mark.parametrize("layout", ["nested", "sibling"])
def test_configure_supports_both_layouts_without_fabricating_nested_checkout(tmp_path, layout):
    vault = tmp_path / "vault"
    tools = copy_tools(vault)
    dev = vault / "开发" if layout == "nested" else tmp_path / "jjd-wiki-dev"
    skill = checkout(dev)
    result = configure(tools, tmp_path)
    assert result.returncode == 0, result.stdout + result.stderr
    config = json.loads((skill / "config.json").read_text(encoding="utf-8"))
    assert Path(config["github"]["dev_root"]) == dev
    assert Path(config["github"]["vault_root"]) == vault
    assert Path(config["python_exe"]) == Path(sys.executable).resolve()
    assert Path(config["taxonomy"]) == skill / "assets/scenario_taxonomy.json"
    if layout == "sibling":
        assert not (vault / "开发").exists()


def test_configure_prefers_valid_nested_checkout(tmp_path):
    vault = tmp_path / "vault"
    tools = copy_tools(vault)
    nested = checkout(vault / "开发")
    sibling = checkout(tmp_path / "jjd-wiki-dev")
    result = configure(tools, tmp_path)
    assert result.returncode == 0, result.stderr
    assert (nested / "config.json").is_file()
    assert not (sibling / "config.json").exists()


def test_incomplete_nested_checkout_is_not_selected(tmp_path):
    tools = copy_tools(tmp_path / "vault")
    incomplete = tmp_path / "vault/开发/staged/research-wiki"
    incomplete.mkdir(parents=True)
    (incomplete / "wiki.py").touch()
    sibling = checkout(tmp_path / "jjd-wiki-dev")
    result = configure(tools, tmp_path)
    assert result.returncode == 0, result.stderr
    assert (sibling / "config.json").is_file()
    assert not (incomplete / "config.json").exists()


def test_deploy_explicit_checkout_works_without_default_checkout(tmp_path):
    tools = copy_tools(tmp_path / "vault")
    skill = checkout(tmp_path / "custom")
    result = subprocess.run(
        [sys.executable, "-X", "utf8", str(tools / "deploy.py"), "--dev-root", str(skill.parents[1]),
         "--verify-only"], capture_output=True, text=True, encoding="utf-8",
    )
    # Missing installs yield a comparison failure, not a path-resolution error.
    assert result.returncode == 1, result.stderr
    assert "hosts" in json.loads(result.stdout)


def test_configure_validates_explicit_dev_root_and_never_falls_back(tmp_path):
    tools = copy_tools(tmp_path / "vault")
    skill = checkout(tmp_path / "jjd-wiki-dev")
    result = configure(tools, tmp_path, "--dev-root", str(tmp_path / "invalid"))
    assert result.returncode != 0
    assert "Invalid development checkout" in result.stderr
    assert not (skill / "config.json").exists()
    assert not (tmp_path / "invalid").exists()


def test_configure_accepts_explicit_checkout_and_refuses_existing_config(tmp_path):
    tools = copy_tools(tmp_path / "vault")
    skill = checkout(tmp_path / "custom")
    result = configure(tools, tmp_path, "--dev-root", str(skill.parents[1]))
    assert result.returncode == 0, result.stderr
    before = (skill / "config.json").read_bytes()
    result = configure(tools, tmp_path, "--dev-root", str(skill.parents[1]))
    assert result.returncode != 0
    assert (skill / "config.json").read_bytes() == before


def test_configure_never_creates_a_missing_checkout(tmp_path):
    tools = copy_tools(tmp_path / "vault")
    result = configure(tools, tmp_path)
    assert result.returncode != 0
    assert "Development checkout not found" in result.stderr
    assert not (tmp_path / "vault/开发").exists()
    assert not (tmp_path / "jjd-wiki-dev").exists()
    assert not (tmp_path / "environment").exists()


def load_tool(name, monkeypatch):
    monkeypatch.syspath_prepend(str(TOOLS))
    spec = importlib.util.spec_from_file_location(name.replace("-", "_"), TOOLS / name)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_deploy_resolves_actual_sibling_checkout(monkeypatch):
    module = load_tool("deploy.py", monkeypatch)
    assert module.SOURCE.joinpath("wiki.py").is_file()
    assert module.SOURCE.joinpath("config.example.json").is_file()


def test_export_can_collect_sibling_declarations_without_writing(monkeypatch):
    module = load_tool("export-dependencies.py", monkeypatch)
    records, inputs, excluded = module.collect(TOOLS.parent)
    assert ("R", "Seurat") in records
    assert inputs and excluded


def run_powershell(path, environment, *arguments):
    if not shutil.which("powershell.exe"):
        pytest.skip("Windows PowerShell is required for Windows entrypoints")
    return subprocess.run(
        ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(path), *arguments],
        env=environment, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=30,
    )


@pytest.mark.parametrize("layout", ["nested", "sibling"])
def test_cli_reads_config_and_preserves_arguments_with_spaces(tmp_path, layout):
    vault = tmp_path / "vault with space"
    tools = copy_tools(vault)
    dev = vault / "开发" if layout == "nested" else tmp_path / "jjd-wiki-dev"
    skill = checkout(dev)
    config = {"python_exe": str(tmp_path / "scientific-python.exe"),
              "env": {"vars": {"TEMP": str(tmp_path / "private temp")}}}
    (skill / "config.json").write_text(json.dumps(config), encoding="utf-8")
    environment = {k: v for k, v in os.environ.items() if not k.startswith("RWIKI_")}
    environment["RWIKI_PYTHON"] = sys.executable
    result = run_powershell(tools / "machine-paths.ps1", environment, "find", "two words", "--json")
    assert result.returncode == 0, result.stdout + result.stderr
    record = json.loads(result.stdout)
    assert record["args"] == ["--config", str(skill / "config.json"), "find", "two words", "--json"]
    assert record["temp"] == str(tmp_path / "private temp")


def test_cli_missing_config_does_not_run_system_python(tmp_path):
    tools = copy_tools(tmp_path / "vault")
    checkout(tmp_path / "jjd-wiki-dev")
    environment = {k: v for k, v in os.environ.items() if not k.startswith("RWIKI_")}
    result = run_powershell(tools / "machine-paths.ps1", environment, "--help")
    assert result.returncode != 0
    assert "configure-machine.py" in result.stderr


def test_hidden_launcher_logs_actionable_bootstrap_failure(tmp_path):
    tools = copy_tools(tmp_path / "vault")
    checkout(tmp_path / "jjd-wiki-dev")
    environment = {k: v for k, v in os.environ.items() if not k.startswith("RWIKI_")}
    result = run_powershell(tools / "launcher.ps1", environment)
    assert result.returncode != 0
    log = tools.parent / ".launcher.log"
    assert log.is_file()
    assert "configure-machine.py" in log.read_text(encoding="utf-8-sig")


def test_cli_rejects_missing_explicit_interpreter(tmp_path):
    tools = copy_tools(tmp_path / "vault")
    skill = checkout(tmp_path / "jjd-wiki-dev")
    (skill / "config.json").write_text(json.dumps({"python_exe": sys.executable}), encoding="utf-8")
    environment = {k: v for k, v in os.environ.items() if not k.startswith("RWIKI_")}
    environment["RWIKI_PYTHON"] = str(tmp_path / "missing.exe")
    result = run_powershell(tools / "machine-paths.ps1", environment, "--help")
    assert result.returncode != 0
    assert "RWIKI_PYTHON" in result.stderr


def test_cli_does_not_treat_scientific_python_as_wiki_interpreter(tmp_path):
    tools = copy_tools(tmp_path / "vault")
    skill = checkout(tmp_path / "jjd-wiki-dev")
    (skill / "config.json").write_text(json.dumps({"python_exe": sys.executable}), encoding="utf-8")
    environment = {k: v for k, v in os.environ.items() if not k.startswith("RWIKI_")}
    environment["USERPROFILE"] = str(tmp_path / "empty-profile")
    result = run_powershell(tools / "machine-paths.ps1", environment, "--help")
    assert result.returncode != 0
    assert "RWIKI_PYTHON" in result.stderr


def test_cli_explicit_paths_and_child_exit_status(tmp_path):
    tools = copy_tools(tmp_path / "vault")
    skill = checkout(tmp_path / "custom")
    config = tmp_path / "custom config.json"
    config.write_text("{}", encoding="utf-8")
    (skill / "wiki.py").write_text("import sys\nraise SystemExit(7)\n", encoding="utf-8")
    environment = {k: v for k, v in os.environ.items() if not k.startswith("RWIKI_")}
    environment.update(RWIKI_HOME=str(skill), RWIKI_CONFIG=str(config), RWIKI_PYTHON=sys.executable)
    result = run_powershell(tools / "machine-paths.ps1", environment, "--help")
    assert result.returncode == 7, result.stdout + result.stderr


def test_cli_explicit_invalid_checkout_does_not_fall_back(tmp_path):
    tools = copy_tools(tmp_path / "vault")
    checkout(tmp_path / "jjd-wiki-dev")
    environment = {k: v for k, v in os.environ.items() if not k.startswith("RWIKI_")}
    environment["RWIKI_DEV_ROOT"] = str(tmp_path / "invalid")
    result = run_powershell(tools / "machine-paths.ps1", environment, "--help")
    assert result.returncode != 0
    assert "Invalid development checkout" in result.stderr


def test_cmd_wrapper_forwards_paths_and_unicode_arguments(tmp_path):
    if os.name != "nt":
        pytest.skip("cmd wrapper requires Windows")
    tools = copy_tools(tmp_path / "vault with space")
    skill = checkout(tmp_path / "jjd-wiki-dev")
    (skill / "config.json").write_text("{}", encoding="utf-8")
    environment = {k: v for k, v in os.environ.items() if not k.startswith("RWIKI_")}
    environment["RWIKI_PYTHON"] = sys.executable
    result = subprocess.run(
        ["cmd.exe", "/d", "/c", "call", str(tools / "bin/rwiki.cmd"), "find", "中文 two words", "--json"],
        env=environment, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=30,
    )
    assert result.returncode == 0, result.stdout + result.stderr
    assert json.loads(result.stdout)["args"][-3:] == ["find", "中文 two words", "--json"]


@pytest.mark.parametrize("location", ["sibling", "legacy-profile"])
def test_bootstrap_discovers_dedicated_wiki_python_without_launching_it(tmp_path, location):
    tools = copy_tools(tmp_path / "vault")
    skill = checkout(tmp_path / "jjd-wiki-dev")
    (skill / "config.json").write_text(json.dumps({"python_exe": "unused-scientific.exe"}), encoding="utf-8")
    profile = tmp_path / "profile"
    executable = (tmp_path / "research-wiki-env/wiki-python/Scripts/python.exe" if location == "sibling"
                  else profile / ".codex/venvs/research-wiki/Scripts/python.exe")
    executable.parent.mkdir(parents=True)
    executable.touch()
    probe = tmp_path / "probe.ps1"
    helper = str(tools / "machine-paths.ps1").replace("'", "''")
    probe.write_text(f". '{helper}'\n(Get-RWikiMachine).Python | ConvertTo-Json\n", encoding="utf-8")
    environment = {k: v for k, v in os.environ.items() if not k.startswith("RWIKI_")}
    environment["USERPROFILE"] = str(profile)
    result = run_powershell(probe, environment)
    assert result.returncode == 0, result.stdout + result.stderr
    assert Path(json.loads(result.stdout)) == executable


@pytest.mark.parametrize("invocation", ["script-array", "powershell-file", "cmd-wrapper", "git-bash-wrapper"])
def test_cli_preserves_windows_arguments_and_stdio_with_spaced_interpreter(tmp_path, invocation):
    tools = copy_tools(tmp_path / "vault with space")
    skill = checkout(tmp_path / "jjd-wiki-dev")
    (skill / "config.json").write_text("{}", encoding="utf-8")
    (skill / "wiki.py").write_text(
        "import json, sys\n"
        "print(json.dumps({'args': sys.argv[1:], 'stdin': sys.stdin.read()}))\n"
        "print('stderr preserved 中文', file=sys.stderr)\n"
        "raise SystemExit(9)\n",
        encoding="utf-8",
    )
    runtime = tmp_path / "runtime with space"
    executable = runtime / "Scripts/python.exe"
    subprocess.run([sys.executable, "-m", "venv", "--without-pip", str(runtime)],
                   check=True, capture_output=True, timeout=30)
    arguments = ["two words", "", 'He said "hello"', "last", "   ", "tab\tvalue",
                 "trailing slash\\", "two trailing slashes\\\\", 'slash\\"quote',
                 'double slash\\\\"quote', '$HOME; | & < > ` $(Get-Date)', '"', "", "中文"]
    if invocation != "cmd-wrapper":
        # cmd.exe consumes physical newlines before invoking a batch script.
        arguments.append("embedded\nnew line")
    argument_file = tmp_path / "arguments.json"
    argument_file.write_text(json.dumps(arguments), encoding="utf-8")
    helper = str(tools / "machine-paths.ps1").replace("'", "''")
    argument_path = str(argument_file).replace("'", "''")
    probe = tmp_path / "forward.ps1"
    probe.write_text(
        f"$forwarded = Get-Content -LiteralPath '{argument_path}' -Raw -Encoding UTF8 | ConvertFrom-Json\n"
        f"& '{helper}' @forwarded\nexit $LASTEXITCODE\n",
        encoding="utf-8",
    )
    environment = {k: v for k, v in os.environ.items() if not k.startswith("RWIKI_")}
    environment["RWIKI_PYTHON"] = str(executable)
    command = ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(probe)]
    if invocation == "powershell-file":
        command = ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
                   str(tools / "machine-paths.ps1"), *arguments]
    elif invocation == "cmd-wrapper":
        command = ["cmd.exe", "/d", "/c", "call", str(tools / "bin/rwiki.cmd"), *arguments]
    elif invocation == "git-bash-wrapper":
        git_executable = shutil.which("git.exe")
        bash = Path(git_executable).parents[1] / "bin/bash.exe" if git_executable else None
        if bash is None or not bash.is_file():
            pytest.skip("Git for Windows Bash is not available")
        # MSYS parses native Windows argv differently from subprocess.list2cmdline.
        # Load literal strings inside Bash so the test isolates the wrapper boundary.
        nul_arguments = tmp_path / "arguments.nul"
        nul_arguments.write_bytes(b"\0".join(value.encode("utf-8") for value in arguments) + b"\0")
        shell_probe = tmp_path / "forward.sh"
        shell_probe.write_text(
            "forwarded=()\nwhile IFS= read -r -d '' value; do forwarded+=(\"$value\"); done < "
            + shlex.quote(nul_arguments.as_posix()) + "\nexec "
            + shlex.quote((tools / "bin/rwiki").as_posix()) + ' "${forwarded[@]}"\n',
            encoding="utf-8",
        )
        command = [str(bash), str(shell_probe)]
    with subprocess.Popen(command, env=environment, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE, text=True, encoding="utf-8", errors="replace") as child:
        try:
            stdout, stderr = child.communicate("stdin preserved 中文\n", timeout=20)
        except subprocess.TimeoutExpired:
            # Only terminate the process tree created by this isolated regression.
            subprocess.run(["taskkill.exe", "/PID", str(child.pid), "/T", "/F"],
                           capture_output=True, timeout=10)
            child.communicate(timeout=5)
            raise
        assert child.returncode == 9, stdout + stderr
    record = json.loads(stdout)
    assert record["args"] == ["--config", str(skill / "config.json"), *arguments]
    assert record["stdin"] == "stdin preserved 中文\n"
    assert stderr.strip() == "stderr preserved 中文"


def test_cli_forwards_interactive_input_and_exits_while_upstream_stdin_stays_open(tmp_path):
    tools = copy_tools(tmp_path / "vault")
    skill = checkout(tmp_path / "jjd-wiki-dev")
    (skill / "config.json").write_text("{}", encoding="utf-8")
    (skill / "wiki.py").write_text(
        "import json, sys\n"
        "print('O' * 262144, flush=True)\n"
        "print('E' * 262144, file=sys.stderr, flush=True)\n"
        "print('READY', flush=True)\n"
        "print(json.dumps({'line': sys.stdin.readline()}), flush=True)\n",
        encoding="utf-8",
    )
    environment = {k: v for k, v in os.environ.items() if not k.startswith("RWIKI_")}
    environment["RWIKI_PYTHON"] = sys.executable
    command = ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
               str(tools / "machine-paths.ps1")]
    with subprocess.Popen(command, env=environment, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE, text=True, encoding="utf-8", errors="replace") as child:
        output = queue.Queue()
        errors = []

        def read_stdout():
            for line in child.stdout:
                output.put(line)

        stdout_reader = threading.Thread(target=read_stdout, daemon=True)
        stderr_reader = threading.Thread(target=lambda: errors.append(child.stderr.read()), daemon=True)
        stdout_reader.start()
        stderr_reader.start()
        try:
            assert output.get(timeout=10) == "O" * 262144 + "\n"
            assert output.get(timeout=10) == "READY\n"
            child.stdin.write("interactive 中文\n")
            child.stdin.flush()
            # The wrapper must deliver this line before the upstream pipe reaches EOF.
            assert json.loads(output.get(timeout=5))["line"] == "interactive 中文\n"
            assert not child.stdin.closed
            assert child.wait(timeout=5) == 0
            assert not child.stdin.closed
            stdout_reader.join(timeout=5)
            stderr_reader.join(timeout=5)
            assert not stdout_reader.is_alive() and not stderr_reader.is_alive()
            assert errors == ["E" * 262144 + "\n"]
        finally:
            if child.poll() is None:
                subprocess.run(["taskkill.exe", "/PID", str(child.pid), "/T", "/F"],
                               capture_output=True, timeout=10)
                child.wait(timeout=5)
