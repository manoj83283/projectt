@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"
title Safe File Transfer Toolkit

set "SCRIPT_DIR=%~dp0"
set "PYTHON_CMD="
set "VENV_PY=%SCRIPT_DIR%.venv\Scripts\python.exe"

echo ============================================================
echo   Safe File Transfer Toolkit - automatic Windows setup
echo ============================================================
echo.

call :find_python
if not defined PYTHON_CMD (
    echo Python 3.10 or newer was not found.
    echo Attempting a current-user Python 3.12 installation...
    call :install_python
    call :find_python
)

if not defined PYTHON_CMD (
    echo.
    echo ERROR: Python could not be installed or detected.
    echo Install Python 3.10+ from https://www.python.org/downloads/
    echo Select "Add Python to PATH", then run this BAT file again.
    pause
    exit /b 2
)

if not exist "%VENV_PY%" (
    echo Creating an isolated Python environment...
    %PYTHON_CMD% -m venv "%SCRIPT_DIR%.venv"
    if errorlevel 1 goto :setup_failed
)

if not exist "%VENV_PY%" goto :setup_failed

echo Installing/updating optional deep-validation Python libraries...
"%VENV_PY%" -m pip install --disable-pip-version-check --quiet --upgrade pip
if errorlevel 1 echo WARNING: pip could not be updated; continuing with the installed pip.
"%VENV_PY%" -m pip install --disable-pip-version-check --quiet -r "%SCRIPT_DIR%requirements.txt"
if errorlevel 1 (
    echo WARNING: Optional deep-validation libraries could not be installed.
    echo The built-in validators remain available; check internet/proxy settings
    echo and run this BAT again later to add the optional validators.
)

echo.
where ffprobe >nul 2>nul
if errorlevel 1 (
    echo NOTE: FFprobe is not installed. Standard validation remains enabled.
    echo       Install FFmpeg and run with --deep-media-check for stronger
    echo       video/audio container validation.
) else (
    echo FFprobe detected. Add --deep-media-check when deep media validation is desired.
)

echo.
echo Starting transfer program...
echo.
"%VENV_PY%" "%SCRIPT_DIR%safe_transfer.py" %*
set "RUN_RESULT=%ERRORLEVEL%"
echo.
if "%RUN_RESULT%"=="0" (
    echo Transfer completed successfully.
) else if "%RUN_RESULT%"=="130" (
    echo Transfer was interrupted safely. Re-run to continue.
) else (
    echo Transfer finished with exit code %RUN_RESULT%. Review the report path shown above.
)
pause
exit /b %RUN_RESULT%

:find_python
py -3.12 -c "import sys; raise SystemExit(0 if sys.version_info >= (3,10) else 1)" >nul 2>nul
if not errorlevel 1 (
    set "PYTHON_CMD=py -3.12"
    exit /b 0
)
py -3 -c "import sys; raise SystemExit(0 if sys.version_info >= (3,10) else 1)" >nul 2>nul
if not errorlevel 1 (
    set "PYTHON_CMD=py -3"
    exit /b 0
)
python -c "import sys; raise SystemExit(0 if sys.version_info >= (3,10) else 1)" >nul 2>nul
if not errorlevel 1 (
    set "PYTHON_CMD=python"
    exit /b 0
)
if exist "%LocalAppData%\Programs\Python\Python312\python.exe" (
    "%LocalAppData%\Programs\Python\Python312\python.exe" -c "import sys; raise SystemExit(0 if sys.version_info >= (3,10) else 1)" >nul 2>nul
    if not errorlevel 1 (
        set PYTHON_CMD="%LocalAppData%\Programs\Python\Python312\python.exe"
        exit /b 0
    )
)
exit /b 1

:install_python
where winget >nul 2>nul
if not errorlevel 1 (
    winget install --id Python.Python.3.12 -e --scope user --accept-package-agreements --accept-source-agreements --silent
    if errorlevel 1 (exit /b 1) else (exit /b 0)
)

echo Windows Package Manager was not found; using the official Python installer.
set "PY_INSTALLER=%TEMP%\python-3.12.8-amd64.exe"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "$u='https://www.python.org/ftp/python/3.12.8/python-3.12.8-amd64.exe';" ^
  "Invoke-WebRequest -UseBasicParsing -Uri $u -OutFile '%PY_INSTALLER%';" ^
  "$s=Get-AuthenticodeSignature '%PY_INSTALLER%';" ^
  "if($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch 'Python Software Foundation'){throw 'Python installer signature validation failed'}"
if errorlevel 1 exit /b 1
"%PY_INSTALLER%" /quiet InstallAllUsers=0 PrependPath=1 Include_pip=1 Include_launcher=1
set "INSTALL_RESULT=%ERRORLEVEL%"
del /q "%PY_INSTALLER%" >nul 2>nul
exit /b %INSTALL_RESULT%

:setup_failed
echo.
echo ERROR: Automatic setup failed.
echo Check your internet connection, available disk space, proxy settings,
echo and permission to create files in: %SCRIPT_DIR%
pause
exit /b 3
