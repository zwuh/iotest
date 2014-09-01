#!/bin/sh

. ./iotest.inc.sh


curl -i -H "X-Auth-User: $AUTHUSER" -H "X-Auth-Key: $AUTHKEY" $AUTHURL 2>/dev/null >/tmp/swift.tmp
storage_url=`grep X-Storage-Url /tmp/swift.tmp | awk '{print $2;}' | tr -d '\r'`
auth_token=`grep X-Auth-Token /tmp/swift.tmp | awk '{print $2;}' | tr -d '\r'`

echo Url: $storage_url
echo Token: $auth_token

rm /tmp/swift.tmp
i=0
while test $i -lt 1000
do
 echo 0/$i.bin >> /tmp/swift.tmp
 i=$(($i+1))
done

curl -i -H "X-Auth-Token: $auth_token" -H "Content-Type: text/plain" $storage_url/?bulk-delete -X DELETE --data-ascii @/tmp/swift.tmp

