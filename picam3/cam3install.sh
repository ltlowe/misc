#!/bin/bash

# Script to add Raspberry Pi Camera Module 3 to octopi 1.0 RC3
# Updated 2023-02-05 
# https://raw.githubusercontent.com/ltlowe/misc/main/picam3/cam3install.sh

# This script combines work from octoprint forums with my own investigation.
# https://community.octoprint.org/t/pi-camera-v3-not-working/49022/16
# https://community.octoprint.org/t/add-support-for-raspberry-pi-camera-v3/49052/5
#
# Ongoing discussion at:
# https://community.octoprint.org/t/pi-camera-v3-imx-chipset-based-cameras-not-working/49022
#
# Tested on:
# - Raspberry Pi 3 Model B Plus Rev 1.3
# - 32bit 1.0.0rc3 - https://unofficialpi.org/Distros/OctoPi/nightly/2022-10-27_2022-09-22-octopi-bullseye-armhf-lite-1.0.0.zip
# - 64bit nightly  - 2023-01-20_2022-09-22-octopi-bullseye-arm64-lite-1.0.0
# 
# Also reported to work on 1.0.0RC3
#
set -e

sudo systemctl stop webcamd && sudo systemctl disable webcamd
sudo systemctl stop octoprint && sudo systemctl disable octoprint
sudo systemctl stop ffmpeg_hls && sudo systemctl disable ffmpeg_hls

sudo apt-get update && sudo apt-get -y dist-upgrade
sudo apt-get install -y \
	libavformat-dev \
	libcamera-dev \
	liblivemedia-dev \
	libjpeg-dev \
	cmake \
	libboost-program-options-dev \
	libdrm-dev \
	libexif-dev

# get and build camera-streamer
git clone --recursive -j8 https://github.com/ayufan/camera-streamer.git
cd camera-streamer/
# checkout the tested commit/764f94ba44ded2fd58a27073d27d9af812f35d22
git checkout 764f94b
make -j4
sudo make install

# create 708 service
cat > service/camera-streamer-pi708-12MP.service << EOF
;
; Official Raspberry Pi v3 12MP camera based on the Sony IMX708 chip
; https://www.raspberrypi.com/products/camera-module-3/
;
[Unit]
Description=camera-streamer web camera
After=network.target

[Service]
;Fail if path doesn't exist.  Restarts will be attempted at 10s intervals.
ExecStartPre=/usr/bin/test -e /sys/bus/i2c/drivers/imx708/10-001a/video4linux

ExecStart=/usr/local/bin/camera-streamer \\
  -camera-path=/base/soc/i2c0mux/i2c@1/imx708@1a \\
  -camera-type=libcamera \\
  ; YUYV offers best quality in camera-streamer
  -camera-format=YUYV \\
  -camera-width=1920 -camera-height=1080 \\
  ; 4608 (H) × 2592 is full res - don't know how to enable it 
  ; frame rate 30 for North America.  25 may work better in 50Hz countries
  -camera-fps=30 \\
  ; use two memory buffers to optimise usage
  -camera-nbufs=2 \\
  ; high-res video is 1920x1080
  ; high-res snapshot is 1920x1056
  -camera-high_res_factor=1 \\
  ; the low-res is 960x512
  -camera-low_res_factor=2 \\
  ; Enable Continuous Autofocus
  -camera-options=AfMode=2 \\
  -camera-options=AfRange=2 \\
  -rtsp-port

DynamicUser=yes
SupplementaryGroups=video i2c
Restart=always
RestartSec=10
Nice=10
IOSchedulingClass=idle
IOSchedulingPriority=7
CPUWeight=20
AllowedCPUs=1-2
MemoryMax=250M

[Install]
WantedBy=multi-user.target

EOF

# update config.txt raspicam section
sudo sed -i 's/start_x=1/dtoverlay=imx708/g' /boot/config.txt
sudo sed -i 's/gpu_mem.*/gpu_mem=256/g' /boot/config.txt


# update octopi.txt 
# Not needed for camera-streamer, but may be useful later
cat << EOF | sudo tee -a /boot/octopi.txt > /dev/null

#enable libcamera
camera="libcamera"
camera_libcamera_options="-r 1280x720"
EOF


# enable services
sudo systemctl enable $PWD/service/camera-streamer-pi708-12MP.service
sudo systemctl enable octoprint


# Reboot is required
echo 
echo Reboot required. 
read -p "reboot now? [y|n]" response
if [[ $response =~ [yY](es)* ]]
then
sudo reboot
fi

