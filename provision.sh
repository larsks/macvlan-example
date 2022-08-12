#!/bin/bash

BASEADDR="192.168.113"
PREFIXLEN="24"
NODE="${HOSTNAME:4}"

yum -y install tcpdump arp-scan

if ! nmcli c show eth1 > /dev/null 2>&1; then
	sudo nmcli c add \
		type ethernet \
		conn.id eth1 \
		ifname eth1 \
		ipv4.method manual \
		ipv4.address "${BASEADDR}.$(( NODE + 10 ))/${PREFIXLEN}"

	sudo nmcli c up eth1
fi

tmpfile=$(mktemp /etc/hostsXXXXXX)
grep -v 'node[0-9]' /etc/hosts > $tmpfile
cat >> $tmpfile <<EOF
${BASEADDR}.11 node1
${BASEADDR}.12 node2
EOF
cat "$tmpfile" > /etc/hosts

if ! ip netns | grep -q ns0; then
	ip netns add ns0
	ip link add macvlan0 link eth1 type macvlan mode bridge
	ip link set netns ns0 macvlan0
	ip -n ns0 addr add "${BASEADDR}.$(( NODE + 20 ))/${PREFIXLEN}" dev macvlan0
	ip -n ns0 link set macvlan0 up
fi
