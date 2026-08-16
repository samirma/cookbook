# AI Agents

This directory contains the agent skills for extending AI assistant capabilities.

## Contents

- **`skills/`** — Reusable agent skills installed via curl or package managers

## Agent Skills Installation Guide

### Prerequisites

Create the skills directory and set up the symlink:

```bash
mkdir -p ~/.agents/skills/ && mkdir -p ~/.config/agents/ && ln -s ~/.agents/skills ~/.config/agents/skills
```

### raspberry-server-finder

Discover and connect to Raspberry Pi server at `raspberry-server.local` using mDNS/Bonjour.

```bash
curl -fsSL https://raw.githubusercontent.com/samirma/cookbook/main/ai_agents/skills/raspberry-server-finder/SKILL.md \
  --create-dirs -o ~/.agents/skills/raspberry-server-finder/SKILL.md
```

### searxng-server

The agent's default web search tool. Query the internet using a self-hosted SearXNG metasearch engine discovered on the local network via mDNS. Features cache-aware IP discovery with health validation, and a two-stage fallback when the local server is unreachable: a validated public SearXNG instance first, then the built-in WebSearch tool.

```bash
BASE_URL="https://raw.githubusercontent.com/samirma/cookbook/main/ai_agents/skills/searxng-server"
DEST_DIR="$HOME/.agents/skills/searxng-server"


curl -fsSL "${BASE_URL}/SKILL.md" --create-dirs -o "${DEST_DIR}/SKILL.md"
curl -fsSL "${BASE_URL}/references/discovery.md" --create-dirs -o "${DEST_DIR}/references/discovery.md"
curl -fsSL "${BASE_URL}/references/public-fallback.md" --create-dirs -o "${DEST_DIR}/references/public-fallback.md"
curl -fsSL "${BASE_URL}/references/setup.md" --create-dirs -o "${DEST_DIR}/references/setup.md"
curl -fsSL "${BASE_URL}/references/queries.md" --create-dirs -o "${DEST_DIR}/references/queries.md"
curl -fsSL "${BASE_URL}/references/troubleshooting.md" --create-dirs -o "${DEST_DIR}/references/troubleshooting.md"
```

### agent-device

Automates interactions for Apple-platform apps (iOS, tvOS, macOS) and Android devices.

Install from https://agent-device.dev/:

```bash
npm install -g agent-device
npx skills add callstackincubator/agent-device -g -y
```

### agent-browser

Browser automation for AI coding agents. Enables agents to automate browser tasks — navigation, snapshots, forms, screenshots, data extraction, and more — without manual guidance.

Install from https://agent-browser.dev/skills:

```bash
npx skills add vercel-labs/agent-browser
```

After installation, agents retrieve skill content at runtime via the CLI:

```bash
# List all available skills
agent-browser skills list

# Get the core browser automation skill
agent-browser skills get core --full
```

### Verification

Verify the skills are installed correctly:

```bash
ls ~/.agents/skills/
```

Each skill directory should contain a `SKILL.md` file.
