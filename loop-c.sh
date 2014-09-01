#!/bin/sh

. ./iotest.inc.sh

LOOP=./loop


func_process_arg ()
{
  while getopts n:t:b:s:dcrwq f
  do
    case $f in
      n) n_loops=$OPTARG ;;
      t) target=$OPTARG ;;
      b) block_size=$OPTARG ;;
      s) n_blocks=$OPTARG ;;
      d) func_add_ext_flag "O_DIRECT"
         direct_sw=-d ;;
      c) func_add_ext_flag "O_SYNC"
         sync_sw=-c ;;
      r) if test -z "$rw"; then rw="read"; fi ;;
      w) rw="write" ;;
      q) quiet="true" ;;
      *) cat <<\EOF
Usage:  loop-c.sh [-r|-w] [-n n_loops] [-t target_dir]
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
  echo \ ext_flags to loop: $ext_flags
  echo \ read/write: $rw
 fi
}


#
# main
#

if test ! -z "$DRY" -a "$DRY" != "0"
then
 echo ERR loop-c.sh does not support dry mode.
 exit
fi

func_process_arg $@
func_print_conf
func_check_tmpf_at_start

if test "$rw" = "write"; then
 $LOOP -q -w -n $n_loops -b $block_size -s $n_blocks -t $target \
       $sync_sw $direct_sw 1>>$TMPF 2>&1
else
 $LOOP -q -r -n $n_loops -b $block_size -s $n_blocks -t $target \
       $sync_sw $direct_sw 1>>$TMPF 2>&1
fi

total_bytes=$(($block_size*$n_blocks*$n_loops))

int_elapsed_ns=`tail -n 2 $TMPF | head -n 1`
int_elapsed=`echo "scale=9; $int_elapsed_ns / 1000000000" | bc`
int_throughput=`echo "scale=9; $total_bytes / 1048576 / $int_elapsed" | bc`

elapsed_ns=`tail -n 1 $TMPF`
elapsed=`echo "scale=9; $elapsed_ns / 1000000000" | bc`
throughput=`echo "scale=9; $total_bytes / 1048576 / $elapsed" | bc`

if test -z "$quiet"; then
 echo Total bytes: $total_bytes
 echo c-internal sec: $int_elapsed sec
 echo c-internal thp: $int_throughput MiBps
 echo c outside \ sec: $elapsed sec
 echo c outside \ thp: $throughput MiBps
else
 echo $int_elapsed
 echo $int_throughput
 echo $elapsed
 echo $throughput
fi

