<# Explicitly obtain a full or lightweight checkout, never install dependencies. #>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Destination,
    [ValidateSet('light', 'full')][string]$Profile = 'light',
    [string]$VaultUrl = 'https://github.com/yubinfengjjd/jjd-wiki.git',
    [string]$DevUrl = 'https://github.com/yubinfengjjd/jjd-wiki-dev.git'
)
$ErrorActionPreference = 'Stop'
$OutputEncoding = New-Object System.Text.UTF8Encoding($false)
function Invoke-CheckedGit {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments)
    & git @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Git failed ($LASTEXITCODE). Existing downloads were retained; retry using the printed repository paths." }
}
$taskDestination = [IO.Path]::GetFullPath($Destination)
$taskVault = Join-Path $taskDestination 'jjd-wiki'
$taskDev = Join-Path $taskDestination 'jjd-wiki-dev'
foreach ($taskTarget in @($taskVault, $taskDev)) {
    if (Test-Path -LiteralPath $taskTarget) { throw "Destination exists; do not overwrite: $taskTarget" }
}
New-Item -ItemType Directory -Path $taskDestination -Force | Out-Null
if ($Profile -eq 'light') {
    Invoke-CheckedGit clone --filter=blob:none --no-checkout -- $VaultUrl $taskVault
    $taskWikiName = if ((& git -C $taskVault ls-tree --name-only HEAD wiki) -eq 'wiki') { 'wiki' } else { [string][char]0x77e5 + [char]0x8bc6 + [char]0x5e93 }
    # Use the tracked tree, not file contents: this cannot hydrate large blobs.
    $taskTracked = & git -C $taskVault -c core.quotePath=false ls-tree -r --name-only HEAD
    if ($LASTEXITCODE -ne 0) { throw 'Cannot read checkout tree.' }
    $taskPatterns = foreach ($taskRelative in $taskTracked) {
        $taskSelect = ($taskRelative -match '^(README\.md|\.gitattributes|\.gitignore|\.push-guard-allow)$' -or
                       $taskRelative -match '^(tools|docs|\.github)/')
        if ($taskRelative.StartsWith($taskWikiName + '/')) {
            $taskWithin = $taskRelative.Substring($taskWikiName.Length + 1)
            $taskSelect = ($taskWithin -match '^[^/]+\.(md|jsonl|json)$' -or
                           $taskWithin -eq '.gitignore' -or $taskWithin -eq '.protected-hashes.json' -or
                           $taskWithin -match '^(methods|templates|recipes|layouts|scenarios|interfaces|chart-types|projects|sources)/[^/]+\.md$' -or
                           $taskWithin -match '^(methods|templates|recipes|layouts)/[^/]+/(runtime\.json|spec\.json|source\.json|acceptance\.json|preview\.png|thumb\.png)$' -or
                           $taskWithin -match '^sources/[^/]+/items\.jsonl$' -or
                           $taskWithin -eq 'sources/figureya-curation.json')
        }
        if ($taskSelect) { '/' + $taskRelative }
    }
    $taskPatterns | & git -C $taskVault sparse-checkout set --no-cone --stdin
    if ($LASTEXITCODE -ne 0) { throw 'Sparse checkout incomplete. Existing files retained.' }
    Invoke-CheckedGit -C $taskVault checkout
} else {
    Invoke-CheckedGit clone -- $VaultUrl $taskVault
}
Invoke-CheckedGit clone -- $DevUrl $taskDev
Write-Output "Vault: $taskVault"
Write-Output "Tools: $taskDev"
Write-Output "Profile: $Profile. No packages installed. Follow the README to configure existing interpreters."
