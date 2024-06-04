REM Convert a full video into an animated gif.
REM Output filename: [input file location]/[input filename]_[fps]fps.gif

REM Absolute paths to ffprobe and ffmpeg executables
SET "ffprobe=C:\Program Files\ffmpeg\bin\ffprobe"
SET "ffmpeg=C:\Program Files\ffmpeg\bin\ffmpeg"

REM Set gif FPS and max width
SET /A fps=15
SET /A maxWidth=1280

REM Intermediate file, don't change
SET "palette=%~dpn1_palette.png"

REM Get video dimensions
"%ffprobe%" ^
-v error ^
-select_streams v:0 ^
-show_entries stream=width,height ^
-of csv=s=x:p=0 ^
"%~1"

REM Generate a palette
"%ffmpeg%" ^
-i "%~1" ^
-vf "fps=%fps%,scale=%maxWidth%:-1:flags=lanczos,palettegen" ^
"%palette%"

REM Use the generated palette
"%ffmpeg%" ^
-y ^
-i "%~1" ^
-i "%palette%" ^
-filter_complex "fps=%fps%,scale=%maxWidth%:-1:flags=lanczos[x];[x][1:v]paletteuse" ^
"%~dpn1_%fps%fps.gif"

REM Cleanup intermediate files
del "%palette%"