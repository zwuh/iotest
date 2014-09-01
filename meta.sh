#!/bin/sh

. ./iotest.inc.sh

# Really carry out the metadata op
# param1: op
# param2: iterations
func_action ()
{
 op=$1
 _n=$2

 i=0
 while test $i -lt $_n
 do
  if test "$op" = "mkdir" -o "$op" = "rmdir"
  then
   CMD="$op $TARGET/${i}.dir"
  elif test "$op" = "touch" -o "$op" = "unlink"
  then
   CMD="$op $TARGET/${i}${BINEXT}"
  elif test "$op" = "ls"
  then
   CMD="ls $TARGET"
  fi
  if test -z "$DRY" -o "$DRY" = "0"
  then
   $CMD > /dev/null
  else
   echo CMD: $CMD
   break
  fi
  i=$(($i+1))
 done
}

#param1: op
#NOTE: ls is always done only once!
func_do_work ()
{
 op=$1
 #echo INFO Doing $op on $fs \($TARGET\) for $n_loops times.
 echo fs:$fs op:$op n_jobs:$n_loops

 if test $op = "ls"
 then
  echo INFO ls is done only once.
  _n=1
  # Clean CloudFuse directory cache, otherwise nothing will be transmitted.
  if test $fs = "fuse"
  then
   echo INFO Re-mounting CloudFuse mount to clean directory cache.
   if test -z "$DRY" -o "$DRY" = "0"
   then
    fusermount -u $FUSEMOUNT
    $CFS $FUSEMOUNT
   fi
  fi
 else
  _n=$n_loops
 fi

 func_clean_cache
 CAPF="${OUTPUTDIR}$fs-$op-$n_loops.cap"
 func_start_capture
 start_ts=`func_print_timestamp`
 func_get_cpu_stat
 func_get_net_stat

 func_action "$op" "$_n"

 if test -z "$DRY" -o "$DRY" = "0"
 then
  sync
 fi
 end_ts=`func_print_timestamp`
 echo -n END-
 func_get_cpu_stat
 echo -n END-
 func_get_net_stat
 func_stop_capture
 rm -f $CAPF
 elapsed_ns=$(($end_ts-$start_ts))
 elapsed=`echo "scale=9; $elapsed_ns / 1000000000" | bc`
 echo Elapsed: $elapsed sec
}

#
# main
# param1: fs
# param2: rounds
# param3: op
#

if test -z "$1"
then
 echo param1:fs \[param2:n_loops \[param3:op\]\]
 exit
fi

fs=$1

case $fs in
 iscsi) ISCSIDIR="${ISCSIMOUNT}${ISCSIBASEDIR}/meta" ;;
 nfs) NFSDIR="${NFSMOUNT}${NFSBASEDIR}/meta" ;;
 fuse) FUSEDIR="${FUSEMOUNT}${FUSEBASEDIR}/meta" ;;
 local) LOCALDIR="${LOCALBASEDIR}/meta" ;;
 *) echo ERR meta.sh unsupported fs: $fs ; exit ;;
esac

func_check_target_dir $fs
func_set_target_dir

echo INFO meta test target: $TARGET
if test ! -x "$TARGET"
then
 echo ERR meta target inaccessible.
 exit
fi

if test ! -z "$2"
then
 n_loops=$2
else
 n_loops=1
fi

if test ! -z "$3"
then
 op=$3
fi
 
func_prepare_output_dir

if test ! -z "$op"
then
 func_do_work "$op"
else
# echo INFO meta pre-run clean up
# func_action "unlink" "$n_loops" >/dev/null 2>&1
# func_action "rmdir" "$n_loops" >/dev/null 2>&1
 
 func_do_work "mkdir"
 func_do_work "touch"
 #NOTE: ls is always done only once!
 func_do_work "ls"
 func_do_work "unlink"
 func_do_work "rmdir"
fi

