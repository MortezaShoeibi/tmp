@echo off
title Windows Boot Fix - Disable Fast Startup & Prioritize USB
echo ================================================
echo This script disables Fast Startup and tries to
echo prioritize USB boot. Run as ADMIN!
echo ================================================
echo.

:: Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Run as Administrator!
    pause
    exit /b 1
)

:: Disable Fast Startup via powercfg
echo Disabling Fast Startup...
powercfg /h off
if %errorLevel% equ 0 (
    echo Success: Fast Startup disabled.
) else (
    echo Warning: Could not disable Fast Startup.
)

:: List current boot entries and try to set USB priority
echo.
echo Current boot entries:
bcdedit /enum | findstr /i "path identifier"
echo.

:: Attempt to set USB as default if a removable entry exists (adapt GUID if needed)
echo Prioritizing USB boot (if detected)...
for /f "tokens=2 delims={" %%i in ('bcdedit /enum ^| findstr /i "removable"') do (
    bcdedit /default {%%i}
    if %errorLevel% equ 0 (
        echo Success: USB set as default boot.
    ) else (
        echo Warning: No USB boot entry found or error setting default.
    )
)

if %errorLevel% neq 0 (
    echo Note: USB not detected—ensure it's inserted and bootable.
)

:: Restart to apply
echo.
set /p confirm="Restart now? (Y/N): "
if /i "%confirm%"=="Y" (
    echo Restarting in 5 seconds...
    timeout /t 5 /nobreak >nul
    shutdown /r /t 0
) else (
    echo Changes applied—manually restart and test F12.
)

pause
