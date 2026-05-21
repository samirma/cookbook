---
name: agent-browser-authenticated-access
description: Access authenticated web pages by launching the user's configured Chromium browser with CDP on port 9222 and the exact existing profile that already contains their cookies. Use when a task needs Jira, GitHub, or another logged-in page in the user's browser session.
---

# Access Authenticated Web Pages

**Goal:** Open a URL with the user's real authenticated browser session. The browser must use the same browser profile the user normally uses for that site, not a temporary, guest, incognito, or unrelated default profile.

**Requirement:** The user must already be logged in to the target site in the configured browser/profile. This skill does not perform authentication.

**Browser support:** Use only Chromium-based browsers that support Chrome DevTools Protocol (CDP): Google Chrome or Microsoft Edge. Do not use Firefox, Safari, or other non-Chromium browsers.

**Agent compatibility:** In opencode, this skill may be auto-loaded. In other agents such as Codex CLI, the agent must explicitly read this `SKILL.md` and `./.browser-config.json`, then follow the same commands. The workflow must not depend on opencode-only features.

## Non-Negotiable Rules

- Always read `~/.agents/skills/agent-browser-authenticated-access/.browser-config.json` before launching a browser.
- Launch exactly the configured browser. Do not substitute another installed or already-running browser.
- First check whether CDP is already active on port `9222`. If it is active for the configured browser, reuse it and open the target URL immediately. Do not quit and relaunch unnecessarily.
- Reuse the user's normal browser data directory. Never create a temporary profile.
- `--user-data-dir` is forbidden unless the user explicitly provides their real existing browser user-data directory. Do not invent one under `/tmp`, the skill directory, the project, or a cache folder.
- `--incognito`, `--inprivate`, `--guest`, and similar private/guest flags are forbidden.
- `--profile-directory` is allowed and often required. Use it to select the user's existing profile directory, such as `Default` or `Profile 1`.
- If the selected profile cannot be determined, ask the user which browser profile they are logged in with instead of guessing.
- Never start the browser with a bare foreground command or a bare trailing `&`. On macOS, prefer `open -na ... --args` so the browser is owned by the desktop session rather than the agent shell. On Linux, use `nohup ... > "$LOG" 2>&1 &`.
- Do not run `agent-browser --cdp 9222 close` at the end of a normal page-reading task unless the user explicitly asks for cleanup. This CDP session is the user's real browser; closing it can destroy useful in-memory authentication state for the next agent.

## Browser Config

Config path:

```text
~/.agents/skills/agent-browser-authenticated-access/.browser-config.json
```

Supported values:

```json
{
  "browser": "Microsoft Edge",
  "profileDirectory": "Default"
}
```

- `browser` is required once configured. Supported values are `Google Chrome` and `Microsoft Edge`.
- `profileDirectory` is optional but preferred. Supported examples are `Default`, `Profile 1`, `Profile 2`, etc.
- If `browser` is missing, ask the user whether they are logged in with Google Chrome or Microsoft Edge, then write the answer to the config.
- If `profileDirectory` is missing, detect it from the browser's `Local State` file before launching. If detection is ambiguous, ask the user and save the answer.

## Detect The User's Existing Profile

Do this before quitting the browser, because the current browser state is the best signal for the profile the user was actually using.

Use the configured browser's `Local State` file:

| Browser | macOS Local State | Linux Local State |
| --- | --- | --- |
| `Google Chrome` | `~/Library/Application Support/Google/Chrome/Local State` | `~/.config/google-chrome/Local State` |
| `Microsoft Edge` | `~/Library/Application Support/Microsoft Edge/Local State` | `~/.config/microsoft-edge/Local State` |

Profile selection order:

1. Use `profileDirectory` from `.browser-config.json` if present.
2. Otherwise use `profile.last_used` from `Local State` if it exists.
3. Otherwise use the only entry in `profile.last_active_profiles` if exactly one exists.
4. Otherwise inspect `profile.info_cache` names and ask the user which profile is logged in to the target site.

After identifying the profile directory, persist it:

```json
{
  "browser": "Microsoft Edge",
  "profileDirectory": "Profile 1"
}
```

Do not confuse the display profile name with the profile directory. The launch flag needs the directory key (`Default`, `Profile 1`), not a display name like `Work` or the user's email.

## Fully Quit The Configured Browser

Before quitting anything, check whether a usable CDP browser is already running:

```bash
curl -s http://localhost:9222/json/version
```

If this returns JSON for the configured browser, skip directly to **Open The URL**. This avoids the odd close/reopen cycle when a previous validated CDP session is already available.

If CDP is active, also confirm the running process is the configured browser/profile when possible:

```bash
pgrep -fl "Microsoft Edge|Google Chrome|remote-debugging-port=9222"
```

Only quit the browser when CDP is not active, the active CDP session is not the configured browser, or the active CDP process clearly uses the wrong profile. The browser must be completely stopped before relaunching with CDP. If it is already running without CDP, Chromium may ignore `--remote-debugging-port=9222` and keep using the old process.

