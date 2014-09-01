#!/bin/sh

. ./iotest.inc.sh

echo Cleaning cache and warming up filesystem.

if test -z "$1"
then
  echo Parameter 1: filesystem to warm up.
  echo See iotest.inc.sh:func_prepare_target_fs\(\) for more information.
else
  func_clean_cache
  func_prepare_target_fs $1
  func_clean_cache
fi
