[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$config = Import-PowerShellDataFile (Join-Path $PSScriptRoot 'SetupConfig.psd1')
$failures = 0

function Add-Result {
    param(
        [Parameter(Mandatory)] [ValidateSet('PASS', 'FAIL', 'MANUAL')] [string] $Status,
        [Parameter(Mandatory)] [string] $Message
    )

    if ($Status -eq 'FAIL') {
        $script:failures++
    }
    Write-Host "[$Status] $Message"
}

function Test-WingetPackage {
    param([Parameter(Mandatory)] [string] $Id)
    & winget.exe list --exact --id $Id --accept-source-agreements --disable-interactivity *> $null
    return $LASTEXITCODE -eq 0
}

function Invoke-WslText {
    param([Parameter(Mandatory)] [string[]] $ArgumentList)

    $originalEncoding = [Console]::OutputEncoding
    try {
        [Console]::OutputEncoding = [Text.Encoding]::Unicode
        $output = (& wsl.exe @ArgumentList 2>$null) -join "`n"
        $exitCode = $LASTEXITCODE
    } finally {
        [Console]::OutputEncoding = $originalEncoding
    }
    return @{ Output = $output; ExitCode = $exitCode }
}

if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'Run this script from Windows PowerShell.'
}

$windows = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
if ([int]$windows.CurrentBuildNumber -ge 22000) {
    Add-Result PASS "Windows 11 build $($windows.CurrentBuildNumber).$($windows.UBR)"
} else {
    Add-Result FAIL "Windows 11 was not detected (build $($windows.CurrentBuildNumber))."
}

$flight = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Flighting' -ErrorAction SilentlyContinue
$preview = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\WindowsSelfHost\Applicability' -ErrorAction SilentlyContinue
$flightEnabled = $null -ne $flight -and
    $flight.PSObject.Properties.Name -contains 'IsBuildFlightingEnabled' -and
    $flight.IsBuildFlightingEnabled -eq 1
$previewEnabled = $null -ne $preview -and
    $preview.PSObject.Properties.Name -contains 'EnablePreviewBuilds' -and
    $preview.EnablePreviewBuilds -eq 1
if ($flightEnabled -or $previewEnabled) {
    Add-Result FAIL 'Windows Insider or preview flighting is enabled.'
} else {
    Add-Result PASS 'Windows flighting is not enabled.'
}

if ($env:USERPROFILE -eq 'C:\Users\kou') {
    Add-Result PASS 'The user profile is C:\Users\kou.'
} else {
    Add-Result FAIL "Unexpected user profile: $env:USERPROFILE"
}

$knownFolders = @{
    Desktop = [Environment]::GetFolderPath('Desktop')
    Documents = [Environment]::GetFolderPath('MyDocuments')
    Downloads = [Environment]::ExpandEnvironmentVariables(
        (Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders').'{374DE290-123F-4565-9164-39C4925E467B}'
    )
}
foreach ($name in $knownFolders.Keys) {
    $expected = Join-Path 'C:\Users\kou' $name
    if ($knownFolders[$name] -eq $expected) {
        Add-Result PASS "$name is $expected."
    } else {
        Add-Result FAIL "Unexpected $name path: $($knownFolders[$name])"
    }
}

$languages = Get-WinUserLanguageList
if ($languages.Count -gt 0 -and $languages[0].LanguageTag -match '^ja(?:-JP)?$' -and
    (Get-WinSystemLocale).Name -eq 'ja-JP' -and (Get-Culture).Name -eq 'ja-JP' -and
    (Get-UICulture).Name -eq 'ja-JP') {
    Add-Result PASS 'User language, system locale, and regional format are ja-JP.'
} else {
    Add-Result FAIL 'The required Japanese language and regional settings do not match.'
}
Add-Result MANUAL 'Verify the Muhenkan, Henkan, and Ctrl+Space IME behavior in Notepad.'

if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
    Add-Result FAIL 'winget was not found.'
} else {
    foreach ($package in $config.WingetPackages) {
        if (Test-WingetPackage -Id $package.Id) {
            Add-Result PASS "$($package.Name) is installed."
        } else {
            Add-Result FAIL "$($package.Name) is not installed."
        }
    }
}

$oneDrivePaths = @(
    (Join-Path $env:LOCALAPPDATA 'Microsoft\OneDrive\OneDrive.exe'),
    (Join-Path $env:ProgramFiles 'Microsoft OneDrive\OneDrive.exe')
)
if ($oneDrivePaths | Where-Object { Test-Path $_ }) {
    Add-Result PASS 'The OneDrive app remains installed.'
} else {
    Add-Result FAIL 'The OneDrive app was not found.'
}
if (Get-Process OneDrive -ErrorAction SilentlyContinue) {
    Add-Result FAIL 'The OneDrive process is running. Check quit and startup settings.'
} else {
    Add-Result PASS 'The OneDrive process is not running.'
}
if ($knownFolders.Values -match '\\OneDrive(?:\\|$)') {
    Add-Result FAIL 'A known folder points inside OneDrive.'
} else {
    Add-Result PASS 'Known folders do not point inside OneDrive.'
}
Add-Result MANUAL 'Verify that OneDrive is signed out, folder backup is off, and startup is disabled.'

$distribution = $config.WslDistribution
$wslList = Invoke-WslText -ArgumentList @('--list', '--verbose')
$distributionReady = $wslList.ExitCode -eq 0 -and
    $wslList.Output -match "(?m)^\s*\*?\s*$([regex]::Escape($distribution))\s+.+\s+2\s*$"
if ($distributionReady) {
    Add-Result PASS "$distribution uses WSL 2."
} else {
    Add-Result FAIL "$distribution on WSL 2 was not detected."
}

if ($distributionReady) {
    & wsl.exe --distribution $distribution -- sh -lc 'command -v docker >/dev/null && docker compose version >/dev/null' 2>$null
    if ($LASTEXITCODE -eq 0) {
        Add-Result PASS 'Docker Desktop CLI and Compose are available in WSL.'
    } else {
        Add-Result FAIL 'Docker Desktop WSL integration was not detected.'
    }

    & wsl.exe --distribution $distribution -- sh -lc 'command -v code >/dev/null' 2>$null
    if ($LASTEXITCODE -eq 0) {
        Add-Result PASS 'VS Code can be started from WSL.'
    } else {
        Add-Result FAIL 'The code command was not found in WSL.'
    }
}

if ($failures -gt 0) {
    Write-Error "$failures required checks failed."
    exit 1
}

Write-Host 'Automated checks passed. Complete every MANUAL check.'
