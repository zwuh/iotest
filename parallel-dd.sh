#!/bin/sh

. ./iotest.inc.sh


func_process_arg ()
{
  while getopts n:t:b:s:dcrwq f
  do
    case $f in
      n) n_threads=$OPTARG ;;
      t) target=$OPTARG ;;
      b) block_size=$OPTARG ;;
      s) n_blocks=$OPTARG ;;
      d) func_add_ext_flag "direct"
         direct_sw=-d ;;
      c) func_add_ext_flag "sync"
         sync_sw=-c ;;
      r) if test -z "$rw"; then rw="read"; fi ;;
      w) rw="write" ;;
      q) quiet="true" ;;
      *) cat <<\EOF
Usage: parallel-dd.sh [-r|-w] [-n n_threads] [-t target_dir]
                      [-b block_size] [-s num_blocks]
                      [-d] O_DIRECT [-c] O_SYNC [-q]uiet
EOF
      exit 1;;
    esac
  done
  shift `expr $OPTIND - 1`

  if test -z "$rw"; then
    rw="write"
  fi
}

func_print_conf ()
{
 if test -z "$quiet"; then
  echo Configuration:
  echo \ number of threads: $n_threads
  echo \ block size: $block_size
  echo \ number of blocks: $n_blocks
  echo \ target: $target
  echo \ ext_flags to dd: $ext_flags
  echo \ read/write: $rw
 fi
}


func_do_io_test_dd ()
{
 iflag=
 oflag=
 if test -n "$ext_flags"; then
  iflag="iflag=$ext_flags"
  oflag="oflag=$ext_flags"
 fi

 old_pwd=`pwd`
 cd $target
 if test $? -ne 0; then
   echo Error: Unable to cd to target.
   exit
 fi

 pids=

 i=0
 while test $i -lt $n_threads
 do
  #echo Starting thread $i
  if test "$rw" = "write"; then
   (dd if=/dev/zero of=${i}${BINEXT} bs=$block_size count=$n_blocks $oflag \
    1>>$TMPF 2>&1) &
  else
   (dd of=/dev/null if=${i}${BINEXT} bs=$block_size count=$n_blocks $iflag \
    1>>$TMPF 2>&1) &
  fi
  pids="$pids $!"
  i=$(($i+1))
 done

 for p in $pids;
 do
  wait $p
  last_status=$?
  if test $last_status -ne 0; then
    echo Error: dd returned with status $last_status
  fi
 done
}


#
# main
#

if test ! -z "$DRY" -a "$DRY" != "0"
then
 echo ERR parallel-dd.sh does not support dry mode.
 exit
fi

func_process_arg $@
func_print_conf
func_check_tmpf_at_start

start_ts=`func_print_timestamp`
func_do_io_test_dd
end_ts=`func_print_timestamp`

total_bytes=$(($block_size*$n_blocks*$n_threads))

elapsed_ns=$(($end_ts-$start_ts))
elapsed=`echo "scale=9; $elapsed_ns / 1000000000" | bc`
throughput=`echo "scale=9; $total_bytes / 1048576 / $elapsed" | bc`

if test -z "$quiet"; then
 echo Total bytes: $total_bytes
 echo dd-internal sec: -1 sec
 echo dd-internal thp: -1 MiBps
 echo dd outside \ sec: $elapsed sec
 echo dd outside \ thp: $throughput MiBps
else
 echo -1
 echo -1
 echo $elapsed
 echo $throughput
fi

