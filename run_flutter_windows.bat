@echo off
title ANEUSO Flutter - Windows
cd /d "%~dp0"
echo.
echo ========================================
echo   ANEUSO Flutter (Windows)
echo ========================================
echo.
echo Starting app... When you see "Flutter run key commands":
echo   r  = hot reload   (after small code changes)
echo   R  = hot restart  (full restart)
echo   q  = quit
echo.
flutter run -d windows
pause
