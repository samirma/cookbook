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
brew install zoxide starship fzf tmux tmuxinator eza bat fd ripgrep btop direnv
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

```bash
# Remove old plugin config if exists
sed -i '' '/# BEGIN: omz_plugins/,/# END: omz_plugins/d' ~/.zshrc

# Add plugins configuration (add this BEFORE 'source $ZSH/oh-my-zsh.sh')
cat >> ~/.zshrc << 'EOF'
# BEGIN: omz_plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
  colored-man-pages
  command-not-found
  fzf
)
# END: omz_plugins
EOF
```

**Note:** If you already have a `plugins=(...)` line in your `.zshrc`, remove it first or update it manually.

---

### 3.3 History Configuration

```bash
# Remove old history config if exists
sed -i '' '/# BEGIN: history_config/,/# END: history_config/d' ~/.zshrc

# Add history configuration
cat >> ~/.zshrc << 'EOF'
# BEGIN: history_config
# History configuration
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
export HISTSIZE=100000
export SAVEHIST=100000
export HISTFILE=~/.zsh_history
# END: history_config
EOF
```

---

### 3.4 Zoxide (Smart cd)

**Project:** [ajeetdsouza/zoxide](https://github.com/ajeetdsouza/zoxide)

```bash
# Remove old zoxide config if exists
sed -i '' '/# BEGIN: zoxide/,/# END: zoxide/d' ~/.zshrc

# Add zoxide configuration
cat >> ~/.zshrc << 'EOF'
# BEGIN: zoxide
# Zoxide - Smart directory jumper
eval "$(zoxide init zsh)"
alias cd="z"
# END: zoxide
EOF
```

---

### 3.5 Starship Prompt

**Project:** [starship/starship](https://github.com/starship/starship)

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

---

### 3.6 fzf (Fuzzy Finder)

**Project:** [junegunn/fzf](https://github.com/junegunn/fzf)

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

### 3.7 Direnv (Per-Directory Environment)

**Project:** [direnv/direnv](https://github.com/direnv/direnv)

```bash
# Remove old direnv config if exists
sed -i '' '/# BEGIN: direnv/,/# END: direnv/d' ~/.zshrc

# Add direnv configuration
cat >> ~/.zshrc << 'EOF'
# BEGIN: direnv
# Direnv - Auto-load environment per directory
eval "$(direnv hook zsh)"
# END: direnv
EOF
```

---

### 3.8 Modern CLI Aliases

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

### 3.9 Utility Functions

```bash
# Remove old functions if exists
sed -i '' '/# BEGIN: utility_functions/,/# END: utility_functions/d' ~/.zshrc

# Add utility functions
cat >> ~/.zshrc << 'EOF'
# BEGIN: utility_functions
# Utility functions

# Create directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# Universal archive extractor
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1" ;;
      *.tar.gz)    tar xzf "$1" ;;
      *.tar.xz)    tar xJf "$1" ;;
      *.bz2)       bunzip2 "$1" ;;
      *.rar)       unrar x "$1" ;;
      *.gz)        gunzip "$1" ;;
      *.tar)       tar xf "$1" ;;
      *.tbz2)      tar xjf "$1" ;;
      *.tgz)       tar xzf "$1" ;;
      *.zip)       unzip "$1" ;;
      *.Z)         uncompress "$1" ;;
      *.7z)        7z x "$1" ;;
      *)           echo "Cannot extract '$1'" ;;
    esac
  fi
}

# Git clone and cd
gclone() { git clone "$1" && cd "$(basename "$1" .git)"; }

# Interactive process killer
killp() {
  ps aux | grep -i "$1" | grep -v grep
  read -q "REPLY?Kill these? (y/n) "
  [[ "$REPLY" =~ ^[Yy]$ ]] && ps aux | grep -i "$1" | grep -v grep | awk '{print $2}' | xargs kill -9
}

# Bookmark current location
bookmark() {
  local name="$1"
  if [[ -z "$name" ]]; then
    echo "Usage: bookmark <name>"
    return 1
  fi
  mkdir -p ~/.bookmarks
  echo "$(pwd)" > ~/.bookmarks/$name
  echo "Bookmark saved: $name -> $(pwd)"
}

# Jump to bookmarked location
jump() {
  local name="$1"
  if [[ -z "$name" ]]; then
    echo "Usage: jump <name>"
    return 1
  fi
  if [[ -f ~/.bookmarks/$name ]]; then
    cd "$(cat ~/.bookmarks/$name)"
  else
    echo "Bookmark not found: $name"
    return 1
  fi
}
# END: utility_functions
EOF
```

---

## 4. Configure Starship (~/.config/starship.toml)

**Apply this configuration:**

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
diverged = "+-"
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

## 5. Configure Tmux (~/.tmux.conf)

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

## 6. Direnv Helper Functions (~/.config/direnv/direnvrc)

```bash
mkdir -p ~/.config/direnv

cat > ~/.config/direnv/direnvrc << 'EOF'
# Direnv configuration

# Python virtualenv layout
layout_python() {
  local venv_path="${PWD}/.venv"
  if [[ ! -d "$venv_path" ]]; then
    log_status "Creating virtualenv in $venv_path"
    python3 -m venv "$venv_path"
  fi
  export VIRTUAL_ENV="$venv_path"
  export PATH="$VIRTUAL_ENV/bin:$PATH"
}

# Node.js layout
layout_node() {
  export NODE_ENV="${NODE_ENV:-development}"
  export PATH="$PWD/node_modules/.bin:$PATH"
}
EOF
```

---

## 7. Reload Everything

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
- `~/.config/direnv/direnvrc` - Direnv helpers
