[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([Environment]::OSVersion.Platform -ne [PlatformID]::Win32NT) {
    throw 'Run this script from Windows PowerShell.'
}

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $WhatIfPreference -and -not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run this script from an elevated Windows PowerShell. Use -WhatIf for a non-elevated preview.'
}

$config = Import-PowerShellDataFile (Join-Path $PSScriptRoot 'SetupConfig.psd1')

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory)] [string] $FilePath,
        [Parameter(Mandatory)] [string[]] $ArgumentList
    )

    & $FilePath @ArgumentList
    if ($LASTEXITCODE -ne 0) {
        throw "$FilePath failed with exit code $LASTEXITCODE."
    }
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

if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
    throw 'winget was not found. Update App Installer from Microsoft Store.'
}

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    throw 'wsl.exe was not found. Complete Windows Update first.'
}

$distribution = $config.WslDistribution
$online = Invoke-WslText -ArgumentList @('--list', '--online')
if ($online.ExitCode -ne 0 -or $online.Output -notmatch "(?m)^\s*$([regex]::Escape($distribution))\s") {
    throw "$distribution is not available from wsl --list --online. Check availability without changing the requirement."
}

foreach ($package in $config.WingetPackages) {
    if (Test-WingetPackage -Id $package.Id) {
        Write-Host "[skip] $($package.Name) is already installed."
        continue
    }

    if ($PSCmdlet.ShouldProcess($package.Id, 'Install with winget')) {
        Invoke-CheckedCommand -FilePath 'winget.exe' -ArgumentList @(
            'install', '--exact', '--id', $package.Id,
            '--accept-package-agreements', '--accept-source-agreements',
            '--disable-interactivity'
        )
    }
}

$installedOutput = Invoke-WslText -ArgumentList @('--list', '--quiet')
$installed = @($installedOutput.Output -split "`n") | ForEach-Object { $_.Trim() }
if ($installed -notcontains $distribution) {
    if ($PSCmdlet.ShouldProcess($distribution, 'Install WSL distribution')) {
        Invoke-CheckedCommand -FilePath 'wsl.exe' -ArgumentList @('--install', '--distribution', $distribution, '--no-launch')
        Write-Host '[info] If Windows requests a restart, restart and run this script again.'
    }
}

if ($PSCmdlet.ShouldProcess('WSL', 'Set WSL 2 as the default for new distributions')) {
    Invoke-CheckedCommand -FilePath 'wsl.exe' -ArgumentList @('--set-default-version', '2')
}

$installedOutput = Invoke-WslText -ArgumentList @('--list', '--quiet')
$installed = @($installedOutput.Output -split "`n") | ForEach-Object { $_.Trim() }
if ($installed -contains $distribution) {
    $verboseList = Invoke-WslText -ArgumentList @('--list', '--verbose')
    if ($verboseList.Output -notmatch "(?m)^\s*\*?\s*$([regex]::Escape($distribution))\s+.+\s+2\s*$") {
        if ($PSCmdlet.ShouldProcess($distribution, 'Convert to WSL 2')) {
            Invoke-CheckedCommand -FilePath 'wsl.exe' -ArgumentList @('--set-version', $distribution, '2')
        }
    }

    if ($PSCmdlet.ShouldProcess($distribution, 'Set as the default WSL distribution')) {
        Invoke-CheckedCommand -FilePath 'wsl.exe' -ArgumentList @('--set-default', $distribution)
    }
}

Write-Host 'Windows setup automation completed.'
