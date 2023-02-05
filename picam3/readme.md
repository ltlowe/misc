# picam3/ 

 Script to add Raspberry Pi Camera Module 3 to octopi 1.0 RC3<br>
 https://raw.githubusercontent.com/ltlowe/misc/main/picam3/cam3install.sh

 This script combines work from octoprint forums with my own investigation.<br>
 https://community.octoprint.org/t/pi-camera-v3-not-working/49022/16<br>
 https://community.octoprint.org/t/add-support-for-raspberry-pi-camera-v3/49052/5

 Ongoing discussion at:<br>
 https://community.octoprint.org/t/pi-camera-v3-imx-chipset-based-cameras-not-working/49022
 
 To use the script, follow these instructions from  [gambiting](https://community.octoprint.org/u/gambiting) on the [Octoprint forum](https://community.octoprint.org/t/pi-camera-v3-imx-chipset-based-cameras-not-working/49022/25)
> Download the Octoprint RC3 release image here:<br>
> https://unofficialpi.org/Distros/OctoPi/nightly/2022-10-27_2022-09-22-octopi-bullseye-armhf-lite-1.0.0.zip 23
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
