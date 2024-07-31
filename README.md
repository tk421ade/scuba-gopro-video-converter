# Scuba Diving Video Converter

Underwater videos are shifted to blue, and the true colours cannot be appreciated. 

This script converts the videos, processing every frame to recover the colours. 

## Limitations

- Converted videos does not have sound (sound does not have much value in underwater videos anyway ...)
- framerate harcoded to 50 fps - current valid for GOPROS.

## Dependencies 

- `imagemagick` version 6.9 or less
- `ffmpeg` 

Debian systems can install this with the following command

``` Bash
apt-get install imagemagick ffmpeg
```

The script has been tested in Ubuntu 22.

## Example

Convert one video

``` Bash
bash converter.sh -i /path/to/GX011123.MP4 -o /path/to/output/folder/
```

Convert all videos in a folder (the script does not search recursively)

``` Bash
bash converter.sh -i /path/to/input/folder/ -o /path/to/output/folder/
```


