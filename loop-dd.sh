#!/bin/sh

. ./iotest.inc.sh


func_process_arg ()
{
  while getopts n:t:b:s:dcrwq f
  do
    case $f in
      n) n_loops=$OPTARG ;;
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
Usage: loop-dd.sh [-r|-w] [-n n_loops] [-t target_dir]
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
  echo \ number of iterations: $n_loops
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

 if test "$rw" = "write"; then
  dd if=/dev/zero of=${i}${BINEXT} bs=$block_size count=$n_blocks $oflag
 else
  dd of=/dev/null if=${i}${BINEXT} bs=$block_size count=$n_blocks $iflag
 fi
}

#
# main
#

if test ! -z "$DRY" -a "$DRY" != "0"
then
 echo ERR loop-dd.sh does not support dry mode.
 exit
fi

func_process_arg $@
func_print_conf
func_check_tmpf_at_start

start_ts=`func_print_timestamp`
i=0
while test $i -lt $n_loops
do
 func_do_io_test_dd >> $TMPF 2>&1
 i=$(($i+1))
done
end_ts=`func_print_timestamp`

total_bytes=$(($block_size*$n_blocks*$n_loops))
dd_sec_sum=0
dd_timestamps=`grep -e copied $TMPF | cut -d\  -f 6 | sed "s/,/./" | sed "s/[eE]+*/\*10\\^/"`
for t in $dd_timestamps
do
  dd_sec_sum=`echo "scale=9; $dd_sec_sum+$t" | bc`
done
dd_throughput=`echo "scale=9; $total_bytes / 1048576 / $dd_sec_sum" | bc`

elapsed_ns=$(($end_ts-$start_ts))
elapsed=`echo "scale=9; $elapsed_ns / 1000000000" | bc`
throughput=`echo "scale=9; $total_bytes / 1048576 / $elapsed" | bc`

if test -z "$quiet"; then
 echo Total bytes: $total_bytes
 echo dd-internal sec: $dd_sec_sum sec
 echo dd-internal thp: $dd_throughput MiBps
 echo dd outside \ sec: $elapsed sec
 echo dd outside \ thp: $throughput MiBps
else
 echo $dd_sec_sum
 echo $dd_throughput
 echo $elapsed
 echo $throughput
fi

