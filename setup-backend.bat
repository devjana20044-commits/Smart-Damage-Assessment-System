@echo off
chcp 65001 >nul 2>&1
title Smart Damage Assessment - Backend Setup

echo ============================================================
echo    Smart Damage Assessment System - Backend Setup
echo ============================================================
echo.

set "PROJECT_DIR=C:\Users\Abdalgani\Desktop\Smart-Damage-Assessment-System"
set "BACKEND_DIR=%PROJECT_DIR%\backend"
set "TEMP_CLONE=%TEMP%\smart-damage-remote"
set "DB_NAME=smart_damage_assessment"

echo [1/8] Cloning remote repository...
if exist "%TEMP_CLONE%" (
    echo       Removing old clone...
    rmdir /s /q "%TEMP_CLONE%" 2>nul
)
git clone https://github.com/nashwa-04/Smart-Damage-Assessment-System.git "%TEMP_CLONE%"
if %errorlevel% neq 0 (
    echo       ERROR: Git clone failed!
    pause
    exit /b 1
)
echo       Done.
echo.

echo [2/8] Removing old backend...
if exist "%BACKEND_DIR%" (
    rmdir /s /q "%BACKEND_DIR%" 2>nul
    echo       Old backend removed.
)
echo.

echo [3/8] Copying new backend from remote repo...
xcopy "%TEMP_CLONE%\backend" "%BACKEND_DIR%\" /e /i /y /q
echo       New backend copied.
echo.

echo [4/8] Creating MySQL database "%DB_NAME%"...
mysql -u root -e "CREATE DATABASE IF NOT EXISTS %DB_NAME% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>nul
if %errorlevel% equ 0 (
    echo       Database created/verified.
) else (
    echo       WARNING: Could not create database automatically.
    echo       Please create it manually: CREATE DATABASE %DB_NAME%;
)
echo.

echo [5/8] Configuring .env file...
if not exist "%BACKEND_DIR%\.env" (
    copy "%BACKEND_DIR%\.env.example" "%BACKEND_DIR%\.env" >nul
    echo       .env created from .env.example
) else (
    echo       .env already exists, skipping copy.
)

REM Update .env for MySQL using PowerShell
powershell -Command "(Get-Content '%BACKEND_DIR%\.env') -replace 'DB_CONNECTION=sqlite', 'DB_CONNECTION=mysql' -replace '# DB_HOST=127.0.0.1', 'DB_HOST=127.0.0.1' -replace '# DB_PORT=3306', 'DB_PORT=3306' -replace '# DB_DATABASE=laravel', 'DB_DATABASE=%DB_NAME%' -replace '# DB_USERNAME=root', 'DB_USERNAME=root' -replace '# DB_PASSWORD=', 'DB_PASSWORD=' | Set-Content '%BACKEND_DIR%\.env'"
echo       .env configured for MySQL.
echo.

echo [6/8] Installing Composer dependencies...
cd /d "%BACKEND_DIR%"
composer install --no-interaction 2>&1
if %errorlevel% neq 0 (
    echo       WARNING: Composer install had issues.
)
echo.

echo [7/8] Generating app key and running migrations...
php artisan key:generate --force
echo       App key generated.
echo.
php artisan migrate --force
if %errorlevel% neq 0 (
    echo       WARNING: Migration had issues.
)
echo.

echo [8/8] Creating storage link...
php artisan storage:link --force 2>nul
echo.

echo ============================================================
echo    SETUP COMPLETE!
echo ============================================================
echo.
echo    Backend location: %BACKEND_DIR%
echo    Database: %DB_NAME% (MySQL)
echo.
echo    To start the server, run:
echo      cd /d "%BACKEND_DIR%"
echo      php artisan serve --host=0.0.0.0 --port=8000
echo.
echo    Or run: start-backend.bat
echo.

cd /d "%PROJECT_DIR%"
pause
