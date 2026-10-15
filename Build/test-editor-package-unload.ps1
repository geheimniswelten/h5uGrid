[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$DelphiBin,
    [string]$OutputRoot = (Join-Path $PSScriptRoot 'Delphi\EditorPackageUnload')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# No forms shown or message loop: framework runtimes stay loaded as in the IDE.
& (Join-Path $PSScriptRoot 'build-delphi.ps1') -DelphiBin $DelphiBin -SkipDemos -OutputRoot $OutputRoot
$taskOutput = [IO.Path]::GetFullPath((Join-Path $OutputRoot 'Win32\Debug'))
$taskSearch = (Join-Path $taskOutput 'bpl') + ';' + (Join-Path $DelphiBin '..\lib\Win32\release')
& (Join-Path $DelphiBin 'dcc32.exe') '-B' '-Q' '-NSSystem;Winapi;Vcl' '-LUrtl;vcl;fmx;h5uGridCore' `
    "-U$taskSearch" "-N0$taskOutput\dcu" "-E$taskOutput\bpl" (Join-Path $PSScriptRoot 'TestEditorPackageUnload.dpr')
if ($LASTEXITCODE -ne 0) { throw 'Package unload test failed to compile.' }
& (Join-Path $taskOutput 'bpl\TestEditorPackageUnload.exe')
if ($LASTEXITCODE -ne 0) { throw 'Package unload test failed.' }
