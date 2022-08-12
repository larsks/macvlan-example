This repository accompanies <https://unix.stackexchange.com/a/713349/4989>.

## Requirements

To use this vagrant environment, you'll need [vagrant][] and the [vagrant-libvirt][] provider.

[vagrant]: https://www.vagrantup.com/
[vagrant-libvirt]:  https://github.com/vagrant-libvirt/vagrant-libvirt

## Usage

From inside this directory, run:

```
vagrant up
```

When the process is complete, you will have two nodes available, `node1` and `node2`. Both are configured as described in [the answer][answer], with a `ns0` namespace containing a `macvlan0` interface:

| Host  | Interface | Address        |
|-------|-----------|----------------|
| node1 | eth1      | 192.168.113.11 |
| node1 | macvlan0  | 192.168.113.21 |
| node2 | eth1      | 192.168.113.12 |
| node2 | macvlan0  | 192.168.113.22 |

Log into `node1` by running:

```
vagrant ssh node1
```

Perform an `arp-scan` against `node2` by running:

```
sudo arp-scan -I eth1 192.168.113.12 192.168.113.22
```

The output should look like this:

```
Interface: eth1, type: EN10MB, MAC: 52:54:00:2e:59:20, IPv4: 192.168.113.11
Starting arp-scan 1.9.7 with 2 hosts (https://github.com/royhills/arp-scan)
192.168.113.12  52:54:00:14:4d:c9       QEMU
192.168.113.22  62:5f:f8:91:2e:67       (Unknown: locally administered)

2 packets received by filter, 0 packets dropped by kernel
Ending arp-scan 1.9.7: 2 hosts scanned in 0.094 seconds (21.28 hosts/sec). 2 responded
```

The MAC addresses will be different than in the above example, but you can see that we have discovered two different MAC addresses for the two different IP addresses configured on `node2`. We can also ping both of these addresses:

```
[vagrant@node1 ~]$ ping -c1 192.168.113.12
PING 192.168.113.12 (192.168.113.12) 56(84) bytes of data.
64 bytes from 192.168.113.12: icmp_seq=1 ttl=64 time=0.627 ms

--- 192.168.113.12 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.627/0.627/0.627/0.000 ms
[vagrant@node1 ~]$ ping -c1 192.168.113.22
PING 192.168.113.22 (192.168.113.22) 56(84) bytes of data.
64 bytes from 192.168.113.22: icmp_seq=1 ttl=64 time=0.673 ms

--- 192.168.113.22 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.673/0.673/0.673/0.000 ms
```

## Verification

Log into `node2` to confirm the accuracy of our experiment. On your host, run:

```
vagrant ssh node2
```

And once logged in, look at the interface configuration:

```
[vagrant@node2 ~]$ sudo ip addr show eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:14:4d:c9 brd ff:ff:ff:ff:ff:ff
    altname enp0s7
    altname ens7
    inet 192.168.113.12/24 brd 192.168.113.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a91f:7547:927a:d236/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
[vagrant@node2 ~]$ sudo ip -n ns0 addr show macvlan0
4: macvlan0@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 62:5f:f8:91:2e:67 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.113.22/24 scope global macvlan0
       valid_lft forever preferred_lft forever
    inet6 fe80::605f:f8ff:fe91:2e67/64 scope link
       valid_lft forever preferred_lft forever
```

You can see that the MAC addresses here match what we discovered when running `arp-scan`.
