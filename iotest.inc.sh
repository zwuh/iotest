#!/bin/sh

if test -f local.inc.sh
then
 . ./local.inc.sh
fi

export LC_ALL=POSIX

# DRY non-zero: dry run
# FSHOT non-zero: do not warm up filesystem
# RESUME non-zero: do not re-run done cases
# SERVERAIDEDDELETE non-zero: use server-aided delete
# CLEANSERVERCACHE non-zero: clean server cache


if test -z "$ISCSIMOUNT"
then
 ISCSIMOUNT="/mnt/iscsi"
fi

if test -z "$ISCSIBASEDIR"
then
 ISCSIBASEDIR="/test"
fi

if test -z "$NFSMOUNT"
then
 NFSMOUNT="/mnt/nfs"
fi

if test -z "$NFSBASEDIR"
then
 NFSBASEDIR=""
fi

if test -z "$FUSEMOUNT"
then
 FUSEMOUNT="/mnt/fuse"
fi

if test -z "$FUSEBASEDIR"
then
 FUSEBASEDIR=""
fi

if test -z "$LOCALBASEDIR"
then
 LOCALBASEDIR="/tmp/test"
fi

DEFISCSIDIR="${ISCSIMOUNT}${ISCSIBASEDIR}/0"
DEFNFSDIR="${NFSMOUNT}${NFSBASEDIR}/0"
DEFFUSEDIR="${FUSEMOUNT}${FUSEBASEDIR}/0"
DEFLOCALDIR="${LOCALBASEDIR}/0"

if test -z "$ISCSIDIR"
then
 ISCSIDIR="$DEFISCSIDIR"
fi
if test -z "$NFSDIR"
then
 NFSDIR="$DEFNFSDIR"
fi
if test -z "$FUSEDIR"
then
 FUSEDIR="$DEFFUSEDIR"
fi
if test -z "$LOCALDIR"
then
 LOCALDIR="$DEFLOCALDIR"
fi

# Benchmark commands
# Parallel
DD_PAR=./parallel-dd.sh
C_PAR=./parallel-c.sh
SWIFT_PAR=./parallel-swift.sh
# Loop
DD_SEQ=./loop-dd.sh
C_SEQ=./loop-c.sh
SWIFT_SEQ=./loop-swift.sh
# Worker
C_WORKER=./worker-c.sh

# CloudFuse executable
if test -z "$CFS"
then
 CFS=$HOME/cloudfuse/cloudfuse
fi
# Swift auth_url
if test -z "$AUTHURL"
then
 AUTHURL="http://localhost:8080/auth/v1.0"
fi
# Swift User:Group
if test -z "$AUTHUSER"
then
 AUTHUSER="test:tester"
fi
# Swift Auth Key
if test -z "$AUTHKEY"
then
 AUTHKEY="testing"
fi
# Swift container
if test -z "$SWIFTCONTAINER"
then
 SWIFTCONTAINER="0"
fi


# Maximum size of a task.
# in each test case. This should be big enought to:
# 1) keep network busy for $duration at its full rate.
# 2) let each of n_threads get at least one job to serve.
# 17179869184 = 16 GiB
# 2147483648 = 2 GiB
# 1073741824 = 1 GiB
# 402653184 = 384 MiB
# 67108864 = 64 MiB
if test -z "$MAX_TASK_SIZE"
then
 MAX_TASK_SIZE=2147483648
fi

# How long a test round may run.
# Zero means infinite - disable this feature
if test -z "$DURATION"
then
 DURATION="0"
fi

if test -z "$TMPDIR"
then
 TMPDIR="/tmp"
fi

# Data output
if test -z "$OUTPUTDIR"
then
 OUTPUTDIR="$TMPDIR/results/"
fi

# default raw output
if test -z "$TMPF"
then
 TMPF="$TMPDIR/raw_out.txt"
fi

# default stderr of tools
if test -z "$ERR"
then
 ERR="$TMPDIR/err.txt"
fi

#default stdout of tools
if test -z "$OUT"
then
 OUT="$TMPDIR/log.txt"
