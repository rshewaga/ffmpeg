# Overview
A collection of useful ffmpeg scripts. These are just convenience wrappers around command line ffmpeg commands with user configurable inputs.
See each individual script for specifics. All scripts have user configurable inputs at the top, including the place to provide your path to your ffmpeg install.
If there is both a .bat and .ps1 script named the same thing, the .bat file is just a wrapper around the PowerShell script so you can drag and drop files onto it, as Windows Explorer by default doesn't facilitate drag and dropping files onto PowerShell script files.

# How to Use
Generally, drag an input file onto the bat script to run it or provide your file as command line arguments to the desired script.

# Scripts

## Clip Lossless
Produce a lossless video clip from an input file given a start and end timestamp.

## Convert to mp4
Convert an input file to mp4 with a given resolution, FPS, and quality.

## Denoise Track 2
Extract the second audio track from a file, denoise it, then combine it with the first audio track of the input file into a new file.

## Extract Frames
Produce .png screenshots at multiple timestamps for all given input files. Great for comparing two similar video files side by side.

## ffprobe
Produce a .csv of ffprobe output information for each input file.

## Video to gif
Convert a full video file into an animated gif.

## Extract periodic frames
Exports an evenly spaced number of frame capture images from an input video file.

## Images to gif
Exports an animated gif of an input text file listing image frame files.

## Extract gifs
Exports an animated gif for each video file within an input directory and its subdirectories.