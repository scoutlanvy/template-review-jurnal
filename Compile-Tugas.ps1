param(
    [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$NIM = 'NIM',
    [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$Nama = 'Nama_Mahasiswa',
    [switch]$Open
)
$ErrorActionPreference = 'Stop'
$repoRoot = $PSScriptRoot
$buildDir = Join-Path $repoRoot 'tmp/build/tugas-review-jurnal'
$outputDir = $PSScriptRoot
$pdf = Join-Path $outputDir "ReviewJurnal_${NIM}_${Nama}.pdf"
Get-Command xelatex -ErrorAction Stop | Out-Null
New-Item -ItemType Directory -Force -Path $buildDir, $outputDir | Out-Null
Push-Location -LiteralPath $repoRoot
try {
    foreach ($pass in 1..2) {
        & xelatex '-interaction=nonstopmode' '-halt-on-error' '-file-line-error' "-output-directory=$buildDir" 'review-jurnal.tex'
        if ($LASTEXITCODE -ne 0) { throw "XeLaTeX gagal. Periksa $buildDir/review-jurnal.log" }
    }
    try {
        Copy-Item -LiteralPath (Join-Path $buildDir 'review-jurnal.pdf') -Destination $pdf -Force
    } catch {
        throw "Build selesai, tetapi PDF utama belum dapat diganti. Tutup '$pdf', lalu jalankan build lagi. Hasil build terbaru tetap tersedia di '$buildDir/review-jurnal.pdf'. Tidak dibuat PDF duplikat. Detail: $($_.Exception.Message)"
    }
    Write-Output "PDF: $pdf"
    if ($Open) { Invoke-Item -LiteralPath $pdf }
} finally {
    Pop-Location
}