fi

#default packet capture interface
if test -z "$IFACE"
then
 IFACE="eth0"
fi

#default storage server
if test -z "$PEER"
then
 PEER=""
fi

#default capture file
if test -z "$CAPF"
then
 CAPF="$TMPDIR/cap"
fi

#default write/read image extension
if test -z "$BINEXT"
then
 BINEXT=".bin"
fi

if test -z "$SERVERAIDEDDELETE"
then
 SERVERAIDEDDELETE=0
fi

if test -z "$CLEANSERVERCACHE"
then
 CLEANSERVERCACHE=0
fi


# NOTICE: the order listed here WILL affect other tools.

# shared
# filesystem: nfs,iscsi,fuse,local
if test -z "$MLOP_FS"
then
 MLOP_FS="nfs iscsi fuse"
fi
# flag: O_DIRECT(d),O_SYNC(s),both(ds),none(def)
if test -z "$MLOP_FLAG"
then
 MLOP_FLAG="d s def ds"
fi
# read or write  NOTE: MUST write first, then read!
if test -z "$MLOP_RW"
then
 MLOP_RW="w r"
fi
# block_size (bytes)
if test -z "$MLOP_BS"
then
 MLOP_BS="4096"
fi

# batch specific
# tool type: c,dd
if test -z "$MLOP_TOOL"
then
 MLOP_TOOL="c dd"
fi
# n: n_loops/n_threads
if test -z "$MLOP_N"
then
 MLOP_N="10"
fi
# block count
if test -z "$MLOP_NBLK"
then
 MLOP_NBLK="1"
fi
# pattern: seq[uential], par[allel]
if test -z "$MLOP_PATTERN"
then
 MLOP_PATTERN="seq par"
fi

# worker specific
# number of worker threads
if test -z "$MLOP_N_WORKER"
then
 MLOP_N_WORKER="10"
fi
# job sizes
if test -z "$MLOP_JOB_SIZES"
then
 MLOP_JOB_SIZES="4096"
fi
# number of jobs per thread
if test -z "$MLOP_JOBS_PER_THREAD"
then
 MLOP_JOBS_PER_THREAD="1"
fi
# total number of jobs
if test -z "$MLOP_N_JOBS"
then
 MLOP_N_JOBS="100"
fi

# End of loop ranges


# see iotest.h
n_threads=10
n_loops=10

block_size=4096
job_size=4096

n_blocks=1
jobpt=1
base_jobsn=0
duration=$DURATION
n_jobs=$(($jobpt*$n_threads))

ext_flags=""
sync_sw=""
direct_sw=""
rw=""
quiet=""
target="$TMPDIR"
BUCKET_THRESHOLD=4096



func_status_line ()
{
 if test -z "$1"
 then
  return
 fi
 time=`date +"%D %T"`
 if test ! -z "$ERR"
 then
  echo "$time === $1" >>$ERR
 fi
 if test ! -z "$OUT"
 then
  echo "$time === $1" >>$OUT
 fi
 echo "$time === $1"
}

func_show ()
{
 # shared by loop/parallel, so use $n instead of $n_loops/$n_threads here
 echo tool:$tool fs:$fs flag:$flag n:$n bs:$block_size nblk:$n_blocks pattern:$pattern rw:$rw
}

func_worker_show ()
{
 echo fs:$fs flag:$flag n:$n_threads bs:$block_size job_sz:$job_size jobpt:$jobpt n_job:$n_jobs base:$base_jobsn du:$duration rw:$rw
}

func_fnames ()
{
 OUTF="${OUTPUTDIR}$tool-$fs-$flag-n$n-b$block_size-s$n_blocks-$pattern-$rw.txt"
 TMPF="${OUTPUTDIR}$tool-$fs-$flag-n$n-b$block_size-s$n_blocks-$pattern-$rw.out"
 CAPF="${OUTPUTDIR}$tool-$fs-$flag-n$n-b$block_size-s$n_blocks-$pattern-$rw.cap"
}

