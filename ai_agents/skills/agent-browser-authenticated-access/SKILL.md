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

Determine which browser to use
- **First**, check the persisted preference file: `~/.agents/skills/agent-browser-authenticated-access/.browser-config.json`.
  - If it exists and contains a `"browser"` value, use that browser.
  - If it does **not** exist, **ask the user** which browser they want to use or already have the target page logged in (e.g., Google Chrome, Microsoft Edge, Safari, Firefox).
  - After the user answers, write the choice to `~/.agents/skills/agent-browser-authenticated-access/.browser-config.json` so it is reused automatically in future sessions.
    ```json
    {
      "browser": "Microsoft Edge"
    }
    ```

Them read the browser configuration, find its executable path, and start the browser with remote debugging enabled on port 9222 using Chrome DevTools Protocol to load the same profile used by the user to laverage its session to be read to be connected as per the https://agent-browser.dev/cdp-model documentation.


### 2. Open and read the target page
```bash
agent-browser --cdp 9222 open "<TARGET_URL>"
sleep 3
agent-browser --cdp 9222 snapshot
```

### 3. Handle authentication if needed
If login screen appears, ask user to authenticate in the opened browser, then:
```bash
agent-browser --cdp 9222 open "<TARGET_URL>" && agent-browser --cdp 9222 snapshot
```

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
| CDP connection refused | Wait a few seconds, then retry; ensure port 9222 is available |
| Still on login page | User needs to authenticate manually in the browser window |
| Stale session errors | Run `agent-browser close --all` and retry |
