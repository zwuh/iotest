#!/bin/sh

. ./iotest.inc.sh

WORKER_EXE=./worker
fuse_hack_sw=

# NOTICE:
# The semantic of block_size and n_blocks changed here.
# With pthread worker pattern, it simulates a pool of n_threads workers
# processing n_blocks of I/O jobs each of size block_size.
func_process_arg ()
{
  while getopts n:t:b:s:j:k:u:dcrwfq f
  do
    case $f in
      n) n_threads=$OPTARG ;;
      t) target=$OPTARG ;;
      b) block_size=$OPTARG ;;
      s) n_jobs=$OPTARG ;;
      j) job_size=$OPTARG ;;
      k) base_jobsn=$OPTARG ;;
      u) duration=$OPTARG ;;
      d) func_add_ext_flag "O_DIRECT"
         direct_sw=-d ;;
      c) func_add_ext_flag "O_SYNC"
         sync_sw=-c ;;
      r) if test -z "$rw"; then rw="read"; fi ;;
      w) rw="write" ;;
      f) fuse_hack_sw="-f" ;;
      q) quiet="true" ;;
      *) cat <<\EOF
Usage: worker-c.sh [-r|-w] [-n n_workers] [-t target_dir]
                   [-b block_size] [-j job_size] [-s num_jobs]
                   [-k base_jobsn] [-u duration]
                   [-d] O_DIRECT [-c] O_SYNC [-q]uiet [-f]use
EOF
      exit 1;;
    esac
  done
  shift `expr $OPTIND - 1`

  if test -z "$rw"; then
    rw="write"
  fi

  if test $(($job_size % $block_size)) -ne 0
  then
   echo job_size must be a mutiple of block_size.
   exit
  fi
}

func_print_conf ()
{
 if test -z "$quiet"; then
  echo Configuration:
  echo \ number of workers: $n_threads
  echo \ job size: $job_size
  echo \ block size: $block_size
  echo \ number jobs: $n_jobs
  echo \ base job sn: $base_jobsn
  echo \ duration: $duration sec
  echo \ target: $target
  echo \ ext_flags to worker: $ext_flags
  echo \ read/write: $rw
 fi
}


#
# main
#

if test ! -z "$DRY" -a "$DRY" != "0"
then
 echo ERR worker-c.sh does not support dry mode.
 exit
fi

func_process_arg $@
func_print_conf
func_check_tmpf_at_start

#echo -n "$BINEXT files in target: " >>$TMPF
#echo `ls $target/*${BINEXT} | wc -l`  >>$TMPF

if test "$rw" = "write"; then
 $WORKER_EXE -q -w -n $n_threads -b $block_size -j $job_size -s $n_jobs -t $target \
             -k $base_jobsn -u $duration $sync_sw $direct_sw $fuse_hack_sw 1>>$TMPF 2>&1
else
 $WORKER_EXE -q -r -n $n_threads -b $block_size -j $job_size -s $n_jobs -t $target \
             -k $base_jobsn -u $duration $sync_sw $direct_sw $fuse_hack_sw 1>>$TMPF 2>&1
fi

P_TIME=
P_THP=
func_worker_per_thread_stat

total_serviced=`tail -n 3 $TMPF | head -n 1`
# NOTE the semantic change!
total_bytes=$(($job_size*$total_serviced))

int_elapsed_ns=`tail -n 2 $TMPF | head -n 1`
int_elapsed=`echo "scale=9; $int_elapsed_ns / 1000000000" | bc`
int_throughput=`echo "scale=9; $total_bytes / 1048576 / $int_elapsed" | bc`

elapsed_ns=`tail -n 1 $TMPF`
elapsed=`echo "scale=9; $elapsed_ns / 1000000000" | bc`
throughput=`echo "scale=9; $total_bytes / 1048576 / $elapsed" | bc`


if test -z "$quiet"; then
 echo Total bytes: $total_bytes \($total_serviced/$n_jobs\)
 echo per-thread sec: $P_TIME sec
 echo per-thread thp: $P_THP MiBps
 echo c-internal sec: $int_elapsed sec
 echo c-internal thp: $int_throughput MiBps
 echo c outside \ sec: $elapsed sec
 echo c outside \ thp: $throughput MiBps
else
 echo $P_TIME
 echo $P_THP
 echo $int_elapsed
 if test $total_serviced -ne $n_jobs
 then
  echo -n \-
 fi
 echo $int_throughput
 echo $elapsed
 if test $total_serviced -ne $n_jobs
 then
  echo -n \-
 fi
 echo $throughput
fi

