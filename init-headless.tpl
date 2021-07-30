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

echo "-- Docker Installation --"

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o  /usr/share/keyrings/docker-archive-keyring.gpg

echo \
"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
 $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get -qq update
apt-get -qq install docker-ce docker-ce-cli containerd.io
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "-- ZeroTier 6PLANE Docker Networks  --"

ZT_IDENT="$(cat /var/lib/zerotier-one/identity.public | cut -f 1 -d :)"

%{ for zt_net in zt_networks }
LOWER=$(echo ${zt_net.id} | cut -c 1-8)
UPPER=$(echo ${zt_net.id} | cut -c 9-16)
PREFIX=$(printf 'fc%x\n' $(( 0x$LOWER ^ 0x$UPPER )))
SIXPLANE=$(echo "$${PREFIX}$${ZT_IDENT}" | sed 's/.\{4\}/&:/g' | awk -F":" '{ print $1":"$2":"$3":"$4":"$5"::/80" }')

docker network create --ipv6 --subnet $${SIXPLANE} ${zt_net.dnsdomain}
%{ endfor ~}

%{ for zt_net in zt_networks }

echo "-- Nginx Hello --"
docker run -d -it --rm -p ${zt_net.ipv4}:80:80 --network ${zt_net.dnsdomain} nginxdemos/hello
%{ endfor ~}
