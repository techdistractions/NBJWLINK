param([string]$Watcom = $env:WATCOM, [string]$BuiltLinker = '')
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).ProviderPath
function AssertPe32([string]$path) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {throw "Missing $path"}
    $b=[IO.File]::ReadAllBytes($path)
    if ($b.Length -lt 16384) {throw "Unexpectedly small executable $path"}
    if ($b[0] -ne 0x4d -or $b[1] -ne 0x5a) {throw "Missing MZ header $path"}
    $p=[BitConverter]::ToInt32($b,0x3c)
    if ($p -lt 0x40 -or $p+0x18 -ge $b.Length) {throw "Bad PE header offset $path"}
    if ($b[$p] -ne 0x50 -or $b[$p+1] -ne 0x45 -or $b[$p+2] -ne 0 -or $b[$p+3] -ne 0) {throw "Not PE $path"}
    if ([BitConverter]::ToUInt16($b,$p+4) -ne 0x14c) {throw "Not 32-bit x86: $path"}
    if ([BitConverter]::ToUInt16($b,$p+0x18) -ne 0x10b) {throw "Not PE32: $path"}
    Write-Output "PASS Windows PE32/x86: $path"
}
if ([string]::IsNullOrWhiteSpace($Watcom)) {throw 'Set WATCOM to the root of your installed Open Watcom toolchain.'}
$bin = Join-Path $Watcom 'binnt'
foreach ($n in 'wcc386.exe','wmake.exe','wlib.exe','wlink.exe') { AssertPe32 (Join-Path $bin $n) }
AssertPe32 (Join-Path $root 'BOOTSTRAP\JWlink.exe')
if ($BuiltLinker) {AssertPe32 $BuiltLinker}
