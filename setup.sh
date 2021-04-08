#!/usr/bin/env bash

#Fully automatic Ubuntu setup script, intended for Hintegram
#Requires certain local binaries and archives to function
#Navigate to this script's directory and run it as root

#Exit trap
trap \
"{
  echo "Exiting..."
  sleep 1 
  exit 1; 
}" \
ERR SIGINT SIGTERM

#Privilege test
if ! [ $(id -u) = 0 ]; then
  echo "Setup is not running as root!"
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

#Local files test
if ! [ -e deb/sonic-pi_2.10.0~repack-2.1build2_amd64.deb ] && \
  [ -e deb/gcc-multilib_9.3.0-1ubuntu2_amd64.deb ] && \
  [ -e deb/kiwix_2.0.5~focal_amd64.deb ] && \
  [ -e deb/scratch_1.4.0.6~dfsg1-6_all.deb ] && \
  [ -e deb/shotcut_20.02.17-2_amd64.deb ] && \
  [ -e bin/PhET-Installer_linux.bin ] && \
  [ -e zim/wikipedia_en_for-schools_2018-09.zim ]
then
  echo "Local files missing!"
  echo "Setup may not complete fully"
  sleep 1
fi

#Announcement banner
banner_large "Starting setup..."

#Software install (deb)
banner_small "Installing software..."

dpkg -i deb/sonic-pi_2.10.0~repack-2.1build2_amd64.deb \
  deb/gcc-multilib_9.3.0-1ubuntu2_amd64.deb \
  deb/kiwix_2.0.5~focal_amd64.deb \
  deb/scratch_1.4.0.6~dfsg1-6_all.deb \
  deb/shotcut_20.02.17-2_amd64.deb

apt-get install -f

#Software install (bin)
{
  printf "%0.s\n" {1..32}
  echo "/opt/PhET"
  echo "y"
  echo "n"
} | sort | ./bin/PhET-Installer_linux.bin

cp /opt/PhET/PhET\ Simulations.desktop \
  /usr/share/applications/PhET\ Simulations.desktop

#Automatic reboot
banner_large "Setup complete!"
echo "Rebooting in 7 seconds... Press Ctrl^C to cancel"
sleep 7
reboot