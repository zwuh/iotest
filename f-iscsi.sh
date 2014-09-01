#!/bin/sh

. ./iotest.inc.sh
. ./file-test.inc.sh

#
# main
# Driver script for File-Test
# Should run prepare-for-read.sh before starting.
#

func_status_line "File test"
func_prepare_output_dir

#MLOP_JOB_SIZES="16777216 1048576 4096"
MLOP_JOB_SIZES="1048576 16777216 4096"
#MLOP_JOB_SIZES="4096 16777216 1048576"
#MLOP_JOB_SIZES="4096 1048576 16777216"
#MLOP_JOB_SIZES="16777216 4096 1048576"
#MLOP_JOB_SIZES="1048576 4096 16777216"
#MLOP_N_WORKER="64 32 16 8 4 2 1"
#MLOP_N_WORKER="1 64 2 32 4 16 8"
MLOP_N_WORKER="8 4 16 64 1 2 32"
#MLOP_N_WORKER="16 2 8 64 4 1 32"
#MLOP_N_WORKER="1 2 4 8 16 32 64"

#MLOP_JOB_SIZES="67108864 16384 16777216 65536 1048576 262144 4194304 4096"
#MLOP_N_WORKER="1"

MLOP_FLAG="d s"
func_file_test_round "iscsi" $MAX_TASK_SIZE

func_status_line "End of File test"

