@echo off
setlocal

cd /d "%~dp0"

where py >nul 2>&1
if %errorlevel%==0 (
    py -3 app.py %*
    goto :end
)

where python >nul 2>&1
if %errorlevel%==0 (
    python app.py %*
    goto :end
)

echo [ERROR] Python is not found in PATH.
echo Install Python 3 and enable "Add python.exe to PATH".
pause

:end
endlocal
