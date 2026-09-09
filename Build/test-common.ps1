[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$DelphiBin,
    [string]$OutputRoot = (Join-Path $PSScriptRoot 'Delphi\CommonTests')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$taskOutput = [IO.Path]::GetFullPath($OutputRoot)
$taskDcu = Join-Path $taskOutput 'dcu'
New-Item -ItemType Directory -Force -Path $taskOutput, $taskDcu | Out-Null
$taskSearch = @((Join-Path $taskRoot 'Source\Common'), (Join-Path $DelphiBin '..\lib\win32\release')) -join ';'
$taskCompiler = Join-Path $DelphiBin 'dcc32.exe'
& $taskCompiler '-B' '-Q' '-NSSystem;Data' "-U$taskSearch" "-N0$taskDcu" "-E$taskOutput" '-$R+' '-$Q+' (Join-Path $PSScriptRoot 'TestCommonBehavior.dpr')
if ($LASTEXITCODE -ne 0) { throw 'Common-Tests konnten nicht kompiliert werden.' }
& (Join-Path $taskOutput 'TestCommonBehavior.exe')
if ($LASTEXITCODE -ne 0) { throw 'Common-Tests fehlgeschlagen.' }
