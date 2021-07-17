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

# echo "-- Squid  --"
# apt-get -y install squid

# cat <<EOF > /etc/squid/conf.d/demolab.conf
# acl demolab src 10.0.0.0/8
# http_access allow localhost
# http_access allow demolab
# http_access deny all
# http_port 3128 intercept
# shutdown_lifetime 1
# EOF

# systemctl enable squid
# systemctl restart squid

# echo "-- HAProxy --"
# apt-get -y install haproxy

# echo "-- Suricata --"

# add-apt-repository ppa:oisf/suricata-stable
# apt-get -qq update
# apt-get -qq install suricata 
