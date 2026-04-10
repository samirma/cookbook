#!/bin/bash
#
# OpenCode Agents Installation Script
# This script installs opencode agent configurations to ~/.opencode/agents
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
OPENCODE_DIR="$HOME/.opencode"
AGENTS_DIR="$OPENCODE_DIR/agents"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_AGENTS_DIR="$SCRIPT_DIR/agents"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  OpenCode Agents Installer${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if source directory exists
if [ ! -d "$SOURCE_AGENTS_DIR" ]; then
    echo -e "${RED}Error: Source agents directory not found at $SOURCE_AGENTS_DIR${NC}"
    exit 1
fi

# Create .opencode directory if it doesn't exist
if [ ! -d "$OPENCODE_DIR" ]; then
    echo -e "${YELLOW}Creating $OPENCODE_DIR directory...${NC}"
    mkdir -p "$OPENCODE_DIR"
fi

# Create agents directory if it doesn't exist
if [ ! -d "$AGENTS_DIR" ]; then
    echo -e "${YELLOW}Creating $AGENTS_DIR directory...${NC}"
    mkdir -p "$AGENTS_DIR"
fi

# Backup existing agents if any
if [ "$(ls -A $AGENTS_DIR)" ]; then
    BACKUP_DIR="$OPENCODE_DIR/agents-backup-$(date +%Y%m%d-%H%M%S)"
    echo -e "${YELLOW}Backing up existing agents to $BACKUP_DIR${NC}"
    mkdir -p "$BACKUP_DIR"
    cp -r "$AGENTS_DIR"/* "$BACKUP_DIR/" 2>/dev/null || true
fi

# Install agent files
echo -e "${BLUE}Installing agent configurations...${NC}"
for file in "$SOURCE_AGENTS_DIR"/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo -e "  ${GREEN}→${NC} Installing $filename"
        cp "$file" "$AGENTS_DIR/"
    fi
done

# Create config.json if it doesn't exist
CONFIG_FILE="$OPENCODE_DIR/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}Creating default config.json...${NC}"
    cat > "$CONFIG_FILE" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "model": "alibaba-coding-plan/MiniMax-M2.5",
  "provider": {
    "alibaba-coding-plan": {
      "options": {
        "apiKey": "YOUR_API_KEY_HERE"
      }
    }
  }
}
EOF
    echo -e "${YELLOW}⚠️  Please edit $CONFIG_FILE and add your API key${NC}"
else
    echo -e "${YELLOW}Config file already exists at $CONFIG_FILE${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Installed agents:${NC}"
ls -1 "$AGENTS_DIR"/*.md 2>/dev/null | grep -v workflow-state | xargs -n1 basename | sed 's/^/  - /'
echo ""
echo -e "${BLUE}Configuration files:${NC}"
ls -1 "$AGENTS_DIR"/*.json 2>/dev/null | xargs -n1 basename | sed 's/^/  - /'
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Edit $CONFIG_FILE to add your API key"
echo "  2. Run 'opencode --version' to verify installation"
echo "  3. Run 'opencode run --agent dev-team \"Your task\"' to start"
echo ""
