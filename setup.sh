#!/bin/bash

#Ubuntu setup script, intended for Hintegram
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

#Privilege test
if ! [ $(id -u) = 0 ]; then
  echo "Setup is not running as root"
  sleep 1
  echo "Exiting..."
  sleep 1
  exit 1
fi

#Internet connection test
echo "Seeking internet connection..."
sleep 1

if ping -c 1 gnu.org > /dev/null 2>&1; then
  echo "Internet connection found"
  sleep 1
else 
  echo "No internet connection found"
  sleep 1
  echo "Exiting..."
  sleep 1
  exit 1
fi

banner_large "Starting setup..."
sleep 1

#Kiwix install
#mchange to repo package installation later
banner_small "Installing Kiwix..."
sleep 1
add-apt-repository -y ppa:kiwixteam/release
apt-get -y install kiwix

#add automatic update and autoremove
#add cancellable reboot/shutdown sequence