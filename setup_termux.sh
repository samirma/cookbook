#!/data/data/com.termux/files/usr/bin/bash

# Update and upgrade packages
echo "Updating and upgrading packages..."
pkg update -y

# Install vim, wget, git, openssh, and iproute2
echo "Installing vim, wget, git, openssh, and iproute2..."
pkg install vim wget git openssh iproute2  cmake ccache libzmq  rsync  avahi root-repo -y

echo "OpenCL section"
pkg install clinfo ocl-icd opencl-headers fastfetch -y

pkg install vulkan-headers vulkan-loader shaderc -y

# Setup termux storage
echo "Setting up Termux storage..."
termux-setup-storage

mkdir ~/storage/dcim/llama.cpp
ln -s ~/storage/dcim/llama.cpp /data/data/com.termux/files/home/.cache/llama.cpp

# Start the SSH server
echo "Starting SSH server..."
sshd

# Display SSH connection command
echo "SSH server started."

fastfetch

USER_NAME=$(whoami)
IP_ADDRESS=$(ip -4 addr show wlan0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || echo "YOUR_DEVICE_IP")

echo "To connect from another computer, use the following command:"
if [ "$IP_ADDRESS" == "YOUR_DEVICE_IP" ]; then
    echo "Could not automatically determine IP address for wlan0."
    echo "Please find it manually using 'ip addr' or 'ifconfig' and replace YOUR_DEVICE_IP."
fi
echo "ssh -p 8022 ${USER_NAME}@${IP_ADDRESS}"
echo "You might need to replace wlan0 with the correct network interface (e.g., eth0, wlan1) if Wi-Fi is not on wlan0."
echo "Use 'ip addr' to list all interfaces and their IP addresses."
