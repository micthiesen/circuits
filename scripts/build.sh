#!/bin/bash

# CircuitScript Build Script
# Builds CircuitScript projects to SVG and PDF formats
# Usage: ./scripts/build.sh <project-name>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Navigate to the project root (parent of scripts directory)
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Configuration
PROJECTS_DIR="$PROJECT_ROOT/projects"
OUTPUT_DIR="$PROJECT_ROOT/output"

# Function to print usage
print_usage() {
    echo -e "${BLUE}CircuitScript Build Tool${NC}"
    echo ""
    echo "Usage: $0 <project-name>"
    echo ""
    echo "Arguments:"
    echo "  project-name    Name of the project to build (without .cst extension)"
    echo ""
    echo "Examples:"
    echo "  $0 fogger       # Builds projects/fogger.cst"
    echo ""
    echo "Output:"
    echo "  SVG: output/<project-name>.svg"
    echo "  PDF: output/<project-name>.pdf"
}

# Function to print colored status messages
print_status() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if project name is provided
if [ $# -eq 0 ]; then
    print_error "Please provide a project name"
    echo ""
    print_usage
    exit 1
fi

# Check for help flag
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    print_usage
    exit 0
fi

PROJECT_NAME="$1"
INPUT_FILE="$PROJECTS_DIR/$PROJECT_NAME.cst"
SVG_OUTPUT="$OUTPUT_DIR/$PROJECT_NAME.svg"
PDF_OUTPUT="$OUTPUT_DIR/$PROJECT_NAME.pdf"

echo -e "${PURPLE}╔══════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║        CircuitScript Build Tool          ║${NC}"
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
if ! command -v circuitscript &> /dev/null; then
    print_error "circuitscript CLI not found"
    print_status "Please install it with: npm install -g circuitscript"
    exit 1
fi

# Create output directory if it doesn't exist
if [ ! -d "$OUTPUT_DIR" ]; then
    print_status "Creating output directory: $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"
fi

print_status "Building project: $PROJECT_NAME"
print_status "Input file: $INPUT_FILE"
print_status "Output directory: $OUTPUT_DIR"
echo ""

# Build SVG
print_status "🎨 Generating SVG schematic..."
if circuitscript "$INPUT_FILE" "$SVG_OUTPUT"; then
    print_success "SVG generated: $SVG_OUTPUT"
else
    print_error "Failed to generate SVG"
    exit 1
fi

# Build PDF
print_status "📄 Generating PDF schematic..."
if circuitscript "$INPUT_FILE" "$PDF_OUTPUT"; then
    print_success "PDF generated: $PDF_OUTPUT"
else
    print_error "Failed to generate PDF"
    exit 1
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Build Complete!             ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
print_success "Project '$PROJECT_NAME' built successfully"
echo ""
echo "Output files:"
echo -e "  📊 SVG: ${CYAN}$SVG_OUTPUT${NC}"
echo -e "  📋 PDF: ${CYAN}$PDF_OUTPUT${NC}"
echo ""

# Get file sizes for user feedback
if [ -f "$SVG_OUTPUT" ]; then
    SVG_SIZE=$(du -h "$SVG_OUTPUT" | cut -f1)
    echo -e "  SVG size: ${YELLOW}$SVG_SIZE${NC}"
fi

if [ -f "$PDF_OUTPUT" ]; then
    PDF_SIZE=$(du -h "$PDF_OUTPUT" | cut -f1)
    echo -e "  PDF size: ${YELLOW}$PDF_SIZE${NC}"
fi

echo ""
print_status "Build completed in $SECONDS seconds"
