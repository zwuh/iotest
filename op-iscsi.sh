#!/bin/sh

. ./iotest.inc.sh

# NOTE same as that of run-worker-bs.sh
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

# param1: fs
func_one_file_round ()
{
 fs="$1"
 func_prepare_target_fs "$fs" >>$OUT 2>>$ERR
 func_set_default_dir "$fs"
 func_set_target_dir
 func_status_line "Round $fs"
 for job_size in $MLOP_JOB_SIZES
 do
  block_size=$job_size
  for flag in $MLOP_FLAG
  do
   rw="w"
   # Before we write, we remove existing file if there is one (except for FUSE).
   # Well, using this might be an over kill ...
   func_remove_old_write_and_clean >>$OUT 2>>$ERR
   func_do_work >>$OUT 2>>$ERR

   rw="r"
   # When we read, we read the file just written.
   func_do_work >>$OUT 2>>$ERR
  done
  # Before we finish with this job_size, delete written files.
  rw="w"
  func_remove_old_write_and_clean >>$OUT 2>>$ERR
 done
}

#
# main
# This program tests different job_size's.
#

func_prepare_output_dir

n_jobs=1
n_threads=1
duration=0
MLOP_JOB_SIZES="67108864 16777216 4194304 1048576 262144 65536 16384 4096"
 
func_status_line "One-File test n_jobs:$n_jobs n_threads:$n_threads duration:$duration"

MLOP_FLAG="d s"
func_one_file_round "iscsi"

func_status_line "End of One-File test"

