@echo off
setlocal

set "LANG_ARG=%~1"
if "%LANG_ARG%"=="" (
  echo Select minimal-coder prompt language:
  echo   [1] English ^(en^) [default]
  echo   [2] Simplified Chinese ^(zh-CN^)
  echo   [3] Traditional Chinese ^(zh-TW^)
  set /p "LANG_ARG=Enter choice (1/2/3): "
)

if "%LANG_ARG%"=="" set "LANG_ARG=en"
set "LANG_ARG=%LANG_ARG: =%"
if "%LANG_ARG%"=="" set "LANG_ARG=en"

set "LANG_DIR="
if /i "%LANG_ARG%"=="1" set "LANG_DIR=en"
if /i "%LANG_ARG%"=="en" set "LANG_DIR=en"
if /i "%LANG_ARG%"=="2" set "LANG_DIR=zh-CN"
if /i "%LANG_ARG%"=="zh-CN" set "LANG_DIR=zh-CN"
if /i "%LANG_ARG%"=="zh_CN" set "LANG_DIR=zh-CN"
if /i "%LANG_ARG%"=="3" set "LANG_DIR=zh-TW"
if /i "%LANG_ARG%"=="zh-TW" set "LANG_DIR=zh-TW"
if /i "%LANG_ARG%"=="zh_TW" set "LANG_DIR=zh-TW"

if "%LANG_DIR%"=="" (
  echo [ERROR] Unsupported language option: "%LANG_ARG%". Use en, zh-CN, or zh-TW.
  exit /b 1
)

set "SRC=%~dp0agents\%LANG_DIR%\minimal-coder\agent.md"
set "TARGET_DIR=%USERPROFILE%\.gemini\config\agents\minimal-coder"
set "TARGET=%TARGET_DIR%\agent.md"

if not exist "%SRC%" (
  echo [ERROR] Source file not found: "%SRC%"
  exit /b 1
)

if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"
copy /y "%SRC%" "%TARGET%" >nul
if errorlevel 1 (
  echo [ERROR] Failed to install minimal-coder to "%TARGET%"
  exit /b 1
)

echo Installed minimal-coder (%LANG_DIR%) to "%TARGET%"
endlocal
