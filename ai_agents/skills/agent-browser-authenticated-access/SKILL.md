---
name: agent-browser-authenticated-access
description: Access authenticated web pages by opening them in the user's existing browser profile via Chrome DevTools Protocol (CDP) on port 9222. The browser must already be logged in to the target site. Only works with Chromium-based browsers (Google Chrome, Microsoft Edge, Brave).
---

# Access Authenticated Web Pages

**Goal:** Open a URL using the user's existing browser profile so their active login sessions and cookies are available. This avoids asking the user to log in again.

**Requirement:** The user's browser must already be logged in to the target website. This skill does not perform authentication — it reuses the user's existing authenticated session.

> **Browser Support:** CDP (Chrome DevTools Protocol) only works with Chromium-based browsers — Google Chrome, Microsoft Edge, Brave, or Chromium. **Do not use Firefox, Safari, or other non-Chromium browsers.**

## How It Works

1. Identify which browser the user wants to use (or is already logged in with).
2. Start that browser with CDP enabled on port `9222`, using the user's **existing profile** (so cookies and sessions are preserved).
3. Use `agent-browser` to connect to that CDP session and open the URL.
4. The page opens with the user's real cookies — no extra login needed.

## Before You Start

Check the persisted preference file:
```
~/.agents/skills/agent-browser-authenticated-access/.browser-config.json
```

- If it exists and contains a `"browser"` value, **use that browser**.
- If it does **not** exist, **ask the user** which browser they are already logged in with (Google Chrome or Microsoft Edge only).
- After the user answers, write the choice to the config file for future reuse:
  ```json
  {
    "browser": "Google Chrome"
  }
  ```

## Start the Browser with CDP

You must start the exact browser from the config (or the user's answer) with CDP enabled on port `9222`. Use the user's default profile so their cookies and logins are available.

**Close all existing browser windows first** to avoid profile lock errors. Then start the browser:

**Google Chrome — macOS:**
```bash
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222 &
```

**Google Chrome — Linux:**
```bash
google-chrome --remote-debugging-port=9222 &
```

**Microsoft Edge — macOS:**
```bash
/Applications/Microsoft\ Edge.app/Contents/MacOS/Microsoft\ Edge --remote-debugging-port=9222 &
```

**Microsoft Edge — Linux:**
```bash
microsoft-edge --remote-debugging-port=9222 &
```

> **Why no `--user-data-dir` flag?** Omitting it uses the browser's default profile directory — the same one the user uses for normal browsing. This is exactly what we want, because that's where their cookies and logins are stored.

## Verify CDP Is Active

```bash
curl -s http://localhost:9222/json/version
```

- **If it returns JSON** with a `"Browser"` field → CDP is running. Proceed to open the URL.
- **If it fails** (connection refused, no response) → the browser did not start correctly. Close all browser windows and retry the start command above.

## Open the URL

```bash
agent-browser --cdp 9222 open "<TARGET_URL>"
agent-browser --cdp 9222 snapshot
```

If the snapshot shows the expected authenticated content, the task is complete.

## If a Login Page Appears

This means the browser is **not** using the user's authenticated profile. Possible causes:
- The browser was started with a guest or temporary profile.
- The user is not actually logged in to this site.
- An existing CDP session was running with a different profile.

**Fix:**
1. Close all browser windows completely.
2. Restart the browser using the commands in **Start the Browser with CDP** above.
3. Reopen the URL and recapture:
   ```bash
   agent-browser --cdp 9222 open "<TARGET_URL>" && agent-browser --cdp 9222 snapshot
   ```
4. If it still shows a login page, ask the user to log in manually in the browser window, then recapture again.

## Cleanup

Close only the CDP-connected session:
```bash
agent-browser --cdp 9222 close
```
