# Discovering the SearXNG Server

The SearXNG server advertises itself on the local network via mDNS. Its `.local` hostname can be anything, so discovery should browse for the service rather than resolve a fixed name.

## Table of Contents

- [Cache-First Workflow](#cache-first-workflow)
- [mDNS Service Details](#mdns-service-details)
- [Discovery Methods](#discovery-methods)
  - [1. Browse mDNS Services](#1-browse-mdns-services-preferred)
  - [2. Resolve a Known Hostname](#2-resolve-a-known-hostname)
  - [3. Manual Network Scan](#3-manual-network-scan-if-mdns-fails)
- [IPv6 Handling](#ipv6-handling)
- [Validate the Server](#validate-the-server)

## Cache-First Workflow

Always try the cache before discovery:

```bash
CACHE_FILE="$HOME/.cache/searxng-server/ip"

# 1. Load from cache
if [ -z "$SEARXNG_IP" ] && [ -f "$CACHE_FILE" ]; then
    SEARXNG_IP=$(cat "$CACHE_FILE")
fi

# 2. Validate cached IP
if [ -n "$SEARXNG_IP" ]; then
    if curl -s --connect-timeout 3 "http://${SEARXNG_IP}:8080/healthz" >/dev/null 2>&1; then
        echo "Using cached SearXNG at ${SEARXNG_IP}"
        export SEARXNG_IP
    else
        echo "Cached IP ${SEARXNG_IP} is not responding"
        unset SEARXNG_IP
    fi
fi

# 3. Discover if no valid IP
if [ -z "$SEARXNG_IP" ]; then
    # Run one of the discovery methods below
fi

# 4. Save valid IP to cache
if [ -n "$SEARXNG_IP" ]; then
    mkdir -p "$(dirname "$CACHE_FILE")"
    echo "$SEARXNG_IP" > "$CACHE_FILE"
fi
```

## mDNS Service Details

| Attribute | Value |
|-----------|-------|
| **Service Type** | `_http._tcp` |
| **TXT Record** | `service=searxng` |
| **Default Port** | `8080` |

## Discovery Methods

### 1. Browse mDNS Services (Preferred)

Browse `_http._tcp` and look for instances with TXT `service=searxng`:

```bash
# macOS — runs continuously; press Ctrl+C after results appear
dns-sd -B _http._tcp | grep -i searxng
# Resolve the instance to get IP
dns-sd -L "<Instance Name>" _http._tcp local

# Linux
avahi-browse -a | grep -i searxng
avahi-browse -r _http._tcp | grep -i searxng
```

If you know the hostname from browsing, resolve it:

```bash
dig +short <hostname>.local
```

### 2. Resolve a Known Hostname

If the server's `.local` name is known (e.g. from prior discovery or user input):

```bash
dig +short <hostname>.local

# Alternatives:
getent hosts <hostname>.local | awk '{print $1}'
ping -c 1 <hostname>.local | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'
```

### 3. Manual Network Scan (if mDNS fails)

```bash
# Scan local network for port 8080
nmap -p 8080 --open 192.168.1.0/24

# Verify candidate IPs
curl -s --connect-timeout 5 "http://<CANDIDATE_IP>:8080/healthz"
```

## IPv6 Handling

If mDNS returns an IPv6 address, wrap it in brackets for curl:

```bash
if [[ "$SEARXNG_IP" == *:* ]]; then
    SEARXNG_URL="http://[${SEARXNG_IP}]:8080"
else
    SEARXNG_URL="http://${SEARXNG_IP}:8080"
fi
```

## Validate the Server

After discovering the IP, confirm it is a working SearXNG instance:

```bash
# Health check
curl -s --connect-timeout 5 "http://${SEARXNG_IP}:8080/healthz"

# Confirm JSON output is enabled
curl -s --connect-timeout 5 "http://${SEARXNG_IP}:8080/search?q=test&format=json" | jq -e '.results'
```
