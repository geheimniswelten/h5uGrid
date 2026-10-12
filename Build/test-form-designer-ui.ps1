[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$DelphiBin,
    [ValidateSet('Win32', 'Win64')]
    [string]$Platform = 'Win32',
    [string]$OutputRoot = (Join-Path $PSScriptRoot 'Delphi\FormDesignerUI')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$taskCompilerName = if ($Platform -eq 'Win64') { 'dcc64.exe' } else { 'dcc32.exe' }
$taskCompiler = Join-Path $DelphiBin $taskCompilerName

# These tests create hidden controls, never show forms or enter the message loop,
# and invoke the editor's population hook without activating it or taking focus.
foreach ($taskFramework in @('Vcl', 'Fmx')) {
    $taskOutput = [IO.Path]::GetFullPath((Join-Path $OutputRoot "$Platform\$taskFramework"))
    $taskDcu = Join-Path $taskOutput 'dcu'
    New-Item -ItemType Directory -Force -Path $taskOutput, $taskDcu | Out-Null
    $taskSearch = @(
        (Join-Path $taskRoot 'Source\Common'),
        (Join-Path $taskRoot "Source\$taskFramework"),
        (Join-Path $DelphiBin "..\lib\$Platform\release")
    ) -join ';'
    $taskProject = Join-Path $PSScriptRoot "Test${taskFramework}FormDesigner.dpr"
    & $taskCompiler '-B' '-Q' "-NSSystem;Data;Winapi;$taskFramework" "-U$taskSearch" `
        "-I$PSScriptRoot" "-N0$taskDcu" "-E$taskOutput" '-$R+' '-$Q+' $taskProject
    if ($LASTEXITCODE -ne 0) { throw "$taskFramework FormDesigner tests failed to compile." }
    & (Join-Path $taskOutput "Test${taskFramework}FormDesigner.exe")
    if ($LASTEXITCODE -ne 0) { throw "$taskFramework FormDesigner tests failed." }
}
