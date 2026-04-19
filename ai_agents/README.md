# AI Agents

This directory contains the agent configurations and skills for extending AI assistant capabilities.

## Contents

- **`opencode/`** — OpenCode multi-agent development workflow configuration (agents, models, provider setup)
- **`skills/`** — Reusable agent skills installed via curl or package managers

## Agent Skills Installation Guide

### Prerequisites

Create the skills directory and set up the symlink:

```bash
mkdir -p ~/.agents/skills/ && ln -s ~/.agents/skills ~/.config/agents/skills
```

### raspberry-server-finder

Discover and connect to Raspberry Pi server at `raspberry-server.local` using mDNS/Bonjour.

```bash
curl -fsSL https://raw.githubusercontent.com/samirma/cookbook/main/ai_agents/skills/raspberry-server-finder/SKILL.md \
  --create-dirs -o ~/.agents/skills/raspberry-server-finder/SKILL.md
```

### searxng-server

Discover and query a SearXNG metasearch server on the local network via mDNS discovery.

```bash
curl -fsSL https://raw.githubusercontent.com/samirma/cookbook/main/ai_agents/skills/searxng-server/SKILL.md \
  --create-dirs -o ~/.agents/skills/searxng-server/SKILL.md
```

### agent-device

Automates interactions for Apple-platform apps (iOS, tvOS, macOS) and Android devices.

Install from https://agent-device.dev/:

```bash
npx -g skills add callstackincubator/agent-device --skill dogfood
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
