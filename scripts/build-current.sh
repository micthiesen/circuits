#!/bin/bash

# CircuitScript Build Current Project Wrapper
# Extracts project name from file path and calls build.sh
# Usage: ./scripts/build-current.sh <full-path-to-cst-file>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to print colored messages
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if file path is provided
if [ $# -eq 0 ]; then
    print_error "Please provide a file path"
    print_error "Usage: $0 <path-to-cst-file>"
    exit 1
fi

FILE_PATH="$1"

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    print_error "File not found: $FILE_PATH"
    exit 1
fi

# Extract filename from full path
filename=$(basename "$FILE_PATH")

# Check if it's a .cst file
if [[ "$filename" != *.cst ]]; then
    print_error "File is not a CircuitScript file (.cst): $filename"
    exit 1
fi

# Extract project name by removing .cst extension
project_name="${filename%.cst}"

# Validate project name is not empty
if [ -z "$project_name" ]; then
    print_error "Could not extract project name from: $filename"
    exit 1
fi

print_status "Extracted project name: $project_name"
print_status "Calling build script..."

# Call the build script
exec "$SCRIPT_DIR/build.sh" "$project_name"
