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
pkg update -y
apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"

print_message "Installing all required packages..."
pkg install vim wget git openssh python python-pip -y

print_message "Installing Python dependencies..."
pip install zeroconf


print_message "Starting SSH server..."
sshd

# --- Master Discovery and Connection ---

print_message "Discovering master server..."
wget -O ~/discover_master.py https://raw.githubusercontent.com/samirma/cookbook/main/scripts/discover_master.py
chmod +x ~/discover_master.py

MASTER_URL=$(python ~/discover_master.py)

if [ -n "$MASTER_URL" ]; then
  echo "Fetching public key from master..."
  MASTER_KEY=$(wget -qO- "$MASTER_URL")

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
chmod +x ~/publish_worker.py
nohup python ~/publish_worker.py &
echo "Worker's SSH service is being published in the background."

