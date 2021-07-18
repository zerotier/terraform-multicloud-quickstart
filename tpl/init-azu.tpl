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

echo "-- ZeroTier --"

curl -s https://install.zerotier.com | bash

zerotier-cli join ${zt_network}

echo "-- ZeroTier Systemd Manager --"

wget https://github.com/zerotier/zerotier-systemd-manager/releases/download/v0.1.9/zerotier-systemd-manager_0.1.9_linux_amd64.deb
dpkg -i zerotier-systemd-manager_0.1.9_linux_amd64.deb
systemctl daemon-reload
systemctl restart zerotier-one
systemctl enable zerotier-systemd-manager.timer
systemctl start zerotier-systemd-manager.timer

echo "-- Various Packages --"

apt-get -qq update &>/dev/null
apt-get -qq upgrade &>/dev/null

apt-get -qq install \
        apt-transport-https \
        software-properties-common \
        ca-certificates

add-apt-repository universe &>/dev/null
apt-get -qq update &>/dev/null

apt-get -qq install \
        apt-transport-https \
        software-properties-common \
        ca-certificates \
        emacs-nox \
        parallel \
        curl \
        gnupg \
        lsb-release \
        linux-tools-common \
        linux-tools-generic \
        zip \
        unzip \
        net-tools \
        iproute2 \
        bridge-utils \
        ntpsec \
        iputils-ping \
        iputils-arping \
        nmap \
        iputils-ping \
        libndp-tools \
        jq \
        scamper \
        tshark \
        python3-pip \
        &>/dev/null
