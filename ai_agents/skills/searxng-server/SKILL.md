---
name: searxng-server
description: The agent's default web search tool. Query the internet for any topic at any time using a self-hosted SearXNG metasearch engine discovered on the local network via mDNS (_http._tcp, TXT service=searxng). Use for all web searches, fact-checking, research, and current information retrieval.
---

# SearXNG Web Search

This skill enables the agent to search the internet at any time using a self-hosted SearXNG metasearch engine on the local network. SearXNG aggregates results from multiple search engines (Google, DuckDuckGo, Bing, etc.) and returns them as structured JSON.

## When to Use This Skill

- **Default search tool**: Use for ANY question requiring current, factual, or external information from the web
- The user asks "search for...", "look up...", "find...", or any research task
- Fact-checking, comparing information, or gathering sources
- The user wants privacy-preserving search (queries stay on the local network)
- **Fallback**: If the SearXNG server is unreachable after discovery attempts, use the `SearchWeb` tool instead

## Important: Always Use IP Address

**Do not rely on `searxng-server.local` in API commands.** mDNS resolution can be unreliable across subnets, VPNs, Docker networks, and some Linux distributions. Always discover the server's IP address first and use the IP directly in all API calls.

The `.local` hostname should only be used for the initial mDNS discovery step.

## Quick Reference

| Task | Command |
|------|---------|
| Discover server IP | `SEARXNG_IP=$(dig +short searxng-server.local)` |
| Browse mDNS services | `dns-sd -B _http._tcp` (Ctrl+C after results appear) |
| Verify health | `curl -s --connect-timeout 5 http://${SEARXNG_IP}:8080/healthz` |
| Search web | `curl -s --connect-timeout 5 "http://${SEARXNG_IP}:8080/search?q=query&format=json" \| jq` |

## mDNS Service Advertisement

| Attribute | Value |
|-----------|-------|
| **Service Type** | `_http._tcp` |
| **TXT Record** | `service=searxng` |
| **Typical Hostname** | `searxng-server.local` (for discovery only) |
| **Default Port** | 8080 |

## Prerequisites

### System Requirements

- **macOS**: Built-in Bonjour (mDNS) support
- **Linux**: Install `avahi-daemon` and `libnss-mdns`
  ```bash
  sudo apt update && sudo apt install -y avahi-daemon libnss-mdns
  sudo systemctl status avahi-daemon
  ```

### Required Tools

- `curl` — for HTTP requests
- `jq` — for JSON parsing
- `dig` — for DNS resolution (usually in `bind-utils` or `dnsutils`)

### Server-Side Requirement

**Critical**: The SearXNG server must have JSON output enabled in `settings.yml`:

```yaml
search:
  formats:
    - html
    - json
```

Without this, `format=json` returns HTML and all `jq` parsing will fail. Restart SearXNG after modifying this setting.

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SEARXNG_IP` | Discovered server IP address | (none, must be set) |
| `SEARXNG_PORT` | Server port override | `8080` |

**All examples below assume `SEARXNG_IP` is exported:**

```bash
export SEARXNG_IP=$(dig +short searxng-server.local)
export SEARXNG_PORT=8080
```

## First Time Setup Workflow

Run this exact sequence before performing any searches:

```bash
# Step 1: Discover the server IP
export SEARXNG_IP=$(dig +short searxng-server.local)

if [ -z "$SEARXNG_IP" ]; then
    echo "ERROR: Could not resolve searxng-server.local via mDNS"
    echo "Try manual discovery with: nmap -p 8080 --open 192.168.1.0/24"
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

echo "SearXNG is ready at http://${SEARXNG_IP}:8080"
```

## Server Discovery

### 1. Discover the IP Address

```bash
# Preferred: Resolve via mDNS (returns IP)
dig +short searxng-server.local

# Alternative: getent
getent hosts searxng-server.local | awk '{print $1}'

# Alternative: resolve via ping
ping -c 1 searxng-server.local | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'

# Alternative: browse mDNS and extract IP (macOS)
# Note: dns-sd -B runs continuously; press Ctrl+C after seeing results
dns-sd -B _http._tcp | grep -i searxng
# Then resolve the specific instance:
dns-sd -L "SearXNG" _http._tcp local
```

**IPv6 Handling**: If mDNS returns an IPv6 address, wrap it in brackets for curl:
```bash
# If SEARXNG_IP contains a colon, it's IPv6
if [[ "$SEARXNG_IP" == *:* ]]; then
    SEARXNG_URL="http://[${SEARXNG_IP}]:8080"
else
    SEARXNG_URL="http://${SEARXNG_IP}:8080"
fi
```

### 2. Manual Discovery (if mDNS Fails)

```bash
# Scan local network for port 8080
nmap -p 8080 --open 192.168.1.0/24

# Verify candidate IPs
curl -s --connect-timeout 5 "http://<CANDIDATE_IP>:8080/healthz"

# Or test the search endpoint directly
curl -s --connect-timeout 5 "http://<CANDIDATE_IP>:8080/search?q=test&format=json" | jq '.'
```

### 3. Verify Service is Running

```bash
# Health endpoint
curl -s --connect-timeout 5 "http://${SEARXNG_IP}:8080/healthz"

# Root endpoint (should return HTML)
curl -s --connect-timeout 5 "http://${SEARXNG_IP}:8080/" | head -20
```

## Web Search Queries

**Note**: All examples assume `SEARXNG_IP` is already exported.

### Basic Search

```bash
curl -s --connect-timeout 5 --max-time 15 \
    "http://${SEARXNG_IP}:8080/search?q=hello+world&format=json" | jq
