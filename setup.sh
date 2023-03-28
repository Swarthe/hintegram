#!/usr/bin/env bash
#
# Automatically set up Ubuntu for Hintegram with external binaries and libraries.
# More information available here: <https://drive.google.com/drive/u/1/folders/1povknwA0eCiID84lqbvH1no2gdcHstoq>
#
# Created by Swarthe, with help from kinnounko (Github).
#

# TODO
#
# completely overhaul in almost every way, and with features from
# <https://github.com/Swarthe/utility>
#
# have script print source and invitation to report bugs/recommendations and
# maybe print authors+copyright(?) as well
#
# turn script into two parts (probably different files): one to download and do
# basic setup of necessary files (bypasses possible licensing issues of
# packaging together) (we can then share the package physically (maybe also with
# linux iso?)). second part would deploy files and configure etc
#

#
# Exit trap
#
trap \
"{
  echo "Exiting..."
  exit 1;
}" \
ERR SIGINT SIGTERM

#
# Test privilege level
#
if ! [ $(id -u) = 0 ]; then
  echo "Setup is not running as root!"
  echo "Exiting..."
  exit 1
fi

#
# Ouput banners
#
banner_large ()
{
  echo "+------------------------------------------+"
  printf "| %-40s |\n" "`date`"
  echo "|                                          |"
  printf "|`tput bold` %-40s `tput sgr0`|\n" "$@"
  echo "+------------------------------------------+"
}

banner_small ()
{
  echo "+------------------------------------------+"
  printf "|`tput bold` %-40s `tput sgr0`|\n" "$@"
  echo "+------------------------------------------+"
}

#
# Test local files for profiles
#
if [ -e deb/sonic-pi_2.10.0~repack-2.1build2_amd64.deb ] && \
   [ -e deb/gcc-multilib_4%3a9.3.0-1ubuntu2_amd64.deb ] && \
   [ -e deb/kiwix_2.0.5~focal_amd64.deb ] && \
   [ -e deb/scratch_1.4.0.6~dfsg1-6_all.deb ] && \
   [ -e deb/shotcut_20.02.17-2_amd64.deb ] && \
   [ -e bin/PhET-Installer_linux.bin ] && \
   [ -e zim/wikipedia_en_for-schools_2018-09.zim ]; then
  echo "Essential local files found!"
  echo "Setup will continue locally"
  prof="local"
else
  echo "Essential local files missing!"
  echo "Setup will continue remotely"
  prof="remote"
fi

#
# Test internet connection for remote
#
if [ "$prof" = "remote" ]; then
  echo "Seeking internet connection..."

  if ping -c 1 archlinux.org > /dev/null 2>&1; then
    echo "Internet connection found!"
  else
    echo "No internet connection found!"
    echo "Exiting..."
    exit 1
  fi
fi

#
# Install software (deb)
#
banner_large "Starting setup..."
banner_small "Installing software..."

export DEBIAN_FRONTEND=noninteractive

if [ "$prof" = "local" ]; then
  apt -yq install ./deb/*
fi

if [ "$prof" = "remote" ]; then
    # Install zoom
    wget https://zoom.us/client/latest/zoom_amd64.deb -P /tmp/
    apt -yq install /tmp/zoom_amd64.deb

    add-apt-repository -y ppa:kiwixteam/release
    apt -yq install kiwix shotcut sonic-pi scratch gcc-multilib
fi

#
# Install software (bin)
#
if [ "$prof" = "local" ]; then
  {
    printf "%0.s\n" {1..32}
    echo "/opt/PhET"
    echo "y"
    echo "n"
  } | sort | ./bin/PhET-Installer_linux.bin
  cp -v /opt/PhET/PhET\ Simulations.desktop \
  /usr/share/applications/PhET\ Simulations.desktop
fi

if [ "$prof" = "remote" ]; then
  wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget \
  --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate \
  'https://docs.google.com/uc?export=download&id=1VddMR5dd7BIVp1Ze0PEd5gsU7th0pnTt' -O- | \
  sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1VddMR5dd7BIVp1Ze0PEd5gsU7th0pnTt" \
  -O /tmp/PhET-Installer_linux.bin
  chmod +x /tmp/PhET-Installer_linux.bin
  {
    printf "%0.s\n" {1..32}
    echo "/opt/PhET"
    echo "y"
    echo "n"
  } | sort | /tmp/PhET-Installer_linux.bin
  cp -v /opt/PhET/PhET\ Simulations.desktop \
    /usr/share/applications/PhET\ Simulations.desktop
fi

#
# Download libraries (zim)
#
banner_small "Downloading libraries..."

user="$SUDO_USER"
sudo -u "$user" mkdir -p "/home/"$user"/.local/share/kiwix/"

if [ "$prof" = "local" ]; then
  cp -v "zim/wikipedia_en_for-schools_2018-09.zim" \
  "/home/"$user"/.local/share/kiwix/wikipedia_en_for-schools_2018-09.zim"
  cp -v "zim/library.xml" \
  "/home/"$user"/.local/share/kiwix/library.xml"
fi

if [ "$prof" = "remote" ]; then
  sudo -u "$user" wget -O /home/"$user"/.local/share/kiwix/wikipedia_en_for-schools_2018-09.zim \
  https://download.kiwix.org/zim/wikipedia_en_for-schools.zim
  sudo -u "$user" wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget \
  --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate \
  'https://docs.google.com/uc?export=download&id=1JyNEoTIDFXwqRV9rByPsNbry20mCZHRl' -O- | \
  sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1JyNEoTIDFXwqRV9rByPsNbry20mCZHRl" \
  -O /home/"$user"/.local/share/kiwix/library.xml
fi

#
# Copy shorcuts ; needs kiwix shortcut
#
banner_small "Setting up shortcuts..."
cp -at "/home/$user/Desktop/" /usr/share/applications/org.shotcut.Shotcut.desktop \
/usr/share/applications/sonic-pi.desktop \
/usr/share/applications/scratch.desktop \
/usr/share/applications/PhET\ Simulations.desktop

#
# Reboot
#
banner_large "Setup complete!"
echo "Rebooting in 7 seconds... Press Ctrl^C to cancel"
sleep 7
reboot
