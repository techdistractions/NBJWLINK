param([Parameter(Mandatory=$true)][string]$Exe)
$ErrorActionPreference='Stop'
if (-not (Test-Path -LiteralPath $Exe -PathType Leaf)) { throw "Missing linker: $Exe" }
$b=[IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $Exe).ProviderPath)
if ($b.Length -lt 10000 -or $b[0] -ne 0x4D -or $b[1] -ne 0x5A) {
    throw 'The linker is not a valid MZ/PE executable.'
}
$pe=[BitConverter]::ToInt32($b,0x3C)
if ($pe -lt 0x40 -or $pe+0x18 -gt $b.Length -or [BitConverter]::ToUInt32($b,$pe) -ne 0x4550) {
    throw 'The linker is not a valid PE executable.'
}
$ascii=[Text.Encoding]::ASCII.GetString($b)
foreach($s in @('https://github.com/techdistractions/NBJWLINK',
                'Sybase Open Watcom Public License')) {
    if (-not $ascii.Contains($s)) {throw "Missing embedded source/license notice: $s"}
}
Write-Host 'PASS: binary contains embedded source location and licence notice.'
