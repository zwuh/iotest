#!/bin/sh

. ./iotest.inc.sh

size=$(($block_size*$n_blocks))

func_process_arg ()
{
  while getopts n:c:b:s:a:u:k:rwq f
  do
    case $f in
      a) AUTHURL=$OPTARG ;;
      u) AUTHUSER=$OPTARG ;;
      k) AUTHKEY=$OPTARG ;;
      n) n_threads=$OPTARG ;;
      c) SWIFTCONTAINER=$OPTARG ;;
      b) block_size=$OPTARG ;;
      s) n_blocks=$OPTARG ;;
      r) rw="read" ;;
      w) rw="write" ;;
      q) quiet="true" ;;
      *) cat <<\EOF
Usage: parallel-swift.sh [-r|-w] [-n n_threads] [-c container]
        [-b block_size] [-s n_blocks] [-a authurl] [-u authuser] [-k authkey]
        [-q]uiet
EOF
      exit 1;;
    esac
  done
  shift `expr $OPTIND - 1`

  if test -z "$rw"; then
    rw="write"
  fi

  size=$(($n_blocks*$block_size))
}

func_print_conf ()
{
 if test -z "$quiet"; then
  echo Configuration:
  echo \ number of threads: $n_threads
  echo \ size: $size \(block_size:$block_size n_blocks:$n_blocks\)
  echo \ container: $SWIFTCONTAINER
  echo \ authurl: $AUTHURL
  echo \ authuser: $AUTHUSER
  echo \ authkey: $AUTHKEY
  echo \ read/write: $rw
 fi
}

func_prepare_image ()
{
 if test "$rw" = "write"; then
   dd if=/dev/zero of=swift.img bs=$size count=1 1>>$TMPF 2>&1
   status=$?
   if test $status -ne 0; then
     echo "Error: cannot create swift.img : $status" >&2
     exit
   fi
 fi
}

func_do_io_test_swift ()
{
 i=0

 pids=
 pid=

 while test $i -lt $n_threads
 do
  #echo Starting thread $i
  if test "$rw" = "write"
  then
   ln -s swift.img ${i}${BINEXT}
   (swift -A $AUTHURL -U $AUTHUSER -K $AUTHKEY upload $SWIFTCONTAINER  ${i}${BINEXT} \
          1>>$TMPF 2>&1) &
  else
   (swift -A $AUTHURL -U $AUTHUSER -K $AUTHKEY download $SWIFTCONTAINER ${i}${BINEXT} \
          -o /dev/null 1>>$TMPF 2>&1) &
  fi
  pids="$pids $!"
  i=$(($i+1))
 done

 for p in $pids;
 do
  wait $p
  last_status=$?
  if test $last_status -ne 0; then
    echo "Error: swift returned with status $last_status" >&2
  fi
 done

 if test "$rw" = "write"
 then
  i=0
  while test $i -lt $n_threads
  do
   unlink ${i}${BINEXT}
   i=$(($i+1))
  done
 fi
}

#
# main
#

if test ! -z "$DRY" -a "$DRY" != "0"
then
 echo ERR parallel-swift.sh does not support dry mode.
 exit
fi

func_process_arg $@
func_print_conf
func_check_tmpf_at_start

old_pwd=`pwd`
cd $TMPDIR
if test $? -ne 0; then
 echo "Unable to cd to TMP:$TMPDIR" >&2
 exit
fi
func_prepare_image
start_ts=`func_print_timestamp`
func_do_io_test_swift
end_ts=`func_print_timestamp`
if test "$rw" = "write"; then
  unlink swift.img
fi
cd $old_pwd

elapsed_ns=$(($end_ts-$start_ts))
elapsed=`echo "scale=9; $elapsed_ns / 1000000000" | bc`
total_bytes=$(($block_size*$n_blocks*$n_threads))
throughput=`echo "scale=9; $total_bytes / 1048576 / $elapsed" | bc`

if test -z "$quiet"; then
 echo Total bytes: $total_byes
 echo internal sec: -1 sec
 echo internal thp: -1 MiBps
 echo outside \ sec: $elapsed sec
 echo outside \ thp: $throughput MiBps
else
 echo -1
 echo -1
 echo $elapsed
 echo $throughput
fi