func_worker_fnames ()
{
 OUTF="${OUTPUTDIR}worker-$fs-$flag-n$n_threads-b$block_size-j$job_size-s$n_jobs-$rw.txt"
 TMPF="${OUTPUTDIR}worker-$fs-$flag-n$n_threads-b$block_size-j$job_size-s$n_jobs-$rw.out"
 CAPF="${OUTPUTDIR}worker-$fs-$flag-n$n_threads-b$block_size-j$job_size-s$n_jobs-$rw.cap"
}

func_worker_set_default_block_size ()
{
 block_size=$job_size
}

func_worker_check_block_size ()
{
 if test $block_size -gt $job_size -o $(($job_size % $block_size)) -ne 0
 then
  return 0
 fi
 return 1
}

# compute the job_size for block_size test
func_worker_bs_get_job_size ()
{
 # generally, 1000 times block_size
 job_size=$(($block_size*1000))
 # but, at least 80M
 if test "$job_size" -lt 83886080
 then
  job_size=83886080
 fi
 # and, at most 224M
 if test "$job_size" -gt 234881024
 then
  job_size=234881024
 fi
}

# param1: fs (optional, default to existing fs)
func_set_target_dir ()
{
 if test -z "$1"
 then
  _fs=$fs
 else
  _fs=$1
 fi

 case $_fs in
    nfs) TARGET=$NFSDIR ;;
  iscsi) TARGET=$ISCSIDIR ;;
   fuse) TARGET=$FUSEDIR ;;
  local) TARGET=$LOCALDIR ;;
      *) echo "ERR Invalid fs:$_fs"
         exit ;;
 esac
}

func_set_rw_switch ()
{
 case $rw in
  r) RW="-r" ;;
  w) RW="-w" ;;
  *) echo "ERR Invalid rw:$rw"
     exit ;;
 esac
}

func_set_dc_switch ()
{
 case $flag in
  def) DC="" ;;
    s) DC="-c" ;;
    d) DC="-d" ;;
   ds) DC="-c -d" ;;
    *) echo "ERR Invalid flag: $flag"
       exit ;;
 esac
}

func_set_worker_switches ()
{
 func_set_target_dir
 func_set_rw_switch
 func_set_dc_switch 
}

func_worker_build_cmd ()
{
 RW=
 DC=
 func_set_worker_switches
 CMD="$C_WORKER $RW -n $n_threads -b $block_size -j $job_size -s $n_jobs -k $base_jobsn -u $duration $DC -t $TARGET -q"
}

#deprecated
func_worker_do_work ()
{
 #XXX deprecated
 echo ERR deprecated func_worker_do_work call
 exit

 CMD=
 func_worker_build_cmd
 OUTF=
 TMPF=
 func_worker_fnames

 func_worker_show

 skip_round=
 if test -s $TMPF
 then
  if test ! -z "$RESUME"
  then
   echo INFO Resume mode, skipping this round.
   skip_round=1
  else
   echo INFO Deleting old tmp file $TMPF
   if test -z "$DRY" -o "$DRY" = "0"
   then
    rm $TMPF
   fi
  fi
 fi

 if test ! -z "$DRY" -a "$DRY" != "0"
 then
  echo OUTF:$OUTF TMPF:$TMPF CMD:$CMD
  skip_round=1
 fi

 if test ! -z "$skip_round"
 then
  return
 fi

 func_remove_old_write_and_clean

 func_worker_invoke_worker_c
}

# delete existing target files and clean cache
func_remove_old_write_and_clean ()
{
 func_set_target_dir
 if test "$rw" = "r"
 then
  echo ERR removing old on a read round? \(TARGET: $TARGET \)
  exit
 fi
 if test ! -x ./punlink
 then
  echo ERR punlink not found
  exit
 fi
 if test "$fs" = "fuse"
 then
  echo INFO not deleting old for Swift/FUSE.
  return
 fi

 func_check_target_dir $fs
 echo "INFO Write round, removing old $BINEXT(s)"

 _aid_func=`type func_server_aided_delete | grep function`
 if test ! -z "$_aid_func" -a ! -z "$SERVERAIDEDDELETE" -a "$SERVERAIDEDDELETE" != "0"
 then
  func_server_aided_delete
 else
  CMD="./punlink -t $TARGET -k $base_jobsn -s $n_jobs -n 32 -q"
  if test ! -z "$DRY" -a "$DRY" != "0"
  then
   echo CMD: $CMD
  else
   $CMD 2>&1
  fi
 fi
 func_clean_cache
}

