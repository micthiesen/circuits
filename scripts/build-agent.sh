#!/bin/bash

# CircuitScript Build Agent
# Compact syntax checker for AI agents
# Usage: ./scripts/build-agent.sh <project-name>

set -e

# Setup NVM and use default Node.js version
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Use default Node.js version if NVM is available
if command -v nvm >/dev/null 2>&1; then
    nvm use default >/dev/null 2>&1 || true
fi

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECTS_DIR="$PROJECT_ROOT/projects"
OUTPUT_DIR="$PROJECT_ROOT/output"

# Check arguments
if [ $# -eq 0 ]; then
    echo "ERROR: Project name required"
    echo "Usage: $0 <project-name>"
    exit 1
fi

PROJECT_NAME="$1"
INPUT_FILE="$PROJECTS_DIR/$PROJECT_NAME.cst"
OUTPUT_FILE="$OUTPUT_DIR/$PROJECT_NAME.svg"

# Validate input file
if [ ! -f "$INPUT_FILE" ]; then
    echo "ERROR: Project file not found: $INPUT_FILE"
    if [ -d "$PROJECTS_DIR" ]; then
        echo "Available projects:"
        for file in "$PROJECTS_DIR"/*.cst; do
            [ -f "$file" ] && basename "$file" .cst
        done
    fi
    exit 1
fi

# Check circuitscript CLI
if ! command -v circuitscript >/dev/null 2>&1; then
    echo "ERROR: circuitscript CLI not found. Install with: npm install -g circuitscript"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Get file timestamp before build
BEFORE_TIME=""
if [ -f "$OUTPUT_FILE" ]; then
    BEFORE_TIME=$(stat -f "%m" "$OUTPUT_FILE" 2>/dev/null || stat -c "%Y" "$OUTPUT_FILE" 2>/dev/null || echo "0")
else
    BEFORE_TIME="0"
fi

# Run circuitscript - redirect stderr to stdout so everything goes to console
echo "Building $PROJECT_NAME..."
circuitscript "$INPUT_FILE" "$OUTPUT_FILE" 2>&1
EXIT_CODE=$?

# Check if file was actually updated
FILE_UPDATED=0
if [ -f "$OUTPUT_FILE" ]; then
    AFTER_TIME=$(stat -f "%m" "$OUTPUT_FILE" 2>/dev/null || stat -c "%Y" "$OUTPUT_FILE" 2>/dev/null || echo "0")
    if [ "$AFTER_TIME" != "$BEFORE_TIME" ] && [ -s "$OUTPUT_FILE" ]; then
        FILE_UPDATED=1
    fi
fi

# Determine result
if [ $EXIT_CODE -eq 0 ] && [ $FILE_UPDATED -eq 1 ]; then
    echo "SUCCESS: $PROJECT_NAME built successfully"
    exit 0
else
    if [ $EXIT_CODE -ne 0 ]; then
        echo "FAILED: Exit code $EXIT_CODE"
    elif [ $FILE_UPDATED -eq 0 ]; then
        echo "FAILED: Output file not created/updated"
    else
        echo "FAILED: Unknown error"
    fi
    exit 1
fi
