print_message() {
  echo
  echo "--------------------------------------------------"
  echo "$1"
  echo "--------------------------------------------------"
}


print_message "Setting up Termux storage..."
termux-setup-storage

# Create a symlink for llama.cpp cache
mkdir -p ~/storage/dcim/llama.cpp
ln -sfn ~/storage/dcim/llama.cpp /data/data/com.termux/files/home/.cache/llama.cpp
