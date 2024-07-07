@echo off
set PSScript=%~dpn0.ps1
pwsh.exe -File "%PSScript%" -FrameCount 3 -Directory %*