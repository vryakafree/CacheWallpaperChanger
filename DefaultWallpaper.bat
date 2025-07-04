@echo off
setlocal EnableDelayedExpansion

REM ======================================================================
REM Default Wallpaper Reset Script
REM Purpose: Resets wallpaper to default, restarts explorer, and cleans up
REM ======================================================================

echo Starting Default Wallpaper Reset...

REM ----------------------
REM Clean wallpaper cache
REM ----------------------
echo Cleaning wallpaper cache...
set "CACHE_FOLDER=C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Themes\CachedFiles"
if exist "%CACHE_FOLDER%" (
    echo Removing cached wallpaper files...
    del "%CACHE_FOLDER%\CachedImage_*.jpg" >nul 2>&1
    echo Wallpaper cache cleaned.
) else (
    echo Wallpaper cache folder not found.
)

REM ----------------------------
REM Save current folder paths
REM ----------------------------
echo Saving current folder paths...
set "TEMP_PATHS=prevfolderpaths.txt"
powershell @^(^(New-Object -com shell.application^).Windows^(^)^).Document.Folder.Self.Path >> "%TEMP_PATHS%"

REM -------------------
REM Restart Explorer
REM -------------------
echo Restarting Windows Explorer...
taskkill /im explorer.exe /f >nul 2>&1
timeout /t 2 /nobreak >nul
start explorer.exe

REM ---------------------------
REM Restore previous folders
REM ---------------------------
echo Restoring previous folder windows...
if exist "%TEMP_PATHS%" (
    FOR /F "tokens=*" %%f IN (%TEMP_PATHS%) DO (
        set "var=%%f"
        set "firstletters=!var:~0,2!"
        IF "!firstletters!" == "::" (
            start /min shell:%%~f
        ) ELSE (
            start /min "" "%%~f"
        )
    )
    del "%TEMP_PATHS%"
    echo Previous folders restored.
) else (
    echo No previous folder paths found.
)

REM -------------------
REM Empty Recycle Bin
REM -------------------
echo Emptying Recycle Bin...
rd /s /q C:\$Recycle.Bin >nul 2>&1

echo Default wallpaper reset complete!
exit
