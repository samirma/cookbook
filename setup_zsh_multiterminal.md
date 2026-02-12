# Zsh Multi-Terminal Development Environment Setup

Complete zsh configuration optimized for developers using multiple terminals with different tasks.

---

## Prerequisites

These instructions assume you have:
- macOS with Homebrew installed
- Zsh as your default shell
- Oh-My-Zsh installed (optional but recommended)

---

## Installation Order

**Install tools first, then apply configurations.**

---

## 1. Install All Tools

```bash
brew install zoxide starship fzf tmux tmuxinator eza bat fd ripgrep btop
```

---

## 2. Install Oh-My-Zsh Custom Plugins

```bash
# Install custom plugins
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

---

## 3. Configure Zsh (~/.zshrc)

**WARNING:** These instructions use markers to avoid duplicate entries. Run them even if you have an existing `.zshrc`.

### 3.1 Completion System

```bash
# Remove old completion config if exists
sed -i '' '/# BEGIN: completion_system/,/# END: completion_system/d' ~/.zshrc

# Add completion system
cat >> ~/.zshrc << 'EOF'
# BEGIN: completion_system
# Initialize completion system
autoload -Uz compinit
compinit
# END: completion_system
EOF
```

---

### 3.2 Oh-My-Zsh Plugins

#### 3.2.1 Install Custom Plugins

First, install the custom plugins that need to be cloned:

```bash
# Install custom plugins
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

# Install tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

**Note:** Most plugins (`git`, `docker`, `kubectl`, `sudo`, etc.) are built into Oh-My-Zsh. If you get "plugin not found" errors, update Oh-My-Zsh:
```bash
omz update
```

#### 3.2.2 Add Plugins to ~/.zshrc

This command adds plugins one by one, avoiding duplicates and preserving existing ones:

```bash
# Show current plugins
echo "Current plugins:"
grep "^plugins=" ~/.zshrc

# Add recommended plugins individually (safe, won't duplicate)
for p in zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search colored-man-pages command-not-found fzf docker docker-compose kubectl terraform node npm gradle mvn flutter sudo dirhistory jsontools encode64 timer extract; do
  if ! grep -q "plugins=.*\b$p\b" ~/.zshrc 2>/dev/null; then
    sed -i '' "s/plugins=(/plugins=($p /" ~/.zshrc
    echo "Added: $p"
  else
    echo "Already has: $p"
  fi
done

# Show result
echo ""
echo "Updated plugins:"
grep "^plugins=" ~/.zshrc
```

**Note:** Review the list above and remove any plugins you don't need. Some plugins like `docker`, `kubectl`, `terraform`, `flutter` are specific to backend/mobile development.

---

### 3.2.3 Plugin Reference Guide

#### Core Productivity
| Plugin | Description |
|--------|-------------|
| `git` | Git aliases (`g`, `ga`, `gc`, `gp`, `gst`) and completions |
| `zsh-autosuggestions` | Suggests commands from history as you type |
| `zsh-syntax-highlighting` | Syntax highlighting for commands (valid=green, invalid=red) |
| `zsh-history-substring-search` | Type part of a command, press ↑/↓ to search history |
| `colored-man-pages` | Adds colors to man pages |
| `command-not-found` | Suggests packages when a command is not found |
| `fzf` | Fuzzy finder integration (Ctrl+T for files, Ctrl+R for history) |

#### Backend Development
| Plugin | Description |
|--------|-------------|
| `docker` | Docker completions + aliases (`dps`, `dstop`, `drm`, `dco`) |
| `docker-compose` | Compose completions + aliases (`dcup`, `dcdown`, `dcr`) |
| `kubectl` | Kubernetes completions + aliases (`k`, `kgp`, `kgsvc`, `kdf`) |
| `terraform` | Terraform completions + aliases (`tf`, `tfp`, `tfa`, `tfd`) |
| `node` | Node.js helpers and completion |
| `npm` | NPM completions + aliases (`npmg`, `npmS`, `npmD`) |
| `gradle` | Gradle completions (essential for Java/Android backend) |
| `mvn` | Maven completions + aliases (`mci`, `mcist`, `mvnd`) |
| `redis-cli` | Redis completions |
| `postgres` | PostgreSQL completions |

#### Mobile Development
| Plugin | Description |
|--------|-------------|
| `flutter` | Flutter aliases (`fl`, `flb`, `flr`, `fld`, `fle`) |
| `bundler` | Bundler completions + aliases (`be`, `bi`, `bu`) |
| `fastlane` | Fastlane completions |

