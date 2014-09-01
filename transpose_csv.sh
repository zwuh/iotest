#!/bin/sh

# param1: input csv
# param2: interested columns

in_file=$1
cols=$2

if test ! -f $in_file
then
 echo Error: no input file $in_file
 exit
fi

if test -z "$cols"
then
 exit
fi

for i in $cols
do
 #echo Column \#$i
 rows=`cut -d\, -f $i $in_file`
 for row in $rows
 do
  echo -n $row,
 done
 echo ""
done

