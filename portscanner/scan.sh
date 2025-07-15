#!/bin/bash
while true; do
  echo "–– Enter ip ––"
  read ip
  if ! [[ "$ip" =~ ^[0-9.]+$ ]]; then 
      echo "Error: is not the ip address"
  else
      break
  fi
done

while true; do
  echo "–– Enter first port ––"
  read port
  if ! [[ "$port" =~ ^[0-9]+$ ]] && (( $port < 1 || $port > 65000 )); then 
      echo "Error: incorrect port number"
  else
      break
  fi
done
while true; do
  echo "–– Enter last port ––"
  read l_port
  if ! [[ "$l_port" =~ ^[0-9]+$ ]] && (( $l_port < 1 || $l_port > 65000 )); then 
      echo "Error: incorrect port number"
  else
      break
  fi
done

while [ $port -le $l_port ]; do #scan all ports
  echo  -n "Try scan $port :"
        # try connection
  (nc $ip $port & sleep 0.01; kill $! 2>/dev/null) && echo "––––––open––––––" || echo "..."

  port=$((port + 1))
done

