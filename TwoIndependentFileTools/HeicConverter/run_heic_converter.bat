@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"
title HEIC HEIF Batch Converter
set "PYTHON_CMD="
set "VENV_PY=%~dp0.venv\Scripts\python.exe"
echo ============================================================
echo   HEIC/HEIF to JPG/PNG Converter - independent launcher
echo ============================================================
call :find_python
if not defined PYTHON_CMD (
  echo Python 3.10+ was not found. Attempting current-user Python installation...
  call :install_python
  call :find_python
)
if not defined PYTHON_CMD goto :setup_failed
if not exist "%VENV_PY%" (
  %PYTHON_CMD% -m venv "%~dp0.venv"
  if errorlevel 1 goto :setup_failed
)
echo Installing/updating Pillow, pillow-heif/libheif, and piexif...
"%VENV_PY%" -m pip install --disable-pip-version-check --quiet --upgrade pip
"%VENV_PY%" -m pip install --disable-pip-version-check -r "%~dp0requirements.txt"
if errorlevel 1 goto :setup_failed
"%VENV_PY%" -c "import PIL,pillow_heif,piexif" >nul 2>nul
if errorlevel 1 goto :setup_failed
echo.
echo Starting HEIC/HEIF converter...
"%VENV_PY%" "%~dp0heic_batch_convert.py" %*
set "RC=%ERRORLEVEL%"
echo.
if "%RC%"=="0" echo Conversion completed successfully.
if "%RC%"=="1" echo Completed with conflicts/failures. Originals were preserved where required.
if "%RC%"=="4" echo Stopped safely. Originals were preserved where incomplete.
if "%RC%"=="130" echo Interrupted safely. Run again to resume remaining work.
pause
exit /b %RC%
:find_python
py -3.12 -c "import sys;raise SystemExit(0 if sys.version_info>=(3,10) else 1)" >nul 2>nul
if not errorlevel 1 (set "PYTHON_CMD=py -3.12"&exit /b 0)
py -3 -c "import sys;raise SystemExit(0 if sys.version_info>=(3,10) else 1)" >nul 2>nul
if not errorlevel 1 (set "PYTHON_CMD=py -3"&exit /b 0)
python -c "import sys;raise SystemExit(0 if sys.version_info>=(3,10) else 1)" >nul 2>nul
if not errorlevel 1 (set "PYTHON_CMD=python"&exit /b 0)
exit /b 1
:install_python
where winget >nul 2>nul
if not errorlevel 1 (
  winget install --id Python.Python.3.12 -e --scope user --accept-package-agreements --accept-source-agreements --silent
  if errorlevel 1 (exit /b 1) else (exit /b 0)
)
echo Install Python 3.10+ from https://www.python.org/downloads/ and rerun this BAT.
exit /b 1
:setup_failed
echo ERROR: Setup failed. Check internet, permissions, proxy, and disk space.
pause
exit /b 3
