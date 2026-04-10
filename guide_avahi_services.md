# Avahi mDNS Service Publication Guide

This guide covers how to publish services using Avahi (mDNS/DNS-SD) for automatic network discovery on Linux systems.

## Overview

[Avahi](https://www.avahi.org/) is a free Zeroconf implementation that allows services to be discovered on a local network without manual configuration. It uses mDNS (multicast DNS) and DNS-SD (DNS Service Discovery) protocols.

Common use cases:
- Discover SSH servers without knowing IP addresses
- Find web services (like SearXNG) automatically
- Publish homelab services for easy access
- Enable service discovery for distributed systems

## Installation

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install avahi-daemon avahi-utils
```

### Start/Enable Service
```bash
sudo systemctl enable avahi-daemon
sudo systemctl start avahi-daemon
```

## Service Configuration Files

Service files are stored in `/etc/avahi/services/` and use XML format with `.service` extension.

### File Structure

```xml
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">%h ServiceName</name>
  <service>
    <type>_service._tcp</type>
    <port>PORT_NUMBER</port>
    <txt-record>key=value</txt-record>
  </service>
</service-group>
```

### Wildcards
- `%h` - Replaced with the system hostname
- `%d` - Replaced with the domain name (usually `local`)

## Example Services

### SSH Service with Metadata

File: `ssh.service`

```xml
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">%h SSH</name>
  <service>
    <type>_ssh._tcp</type>
    <port>22</port>
    <txt-record>description=Raspberry Homelab Server</txt-record>
    <txt-record>type=homelab</txt-record>
    <txt-record>hardware=raspberry</txt-record>
    <txt-record>os=linux</txt-record>
  </service>
</service-group>
```

**Published as:** `raspberry-server SSH`  
**Access:** `ssh user@raspberry-server.local`

### HTTP Service (SearXNG)

File: `searxng.service`

```xml
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">%h SearXNG</name>
  <service>
    <type>_http._tcp</type>
    <port>8080</port>
    <txt-record>path=/</txt-record>
    <txt-record>description=SearXNG Privacy Search Engine</txt-record>
    <txt-record>service=searxng</txt-record>
    <txt-record>type=search-engine</txt-record>
  </service>
</service-group>
```

**Published as:** `raspberry-server SearXNG`  
**Access:** `http://raspberry-server.local:8080/`

## Installation Steps

1. **Copy service files to Avahi directory:**
   ```bash
   sudo cp ssh.service /etc/avahi/services/
   sudo cp searxng.service /etc/avahi/services/
   ```

2. **Set proper permissions:**
   ```bash
   sudo chmod 644 /etc/avahi/services/*.service
   ```

3. **Reload Avahi daemon:**
   ```bash
   sudo systemctl reload avahi-daemon
   ```

## Verification

### List Discovered Services
```bash
avahi-browse -a
```

### Browse Specific Service Type
```bash
# Browse HTTP services
avahi-browse -r _http._tcp

# Browse SSH services
avahi-browse -r _ssh._tcp
```

### Resolve Service Details
```bash
avahi-resolve-host-name raspberry-server.local
```

## Common Service Types

| Service | Type | Port |
|---------|------|------|
| SSH | `_ssh._tcp` | 22 |
| HTTP | `_http._tcp` | 80/8080 |
| HTTPS | `_https._tcp` | 443 |
| SMB/CIFS | `_smb._tcp` | 445 |
| AFP | `_afpovertcp._tcp` | 548 |
| NFS | `_nfs._tcp` | 2049 |
| Printer | `_ipp._tcp` | 631 |
| AirPlay | `_airplay._tcp` | Variable |

## TXT Record Best Practices

TXT records provide metadata about your service. Common keys:

| Key | Purpose | Example |
|-----|---------|---------|
| `description` | Human-readable description | `Raspberry Homelab Server` |
| `type` | Service category | `homelab`, `search-engine` |
| `service` | Specific service identifier | `searxng` |
| `hardware` | Hardware platform | `raspberry`, `x86_64` |
| `os` | Operating system | `linux`, `macos` |
| `path` | URL path | `/`, `/api` |
| `version` | Service version | `1.0.0` |

## Troubleshooting

### Service Not Appearing
1. Check Avahi is running: `sudo systemctl status avahi-daemon`
2. Verify service file syntax: `xmllint --noout servicefile.service`
3. Check firewall allows mDNS (UDP port 5353)

### Permission Denied
```bash
# Fix permissions
sudo chmod 644 /etc/avahi/services/*.service
sudo chown root:root /etc/avahi/services/*.service
```

### Debug Mode
```bash
# Stop daemon and run in foreground with debug output
sudo systemctl stop avahi-daemon
sudo avahi-daemon --debug
```

## Configuration Files Location

This directory contains reference service files:
- `ssh.service` - SSH service with homelab metadata
- `searxng.service` - SearXNG search engine discovery

To install on a new system:
```bash
cd /path/to/cookbook/avahi-services
sudo cp *.service /etc/avahi/services/
sudo systemctl reload avahi-daemon
```
