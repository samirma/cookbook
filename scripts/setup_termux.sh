#!/data/data/com.termux/files/usr/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Functions ---

# Function to print a formatted message
print_message() {
  echo
  echo "--------------------------------------------------"
  echo "$1"
  echo "--------------------------------------------------"
}

# --- Main Script ---

print_message "Updating and upgrading packages..."
apt-get update -y
apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

print_message "Installing all required packages..."
apt-get install vim wget git openssh iproute2 python python-pip cmake ccache libzmq rsync root-repo file \
clinfo ocl-icd opencl-headers fastfetch vulkan-headers vulkan-loader shaderc -y

print_message "Install ubuntu"
pkg install proot-distro -y
proot-distro install ubuntu

print_message "Installing Python dependencies..."
pip install zeroconf


print_message "Starting SSH server..."
sshd

# --- Master Discovery and Connection ---

print_message "IMPORTANT: Please ensure master.py is running on another PC on the same network."

print_message "Discovering master server..."
wget -O ~/discover_master.py https://raw.githubusercontent.com/samirma/cookbook/main/scripts/discover_master.py
chmod +x ~/discover_master.py

MASTER_URL=$(python ~/discover_master.py)

if [ -n "$MASTER_URL" ]; then
  echo "Fetching public key from master..."
  MASTER_KEY=$(wget -qO- "$MASTER_URL")

  # Extract base URL to request IP from master
  # MASTER_URL is like http://ip:port/path
  MASTER_BASE_URL=$(echo "$MASTER_URL" | sed -E 's|(http://[^/]+).*|\1|')
  if [ -n "$MASTER_BASE_URL" ]; then
      print_message "Requesting public IP from master..."
      IP_FROM_MASTER=$(wget -qO- "${MASTER_BASE_URL}/ip")
      if [ -n "$IP_FROM_MASTER" ]; then
          IP_ADDRESS="$IP_FROM_MASTER"
          echo "Master reported our IP as: $IP_ADDRESS"
      fi
  fi

  if [ -n "$MASTER_KEY" ]; then
    print_message "Adding master's public key to authorized_keys..."
    mkdir -p ~/.ssh
    echo "$MASTER_KEY" >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    echo "Public key added successfully."
  else
    echo "Could not fetch public key from master server." >&2
  fi
else
  echo "Could not find master server. Please ensure the master is running and on the same network." >&2
fi

# --- Worker Publishing ---

print_message "Publishing worker service..."
wget -O ~/publish_worker.py https://raw.githubusercontent.com/samirma/cookbook/main/scripts/publish_worker.py

# --- SSH Setup ---

print_message "Setting up SSH..."
if [ ! -f ~/.ssh/id_rsa.pub ]; then
  echo "Generating SSH key pair..."
  ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
else
  echo "SSH key pair already exists."
fi

# --- Final Instructions ---

# Get device IP address if not already set by master
if [ -z "$IP_ADDRESS" ]; then
    IP_ADDRESS=$(ip -4 addr show wlan0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
fi
USER_NAME=$(whoami)
PORT=8022 # Default Termux SSH port

print_message "To connect to this Termux instance from another computer, use:"
if [ -n "$IP_ADDRESS" ]; then
    echo
    echo "ssh -p ${PORT} ${USER_NAME}@${IP_ADDRESS}"
    echo
else
    echo "Could not automatically determine the IP address for wlan0." >&2
    echo "Please find it manually using 'ip addr' or 'ifconfig' and connect." >&2
fi
echo "Note: If you are not using Wi-Fi, you might need to find the IP for a different network interface (e.g., eth0)."


wget https://raw.githubusercontent.com/samirma/cookbook/main/scripts/run_termux.sh

echo "sh run_termux.sh" > ~/.bashrc

sh ~/.bashrc

