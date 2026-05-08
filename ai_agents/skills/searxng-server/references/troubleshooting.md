# Troubleshooting

## Cannot Resolve Hostname

```bash
# Check mDNS is working locally
ping -c 1 $(hostname).local

# Browse all mDNS services (Ctrl+C to stop)
dns-sd -B _http._tcp        # macOS
avahi-browse -a             # Linux

# Query specific hostname (replace with actual hostname)
dns-sd -q <hostname>.local

# Check TXT record contains service=searxng
dns-sd -Z _http._tcp local | grep -A 3 -i searxng
```

## Server Not Found

1. **Verify SearXNG is running** on the server
2. **Check mDNS daemon** on the server:
   ```bash
   sudo systemctl status avahi-daemon
   avahi-browse -r _http._tcp | grep -i searxng
   ```
3. **Same network**: Ensure both devices are on the same subnet
4. **Firewall**: Check port 8080 and mDNS (port 5353) are not blocked
5. **Find IP manually** if mDNS is unavailable:
   ```bash
   nmap -p 8080 --open 192.168.1.0/24
   curl -s --connect-timeout 5 "http://<IP>:8080/healthz"
   ```

## Connection Issues

```bash
# Test direct connection to IP
curl -v --connect-timeout 5 "http://${SEARXNG_IP}:8080/"

# Check if port is open
nmap -p 8080 "${SEARXNG_IP}"
```

## HTML Response Instead of JSON

If `jq` fails to parse output, SearXNG is returning HTML. JSON output is **not enabled** on the server.

**Fix**: Add `json` to `search.formats` in `settings.yml` and restart:

```yaml
search:
  formats:
    - html
    - json
```

Verify:
```bash
curl -s --connect-timeout 5 "http://${SEARXNG_IP}:8080/search?q=test&format=json" | head -1
# Should start with '{', not '<'
```

## No Results Returned

If the API responds with valid JSON but `.results` is empty:

1. **Check engine configuration** — SearXNG may have no search engines enabled
2. **Rate limiting** — Search engines may have blocked the SearXNG instance. Try:
   - Adding `&engines=duckduckgo` or `&engines=bing`
   - Checking SearXNG logs for engine errors
3. **Query too restrictive** — Try a broader search term
4. **Safe search** — If `safesearch=2`, some results may be filtered

## Stale Cache

If the cached IP no longer responds, the server may have moved to a different address:

```bash
# Remove stale cache
rm ~/.cache/searxng-server/ip

# Rediscover the server
# (see references/discovery.md for discovery methods)
```

## Alternative: Static IP

If mDNS doesn't work reliably, set a static IP on the server:

```bash
export SEARXNG_IP="192.168.1.100"
export SEARXNG_PORT=8080
curl -s --connect-timeout 5 "http://${SEARXNG_IP}:${SEARXNG_PORT}/search?q=test&format=json" | jq
```
