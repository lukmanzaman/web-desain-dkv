# ==============================================================================
# Script Upload Bertahap ke GitHub: web-desain-dkv
# Penulis: Lukman Zaman - Institut STTS
# ==============================================================================

$ErrorActionPreference = "Continue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$RepoUrl = "https://github.com/lukmanzaman/web-desain-dkv.git"
$TotalBab = 71
$BatchSize = 5

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host "  UPLOAD BERTAHAP KE GITHUB: web-desain-dkv" -ForegroundColor Yellow
Write-Host "  Target: $RepoUrl" -ForegroundColor Gray
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host ""

# Konfigurasi safe.directory
git config --global --add safe.directory "*" 2>$null

# 1. Inisialisasi Git jika belum ada
if (-not (Test-Path ".git")) {
    Write-Host "[1/4] Menginisialisasi repositori Git lokal..." -ForegroundColor Green
    git init
    git branch -M main
    git remote add origin $RepoUrl
} else {
    Write-Host "[1/4] Repositori Git lokal sudah terhubung." -ForegroundColor Green
    git branch -M main 2>$null
    $remotes = git remote
    if ($remotes -notcontains "origin") {
        git remote add origin $RepoUrl
    } else {
        git remote set-url origin $RepoUrl
    }
}

# Konfigurasi buffer Git untuk file besar
git config http.postBuffer 524288000
git config http.lowSpeedLimit 1000
git config http.lowSpeedTime 60
git config core.compression 0

# Fungsi Push dengan Retry
function Push-WithRetry {
    param (
        [string]$Deskripsi,
        [int]$MaxRetry = 3
    )
    $attempt = 1
    while ($attempt -le $MaxRetry) {
        Write-Host "  -> Melakukan push ke GitHub ($Deskripsi) [Percobaan $attempt/$MaxRetry]..." -ForegroundColor Yellow
        git push origin main
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] Push $Deskripsi berhasil!" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  [!] Push gagal pada percobaan ke-$attempt. Menunggu 5 detik..." -ForegroundColor Red
            Start-Sleep -Seconds 5
            $attempt++
        }
    }
    Write-Host "  [GAGAL] Gagal mengunggah $Deskripsi setelah $MaxRetry percobaan." -ForegroundColor Red
    Write-Host "  Anda dapat menghentikan script dan melanjutkannya lagi kapan saja." -ForegroundColor Yellow
    return $false
}

# 2. Upload Tahap 1: Metadata dasar (README, .gitignore, scripts)
Write-Host ""
Write-Host "[2/4] Memeriksa Berkas Dasar (README, .gitignore, Scripts)..." -ForegroundColor Cyan
git add "README.md" ".gitignore" "upload_bertahap.bat" "upload_bertahap.ps1" "sync_update.bat" 2>$null
$statusBasic = git status --porcelain
if ($statusBasic) {
    git commit -m "Inisialisasi repositori: README, dokumentasi dan script otomasi"
    $pushOk = Push-WithRetry "Berkas Dasar"
    if (-not $pushOk) { exit 1 }
} else {
    $unpushed = git log origin/main..HEAD 2>$null
    if ($unpushed) {
        $pushOk = Push-WithRetry "Commit Pending"
        if (-not $pushOk) { exit 1 }
    } else {
        Write-Host "  [OK] Berkas dasar sudah terunggah." -ForegroundColor Green
    }
}

# 3. Upload Tahap 2: COMPANION & PDF Teks (Ukuran Ringan ~10MB)
Write-Host ""
Write-Host "[3/4] Memeriksa COMPANION Code & PDF Text Version..." -ForegroundColor Cyan
git add "PDF-text-version" "COMPANION" 2>$null
$statusCompanion = git status --porcelain
if ($statusCompanion) {
    git commit -m "Upload kode pendukung praktikum (COMPANION) dan PDF versi teks ringkas"
    $pushOk = Push-WithRetry "COMPANION & PDF Text"
    if (-not $pushOk) { exit 1 }
} else {
    Write-Host "  [OK] COMPANION dan PDF Text Version sudah tersinkron." -ForegroundColor Green
}

# 4. Upload Tahap 3: Materi Slide Besar (PPT & PDF) per Batch 5 Bab
Write-Host ""
Write-Host "[4/4] Mengunggah Slide PPT & PDF secara bertahap ($BatchSize Bab per batch)..." -ForegroundColor Cyan

for ($start = 1; $start -le $TotalBab; $start += $BatchSize) {
    $end = [math]::Min($start + $BatchSize - 1, $TotalBab)
    $batchLabel = "Bab $(("{0:D2}" -f $start)) s.d. $(("{0:D2}" -f $end))"
    
    # Kumpulkan berkas bab ini
    $batchFiles = @()
    for ($b = $start; $b -le $end; $b++) {
        $babPadded = "{0:D2}" -f $b
        $pptItems = Get-ChildItem -Path "PPT\bab-$babPadded-*" -File -ErrorAction SilentlyContinue
        $pdfItems = Get-ChildItem -Path "PDF\bab-$babPadded-*" -File -ErrorAction SilentlyContinue
        if ($pptItems) { $batchFiles += $pptItems.FullName }
        if ($pdfItems) { $batchFiles += $pdfItems.FullName }
    }

    if ($batchFiles.Count -gt 0) {
        git add $batchFiles 2>$null
    }

    $statusBatch = git status --porcelain
    if ($statusBatch) {
        Write-Host ""
        Write-Host "--- Memproses $batchLabel ($($batchFiles.Count) berkas) ---" -ForegroundColor Cyan
        git commit -m "Upload materi slide PPT dan PDF $batchLabel"
        $pushOk = Push-WithRetry "$batchLabel"
        if (-not $pushOk) {
            Write-Host ""
            Write-Host "[INFO] Proses upload dihentikan pada $batchLabel." -ForegroundColor Yellow
            Write-Host "Kemajuan yang sudah berhasil diupload tetap aman tersimpan di GitHub." -ForegroundColor Yellow
            Write-Host "Silakan jalankan script ini kembali nanti untuk melanjutkan bab berikutnya." -ForegroundColor Green
            exit 1
        }
    } else {
        Write-Host "  [LEWATI] $batchLabel sudah terupload." -ForegroundColor DarkGray
    }
}

# 5. Final check: Pastikan tidak ada berkas tersisa
Write-Host ""
Write-Host "--- Memeriksa berkas akhir... ---" -ForegroundColor Cyan
git add -A
$statusFinal = git status --porcelain
if ($statusFinal) {
    git commit -m "Upload berkas akhir pelengkap repositori"
    Push-WithRetry "Berkas Akhir"
}

Write-Host ""
Write-Host "=================================================================" -ForegroundColor Green
Write-Host "  [SELESAI] Seluruh 71 Bab dan berkas pendukung berhasil diupload!" -ForegroundColor Green
Write-Host "  URL Repositori: $RepoUrl" -ForegroundColor Yellow
Write-Host "=================================================================" -ForegroundColor Green
