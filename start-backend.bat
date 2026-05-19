@echo off
chcp 65001 >nul 2>&1
title Smart Damage Assessment - Backend Server

echo ============================================================
echo    Smart Damage Assessment - Laravel Server
echo    Access: http://localhost:8000
echo    Network: http://0.0.0.0:8000
echo ============================================================
echo.
echo    Press Ctrl+C to stop the server.
echo.

cd /d "C:\Users\Abdalgani\Desktop\Smart-Damage-Assessment-System\backend"

REM Start queue worker in background
start "Queue Worker" /min php artisan queue:work --tries=3 --timeout=120

REM Start Laravel server
php artisan serve --host=0.0.0.0 --port=8000
