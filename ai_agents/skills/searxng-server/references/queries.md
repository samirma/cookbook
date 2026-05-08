# Search Queries and Filters

All examples assume `SEARXNG_IP` is exported.

## Basic Search

```bash
curl -s --connect-timeout 5 --max-time 15 \
    "http://${SEARXNG_IP}:8080/search?q=hello+world&format=json" | jq
```

## Available Filters

```bash
# Language (en, de, fr, es, etc.)
curl -s --connect-timeout 5 --max-time 15 \
    "http://${SEARXNG_IP}:8080/search?q=news&language=en&format=json" | jq '.results'

# Category: news, images, videos, files, map, music, science, social_media, it, general
curl -s --connect-timeout 5 --max-time 15 \
    "http://${SEARXNG_IP}:8080/search?q=AI&categories=news&format=json" | jq '.results'

# Specific engines
curl -s --connect-timeout 5 --max-time 15 \
    "http://${SEARXNG_IP}:8080/search?q=docker&engines=google,duckduckgo&format=json" | jq '.results'

# Safe search: 0=off, 1=moderate, 2=strict
curl -s --connect-timeout 5 --max-time 15 \
    "http://${SEARXNG_IP}:8080/search?q=test&safesearch=2&format=json" | jq '.results'

# Time range: day, week, month, year
curl -s --connect-timeout 5 --max-time 15 \
    "http://${SEARXNG_IP}:8080/search?q=AI&time_range=week&format=json" | jq '.results'

# Pagination (pageno starts at 1)
curl -s --connect-timeout 5 --max-time 15 \
    "http://${SEARXNG_IP}:8080/search?q=linux&pageno=2&format=json" | jq '.results'
```

## Result Extraction with jq

```bash
# Titles and URLs only
jq -r '.results[] | "\(.title)\n  \(.url)"'

# Top 5 with truncated snippets
jq -r '.results[0:5] | .[] | "\(.title)\n\(.url)\n\(.content | substring(0,200))...\n"'

# URLs only
jq -r '.results[].url'

# Results with engine source info
jq -r '.results[] | "[\(.engines | join(","))] \(.title)"'

# Total result count
jq '.number_of_results'

# Suggested corrections
jq '.suggestions'

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
