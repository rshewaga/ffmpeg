REM Extract a .srt subtitle file from the input file.
REM Extracted location is set to the location of the input file.
REM Output filename: [input file location]/[input filename]_subs_[track].srt
REM Updated 2024.08.30

REM Set the location of your ffmpeg executable
SET "ffmpeg=C:\Program Files\ffmpeg\bin\ffmpeg"

REM Which subtitle stream to extract
SET subStream=0

"%ffmpeg%" ^
-i "%~1" ^
-c:s srt ^
-map 0:s:%subStream%? ^
-hide_banner -y ^
"%~dpn1_subs_%subStream%".srt