[CmdletBinding()]
param(
    [ValidateSet('Win32', 'Win64')]
    [string]$Platform = 'Win32',

    [string]$DelphiBin,

    [string]$RsVars,

    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Debug',

    [string]$OutputRoot = (Join-Path $PSScriptRoot 'Output'),

    [switch]$SkipRuntimePackages,
    [switch]$SkipDesignPackages,
    [switch]$SkipDemos,
    [switch]$Clean
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Import-BatchEnvironment {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$BatchFile)

    if (-not (Test-Path -LiteralPath $BatchFile -PathType Leaf)) {
        throw "rsvars.bat wurde nicht gefunden: $BatchFile"
    }

    $command = 'call "{0}" >nul && set' -f $BatchFile
    $lines = & $env:ComSpec /d /s /c $command
    if ($LASTEXITCODE -ne 0) {
        throw "rsvars.bat wurde mit Exitcode $LASTEXITCODE beendet."
    }

    foreach ($line in $lines) {
        $separator = $line.IndexOf('=')
        if ($separator -le 0) { continue }
        $name = $line.Substring(0, $separator)
        $value = $line.Substring($separator + 1)
        [Environment]::SetEnvironmentVariable($name, $value, 'Process')
    }
}

function Resolve-DelphiBin {
    [CmdletBinding()]
    param([string]$ExplicitBin)

    if ($ExplicitBin) {
        return (Resolve-Path -LiteralPath $ExplicitBin).Path
    }

    if ($env:BDSBIN -and (Test-Path -LiteralPath $env:BDSBIN -PathType Container)) {
        return (Resolve-Path -LiteralPath $env:BDSBIN).Path
    }

    if ($env:BDS) {
        $candidate = Join-Path $env:BDS 'bin'
        if (Test-Path -LiteralPath $candidate -PathType Container) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    throw 'DelphiBin konnte nicht ermittelt werden. Übergib -DelphiBin oder lade die BDS-Umgebung über -RsVars.'
}

function Invoke-Dcc {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Project,
        [Parameter(Mandatory)][string]$Compiler,
        [Parameter(Mandatory)][string]$DcuOutput,
        [Parameter(Mandatory)][string]$BinaryOutput,
        [Parameter(Mandatory)][string]$PackageOutput,
        [Parameter(Mandatory)][string]$SearchPath,
        [string[]]$Defines = @()
    )

    if (-not (Test-Path -LiteralPath $Project -PathType Leaf)) {
        throw "Projektdatei fehlt: $Project"
    }

    foreach ($directory in @($DcuOutput, $BinaryOutput, $PackageOutput)) {
        New-Item -ItemType Directory -Force -Path $directory | Out-Null
    }

    $arguments = @(
        '-B',
        '-Q',
        "-N0$DcuOutput",
        "-E$BinaryOutput",
        "-LE$PackageOutput",
        "-LN$PackageOutput",
        "-U$SearchPath",
        "-I$SearchPath"
    )

    if ($Configuration -eq 'Debug') {
        $arguments += @('-DDEBUG', '-$D+', '-$L+', '-$Y+')
    }
    else {
        $arguments += @('-DRELEASE', '-$D-', '-$L-', '-$Y-')
    }

    foreach ($define in $Defines) {
        if ($define) { $arguments += "-D$define" }
    }

    $arguments += $Project
    Write-Host "`n==> $([IO.Path]::GetFileName($Project)) [$Platform/$Configuration]"
    & $Compiler @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "DCC fehlgeschlagen (Exitcode $LASTEXITCODE): $Project"
    }
}

function Invoke-DemoProject {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Project)

    # Use the selected compiler and repository paths, independent of private IDE settings.
    $demoSearchPath = $searchPath + ';' + (Join-Path $resolvedBin "..\lib\$Platform\release")

    # DCC alone does not generate the icon/version/manifest resources from the
    # DPROJ. In particular, an Android build can leave an empty Windows RES.
    $projectFile = [IO.Path]::ChangeExtension($Project, '.dproj')
    if (-not (Test-Path -LiteralPath $projectFile -PathType Leaf)) {
        throw "Demo-Projektdatei fehlt: $projectFile"
    }
    foreach ($directory in @($dcuOutput, $binaryOutput, $packageOutput)) {
        New-Item -ItemType Directory -Force -Path $directory | Out-Null
    }
    $arguments = @(
        $projectFile, '/nologo', '/t:Build', '/v:minimal',
        '/p:EnvironmentSettings=', '/p:ImportEnvOptions=false',
        "/p:DCC_UnitSearchPath=$($demoSearchPath.Replace(';', '%3B'))",
        "/p:Config=$Configuration", "/p:Platform=$Platform", '/p:DCC_BuildAllUnits=true',
        "/p:DCC_DcuOutput=$dcuOutput", "/p:DCC_ExeOutput=$binaryOutput",
        "/p:DCC_DcpOutput=$packageOutput", "/p:DCC_BplOutput=$packageOutput"
    )
    Write-Host "`n==> $([IO.Path]::GetFileName($projectFile)) [$Platform/$Configuration]"
    & $msbuild @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "MSBuild fehlgeschlagen (Exitcode $LASTEXITCODE): $projectFile"
    }
}

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

