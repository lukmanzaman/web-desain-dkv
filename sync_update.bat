@echo off
title Sinkronisasi Update ke GitHub - web-desain-dkv
cd /d "%~dp0"

echo =================================================================
echo  Sinkronisasi Perubahan / Tambahan Materi ke GitHub
echo  Target: https://github.com/lukmanzaman/web-desain-dkv
echo =================================================================
echo.

echo [1/3] Memeriksa status berkas lokal...
git status -s
echo.

echo [2/3] Menyiapkan berkas yang baru atau diedit...
git add -A

git diff-index --quiet HEAD --
if %ERRORLEVEL% equ 0 (
    echo [INFO] Tidak ada perubahan berkas baru yang perlu diunggah.
    goto :end
)

echo.
set /p msg="Masukkan catatan update (tekan ENTER untuk catatan otomatis): "
if "%msg%"=="" set msg=Update materi dan berkas pendukung (%date% %time%)

git commit -m "%msg%"

echo.
echo [3/3] Mengunggah perubahan ke GitHub...
git push origin main

if %ERRORLEVEL% equ 0 (
    echo.
    echo =================================================================
    echo  [BERHASIL] Seluruh pembaruan telah tersinkron ke GitHub!
    echo =================================================================
) else (
    echo.
    echo =================================================================
    echo  [PERINGATAN] Terjadi kendala koneksi saat melakukan push.
    echo  Silakan coba jalankan sync_update.bat kembali nanti.
    echo =================================================================
)

:end
echo.
echo Tekan tombol apa saja untuk menutup jendela ini...
pause >nul
