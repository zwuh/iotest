Testbed Setup
======

 * Interconnection: 1 Gbps LAN switch + 802.11n Wi-Fi
 * Storage client: Linux, GbE + Wi-Fi
 * Storage server: Linux, GbE
 * WANem: http://sourceforge.net/projects/wanem/ , GbE
 * Route IP traffic through WANem when necessary.

## Useful Commands

 * `traceroute`
 * `iperf`
 * Clean cache

```
sync
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
```

 * Disable network interface offload engines if packet capture is desired

```
# all as root
 ethtool --offload <iface> rx off
 ethtool --offload <iface> tx off
 ethtool --offload <iface> gso off
 ethtool --offload <iface> tso off
 ethtool --offload <iface> sg off
 ethtool --offload <iface> ufo off
 ethtool --offload <iface> gro off
 ethtool --offload <iface> lro off
 ethtool --offload <iface> rxvlan off
 ethtool --offload <iface> txvlan off
```


## OpenStack Swift


### Server

 * http://docs.openstack.org/developer/swift/development_saio.html

### Client - CloudFuse

 * http://redbo.github.io/cloudfuse/
 * Note that older kernels does not support `O_DIRECT` for FUSE `open()`.


## NFS

 * `/etc/exports`

```
(NFS mount) 192.168.1.0/255.255.255.0(rw,sync,all_squash,no_subtree_check,anonuid=1000,anongid=1000)
```

 * Make a subdirectory in iSCSI mount point and set the test user as owner.

## iSCSI

### Intel iSCSI

 * See reference [1]

#### Target

 * udisk start script `~/start-iscsi-server.sh`

```
#!/bin/sh
DEV=/dev/sdX
# 3260 is the default iSCSI port
PORT=3261
GBS=100
sudo killall udisk
sudo rm -f /tmp/UDISK.$PORT
sudo /usr/local/bin/udisk -d $DEV -p $PORT -b 1024 -n `expr 1024 \* 1024 \* $GBS` > SOMEWHERE
```

#### Initiator

  * `~/start-iscsi-client.sh`

```
sudo modprobe intel_iscsi
sudo mount /dev/sdXn (mountpoint)
```

### IET iSCSI Target

 * `/etc/default/iscsitarget`

```
ISCSITARGET_ENABLE=true
```

 * Package (Ubuntu): `iscsitarget` and `ietadm`

### Open-iSCSI Initiator

 * Start commands

```
iscsiadm -m discovery -t st -p (server)
iscsiadm -m node --login
mount /dev/sdXn (mountpoint)
```


Performance Tuning
======


### TCP parameter

 *  Server and Client: `/etc/sysctl.conf`

```
# for swift
# Increase conntrack table size for swift
net.netfilter.nf_conntrack_max = 262144

# for throughput test
net.core.wmem_max = 16777216
net.core.rmem_max = 16777216
net.ipv4.tcp_rmem = 1048576 4194304 16777216
net.ipv4.tcp_wmem = 1048576 4194304 16777216
net.ipv4.tcp_no_metrics_save = 1
net.core.netdev_max_backlog = 10000
```

### NFS

 * server worker threads: `/etc/sysconfig/nfs`

```
# Default is 8
RPCNFSDCOUNT=32
```

### iSCSI

 * Intel iSCSI target (udisk): `/etc/ips.conf`

```
MaxRecvDataSegmentLength=65536
FirstBurstLength=67108864
MaxBurstLength=67108864

```

 * Open-iSCSI initiator:

  * `/etc/iscsi/iscsid.conf`

```
#(also those in ietd.conf of Target)
node.conn[0].tcp.window_size = 4194304
```


 * IET iSCSI Target: `/etc/iet/ietd.conf`

```
MaxRecvDataSegmentLength = 262144
MaxXmitDataSegmentLength = 262144
MaxBurstLength = 16777216
FirstBurstLength = 16777216
IntialR2T = no
ImmediateData = yes
```

### Swift

 * SAIO but with only 1 node and 1 replica.

 * May also use ext4 instead of xfs.

 * There are some decisions made in CloudFuse which made some operations spend long time backing off, or hang if Swift server does not reply. Patched: https://github.com/zwuh/cloudfuse/tree/timeout


References
======


1. "User Guide for Linux and Windows DSS", Systems Architecture Lab, Intel Labs ,January 5, 2013