```

### Search with Filters

```bash
# Limit results and get specific fields with snippet truncation
curl -s --connect-timeout 5 --max-time 15 \
    "http://${SEARXNG_IP}:8080/search?q=Python+tutorials&format=json" | \
    jq -r '.results[0:5] | .[] | "\(.title)\n\(.url)\n\(.content | substring(0,200))...\n"'

# Filter by language (en, de, fr, es, etc.)
curl -s --connect-timeout 5 --max-time 15 \
    "http://${SEARXNG_IP}:8080/search?q=news&language=en&format=json" | jq '.results'

# Filter by category: news, images, videos, files, map, music, science, social_media, it, general
# Note: use underscore for multi-word categories
curl -s --connect-timeout 5 --max-time 15 \
    "http://${SEARXNG_IP}:8080/search?q=AI&categories=news&format=json" | jq '.results'

# Use specific search engines
curl -s --connect-timeout 5 --max-time 15 \
    "http://${SEARXNG_IP}:8080/search?q=docker&engines=google,duckduckgo&format=json" | jq '.results'

# Safe search (0=off, 1=moderate, 2=strict)
curl -s --connect-timeout 5 --max-time 15 \
    "http://${SEARXNG_IP}:8080/search?q=test&safesearch=2&format=json" | jq '.results'

# Time range: day, week, month, year
curl -s --connect-timeout 5 --max-time 15 \
    "http://${SEARXNG_IP}:8080/search?q=AI&time_range=week&format=json" | jq '.results'

# Pagination (pageno starts at 1)
curl -s --connect-timeout 5 --max-time 15 \
    "http://${SEARXNG_IP}:8080/search?q=linux&pageno=2&format=json" | jq '.results'
```

### Get Results Summary

```bash
# Get just the titles and URLs
curl -s --connect-timeout 5 --max-time 15 \
    "http://${SEARXNG_IP}:8080/search?q=openai&format=json" | \
    jq -r '.results[] | "\(.title)\n  \(.url)\n"'

# Get total result count
curl -s --connect-timeout 5 --max-time 15 \
    "http://${SEARXNG_IP}:8080/search?q=linux&format=json" | \
    jq '.number_of_results'

# Get suggested corrections if available
curl -s --connect-timeout 5 --max-time 15 \
    "http://${SEARXNG_IP}:8080/search?q=recieve&format=json" | \
    jq '.suggestions'
```

### Common jq Extraction Patterns

```bash
# Title and URL only
jq -r '.results[] | "\(.title)\n\(.url)"'

# Top 5 with truncated content
jq -r '.results[0:5] | .[] | "[\(.title)]\n\(.url)\n\(.content[:150])...\n---"'

# URLs only
jq -r '.results[].url'

# Results with engine source info
jq -r '.results[] | "[\(.engines | join(","))] \(.title)"'

# Check if no results
jq 'if (.results | length) == 0 then "No results" else .results end'
```

## API Response Format

```json
{
  "query": "search term",
  "number_of_results": 10000000,
  "results": [
    {
      "url": "https://example.com",
      "title": "Page Title",
      "content": "Snippet of the page content...",
      "engines": ["google", "duckduckgo"],
      "score": 1.0
    }
  ],
  "suggestions": ["alternative query"],
  "answers": [],
  "corrections": []
}
```

## Troubleshooting

### Cannot Resolve Hostname

```bash
# Check mDNS is working locally
ping -c 1 $(hostname).local

# Browse all mDNS services (Ctrl+C to stop)
dns-sd -B _http._tcp        # macOS
avahi-browse -a             # Linux

# Query specific record
dns-sd -q searxng-server.local

# Check if TXT record contains service=searxng
dns-sd -Z _http._tcp local | grep -A 3 -i searxng
```

### Server Not Found

1. **Verify SearXNG is running** on the server
2. **Check mDNS daemon** is running on the server:
   ```bash
   # On the server (e.g., Raspberry Pi)
   sudo systemctl status avahi-daemon
   avahi-browse -r _http._tcp | grep -i searxng
   ```
3. **Same network**: Ensure both devices are on the same subnet
4. **Firewall**: Check port 8080 and mDNS (port 5353) are not blocked
5. **Find IP manually** if mDNS is unavailable:
   ```bash
   nmap -p 8080 --open 192.168.1.0/24
   # Test candidate IPs directly
   curl -s --connect-timeout 5 "http://<IP>:8080/healthz"
   ```

### Connection Issues

```bash
# Test direct connection to IP (replace with actual IP)
curl -v --connect-timeout 5 "http://${SEARXNG_IP}:8080/"

# Check if port is open
nmap -p 8080 "${SEARXNG_IP}"
```

### HTML Response Instead of JSON

If `jq` fails to parse output, SearXNG is likely returning HTML. This means JSON output is **not enabled** on the server.

**Fix**: Add `json` to `search.formats` in `settings.yml` and restart:

```yaml
search:
  formats:
    - html
    - json
```

Verify with:
```bash
curl -s --connect-timeout 5 "http://${SEARXNG_IP}:8080/search?q=test&format=json" | head -1
# Should start with '{', not '<'
```

### No Results Returned

If the API responds with valid JSON but `.results` is empty:

1. **Check engine configuration** — SearXNG may have no search engines enabled
2. **Rate limiting** — Search engines may have blocked the SearXNG instance. Try:
   - Adding `&engines=duckduckgo` or `&engines=bing` to force specific engines
   - Checking SearXNG logs for engine errors
3. **Query too restrictive** — Try a broader search term
4. **Safe search** — If `safesearch=2`, some results may be filtered

### Alternative: Use Static IP

If mDNS doesn't work reliably, set a static IP on the server and use it directly:

```bash
export SEARXNG_IP="192.168.1.100"
export SEARXNG_PORT=8080
curl -s --connect-timeout 5 "http://${SEARXNG_IP}:${SEARXNG_PORT}/search?q=test&format=json" | jq
```
