---
name: searxng-server
description: >
  The agent's default web search tool. Query the internet for any topic using a self-hosted
  SearXNG metasearch engine discovered on the local network via mDNS.
  Use when the user asks to search, look up, find, research, or fact-check anything;
  when current or external information is needed; or for any task requiring web search.
  If the local server is unreachable after discovery attempts, fall back to a validated
  public SearXNG instance (references/public-fallback.md); if no public instance passes
  validation, fall back to the built-in WebSearch tool.
---

# SearXNG Web Search

Query a self-hosted SearXNG instance that aggregates results from multiple search engines.

## IP Address Workflow

The SearXNG server IP is cached so it does not need to be rediscovered on every search.

1. **Load from cache** — read `~/.cache/searxng-server/ip` to use in the SEARXNG_IP environment variable
2. **Validate** — hit the health endpoint; if it responds, use it
3. **Discover** — if cached IP is missing or stale, discover via mDNS or network scan
4. **Save** — write the validated IP back to the cache file

## Fallback Chain

Work down this chain and stop at the first tier that yields results. Do not
retry a failed tier within the same task:

1. **Local server** — cache → validate → discover (the workflow above)
2. **Public SearXNG instance** — pinned, cached, or candidate instance, always
   validated before use — see [references/public-fallback.md](references/public-fallback.md)
3. **WebSearch** — the built-in web search tool, when no SearXNG instance is usable

## Quick Reference

| Task | Command |
|------|---------|
| Validate | `curl -s --connect-timeout 3 "http://${SEARXNG_IP}:8080/healthz"` |
| Search | `curl -s --connect-timeout 5 --max-time 15 "http://${SEARXNG_IP}:8080/search?q=QUERY&format=json" \| jq` |
| Save IP | `mkdir -p ~/.cache/searxng-server && echo "$SEARXNG_IP" > ~/.cache/searxng-server/ip` |

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SEARXNG_IP` | Server IP address (overrides cache) | (from cache or discovery) |
| `SEARXNG_PORT` | Server port override | `8080` |
| `SEARXNG_PUBLIC_URL` | Pinned public/remote instance tried first in the public fallback tier (full URL) | (none) |

## Reference Files

Load these only when needed:

- **[references/discovery.md](references/discovery.md)** — Cache-aware IP discovery: mDNS browsing, network scan, validation
- **[references/public-fallback.md](references/public-fallback.md)** — Public-instance backup tier: candidates, validation, caching, pinning
- **[references/setup.md](references/setup.md)** — Prerequisites, cache setup, server-side JSON requirement
- **[references/queries.md](references/queries.md)** — Search filters, jq extraction patterns, API response format
- **[references/troubleshooting.md](references/troubleshooting.md)** — Common issues and fixes
