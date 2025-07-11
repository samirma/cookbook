#!/data/data/com.termux/files/usr/bin/bash

# Update and upgrade packages
echo "Updating and upgrading packages..."
pkg update -y && pkg upgrade -y

# Install vim, wget, git, and openssh
echo "Installing vim, wget, git, and openssh..."
pkg install vim wget git openssh -y

# Setup termux storage
echo "Setting up Termux storage..."
termux-setup-storage

# Start the SSH server
echo "Starting SSH server..."
sshd

# Display SSH connection command
echo "SSH server started."
echo "To connect from another computer, use the following command:"
echo "ssh -p 8022 $(whoami)@$(ifconfig wlan0 | awk '/inet / {print $2}')"
echo "You might need to replace wlan0 with the correct network interface if Wi-Fi is not used."
echo "Use 'ip addr' or 'ifconfig' to find your device's IP address if the above command doesn't work."
