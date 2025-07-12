#!/bin/bash

# This script will be run on the master server.
# It will publish the master's public key using Avahi.

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# Check if avahi-publish is installed
if ! command -v avahi-publish &> /dev/null; then
  echo "avahi-publish could not be found. Please install avahi-daemon and avahi-utils."
  exit 1
fi

# Generate a key pair if one doesn't exist
if [ ! -f ~/.ssh/id_rsa.pub ]; then
  ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
fi

# Get the public key
PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)

# Publish the public key using Avahi
avahi-publish -s "Master SSH Key" _ssh-public-key._tcp 22 "key=${PUBLIC_KEY}" &

echo "Master SSH key is being published."
echo "Press Ctrl+C to stop."

# Wait for the user to stop the script
while true; do
  sleep 1
done
