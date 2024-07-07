<#
.SYNOPSIS
    Exports an animated gif for each video file within an input directory and its subdirectories.
.DESCRIPTION
    Output saved as: [input file folder]\[input file name].gif
.PARAMETER Directory
    The absolute path to the source directory. All subdirectories are also traversed.
.PARAMETER FrameCount
    The number of frames in each gif. Frames are captured at evenly spaced time intervals excluding start and end points.
    E.g. FrameCount=2 results in frame captures at 33% and 66% through a video file.
.PARAMETER ExtractPeriodicFramesScript
    File name of the PowerShell script to extract periodic frames from a video file.
    E.g. "Extract periodic frames.ps1"
.PARAMETER ImagesToGifScript
    File name of the bat script to convert images into a gif.
    E.g. "Images to gif.bat"
.EXAMPLE
    PS> Extract gifs -Directory "C:\folder\" with "C:\folder\vid1.mp4" and "C:\folder\subfolder\vid2.mkv"
    C:\folder\vid1.gif
    C:\folder\subfolder\vid2.gif
.LINK
    To do:
        - If the input directory or its subdirectories use [] characters, the IamgesToGifScript fails
    Last updated: 2024.06.25
#>

Param(
    [string]$Directory = "",
    [ValidateRange("Positive")]
    [int]$FrameCount = 10,
    [string]$ExtractPeriodicFramesScript = "Extract periodic frames.ps1",
    [string]$ImagesToGifScript = "Images to gif.bat"
)

# Sanitize input
if (!(Test-Path -LiteralPath "$Directory" -PathType Container))
{
    Throw "Input `"Directory`" isn't a directory"
}

# Get every valid media file input from the directory and subdirectories.
$AllMediaFiles = $(Get-ChildItem -Recurse -LiteralPath $Directory -Include *.mp4,*.mkv -Name)

# Run a script on every input media file to extract periodic frame images from it.
# Each of these script processes are run in parallel and execution of this script waits until all are finished.
$PeriodicFramesScript = Join-Path -Path $PSScriptRoot -ChildPath $ExtractPeriodicFramesScript

$Processes = @()
foreach ($mediaFile in $AllMediaFiles)
{
    $FullMediaPath = $(Join-Path -Path $Directory -ChildPath $mediaFile)

    $Processes += Start-Process pwsh -ArgumentList "-File `"$PeriodicFramesScript`"","-Source `"$FullMediaPath`"","-FrameCount $FrameCount" -NoNewWindow -PassThru
}

# Wait for all of the first stage processes to finish
$countUnfinished = $Processes.count
while($countUnfinished -gt 0)
{
    $countUnfinished = $Processes.count
    foreach ($process in $Processes)
    {
        if($process.HasExited)
        {
            $countUnfinished--
        }
    }
}
$Processes = @()

# For each media file, collect the extracted image frames and pass them to a script to convert them into an animated gif.
$GifScript = Join-Path -Path $PSScriptRoot -ChildPath $ImagesToGifScript
foreach ($mediaFile in $AllMediaFiles)
{
    $FullMediaPath = $(Join-Path -Path $Directory -ChildPath $mediaFile)
    $MediaFileNoExt = $(Split-Path -Path "$FullMediaPath" -LeafBase)
    $MediaFileDir = $(Split-Path -Path "$FullMediaPath" -Parent)

    # [] must be double `` escaped in the include token for Get-ChildItem to use it
    $IncludeToken = "*" + $MediaFileNoExt.Replace("[","``[").Replace("]","``]").Replace("!","``!") + "_*.png"
    $Images = Get-ChildItem -LiteralPath "$MediaFileDir" -Recurse -Name -Include "$IncludeToken"
    for ($i = 0; $i -lt $Images.Count; $i++) {
        $Images[$i] = "`"" + $(Join-Path -Path $MediaFileDir -ChildPath $Images[$i]) + "`""
    }

    $Processes += Start-Process -FilePath $GifScript -ArgumentList $Images -WorkingDirectory "$MediaFileDir" -NoNewWindow -PassThru
}