#!/usr/bin/env bash

#Fully automatic Ubuntu setup script, intended for Hintegram
#Navigate to this script's directory and run it as root

#Sleep commands are temporary

#Exit trap
set -e

trap \
"{
  echo "Exiting..."
  sleep 1 
  exit 1; 
}" \
ERR SIGINT SIGTERM

#Privilege test
if ! [ $(id -u) = 0 ]; then
  echo "Setup is not running as root"
  sleep 1
  echo "Exiting..."
  sleep 1
  exit 1
fi

#Ouput banners
banner_large()
{
  echo "+------------------------------------------+"
  printf "| %-40s |\n" "`date`"
  echo "|                                          |"
  printf "|`tput bold` %-40s `tput sgr0`|\n" "$@"
  echo "+------------------------------------------+"
}

banner_small()
{
  echo "+------------------------------------------+"
  printf "|`tput bold` %-40s `tput sgr0`|\n" "$@"
  echo "+------------------------------------------+"
}

#Internet connection test
echo "Seeking internet connection..."

if ping -c 1 gnu.org > /dev/null 2>&1; then
  echo "Internet connection found"
else 
  echo "No internet connection found"
  sleep 1
  echo "Exiting..."
  sleep 1
  exit 1
fi

#Announcement banner
banner_large "Starting setup..."

#Update and cleansing
banner_small "Updating and cleaning up..."

apt-get update && apt-get upgrade
apt-get autoremove

#Software install
banner_small "Installing software..."

add-apt-repository -y ppa:kiwixteam/release
apt-get -y install kiwix shotcut sonic-pi scratch gcc-multilib

{
  printf "%0.s\n" {1..32}
  echo "y"
  echo "/opt/PhET"
  echo "y"
  echo "n"
} | sort \
| ./PhET-Installer_linux.bin

#Automatic reboot
banner_large "Setup complete!"
echo "Rebooting in 7 seconds... Press Ctrl^C to cancel"
sleep 7
reboot