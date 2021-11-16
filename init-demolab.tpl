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
iptables -I INPUT -p udp --dport 9993 -j ACCEPT
iptables -I INPUT -p udp --dport 53 -j ACCEPT
iptables -I INPUT -p tcp --dport 53 -j ACCEPT
iptables -I INPUT -p tcp --dport 22 -j ACCEPT
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 443 -j ACCEPT

echo "-- ZeroTier identity --"
mkdir -p /var/lib/zerotier-one/
echo ${zt_identity.public_key} > /var/lib/zerotier-one/identity.public
chmod 0644 /var/lib/zerotier-one/identity.public
echo ${zt_identity.private_key} > /var/lib/zerotier-one/identity.secret
chmod 0600 /var/lib/zerotier-one/identity.secret

echo "-- ZeroTier --"
# curl -s https://install.zerotier.com | bash
wget https://download.zerotier.com/debian/xenial/pool/main/z/zerotier-one/zerotier-one_1.6.6_amd64.deb
dpkg -i zerotier-one_1.6.6_amd64.deb

zerotier-cli join ${zt_network}
while ! zerotier-cli listnetworks | grep ${zt_network} | grep OK ;
do
  sleep 1
done

echo "-- ZeroTier Systemd Manager --"
wget -q https://github.com/zerotier/zerotier-systemd-manager/releases/download/v0.2.1/zerotier-systemd-manager_0.2.1_linux_amd64.deb
dpkg -i zerotier-systemd-manager_0.2.1_linux_amd64.deb

%{ if zeronsd ~}
echo "-- ZeroTier Central Token --"

bash -c "echo ${zt_token} > /var/lib/zerotier-one/token"
chown zerotier-one:zerotier-one /var/lib/zerotier-one/token
chmod 600 /var/lib/zerotier-one/token

echo "-- ZeroNSD --"

wget -q https://github.com/zerotier/zeronsd/releases/download/v0.2.4/zeronsd_0.2.4_amd64.deb
dpkg -i zeronsd_0.2.4_amd64.deb

echo "zeronsd supervise -t /var/lib/zerotier-one/token -d ${dnsdomain} ${zt_network}"
zeronsd supervise -t /var/lib/zerotier-one/token -d ${dnsdomain} ${zt_network}

echo "systemctl enable zeronsd-${zt_network}"
systemctl enable zeronsd-${zt_network}

systemctl daemon-reload

echo "systemctl restart zeronsd-${zt_network}"
systemctl restart zeronsd-${zt_network}
%{ endif ~}

echo "-- Update Apt Cache --"

apt-get -qq update &>/dev/null

echo "-- Nginx Hello --"
apt-get -qq install docker.io

%{ for user in svc }
usermod -a -G docker ${user.username}
%{ endfor ~}

docker run -d -it --restart always --network host nginxdemos/hello

echo "-- Various Packages --"

export DEBIAN_FRONTEND=noninteractive
apt-get -qq install \
        emacs-nox \
        net-tools \
        iproute2 \
        iputils-ping \
        libndp-tools \
        tshark \
        nmap \
        avahi-utils \
        speedtest-cli \
    &>/dev/null

echo "-- ZeroTier 6PLANE Docker Networks  --"

ZT_IDENT="$(cat /var/lib/zerotier-one/identity.public | cut -f 1 -d :)"
LOWER=$(echo ${zt_network} | cut -c 1-8)
UPPER=$(echo ${zt_network} | cut -c 9-16)
PREFIX=$(printf 'fc%x\n' $(( 0x$LOWER ^ 0x$UPPER )))
SIXPLANE=$(echo "$${PREFIX}$${ZT_IDENT}" | sed 's/.\{4\}/&:/g' | awk -F":" '{ print $1":"$2":"$3":"$4":"$5"::/80" }')

cat <<EOF > /etc/docker/daemon.json
{
  "ipv6": true,
  "bip": "${pod_cidr}",
  "fixed-cidr": "${pod_cidr}",
  "fixed-cidr-v6": "$${SIXPLANE}",
  "ip-forward": true
}
EOF

systemctl restart docker
ip6tables -t nat -A POSTROUTING -s $${SIXPLANE} ! -o docker0 -j MASQUERADE
iptables --policy FORWARD ACCEPT

echo "-- docker container routes --"

ROUTER_ID=$(echo ${pod_cidr} | cut -f 1 -d '/')
apt-get -qq install bird

cat <<EOF> /etc/bird/bird.conf
router id $${ROUTER_ID};

protocol kernel {
	metric 64;
	import none;
	export all;
}

protocol device { }

filter ospf_in {
       	if net = 0.0.0.0/0 then reject; else accept;
}

filter ospf_out {
       	if net = 0.0.0.0/8 then {
     	    reject;
	} else {
	    ospf_metric1 = 1000;
   	    accept;
	}
}

protocol ospf ospf1 {
        debug { states, routes, interfaces };
	import filter ospf_in;
	export filter ospf_out;

	area 0 {
	     interface "*" { };
	};
}
EOF

systemctl enable bird
systemctl restart bird

iptables -I INPUT -p ospf -j ACCEPT
iptables -I OUTPUT -p ospf -j ACCEPT

echo "-- script finished! --"
