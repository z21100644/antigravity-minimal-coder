@echo off
setlocal

set "TARGET_DIR=%USERPROFILE%\.gemini\config\agents\minimal-coder"
set "TARGET=%TARGET_DIR%\agent.md"

if exist "%TARGET%" (
  del /f /q "%TARGET%"
  rmdir "%TARGET_DIR%" 2>nul
  echo Removed "%TARGET%"
) else (
  echo Not installed: "%TARGET%"
)

endlocal
