@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\Setup-ScheduledTasks.ps1"
echo.
echo Done. You can close this window.
pause
