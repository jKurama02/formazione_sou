#!/bin/bash
echo "–– Enter ip ––"
read ip
echo "–– Enter first port ––"
read port
echo "–– Enter last port ––"
read l_port

while [ $port -le $l_port ]; do #scan all ports
  echo  -n "Try scan $port :"
        # try connection
  (nc $ip $port & sleep 0.01; kill $! 2>/dev/null) && echo "––––––open––––––" || echo "..."

  port=$((port + 1))
done


# basic script, there is no error check or limitation