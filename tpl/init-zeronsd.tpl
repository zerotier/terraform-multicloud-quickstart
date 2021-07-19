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
