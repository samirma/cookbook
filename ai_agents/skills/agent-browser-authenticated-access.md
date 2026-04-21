# Accessing Authenticated Pages with agent-browser

## Purpose

This document provides step-by-step instructions for the LLM agent on how to use `agent-browser` to access authenticated web pages (such as Confluence, Jira, or other internal tools) by leveraging the user's real browser profile and cookies.

## When to Use

Use these instructions whenever you need to retrieve content from a URL that requires authentication and the user has provided a Confluence or other authenticated URL.

---

## Agent Instructions

### Step 1. Determine which browser to use
- **First**, check the persisted preference file: `.agents/skills/nox-dev-docs/.browser-config.json`.
  - If it exists and contains a `"browser"` value, use that browser.
  - If it does **not** exist, **ask the user** which browser they want to use (e.g., Google Chrome, Microsoft Edge, Safari, Firefox).
  - After the user answers, write the choice to `.agents/skills/nox-dev-docs/.browser-config.json` so it is reused automatically in future sessions.
    ```json
    {
      "browser": "Microsoft Edge"
    }
    ```

### Step 2. Ensure the browser is running with Remote Debugging Port (CDP)
You must connect to the browser via CDP on port `9222` using the user's real profile so their authentication cookies are preserved.

**A. Resolve the binary and user-data-dir based on the chosen browser:**

| Browser | Binary Path | User Data Dir |
|---------|-------------|---------------|
| Google Chrome | `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome` | `$HOME/Library/Application Support/Google/Chrome` |
| Microsoft Edge | `/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge` | `$HOME/Library/Application Support/Microsoft Edge` |

**B. Launch the browser with CDP:**

First, ensure no stale agent-browser session is blocking profile reuse:
```bash
agent-browser close --all 2>/dev/null || true
```

Then launch the browser. Replace `<binary>` and `<user-data-dir>` with the values from the table above.
```bash
nohup "<binary>" --remote-debugging-port=9222 --user-data-dir="<user-data-dir>" --no-first-run >/dev/null 2>&1 &
sleep 5
```

For example, for **Microsoft Edge**:
```bash
nohup "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" --remote-debugging-port=9222 --user-data-dir="$HOME/Library/Application Support/Microsoft Edge" --no-first-run >/dev/null 2>&1 &
sleep 5
```

**C. Verify CDP is active:**
```bash
curl -s http://localhost:9222/json/version
```
If this does not return a JSON response with `"Browser"`, the browser may not have started correctly. In that case:
1. Check whether the browser process is running.
2. If it is already running without CDP, terminate it (`killall "Microsoft Edge"` or `killall "Google Chrome"`), then repeat Step 2B.

### Step 3. Open the target page via agent-browser
Once CDP is confirmed active, run:
```bash
agent-browser --cdp 9222 open "<TARGET_URL>"
```
Wait a few seconds for the page to settle before reading it.

### Step 4. Read the page content
Retrieve the full content using snapshot or text extraction:
```bash
agent-browser --cdp 9222 snapshot
```
If the output is truncated or you need cleaner text, also try:
```bash
agent-browser --cdp 9222 get text
```

### Step 5. Handle authentication if required
- If the snapshot shows a **login screen** (e.g., "Log in with Atlassian account"), instruct the user to authenticate in the opened browser window.
- After the user confirms they are logged in, refresh and re-read:
  ```bash
  agent-browser --cdp 9222 open "<TARGET_URL>" && agent-browser --cdp 9222 snapshot
  ```

### Step 6. Answer the user's question
Once the page content is successfully retrieved, use the information from the page to answer the user's request or perform the task.

### Step 7. Cleanup (optional)
Close the `agent-browser` session when done:
```bash
agent-browser close --all
```
