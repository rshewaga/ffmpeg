REM Extracts and saves a .png at the set timestamps for each input file.
REM Extracted location is set to the location of each separate input file.
REM Output filename: [input file location]/[timestamp]_[input filename].png
REM Updated 2024.05.20

setlocal enabledelayedexpansion

REM Set the location of your ffmpeg executable
SET "ffmpeg=C:\Program Files\ffmpeg\bin\ffmpeg"

REM Set the HH:MM:SS:MS timestamps to extract an image from. Supports single or multiple.
REM e.g. SET "timestamps=00:01:20.2"
REM e.g. SET "timestamps=00:01:20.2 01:43:45.0"
SET "timestamps=00:05:14.0 00:09:37.0"

REM For each input argument, save its path and filename separately to use when naming output files
set argCount=0
for %%r in (%*) do (
    set /A argCount+=1
    set "argVec[!argCount!]=%%~r"
    set "pathVec[!argCount!]=%%~dpr"
    set "filenameVec[!argCount!]=%%~nxr"
)


for %%T in (%timestamps%) do (
    REM Convert the colons in the timestamp into dashes for file saving
    REM Trying to use %%T in the substitution line doesn't work, so use an intermediate
    SET intermediate=%%T
    SET "timestampValid=!intermediate::=-!"

    for /L %%i in (1,1,%argCount%) do (
        "%ffmpeg%" ^
        -ss %%T ^
        -i "!argVec[%%i]!" ^
        -frames:v 1 ^
        -y ^
        "!pathVec[%%i]!!timestampValid!_!filenameVec[%%i]!.png" ^
    )
)