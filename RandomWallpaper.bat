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
set "CACHE_FOLDER=C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Themes\CachedFiles"
if exist "%CACHE_FOLDER%" (
    echo Removing existing cached wallpaper files...
    del "%CACHE_FOLDER%\CachedImage_*.jpg" >nul 2>&1
    echo Existing wallpaper cache cleaned.
) else (
    echo No existing wallpaper cache found.
)

REM ----------------------------------
REM Select random image from Desktop
REM ----------------------------------
echo Selecting random wallpaper...
set "IMAGE_FOLDER=C:\Users\%USERNAME%\Desktop\Images"

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

REM ----------------------------------
REM Get screen resolution dynamically
REM ----------------------------------
echo Detecting screen resolution...
for /f "tokens=1,2" %%a in ('powershell "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width, [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height"') do (
    set "SCREEN_WIDTH=%%a"
    set "SCREEN_HEIGHT=%%b"
)
echo Screen resolution: %SCREEN_WIDTH%x%SCREEN_HEIGHT%

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
set "TARGET_NAME=CachedImage_%SCREEN_WIDTH%_%SCREEN_HEIGHT%_POS2.jpg"
for %%f in (*.*) do (
    if /i not "%%f"=="%TARGET_NAME%" (
        ren "%%f" "%TARGET_NAME%" >nul 2>&1
        echo Renamed to: %TARGET_NAME%
        goto :renamed
    )
)
:renamed

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
echo Cached as: %TARGET_NAME%
exit
