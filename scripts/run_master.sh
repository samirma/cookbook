#!/bin/bash

# Master server runner using uv
# This script runs the master.py server using uv for automatic dependency management

cd "$(dirname "$0")"

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "Error: 'uv' is not installed."
    echo "Install it with: curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi

# Run the master server with automatic dependency resolution
uv run master.py "$@"
