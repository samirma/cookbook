# Cookbook

A collection of guides and scripts for setting up development environments, operating systems, and AI tools.

## Setup Guides

### System Setup

- **[setup_dev_env.md](setup_dev_env.md)**: Universal guide for setting up development tools (Git, Python/Pyenv/UV, Node/NVM, Docker, Java, Android SDK).
- **[setup_macos.md](setup_macos.md)**: Post-installation setup for macOS (Homebrew, Zsh, Utilities).
- **[setup_ubuntu.md](setup_ubuntu.md)**: Post-installation setup for Ubuntu (packages, settings).
- **[setup_termux_android.md](setup_termux_android.md)**: Setup guide for Termux on Android.

### AI & Machine Learning

- **[setup_llama_cpp_distributed.md](setup_llama_cpp_distributed.md)**: Building and configuring llama.cpp for distributed inference across multiple devices.

## Usage Guides

- **[guide_ssh_key_restore.md](guide_ssh_key_restore.md)**: Guide for restoring SSH keys from backup.
- **[guide_outlook_rules.md](guide_outlook_rules.md)**: Instructions for filtering Outlook meeting invites.
- **[guide_avahi_services.md](guide_avahi_services.md)**: Configuring Avahi mDNS service discovery for homelab services (SSH, SearXNG).
- **[guide_agent_skills.md](guide_agent_skills.md)**: Installing AI agent skills.

## AI Agents

This repository includes AI agent skills in the **[ai_agents/skills/](ai_agents/skills/)** directory:

| Skill | Description |
|-------|-------------|
| **[raspberry-server-finder](ai_agents/skills/raspberry-server-finder/)** | Discover and connect to Raspberry Pi server at `raspberry-server.local` using mDNS/Bonjour. |
| **[searxng-server](ai_agents/skills/searxng-server/)** | Discover and query a SearXNG metasearch server on the local network via mDNS discovery. |

Skills are installed to `~/.agents/skills/` with a symlink at `~/.config/agents/skills/`.

See **[guide_agent_skills.md](guide_agent_skills.md)** for installation instructions (including agent-device from https://agent-device.dev/).
