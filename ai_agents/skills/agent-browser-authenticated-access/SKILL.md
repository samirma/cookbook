---
name: agent-browser-authenticated-access
description: Access authenticated web pages using the user's existing browser session via Chrome DevTools Protocol (CDP) on port 9222. Only works with Chromium-based browsers (Chrome, Edge, Brave).
---

# Access Authenticated Web Pages

Open URLs requiring authentication by connecting to the user's already-logged-in browser via CDP.

## Quick Commands

```bash
# Check if CDP is active
curl -s http://localhost:9222/json/version

# Open URL and capture content
agent-browser --cdp 9222 open "<URL>"
agent-browser --cdp 9222 snapshot

# Close CDP session
agent-browser --cdp 9222 close
```

## Workflow

### 1. Connect to browser

Check if CDP is already running:
```bash
curl -s http://localhost:9222/json/version
```

If **not running**, start Chrome or Edge with CDP using the user's existing profile:

```bash
# macOS example
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222 &

# Linux example
google-chrome --remote-debugging-port=9222 &
```

> **Note:** If you get a "profile locked" error, close all browser windows first, then retry.

Verify CDP is active:
```bash
curl -s http://localhost:9222/json/version
```

### 2. Open the URL

```bash
agent-browser --cdp 9222 open "<URL>"
agent-browser --cdp 9222 snapshot
```

If the snapshot shows a **login page**, ask the user to log in manually in the browser window, then rerun:
```bash
agent-browser --cdp 9222 open "<URL>" && agent-browser --cdp 9222 snapshot
```

### 3. Cleanup

```bash
agent-browser --cdp 9222 close
```
