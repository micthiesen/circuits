#!/bin/bash

# Create new atopile project from sample template
# Usage: ./scripts/new-project.sh project-name

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if project name is provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: Please provide a project name${NC}"
    echo "Usage: $0 <project-name>"
    echo "Example: $0 fogger"
    exit 1
fi

PROJECT_NAME="$1"
PROJECT_DIR="projects/$PROJECT_NAME"
SAMPLE_DIR="projects/sample"

# Check if we're in the right directory
if [ ! -d "projects/sample" ]; then
    echo -e "${RED}Error: Must be run from circuits root directory${NC}"
    exit 1
fi

# Check if project already exists
if [ -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Error: Project '$PROJECT_NAME' already exists${NC}"
    exit 1
fi

echo -e "${BLUE}Creating new project: $PROJECT_NAME${NC}"

# Create project directory
mkdir -p "$PROJECT_DIR"

# Create relative symlinks to shared files
echo "Creating symlinks..."
cd "$PROJECT_DIR"

# Symlink shared files (relative paths)
ln -s "../sample/ato.yaml" ato.yaml
ln -s "../sample/layouts" layouts

# Copy files that should be unique per project
echo "Copying project-specific files..."
cp "../sample/main.ato" main.ato
cp "../sample/README.md" README.md

# Replace placeholder in README
sed -i.bak "s/PROJECT_NAME/$PROJECT_NAME/g" README.md
rm README.md.bak

# Go back to project root
cd - > /dev/null

echo -e "${GREEN}✅ Project '$PROJECT_NAME' created successfully!${NC}"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_DIR"
echo "  # Edit main.ato to define your circuit"
echo "  # Edit README.md to document your project"
echo "  ato build"
echo ""
echo "Files created:"
echo "  📁 $PROJECT_DIR/"
echo "  🔗 ato.yaml (symlink)"
echo "  🔗 layouts/ (symlink)"
echo "  📄 main.ato (copy)"
echo "  📄 README.md (copy)"
