#!/bin/sh

# This file is supposed to be included from iotest.inc.sh
#
# NOTE: Think CAREFULLY before using something from iotest.inc.sh or elsewhere
#

# TODO: Dry-run switch. Comment out to enable real run.
#DRY=1

if test ! -z "$DRY" -a "$DRY" != "0"
then
 echo WARNING \(local.inc.sh\) Dry-run mode.
fi

#TODO: Uncomment to enable server aided delete
#SERVERAIDEDDELETE=1

#TODO: Uncomment to enable clean server cache
#CLEANSERVERCACHE=1

# If func_prepare_target_fs is unnecessary, enable this.
#FSHOT=1

DURATION=90
# For testing
#DURATION=10
# Infinite
#DURATION=0

# TODO: This specifies the desired maximum volume to transfer
# Overrides the value in iotest.inc.sh
MAX_TASK_SIZE="2147483648" # 2G
#MAX_TASK_SIZE="402653184" # 384M
#MAX_TASK_SIZE="67108864"  # 64M

# TODO Output goes to here
#TMPDIR=/run/shm
#TMPDIR=/home/user/tmp

#LOCALBASEDIR=/mnt/sdb1/nfs

IFACE="em1"
#IFACE="eth0"

PEER="tcs2"
#PEER="vm"
#PEER="ds"

CFS=/home/user/cloudfuse/cloudfuse
#CFS=/home/hwangz1/cloudfuse/cloudfuse

#AUTHURL="http://tcs2:8080/auth/v1.0"
AUTHURL="http://tcs2:27080/auth/v1.0"
#AUTHURL="http://vm:8080/auth/v1.0"

AUTHUSER="test:tester"
AUTHKEY="testing"

func_clean_server ()
{
 if test -z "$CLEANSERVERCACHE" -o "$CLEANSERVERCACHE" = "0"
 then
  return
 fi

 # XXX: Intel testbed-only hack
 if test "$PEER" != "tcs2"
 then
  echo XXX clean server cache: unsupported peer $peer
  return
 fi

 echo INFO clean server cache
 if test ! -z "$DRY" -a "$DRY" != "0"
 then
  return
 fi

 # XXX: This is why ...
 ssh $PEER -t -t "sh ./clean-filesystem-cache.sh";
}

func_server_aided_delete ()
{
 if test -z "$SERVERAIDEDDELETE" -o "$SERVERAIDEDDELETE" = "0"
 then
  echo ERR server aided delete called when flag not set.
  exit
 fi

 # XXX: Intel testbed-only hack
 if test "$PEER" != "tcs2"
 then
  echo XXX server aided delete: unsupported peer $peer
  return
 fi

 echo INFO server aided delete: $fs
 if test ! -z "$DRY" -a "$DRY" != "0"
 then
  #TODO remember to update these
  if test "$fs" = "nfs"
  then
   echo CMD: ssh $PEER -t -t \"./iotest/punlink -t $_srv_nfs -k $base_jobsn -s $n_jobs -n 32 -q\"
  elif test "$fs" = "iscsi"
  then
   echo CMD: ./punlink -t $TARGET -k $base_jobsn -s $n_jobs -n 32 -q
  fi
  return
 fi

 if test "$fs" = "nfs"
 then
  #XXX server side NFS path for tcs2
  _srv_nfs=`echo $TARGET | sed "s/nfs/sdb1\/nfs/g"`
  #TODO if changed, update DRY block above.
  ssh $PEER -t -t "./iotest/punlink -t $_srv_nfs -k $base_jobsn -s $n_jobs -n 32 -q" 1>&2
 elif test "$fs" = "iscsi"
 then
  sh ~/unset-route.sh
  _not_have_wanem=$?
  if test $_not_have_wanem = 0
  then
   echo INFO server aided delete: Have WANem
   #XXX
   ssh $PEER -t -t "sh ~/unset-route.sh" 1>&2
  fi
  #TODO if changed, update DRY block above.
  ./punlink -t $TARGET -k $base_jobsn -s $n_jobs -n 32 -q 1>&2
  if test $_not_have_wanem = 0
  then
   #XXX
   ssh $PEER -t -t "sh ~/script.sh" 1>&2
   sh ~/script.sh
  fi
 fi
}

# NOTE Caller is supposed to set various variables.
func_reheat_server_cache_for_read ()
{
 # XXX: Intel testbed-only hack
 if test "$PEER" != "tcs2"
 then
  echo XXX reheat server cache: unsupported peer $peer
  return
 fi

 if test "$rw" != "r"
 then
  echo ERR reheat server: rw != r ?!
  exit
 fi

 if test ! -z "$CLEANSERVERCACHE" -a "$CLEANSERVERCACHE" != "0"
 then
  echo ERR reheat + clean server cache does not make sense!
  exit
 fi

 echo INFO reheat server cache: $fs

 if test -z "$DRY" -o "$DRY" = "0"
 then
  # Bypass WANem to save time and achieve best effect.
  sh ~/unset-route.sh
  _not_have_wanem=$?
  if test $_not_have_wanem = 0
  then
   echo INFO reheat server cache: Have WANem
   #XXX
   ssh $PEER -t -t "sh ~/unset-route.sh" 1>&2
  fi
 fi

 # Set flag to O_DIRECT - only re-heat server cache, not client!
 _flag=$flag
 # XXX : Old kernels do not support O_DIRECT for FUSE ...
 if test "$fs" = "fuse"
 then
  flag="def"
 else
  flag="d"
 fi
 # Use 32 threads
 _n_threads=$n_threads
 n_threads=32
 # Allow slightly more time
 _duration=$duration
 duration=$(($duration+5))
 # These will be set by func_worker_invoke_worker_c() with func_worker_fnames()
 # We will rename them later
 OUTF=
 TMPF=
 #XXX Actually, we should not call stuff in iotest.inc.sh from local.inc.sh.
 # But since this function is going to be called from iotest.inc.sh ...
 func_set_read_dir $fs $job_size
 func_worker_invoke_worker_c
 if test ! -z "$DRY" -a "$DRY" != "0"
 then
  echo CMD rename OUTF and TMPF to reheat-$fs-$job_size-$flag-$n_threads-${n_jobs}.txt/.out
 else
  mv $OUTF ${OUTPUTDIR}reheat-$fs-$job_size-$flag-$n_threads-${n_jobs}.txt
  mv $TMPF ${OUTPUTDIR}reheat-$fs-$job_size-$flag-$n_threads-${n_jobs}.out
  if test $_not_have_wanem = 0
  then
   #XXX
   ssh $PEER -t -t "sh ~/script.sh" 1>&2
   sh ~/script.sh
  fi
 fi
 flag=$_flag
 n_threads=$_n_threads
 duration=$_duration
}

