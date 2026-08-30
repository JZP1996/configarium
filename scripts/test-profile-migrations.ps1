$ErrorActionPreference = "Stop"

$root = Split-Path $PSScriptRoot -Parent
$temporaryDirectory = Join-Path ([IO.Path]::GetTempPath()) "configarium-$([guid]::NewGuid())"

function Get-MigrationScript {
    $source = Join-Path $root ".chezmoiscripts/run_after_powershell-profile.ps1.tmpl"
    $override = '{"chezmoi":{"os":"windows"}}'
    (& chezmoi execute-template --override-data $override -f $source) -join "`n"
}

function Invoke-Migration([string]$ProfilePath, [string]$ScriptPath) {
    $PROFILE = [pscustomobject]@{ CurrentUserAllHosts = $ProfilePath }
    & $ScriptPath
}

try {
    New-Item -ItemType Directory -Path $temporaryDirectory | Out-Null
    $scriptPath = Join-Path $temporaryDirectory "migrate.ps1"
    [IO.File]::WriteAllText($scriptPath, (Get-MigrationScript))

    $newProfile = Join-Path $temporaryDirectory "new-profile.ps1"
    Invoke-Migration $newProfile $scriptPath
    $first = [IO.File]::ReadAllBytes($newProfile)
    Invoke-Migration $newProfile $scriptPath
    $second = [IO.File]::ReadAllBytes($newProfile)
    if (-not [Linq.Enumerable]::SequenceEqual($first, $second)) {
        throw "PowerShell profile migration is not idempotent"
    }

    $legacyProfile = Join-Path $temporaryDirectory "legacy-profile.ps1"
    [IO.File]::WriteAllText(
        $legacyProfile,
        '$env:TEST = "keep"' + "`r`n" + '. "$HOME\.config\powershell\profile.ps1"' + "`r`n"
    )
    Invoke-Migration $legacyProfile $scriptPath
    $legacyContent = [IO.File]::ReadAllText($legacyProfile)
    if (-not $legacyContent.Contains('$env:TEST = "keep"') -or
        $legacyContent.Contains('. "$HOME\.config\powershell\profile.ps1"')) {
        throw "Legacy PowerShell profile migration did not preserve user content"
    }

    $legacyBlockProfile = Join-Path $temporaryDirectory "legacy-block-profile.ps1"
    [IO.File]::WriteAllText(
        $legacyBlockProfile,
        @'
$env:TEST = "keep"
$managedProfile = "$HOME\.config\powershell\profile.ps1"
if (Test-Path $managedProfile) {
    . $managedProfile
}
'@
    )
    Invoke-Migration $legacyBlockProfile $scriptPath
    $legacyBlockContent = [IO.File]::ReadAllText($legacyBlockProfile)
    if (($legacyBlockContent.Split('$managedProfile =').Count - 1) -ne 1 -or
        ($legacyBlockContent.Split("# BEGIN CONFIGARIUM").Count - 1) -ne 1) {
        throw "Legacy PowerShell managed block was not upgraded"
    }

    $conflictProfile = Join-Path $temporaryDirectory "conflict-profile.ps1"
    $conflictContent = "mise activate pwsh | Out-String | Invoke-Expression`n"
    [IO.File]::WriteAllText($conflictProfile, $conflictContent)
    & pwsh -NonInteractive -NoProfile -Command "`$PROFILE = [pscustomobject]@{ CurrentUserAllHosts = '$conflictProfile' }; & '$scriptPath'" *> $null
    $failed = $LASTEXITCODE -ne 0
    if (-not $failed -or [IO.File]::ReadAllText($conflictProfile) -ne $conflictContent) {
        throw "Non-interactive PowerShell conflict handling failed"
    }

    Write-Host "PowerShell profile migration tests passed."
}
finally {
    Remove-Item $temporaryDirectory -Recurse -Force -ErrorAction SilentlyContinue
}
