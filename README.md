# Overview
A collection of useful ffmpeg bat scripts. These are just convenience wrappers around command line ffmpeg commands with user configurable inputs.
See each individual script for specifics. All scripts have user configurable inputs at the top, including the place to provide your path to your ffmpeg install.

# How to Use
Generally, drag an input file onto the bat script to run it or provide your file as command line arguments to the desired script.

# Scripts
## Clip Lossless
Produce a lossless video clip from an input file given a start and end timestamp.

## Extract Frames
Produce .png screenshots at multiple timestamps for all given input files. Great for comparing two similar video files side by side.

## ffprobe
Produce a .csv of ffprobe output information for each input file.