# Agent Skills Installation Guide

This guide covers how to install the agent skills for extending AI assistant capabilities.

## Prerequisites

Create the skills directory and set up the symlink:

```bash
mkdir -p ~/.agents/skills/ && ln -s ~/.agents/skills ~/.config/agents/skills
```

## raspberry-server-finder

Discover and connect to Raspberry Pi server at `raspberry-server.local` using mDNS/Bonjour.

```bash
curl -fsSL https://raw.githubusercontent.com/samirma/cookbook/main/ai_agents/skills/raspberry-server-finder/SKILL.md \
  --create-dirs -o ~/.agents/skills/raspberry-server-finder/SKILL.md
```

## searxng-server

Discover and query a SearXNG metasearch server on the local network via mDNS discovery.

```bash
curl -fsSL https://raw.githubusercontent.com/samirma/cookbook/main/ai_agents/skills/searxng-server/SKILL.md \
  --create-dirs -o ~/.agents/skills/searxng-server/SKILL.md
```

## agent-device

Automates interactions for Apple-platform apps (iOS, tvOS, macOS) and Android devices.

Install from https://agent-device.dev/:

```bash
npx -g skills add callstackincubator/agent-device --skill dogfood
```

## Verification

Verify the skills are installed correctly:

```bash
ls ~/.agents/skills/
```

Each skill directory should contain a `SKILL.md` file.
