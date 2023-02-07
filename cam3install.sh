#!/bin/bash

echo "*********************************************************************"
echo This script has moved to 
echo   https://raw.githubusercontent.com/ltlowe/misc/main/picam3/cam3install.sh
echo 
echo "*********************************************************************"
echo 

read -p "Download and execute from new location? [y|n]" response
if [[ $response =~ [yY](es)* ]]
then
wget -O cam3install.sh.2 https://raw.githubusercontent.com/ltlowe/misc/main/picam3/cam3install.sh
chmod +x cam3install.sh.2
./cam3install.sh.2
fi
