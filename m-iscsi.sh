#!/bin/sh

. ./iotest.inc.sh
. ./file-test.inc.sh

# TODO round variables (see iotest.inc.sh)
# Common:
#  MLOP_FS
#  MLOP_FLAG
#  MLOP_RW  (w MUST precede r)
# Batch:
#  MLOP_TOOL
#  MLOP_BS
#  MLOP_N
#  MLOP_NBLK
#  MLOP_PATTERN
# Worker:
#  MLOP_N_WORKER
#  MLOP_N_JOBS
#  MLOP_JOB_SIZES
#  MLOP_JOBS_PER_THREAD

#
# main
#
# Should run prepare-for-read.sh before starting.
#

func_status_line "Metadata test"

func_set_default_dir "iscsi"

N_ITER="1000 100 10 1"
for n_loops in $N_ITER
do
 func_status_line "Meta: iscsi x $n_loops"
 sh ./meta.sh "iscsi" $n_loops >> $OUT  2>>$ERR
done

func_status_line "End of Metadata test"

