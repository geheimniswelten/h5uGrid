[CmdletBinding()]
param(
    [string]$DelphiBin = '',
    [string]$OutputRoot = (Join-Path $PSScriptRoot 'Delphi\DesignRegistration')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
if (-not $DelphiBin) { $DelphiBin = Split-Path -Parent (Get-Command 'dcc32.exe' -ErrorAction Stop).Source }
$env:PATH = "$DelphiBin;$env:PATH"

# Inspect registration callbacks in a separate process, without touching the running IDE.
foreach ($taskFramework in @('Vcl', 'Fmx')) {
    $taskOutput = [IO.Path]::GetFullPath((Join-Path $OutputRoot $taskFramework))
    $taskDcu = Join-Path $taskOutput 'dcu'
    New-Item -ItemType Directory -Force -Path $taskOutput, $taskDcu | Out-Null
    $taskSearch = @(
        (Join-Path $taskRoot 'Source\Common'),
        (Join-Path $taskRoot 'Source\Design'),
        (Join-Path $taskRoot "Source\$taskFramework"),
        (Join-Path $DelphiBin '..\lib\Win32\release')
    ) -join ';'
    $taskDefines = if ($taskFramework -eq 'Fmx') { 'TEST_FMX' } else { 'TEST_VCL' }
    & (Join-Path $DelphiBin 'dcc32.exe') '-B' '-Q' "-D$taskDefines" "-NSSystem;Data;Winapi;$taskFramework" `
        '-LUrtl;vcl;designide' "-U$taskSearch" "-N0$taskDcu" "-E$taskOutput" `
        (Join-Path $PSScriptRoot 'TestGridDesignRegistration.dpr')
    if ($LASTEXITCODE -ne 0) { throw "$taskFramework design registration test failed to compile." }
    & (Join-Path $taskOutput 'TestGridDesignRegistration.exe')
    if ($LASTEXITCODE -ne 0) { throw "$taskFramework design registration test failed." }
}
