# picam3/ 

 This directory contains informaton and scripts for installing and using a Raspberry Pi Camera Module 3 in octopi with [camera-streamer](https://github.com/ayufan/camera-streamer).  cam3install.sh is the main script for downloading, installing and configuring on a fresh 1.0.0 install of octopi.
 
 Script to add Raspberry Pi Camera Module 3 to octopi 1.0 RC3<br>
 https://raw.githubusercontent.com/ltlowe/misc/main/picam3/cam3install.sh
 
Tested on Raspberry Pi 3 Model B Plus Rev 1.3 using each of 
 - 32bit 1.0.0rc3 - https://unofficialpi.org/Distros/OctoPi/nightly/2022-10-27_2022-09-22-octopi-bullseye-armhf-lite-1.0.0.zip
 - 64bit nightly  - 2023-01-20_2022-09-22-octopi-bullseye-arm64-lite-1.0.0
 
 This script combines work from octoprint forums with my own investigation.<br>
 https://community.octoprint.org/t/pi-camera-v3-not-working/49022/16<br>
 https://community.octoprint.org/t/add-support-for-raspberry-pi-camera-v3/49052/5

 Ongoing discussion at:<br>
 https://community.octoprint.org/t/pi-camera-v3-imx-chipset-based-cameras-not-working/49022
 
 <hr/>
 
## Installation
 To use the script, follow these instructions from  [gambiting](https://community.octoprint.org/u/gambiting) on the [Octoprint forum](https://community.octoprint.org/t/pi-camera-v3-imx-chipset-based-cameras-not-working/49022/25)
> Download the Octoprint RC3 release image here:<br>
> https://unofficialpi.org/Distros/OctoPi/nightly/2022-10-27_2022-09-22-octopi-bullseye-armhf-lite-1.0.0.zip
>
> Flash it to a microsd card, boot up the raspberry pi as usual, don't do anything else on it yet.
>
> Log in, either locally or via SSH, doesn't matter.<br>
> Then run the following:
>
> ```
> wget https://raw.githubusercontent.com/ltlowe/misc/main/picam3/cam3install.sh
> chmod +x cam3install.sh
> ./cam3install.sh
> ```
> restart your system.

The script will prompt for reboot once everything has been downloaded and installed.

After the reboot the camera should be working with default `Webcam & Timelapse` settings, although you may want to change the aspect ratio to 16:9 since the camera module 3 is a wide aspect ratio camera.

###  Updating
The script does not support updates at this point.  If you have already used the script and are just looking for my latest service file, it is 
https://raw.githubusercontent.com/ltlowe/misc/main/picam3/camera-streamer-pi708-12MP.service
After replacing it you will need to restart the service or reboot.


## Resolution
I tried various settings for setting the camera resolution. The script sets them to the highest I was able to validate, although not the highest supported by the camera. This script sets the stream and snapshot resolutions to
- Stream (default): 1920x1080
- Snapshot (default): 1920x1056
- Stream (low): 960x512
- Snapshot (low): 960x512


## Stream Lag
By default, Octoprint uses the high resolution stream and snapshot.  If live view on the control tab is slow or lagging, try setting the Stream URL to `/webcam/?action=stream&res=low` on the `Webcam and Timelapse` page.  The lowres stream is `960x512` and is the one I personally use.


## Autofocus
This script automatically enables autofocus for the full range.  If you prefer manual focus via the `Camera Settings` plugin or other method, you can modify the camera-streamer service file.
Edit `/home/pi/camera-streamer/service/camera-streamer-pi708-12MP.service` and remove the following lines, followed by another reboot (or restart the service.)
```
  ; Enable Continuous Autofocus
  -camera-options=AfMode=2 \
  -camera-options=AfRange=2 \
```

