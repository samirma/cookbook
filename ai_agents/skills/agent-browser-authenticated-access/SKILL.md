---
name: agent-browser-authenticated-access
description: Access authenticated web pages (Confluence, Jira, internal tools) using agent-browser with the user's real browser profile and cookies. Use when you need to retrieve content from URLs that require authentication.
---

# Accessing Authenticated Pages with agent-browser

This skill enables `agent-browser` to access authenticated web pages (such as Confluence, Jira, or other internal tools) by leveraging the user's real browser profile and cookies via Chrome DevTools Protocol (CDP).

## Quick Reference

| Task | Command |
|------|---------|
| Close stale sessions | `agent-browser close --all 2>/dev/null \|\| true` |
| Launch browser with CDP | `nohup "<browser>" --remote-debugging-port=9222 --user-data-dir="<profile>" --no-first-run >/dev/null 2>&1 &` |
| Verify CDP active | `curl -s http://localhost:9222/json/version` |
| Open URL | `agent-browser --cdp 9222 open "<URL>"` |
| Get page snapshot | `agent-browser --cdp 9222 snapshot` |
| Get page text | `agent-browser --cdp 9222 get text` |
| Close session | `agent-browser close --all` |

## When to Use

Use this skill when:
- User provides a Confluence, Jira, or other authenticated URL
- You need to access internal tools or documentation behind login
- Regular `webfetch` returns login pages or authentication errors

## Prerequisites

1. **agent-browser** installed:
   ```bash
   npx skills add vercel-labs/agent-browser
   ```

2. One of the supported browsers installed:
   - Google Chrome
   - Microsoft Edge

## Step-by-Step Instructions

### Step 1: Determine Browser Preference

Check for persisted browser preference:

```bash
cat ~/.agents/skills/agent-browser-authenticated-access/.browser-config.json 2>/dev/null
```

If not found, **ask the user** which browser to use:
- Google Chrome
- Microsoft Edge

Then save the preference:

```bash
mkdir -p ~/.agents/skills/agent-browser-authenticated-access
echo '{"browser": "Microsoft Edge"}' > ~/.agents/skills/agent-browser-authenticated-access/.browser-config.json
```

### Step 2: Browser Configuration

| Browser | Binary Path | User Data Dir |
|---------|-------------|---------------|
| Google Chrome | `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome` | `$HOME/Library/Application Support/Google/Chrome` |
| Microsoft Edge | `/Applications/Microsoft Edge.app/Contents/Microsoft Edge` | `$HOME/Library/Application Support/Microsoft Edge` |

### Step 3: Launch Browser with CDP

**A. Close any stale agent-browser sessions:**
```bash
agent-browser close --all 2>/dev/null || true
```

**B. Launch the browser with Remote Debugging Port (CDP):**

For **Microsoft Edge**:
```bash
nohup "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
  --remote-debugging-port=9222 \
  --user-data-dir="$HOME/Library/Application Support/Microsoft Edge" \
  --no-first-run >/dev/null 2>&1 &
sleep 5
```

For **Google Chrome**:
```bash
nohup "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --remote-debugging-port=9222 \
  --user-data-dir="$HOME/Library/Application Support/Google/Chrome" \
  --no-first-run >/dev/null 2>&1 &
sleep 5
```

**C. Verify CDP is active:**
```bash
curl -s http://localhost:9222/json/version
```

Expected output includes `"Browser"` field with browser info.

### Step 4: Navigate to Target URL

```bash
agent-browser --cdp 9222 open "<TARGET_URL>"
```

Wait a few seconds for the page to settle before reading.

### Step 5: Extract Page Content

**Option A - Snapshot (recommended):**
```bash
agent-browser --cdp 9222 snapshot
```

**Option B - Text extraction:**
```bash
agent-browser --cdp 9222 get text
```

### Step 6: Handle Authentication

