@echo off
setlocal EnableDelayedExpansion

REM ======================================================================
REM Random Wallpaper Setter Script
REM Purpose: Sets a random wallpaper from Desktop\Images, restarts explorer
REM ======================================================================

echo Starting Random Wallpaper Setup...

REM ----------------------
REM Clean wallpaper cache
REM ----------------------
echo Cleaning existing wallpaper cache...
set "WALLPAPER_CACHE=C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Themes\CachedFiles\*.jpg"
if exist "%WALLPAPER_CACHE%" (
    del "%WALLPAPER_CACHE%"
    echo Existing wallpaper cache cleaned.
) else (
    echo No existing wallpaper cache found.
)

REM ----------------------------------
REM Select random image from Desktop
REM ----------------------------------
echo Selecting random wallpaper from your pictures...
set "IMAGE_FOLDER=C:\Users\%USERNAME%\Pictures"
set "CACHE_FOLDER=C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Themes\CachedFiles"

if not exist "%IMAGE_FOLDER%" (
    echo ERROR: Images folder not found at %IMAGE_FOLDER%
    echo Please create the folder and add image files.
    pause
    exit /b 1
)

cd /d "%IMAGE_FOLDER%"
set n=0

REM Count all image files
for %%f in (*.*) do (
    set /A n+=1
    set "file[!n!]=%%f"
)

if %n% EQU 0 (
    echo ERROR: No image files found in %IMAGE_FOLDER%
    echo Please add image files to the folder.
    pause
    exit /b 1
)

REM Select random file
set /A "rand=%random% %% n + 1"
echo Selected image: !file[%rand%]!

REM Copy random image to cache folder
if not exist "%CACHE_FOLDER%" mkdir "%CACHE_FOLDER%"
copy "!file[%rand%]!" "%CACHE_FOLDER%" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy image to cache folder.
    pause
    exit /b 1
)

REM ----------------------------
REM Rename to wallpaper format
REM ----------------------------
echo Setting up wallpaper cache...
cd /d "%CACHE_FOLDER%"
for %%f in (*.*) do (
    if /i not "%%f"=="CachedImage_1920_1080_POS2.jpg" (
        ren "%%f" "CachedImage_1920_1080_POS2.jpg" >nul 2>&1
    )
)

REM ----------------------------
REM Save current folder paths
REM ----------------------------
echo Saving current folder paths...
set "TEMP_PATHS=prevfolderpaths.txt"
cd /d "%~dp0"
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

echo Random wallpaper setup complete!
echo New wallpaper: !file[%rand%]!
exit
