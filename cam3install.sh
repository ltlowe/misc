#!/bin/bash

# Script to add Raspberry Pi Camera Module 3 to octopi 1.0 RC3
# Combining work from octoprint forums:
# https://community.octoprint.org/t/pi-camera-v3-not-working/49022/16
# https://community.octoprint.org/t/add-support-for-raspberry-pi-camera-v3/49052/5
#
# Tested on a clean install of Jan 20, 2023 Nightly build:
# 2023-01-20_2022-09-22-octopi-bullseye-arm64-lite-1.0.0
#

sudo systemctl stop webcamd && sudo systemctl disable webcamd
sudo systemctl stop octoprint && sudo systemctl disable octoprint
sudo systemctl stop ffmpeg_hls && sudo systemctl disable ffmpeg_hls

sudo apt-get update && sudo apt-get -y dist-upgrade

# do we need to reboot here ? I don't think so

sudo apt-get install -y libavformat-dev libcamera-dev liblivemedia-dev libjpeg-dev
sudo apt install -y cmake libboost-program-options-dev libdrm-dev libexif-dev


git clone --recursive -j8 https://github.com/ayufan/camera-streamer.git
cd camera-streamer/
make
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
ConditionPathExists=/sys/bus/i2c/drivers/imx708/10-001a/video4linux

[Service]
ExecStart=/usr/local/bin/camera-streamer \\
  -camera-path=/base/soc/i2c0mux/i2c@1/imx708@1a \\
  -camera-type=libcamera \\
  -camera-format=YUYV \\
  ; 2304x1296-YUV420
  -camera-width=2304 -camera-height=1296 \\
  -camera-fps=30 \\
  ; use two memory buffers to optimise usage
  -camera-nbufs=2 \\
  ; the high-res is 2304x1296
  -camera-high_res_factor=2 \\
  ; the low-res is 576x324
  -camera-low_res_factor=4 \\
  ; bump brightness slightly
  -camera-options=brightness=0.1 \\
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

# update config.txt
sudo sed -i 's/start_x=1/dtoverlay=imx708/g' /boot/config.txt


#update octopi.txt
cat << EOF | sudo tee -a /boot/octopi.txt > /dev/null

#enable libcamera
camera="libcamera"
camera_libcamera_options="-r 1280x720"
EOF


# enable services

sudo systemctl enable $PWD/service/camera-streamer-pi708-12MP.service
sudo systemctl enable octoprint

# uncomment to have the script auto-reboot
#sudo reboot

