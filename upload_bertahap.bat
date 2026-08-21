@echo off
title Upload Bertahap ke GitHub - web-desain-dkv
cd /d "%~dp0"

echo =================================================================
echo  Menjalankan Upload Bertahap ke GitHub (web-desain-dkv)
echo =================================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0upload_bertahap.ps1"

echo.
echo Tekan tombol apa saja untuk menutup jendela ini...
pause >nul
