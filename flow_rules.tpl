
# drop not ethertype ipv4 and not ethertype arp and not ethertype ipv6;
tee -1 ${ethertap};
# watch -1 ${ethertap} chr inbound;
accept;
