#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "-- functions and variables --"

function apt-get() {
    while fuser -s /var/lib/dpkg/lock || fuser -s /var/lib/apt/lists/lock || fuser -s /var/lib/dpkg/lock-frontend ; do
        echo 'waiting for dpkg lock release' ;
        sleep 1 ;
    done ; /usr/bin/apt-get "$@"
}

export DEBIAN_FRONTEND=noninteractive

echo "-- iptables --"
iptables -F

echo "-- ZeroTier --"

curl -s https://install.zerotier.com | bash

%{ for zt_net in zt_networks }
zerotier-cli join ${zt_net.id}
while ! zerotier-cli listnetworks | grep ${zt_net.id} | grep OK ;
do
  sleep 1
done
%{ endfor ~}

echo "-- ZeroTier Systemd Manager --"
wget -q https://github.com/zerotier/zerotier-systemd-manager/releases/download/v0.2.1/zerotier-systemd-manager_0.2.1_linux_amd64.deb
dpkg -i zerotier-systemd-manager_0.2.1_linux_amd64.deb

echo "-- Update Apt Cache --"

apt-get -qq update &>/dev/null

echo "-- Nginx Hello --"
apt-get -qq install docker.io
docker run -d -it --rm --network host nginxdemos/hello

echo "-- Various Packages --"

apt-get -qq install \
        emacs-nox \
        curl \
        net-tools \
        iproute2 \
        iputils-ping \
        libndp-tools \
        tshark \
    &>/dev/null

echo "-- Script Finished! --"
