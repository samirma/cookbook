# Project Documentation

This repository contains scripts and documentation for setting up various environments.

## Available Scripts and Guides

### 1. Termux Setup for Android (`setup_termux.sh`)

The `setup_termux.sh` script is designed to automate the setup of a Termux environment on an Android device. It performs the following actions:
- Updates and upgrades all installed packages.
- Installs essential tools: `vim`, `wget`, `git`, and `openssh`.
- Sets up Termux storage access by running `termux-setup-storage`.
- Starts an OpenSSH server (`sshd`) to allow remote connections to your device.
- Displays the command needed to connect to your device via SSH from another computer.

**How to use this script on Android:**
For detailed instructions on downloading and running this script within Termux, please refer to the [**`run_script_android.md`**](./run_script_android.md) guide.

### 2. Running `setup_termux.sh` on Android (`run_script_android.md`)

The [**`run_script_android.md`**](./run_script_android.md) file provides a step-by-step guide on how to:
- Install Termux on your Android device.
- Download the `setup_termux.sh` script.
- Make the script executable.
- Run the script to set up your environment.
- It also includes convenient one-liner commands to download and execute the script directly, for users who understand the security implications.

### 3. Ubuntu Installation Guide (`new_ubuntu_instalation.md`)

The [**`new_ubuntu_instalation.md`**](./new_ubuntu_instalation.md) file contains instructions and guidance for setting up a standard Ubuntu desktop or server environment. This is distinct from the Termux setup, which is specific to Android.

If you are looking to set up a fresh Ubuntu system, please consult this document.

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues to improve these scripts and documentation.
