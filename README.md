# Project Documentation

This repository contains scripts and documentation for setting up various environments.

## Termux Setup

This project provides a set of scripts to automate the setup of a Termux environment on an Android device and connect it to a master server.

### `scripts/master.py`

This script runs on the master server and publishes its SSH public key via a temporary HTTP server using Zeroconf.

**Prerequisites:**
- A Linux-based OS with Python 3 and `pip` installed.
- The `zeroconf` library. Install it with `pip install zeroconf`.

**Usage:**
1.  Open a terminal on the master server.
2.  Navigate to the `scripts` directory.
3.  Run the script: `python3 master.py`

The script will publish the master's public key on the local network.

### `scripts/setup_termux.sh`

This script runs on a new Termux instance and performs the following actions:
- Updates and upgrades all installed packages.
- Installs essential tools: `vim`, `wget`, `git`, `openssh`, and `avahi`.
- Generates an SSH key pair if one doesn't exist.
- Discovers the master server on the network using Avahi.
- Retrieves the master's public key and adds it to `~/.ssh/authorized_keys`.
- Starts the SSH server.
- Publishes its own SSH service using Avahi, making it discoverable as a "worker".

**How to use this script on Android:**
1.  Install Termux on your Android device.
2.  Open Termux and run the following command to download and execute the script:

    ```bash
    bash <(curl -s https://raw.githubusercontent.com/your_username/your_repository/main/scripts/setup_termux.sh)
    ```
    *(Replace `your_username` and `your_repository` with the actual values)*

### Master and Worker Interaction

1.  **Master:** The master server runs `master.py` to advertise its public key.
2.  **Worker (Termux):** The Termux instance runs `setup_termux.sh` to:
    -   Find the master's public key and authorize it.
    -   Advertise its own SSH service.
3.  **Master (post-setup):** The master can then discover the workers on the network and SSH into them without a password.

### `scripts/discover_workers.sh`

This script, when run on the master server, will discover all available Termux workers on the network and print the full SSH command required to connect to each one.

**Usage:**
1.  Open a terminal on the master server.
2.  Navigate to the `scripts` directory.
3.  Run the script: `./discover_workers.sh`

The output will be a list of SSH commands, one for each discovered worker.

## Other Guides

### Ubuntu Installation Guide (`new_ubuntu_instalation.md`)

The [**`new_ubuntu_instalation.md`**](./new_ubuntu_instalation.md) file contains instructions and guidance for setting up a standard Ubuntu desktop or server environment. This is distinct from the Termux setup, which is specific to Android.

If you are looking to set up a fresh Ubuntu system, please consult this document.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues to improve these scripts and documentation.
