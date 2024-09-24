REM Combines 3 input files into a single video.
REM A video file, an audio file, and a subtitle file.
REM Exported location is set to the location of the first input file.
REM Output filename: [first input file location]/[first input filename]_combined.[format]
REM Updated 2024.09.21

REM Set the location of your ffmpeg executable
SET "ffmpeg=C:\Program Files\ffmpeg\bin\ffmpeg"

REM Set whether to play the result in your media player after export
SET playAfter=true

REM Set the location of your media player
SET "player=C:\Program Files\VideoLAN\VLC\vlc"

REM Output media format
SET format=mkv

"%ffmpeg%" ^
-i "%~1" ^
-i "%~2" ^
-i "%~3" ^
-c copy ^
-disposition:s:0 default ^
-hide_banner -y ^
"%~dpn1_combined".%format%

if %playAfter%==true "%player%" "%~dpn1_combined".%format%

REM If you wish to have the subtitle stream default on in the output, add this line above the "-hide_banner" line above
::-disposition:s:0 default ^