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

> [!IMPORTANT]
> **You MUST completely QUIT/EXIT all existing instances of the browser before starting it with CDP.** 
> Simply closing the browser windows is NOT sufficient, especially on macOS where the browser process continues to run in the Dock, or on other OSs where background processes persist.
> If the browser is already running, launching it with `--remote-debugging-port=9222` will fail silently—Chromium will simply open a window in the existing instance and ignore the debugging port. This will cause the CDP port check (`curl`) to fail, often tempting agents to incorrectly fall back to a temporary profile.

### Step 1: Fully Quit/Kill Existing Browser Processes

To ensure the browser is completely closed and its profile directory is unlocked, run the appropriate command:

**Google Chrome — macOS:**
```bash
# Gracefully quit Google Chrome
osascript -e 'quit app "Google Chrome"'
# Wait 1-2 seconds, or force quit if still running
killall "Google Chrome" 2>/dev/null
```

**Google Chrome — Linux:**
```bash
killall google-chrome 2>/dev/null
killall chrome 2>/dev/null
```

**Microsoft Edge — macOS:**
```bash
# Gracefully quit Microsoft Edge
osascript -e 'quit app "Microsoft Edge"'
# Wait 1-2 seconds, or force quit if still running
killall "Microsoft Edge" 2>/dev/null
```

**Microsoft Edge — Linux:**
```bash
killall microsoft-edge 2>/dev/null
killall msedge 2>/dev/null
```

### Step 2: Start the Browser with Remote Debugging

Run the launch command for the selected browser.

> [!WARNING]
> **NEVER use the `--user-data-dir`, `--profile-directory`, or `--incognito`/`--private` flags.**
> Omitting these flags forces Chromium to use the user's default profile directory, which is exactly where their active login sessions and cookies are stored. Adding a custom `--user-data-dir` will open a blank, new profile, causing all authenticated page loads to fail and require login.

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

## Verify CDP Is Active

```bash
curl -s http://localhost:9222/json/version
```

- **If it returns JSON** with a `"Browser"` field → CDP is running successfully using the user's default profile. Proceed to open the URL.
- **If it fails** (connection refused, no response, or command hangs) → the browser did not start with CDP active. This is almost always because an existing browser instance was still running in the background.
  - **Do NOT** attempt to bypass this by running a command with `--user-data-dir`.
  - **Instead**, rerun the quit/kill command from Step 1, wait 2 seconds, and retry starting the browser.

## Open the URL

```bash
agent-browser --cdp 9222 open "<TARGET_URL>"
agent-browser --cdp 9222 snapshot
```

If the snapshot shows the expected authenticated content, the task is complete.

## If a Login Page Appears

This means the browser is **not** using the user's authenticated profile. Possible causes:
- The browser was started with a guest or temporary profile (e.g., you accidentally used `--user-data-dir` or `--profile-directory`).
- The user is not actually logged in to this site in their main profile.
- An existing CDP session was running with a different profile.

**Fix:**
1. Quit the browser completely using the quit/kill commands from Step 1.
2. Double-check that no temporary profile flags (`--user-data-dir`, `--profile-directory`, `--incognito`) are being used.
3. Restart the browser using the commands in **Start the Browser with CDP** above.
4. Reopen the URL and recapture:
   ```bash
   agent-browser --cdp 9222 open "<TARGET_URL>" && agent-browser --cdp 9222 snapshot
   ```
5. If it still shows a login page, ask the user to open their browser normally (without CDP), log in to the site, then quit the browser completely and restart it with CDP enabled.

## Cleanup

Close only the CDP-connected session:
```bash
agent-browser --cdp 9222 close
```