# actually activates worker-c.sh
func_worker_invoke_worker_c ()
{
 CMD=
 func_worker_build_cmd
 OUTF=
 TMPF=
 func_worker_fnames
 func_check_target_dir $fs

 if test ! -z "$DRY" -a "$DRY" != "0"
 then
  echo OUTF:$OUTF TMPF:$TMPF CMD:$CMD
  return
 fi

 TMPF="$TMPF" $CMD > $OUTF 2>&1
}

# param1: fs
func_check_fs ()
{
 if test ! -z "$DRY" -a "$DRY" != "0"
 then
  return
 fi

 _fs=$1

 case $_fs in
  nfs)
   mount=`mount | grep $NFSMOUNT`
   ;;
  iscsi)
   mount=`mount | grep $ISCSIMOUNT`
   ;;
  fuse)
   mount=`mount | grep $FUSEMOUNT`
   ;;
  local)
   mount="LOCAL"
   ;;
  *)
   echo ERR Check-FS: Invalid FS: $_fs
   exit
   ;;
 esac

 if test -z "$mount"
 then
  echo ERR Check-FS: $_fs not mounted.
  exit
 fi
}

# param1: fs
func_check_target_dir ()
{
 if test ! -z "$DRY" -a "$DRY" != "0"
 then
  return
 fi

 _TARGET="$TARGET"
 _fs="$fs"
 fs=$1
 func_check_fs $fs
 func_set_target_dir $fs
 if test ! -d "$TARGET"
 then
  echo ERR Check-FS: $TARGET not found or invalid.
  exit
 fi
 TARGET=$_TARGET
 fs=$_fs
}

# param1: fs
func_prepare_target_fs ()
{
 # Warn up with 100 x 1M files
 _n_jobs=100
 _job_size=1048576

 if test ! -z "$FSHOT" -a "FSHOT" != "0"
 then
  echo INFO FS is HOT, not preparing fs:$1
  return
 fi

 if test ! -z "$DRY" -a "$DRY" != "0"
 then
  echo INFO Prepare FS: $1
  return
 fi

 _fs=$fs
 fs=$1

 echo INFO Preparing FS: $fs
 case $fs in
  nfs)
   umount $NFSMOUNT
   mount $NFSMOUNT
   ;;
  iscsi)
   umount $ISCSIMOUNT
   mount $ISCSIMOUNT
   ;;
  fuse)
   fusermount -u $FUSEMOUNT
   $CFS $FUSEMOUNT
   ;;
  local)
   ;;
  *)
   echo ERR Prepare-FS: Invalid FS: $fs
   exit
   ;;
 esac

 func_check_target_dir $fs
 func_set_target_dir

 echo INFO Removing target $BINEXT files in $TARGET
 ./punlink -t $TARGET -s $_n_jobs -n 8 -q 1>&2
 sync
 echo INFO Warm up: writing
 $DD_SEQ -w -t $TARGET -n $_n_jobs -b $_job_size -c -q 1>&2
 func_clean_client_cache
 echo INFO Warm up: reading
 $DD_SEQ -r -t $TARGET -n $_n_jobs -b $_job_size -c -q 1>&2
 echo INFO Removing target $BINEXT files again in $TARGET
 ./punlink -t $TARGET -s $_n_jobs -n 8 -q 1>&2
 func_clean_client_cache
 echo INFO Warm up: sleep
 sleep 10
 echo INFO Preparation of FS: $fs done.
 sleep 2

 fs=$_fs
}

