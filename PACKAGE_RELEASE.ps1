# Create a standalone binary release from the current BIN/NBJWLINK.EXE.
# This never packages the Open Watcom compiler or JWASM assembler.
param([string]$Version='0.0.10')
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path
$exe=Join-Path $root 'BIN\NBJWLINK.EXE'
if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) {throw 'Missing BIN\NBJWLINK.EXE'}
# Do not accidentally republish an old binary under a new version.
$exeBytes=[IO.File]::ReadAllBytes($exe)
$banner=[Text.Encoding]::ASCII.GetString($exeBytes)
if (-not $banner.Contains('https://github.com/techdistractions/NBJWLINK')) {
    throw 'Executable lacks the new embedded source URL. Rebuild and promote first.'
}
$dist=Join-Path $root 'dist'
$stage=Join-Path $dist "NBJWLINK_${Version}_Win32"
if (Test-Path $stage) {Remove-Item -LiteralPath $stage -Recurse -Force}
New-Item -ItemType Directory -Force -Path $stage | Out-Null
Copy-Item -LiteralPath $exe -Destination (Join-Path $stage 'NBJWLINK.EXE')
Copy-Item -LiteralPath (Join-Path $root 'LICENSE.txt') -Destination (Join-Path $stage 'LICENSE.txt')
Copy-Item -LiteralPath (Join-Path $root 'NOTICE.txt') -Destination (Join-Path $stage 'NOTICE.txt')
Copy-Item -LiteralPath (Join-Path $root 'RELEASE_NOTES.md') -Destination (Join-Path $stage 'RELEASE_NOTES.md')
@'
NBJWLINK Windows x86 executable - modified JWlink linker.

The modified source is available under the Sybase Open Watcom Public
License v1.0 from: https://github.com/techdistractions/NBJWLINK

See LICENSE.txt for the complete terms and NOTICE.txt for source availability,
attribution, and acceptance language. Any use, including reproduction,
modification or distribution, constitutes acceptance of the license.
Do not use the covered code if you do not accept all the license terms.

No Open Watcom compiler or JWASM assembler is bundled.
Run NBJWLINK.EXE @app.rsp where app.rsp contains linker directives.
See RELEASE_NOTES.md for compatibility/testing limitations.
'@ | Set-Content -LiteralPath (Join-Path $stage 'README.txt') -Encoding ASCII
$hash=(Get-FileHash -LiteralPath (Join-Path $stage 'NBJWLINK.EXE') -Algorithm SHA256).Hash.ToLowerInvariant()
"$hash  NBJWLINK.EXE" | Set-Content -LiteralPath (Join-Path $stage 'SHA256SUMS.txt') -Encoding ASCII
$zip=Join-Path $dist "NBJWLINK_${Version}_Win32.zip"
if (Test-Path $zip) {Remove-Item -LiteralPath $zip -Force}
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip
Write-Host "Created $zip"
