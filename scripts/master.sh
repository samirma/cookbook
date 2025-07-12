#!/bin/bash

# This script will be run on the master server.
# It will publish the master's public key using Avahi.


# Generate a key pair if one doesn't exist
if [ ! -f ~/.ssh/id_rsa.pub ]; then
  ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
fi

# Get the public key
PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)

# Publish the public key using Avahi
avahi-publish-service "Master SSH Key" _ssh-public-key._tcp 22 "key=${PUBLIC_KEY}" &

echo "Master SSH key is being published."
echo "Press Ctrl+C to stop."

# Wait for the user to stop the script
while true; do
  sleep 1
done
