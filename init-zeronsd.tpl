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

echo "-- hostname --"

hostname ${hostname}
echo "${hostname}" > /etc/hostname
sed -i "s/^127.0.1.1*/127.0.1.1    ${hostname}.${dnsdomain} ${hostname}/" /etc/hosts

echo "-- users --"

%{ for user in svc }
useradd ${user.username} -c ${user.username} -m -U -s /bin/bash
mkdir -p /home/${user.username}/.ssh

echo "${user.ssh_pubkey}" > /home/${user.username}/.ssh/authorized_keys
chmod 0600 /home/${user.username}/.ssh/authorized_keys
chmod 0700 /home/${user.username}/.ssh
chown -R ${user.username} ~${user.username}

echo "${user.username} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${user.username}
chmod 440 /etc/sudoers.d/${user.username}
%{ endfor ~}

echo "-- iptables --"
iptables -F

echo "-- ZeroTier identity --"
mkdir -p /var/lib/zerotier-one/
echo ${zt_identity.public_key} > /var/lib/zerotier-one/identity.public
chmod 0644 /var/lib/zerotier-one/identity.public
echo ${zt_identity.private_key} > /var/lib/zerotier-one/identity.secret
chmod 0600 /var/lib/zerotier-one/identity.secret

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
        net-tools \
        iproute2 \
        iputils-ping \
        libndp-tools \
        tshark \
        nmap \
        avahi-utils \
    &>/dev/null

echo "-- Script Finished! --"
