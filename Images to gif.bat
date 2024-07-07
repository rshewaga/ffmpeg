@echo off
set PSScript=%~dpn0.ps1

REM PowerShell script expects the ImageFrameList as a text file with each line being a double quoted absolute file path.
set "filelist=%~dpn1_files.txt"
echo. 2> "%filelist%"

for %%i in (%*) do (
    set "unformatted=%%i"
    
    setlocal enabledelayedexpansion
    echo !unformatted! >> !filelist!
    endlocal
)

REM -DeleteImageFrameList
REM -DeleteImageFrameFiles
pwsh.exe -File "%PSScript%" -ImageFrameList "%filelist%" -DeleteImageFrameList -DeleteImageFrameFiles -Duration 5 -MaxWidth 500