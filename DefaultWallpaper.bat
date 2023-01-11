@echo off
setlocal EnableDelayedExpansion
del C:\Users\%USERNAME%\AppData\Roaming\Microsoft\Windows\Themes\CachedFiles\CachedImage_1920_1080_POS2.jpg

powershell  @^(^(New-Object -com shell.application^).Windows^(^)^).Document.Folder.Self.Path >> prevfolderpaths.txt
taskkill /im explorer.exe /f
start explorer.exe
FOR /F "tokens=*" %%f IN (prevfolderpaths.txt) DO (
set "var=%%f"
set "firstletters=!var:~0,2!"
IF "!firstletters!" == "::" ( start /min shell:%%~f ) ELSE ( start /min "" "%%~f" )
)
del "prevfolderpaths.txt"

rd /s /q C:\$Recycle.Bin

exit
