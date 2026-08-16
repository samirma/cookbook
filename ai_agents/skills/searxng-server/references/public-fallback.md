# Public Instance Fallback

When the local SearXNG server cannot be found or used, try a public SearXNG
instance before giving up on SearXNG entirely. The full fallback chain is:

1. **Local server** — cache → validate → discover (see [discovery.md](discovery.md))
2. **Public SearXNG instance** — this file
3. **Built-in web search tool** (WebSearch) — when no SearXNG instance is usable

## Why validation is mandatory

Public instances rarely enable the JSON API. `format=json` only works when the
operator adds `json` to `search.formats` in `settings.yml`; otherwise the
instance returns **403 Forbidden by design**. Most public operators leave JSON
disabled deliberately to deter bot scraping, and the SearXNG project publishes
no list of JSON-enabled public instances. Instance behavior also changes
without notice. So never assume a public instance works — validate before
every use (cheap, one request) and expect to fall through to WebSearch when
none pass.

## Selection order

1. **Pinned instance** — if `SEARXNG_PUBLIC_URL` is set, validate and use it
2. **Cached instance** — read `~/.cache/searxng-server/public_url`, validate it
3. **Candidate list** — probe the candidates below in order; first valid wins; save it to the cache
4. **None valid** — fall back to the built-in web search tool (WebSearch)

## Validation

The same authoritative check used for the local server — a JSON search that
parses. Note `-f`: without it, a 403/404 body would count as success.

```bash
check_public() {
    curl -sfG --connect-timeout 3 --max-time 10 \
        --data-urlencode "q=test" --data "format=json" \
        "${1}/search" | jq -e '.results' >/dev/null 2>&1
}
```

- **403** — the operator disabled JSON output; skip the instance, do not retry
- **429 or a CAPTCHA page** — rate limited; skip it for the rest of the session

## Candidate public instances

Reputable, long-running instances taken from https://searx.space. Most will
still fail the JSON check — that is expected; the loop exists to catch the
ones that do not:

```bash
PUBLIC_CANDIDATES=(
    "https://searx.be"
    "https://searx.tiekoetter.com"
    "https://priv.au"
    "https://opnxng.com"
    "https://search.inetol.net"
)
```

Refresh this list occasionally from https://searx.space (filter by uptime and
grade; uptime history at https://uptime.searxng.org) — public instances come
and go.

## Full fallback sequence

```bash
PUBLIC_CACHE="$HOME/.cache/searxng-server/public_url"
SEARXNG_URL=""

for candidate in "${SEARXNG_PUBLIC_URL}" "$(cat "$PUBLIC_CACHE" 2>/dev/null)" "${PUBLIC_CANDIDATES[@]}"; do
    [ -z "$candidate" ] && continue
    if check_public "$candidate"; then
        SEARXNG_URL="$candidate"
        mkdir -p "$(dirname "$PUBLIC_CACHE")"
        echo "$candidate" > "$PUBLIC_CACHE"
        break
    fi
done

if [ -n "$SEARXNG_URL" ]; then
    curl -sfG --connect-timeout 5 --max-time 15 \
        --data-urlencode "q=YOUR QUERY" --data "format=json" \
        "${SEARXNG_URL}/search" | jq '.results'
else
    echo "No public SearXNG instance usable — fall back to the WebSearch tool"
fi
```

The result format and jq extraction patterns from
[queries.md](queries.md) apply unchanged — only the base URL differs.

## Etiquette on public instances

Public instances are donated capacity. Use them as a backup, not a default:
prefer the local server, keep query volume low, never loop retries against
403/429 responses, and drop an instance for the session at the first sign of
rate limiting.

## The reliable backup: a remote instance you control

Because public instances rarely allow JSON and can revoke it at any time, the
dependable off-network backup is a second instance you operate (e.g. on a VPS)
with `json` enabled in `search.formats` (see [setup.md](setup.md)). Pin it so
it is always tried first:

```bash
export SEARXNG_PUBLIC_URL="https://searxng.example.com"
```
