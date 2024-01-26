#!/bin/bash
# Installation script
sudo cp LIB/libftd2xx.tar /usr/local/lib/.
cd /usr/local/lib
sudo tar xf libftd2xx.tar
sudo rm -f /usr/local/lib/libftd2xx.tar
cd -
# Keep original raspi-blacklist.conf
if [ -s /etc/modprobe.d/raspi-blacklist.conf ]
then   
	echo "Updating /etc/modprobe.d/raspi-blacklist.conf file"
	cat /etc/modprobe.d/raspi-blacklist.conf > raspi-blacklist.conf
	echo "blacklist ftdi_sio" >> raspi-blacklist.conf
else
	echo "Creating /etc/modprobe.d/raspi-blacklist.conf file"
	echo "blacklist ftdi_sio" > raspi-blacklist.conf
fi
echo "blacklist usbserial" >> raspi-blacklist.conf
sudo cp raspi-blacklist.conf /etc/modprobe.d/raspi-blacklist.conf
rm -f raspi-blacklist.conf
if [ -d ~/Downloads ]
then
echo "Update ~/Downloads "
else
echo "Create ~/Downloads "
mkdir ~/Downloads
fi
cp LIB/libftd2xx-arm-v6-hf-1.4.24.tgz ~/Downloads/.
cd ~/Downloads 
tar xf libftd2xx-arm-v6-hf-1.4.24.tgz
mv release release_v6-hf
cd -
echo "reboot the pi"
