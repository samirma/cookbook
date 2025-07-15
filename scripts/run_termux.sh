print_message() {
  echo
  echo "--------------------------------------------------"
  echo "$1"
  echo "--------------------------------------------------"
}

print_message "Publishing worker service..."
chmod +x ~/publish_worker.py
nohup python ~/publish_worker.py &
echo "Worker's SSH service is being published in the background."


print_message "Setting up Termux storage..."
termux-setup-storage

# Create a symlink for llama.cpp cache
mkdir -p ~/storage/dcim/llama.cpp
ln -sfn ~/storage/dcim/llama.cpp /data/data/com.termux/files/home/.cache/llama.cpp

print_message "Starting SSH server..."
sshd

fastfetch