func_prepare_output_dir ()
{
 if test ! -z "$DRY" -a "$DRY" != "0"
 then
  return
 fi

 if test ! -d $OUTPUTDIR
 then
  mkdir $OUTPUTDIR
 else
  echo INFO $OUTPUTDIR already exists, overwritting!
 fi

 if test ! -d $OUTPUTDIR || test ! -w $OUTPUTDIR || test ! -x $OUTPUTDIR
 then
  echo ERR Unable to set up output directory $OUTPUTDIR.
  exit
 fi

 echo INFO Outputs go to $OUTPUTDIR
}

func_clean_client_cache ()
{
  echo INFO Clean client cache
  if test -z "$DRY" -o "$DRY" = "0"
  then
   sync
   sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
   sleep 1
  fi
}

func_clean_cache ()
{
  echo INFO Clean cache
  func_clean_client_cache
  _srv_func=`type func_clean_server | grep function`
  if test ! -z "$_srv_func"
  then
   func_clean_server
  fi
}

# param1: flag to add
func_add_ext_flag ()
{
  if test -n "$ext_flags"; then
    ext_flags="${ext_flags},"
  fi
  ext_flags="${ext_flags}$1"
  shift
}


func_print_timestamp ()
{
  # seconds nanoseconds
  date +"%s%N"
}

func_check_tmpf_at_start ()
{
  if test -z "$TMPF"
  then
    echo ERR TMPF not set?
    exit
  fi
  if test -e $TMPF
  then
    echo INFO TMPF\($TMPF\) exists, removing it.
    rm -f $TMPF
  fi
}

func_worker_per_thread_stat ()
{
 P_TIME=0
 P_THP=0

 if test ! -f $TMPF
 then
  return
 fi

 i=0
 while test $i -lt $n_threads
 do
  lines_to_tail=$(($n_threads+3-$i))
  line=`tail -n $lines_to_tail $TMPF | head -n 1`
  serviced_req=`echo $line | cut -d\  -f 1`
  elapsed=`echo $line | cut -d\  -f 2`
  if test $elapsed -gt 0
  then
   P_TIME=$(($P_TIME+$elapsed))
   P_THP=`echo "scale=9; $P_THP+(($serviced_req*$job_size/1048576)/($elapsed/1000000000))" | bc`
   if test $elapsed -gt $P_TIME
   then
    P_TIME=$elapsed
   fi
  fi
  i=$(($i+1))
 done
 P_TIME=`echo "scale=9; $P_TIME / 1000000000" | bc`
}

# Check that current task size is not too big.
# param1: pattern/worker
# return 1: too big
func_check_task_size ()
{
 case $1 in
  seq) task_size=$(($n_loops*$block_size*$n_blocks)) ;;
  par) task_size=$(($n_threads*$block_size*$n_blocks)) ;;
  worker) task_size=$(($job_size*$n_jobs)) ;;
  *) task_size=0 ;;
 esac

 if test $task_size -gt $MAX_TASK_SIZE
 then
  return 1
 fi

 total_task_size=$(($total_task_size + $task_size))

 return 0
}

func_start_capture ()
{
 echo -n INFO Starting tcpdump ...
 # Exclude SSH here because clean_cache may incur SSH traffic if
 # server cache is also purged.
 FILTER="tcp and port not ssh"
 if test ! -z "$PEER"
 then
  FILTER="$FILTER and ip host $PEER"
 fi
 CMD="sudo tcpdump -i $IFACE -w $CAPF $FILTER"
 if test ! -z "$DRY"  -a "$DRY" != "0"
 then
  echo $CMD
  return
 fi
 $CMD & >/dev/null 2>&1 &
 # tcpdump takes some time to start ...
 sleep 1
 echo \ capf:$CAPF
}

func_stop_capture ()
{
 echo -n INFO Stopping tcpdump ...

 if test ! -z "$DRY" -a "$DRY" != "0"
 then
  echo nothing to do.
  return
 fi

 sudo pkill tcpdump
 user=`id -un`
 sudo chown $user $CAPF
 echo \ pcap file: $CAPF
 tshark -r $CAPF -q -z io,stat,0 2>/dev/null
}

