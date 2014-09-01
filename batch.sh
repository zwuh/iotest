#!/bin/sh

# XXX tcs2 specific: sdb is the iSCSI block device
# param1: scheduler
func_set_sdb_iosched ()
{
 sudo sh -c "echo $1 > /sys/block/sdb/queue/scheduler"
 echo -n INFO sdb iosched:\ 
 cat /sys/block/sdb/queue/scheduler
}

# param1: dirname
func_move_outputs ()
{
  mkdir $TMPDIR/$1
  mv $TMPDIR/*.txt $TMPDIR/results $TMPDIR/$1/
}

# XXX default for Fedora
func_set_sdb_iosched "cfq"

# XXX for tcs2
export TMPDIR=/home/user/tmp


# TODO Each run should be like this:
# 1. Set I/O scheduler
# 2. Show status
# 3. Set TMPDIR to desired output dir
# 4. Run the test(s)
#  Tests: meta.sh, run-file.sh, run-meta.sh, run-one-pkt.sh, run-worker-bs.sh
# 5. Restore I/O scheduler to cfq if changed

sh run-file.sh
func_move_outputs "f-ncl"
sh run-worker-bs.sh
func_move_outputs "bs-ncl"
sh run-one-pkt.sh
func_move_outputs "op-ncl"
sh run-meta.sh
func_move_outputs "m-ncl"

func_set_sdb_iosched "deadline"
sh f-iscsi.sh
func_move_outputs "f-idead-ncl"
sh bs-iscsi.sh
func_move_outputs "bs-idead-ncl"
sh op-iscsi.sh
func_move_outputs "op-idead-ncl"
sh m-iscsi.sh
func_move_outputs "m-idead-ncl"
func_set_sdb_iosched "cfq"

func_set_sdb_iosched "noop"
sh f-iscsi.sh
func_move_outputs "f-inoop-ncl"
sh bs-iscsi.sh
func_move_outputs "bs-inoop-ncl"
sh op-iscsi.sh
func_move_outputs "op-inoop-ncl"
sh m-iscsi.sh
func_move_outputs "m-inoop-ncl"
func_set_sdb_iosched "cfq"


# TODO
exit

# TODO 
export CLEANSERVERCACHE=1
func_set_sdb_iosched "cfq"

sh run-file.sh
func_move_outputs "f-cl"
sh run-worker-bs.sh
func_move_outputs "bs-cl"
sh run-one-pkt.sh
func_move_outputs "op-cl"
sh run-meta.sh
func_move_outputs "m-cl"

func_set_sdb_iosched "deadline"
sh f-iscsi.sh
func_move_outputs "f-idead-cl"
sh bs-iscsi.sh
func_move_outputs "bs-idead-cl"
sh op-iscsi.sh
func_move_outputs "op-idead-cl"
sh m-iscsi.sh
func_move_outputs "m-idead-cl"
func_set_sdb_iosched "cfq"

func_set_sdb_iosched "noop"
sh f-iscsi.sh
func_move_outputs "f-inoop-cl"
sh bs-iscsi.sh
func_move_outputs "bs-inoop-cl"
sh op-iscsi.sh
func_move_outputs "op-inoop-cl"
sh m-iscsi.sh
func_move_outputs "m-inoop-cl"
func_set_sdb_iosched "cfq"

# TODO
exit

