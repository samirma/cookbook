---
name: searxng-server
description: Discover and query a SearXNG metasearch server on the local network via mDNS discovery. The server publishes itself as _http._tcp with TXT record service=searxng. Use when user needs to discover the SearXNG search server and query its JSON API.
---

# SearXNG Server Discovery & Search

This skill helps discover and perform web searches using a self-hosted SearXNG metasearch engine that advertises itself via mDNS/Bonjour on the local network.

## Quick Reference

| Task | Command |
|------|---------|
| Discover server | `dns-sd -B _http._tcp \| grep -i searxng` |
| Get server URL | `searxng-url` (see helper below) |
| Search web | `searxng-search "query" 5` |
| Ping test | `ping -c 3 searxng-server.local` |
| Check health | `curl -s http://searxng-server.local:8080/healthz` |

## mDNS Service Advertisement

| Attribute | Value |
|-----------|-------|
| **Service Type** | `_http._tcp` |
| **TXT Record** | `service=searxng` |
| **Typical Hostname** | `searxng-server.local` |
| **Default Port** | 8080 |

## Prerequisites

Ensure your system has mDNS support:

- **macOS**: Built-in (Bonjour)
- **Linux**: Install `avahi-daemon` and `libnss-mdns`
  ```bash
  sudo apt update && sudo apt install -y avahi-daemon libnss-mdns
  sudo systemctl status avahi-daemon
  ```

## Server Discovery

### 1. Basic Resolution Test

```bash
ping -c 3 searxng-server.local
```

### 2. Browse for SearXNG Service

```bash
# macOS - Browse all HTTP services and filter for SearXNG
dns-sd -B _http._tcp | grep -i searxng

# macOS - Resolve SearXNG service details
dns-sd -L "SearXNG" _http._tcp local

# Linux (avahi-utils)
avahi-browse -r _http._tcp | grep -A 5 -i searxng

# Linux - Search for specific TXT record
avahi-browse -r _http._tcp 2>/dev/null | grep -B 2 "service=searxng"
```

### 3. Get IP Address

```bash
# macOS/Linux
dig +short searxng-server.local
getent hosts searxng-server.local

# Alternative using ping
ping -c 1 searxng-server.local | head -1
```

### 4. Verify Service is Running

```bash
# Check HTTP endpoint
curl -s http://searxng-server.local:8080/healthz

# Or use discovered IP
curl -s http://$(dig +short searxng-server.local):8080/healthz
```

## Web Search Queries

### Basic Search

```bash
# Using hostname
curl -s "http://searxng-server.local:8080/search?q=hello+world&format=json" | jq

# Using IP (if mDNS resolution has issues)
SEARXNG_IP=$(dig +short searxng-server.local)
curl -s "http://${SEARXNG_IP}:8080/search?q=hello+world&format=json" | jq
```

### Search with Filters

```bash
# Limit results and get specific fields
curl -s "http://searxng-server.local:8080/search?q=Python+tutorials&format=json" | \
  jq -r '.results[0:5] | .[] | "\(.title)\n\(.url)\n\(.content | substring(0,200))...\n"'

# Filter by language (en, de, fr, es, etc.)
curl -s "http://searxng-server.local:8080/search?q=news&lang=en&format=json" | jq '.results'

# Filter by category: news, images, videos, files, map, music, science, social_media, it, general
# Note: use underscore for multi-word categories
curl -s "http://searxng-server.local:8080/search?q=AI&categories=news&format=json" | jq '.results'

# Use specific search engines
curl -s "http://searxng-server.local:8080/search?q=docker&engines=google,duckduckgo&format=json" | jq '.results'

# Safe search (0=off, 1=moderate, 2=strict)
curl -s "http://searxng-server.local:8080/search?q=test&safesearch=2&format=json" | jq '.results'

# Time range: day, week, month, year
curl -s "http://searxng-server.local:8080/search?q=AI&time_range=week&format=json" | jq '.results'
```

### Get Results Summary

```bash
# Get just the titles and URLs
curl -s "http://searxng-server.local:8080/search?q=openai&format=json" | \
  jq -r '.results[] | "\(.title)\n  \(.url)\n"'

# Get total result count
curl -s "http://searxng-server.local:8080/search?q=linux&format=json" | \
  jq '.number_of_results'

# Get suggested corrections if available
curl -s "http://searxng-server.local:8080/search?q=recieve&format=json" | \
  jq '.suggestions'
```

## Shell Helper Functions

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Discover SearXNG server and return base URL
searxng-url() {
    local ip
    ip=$(dig +short searxng-server.local 2>/dev/null | head -1)
    if [ -n "$ip" ]; then
        echo "http://${ip}:8080"
    else
        echo "http://searxng-server.local:8080"
    fi
}

