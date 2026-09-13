[CmdletBinding()]
param(
    [string]$LazBuild = 'lazbuild',
    [string]$Compiler = '',
    [string]$PrimaryConfigPath = '',
    [string]$WidgetSet = 'win32',
    [switch]$SkipDesignPackages,
    [switch]$SkipDemos,
    [switch]$IncludeTests
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$taskRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$taskLazBuild = (Get-Command $LazBuild -ErrorAction Stop).Source
if (-not $PrimaryConfigPath) {
    $PrimaryConfigPath = Join-Path $PSScriptRoot 'LCL\config'
}
New-Item -ItemType Directory -Force -Path $PrimaryConfigPath | Out-Null
$taskArguments = @('--no-write-project', '--max-process-count=1',
    "--pcp=$PrimaryConfigPath", "--ws=$WidgetSet", "--lazarusdir=$(Split-Path -Parent $taskLazBuild)")
if ($Compiler) { $taskArguments += "--compiler=$((Get-Command $Compiler -ErrorAction Stop).Source)" }

# Package links go to an isolated build configuration; the user's IDE is untouched.
$taskPackages = @('h5uGridCoreLazarus', 'h5uGridLcl')
if (-not $SkipDesignPackages) {
    $taskPackages = @('h5uGridCoreLazarus', 'h5uGridLcl', 'h5uGridCoreLazarusDesign', 'h5uGridLclDesign')
}
foreach ($taskPackage in $taskPackages) {
    $taskPath = Join-Path $taskRoot "Packages\$taskPackage.lpk"
    & $taskLazBuild @taskArguments '--add-package-link' $taskPath
    if ($LASTEXITCODE -ne 0) { throw "Lazarus-Paketlink fehlgeschlagen: $taskPackage" }
}
foreach ($taskPackage in $taskPackages) {
    & $taskLazBuild @taskArguments (Join-Path $taskRoot "Packages\$taskPackage.lpk")
    if ($LASTEXITCODE -ne 0) { throw "Lazarus-Paketbuild fehlgeschlagen: $taskPackage" }
}
if (-not $SkipDemos) {
    foreach ($taskDemo in @('ClientDataset', 'ObjectList', 'VirtualLive')) {
        & $taskLazBuild @taskArguments (Join-Path $taskRoot "Demos\LCL\$taskDemo\GridLcl${taskDemo}Demo.lpi")
        if ($LASTEXITCODE -ne 0) { throw "Lazarus-Demobuild fehlgeschlagen: $taskDemo" }
    }
}
if ($IncludeTests) {
    foreach ($taskTest in @('TestLclDemoResources', 'TestLclBehavior')) {
        & $taskLazBuild @taskArguments (Join-Path $PSScriptRoot "$taskTest.lpi")
        if ($LASTEXITCODE -ne 0) { throw "Lazarus-Testbuild fehlgeschlagen: $taskTest" }
    }
}
