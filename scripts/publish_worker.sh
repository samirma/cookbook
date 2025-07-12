#!/data/data/com.termux/files/usr/bin/bash

# Start the avahi daemon
avahi-daemon &

USER_NAME=$(whoami)
PORT=$(sshd -T | grep "port" | awk '{print $2}' | head -n 1)


while true; do
  avahi-publish-service "Termux Worker ${USER_NAME}" _ssh._tcp $PORT "user=${USER_NAME}" "worker"
  sleep 10
done
