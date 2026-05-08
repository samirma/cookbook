# Setup and Prerequisites

## System Requirements

- **macOS**: Built-in Bonjour (mDNS) support
- **Linux**: Install `avahi-daemon` and `libnss-mdns`
  ```bash
  sudo apt update && sudo apt install -y avahi-daemon libnss-mdns
  sudo systemctl status avahi-daemon
  ```

## Required Tools

- `curl` — HTTP requests
- `jq` — JSON parsing
- `dig` — DNS resolution (usually in `bind-utils` or `dnsutils`)

## Cache File

The server IP is persisted in:

```
~/.cache/searxng-server/ip
```

Create the cache directory before first use:

```bash
mkdir -p ~/.cache/searxng-server
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SEARXNG_IP` | Server IP address (overrides cache) | (from cache or discovery) |
| `SEARXNG_PORT` | Server port override | `8080` |

## Server-Side Requirement

The SearXNG server **must have JSON output enabled** in `settings.yml`:

```yaml
search:
  formats:
    - html
    - json
```

Without this, `format=json` returns HTML and `jq` parsing will fail. Restart SearXNG after modifying this setting.

## First-Time Setup Workflow

Run this sequence once to discover, validate, and cache the server IP:

```bash
CACHE_FILE="$HOME/.cache/searxng-server/ip"
mkdir -p "$(dirname "$CACHE_FILE")"

# Step 1: Discover the server IP via mDNS browse or scan
# (see references/discovery.md for methods)

# Example: resolve if you know the hostname (replace with actual name)
SEARXNG_IP=$(dig +short <hostname>.local 2>/dev/null)

# Fallback: scan the local network if mDNS fails
if [ -z "$SEARXNG_IP" ]; then
    # Adjust subnet as needed
    SEARXNG_IP=$(nmap -p 8080 --open 192.168.1.0/24 -oG - | awk '/8080\/open/{print $2}' | head -1)
fi

if [ -z "$SEARXNG_IP" ]; then
    echo "ERROR: Could not discover SearXNG server"
    exit 1
fi

echo "Discovered SearXNG at: ${SEARXNG_IP}"

# Step 2: Verify the server is healthy
curl -s --connect-timeout 5 --max-time 10 "http://${SEARXNG_IP}:8080/healthz" || {
    echo "ERROR: Server at ${SEARXNG_IP} is not responding"
    exit 1
}

# Step 3: Verify JSON output is working
curl -s --connect-timeout 5 --max-time 10 \
    "http://${SEARXNG_IP}:8080/search?q=test&format=json" | jq -e '.results' >/dev/null || {
    echo "ERROR: Server returned invalid JSON. Ensure 'json' is enabled in SearXNG settings.yml"
    exit 1
}

# Step 4: Save to cache
echo "$SEARXNG_IP" > "$CACHE_FILE"
echo "SearXNG is ready at http://${SEARXNG_IP}:8080"
```
