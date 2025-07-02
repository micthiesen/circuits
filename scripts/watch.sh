#!/bin/bash

# Atopile File Watcher Script
# Automatically builds the project when .ato files change

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
WATCH_EXTENSIONS="ato yaml yml"
BUILD_COMMAND="ato build"
DEBOUNCE_TIME=2  # seconds to wait before building after changes

echo -e "${BLUE}🔍 Starting atopile file watcher...${NC}"
echo -e "${BLUE}Watching for changes in: ${WATCH_EXTENSIONS}${NC}"
echo -e "${BLUE}Build command: ${BUILD_COMMAND}${NC}"
echo -e "${BLUE}Press Ctrl+C to stop${NC}"
echo ""

# Check if fswatch is installed
if ! command -v fswatch &> /dev/null; then
    echo -e "${YELLOW}⚠️  fswatch not found. Installing via Homebrew...${NC}"
    if command -v brew &> /dev/null; then
        brew install fswatch
    else
        echo -e "${RED}❌ Homebrew not found. Please install fswatch manually:${NC}"
        echo -e "${RED}   brew install fswatch${NC}"
        exit 1
    fi
fi

# Function to build the project
build_project() {
    echo -e "${YELLOW}🔨 Building project...${NC}"
    if $BUILD_COMMAND; then
        echo -e "${GREEN}✅ Build successful!${NC}"
        echo -e "${GREEN}$(date): Project built successfully${NC}"
    else
        echo -e "${RED}❌ Build failed!${NC}"
        echo -e "${RED}$(date): Build failed with exit code $?${NC}"
    fi
    echo ""
}

# Function to check if file should trigger build
should_build() {
    local file="$1"
    local extension="${file##*.}"

    # Skip hidden files and directories
    if [[ $(basename "$file") == .* ]]; then
        return 1
    fi

    # Skip build directory
    if [[ "$file" == *"/build/"* ]]; then
        return 1
    fi

    # Skip layouts directory (generated files)
    if [[ "$file" == *"/layouts/"* ]]; then
        return 1
    fi

    # Check if extension matches our watch list
    for ext in $WATCH_EXTENSIONS; do
        if [[ "$extension" == "$ext" ]]; then
            return 0
        fi
    done

    return 1
}

# Initial build
echo -e "${YELLOW}🚀 Running initial build...${NC}"
build_project

# Track last build time to implement debouncing
last_build_time=0

# Start watching for file changes
fswatch -r . | while read file; do
    if should_build "$file"; then
        current_time=$(date +%s)

        # Implement debouncing - only build if enough time has passed
        if (( current_time - last_build_time >= DEBOUNCE_TIME )); then
            echo -e "${BLUE}📝 File changed: $(basename "$file")${NC}"
            build_project
            last_build_time=$current_time
        else
            echo -e "${YELLOW}⏳ Change detected but debouncing...${NC}"
        fi
    fi
done
