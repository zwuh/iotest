#!/bin/sh

#
# main
# param1: server
#

#in KB
MLOP_JOB_SIZES="1024"

MLOP_N_WORKER="1 2 4 8 16"

duration=20

for job_size in $MLOP_JOB_SIZES
do
 for n_threads in $MLOP_N_WORKER
 do
  echo -n n:$n_threads sz:$job_size\(K\) : 
  iperf -c $1 -t $duration -l ${job_size}K -P $n_threads | tail -n 1
 done
done

