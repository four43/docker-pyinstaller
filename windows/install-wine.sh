#!/bin/bash
set -exo pipefail

dpkg --add-architecture i386
wget -O- -q https://dl.winehq.org/wine-builds/winehq.key | apt-key add -
echo 'deb https://dl.winehq.org/wine-builds/debian/ buster main' > /etc/apt/sources.list.d/wine.list
wget -O- -q https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key | apt-key add -
echo "deb http://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./" > /etc/apt/sources.list.d/wine-obs.list
apt update
apt install -y --install-recommends winehq-stable
apt clean

wget -nv https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks
mv winetricks /usr/local/bin/
