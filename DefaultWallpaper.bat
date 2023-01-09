@echo off
setlocal EnableDelayedExpansion
del C:\Users\cevdatran1\AppData\Roaming\Microsoft\Windows\Themes\CachedFiles\CachedImage_1920_1080_POS2.jpg
rd /s /q C:\$Recycle.Bin
tskill explorer 
exit