# Search using SearXNG
# Usage: searxng-search "query" [num_results] [language] [category]
searxng-search() {
    local query="$1"
    local num="${2:-10}"
    local lang="${3:-en}"
    local category="${4:-general}"
    local url=$(searxng-url)
    local encoded_query
    
    # URL encode the query
    encoded_query=$(printf '%s' "$query" | jq -sRr @uri)
    
    curl -s "${url}/search?q=${encoded_query}&format=json&lang=${lang}&categories=${category}" | \
        jq -r --arg n "$num" '.results[0:($n | tonumber)] | 
        .[] | "\n[\(.title)]\nURL: \(.url)\n\(.content)\n---"'
}

# Quick search - just URLs
searxng-urls() {
    local query="$1"
    local num="${2:-5}"
    local url=$(searxng-url)
    local encoded_query
    
    encoded_query=$(printf '%s' "$query" | jq -sRr @uri)
    
    curl -s "${url}/search?q=${encoded_query}&format=json" | \
        jq -r --arg n "$num" '.results[0:($n | tonumber)] | .[] | "\(.title)\n\(.url)"'
}
```

Then use:
```bash
# Get server URL
searxng-url

# Search with defaults (10 results, English, general category)
searxng-search "machine learning"

# Search with options: 5 results, German language, news category
searxng-search "climate change" 5 de news

# Get just URLs
searxng-urls "docker tutorial" 3
```

## Python Helper Script

Create a reusable search script at `~/.local/bin/searxng-search.py`:

```python
#!/usr/bin/env python3
"""SearXNG search client for local network server."""

import argparse
import json
import sys
import urllib.parse
import urllib.request
import socket


def resolve_searxng_host() -> str:
    """Resolve searxng-server.local to IP or return hostname."""
    try:
        ip = socket.getaddrinfo("searxng-server.local", None)[0][4][0]
        return f"http://{ip}:8080"
    except socket.gaierror:
        return "http://searxng-server.local:8080"


def search(query: str, num: int = 10, lang: str = "en", category: str = "general") -> dict:
    """Perform a search query against the SearXNG server."""
    base_url = resolve_searxng_host()
    params = {
        "q": query,
        "format": "json",
        "language": lang,
        "categories": category,
    }
    url = f"{base_url}/search?{urllib.parse.urlencode(params)}"
    
    try:
        with urllib.request.urlopen(url, timeout=30) as response:
            return json.loads(response.read().decode('utf-8'))
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description="Search using local SearXNG server")
    parser.add_argument("query", help="Search query")
    parser.add_argument("-n", "--num", type=int, default=10, help="Number of results")
    parser.add_argument("-l", "--lang", default="en", help="Language code")
    parser.add_argument("-c", "--category", default="general", help="Search category")
    parser.add_argument("--urls-only", action="store_true", help="Output only URLs")
    parser.add_argument("--json", action="store_true", help="Output raw JSON")
    
    args = parser.parse_args()
    
    result = search(args.query, args.num, args.lang, args.category)
    
    if args.json:
        print(json.dumps(result, indent=2))
        return
    
    results = result.get("results", [])[:args.num]
    
    for r in results:
        if args.urls_only:
            print(r["url"])
        else:
            print(f"\n[{r['title']}]")
            print(f"URL: {r['url']}")
            if r.get('content'):
                print(r['content'][:200] + "..." if len(r['content']) > 200 else r['content'])
            print("-" * 40)


if __name__ == "__main__":
    main()
```

Make it executable and use:
```bash
chmod +x ~/.local/bin/searxng-search.py

# Basic search
searxng-search.py "python tutorials"

# Get 5 results in German, news category
searxng-search.py "weather" -n 5 -l de -c news

# Just URLs
searxng-search.py "docker compose" --urls-only

# Raw JSON output
searxng-search.py "linux commands" --json
```

## Troubleshooting

### Cannot Resolve Hostname

```bash
# Check mDNS is working locally
ping -c 1 $(hostname).local

# Browse all mDNS services
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

### Connection Issues

```bash
# Test direct connection
curl -v http://searxng-server.local:8080/

# Check if port is open
nmap -p 8080 searxng-server.local
```

### Alternative: Use IP Directly

If mDNS doesn't work, find the IP manually:

```bash
# Scan network for port 8080
nmap -p 8080 --open 192.168.1.0/24

# Then use IP directly
export SEARXNG_URL="http://192.168.1.100:8080"
curl -s "${SEARXNG_URL}/search?q=test&format=json" | jq
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

## One-Liners

```bash
# Get top 3 search results as URLs
curl -s "http://searxng-server.local:8080/search?q=docker+compose&format=json" | jq -r '.results[0:3].url'

# Search and open first result (macOS)
open $(curl -s "http://searxng-server.local:8080/search?q=github&format=json" | jq -r '.results[0].url')

# Check server health
curl -s http://searxng-server.local:8080/healthz && echo "Server is up"

# Search and save results to file
curl -s "http://searxng-server.local:8080/search?q=linux&format=json" | jq '.' > search_results.json
```
