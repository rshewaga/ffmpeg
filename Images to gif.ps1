<#
.SYNOPSIS
    Exports an animated gif from an input text file listing image frame files.
.DESCRIPTION
    Output saved as: [first input image file folder]\[first input image file name].gif
.PARAMETER ImageFrameList
    Absolute path to a text file. Each line of the text file lists a double quoted absolute path to an image frame.
.PARAMETER DeleteImageFrameList
    Delete the input ImageFrameList text file after exporting the gif.
.PARAMETER DeleteImageFrameFiles
    Delete the input image frame files after exporting the gif.
.PARAMETER ffmpeg
    The absolute path to the ffmpeg executable.
.PARAMETER ffprobe
    The absolute path to the ffprobe executable.
.PARAMETER Duration
    The total duration of the final .gif, in seconds.
.PARAMETER MaxWidth
    The maximum width of the .gif, in pixels. Height will be calculated to maintain the aspect ratio of the first input image.
.EXAMPLE
    C:\myImages.txt contents:
        "C:\folder\img1.png"
        "C:\folder\img2.png"
    PS> Images to gif -ImageFrameList "C:\myImages.txt"
    C:\folder\img1.gif
.LINK
    Last updated: 2024.06.26
#>

Param(
    [Parameter(Mandatory)]
    [string]$ImageFrameList,
    [string]$ffmpeg = "C:\Program Files\ffmpeg\bin\ffmpeg.exe",
    [string]$ffprobe = "C:\Program Files\ffmpeg\bin\ffprobe.exe",
    [ValidateRange("Positive")]
    [float]$Duration = 5,
    [ValidateRange("Positive")]
    [float]$MaxWidth = 720,
    [switch]$DeleteImageFrameList,
    [switch]$DeleteImageFrameFiles
)

# Sanitize input
if (!($(Split-Path -Path "$ImageFrameList" -Extension) -eq ".txt"))
{
    Throw "Input `"ImageFrameList`" is not a .txt file: $ImageFrameList"
}
if (!(Test-Path -Path "$ffmpeg" -PathType Leaf))
{
    Throw "Input `"ffmpeg`" executable doesn't exist: $ffmpeg"
}
if (!(Test-Path -Path "$ffprobe" -PathType Leaf))
{
    Throw "Input `"ffprobe`" executable doesn't exist: $ffprobe"
}

# Read the input ImageFrameList text file line by line, editing each line as necessary.
# Add each frame's calculated duration.
# Output to a new text file actually passed to the ffmpeg concat input to take.
$ListFile = $(Join-Path -Path $(Split-Path -Path "$ImageFrameList" -Parent) -ChildPath $(Split-Path -Path "$ImageFrameList" -LeafBase)) + "_actual.txt"
Out-File -LiteralPath "$ListFile" -Force

$ImageFrameListLines = Get-Content -LiteralPath "$ImageFrameList"
foreach ($ImageFrameListLine in $ImageFrameListLines)
{
    $Formatted = $ImageFrameListLine.Replace("\","/").Replace('''','''''').Replace('"','''')
    "file $Formatted" | Out-File -LiteralPath "$ListFile" -Append
    "duration $($Duration/$ImageFrameListLines.Count)" | Out-File -LiteralPath "$ListFile" -Append
}

# Calculate the output file name
$FirstImageFile = $ImageFrameListLines[0].Trim('"')
$FirstImageFile = $(Join-Path -Path $(Split-Path -Path "$FirstImageFile" -Parent) -ChildPath $(Split-Path -Path "$FirstImageFile" -LeafBase))
$Output = $FirstImageFile + ".gif"

# Run ffmpeg
& "$ffmpeg" -y -hide_banner -loglevel error -f concat -safe 0 -i "$ListFile" -filter_complex "scale=${MaxWidth}:-1" "$Output"

# Clean up
Remove-Item -LiteralPath "$ListFile"

if($DeleteImageFrameList)
{
    Remove-Item -LiteralPath $ImageFrameList
}

if($DeleteImageFrameFiles)
{
    foreach ($ImageFrameListLine in $ImageFrameListLines)
    {
        $ImageFrameListLine = $ImageFrameListLine.Trim()
        if($ImageFrameListLine.StartsWith('"'))
        {
            $ImageFrameListLine = $ImageFrameListLine.Remove(0,1)
        }
        if($ImageFrameListLine.EndsWith('"'))
        {
            $ImageFrameListLine = $ImageFrameListLine.Remove($ImageFrameListLine.Length - 1,1)
        }
        Remove-Item -LiteralPath $ImageFrameListLine
    }
}