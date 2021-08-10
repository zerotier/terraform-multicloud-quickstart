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

%{ for zt_net in zt_networks }
zerotier-cli join ${zt_net.id}
%{ endfor ~}

echo "-- ZeroTier Systemd Manager --"

# 0.1.9
# 0.2.0

wget -q https://github.com/zerotier/zerotier-systemd-manager/releases/download/v0.1.9/zerotier-systemd-manager_0.1.9_linux_amd64.deb
dpkg -i zerotier-systemd-manager_0.1.9_linux_amd64.deb
systemctl daemon-reload
systemctl enable zerotier-systemd-manager.timer
systemctl restart zerotier-systemd-manager.timer

echo "-- ZeroTier Central Token --"

bash -c "echo ${zt_token} > /var/lib/zerotier-one/token"
chown zerotier-one:zerotier-one /var/lib/zerotier-one/token
chmod 600 /var/lib/zerotier-one/token

echo "-- ZeroNSD --"

# 0.2.2
# 0.2.3

wget -q https://github.com/zerotier/zeronsd/releases/download/v0.2.2/zeronsd_0.2.2_amd64.deb
dpkg -i zeronsd_0.2.2_amd64.deb

%{ for zt_net in zt_networks }
echo "zeronsd supervise -t /var/lib/zerotier-one/token -d ${zt_net.dnsdomain} ${zt_net.id}"
zeronsd supervise -t /var/lib/zerotier-one/token -d ${zt_net.dnsdomain} ${zt_net.id}
%{ endfor ~}

systemctl daemon-reload

%{ for zt_net in zt_networks }
echo "systemctl enable zeronsd-${zt_net.id}"
echo "systemctl restart zeronsd-${zt_net.id}"
systemctl enable zeronsd-${zt_net.id}
systemctl restart zeronsd-${zt_net.id}
%{ endfor ~}

echo "-- Various Packages --"

apt-get -qq update &>/dev/null

apt-get -qq install \
        apt-transport-https \
        software-properties-common \
        ca-certificates \
        lsb-release \
        emacs-nox \
        curl \
        gnupg \
        net-tools \
        iproute2 \
        iputils-ping \
        libndp-tools \
        tshark \
        docker.io \
    &>/dev/null

echo "-- Nginx Hello --"
docker run -d -it --rm -p 80:80 nginxdemos/hello
