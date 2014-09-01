#!/bin/sh

# param1: iface
func_offload_off ()
{
 echo Turning off offload engines for $1
 ethtool --offload $1 rx off
 ethtool --offload $1 tx off
 ethtool --offload $1 gso off
 ethtool --offload $1 tso off
 ethtool --offload $1 sg off
 ethtool --offload $1 ufo off
 ethtool --offload $1 gro off
 ethtool --offload $1 lro off
 ethtool --offload $1 rxvlan off
 ethtool --offload $1 txvlan off
}

if test ! -z $1
then
 func_offload_off $1
else
 echo Usage: sudo sh offload.sh \<iface\>
fi

