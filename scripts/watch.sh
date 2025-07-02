#!/bin/bash

# CircuitScript Watch Script
# Watches for changes in CircuitScript files and automatically rebuilds
# Usage: ./scripts/watch.sh <project-name> [format]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Navigate to the project root (parent of scripts directory)
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Configuration
PROJECTS_DIR="$PROJECT_ROOT/projects"
OUTPUT_DIR="$PROJECT_ROOT/output"
DEBOUNCE_TIME=1.5  # seconds to wait before building after changes
DEFAULT_FORMAT="svg"

# Function to print usage
print_usage() {
    echo -e "${BLUE}CircuitScript Watch Tool${NC}"
    echo ""
    echo "Usage: $0 <project-name> [format]"
    echo ""
    echo "Arguments:"
    echo "  project-name    Name of the project to watch (without .cst extension)"
    echo "  format          Output format: 'svg' or 'pdf' (default: svg)"
    echo ""
    echo "Examples:"
    echo "  $0 fogger       # Watches projects/fogger.cst, outputs SVG"
    echo "  $0 fogger pdf   # Watches projects/fogger.cst, outputs PDF"
    echo "  $0 fogger svg   # Watches projects/fogger.cst, outputs SVG"
    echo ""
    echo "Controls:"
    echo "  Ctrl+C          Stop watching"
    echo "  r + Enter       Force rebuild"
    echo "  q + Enter       Quit"
}

# Function to print colored status messages
print_status() {
    echo -e "${CYAN}[$(date '+%H:%M:%S')] ${GRAY}$1${NC}"
}

print_success() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')] ✅ $1${NC}"
}

print_error() {
    echo -e "${RED}[$(date '+%H:%M:%S')] ❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')] ⚠️  $1${NC}"
}

print_build() {
    echo -e "${PURPLE}[$(date '+%H:%M:%S')] 🔨 $1${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install file watcher
install_watcher() {
    print_status "Installing file watcher..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command_exists brew; then
            print_status "Installing fswatch via Homebrew..."
            brew install fswatch
        else
            print_error "Homebrew not found. Please install fswatch manually:"
            print_error "  brew install fswatch"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        if command_exists apt-get; then
            print_status "Installing inotify-tools via apt..."
            sudo apt-get install -y inotify-tools
        elif command_exists yum; then
            print_status "Installing inotify-tools via yum..."
            sudo yum install -y inotify-tools
        else
            print_error "Package manager not found. Please install inotify-tools manually."
            exit 1
        fi
    else
        print_error "Unsupported OS. Please install a file watcher manually."
        exit 1
    fi
}

# Function to build the project
build_project() {
    local project_name="$1"
    local format="$2"
    local input_file="$PROJECTS_DIR/$project_name.cst"
    local output_file="$OUTPUT_DIR/$project_name.$format"

    print_build "Building $project_name.$format..."

    # Create output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"

    # Capture both stdout and stderr
    local build_output
    local exit_code

    if build_output=$(circuitscript "$input_file" "$output_file" 2>&1); then
        exit_code=0
    else
        exit_code=$?
    fi

    if [ $exit_code -eq 0 ]; then
        if [ -f "$output_file" ]; then
            local file_size=$(du -h "$output_file" 2>/dev/null | cut -f1 || echo "unknown")
            file_size="${file_size#"${file_size%%[![:space:]]*}"}"  # trim leading
            file_size="${file_size%"${file_size##*[![:space:]]}"}"  # trim trailing
            print_success "Built successfully → $project_name.$format ($file_size)"
        else
            print_success "Build completed"
        fi
    else
        print_error "Build failed (exit code: $exit_code)"

        # Parse and display error nicely
        if [[ -n "$build_output" ]]; then
            echo ""
            echo -e "${RED}╔══════════════════════════════════════════╗${NC}"
            echo -e "${RED}║                Build Error               ║${NC}"
            echo -e "${RED}╚══════════════════════════════════════════╝${NC}"

            # Clean up the error output
            local clean_output=$(echo "$build_output" | sed 's/^/  /')

            # Highlight common error patterns
            clean_output=$(echo "$clean_output" | sed -E "s/(Error:|SyntaxError:|TypeError:)/$(printf '\033[1;31m')\1$(printf '\033[0m')/g")
            clean_output=$(echo "$clean_output" | sed -E "s/(line [0-9]+)/$(printf '\033[1;33m')\1$(printf '\033[0m')/g")
            clean_output=$(echo "$clean_output" | sed -E "s/(at .+:[0-9]+:[0-9]+)/$(printf '\033[0;36m')\1$(printf '\033[0m')/g")

            echo -e "$clean_output"
            echo ""
        fi

        return 1
    fi
}

# Function to watch files
watch_files() {
    local project_name="$1"
    local format="$2"
    local input_file="$PROJECTS_DIR/$project_name.cst"
    local last_build_time=0

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - use fswatch
        if ! command_exists fswatch; then
            print_warning "fswatch not found"
            install_watcher
        fi

        print_status "Watching $input_file for changes..."
        print_status "Press 'r' + Enter to force rebuild, 'q' + Enter to quit"

        # Use fswatch to monitor the specific file
        fswatch -o "$input_file" 2>/dev/null | while read -r; do
            current_time=$(date +%s.%N)
            time_diff=$(echo "$current_time - $last_build_time" | bc -l 2>/dev/null || echo "999")

            if (( $(echo "$time_diff >= $DEBOUNCE_TIME" | bc -l 2>/dev/null || echo "1") )); then
                print_status "File changed, rebuilding..."
                build_project "$project_name" "$format"
                last_build_time=$current_time
            else
                print_status "Change detected, debouncing..."
            fi
        done &

    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux - use inotifywait
        if ! command_exists inotifywait; then
            print_warning "inotifywait not found"
            install_watcher
        fi

        print_status "Watching $input_file for changes..."
        print_status "Press 'r' + Enter to force rebuild, 'q' + Enter to quit"

        while true; do
            # Wait for file modification
            if inotifywait -e modify "$input_file" >/dev/null 2>&1; then
                current_time=$(date +%s.%N)
                time_diff=$(echo "$current_time - $last_build_time" | bc -l 2>/dev/null || echo "999")

                if (( $(echo "$time_diff >= $DEBOUNCE_TIME" | bc -l 2>/dev/null || echo "1") )); then
                    print_status "File changed, rebuilding..."
                    build_project "$project_name" "$format"
                    last_build_time=$current_time
                else
                    print_status "Change detected, debouncing..."
                fi
            fi
        done &
    else
        print_error "File watching not supported on this OS"
        exit 1
    fi

    # Store the background process PID
    local watcher_pid=$!

    # Handle user input
    while true; do
        read -r input
        case "$input" in
            "r"|"R")
                print_status "Force rebuilding..."
                build_project "$project_name" "$format"
                ;;
            "q"|"Q")
                print_status "Stopping watcher..."
                kill $watcher_pid 2>/dev/null || true
                exit 0
                ;;
            *)
                print_status "Unknown command. Use 'r' to rebuild, 'q' to quit."
                ;;
        esac
    done
}