If the page shows a login screen:
1. Instruct the user to authenticate in the opened browser window
2. Wait for user confirmation
3. Re-read the page:
   ```bash
   agent-browser --cdp 9222 open "<TARGET_URL>" && agent-browser --cdp 9222 snapshot
   ```

### Step 7: Cleanup (Optional)

Close the agent-browser session when done:
```bash
agent-browser close --all
```

## Helper Script

Create a helper script at `~/.local/bin/auth-browser-open`:

```bash
#!/bin/bash
# Open authenticated browser with CDP for agent-browser
# Usage: auth-browser-open <URL> [chrome|edge]

set -e

BROWSER="${2:-edge}"
URL="$1"

if [ -z "$URL" ]; then
    echo "Usage: auth-browser-open <URL> [chrome|edge]"
    exit 1
fi

# Browser configurations
case "$BROWSER" in
    chrome)
        BINARY="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
        PROFILE="$HOME/Library/Application Support/Google/Chrome"
        ;;
    edge)
        BINARY="/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
        PROFILE="$HOME/Library/Application Support/Microsoft Edge"
        ;;
    *)
        echo "Unknown browser: $BROWSER. Use 'chrome' or 'edge'."
        exit 1
        ;;
esac

# Close stale sessions
agent-browser close --all 2>/dev/null || true

# Launch browser with CDP
echo "Launching $BROWSER with CDP on port 9222..."
nohup "$BINARY" \
    --remote-debugging-port=9222 \
    --user-data-dir="$PROFILE" \
    --no-first-run >/dev/null 2>&1 &
sleep 5

# Verify CDP
if ! curl -s http://localhost:9222/json/version | grep -q "Browser"; then
    echo "ERROR: CDP not responding. Is the browser already running without CDP?"
    echo "Try: killall \"$(basename "$BINARY")\" and run again."
    exit 1
fi

# Open URL
echo "Opening: $URL"
agent-browser --cdp 9222 open "$URL"
sleep 3

# Get snapshot
echo "--- Page Content ---"
agent-browser --cdp 9222 snapshot
```

Make it executable:
```bash
chmod +x ~/.local/bin/auth-browser-open

# Usage:
auth-browser-open "https://confluence.example.com/page" edge
```

## Troubleshooting

### CDP Not Responding

If `curl -s http://localhost:9222/json/version` fails:

1. Check if browser is already running without CDP:
   ```bash
   ps aux | grep -i "chrome\|edge"
   ```

2. Kill the browser and try again:
   ```bash
   # For Edge
   killall "Microsoft Edge"
   
   # For Chrome
   killall "Google Chrome"
   ```

3. Retry Step 3 (launch browser with CDP)

### Profile Locked Error

If you get a profile locked error:
1. Ensure no other instances of the browser are running
2. Check for stale lock files:
   ```bash
   # For Chrome
   rm -f "$HOME/Library/Application Support/Google/Chrome/SingletonLock"
   
   # For Edge
   rm -f "$HOME/Library/Application Support/Microsoft Edge/SingletonLock"
   ```

### Page Still Shows Login

1. The user may need to authenticate manually in the browser window
2. After login, refresh the page:
   ```bash
   agent-browser --cdp 9222 open "<URL>" && agent-browser --cdp 9222 snapshot
   ```

### Content Truncated

If snapshot output is truncated, try:
```bash
# Get full text
agent-browser --cdp 9222 get text

# Or take a screenshot for visual inspection
agent-browser --cdp 9222 screenshot /tmp/page.png
```

## Security Notes

- **Never share browser profile data** - The CDP connection uses your real browser profile
- **Close sessions when done** - Run `agent-browser close --all` to clean up
- **Be cautious with sensitive URLs** - The browser window is visible on your desktop
- **Profile data stays local** - No data is sent to external services

## Related Skills

- **agent-browser** — Core browser automation capabilities (must be installed first)
- **agent-device** — For mobile/TV device automation

## Resources

- [agent-browser Documentation](https://agent-browser.dev/)
- [Chrome DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/)