REM Use ffprobe to export media information and saves a .csv of data for each input file.
REM Export location is set to the location of each separate input file.
REM Output filename: [input file location]/[input filename]_ffprobe.[format]
REM Updated 2024.06.04

SET format=csv

REM Set the location of your ffprobe executable
SET "ffprobe=C:\Program Files\ffmpeg\bin\ffprobe"

for %%r in (%*) do (
    REM show_streams: Show information about each media stream
    "%ffprobe%" ^
    -print_format %format%=nokey=0:print_section=1 ^
    -show_streams ^
    -i "%%~r" ^
    -o "%%~dpnr_ffprobe.%format%
)