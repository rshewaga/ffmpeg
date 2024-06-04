REM Export a lossless clip between two timestamps for a given input file.
REM Extracted location is set to the location of the input file.
REM Output filename: [input file location]/[input filename]_clip_lossless.[format]
REM Updated 2024.05.20

REM Set the location of your ffmpeg executable
SET "ffmpeg=C:\Program Files\ffmpeg\bin\ffmpeg"

REM Set whether to play the clip in your media player after export
SET playAfter=true

REM Set the location of your media player
SET "player=C:\Program Files\VideoLAN\VLC\vlc"

REM Start and end timestamps in HH:MM:SS.MS format
SET "start=02:03:27.0"
SET "end=02:14:52.0"

REM Which video stream to keep in the output
SET videoStream=0
SET videoCodec=copy

REM Which audio stream to keep in the output
SET audioStream=0
SET audioCodec=copy

REM Which subtitle stream to keep in the output
SET subStream=0
SET subCodec=copy

REM Output media format
SET format=mkv

"%ffmpeg%" ^
-ss %start% -to %end% ^
-i "%~1" ^
-c:v %videoCodec% ^
-map 0:v:%videoStream%? ^
-c:a %audioCodec% ^
-map 0:a:%audioStream%? ^
-c:s %subCodec% ^
-map 0:s:%subStream%? ^
-hide_banner -y ^
"%~dpn1_clip_lossless".%format%

if %playAfter%==true "%player%" "%~dpn1_clip_lossless".%format%

REM If you wish to have the subtitle stream default on in the output, add this line above the "-hide_banner" line above
::-disposition:s:0 default ^