@echo off
set PSScript=%~dpn0.ps1
pwsh.exe -File "%PSScript%" -Source %* -FrameCount 5