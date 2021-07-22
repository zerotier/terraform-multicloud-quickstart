# drop not ethertype ipv4 and not ethertype arp and not ethertype ipv6;
tee -1 ${ethertap};
accept;
