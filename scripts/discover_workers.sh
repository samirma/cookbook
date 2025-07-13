#!/bin/bash

# This script will be run on the master server.
# It will discover workers on the network and print the SSH command to connect to them.

echo "Discovering workers..."
avahi-browse -r -p -t _ssh._tcp | grep "Termux Worker" | while IFS=';' read -r _ interface _ name type _ host ip port txt; do
  if [ "$name" != "" ]; then
      user=$(echo "$txt" | grep -o 'user=[^"]*' | cut -d= -f2)
      echo "ssh -p $port $user@$ip"
  fi
done