if ($RsVars) {
    Import-BatchEnvironment -BatchFile $RsVars
}

$resolvedBin = Resolve-DelphiBin -ExplicitBin $DelphiBin
if (-not $SkipDemos) {
    if (-not $RsVars) {
        Import-BatchEnvironment -BatchFile (Join-Path $resolvedBin 'rsvars.bat')
    }
    $msbuild = Join-Path $env:FrameworkDir 'MSBuild.exe'
    if (-not (Test-Path -LiteralPath $msbuild -PathType Leaf)) {
        throw "MSBuild wurde nicht gefunden: $msbuild"
    }
}
$compilerName = if ($Platform -eq 'Win64') { 'dcc64.exe' } else { 'dcc32.exe' }
$compiler = Join-Path $resolvedBin $compilerName
if (-not (Test-Path -LiteralPath $compiler -PathType Leaf)) {
    throw "Compiler wurde nicht gefunden: $compiler"
}

$output = Join-Path ([IO.Path]::GetFullPath($OutputRoot)) "$Platform\$Configuration"
$dcuOutput = Join-Path $output 'dcu'
$binaryOutput = Join-Path $output 'bin'
$packageOutput = Join-Path $output 'bpl'

if ($Clean -and (Test-Path -LiteralPath $output)) {
    Remove-Item -LiteralPath $output -Recurse -Force
}

$searchDirectories = @(
    (Join-Path $root 'Source\Common'),
    (Join-Path $root 'Source\VCL'),
    (Join-Path $root 'Source\FMX'),
    (Join-Path $root 'Source\Design'),
    $dcuOutput,
    $packageOutput
)
$searchPath = ($searchDirectories -join ';')

$runtimePackages = @(
    (Join-Path $root 'Packages\h5uGridCoreR.dpk'),
    (Join-Path $root 'Packages\h5uGridVclR.dpk'),
    (Join-Path $root 'Packages\h5uGridFmxR.dpk')
)

$designPackages = @(
    (Join-Path $root 'Packages\h5uGridCoreD.dpk'),
    (Join-Path $root 'Packages\h5uGridVclD.dpk'),
    (Join-Path $root 'Packages\h5uGridFmxD.dpk')
)

$demoProjects = @(
    (Join-Path $root 'Demos\VCL\ClientDataset\GridVclClientDatasetDemo.dpr'),
    (Join-Path $root 'Demos\VCL\ObjectList\GridVclObjectListDemo.dpr'),
    (Join-Path $root 'Demos\VCL\VirtualLive\GridVclVirtualLiveDemo.dpr'),
    (Join-Path $root 'Demos\FMX\ClientDataset\GridFmxClientDatasetDemo.dpr'),
    (Join-Path $root 'Demos\FMX\ObjectList\GridFmxObjectListDemo.dpr'),
    (Join-Path $root 'Demos\FMX\VirtualLive\GridFmxVirtualLiveDemo.dpr')
)

if (-not $SkipRuntimePackages) {
    foreach ($package in $runtimePackages) {
        Invoke-Dcc -Project $package -Compiler $compiler -DcuOutput $dcuOutput `
            -BinaryOutput $binaryOutput -PackageOutput $packageOutput -SearchPath $searchPath
    }
}

if (-not $SkipDesignPackages) {
    if ($Platform -ne 'Win32') {
        Write-Warning 'Design-Time-Packages werden übersprungen: Sie werden für die Delphi-IDE üblicherweise als Win32-Package gebaut.'
    }
    else {
        foreach ($package in $designPackages) {
            Invoke-Dcc -Project $package -Compiler $compiler -DcuOutput $dcuOutput `
                -BinaryOutput $binaryOutput -PackageOutput $packageOutput -SearchPath $searchPath -Defines @('DESIGNIDE')
        }
    }
}

if (-not $SkipDemos) {
    foreach ($demo in $demoProjects) {
        Invoke-DemoProject -Project $demo
    }
    & (Join-Path $PSScriptRoot 'test-demo-icons.ps1') -BinaryDirectory $binaryOutput
}

Write-Host "`nBuild abgeschlossen. Ausgabe: $output"
