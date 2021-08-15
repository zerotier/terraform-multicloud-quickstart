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
wget -q https://github.com/zerotier/zerotier-systemd-manager/releases/download/v0.2.0/zerotier-systemd-manager_0.2.0_linux_amd64.deb
dpkg -i zerotier-systemd-manager_0.2.0_linux_amd64.deb

echo "-- ZeroTier Central Token --"

bash -c "echo ${zt_token} > /var/lib/zerotier-one/token"
chown zerotier-one:zerotier-one /var/lib/zerotier-one/token
chmod 600 /var/lib/zerotier-one/token

echo "-- ZeroNSD --"

wget -q https://github.com/zerotier/zeronsd/releases/download/v0.2.3/zeronsd_0.2.3_amd64.deb
dpkg -i zeronsd_0.2.3_amd64.deb

%{ for zt_net in zt_networks }
echo "zeronsd supervise -t /var/lib/zerotier-one/token -d ${zt_net.dnsdomain} ${zt_net.id}"
zeronsd supervise -t /var/lib/zerotier-one/token -d ${zt_net.dnsdomain} ${zt_net.id}
%{ endfor ~}

%{ for zt_net in zt_networks }
echo "systemctl enable zeronsd-${zt_net.id}"
systemctl enable zeronsd-${zt_net.id}
%{ endfor ~}

systemctl daemon-reload

%{ for zt_net in zt_networks }
echo "systemctl restart zeronsd-${zt_net.id}"
systemctl restart zeronsd-${zt_net.id}
%{ endfor ~}

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
        tshark
    &>/dev/null
