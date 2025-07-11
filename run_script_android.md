# How to Run `setup_termux.sh` on Android using Termux

This guide explains how to download and execute the `setup_termux.sh` script on your Android device using the Termux application. This script helps in setting up your Termux environment with essential packages like `vim`, `wget`, `git`, and `openssh`, and also starts an SSH server.

## Prerequisites

1.  **Install Termux**: If you haven't already, download and install Termux from F-Droid or the Google Play Store.
    *   [Termux on F-Droid](https://f-droid.org/en/packages/com.termux/)
    *   Note: The Play Store version might be outdated. F-Droid is generally recommended for the latest updates.

## Steps to Run the Script

1.  **Open Termux**: Launch the Termux app on your Android device.

2.  **Download the script**:
    You can download the `setup_termux.sh` script using `curl` or `wget`. The script is hosted at `https://github.com/samirma/cookbook/blob/main/setup_termux.sh`. The raw content URL is `https://raw.githubusercontent.com/samirma/cookbook/main/setup_termux.sh`.

    Using `curl`:
    ```bash
    curl -fsSL -o setup_termux.sh https://raw.githubusercontent.com/samirma/cookbook/main/setup_termux.sh
    ```

    Or using `wget`:
    ```bash
    wget -O setup_termux.sh https://raw.githubusercontent.com/samirma/cookbook/main/setup_termux.sh
    ```

3.  **Make the script executable**:
    After downloading, you need to give the script execution permissions.
    ```bash
    chmod +x setup_termux.sh
    ```

4.  **Run the script**:
    Now you can execute the script.
    ```bash
    ./setup_termux.sh
    ```
    The script will then:
    *   Update and upgrade your Termux packages.
    *   Install `vim`, `wget`, `git`, and `openssh`.
    *   Run `termux-setup-storage` (you'll need to grant storage permission when prompted).
    *   Start the `sshd` server.
    *   Display the command to connect to your device via SSH.

## One-liner Command to Download and Run

For convenience, you can download and execute the script in a single command. This is similar to how some other installation scripts (like Docker's) are run.

**Make sure you trust the source of the script before running it this way.**

The raw content URL for the script is `https://raw.githubusercontent.com/samirma/cookbook/main/setup_termux.sh`.

Using `curl`:
```bash
curl -fsSL https://raw.githubusercontent.com/samirma/cookbook/main/setup_termux.sh | bash
```

Or using `wget`:
```bash
wget -qO - https://raw.githubusercontent.com/samirma/cookbook/main/setup_termux.sh | bash
```

This command fetches the script content and pipes it directly to `bash` for execution.

---

The URLs provided point to the `setup_termux.sh` script in the `main` branch of the `samirma/cookbook` GitHub repository.
