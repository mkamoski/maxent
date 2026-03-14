@echo off
REM MaxEnt Project - Quick Setup Launcher
REM This batch file provides easy access to setup and test commands

echo ================================================
echo MaxEnt Project Setup Launcher
echo ================================================
echo.

:menu
echo Please select an option:
echo.
echo [1] Run automated setup (install Phase 2 dependencies)
echo [2] Test installation
echo [3] Set up environment variables (for current session)
echo [4] Install Phase 2 dependencies only
echo [5] View installation status
echo [6] Activate virtual environment
echo [7] Help and documentation
echo [8] Exit
echo.

set /p choice="Enter your choice (1-8): "

if "%choice%"=="1" goto setup
if "%choice%"=="2" goto test
if "%choice%"=="3" goto env
if "%choice%"=="4" goto phase2
if "%choice%"=="5" goto status
if "%choice%"=="6" goto activate
if "%choice%"=="7" goto help
if "%choice%"=="8" goto end

echo Invalid choice. Please try again.
echo.
goto menu

:setup
echo.
echo Running automated setup...
echo.
powershell -ExecutionPolicy Bypass -File setup_windows.ps1
echo.
pause
goto menu

:test
echo.
echo Running installation tests...
echo.
.\venv_maxent\Scripts\python.exe test_installation.py
echo.
pause
goto menu

:env
echo.
echo Setting up environment variables for current session...
echo.
set HOME=%USERPROFILE%
echo HOME=%HOME%
echo.
echo Note: This only affects the current session.
echo For permanent setup, add to system environment variables.
echo.
pause
goto menu

:phase2
echo.
echo Installing Phase 2 dependencies...
echo.
.\venv_maxent\Scripts\pip.exe install -r requirements_phase2.txt
echo.
pause
goto menu

:status
echo.
echo Current Installation Status:
echo.
type INSTALLATION_STATUS.md
echo.
echo Installed packages:
.\venv_maxent\Scripts\pip.exe list
echo.
pause
goto menu

:activate
echo.
echo Activating virtual environment...
echo Note: Run this in PowerShell for full activation:
echo   .\venv_maxent\Scripts\Activate.ps1
echo.
cmd /k ".\venv_maxent\Scripts\activate.bat"
goto end

:help
echo.
echo Documentation files:
echo.
echo   QUICK_INSTALL_GUIDE.md     - Quick installation instructions
echo   SETUP_ANALYSIS_AND_STEPS.md - Detailed analysis and steps
echo   requirements_phase2.txt     - Phase 2 dependencies
echo   requirements_complete.txt   - Complete dependency list
echo.
echo Opening QUICK_INSTALL_GUIDE.md...
notepad QUICK_INSTALL_GUIDE.md
goto menu

:end
echo.
echo Thank you for using MaxEnt Setup Launcher!
echo.
exit /b 0
