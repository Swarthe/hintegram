#!/usr/bin/env bash

#Fully automatic Ubuntu setup script, intended for Hintegram
#Requires certain local or remote binaries and archives to function
#Navigate to this script's directory and run it as root

#Exit trap
trap \
"{
  echo "Exiting..."
  exit 1; 
}" \
ERR SIGINT SIGTERM

#Privilege test
if ! [ $(id -u) = 0 ]; then
  echo "Setup is not running as root!"
  echo "Exiting..."
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

#Local files test for profiles
if [ -e deb/sonic-pi_2.10.0~repack-2.1build2_amd64.deb ] && \
  [ -e deb/gcc-multilib_9.3.0-1ubuntu2_amd64.deb ] && \
  [ -e deb/kiwix_2.0.5~focal_amd64.deb ] && \
  [ -e deb/scratch_1.4.0.6~dfsg1-6_all.deb ] && \
  [ -e deb/shotcut_20.02.17-2_amd64.deb ] && \
  [ -e bin/PhET-Installer_linux.bin ] && \
  [ -e zim/wikipedia_en_for-schools_2018-09.zim ]; then
    echo "Local files found!"
    echo "Setup will continue locally"
    prof="local"
else
  echo "Local files missing!"
  echo "Setup will continue with internet"
  prof="remote"
fi

#Internet connection test for remote
if [ "$prof" == "remote" ]; then
  echo "Seeking internet connection..."
  if ping -c 1 gnu.org > /dev/null 2>&1; then
    echo "Internet connection found!"
  else
    echo "No internet connection found!"
    echo "Exiting..."
    exit 1
  fi
fi

#Announcement banner
banner_large "Starting setup..."

#Software install (deb)
banner_small "Installing software..."

if [ "$prof" == "local" ]; then
  dpkg -i deb/sonic-pi_2.10.0~repack-2.1build2_amd64.deb \
    deb/gcc-multilib_9.3.0-1ubuntu2_amd64.deb \
    deb/kiwix_2.0.5~focal_amd64.deb \
    deb/scratch_1.4.0.6~dfsg1-6_all.deb \
    deb/shotcut_20.02.17-2_amd64.deb
  apt-get install -f
fi

if [ "$prof" == "remote" ]; then
  apt-get -y update
  add-apt-repository -y ppa:kiwixteam/release
  apt-get -y install kiwix shotcut sonic-pi scratch gcc-multilib
fi

#Software install (bin)
if [ "$prof" == "local" ]; then
  {
    printf "%0.s\n" {1..32}
    echo "/opt/PhET"
    echo "y"
    echo "n"
  } | sort | ./bin/PhET-Installer_linux.bin
  cp /opt/PhET/PhET\ Simulations.desktop \
    /usr/share/applications/PhET\ Simulations.desktop
fi

if [ "$prof" == "remote" ]; then
  wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget \
    --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate \
    'https://docs.google.com/uc?export=download&id=1VddMR5dd7BIVp1Ze0PEd5gsU7th0pnTt' -O- | \
    sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1VddMR5dd7BIVp1Ze0PEd5gsU7th0pnTt" \
    -O PhET-Installer_linux.bin && rm -rf /tmp/cookies.txt
  {
    printf "%0.s\n" {1..32}
    echo "/opt/PhET"
    echo "y"
    echo "n"
  } | sort | ./PhET-Installer_linux.bin
  cp /opt/PhET/PhET\ Simulations.desktop \
    /usr/share/applications/PhET\ Simulations.desktop
fi

#Library install (wip)
banner_small "Downloading libraries..."

mkdir "/home/academic/.local/share/kiwix/"

if [ "$prof" == "local" ]; then
  cp "zim/wikipedia_en_for-schools_2018-09.zim" "/home/academic/.local/share/kiwix/wikipedia_en_for-schools_2018-09.zim"
fi

if [ "$prof" == "remote" ]; then
  wget -O wikipedia_en_for-schools_2018-09.zim https://download.kiwix.org/zim/wikipedia_en_for-schools.zim
  mv "wikipedia_en_for-schools_2018-09.zim" "/home/academic/.local/share/kiwix/wikipedia_en_for-schools_2018-09.zim"
fi

#Automatic reboot
banner_large "Setup complete!"
echo "Rebooting in 7 seconds... Press Ctrl^C to cancel"
sleep 7
reboot