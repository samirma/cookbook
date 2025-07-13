#!/data/data/com.termux/files/usr/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Update and upgrade packages
echo "Updating and upgrading packages..."
pkg update -y

# Install all required packages at once
echo "Installing required packages..."
pkg install vim wget git openssh iproute2 cmake ccache libzmq rsync root-repo file avahi \
            clinfo ocl-icd opencl-headers fastfetch \
            vulkan-headers vulkan-loader shaderc -y

# Setup termux storage
echo "Setting up Termux storage..."
termux-setup-storage

# Create a symlink for llama.cpp cache if the directory exists
if [ -d "$HOME/storage/dcim/llama.cpp" ]; then
    mkdir -p "$HOME/.cache"
    ln -sfn "$HOME/storage/dcim/llama.cpp" "$HOME/.cache/llama.cpp"
fi

# Generate an SSH key pair if one doesn't exist
if [ ! -f "$HOME/.ssh/id_rsa" ]; then
  echo "Generating SSH key pair..."
  ssh-keygen -t rsa -N "" -f "$HOME/.ssh/id_rsa"
fi

# Start the SSH server
echo "Starting SSH server on port 8022..."
sshd

# Discover the master server and add its public key
echo "Discovering master server..."
# The timeout is to prevent the script from hanging indefinitely if no service is found
SERVICE_INFO=$(timeout 15s avahi-browse -r -t _http-public-key._tcp | head -n 1 || true)

if [ -n "$SERVICE_INFO" ]; then
  # Extract the IP address and port
  IP_ADDRESS=$(echo "$SERVICE_INFO" | grep "address" | cut -d'[' -f2 | cut -d']' -f1)
  PORT=$(echo "$SERVICE_INFO" | grep "port" | cut -d'[' -f2 | cut -d']' -f1)

  if [ -n "$IP_ADDRESS" ] && [ -n "$PORT" ]; then
    # Fetch the public key
    echo "Fetching public key from http://${IP_ADDRESS}:${PORT}/public_key.txt"
    MASTER_KEY=$(wget -qO- "http://${IP_ADDRESS}:${PORT}/public_key.txt")

    if [ -n "$MASTER_KEY" ]; then
      echo "Master server found. Adding public key to authorized_keys."
      mkdir -p "$HOME/.ssh"
      # Append key only if it's not already there
      if ! grep -qF "$MASTER_KEY" "$HOME/.ssh/authorized_keys"; then
        echo "$MASTER_KEY" >> "$HOME/.ssh/authorized_keys"
      fi
      chmod 600 "$HOME/.ssh/authorized_keys"
      echo "Public key added."
    else
      echo "Could not fetch public key from master server."
    fi
  else
    echo "Could not parse IP address and port from discovered service."
  fi
else
  echo "Could not find master server. Please ensure the master is running and on the same network."
fi

# Download and run the publish_worker.sh script
echo "Downloading the publish_worker.sh script..."
wget -O "$HOME/publish_worker.sh" https://raw.githubusercontent.com/samirma/cookbook/main/scripts/publish_worker.sh
chmod +x "$HOME/publish_worker.sh"

# Stop any previous instances of the script before starting a new one
pkill -f "publish_worker.sh" || true
nohup "$HOME/publish_worker.sh" &
echo "Worker's SSH service is being published in the background."

# Display system information
fastfetch

# Final instructions for the user
echo
echo "---"
echo "✅ Setup complete!"
echo
echo "To connect from your master server, use the following command:"
echo "ssh -p 8022 $(whoami)@<YOUR-ANDROID-IP>"
echo
echo "You can find your Android device's IP address by:"
echo "  - Checking your phone's Wi-Fi settings."
echo "  - Running 'ifconfig' or 'ip addr' in Termux and looking for the 'wlan0' interface."
echo "---"
