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

echo "-- ZeroTier Central Token --"

bash -c "echo ${zt_token} > /var/lib/zerotier-one/token"
chown zerotier-one:zerotier-one /var/lib/zerotier-one/token
chmod 600 /var/lib/zerotier-one/token

echo "-- ZeroNSD --"

wget https://github.com/zerotier/zeronsd/releases/download/v0.2.2/zeronsd_0.2.2_amd64.deb
dpkg -i zeronsd_0.2.2_amd64.deb

zeronsd supervise -t /var/lib/zerotier-one/token -d ${dnsdomain} ${zt_network}
systemctl daemon-reload
systemctl enable zeronsd-${zt_network}
systemctl start zeronsd-${zt_network}

echo "-- Kernel IP forwarding --"

echo "net.ipv4.conf.all.forwarding=1" > /etc/sysctl.d/21-net.net.ipv4.conf.all.forwarding.conf
echo "net.ipv6.conf.all.forwarding=1" > /etc/sysctl.d/21-net.net.ipv6.conf.all.forwarding.conf
systemctl restart systemd-sysctl.service

echo "-- Configuring NAT --."
mosdef=$(ip route | grep ^default | awk '{ print $5 }')

for i in $(ls /sys/class/net | grep $mosdef) ; do
    echo "* IPv4 Masquerade on $${i} ..."
    iptables -t nat -A POSTROUTING -o "$${i}" -j MASQUERADE
    echo "* IPv6 Masquerade on $${i} ..."
    ip6tables -t nat -A POSTROUTING -o "$${i}" -j MASQUERADE
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
