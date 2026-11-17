param([string]$Root = (Join-Path $PSScriptRoot '..'), [switch]$OnlyGui)
$ErrorActionPreference = 'Stop'
function Assert([bool]$v,[string]$m) { if (-not $v) {throw $m} }
function Read-NE([string]$path,[bool]$win1) {
    $b = [IO.File]::ReadAllBytes($path)
    function U16([int]$o) { return [BitConverter]::ToUInt16($b,$o) }
    function U32([int]$o) { return [BitConverter]::ToUInt32($b,$o) }
    Assert ($b.Length -ge 128) "Too short: $path"
    Assert ((U16 0) -eq 0x5A4D) 'Bad MZ'
    $ne = [int](U32 0x3c)
    Assert ($ne -gt 0 -and $ne + 0x40 -lt $b.Length) 'Bad e_lfanew'
    Assert ((U16 $ne) -eq 0x454e) 'Bad NE'
    $segs = U16 ($ne + 0x1c)
    $segtable = U16 ($ne + 0x22)
    $res = U16 ($ne + 0x24)
    $resident = U16 ($ne + 0x26)
    $shift = U16 ($ne + 0x32)
    Write-Output ('CHECK NE {0}: size={1}; header=0x{2:X}; shift={3}; segs={4}; WIN1={5}' -f (Split-Path $path -Leaf),$b.Length,$ne,$shift,$segs,$win1)
    Assert ($segs -ge 1 -and $segs -lt 64) 'Unreasonable segment count'
    Assert ($ne + $segtable + $segs*8 -le $b.Length) 'Segment table exceeds file'
    if ($win1) {
        Assert ($shift -ge 4) ('WIN1 expected shift >=4, got '+$shift+' for '+$path+'; stale JWLINK object files? Run MAKE.CMD from 0.0.9')
        Assert ($ne -eq 0x400) "WIN1 expected 0x400 NE; got $ne"
        Assert ($b[$ne+0x36] -eq 0) 'Wrong WIN1 target OS'
        Assert ((U16 ($ne+0x3e)) -eq 0) 'Wrong WIN1 expected version'
        Assert (((U16 ($ne+12)) -band 0x0208) -eq 0) 'Protected-mode Windows flags found'
        Assert ($res -eq ($segtable + $segs*8)) 'Resource table not next to segment table'
        Assert ($resident -ge ($res + 4)) 'Missing empty resource table'
        Assert ((U16 ($ne+$res+2)) -eq 0) 'Missing resource terminator'
        $pages = U16 4
        $cblp = U16 2
        $mzsize = (($pages-1)*512) + $(if($cblp -eq 0){512}else{$cblp})
        Assert ($mzsize -eq $b.Length) 'DOS header length not equal to physical file length'
    } else {
        Assert ($b[$ne+0x36] -eq 2) 'Default Windows target OS changed'
        Assert ((U16 ($ne+0x3e)) -eq 0x0300) 'Default Windows expected version changed'
    }
    for ($s=0; $s -lt $segs; $s++) {
        $o=$ne+$segtable+$s*8
        $so=U16 $o
        $ss=U16 ($o+2)
        $sf=U16 ($o+4)
        if ($so -ne 0) {
            $phys=$so -shl $shift
            Assert ($phys -lt $b.Length) "Segment $s offset beyond EOF"
            if ($ss -ne 0) { Assert ($phys + $ss -le $b.Length) "Segment $s crosses EOF" }
        }
        if ($win1 -and $so -ne 0) {
            if (($sf -band 1) -eq 1) { Assert (($sf -band 0x50) -eq 0x50) 'WIN1 DATA flags wrong' }
            else { Assert (($sf -band 0x1070) -eq 0x1070) 'WIN1 CODE flags wrong' }
        }
    }
    Write-Output ("PASS NE {0} bytes={1} NE={2:X} segs={3} win1={4}" -f (Split-Path $path -Leaf),$b.Length,$ne,$segs,$win1)
}
$rootPath=(Resolve-Path $Root).Path
if ($OnlyGui) {
    Read-NE (Join-Path $rootPath 'OUTPUT\WIN1GUI.EXE') $true
} else {
    Read-NE (Join-Path $rootPath 'OUTPUT\WIN1MIN.EXE') $true
    Read-NE (Join-Path $rootPath 'OUTPUT\WIN1MULTI.EXE') $true
    Read-NE (Join-Path $rootPath 'OUTPUT\STDNE.EXE') $false
    $b=[IO.File]::ReadAllBytes((Join-Path $rootPath 'OUTPUT\WIN1MULTI.EXE'))
    $ne=[BitConverter]::ToUInt32($b,0x3c)
    $off=[BitConverter]::ToUInt16($b,$ne+0x40)
    $shift=[BitConverter]::ToUInt16($b,$ne+0x32)
    $code=$off -shl $shift
    Assert (($b[$code] -eq 0xE8) -and ($b[$code+1] -eq 13) -and ($b[$code+2] -eq 0)) 'Cross-OBJ CALL fixup not resolved as expected'
    Write-Output 'PASS inter-object near CALL FIXUPP target offset'
}
