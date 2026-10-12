[CmdletBinding()]
param(
    [string]$DelphiBin = '',
    [ValidateSet('Win32', 'Win64')]
    [string]$Platform = 'Win32',
    [string]$OutputRoot = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$taskCommon = Join-Path $taskRoot 'Source\Common'
$taskSource = Join-Path $PSScriptRoot 'TestFormDesigner.dpr'

if (-not $DelphiBin) {
    $DelphiBin = Split-Path -Parent (Get-Command 'dcc32.exe' -ErrorAction Stop).Source
}
if (-not $OutputRoot) { $OutputRoot = Join-Path $PSScriptRoot "Delphi\FormDesignerTests\$Platform" }
$taskOutput = [IO.Path]::GetFullPath($OutputRoot)
$taskUnits = Join-Path $taskOutput 'dcu'
New-Item -ItemType Directory -Force -Path $taskOutput, $taskUnits | Out-Null
$taskCompilerName = if ($Platform -eq 'Win64') { 'dcc64.exe' } else { 'dcc32.exe' }
$taskCompiler = Join-Path $DelphiBin $taskCompilerName
$taskSearch = @($taskCommon, (Join-Path $DelphiBin "..\lib\$($Platform.ToLowerInvariant())\release")) -join ';'
& $taskCompiler '-B' '-Q' '-NSSystem;Data' "-U$taskSearch" "-N0$taskUnits" "-E$taskOutput" '-$R+' '-$Q+' $taskSource
if ($LASTEXITCODE -ne 0) { throw 'FormDesigner-Tests konnten nicht kompiliert werden.' }

$taskExeName = 'TestFormDesigner'
if ($env:OS -eq 'Windows_NT') { $taskExeName += '.exe' }
$taskRunOutput = & (Join-Path $taskOutput $taskExeName) 2>&1
$taskExit = $LASTEXITCODE
$taskRunOutput | Tee-Object -FilePath (Join-Path $taskOutput 'TestFormDesigner.log')
if ($taskExit -ne 0) { throw 'FormDesigner-Tests fehlgeschlagen.' }
