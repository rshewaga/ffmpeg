<#
.SYNOPSIS
    Exports an evenly spaced number of frame captures of an input video file.
.DESCRIPTION
    Output frame captures are stored as: [input file folder]\[input file name]_[HH]-[MM]-[SS]-[MS].[OutputFormat].
.PARAMETER Source
    The absolute path to the source video file.
.PARAMETER FrameCount
    The number of frame captures to export. Frames are captured at evenly spaced time intervals excluding start and end points.
    E.g. FrameCount=2 results in frame captures at 33% and 66% through a video file.
.PARAMETER ffmpeg
    The absolute path to the ffmpeg executable.
.PARAMETER ffprobe
    The absolute path to the ffprobe executable.
.PARAMETER OutputFormat
    The output image format.
.PARAMETER ExcludeTimestamp
    Exclude drawing the timestamp on each output frame capture.
.EXAMPLE
    PS> test -Source "C:\folder\file.mp4"
    C:\folder\file_00-00-03-33.png
    C:\folder\file_00-00-06-66.png
.EXAMPLE
    PS> test -Source "C:\folder\file.mp4" -FrameCount 4 -OutputFormat ".jpg"
    C:\folder\file_00-00-02-00.jpg
    C:\folder\file_00-00-04-00.jpg
    C:\folder\file_00-00-06-00.jpg
    C:\folder\file_00-00-08-00.jpg
.LINK
    To do:
        -Parse $Source as an array of files, supporting multiple files
        -Only use 1 call to ffmpeg. The timestamps can be changed to a subtitle file instead (https://stackoverflow.com/questions/17623676/text-on-video-ffmpeg)

    Last updated: 2024.06.25
#>

Param(
    [string]$Source = "",
    [ValidateRange("Positive")]
    [int]$FrameCount = 5,
    [string]$ffmpeg = "C:\Program Files\ffmpeg\bin\ffmpeg.exe",
    [string]$ffprobe = "C:\Program Files\ffmpeg\bin\ffprobe.exe",
    [string]$OutputFormat = ".png",
    [switch]$ExcludeTimestamp
)

# Sanitize input
# Square brackets used as path arguments to PowerShell cmdlets are typically wildcard pattern matched. 
# Avoid this by escaping them with backticks.
# This only needs to be done for the pass to Test-Path.
# See https://superuser.com/questions/212808/powershell-bug-in-copy-move-rename-when-filename-contains-square-bracket-charac#:%7E:text=Getting%20PowerShell%20to%20correctly%20recognize,four%20backticks%20to%20escape%20it
# See https://stackoverflow.com/questions/21008180/copy-file-with-square-brackets-in-the-filename-and-use-wildcard
$PSSource = $Source.Replace("[","````[").Replace("]","````]")
if (!(Test-Path -Path "$PSSource" -PathType Leaf))
{
    Throw "Input `"Source`" file doesn't exist: $Source"
}
if (!(Test-Path -Path "$ffmpeg" -PathType Leaf))
{
    Throw "Input `"ffmpeg`" executable doesn't exist: $ffmpeg"
}
if (!(Test-Path -Path "$ffprobe" -PathType Leaf))
{
    Throw "Input `"ffprobe`" executable doesn't exist: $ffprobe"
}

# Get the input file duration in seconds
$DurInS = & "$ffprobe" -i "$Source" -v error -select_streams v -of csv=p=0 -show_entries format=duration
# Interval between each frame capture in seconds
$IntervalInS = $($DurInS / ($FrameCount + 1))
# e.g. "C:\folder\file" without suffix and extension
$OutputPath = $(Join-Path -Path $(Split-Path -Path "$Source" -Parent) -ChildPath $(Split-Path -Path "$Source" -LeafBase))

Write-Output "Extracting $FrameCount periodic frames for `"$Source`""
for ($count = 1; $count -le $FrameCount; $count++)
{
    $CurTimestampInS = $count * $IntervalInS

    # Use a timespan to parse seconds to other time units and easily print to a nice format
    $Timespan = New-TimeSpan -Seconds $CurTimestampInS -Milliseconds $([int]($CurTimestampInS % 1 * 1000))

    # Compose final output filename
    # [input file folder]\[input file name]_[HH]-[MM]-[SS]-[MS].[OutputFormat]
    $Output = "$OutputPath" + "_" + $Timespan.ToString("hh\-mm\-ss\-ff") + $OutputFormat

    # Set the drawtext filter to print the timestamp on the image
    $TimeStampForDrawText = $($Timespan.ToString("hh\\\:mm\\\:ss\.ff"))
    if ($ExcludeTimestamp)
    {
        $TimeStampForDrawText = ""
    }
    $DrawTextFilter = "drawtext=fontfile=C\\:/Windows/Fonts/calibri.ttf:text='$TimeStampForDrawText':fontcolor=white:fontsize=h/10:box=1:boxcolor=black@0.5:boxborderw=10:x=(w-text_w)/2:y=(h*0.95-text_h)"
    
    # -ss before -i for fast seeking
    & "$ffmpeg" -ss $CurTimestampInS -i "$Source" -frames:v 1 -update true -y -hide_banner -loglevel error -vf $DrawTextFilter "$Output"
}