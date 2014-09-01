Pre-run Check List
=====

 - Target: `/var/log/messages` oversize

  OpenStack Swift tests generate a huge amount of log.

```
 sudo mv messages messages-YYYYMMDD
 sudo service rsyslog restart
 sudo bzip2 messages-YYYYMMDD
```

 - Target: Swift partition mounted

```
 sudo mount /dev/sdd1 /mnt/sdd1
```

 - Target: Swift started

```
 sudo service memcached restart
 source /home/user/venv/activate
 swift-init main start
 deactivate
```

 - Target: iSCSI target running

```
 rm nohup.out
 nohup ./start-iscsi-server.sh &
```

 - Client: NFS,iSCSI,FUSE mounted

 - Both: NTPd running (optional)

```
 sudo service ntpd start
```

 - Both: route + WANem (if necessary)

```
 route -n
 sh ./script.sh
 traceroute tcs1/tcs2 # should go through WANem
```

 - Both: Network

```
 iperf
 ping
```

 - Client: Interface TCP offload engines disabled

```
 cd benchmark/iotest
 sudo sh offload.sh em1 # example
 ethtool -k em1
```

 - Client: `local.inc.sh`

```
 CLEANSERVERCACHE
 SERVERAIDEDDELETE
 MAX_TASK_SIZE
 TMPDIR
 duration
 ...
```


