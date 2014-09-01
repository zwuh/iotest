#!/bin/sh


# To be included from a script which also includes iotest.inc.sh

func_file_test_do_work ()
{
 func_worker_show
 func_worker_fnames
 func_set_read_dir $fs $job_size
 # Always clean client cache before read/write round
 if test "$rw" = "w" -a "$fs" != "fuse"
 then
  # Do not delete existing files for FUSE-write
  # delete for Swift is slow but create/replace is the same.
  func_remove_old_write_and_clean
 else
  func_clean_cache
 fi
#TODO disabled tcpdump
# func_start_capture
 func_get_cpu_stat
 func_get_net_stat
 if test -z "$DRY" -o "$DRY" = "0"
 then
  func_worker_invoke_worker_c
 else
  CMD=
  func_worker_build_cmd
  echo CMD: $CMD
 fi
 echo -n END-
 func_get_cpu_stat
 echo -n END-
 func_get_net_stat
# func_stop_capture
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
  rm -f $CAPF
  echo -n Serviced: \ 
  tail -n 3 $TMPF | head -n 1
  echo -n Elapsed:\ 
  tail -n 2 $OUTF | head -n 1
  echo -n Throughput:\ 
  tail -n 1 $OUTF
 fi
 # Delete written files after a write round
 if test "$rw" = "w" -a "$fs" != "fuse"
 then
  func_remove_old_write_and_clean
 fi 
}

#param1 fs
#param2 total_size_each_case : total size of each test case
func_file_test_round ()
{
 fs=$1
 total_size_each_case=$2

 func_status_line "File-Test $fs total_size_each_case:$total_size_each_case"

 # Make sure we start with default
 func_set_default_dir "$fs"

 #XXX Must write then read, so this prepares target for write.
 func_prepare_target_fs "$fs" >>$OUT 2>>$ERR
 for rw in $MLOP_RW
 do
  for job_size in $MLOP_JOB_SIZES
  do
   func_status_line "File-Test $fs job_size:$job_size rw:$rw"
   n_jobs=$(($total_size_each_case / $job_size))
   # CloudFuse+Swift is only able to read 10K files in one container
#   if test "$fs" = "fuse" -a $n_jobs -gt 10000
#   then
#    n_jobs=10000
#   fi
   block_size=$job_size
   # Reheat server cache before reads, unless clean server cache is desired.
   if test "$rw" = "r"
   then
    if test -z "$CLEANSERVERCACHE" -o "$CLEANSERVERCACHE" = "0"
    then
     func_reheat_server_cache_for_read >>$OUT 2>>$ERR
    fi
   fi
   for flag in $MLOP_FLAG
   do
    for n_threads in $MLOP_N_WORKER
    do
    func_file_test_do_work >>$OUT 2>>$ERR
    done
   done
  done
 done

 # Restore DIR path
 func_set_default_dir "$fs"

 # Final clean up: delete written files
 if test "$fs" != "fuse"
 then
  func_status_line "File-Test $fs final clean up"
  # This gives the largest possible n_jobs
  job_size=4096
  n_jobs=$(($total_size_each_case / $job_size))
  rw="w"
  func_remove_old_write_and_clean >>$OUT 2>>$ERR
 fi
}

