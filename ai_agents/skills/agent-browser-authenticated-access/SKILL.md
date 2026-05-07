---
name: agent-browser-authenticated-access
description: Access authenticated web pages (Confluence, Jira, internal tools) using agent-browser with the user's browser profile and cookies. Use when you need to retrieve content from URLs that require authentication.
---

# Access Authenticated Web Pages

## When to Use
Use this skill when you need to retrieve content from URLs requiring authentication (Confluence, Jira, internal tools). Leverages the user's real browser profile and cookies.

## Quick Reference

| Task | Command |
|------|---------|
| Open URL | `agent-browser --cdp 9222 open "<URL>"` |
| Read page content | `agent-browser --cdp 9222 snapshot` |
| Get clean text | `agent-browser --cdp 9222 get text` |
| Close session | `agent-browser close --all` |

## Workflow

### 1. Start browser session
Ensure that the target page really requires an authenticated session.

**Determine which browser to use:**
- **First**, check the persisted preference file: `~/.agents/skills/agent-browser-authenticated-access/.browser-config.json`.
  - If it exists and contains a `"browser"` value, use that browser.
  - If it does **not** exist, **ask the user** which browser they want to use or already have the target page logged in (e.g., Google Chrome, Microsoft Edge, Safari, Firefox).
  - After the user answers, write the choice to `~/.agents/skills/agent-browser-authenticated-access/.browser-config.json` so it is reused automatically in future sessions.
    ```json
    {
      "browser": "Microsoft Edge"
    }
    ```

**Start the browser with CDP:**
- Consult the agent-browser documentation at https://agent-browser.dev/cdp-model for the correct procedure to start the chosen browser with Chrome DevTools Protocol (CDP) enabled on port 9222, using the user's existing browser profile to leverage their authenticated sessions.

**Verify CDP is active:**
```bash
curl -s http://localhost:9222/json/version
```
If this does not return valid JSON with a `"Browser"` field:
1. Check if the browser is already running without CDP enabled
2. If so, ask the user to close all browser windows, then retry starting with CDP
3. Wait a few seconds after launch and retry the verification

**If CDP is already active:**
Do not assume the existing browser instance is using the user's authenticated profile. An existing CDP session may be running with a guest, incognito, or stale profile. Proceed to open the target page and verify you can access it. If the page shows a login screen, access denied, or "not found" when the user expects access, close the browser completely and restart it fresh with CDP on port 9222 using the user's default profile.

### 2. Open and read the target page
```bash
agent-browser --cdp 9222 open "<TARGET_URL>"
sleep 3
agent-browser --cdp 9222 snapshot
```

### 3. Handle authentication if needed
If a login screen appears:
- On a **freshly started** browser, ask the user to authenticate in the opened browser window, then re-open the page:
  ```bash
  agent-browser --cdp 9222 open "<TARGET_URL>" && agent-browser --cdp 9222 snapshot
  ```
- On an **existing** CDP session, the browser is likely not using the user's authenticated profile. Close all browser windows, restart the browser fresh with CDP on port 9222, then re-open the target page.

### 4. Complete the task
Use the retrieved content to answer the user's request.

### 5. Cleanup (optional)
```bash
agent-browser close --all
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Browser fails to start | Check Chrome or Edge is installed; verify no conflicting instances |
| CDP not responding | Browser may be running without CDP. Ask user to close all browser windows and retry |
| CDP connection refused | Wait a few seconds, then retry; ensure port 9222 is available |
| Profile locked error | Close all browser instances and remove lock file from profile directory |
| Still on login page | User needs to authenticate manually in the browser window |
| Existing CDP session not authenticated | Close all browser windows, restart the browser fresh with `--remote-debugging-port=9222`, and retry |
| Stale session errors | Run `agent-browser close --all` and retry |
