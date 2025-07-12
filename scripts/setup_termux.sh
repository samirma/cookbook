#!/data/data/com.termux/files/usr/bin/bash

# Update and upgrade packages
echo "Updating and upgrading packages..."
pkg update -y

# Install vim, wget, git, openssh, and iproute2
echo "Installing vim, wget, git, openssh, and iproute2..."
pkg install vim wget git openssh iproute2  cmake ccache libzmq  rsync  avahi root-repo  file -y

echo "OpenCL section"
pkg install clinfo ocl-icd opencl-headers fastfetch -y

pkg install vulkan-headers vulkan-loader shaderc -y

# Setup termux storage
echo "Setting up Termux storage..."
termux-setup-storage

mkdir ~/storage/dcim/llama.cpp
ln -s ~/storage/dcim/llama.cpp /data/data/com.termux/files/home/.cache/llama.cpp

# Generate an SSH key pair if one doesn't exist
if [ ! -f ~/.ssh/id_rsa.pub ]; then
  ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
fi

# Start the SSH server
echo "Starting SSH server..."
sshd

# Discover the master server and add its public key
echo "Discovering master server..."
MASTER_KEY=$(avahi-browse -r -t _ssh-public-key._tcp | grep "key=" | cut -d'=' -f2- | head -n 1)

if [ -n "$MASTER_KEY" ]; then
  echo "Master server found. Adding public key to authorized_keys."
  mkdir -p ~/.ssh
  echo "$MASTER_KEY" >> ~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys
  echo "Public key added."
else
  echo "Could not find master server. Please ensure the master is running and on the same network."
fi

# Download and run the publish_worker.sh script
echo "Downloading and running the publish_worker.sh script..."
mkdir -p ~/.termux/boot
wget -O ~/.termux/boot/publish_worker.sh https://raw.githubusercontent.com/samirma/cookbook/main/scripts/publish_worker.sh
chmod +x ~/.termux/boot/publish_worker.sh
nohup ~/.termux/boot/publish_worker.sh &
echo "Worker's SSH service is being published in the background."

fastfetch

echo "To connect from another computer, use the following command:"
if [ "$IP_ADDRESS" == "YOUR_DEVICE_IP" ]; then
    echo "Could not automatically determine IP address for wlan0."
    echo "Please find it manually using 'ip addr' or 'ifconfig' and replace YOUR_DEVICE_IP."
fi
echo "ssh -p ${PORT} ${USER_NAME}@${IP_ADDRESS}"
echo "You might need to replace wlan0 with the correct network interface (e.g., eth0, wlan1) if Wi-Fi is not on wlan0."
echo "Use 'ip addr' to list all interfaces and their IP addresses."
