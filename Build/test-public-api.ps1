[CmdletBinding()]
param(
    [string]$DelphiBin = '',
    [ValidateSet('Win32', 'Win64')]
    [string]$Platform = 'Win32',
    [string]$OutputRoot = (Join-Path $PSScriptRoot 'Delphi\PublicApi')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
if (-not $DelphiBin) { $DelphiBin = Split-Path -Parent (Get-Command 'dcc32.exe' -ErrorAction Stop).Source }
$taskCompilerName = if ($Platform -eq 'Win64') { 'dcc64.exe' } else { 'dcc32.exe' }
$taskCompiler = Join-Path $DelphiBin $taskCompilerName

# Hidden component/streaming tests: no forms shown, message loop or focus changes.
foreach ($taskFramework in @('Vcl', 'Fmx')) {
    $taskOutput = [IO.Path]::GetFullPath((Join-Path $OutputRoot "$Platform\$taskFramework"))
    $taskDcu = Join-Path $taskOutput 'dcu'
    New-Item -ItemType Directory -Force -Path $taskOutput, $taskDcu | Out-Null
    $taskSearch = @(
        (Join-Path $taskRoot 'Source\Common'),
        (Join-Path $taskRoot "Source\$taskFramework"),
        (Join-Path $taskRoot 'Source\Design'),
        (Join-Path $taskRoot "Demos\$taskFramework\ClientDataset"),
        (Join-Path $taskRoot "Demos\$taskFramework\ObjectList"),
        (Join-Path $taskRoot "Demos\$taskFramework\VirtualLive"),
        (Join-Path $taskRoot "Demos\$taskFramework\MegaDemo"),
        (Join-Path $DelphiBin "..\lib\$Platform\release")
    ) -join ';'
    $taskDefines = if ($taskFramework -eq 'Fmx') { 'TEST_FMX' } else { 'TEST_VCL' }
    foreach ($taskTest in @('TestGridPublicApi', 'TestPropertyEditorPublicApi', 'TestDemoFormResources')) {
        & $taskCompiler '-B' '-Q' "-D$taskDefines" "-NSSystem;Data;Winapi;$taskFramework" "-U$taskSearch" `
            "-N0$taskDcu" "-E$taskOutput" '-$R+' '-$Q+' (Join-Path $PSScriptRoot "$taskTest.dpr")
        if ($LASTEXITCODE -ne 0) { throw "$taskFramework $taskTest failed to compile." }
        & (Join-Path $taskOutput "$taskTest.exe")
        if ($LASTEXITCODE -ne 0) { throw "$taskFramework $taskTest failed." }
    }
}
