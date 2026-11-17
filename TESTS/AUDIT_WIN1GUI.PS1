param([Parameter(Mandatory=$true)][string]$Exe)
$ErrorActionPreference = 'Stop'
$b = [IO.File]::ReadAllBytes($Exe)
function U16([int]$i) { return [BitConverter]::ToUInt16($b,$i) }
function U32([int]$i) { return [BitConverter]::ToUInt32($b,$i) }
function Check([bool]$ok,[string]$why) { if (-not $ok) { throw ('GUI REJECT: '+$why) } }
Check ($b.Length -ge 0x480) 'file too small for Win1 NE'
Check ((U16 0) -eq 0x5A4D) 'missing MZ'
$ne = [int](U32 0x3C)
Check ($ne -eq 0x400) 'WIN1 NE header must be at 0400h'
Check ((U16 $ne) -eq 0x454E) 'missing NE'
Check ($b[$ne+0x36] -eq 0) 'WIN1 target OS must be zero'
Check ((U16 ($ne+0x3E)) -eq 0) 'WIN1 expected version must be zero'
$shift = U16 ($ne+0x32)
Check ($shift -ge 4) ('WIN1 segment alignment below 16 bytes; shift='+$shift)
$segCount=U16 ($ne+0x1C)
Check ($segCount -ge 2) 'missing CODE/DATA segments'
$segTable=U16 ($ne+0x22)
$codeSeg=$ne+$segTable
$off=(U16 $codeSeg) -shl $shift
$len=U16 ($codeSeg+2)
$flg=U16 ($codeSeg+4)
Check ($off -gt 0 -and ($off + $len + 2) -le $b.Length) 'invalid CODE segment or relocations'
Check (($flg -band 0x100) -ne 0) 'CODE relocation bit missing'
Check (($off -band 15) -eq 0) 'CODE segment not paragraph aligned'
for ($i=0;$i -lt 8;$i++) { Check ($b[$off+$i] -eq 0x90) ('missing NOWN startup NOP at '+$i) }
Check ($b[$off+8] -eq 0x9A) 'first instruction after NOPs is not FAR InitTask'
$relocAt=$off+$len
$relocCount=U16 $relocAt
Check ($relocCount -ge 4) ('expected at least 4 Win16 import relocations, got '+$relocCount)
Check (($relocAt+2+($relocCount*8)) -le $b.Length) 'CODE relocation table truncated'
$mods=U16 ($ne+0x1E)
$moduleTable=U16 ($ne+0x28)
$importTable=U16 ($ne+0x2A)
$names=@{}
for ($i=1;$i -le $mods;$i++) {
    $p=$ne+$importTable+(U16 ($ne+$moduleTable+(($i-1)*2)))
    $n=$b[$p]
    $names[$i]=[Text.Encoding]::ASCII.GetString($b,$p+1,$n).ToUpperInvariant()
}
$got=@{}
for ($i=0;$i -lt $relocCount;$i++) {
    $p=$relocAt+2+($i*8)
    $fixType=$b[$p]
    $flags=$b[$p+1]
    if ($fixType -ne 3 -or $flags -ne 1) { continue }
    $src=U16 ($p+2)
    $mi=U16 ($p+4)
    $ord=U16 ($p+6)
    if ($names.ContainsKey([int]$mi)) {
        $key=$names[[int]$mi]+'.'+$ord
        $got[$key]=$src
        Check ($src -lt $len) ('import fixup source beyond CODE at '+$src)
    }
}
$sequence=@('KERNEL.91','KERNEL.30','USER.5','USER.1')
$prior=-1
foreach ($key in $sequence) {
    Check ($got.ContainsKey($key)) ('missing import ordinal relocation '+$key)
    $pos=[int]$got[$key]
    Check ($pos -gt $prior) ('startup import call order wrong at '+$key)
    $prior=$pos
}
Write-Output ('PASS GUI WIN1 NE: shift='+$shift+'; code offset='+$off+'; ordinal imports='+($got.Keys -join ','))
Write-Output 'RUNTIME NOT YET VERIFIED: Windows 1.01 and Windows 3.0 /R guest execution required.'
