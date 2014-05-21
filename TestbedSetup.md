Testbed Setup
=====

 * Interconnection: 1 Gbps LAN switch + 802.11n Wi-Fi
 * tcs1: Storage client, Linux, GbE + Wi-Fi
 * tcs2: Storage server/target, Linux, GbE
 * WANem: http://http://sourceforge.net/projects/wanem/, GbE

 * TCP parameter (tcs1,tcs2)

  * Conf: /etc/sysctl.conf

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

 * NFS server

  * Worker threads: /etc/sysconfig/nfs

```
# Default is 8
RPCNFSDCOUNT=32
```

 * NFS Exports: /etc/exports

```
(NFS mount) 192.168.1.0/255.255.255.0(rw,sync,all_squash,no_subtree_check,anonuid=1000,anongid=1000)
```

 * Make a subdirectory in iSCSI mount point and set the test user as owner.

 * Intel iSCSI target: udisk 

  * /etc/ips.conf

```
MaxRecvDataSegmentLength=65536
FirstBurstLength=67108864
MaxBurstLength=67108864

```

 * udisk start script ~/start-iscsi-server.sh

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

 * Intel iSCSI initiator: intel\_iscsi

  * ~/start-iscsi-client.sh

```
sudo modprobe intel_iscsi
sudo mount /dev/sdXn (mountpoint)
```

 * IET iSCSI target:

  * /etc/default/iscsitarget

```
ISCSITARGET_ENABLE=true
```

 * /etc/iet/ietd.conf

```
MaxRecvDataSegmentLength = 262144
MaxXmitDataSegmentLength = 262144
MaxBurstLength = 16777216
FirstBurstLength = 16777216
IntialR2T = no
ImmediateData = yes
```

 * IET iSCSI target package (Ubuntu): iscsitarget ietadm

 * Open-iSCSI initiator:

  * /etc/iscsi/iscsid.conf

```
#(also those in ietd.conf of Target)
node.conn[0].tcp.window_size = 4194304
```

  * Open-iSCSI initiator start commands:

```
iscsiadm -m discovery -t st -p (server)
iscsiadm -m node --login
mount /dev/sdXn (mountpoint)
```

 * Swift: http://github.com/openstack/swift

  * SAIO but with only 1 node and 1 replica and use ext4 instead of xfs.

 * CloudFuse with custom patch: https://github.com/zwuh/cloudfuse/tree/timeout

  * ~/.cloudfuse

```
username=test:tester
password=testing
authurl=http://(server):8080/auth/v1.0
```

 * CloudFuse commands

```
./cloudfuse (mountpoint)    (mount)
fusermount -u (mountpoint)  (unmount)
```

 * Clean cache

```
sync
sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
```

References
----

1. "User Guide for Linux and Windows DSS", Systems Architecture Lab, Intel Labs ,January 5, 2013

