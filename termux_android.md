# How to Run `setup_termux.sh` on Android using Termux

This guide explains how to download and execute the `setup_termux.sh` script on your Android device using the Termux application. This script helps in setting up your Termux environment with essential packages like `vim`, `wget`, `git`, and `openssh`, and also starts an SSH server.

## Prerequisites

1.  **Install Termux**: If you haven't already, download and install Termux from F-Droid or the Google Play Store.
    *   [Termux on F-Droid](https://f-droid.org/en/packages/com.termux/)
    *   Note: The Play Store version might be outdated. F-Droid is generally recommended for the latest updates.

## Steps to Run the Script

## One-liner Command to Download and Run

For convenience, you can download and execute the script in a single command. This is similar to how some other installation scripts (like Docker's) are run.

**Make sure you trust the source of the script before running it this way.**

The raw content URL for the script is `https://raw.githubusercontent.com/samirma/cookbook/main/setup_termux.sh`.

Using `curl`:
```bash
curl -fsSL https://raw.githubusercontent.com/samirma/cookbook/main/scripts/setup_termux.sh | bash
```


This command fetches the script content and pipes it directly to `bash` for execution.

---

The URLs provided point to the `setup_termux.sh` script in the `main` branch of the `samirma/cookbook` GitHub repository.
