[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$BinaryDirectory,
    [string]$ExpectedIcon = (Join-Path $PSScriptRoot '..\Icons\h5uGridDemo.ico')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not ('H5uDemoIconResources' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
public static class H5uDemoIconResources {
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern IntPtr LoadLibraryEx(string path, IntPtr reserved, uint flags);
    [DllImport("kernel32.dll")]
    public static extern bool FreeLibrary(IntPtr module);
    [DllImport("kernel32.dll", EntryPoint="FindResourceW", CharSet=CharSet.Unicode, SetLastError=true)]
    private static extern IntPtr FindNamed(IntPtr module, string name, IntPtr type);
    [DllImport("kernel32.dll", EntryPoint="FindResourceW", SetLastError=true)]
    private static extern IntPtr FindNumbered(IntPtr module, IntPtr name, IntPtr type);
    [DllImport("kernel32.dll", SetLastError=true)]
    private static extern IntPtr LoadResource(IntPtr module, IntPtr resource);
    [DllImport("kernel32.dll")]
    private static extern IntPtr LockResource(IntPtr resource);
    [DllImport("kernel32.dll")]
    private static extern uint SizeofResource(IntPtr module, IntPtr resource);
    private static byte[] Read(IntPtr module, IntPtr resource) {
        if (resource == IntPtr.Zero) throw new Win32Exception(Marshal.GetLastWin32Error());
        byte[] bytes = new byte[SizeofResource(module, resource)];
        IntPtr data = LockResource(LoadResource(module, resource));
        if (data == IntPtr.Zero) throw new Win32Exception(Marshal.GetLastWin32Error());
        Marshal.Copy(data, bytes, 0, bytes.Length);
        return bytes;
    }
    public static byte[] MainIcon(IntPtr module) { return Read(module, FindNamed(module, "MAINICON", (IntPtr)14)); }
    public static byte[] IconImage(IntPtr module, int id) { return Read(module, FindNumbered(module, (IntPtr)id, (IntPtr)3)); }
}
'@
}

$icon = [IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $ExpectedIcon).Path)
$count = [BitConverter]::ToUInt16($icon, 4)
$sha = [Security.Cryptography.SHA256]::Create()
try {
    foreach ($framework in @('Vcl', 'Fmx')) {
        foreach ($demo in @('ClientDataset', 'ObjectList', 'VirtualLive')) {
            $exe = (Resolve-Path -LiteralPath (Join-Path $BinaryDirectory "Grid${framework}${demo}Demo.exe")).Path
            # Load only resources; this does not start the executable.
            $module = [H5uDemoIconResources]::LoadLibraryEx($exe, [IntPtr]::Zero, 0x22)
            if ($module -eq [IntPtr]::Zero) { throw "EXE-Ressourcen nicht lesbar: $exe" }
            try {
                $group = [H5uDemoIconResources]::MainIcon($module)
                if ([BitConverter]::ToUInt16($group, 4) -ne $count) { throw "Unvollständiges MAINICON: $exe" }
                for ($i = 0; $i -lt $count; $i++) {
                    $entry = 6 + 16 * $i
                    $length = [BitConverter]::ToUInt32($icon, $entry + 8)
                    $offset = [BitConverter]::ToUInt32($icon, $entry + 12)
                    $id = [BitConverter]::ToUInt16($group, 6 + 14 * $i + 12)
                    $image = [H5uDemoIconResources]::IconImage($module, $id)
                    $expectedHash = [Convert]::ToBase64String($sha.ComputeHash($icon, $offset, $length))
                    $actualHash = [Convert]::ToBase64String($sha.ComputeHash($image))
                    if ($actualHash -ne $expectedHash) { throw "Abweichendes Icon-Bild $i in $exe" }
                }
                Write-Output "PASS: $([IO.Path]::GetFileName($exe)) MAINICON, alle $count Bilder entsprechen h5uGridDemo.ico"
            }
            finally { [void][H5uDemoIconResources]::FreeLibrary($module) }
        }
    }
}
finally { $sha.Dispose() }