Do not quit/relaunch merely because a target site shows a login screen while the CDP process already matches the configured browser/profile. In that case, relaunching the same profile usually cannot create an authenticated session and may discard an in-memory session another agent was using. Follow **If A Login Page Appears** instead.

**Google Chrome, macOS:**

```bash
osascript -e 'quit app "Google Chrome"'
sleep 2
killall "Google Chrome" 2>/dev/null
```

**Google Chrome, Linux:**

```bash
killall google-chrome 2>/dev/null
killall chrome 2>/dev/null
```

**Microsoft Edge, macOS:**

```bash
osascript -e 'quit app "Microsoft Edge"'
sleep 2
killall "Microsoft Edge" 2>/dev/null
```

**Microsoft Edge, Linux:**

```bash
killall microsoft-edge 2>/dev/null
killall msedge 2>/dev/null
```

## Launch With CDP And The Existing Profile

Launch the configured browser with CDP on port `9222`, the detected existing profile directory, and the target URL. Opening the URL in the launch command prevents a blank browser from sitting idle before navigation.

On macOS, use LaunchServices with `open -na`. Some agent shells, including standalone Codex CLI, may terminate child processes started with direct `nohup /Applications/... &` after the command completes. `open -na` keeps the browser attached to the user's desktop session and still returns immediately.

On Linux, use `nohup` and redirect browser logs away from the shell.

Use a stable log path:

```bash
LOG="/tmp/agent-browser-authenticated-access-cdp.log"
```

**Google Chrome, macOS:**

```bash
open -na "Google Chrome" --args --remote-debugging-port=9222 --profile-directory="<PROFILE_DIRECTORY>" "<TARGET_URL>"
```

**Google Chrome, Linux:**

```bash
LOG="/tmp/agent-browser-authenticated-access-cdp.log"
nohup google-chrome --remote-debugging-port=9222 --profile-directory="<PROFILE_DIRECTORY>" "<TARGET_URL>" > "$LOG" 2>&1 &
```

**Microsoft Edge, macOS:**

```bash
open -na "Microsoft Edge" --args --remote-debugging-port=9222 --profile-directory="<PROFILE_DIRECTORY>" "<TARGET_URL>"
```

**Microsoft Edge, Linux:**

```bash
LOG="/tmp/agent-browser-authenticated-access-cdp.log"
nohup microsoft-edge --remote-debugging-port=9222 --profile-directory="<PROFILE_DIRECTORY>" "<TARGET_URL>" > "$LOG" 2>&1 &
```

`--profile-directory` must point to an existing profile inside the browser's normal user-data directory. It must not be paired with a temporary `--user-data-dir`.

Do not wait passively after launching. Immediately poll CDP for up to 10 seconds, then proceed as soon as JSON is returned:

```bash
for i in 1 2 3 4 5 6 7 8 9 10; do
  curl -s http://localhost:9222/json/version && break
  sleep 1
done
```

## Verify CDP

```bash
curl -s http://localhost:9222/json/version
```

- If JSON is returned with a `Browser` field, CDP is active.
- Confirm the running app/process is the configured browser. Edge may report a Chromium/Chrome-like browser string internally, so verify the process when the configured browser is Microsoft Edge.
- If the request fails after the 10-second poll, quit/kill the configured browser once, relaunch with the platform-specific command above, and poll again. Do not leave the browser open doing nothing while waiting for a shell timeout. Do not fix this by creating a temporary user-data directory.

## Open The URL

Open the target URL through the CDP session:

```bash
agent-browser --cdp 9222 open "<TARGET_URL>"
agent-browser --cdp 9222 snapshot
```

The snapshot must show the requested authenticated content. For Jira, it should show the requested issue page rather than an Atlassian login screen.

## If A Login Page Appears

A login page means the selected browser/profile does not contain the target site's authenticated session.

First determine whether the active CDP process already matches the configured browser/profile.

If the active process matches the configured browser and `--profile-directory`, do not relaunch the same profile. Report that the configured profile is not currently authenticated for the site and ask the user to log in with that exact browser/profile.

If the active process does not match the configured browser/profile, fix in this order:

1. Confirm the browser in `.browser-config.json` is the browser the user actually uses for the site.
2. Confirm `profileDirectory` is the profile the user is logged in with.
3. Quit/kill the browser completely.
4. Relaunch with the platform-specific command using `--remote-debugging-port=9222 --profile-directory="<PROFILE_DIRECTORY>"` and the target URL.
5. Reopen the target URL and capture a new snapshot.
6. If login still appears, ask the user to open the configured browser normally, switch to the intended profile, log in to the site, fully quit the browser, then retry this CDP launch flow.

Do not fall back to a temporary profile, a different browser, or an unauthenticated scraping approach.

## Cleanup

Default behavior: leave the CDP browser running. This is the user's real browser/profile and preserving it lets future agents reuse the authenticated session without a close/reopen cycle.

Only if the user explicitly asks to close the browser, close the CDP-connected automation session:

```bash
agent-browser --cdp 9222 close
```
