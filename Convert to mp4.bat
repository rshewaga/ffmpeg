REM Convert the input file to a given resolution, FPS, and quality to an output mp4 file.
REM Output filename: [input file location]/[input filename]_[height]p[fps]_crf[quality].mp4

REM  Your ffmpeg executable location
SET "ffmpeg=C:\Program Files\ffmpeg\bin\ffmpeg"

REM Output FPS
SET /A fps=30

REM Output resolution
SET "width=1920"
SET "height=1080"

REM Quality. [0-51], lower = better. Default 23.
SET /A crf=23

"%ffmpeg%" ^
-i "%~1" ^
-filter:v fps=fps=%fps% ^
-f mp4 ^
-s %width%x%height% ^
-c:v libx264 ^
-crf %crf% ^
-preset veryfast ^
-profile:v main ^
-acodec aac ^
-hide_banner -y ^
"%~dpn1_%height%p%fps%_crf%crf%".mp4