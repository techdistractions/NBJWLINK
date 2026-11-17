# Recreate DOCS/MANIFEST.sha256 from all tracked release inputs, excluding outputs.
$ErrorActionPreference='Stop'
$root=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).ProviderPath
$manifest=Join-Path $root 'DOCS\MANIFEST.sha256'
$exclude='^(?i:(?:\.git|BUILD|LOGS|OUTPUT|dist|TOOLS|OW_PORTABLE)\\|SOURCE\\jwlink-2\.0\\build\\)'
$files=Get-ChildItem -LiteralPath $root -Recurse -File | Where-Object {
    $rel=$_.FullName.Substring($root.Length).TrimStart('\')
    ($_.FullName -ne $manifest) -and ($rel -notmatch $exclude)
}
$lines=@($files | ForEach-Object {
    $rel=$_.FullName.Substring($root.Length).TrimStart('\').Replace('\','/')
    $hash=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    '{0}  {1}' -f $hash,$rel
} | Sort-Object)
# Sort by normalized path rather than checksum (keeps the same stable order).
$lines=@($lines | Sort-Object {($_ -split '  ',2)[1]})
[IO.File]::WriteAllText($manifest,(($lines -join "`n")+"`n"),[Text.Encoding]::ASCII)
Write-Host ('PASS: refreshed manifest with {0} files' -f $lines.Count)
