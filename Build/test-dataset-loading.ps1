[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$DelphiBin,
    [string]$OutputRoot = (Join-Path $PSScriptRoot 'Output\DatasetLoading')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$taskCompiler = Join-Path $DelphiBin 'dcc32.exe'
if (-not (Test-Path -LiteralPath $taskCompiler)) {
    throw "Compiler fehlt: $taskCompiler"
}
$taskRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$taskLib = Join-Path $DelphiBin '..\lib\win32\release'
$taskOutput = [IO.Path]::GetFullPath($OutputRoot)
$taskDcu = Join-Path $taskOutput 'dcu'
New-Item -ItemType Directory -Force -Path $taskOutput, $taskDcu | Out-Null
$taskSearch = @((Join-Path $taskRoot 'Source\Common'), (Join-Path $taskRoot 'Source\VCL'), $taskLib) -join ';'

Push-Location $PSScriptRoot
try {
    foreach ($taskTest in @('TestDatasetReadNotifications', 'TestVclDatasetLoading')) {
        $taskArguments = @('-B', '-Q', '-NSSystem;Data;Datasnap;Winapi;System.Win;Vcl;Vcl.Imaging',
            "-U$taskSearch", "-I$taskSearch", "-N0$taskDcu", "-E$taskOutput", '-$R+', '-$Q+', "$taskTest.dpr")
        & $taskCompiler @taskArguments
        if ($LASTEXITCODE -ne 0) {
            throw "Kompilierung fehlgeschlagen: $taskTest"
        }
        $taskStdout = Join-Path $taskOutput "$taskTest.stdout.log"
        $taskStderr = Join-Path $taskOutput "$taskTest.stderr.log"
        $taskProcess = Start-Process -FilePath (Join-Path $taskOutput "$taskTest.exe") -WindowStyle Hidden -PassThru `
            -RedirectStandardOutput $taskStdout -RedirectStandardError $taskStderr
        try {
            if (-not $taskProcess.WaitForExit(30000)) {
                $taskProcess.Kill()
                $taskProcess.WaitForExit()
                throw "Zeitlimit von 30 Sekunden erreicht: $taskTest"
            }
            Get-Content -LiteralPath $taskStdout
            Get-Content -LiteralPath $taskStderr
            if ($taskProcess.ExitCode -ne 0) {
                throw "Test fehlgeschlagen: $taskTest (Exitcode $($taskProcess.ExitCode))"
            }
        }
        finally {
            $taskProcess.Dispose()
        }
    }
}
finally {
    Pop-Location
}
