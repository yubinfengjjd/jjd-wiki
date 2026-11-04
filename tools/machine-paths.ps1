# Shared configuration bootstrap for the UI launcher and command wrappers.
# Dot-source to resolve settings without starting a server or browser.

function Test-RWikiCheckout([string]$DevRoot) {
    $skill = Join-Path $DevRoot 'staged/research-wiki'
    return ((Test-Path -LiteralPath (Join-Path $skill 'wiki.py') -PathType Leaf) -and
            (Test-Path -LiteralPath (Join-Path $skill 'config.example.json') -PathType Leaf))
}

function Get-RWikiMachine {
    $vault = Split-Path -Parent $PSScriptRoot
    if ($env:RWIKI_HOME) {
        $skill = [System.IO.Path]::GetFullPath($env:RWIKI_HOME)
    } else {
        if ($env:RWIKI_DEV_ROOT) {
            $candidates = @($env:RWIKI_DEV_ROOT)
        } else {
            # Use codepoints so Windows PowerShell can read this script without a BOM.
            $nested = [string][char]0x5f00 + [char]0x53d1
            $candidates = @((Join-Path $vault $nested),
                            (Join-Path (Split-Path -Parent $vault) 'jjd-wiki-dev'))
        }
        $dev = $null
        foreach ($candidate in $candidates) {
            if (Test-RWikiCheckout $candidate) { $dev = $candidate; break }
        }
        if (-not $dev) {
            throw "Invalid development checkout: $($candidates -join ', '). Set RWIKI_DEV_ROOT to a checkout containing staged/research-wiki/wiki.py and config.example.json."
        }
        $skill = [System.IO.Path]::GetFullPath((Join-Path $dev 'staged/research-wiki'))
    }
    $wiki = Join-Path $skill 'wiki.py'
    if (-not (Test-Path -LiteralPath $wiki -PathType Leaf)) {
        throw "wiki.py not found: $wiki. Check RWIKI_HOME or RWIKI_DEV_ROOT."
    }
    $configPath = if ($env:RWIKI_CONFIG) { $env:RWIKI_CONFIG } else { Join-Path $skill 'config.json' }
    $configPath = [System.IO.Path]::GetFullPath($configPath)
    if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
        throw "Machine config missing: $configPath. Run tools/configure-machine.py with --python-exe and --rscript-exe, or set RWIKI_CONFIG."
    }
    try {
        $config = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch {
        throw "Cannot read machine config ${configPath}: $($_.Exception.Message)"
    }
    if ($env:RWIKI_PYTHON) {
        $pythonCandidates = @($env:RWIKI_PYTHON)
    } else {
        # config.python_exe belongs to scientific runners, not the Wiki CLI.
        $pythonCandidates = @(
            (Join-Path (Split-Path -Parent $vault) 'research-wiki-env/wiki-python/Scripts/python.exe'),
            (Join-Path $env:USERPROFILE '.codex/venvs/research-wiki/Scripts/python.exe')
        )
    }
    $python = $null
    foreach ($candidate in $pythonCandidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { $python = $candidate; break }
    }
    if (-not $python) {
        throw "Wiki Python not found: $($pythonCandidates -join ', '). Install the dedicated Wiki environment and set RWIKI_PYTHON to its python.exe."
    }
    return [pscustomobject]@{
        Vault = $vault; Wiki = $wiki; ConfigPath = $configPath
        Python = [System.IO.Path]::GetFullPath($python); Config = $config
    }
}

function Set-RWikiEnvironment($Machine) {
    foreach ($property in $Machine.Config.env.vars.PSObject.Properties) {
        $name = $property.Name
        # Cache locations must come from the machine config, including Windows defaults.
        if ($name -in @('TEMP', 'TMP', 'MPLCONFIGDIR') -or -not [Environment]::GetEnvironmentVariable($name)) {
            [Environment]::SetEnvironmentVariable($name, [string]$property.Value, 'Process')
        }
    }
    $prepend = @($Machine.Config.env.path_prepend | Where-Object { $_ })
    if ($prepend.Count) { $env:PATH = ($prepend -join [IO.Path]::PathSeparator) + [IO.Path]::PathSeparator + $env:PATH }
    $env:PYTHONDONTWRITEBYTECODE = '1'
}

if ($MyInvocation.InvocationName -ne '.') {
    $ErrorActionPreference = 'Stop'
    try {
        $machine = Get-RWikiMachine
        Set-RWikiEnvironment $machine
        # PowerShell 5 native invocation loses empty arguments and literal quotes.
        # Encode each argument using the Windows C-runtime quoting rules instead.
        $forwarded = @('-X', 'utf8', $machine.Wiki, '--config', $machine.ConfigPath) + $args
        $quoted = foreach ($argument in $forwarded) {
            $escaped = [regex]::Replace([string]$argument, '(\\*)"', '$1$1\"')
            $escaped = [regex]::Replace($escaped, '(\\+)$', '$1$1')
            '"' + $escaped + '"'
        }
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = $machine.Python
        $startInfo.Arguments = $quoted -join ' '
        $startInfo.UseShellExecute = $false
        $startInfo.CreateNoWindow = $true
        $startInfo.RedirectStandardInput = $true
        # Keep stdout/stderr handles intact and forward stdin without buffering it.
        if (-not ('ResearchWiki.InputBridge' -as [type])) {
            Add-Type -TypeDefinition @'
using System.IO;
using System.Threading.Tasks;

namespace ResearchWiki {
    public static class InputBridge {
        public static async Task CopyAsync(Stream source, Stream destination) {
            byte[] buffer = new byte[4096];
            try {
                int count;
                while ((count = await source.ReadAsync(buffer, 0, buffer.Length).ConfigureAwait(false)) != 0) {
                    await destination.WriteAsync(buffer, 0, count).ConfigureAwait(false);
                    await destination.FlushAsync().ConfigureAwait(false);
                }
            } finally {
                destination.Close();
            }
        }
    }
}
'@
        }
        $child = [System.Diagnostics.Process]::Start($startInfo)
        try {
            $inputCopy = [ResearchWiki.InputBridge]::CopyAsync(
                [Console]::OpenStandardInput(), $child.StandardInput.BaseStream)
            do {
                if ($inputCopy -and $inputCopy.IsCompleted) {
                    [void]($inputCopy.GetAwaiter().GetResult())
                    $inputCopy = $null
                }
            } while (-not $child.WaitForExit(50))
            exit $child.ExitCode
        } finally {
            $child.Dispose()
        }
    } catch {
        [Console]::Error.WriteLine($_.Exception.Message)
        exit 1
    }
}
