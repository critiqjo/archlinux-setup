ip addr add 10.129.79.69/16 broadcast 10.129.79.255 dev enp2s0
ip route add default via 10.129.250.1
echo "nameserver 10.200.1.11" >> /etc/resolv.conf