#### General Utilities
| Plugin | Description |
|--------|-------------|
| `sudo` | Press `ESC` twice → adds `sudo` to current line |
| `dirhistory` | `Alt+Left/Right` → navigate directory history |
| `jsontools` | JSON tools: `pp_json`, `is_json`, `urlencode_json` |
| `encode64` | `encode64` / `decode64` for Base64 encoding |
| `timer` | Shows command execution time (for commands > 2s) |
| `extract` | Universal archive extractor: `extract <file>` |
| `aliases` | List all aliases with `als` or search with `alsc` |
| `web-search` | Search from terminal: `google <query>`, `github <query>` |
| `safe-paste` | Prevents accidental execution of pasted multi-line code |

---

### 3.2.4 Quick Plugin Commands

```bash
# List all active plugins
omz plugin list

# Enable a plugin temporarily
omz plugin enable <plugin-name>

# Disable a plugin temporarily
omz plugin disable <plugin-name>

# Reload after changes
omz reload
```

---

### 3.3 History Configuration

This script safely adds history settings, only adding what's missing and preserving your existing configuration:

```bash
#!/bin/bash

ZSHRC="$HOME/.zshrc"

# Function to add setting if not present
add_if_missing() {
    local pattern="$1"
    local line="$2"
    if ! grep -qE "^${pattern}$" "$ZSHRC" 2>/dev/null; then
        echo "$line" >> "$ZSHRC"
        echo "Added: $line"
    else
        echo "Already exists: $pattern"
    fi
}

# Backup
cp "$ZSHRC" "${ZSHRC}.backup.$(date +%Y%m%d)"

echo "Configuring history settings..."

# Add each option individually (only if missing)
add_if_missing "setopt SHARE_HISTORY" "setopt SHARE_HISTORY"
add_if_missing "setopt INC_APPEND_HISTORY" "setopt INC_APPEND_HISTORY"
add_if_missing "setopt HIST_EXPIRE_DUPS_FIRST" "setopt HIST_EXPIRE_DUPS_FIRST"
add_if_missing "setopt HIST_IGNORE_DUPS" "setopt HIST_IGNORE_DUPS"
add_if_missing "export HISTSIZE=.*" "export HISTSIZE=100000"
add_if_missing "export SAVEHIST=.*" "export SAVEHIST=100000"

echo ""
echo "Current history settings in $ZSHRC:"
grep -E "^(setopt.*HIST|export HIST)" "$ZSHRC"
```

**What this does:**
1. Creates a backup of your `~/.zshrc`
2. Checks each setting individually
3. Only adds settings that don't already exist
4. Shows you exactly what was added vs. what already existed
5. Displays the final history configuration

**Settings explained:**
| Setting | Purpose |
|---------|---------|
| `SHARE_HISTORY` | Share history between all open terminal sessions |
| `INC_APPEND_HISTORY` | Save commands to history immediately (not on exit) |
| `HIST_EXPIRE_DUPS_FIRST` | When history is full, delete duplicates before old entries |
| `HIST_IGNORE_DUPS` | Don't save a command if it's identical to the previous one |
| `HISTSIZE=100000` | Keep 100,000 commands in memory |
| `SAVEHIST=100000` | Save 100,000 commands to disk |

---

### 3.4 Starship Prompt

