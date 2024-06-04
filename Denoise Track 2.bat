REM Extract the second audio track from a file, perform noise reduction on that track, and combine it with the first audio track into a new mp4 file.
REM Useful e.g. screen recording a video with audio track 1 being the source audio output and audio track 2 being your microphone.
REM Output filename: [input file location]/[input filename]_clean.mp4

REM  Your ffmpeg executable location
SET "ffmpeg=C:\Program Files\ffmpeg\bin\ffmpeg"

REM Output FPS
SET /A fps=30

REM Output resolution
SET "width=1920"
SET "height=1080"

REM Quality. 0-51, lower = better. Default 23.
SET /A crf=23

REM Intermediate file, don't change
SET "outTrack2NoNoise=%~dpn1_Track2NoNoise.mp3"

ECHO Extracting audio track 2 and doing noise reduction
timeout 2

REM extract audio track 2 and do noise reduction
"%ffmpeg%" ^
-i "%~1" ^
-map 0:a:1 ^
-af afftdn ^
"%outTrack2NoNoise%"

ECHO Combining track 1 video and audio with noise reduced track 2
timeout 2

REM combine audio track 1 and noiseless track 2 into a video of given quality
"%ffmpeg%" ^
-hide_banner ^
-y ^
-i "%~1" ^
-i "%outTrack2NoNoise%" ^
-filter:v fps=fps=%fps% ^
-f mp4 ^
-s %width%x%height% ^
-c:v libx264 ^
-crf %crf% ^
-preset veryfast ^
-profile:v main ^
-acodec aac ^
-map 0:v:0 ^
-filter_complex amix ^
"%~dpn1_clean.mp4"

REM delete temporary files
ECHO Deleting temporary files
timeout 2
del %outTrack2NoNoise%