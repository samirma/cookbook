#!/bin/bash

# Master server runner using uv
# This script runs the master.py server using uv for automatic dependency management

cd "$(dirname "$0")"

# Try to find uv - check common locations and PATH
UV_CMD=""
if command -v uv &> /dev/null; then
    UV_CMD="uv"
elif [ -x "$HOME/.local/bin/uv" ]; then
    UV_CMD="$HOME/.local/bin/uv"
elif [ -x "$HOME/.cargo/bin/uv" ]; then
    UV_CMD="$HOME/.cargo/bin/uv"
fi

if [ -z "$UV_CMD" ]; then
    echo "Error: 'uv' is not installed."
    echo "Install it with: curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi

# Run the master server with automatic dependency resolution
$UV_CMD run master.py "$@"