# Signal handler for clean exit
cleanup() {
    print_status "Stopping watcher..."
    exit 0
}

trap cleanup SIGINT SIGTERM

# Parse arguments
if [ $# -eq 0 ]; then
    print_error "Please provide a project name"
    echo ""
    print_usage
    exit 1
fi

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    print_usage
    exit 0
fi

PROJECT_NAME="$1"
FORMAT="${2:-$DEFAULT_FORMAT}"

# Validate format
if [[ "$FORMAT" != "svg" && "$FORMAT" != "pdf" ]]; then
    print_error "Invalid format: $FORMAT"
    print_error "Supported formats: svg, pdf"
    exit 1
fi

INPUT_FILE="$PROJECTS_DIR/$PROJECT_NAME.cst"

# Print header
echo -e "${PURPLE}╔══════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║       CircuitScript Watch Tool          ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════╝${NC}"
echo ""

# Validate input file exists
if [ ! -f "$INPUT_FILE" ]; then
    print_error "Project file not found: $INPUT_FILE"
    echo ""
    print_status "Available projects:"
    if [ -d "$PROJECTS_DIR" ]; then
        for file in "$PROJECTS_DIR"/*.cst; do
            if [ -f "$file" ]; then
                basename "$file" .cst | sed 's/^/  - /'
            fi
        done
    else
        echo "  (No projects directory found)"
    fi
    exit 1
fi

# Check if circuitscript is installed
if ! command_exists circuitscript; then
    print_error "circuitscript CLI not found"
    print_status "Please install it with: npm install -g circuitscript"
    exit 1
fi

print_status "Project: $PROJECT_NAME"
print_status "Format: $FORMAT"
print_status "Input: $INPUT_FILE"
print_status "Output: $OUTPUT_DIR/$PROJECT_NAME.$FORMAT"
echo ""

# Initial build
print_status "Performing initial build..."
build_project "$PROJECT_NAME" "$FORMAT"
echo ""

# Start watching
watch_files "$PROJECT_NAME" "$FORMAT"
