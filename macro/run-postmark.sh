#!/bin/sh

# Driver for PostMark

EXE=./postmark

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

func_print_timestamp ()
{
  # seconds # ns
  date +"%s%N"
}

if test -z "$OUTDIR"
then
 OUTDIR=cur
fi

if test ! -d "$OUTDIR"
then
 mkdir -p "$OUTDIR"
fi
echo INFO postmark-1.53 outputs go to $OUTDIR

if test "$DRY" != "0"
then
 exit
fi

func_clean_cache

echo INFO iSCSI cfq
func_set_sdb_iosched "cfq"
start=`func_print_timestamp`
$EXE < iscsi.cfg > $OUTDIR/iscsi-cfq.txt 2>&1
func_clean_cache
end=`func_print_timestamp`
echo -n Elapsed:\ 
echo "scale=3; ($end - $start)/1000000000" | bc

echo INFO iSCSI deadline
func_set_sdb_iosched "deadline"
start=`func_print_timestamp`
$EXE < iscsi.cfg > $OUTDIR/iscsi-dead.txt 2>&1
func_clean_cache
end=`func_print_timestamp`
echo -n Elapsed:\ 
echo "scale=3; ($end - $start)/1000000000" | bc

echo INFO iSCSI noop
func_set_sdb_iosched "noop"
start=`func_print_timestamp`
$EXE < iscsi.cfg > $OUTDIR/iscsi-noop.txt 2>&1
func_clean_cache
end=`func_print_timestamp`
echo -n Elapsed:\ 
echo "scale=3; ($end - $start)/1000000000" | bc

func_set_sdb_iosched "cfq"

echo INFO NFS
start=`func_print_timestamp`
$EXE < nfs.cfg > $OUTDIR/nfs.txt 2>&1
func_clean_cache
end=`func_print_timestamp`
echo -n Elapsed:\ 
echo "scale=3; ($end - $start)/1000000000" | bc

echo INFO Swift/FUSE
start=`func_print_timestamp`
$EXE < fuse.cfg > $OUTDIR/fuse.txt 2>&1
func_clean_cache
end=`func_print_timestamp`
echo -n Elapsed:\ 
echo "scale=3; ($end - $start)/1000000000" | bc

echo -n INFO end\ 
date

