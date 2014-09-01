#!/bin/sh

. ./iotest.inc.sh

#
# Generate image files for read tests.
# See iotest.inc.sh:func_set_read_dir ()
#

MLOP_JOB_SIZES="67108864 16777216 4194304 1048576 262144 65536 16384 4096"


#
# main
# param1: fs
#

if test -z "$1"
then
 echo param1: fs
 exit
fi

func_prepare_output_dir

fs=$1

echo INFO setting duration to 0 \(infinite\)
duration=0

for job_size in $MLOP_JOB_SIZES
do
 n_jobs=$(($MAX_TASK_SIZE / $job_size))
 block_size=$job_size
 rw="r" #needed to fool func_set_read_dir()
 func_set_read_dir $fs $job_size
 func_check_fs $fs
 func_set_target_dir
 if test -z "$DRY" -o "$DRY" = "0"
 then
  mkdir -p $TARGET
 else
  echo prepare: mkdir -p $TARGET
 fi
 func_create_buckets $fs $rw $job_size $n_jobs
 rw="w"
 #XXX CloudFuse+Swift can only handle containers with < 10K objects
# if test "$fs" = "fuse" -a $n_jobs -gt 10000
# then
#  n_jobs=10000
# fi
 flag="def"
 n_threads=32
 func_worker_show
 func_worker_invoke_worker_c
 if test -z "$DRY" -o "$DRY" = "0"
 then
  echo -n Elapsed:\ 
  tail -n 2 $OUTF | head -n 1
  echo -n Throughput:\ 
  tail -n 1 $OUTF
  echo -n Serviced:\ 
  tail -n 3 $TMPF | head -n 1
 fi
 echo INFO creating write buckets.
 func_set_default_dir $fs
 func_create_buckets $fs $rw $job_size $n_jobs
done

func_clean_client_cache

