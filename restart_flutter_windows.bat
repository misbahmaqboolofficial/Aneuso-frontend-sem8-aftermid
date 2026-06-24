@echo off
title ANEUSO Flutter - Restart
cd /d "%~dp0"
echo Stopping old app...
taskkill /IM aneuso_app.exe /F 2>nul
timeout /t 2 /nobreak >nul
echo Starting Flutter...
flutter run -d windows
pause
