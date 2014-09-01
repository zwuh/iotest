#!/bin/sh

. ./iotest.inc.sh

func_do_work ()
{
 func_worker_show
 func_worker_fnames
 func_clean_cache
 func_get_cpu_stat
 func_get_net_stat
 func_worker_invoke_worker_c
 echo -n END-
 func_get_cpu_stat
 echo -n END-
 func_get_net_stat
 ts_before_clean_cache=`func_print_timestamp`
 func_clean_cache
 ts_after_clean_cache=`func_print_timestamp`
 echo CLEAN-NS: $(($ts_after_clean_cache - $ts_before_clean_cache))
 echo -n CLEAN-
 func_get_cpu_stat
 echo -n CLEAN-
 func_get_net_stat
 if test -z "$DRY" -o "$DRY" = "0"
 then
  echo -n Elapsed:\ 
  tail -n 2 $OUTF | head -n 1
  echo -n Throughput:\ 
  tail -n 1 $OUTF
 fi
}

func_prepare_round ()
{
 echo INFO bsprepare $fs $rw
 block_size=$job_size
 flag="def"
 # We will rename them later
 OUTF=
 TMPF=
 func_worker_invoke_worker_c
 if test -z "$DRY" -o "$DRY" = "0"
 then
  mv $OUTF ${OUTPUTDIR}bsprepare-$fs-${rw}.txt
  mv $TMPF ${OUTPUTDIR}bsprepare-$fs-${rw}.out
 else
  echo CMD rename OUTF and TMPF to ${OUTPUTDIR}bsprepare-$fs-${rw}.txt/out
 fi
 func_clean_cache
}

# param1: fs
# Assumption: job_size, n_threads, n_jobs are fixed.
func_fs_bs_round ()
{
 fs="$1"
 func_prepare_target_fs "$fs" >>$OUT 2>>$ERR
 func_set_default_dir "$fs"
 func_set_target_dir
 # Write
 rw="w"
 func_status_line "Round $fs write"
 # Create the image for use.
 # Note that we write into existing image file.
 func_prepare_round >>$OUT 2>>$ERR
 for flag in $MLOP_FLAG
 do
  for block_size in $MLOP_BS
  do
   func_do_work >>$OUT 2>>$ERR
  done
 done
 # Read
 rw="r"
 func_status_line "Round $fs read"
 # Use the same image, but read it once as preparation.
 func_prepare_round >>$OUT 2>>$ERR
 for flag in $MLOP_FLAG
 do
  for block_size in $MLOP_BS
  do
   func_do_work >>$OUT 2>>$ERR
  done
 done
 # Delete the image
 rw="w"
 func_remove_old_write_and_clean >>$OUT 2>>$ERR
}

#
# main
# This program tests different block_size's.
#

func_prepare_output_dir

n_jobs=1
n_threads=1
duration=0
job_size=16777216
MLOP_BS="16777216 4194304 1048576 262144 65536 16384 4096"

func_status_line "Block-Size test n_jobs:$n_jobs n_threads:$n_threads duration:$duration job_size:$job_size"

MLOP_FLAG="d s"
func_fs_bs_round "iscsi"
func_fs_bs_round "nfs"
#func_fs_bs_round "local"
MLOP_FLAG="def"
func_fs_bs_round "fuse"

func_status_line "End of Block-Size test"

