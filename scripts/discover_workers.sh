#!/bin/bash

# This script will be run on the master server.
# It will discover workers on the network and print the SSH command to connect to them.

# Check if avahi-browse is installed
if ! command -v avahi-browse &> /dev/null; then
  echo "avahi-browse could not be found. Please install avahi-utils."
  exit 1
fi

echo "Discovering workers..."
avahi-browse -r -t _ssh._tcp | grep "Termux Worker" | while read line; do
  if [[ $line == "="* ]]; then
    SERVICE_NAME=$(echo "$line" | grep "hostname" | cut -d'=' -f2 | cut -d'[' -f1)
    IP_ADDRESS=$(echo "$line" | grep "address" | cut -d'=' -f2 | cut -d'[' -f2 | cut -d']' -f1)
    PORT=$(echo "$line" | grep "port" | cut -d'=' -f2 | cut -d'[' -f2 | cut -d']' -f1)
    USER=$(echo "$line" | grep "user" | cut -d'=' -f2)
    echo "ssh -p $PORT $USER@$IP_ADDRESS"
  fi
done
