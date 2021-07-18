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

echo "-- zerotier --"

curl -s https://install.zerotier.com | bash

zerotier-cli join ${zt_network}

echo "-- ZeroTier Systemd Manager --"

wget https://github.com/zerotier/zerotier-systemd-manager/releases/download/v0.1.9/zerotier-systemd-manager_0.1.9_linux_amd64.deb
dpkg -i zerotier-systemd-manager_0.1.9_linux_amd64.deb
systemctl daemon-reload
systemctl restart zerotier-one
systemctl enable zerotier-systemd-manager.timer
systemctl start zerotier-systemd-manager.timer

echo "-- iptables NAT --"

mosdef=$(ip route | grep ^default | awk '{ print $5 }')

for i in $(ls /sys/class/net | grep $mosdef) ; do
    echo "* configuring NAT on $${i} ..."
    echo "net.ipv4.conf.$${i}.forwarding=1" > /etc/sysctl.d/21-net.ipv4.conf.$${i}.conf
    echo "net.ipv6.conf.$${i}.forwarding=1" > /etc/sysctl.d/21-net.ipv6.conf.$${i}.conf
    echo iptables -t nat -A POSTROUTING -o "$${i}" -j MASQUERADE
done

echo "-- Various Packages --"

apt-get -qq update &>/dev/null
apt-get -qq upgrade &>/dev/null

apt-get -qq install \
        apt-transport-https \
        software-properties-common \
        ca-certificates \
        lsb-release \
        linux-tools-common \
        linux-tools-generic \
        ntpsec \
        emacs-nox \
        parallel \
        curl \
        gnupg \
        zip \
        unzip \
        net-tools \
        iproute2 \
        bridge-utils \
        iputils-ping \
        iputils-arping \
        libndp-tools \
        jq \
        scamper \
        tshark \
        nmap \
       &>/dev/null