**Project:** [starship/starship](https://github.com/starship/starship)

Starship is a minimal, fast, and customizable shell prompt that shows git status, programming language versions, command duration, and more.

#### 3.4.1 Enable Starship in Zsh

```bash
# Remove old starship config if exists
sed -i '' '/# BEGIN: starship/,/# END: starship/d' ~/.zshrc

# Add starship configuration
cat >> ~/.zshrc << 'EOF'
# BEGIN: starship
# Starship - Fast, customizable prompt
eval "$(starship init zsh)"
# END: starship
EOF
```

#### 3.4.2 Configure Starship (~/.config/starship.toml)

```bash
# Create config directory if not exists
mkdir -p ~/.config

# Write Starship configuration
cat > ~/.config/starship.toml << 'EOF'
# Starship Configuration - Clean (No Nerd Fonts)

add_newline = true

format = """
$directory$git_branch$git_status$nodejs$python
$character"""

right_format = """
$cmd_duration
"""

[character]
success_symbol = ">"
error_symbol = "x"

[directory]
truncation_length = 3
truncation_symbol = ".../"
style = "cyan bold"
truncate_to_repo = true

[git_branch]
format = " [$branch]($style)"
style = "purple bold"

[git_status]
format = "([$all_status$ahead_behind]($style))"
style = "yellow bold"
ahead = "+"
behind = "-"
diverged = "+_"
up_to_date = ""
untracked = "?"
modified = "*"
staged = "+"
stashed = "$"
deleted = "x"

[nodejs]
format = " [node:$version]($style)"
style = "green"

[python]
format = " [py:$version]($style)"
style = "yellow"

[cmd_duration]
min_time = 2000
format = "[$duration]($style) "
style = "dimmed"

# Disable unused modules
[ruby]
disabled = true

[rust]
disabled = true

[java]
disabled = true

[golang]
disabled = true

[package]
disabled = true

[container]
disabled = true

[time]
disabled = true
EOF
```

---

### 3.5 fzf (Fuzzy Finder)

**Project:** [junegunn/fzf](https://github.com/junegunn/fzf)

fzf is a command-line fuzzy finder that helps you quickly find files, commands, or any text using fuzzy matching. It provides interactive filtering with real-time results as you type.

**Key bindings:**
- `Ctrl+T` - Fuzzy find files in current directory
- `Alt+C` - Fuzzy find directories and `cd` into selected one  
- `Ctrl+R` - Fuzzy search through command history

```bash
# Remove old fzf config if exists
sed -i '' '/# BEGIN: fzf/,/# END: fzf/d' ~/.zshrc

# Add fzf configuration
cat >> ~/.zshrc << 'EOF'
# BEGIN: fzf
# fzf - Fuzzy finder
source <(fzf --zsh)

# fzf customization
export FZF_DEFAULT_OPTS="
  --height 40%
  --layout=reverse
  --border
  --preview 'bat --color=always --style=numbers --line-range=:500 {}' 
  --preview-window hidden:right:50%
  --bind 'ctrl-/:toggle-preview'
"
export FZF_DEFAULT_COMMAND="fd --type f --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --strip-cwd-prefix --exclude .git"
# END: fzf
EOF
```

---

### 3.6 Modern CLI Aliases

```bash
# Remove old aliases if exists
sed -i '' '/# BEGIN: modern_aliases/,/# END: modern_aliases/d' ~/.zshrc

# Add aliases
cat >> ~/.zshrc << 'EOF'
# BEGIN: modern_aliases
# Modern CLI aliases
if command -v eza &> /dev/null; then
  alias ls="eza --group-directories-first"
  alias ll="eza -l --git"
  alias la="eza -la --git"
  alias lt="eza --tree --level=2"
  alias l="eza -lah"
fi

if command -v bat &> /dev/null; then
  alias cat="bat --paging=never"
  alias catp="bat --plain"
fi

if command -v btop &> /dev/null; then
  alias top="btop"
fi

alias grep="rg"
alias find="fd"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
# END: modern_aliases
EOF
```

---

## 4. Configure Tmux (~/.tmux.conf)

```bash
cat > ~/.tmux.conf << 'EOF'
# Tmux Configuration

# Set prefix to Ctrl+A
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Enable mouse
set -g mouse on

# Set default terminal
set -g default-terminal "screen-256color"

# Increase history
set -g history-limit 50000

# Start windows at 1
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on

# Key bindings
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Copy mode
setw -g mode-keys vi

# Status bar
set -g status-style bg=default,fg=white
set -g status-left "Session: #S "
set -g status-right "%H:%M"

# Plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

run '~/.tmux/plugins/tpm/tpm'
EOF
```

---

## 5. Reload Everything

```bash
# Reload zsh configuration
source ~/.zshrc

# Install tmux plugins (open tmux and press Ctrl+A then Shift+I)
```

---

## Quick Verification

After setup, verify everything works:

```bash
# Test completions
cd De<TAB>     # Should complete to Desktop/

# Test zoxide
cd ~/Desktop
cd ~
cd Des<TAB>    # Should jump back to Desktop

# Test starship
# You should see a clean prompt with git info

# Test aliases
ls             # Should use eza
ll             # Should show git status

# Test fzf
Ctrl+T         # Should open file finder
```

---

## Troubleshooting

### Completion not working
```bash
# Remove completion dump and reinitialize
rm -f ~/.zcompdump*
source ~/.zshrc
```

### Duplicate entries in .zshrc
The instructions use markers (`# BEGIN: ... / # END: ...`) to prevent duplicates. If you still see duplicates:
```bash
# View your .zshrc
cat ~/.zshrc | grep -E "^# BEGIN:|^# END:"
```

### Reset everything and start fresh
```bash
# Backup first
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d)

# Remove all marked sections
sed -i '' '/# BEGIN: /,/# END: /d' ~/.zshrc

# Now re-run the instructions above
```

---

## See Also

- `~/.zshrc` - Main shell configuration
- `~/.config/starship.toml` - Prompt configuration
- `~/.tmux.conf` - Tmux configuration
