# Create a standalone binary release from the current BIN/NBJWLINK.EXE.
# This never packages the Open Watcom compiler or JWASM assembler.
param([string]$Version='0.0.9')
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path
$exe=Join-Path $root 'BIN\NBJWLINK.EXE'
if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) {throw 'Missing BIN\NBJWLINK.EXE'}
$dist=Join-Path $root 'dist'
$stage=Join-Path $dist "NBJWLINK_${Version}_Win32"
if (Test-Path $stage) {Remove-Item -LiteralPath $stage -Recurse -Force}
New-Item -ItemType Directory -Force -Path $stage | Out-Null
Copy-Item -LiteralPath $exe -Destination (Join-Path $stage 'NBJWLINK.EXE')
Copy-Item -LiteralPath (Join-Path $root 'LICENSE.txt') -Destination (Join-Path $stage 'LICENSE.txt')
Copy-Item -LiteralPath (Join-Path $root 'RELEASE_NOTES.md') -Destination (Join-Path $stage 'RELEASE_NOTES.md')
@'
NBJWLINK Windows x86 executable.
No compiler, assembler, installer or other Open Watcom programs are included.
Use NBJWLINK.EXE @app.rsp where app.rsp contains linker directives.
See RELEASE_NOTES.md for options, provenance and testing limitations.
'@ | Set-Content -LiteralPath (Join-Path $stage 'README.txt') -Encoding ASCII
$hash=(Get-FileHash -LiteralPath (Join-Path $stage 'NBJWLINK.EXE') -Algorithm SHA256).Hash.ToLowerInvariant()
"$hash  NBJWLINK.EXE" | Set-Content -LiteralPath (Join-Path $stage 'SHA256SUMS.txt') -Encoding ASCII
$zip=Join-Path $dist "NBJWLINK_${Version}_Win32.zip"
if (Test-Path $zip) {Remove-Item -LiteralPath $zip -Force}
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip
Write-Host "Created $zip"
