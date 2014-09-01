#!/bin/sh

# Driver script for FileBench

EXE=/usr/local/bin/filebench

func_set_sdb_iosched ()
{
 sudo sh -c "echo $1 > /sys/block/sdb/queue/scheduler"
 echo -n INFO sdb iosched:\ 
 cat /sys/block/sdb/queue/scheduler
}

func_clean_cache ()
{
 echo INFO clean cache
 sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
}

# param1: out file
# param2: fs
func_gen_sql ()
{
 IOPS=`grep "IO Summary" $1 | awk '{print $7}'`
 if test $PROFILE = "fileserver"
 then
  conf=3
 elif test $PROFILE = "varmail"
 then
  conf=4
 fi
 echo -n SQL: insert into macro \(elapsed,bench,conf,date,scenario,fs,throughput\) values\ 
 echo \(120,3,$conf,\'$DATE\',$SCENE,$2,$IOPS\)\;
}

if test -z "$OUTDIR"
then
 OUTDIR=cur
fi

if test -z "$1" -a -z "$PROFILE"
then
 echo ERR no profile specified.
 exit
fi
if test ! -z "$1"
then
 PROFILE=$1
fi
echo INFO filebench profile: $PROFILE

if test ! -d "$OUTDIR"
then
 mkdir -p "$OUTDIR"
fi
echo INFO filebench outputs go to $OUTDIR

if test "$DRY" != "0"
then
 exit
fi

add_rand=`cat /proc/sys/kernel/randomize_va_space`
echo INFO Disabling virtual address space randomization
sudo sh -c "echo 0 > /proc/sys/kernel/randomize_va_space"

func_clean_cache

echo -n INFO iSCSI\ 
echo -n cfq\ 
date
func_set_sdb_iosched "cfq"
sudo $EXE -f ${PROFILE}.iscsi >$OUTDIR/iscsi-cfq.txt 2>&1
func_gen_sql "$OUTDIR/iscsi-cfq.txt" 2
func_clean_cache
echo -n deadline\ 
date
func_set_sdb_iosched "deadline"
sudo $EXE -f ${PROFILE}.iscsi >$OUTDIR/iscsi-dead.txt 2>&1
func_gen_sql "$OUTDIR/iscsi-dead.txt" 3
func_clean_cache
echo -n noop\ 
date
func_set_sdb_iosched "noop"
sudo $EXE -f ${PROFILE}.iscsi >$OUTDIR/iscsi-noop.txt 2>&1
func_gen_sql "$OUTDIR/iscsi-noop.txt" 4
func_clean_cache
func_set_sdb_iosched "cfq"
echo -n INFO NFS\ 
date
sudo $EXE -f ${PROFILE}.nfs   >$OUTDIR/nfs.txt   2>&1
func_gen_sql "$OUTDIR/nfs.txt" 1
func_clean_cache
echo -n INFO Swift/FUSE\ 
date
#remount FUSE mount
#sh /home/user/mount_fuse.sh
sudo $EXE -f ${PROFILE}.fuse  >$OUTDIR/fuse.txt  2>&1
func_gen_sql "$OUTDIR/fuse.txt" 5
func_clean_cache

echo INFO Restoring virtual address space randomization
date
sudo sh -c "echo $add_rand > /proc/sys/kernel/randomize_va_space"

