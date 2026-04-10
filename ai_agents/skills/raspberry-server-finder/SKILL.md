---
name: raspberry-server-finder
description: Discover and connect to Raspberry Pi server at raspberry-server.local using mDNS/Bonjour. Use when user needs to find, ping, SSH into, or troubleshoot connection to the Raspberry Pi server on the local network.
---

# Raspberry Pi Server Finder

This skill helps discover and connect to a Raspberry Pi server that publishes itself as `raspberry-server.local` via mDNS (Bonjour/Zeroconf).

## Quick Reference

| Task | Command |
|------|---------|
| Ping test | `ping raspberry-server.local` |
| SSH connect | `ssh pi@raspberry-server.local` |
| Check mDNS resolution | `dig +short raspberry-server.local` |
| Scan for open ports | `nmap raspberry-server.local` |
| View mDNS services | `dns-sd -B _ssh._tcp` (macOS) / `avahi-browse -a` (Linux) |

## Prerequisites

Ensure your system has mDNS support:

- **macOS**: Built-in (Bonjour)
- **Linux**: Install `avahi-daemon` and `libnss-mdns`
  ```bash
  # Debian/Ubuntu/Raspberry Pi OS
  sudo apt update && sudo apt install -y avahi-daemon libnss-mdns
  
  # Verify service is running
  sudo systemctl status avahi-daemon
  ```
- **Windows**: Install iTunes or Bonjour Print Services

## Discovery Methods

### 1. Basic Resolution Test
```bash
ping -c 3 raspberry-server.local
```

### 2. Get IP Address
```bash
# macOS/Linux
dig +short raspberry-server.local
getent hosts raspberry-server.local

# Alternative using ping
ping -c 1 raspberry-server.local | head -1
```

### 3. Browse mDNS Services
```bash
# macOS
dns-sd -B _ssh._tcp
dns-sd -B _http._tcp
dns-sd -B _smb._tcp

# Linux (requires avahi-utils)
avahi-browse -a
avahi-browse -r _ssh._tcp
```

## SSH Connection

### Default Connection
```bash
ssh pi@raspberry-server.local
```

### With Specific Key
```bash
ssh -i ~/.ssh/raspberry_key pi@raspberry-server.local
```

### Common Raspberry Pi Credentials
- **Username**: `pi` (older) or user-defined (newer Raspberry Pi OS)
- **Default password**: `raspberry` (must be changed on first boot for newer systems)

## Troubleshooting

### Cannot Resolve Hostname

1. **Check mDNS is working on your machine**:
   ```bash
   # Test with known mDNS host
   ping -c 1 $(hostname).local
   ```

2. **Verify Pi is broadcasting**:
   ```bash
   # From another device on same network
   nmap -sn 192.168.1.0/24  # Adjust subnet as needed
   ```

3. **Check network isolation**:
   - Ensure both devices are on the **same subnet**
   - Disable AP isolation on WiFi router if present
   - Try ethernet connection for testing

4. **Restart mDNS on Pi** (if you have alternative access):
   ```bash
   sudo systemctl restart avahi-daemon
   ```

### Connection Refused

- SSH may not be enabled on the Pi
- Check: `nmap raspberry-server.local` should show port 22 open

### Slow Resolution

Add to `~/.ssh/config`:
```
Host raspberry-server.local
    GSSAPIAuthentication no
    PreferredAuthentications publickey,password
```

## Network Scan Alternative

If mDNS fails, scan your network:

```bash
# Find all devices with port 22 (SSH) open
nmap -p 22 --open 192.168.1.0/24

# Full scan with OS detection (slower)
sudo nmap -O 192.168.1.0/24
```

## Useful File Transfers

```bash
# Copy file to Pi
scp file.txt pi@raspberry-server.local:/home/pi/

# Copy from Pi
scp pi@raspberry-server.local:/home/pi/file.txt .

# Sync directory
rsync -avz ./local-dir/ pi@raspberry-server.local:/home/pi/remote-dir/
```
