[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$DelphiBin,
    [ValidateSet('Win32', 'Win64')]
    [string]$Platform = 'Win32',
    [string]$OutputRoot = (Join-Path $PSScriptRoot 'Delphi\GeometryPrecision')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$taskCompilerName = if ($Platform -eq 'Win64') { 'dcc64.exe' } else { 'dcc32.exe' }
$taskCompiler = Join-Path $DelphiBin $taskCompilerName
$taskTests = @(
    @{ Framework = 'Fmx'; Name = 'TestFmxTouchPrecision' },
    @{ Framework = 'Vcl'; Name = 'TestVclFractionalSpacing' }
)

# Both programs keep their forms hidden and render only into offscreen bitmaps.
foreach ($taskTest in $taskTests) {
    $taskFramework = $taskTest.Framework
    $taskName = $taskTest.Name
    $taskOutput = [IO.Path]::GetFullPath((Join-Path $OutputRoot "$Platform\$taskFramework"))
    $taskDcu = Join-Path $taskOutput 'dcu'
    New-Item -ItemType Directory -Force -Path $taskOutput, $taskDcu | Out-Null
    $taskSearch = @(
        (Join-Path $taskRoot 'Source\Common'),
        (Join-Path $taskRoot "Source\$taskFramework"),
        (Join-Path $DelphiBin "..\lib\$Platform\release")
    ) -join ';'
    $taskProject = Join-Path $PSScriptRoot "$taskName.dpr"
    & $taskCompiler '-B' '-Q' "-NSSystem;Data;Winapi;$taskFramework" "-U$taskSearch" `
        "-I$PSScriptRoot" "-N0$taskDcu" "-E$taskOutput" '-$R+' '-$Q+' $taskProject
    if ($LASTEXITCODE -ne 0) { throw "$taskName failed to compile for $Platform." }
    & (Join-Path $taskOutput "$taskName.exe")
    if ($LASTEXITCODE -ne 0) { throw "$taskName failed for $Platform." }
}
