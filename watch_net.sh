#!/bin/sh

str=`grep em2 /proc/net/dev`
read rxbytes rxpkt txbytes txpkt <<END
 $(echo $str | awk '{print $2 " " $3 " " $10 " " $11}')
END

echo Starting
 
while test 1
do
 sleep 2
 prev_rxbytes=$rxbytes
 prev_txbytes=$txbytes
 str=`grep em2 /proc/net/dev`
 echo -n NET\ 
 if test ! -z "$str"
 then
  read rxbytes rxpkt txbytes txpkt <<END
 $(echo $str | awk '{print $2 " " $3 " " $10 " " $11}')
END
 fi
 echo RX $((($rxbytes-$prev_rxbytes)/2048)) TX $((($txbytes - $prev_txbytes)/2048))
done

