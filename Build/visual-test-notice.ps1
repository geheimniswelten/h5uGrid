# Shared entry point for scripted and manually launched visual tests.
function Show-GridVisualTestNotice {
    [CmdletBinding()]
    param(
        [ValidatePattern('^[\p{L}\p{N} ._-]+$')]
        [string]$TestName = 'h5u.Grid',
        [ValidateSet(5, 10)]
        [int]$Seconds = 10
    )

    $taskNoticeHost = Join-Path $PSScriptRoot 'visual-test-notice-host.ps1'
    $taskWindowsPowerShell = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    $taskNoticeArguments = @('-NoProfile', '-STA', '-File', ('"{0}"' -f $taskNoticeHost),
        '-Seconds', $Seconds, '-TestName', ('"{0}"' -f $TestName))
    $taskNoticeProcess = Start-Process -FilePath $taskWindowsPowerShell -ArgumentList $taskNoticeArguments `
        -WindowStyle Hidden -PassThru
    try {
        if (-not $taskNoticeProcess.WaitForExit(30000)) {
            $taskNoticeProcess.Kill()
            $taskNoticeProcess.WaitForExit()
            throw 'Der Testhinweis wurde nicht rechtzeitig beendet; der visuelle Test wird nicht gestartet.'
        }
        if ($taskNoticeProcess.ExitCode -ne 0) {
            throw "Der Testhinweis wurde abgebrochen oder konnte nicht angezeigt werden (Exitcode $($taskNoticeProcess.ExitCode))."
        }
    }
    finally {
        $taskNoticeProcess.Dispose()
    }
}
