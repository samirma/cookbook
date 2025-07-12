
# Start the avahi daemon
avahi-daemon &

USER_NAME=$(whoami)
IP_ADDRESS=$(ip -4 addr show wlan0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || echo "YOUR_DEVICE_IP")
PORT=$(sshd -T | awk '/^port / {print $2}')

if [ "$IP_ADDRESS" = "YOUR_DEVICE_IP" ]; then
    echo "Could not automatically determine IP address for wlan0."
    echo "Please find it manually using 'ip addr' or 'ifconfig' and replace YOUR_DEVICE_IP."
    exit 1
fi

while true; do
  avahi-publish-service "Termux Worker ${USER_NAME}" _ssh._tcp $PORT "user=${USER_NAME}" "ip=${IP_ADDRESS}"
  sleep 10
done