# param1: fs
func_set_default_dir ()
{
 _fs=$1
 case $_fs in
  iscsi) ISCSIDIR="$DEFISCSIDIR" ;;
  nfs) NFSDIR="$DEFNFSDIR" ;;
  fuse) FUSEDIR="$DEFFUSEDIR" ;;
  local) LOCALDIR="$DEFLOCALDIR" ;;
 esac
}

# param1: fs
# param2: job_size
# Set fs-DIR to prepared image path
func_set_read_dir ()
{
 _fs=$1
 _job_size=$2

 if test $_fs = "" -o $_job_size = ""
 then
  echo ERR set_read_dir: invocation error: _fs:$_fs _job_size:$_job_size
  exit
 fi

 if test "$rw" = "w"
 then
  func_set_default_dir $_fs
 else
  case $_fs in
   fuse)
    FUSEDIR="${FUSEMOUNT}${FUSEBASEDIR}/${_job_size}"
    ;;
   nfs)
    NFSDIR="${NFSMOUNT}${NFSBASEDIR}/${_job_size}"
    ;;
   iscsi)
    ISCSIDIR="${ISCSIMOUNT}${ISCSIBASEDIR}/${_job_size}"
    ;;
   local)
    LOCALDIR="${LOCALBASEDIR}/${_job_size}"
    ;;
   *) echo ERR set_read_dir: unsupported fs:$_fs ; exit ;;
  esac
 fi

 func_set_target_dir $_fs
}


#param1: TMPDIR (optional)
func_set_run_out_dir ()
{
 if test ! -z "$1"
 then
  TMPDIR="$1"
 fi

 # Data output
 OUTPUTDIR="$TMPDIR/results/"
 # Raw output
 TMPF="$TMPDIR/raw_out.txt"
 # stderr
 ERR="$TMPDIR/err.txt"
 # stdout
 OUT="$TMPDIR/log.txt"
}

func_get_net_stat ()
{
 str=`grep $IFACE /proc/net/dev`
 echo -n NET\ 
 if test ! -z "$str"
 then
  read rxbytes rxpkt txbytes txpkt <<END
 $(echo $str | awk '{print $2 " " $3 " " $10 " " $11}')
END
  echo $(($rxpkt+$txpkt)) $(($rxbytes+$txbytes))
 else
  echo 0 0
 fi
}

func_get_cpu_stat ()
{
 str=`head -n 1 /proc/stat`
 echo -n CPU\ 
 if test ! -z "$str"
 then
  read usr ni sys idle io <<END
 $(echo $str | awk '{print $2 " " $3 " " $4 " " $5 " " $6}')
END
  echo $(($usr+$ni+$sys)) $(($usr+$ni+$sys+$idle+$io))
 else
  echo 0 0
 fi
}

# param1 fs
# param2 rw
# param3 job_size
# param4 n_jobs
func_create_buckets ()
{
 _fs=$fs
 fs=$1
 _rw=$rw
 rw=$2
 _job_size=$job_size
 job_size=$3
 _n_jobs=$n_jobs
 n_jobs=$4
 _target=$target

 if test $n_jobs -le $BUCKET_THRESHOLD
 then
  echo INFO create_buckets: within threshold, no buckets.
  return
 fi

 if test $rw = "w"
 then
  func_set_target_dir $fs
 else
  func_set_read_dir $fs $job_size
 fi

 i=0
 num_buckets=$(($n_jobs/$BUCKET_THRESHOLD))
 while test $i -le $num_buckets
 do
  if test -z "$DRY" -o "$DRY" = "0"
  then
   mkdir -p ${TARGET}/${i}
  else
   echo create_bucket: mkdir -p ${TARGET}/${i}
  fi
  i=$(($i+1))
 done

 fs=$_fs
 rw=$_rw
 job_size=$_job_size
 n_jobs=$_n_jobs
 target=$_target
}

