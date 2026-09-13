[CmdletBinding()]
param(
    [string]$LazBuild = 'lazbuild',
    [string]$Compiler = '',
    [string]$PrimaryConfigPath = '',
    [switch]$SkipBuild,
    [switch]$SkipVisual,
    [ValidateSet(5, 10)][int]$NoticeSeconds = 10,
    [string]$Screenshot = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not $SkipBuild) {
    & (Join-Path $PSScriptRoot 'build-lazarus.ps1') -LazBuild $LazBuild -Compiler $Compiler `
        -PrimaryConfigPath $PrimaryConfigPath -IncludeTests
}
# The Windows launcher targets the native win32 widgetset, including Win64.
$taskLazBuild = (Get-Command $LazBuild -ErrorAction Stop).Source
if (-not $PrimaryConfigPath) { $PrimaryConfigPath = Join-Path $PSScriptRoot 'LCL\config' }
$taskArguments = @("--pcp=$PrimaryConfigPath", "--lazarusdir=$(Split-Path -Parent $taskLazBuild)", '--ws=win32')
if ($Compiler) { $taskArguments += "--compiler=$((Get-Command $Compiler -ErrorAction Stop).Source)" }
$taskCpuLines = & $taskLazBuild @taskArguments '--get=TargetCPU' (Join-Path $PSScriptRoot 'TestLclBehavior.lpi')
if ($LASTEXITCODE -ne 0) { throw 'Lazarus-Zielarchitektur konnte nicht ermittelt werden.' }
$taskCpu = ($taskCpuLines | Select-Object -Last 1).Trim()
$taskOsLines = & $taskLazBuild @taskArguments '--get=TargetOS' (Join-Path $PSScriptRoot 'TestLclBehavior.lpi')
if ($LASTEXITCODE -ne 0) { throw 'Lazarus-Zielsystem konnte nicht ermittelt werden.' }
$taskOs = ($taskOsLines | Select-Object -Last 1).Trim()
$taskBin = Join-Path $PSScriptRoot "LCL\bin\$taskCpu-$taskOs\win32"
& (Join-Path $taskBin 'TestLclDemoResources.exe')
if ($LASTEXITCODE -ne 0) { throw 'LCL-Formular- und Datentest fehlgeschlagen.' }
if (-not $SkipVisual) {
    . (Join-Path $PSScriptRoot 'visual-test-notice.ps1')
    Show-GridVisualTestNotice -TestName 'h5u Grid LCL' -Seconds $NoticeSeconds
    $taskTestArguments = @('--visual')
    if ($Screenshot) { $taskTestArguments += $Screenshot }
    & (Join-Path $taskBin 'TestLclBehavior.exe') @taskTestArguments
    if ($LASTEXITCODE -ne 0) { throw 'LCL-Bedienungstest fehlgeschlagen.' }
}
