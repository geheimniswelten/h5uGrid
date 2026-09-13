[CmdletBinding()]
param(
    [string]$Fpc = 'fpc',
    [string]$OutputRoot = '',
    [string[]]$CompilerOptions = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$taskCompiler = (Get-Command $Fpc -ErrorAction Stop).Source
if (-not $OutputRoot) {
    $taskCpu = & $taskCompiler -iTP
    if ($LASTEXITCODE -ne 0) { throw 'FPC-Zielarchitektur konnte nicht ermittelt werden.' }
    $taskOs = & $taskCompiler -iTO
    if ($LASTEXITCODE -ne 0) { throw 'FPC-Zielsystem konnte nicht ermittelt werden.' }
    $OutputRoot = Join-Path $PSScriptRoot "FPC\$taskCpu-$taskOs"
}
$taskOutput = [IO.Path]::GetFullPath($OutputRoot)
$taskUnits = Join-Path $taskOutput 'units'
New-Item -ItemType Directory -Force -Path $taskOutput, $taskUnits | Out-Null
$taskCommon = Join-Path $taskRoot 'Source\Common'

foreach ($taskProgram in @('TestCommonBehavior.dpr', 'TestFpcCompatibility.pas')) {
    $taskSource = Join-Path $PSScriptRoot $taskProgram
    & $taskCompiler @CompilerOptions '-B' '-Mobjfpc' '-Sh' '-Cr' '-Co' '-gl' '-gh' "-Fu$taskCommon" "-FU$taskUnits" "-FE$taskOutput" $taskSource
    if ($LASTEXITCODE -ne 0) { throw "FPC-Kompilierung fehlgeschlagen: $taskProgram" }
    $taskExeName = [IO.Path]::GetFileNameWithoutExtension($taskProgram)
    if ($env:OS -eq 'Windows_NT') { $taskExeName += '.exe' }
    $taskLog = Join-Path $taskOutput "$taskExeName.log"
    $taskRunOutput = & (Join-Path $taskOutput $taskExeName) 2>&1
    $taskExit = $LASTEXITCODE
    $taskRunOutput | Tee-Object -FilePath $taskLog
    if ($taskExit -ne 0) { throw "FPC-Test fehlgeschlagen: $taskProgram" }
    if (($taskRunOutput -join "`n") -match '(?m)^\s*[1-9][0-9]* unfreed memory blocks') {
        throw "Speicherleck im FPC-Test: $taskProgram"
    }
}
