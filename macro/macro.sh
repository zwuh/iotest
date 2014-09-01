#!/bin/sh

# Top level driver script

if test -z "$DRY"
then
 DRY=1
fi

if test -z "$OUTBASE"
then
 OUTBASE=/home/user/tmp/macro
fi
if test -z "$BENCH_BASE"
then
 BENCH_BASE=/home/user/benchmark
fi

if test -z "$SCENE"
then
 echo ERR: You MUST specify SCENE.
 exit
fi

if test -z "$FPROF"
then
 echo ERR: You MUST specify FPROF.
 exit
fi

if test ! -d "$OUTBASE"
then
 mkdir -p "$OUTBASE"
fi

DATE=`date +'%Y-%m-%d'`
export DATE
export SCENE

SAVEDIR="${DATE}_c${SCENE}"

echo DATE: $DATE
echo OUTBASE: $OUTBASE
echo BENCH_BASE: $BENCH_BASE
echo SCENE: $SCENE
echo FPROF: $FPROF

cd $BENCH_BASE/filebench-run
echo -n INFO filebench\ 
date
export OUTDIR="$OUTBASE/filebench/$SAVEDIR"
PROFILE=$FPROF sh run-filebench.sh

cd $BENCH_BASE/postmark-1.53
echo -n INFO postmark-1.53\ 
date
export OUTDIR="$OUTBASE/postmark-1.53/$SAVEDIR"
sh run-postmark.sh

echo -n INFO end\ 
date
